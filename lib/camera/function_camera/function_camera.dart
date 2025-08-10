import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';

// Serwis obsługujący połączenia wideo/głosowe z użyciem WebRTC
// i Firebase Realtime Database jako kanału sygnalizacyjnego.
class CallService {
  final String currentUserId;
  final String remoteUserId;
  Function? onRemoteStreamSet; // Callback po ustawieniu zdalnego strumienia wideo

  late RTCPeerConnection _peerConnection; // Główne połączenie WebRTC
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();  // Podgląd kamery lokalnej
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer(); // Wideo rozmówcy

  final DatabaseReference db = FirebaseDatabase.instance.ref();

  // Subskrypcje zdarzeń z Firebase
  StreamSubscription? _candidatesSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _offerSubscription;

  CallService({required this.currentUserId, required this.remoteUserId});

  // Inicjalizacja rendererów wideo (obowiązkowa przed ich użyciem)
  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  // Konfiguracja połączenia WebRTC i strumieni audio/wideo
  Future<void> initializePeerConnection() async {
    // Konfiguracja serwerów ICE (STUN/TURN)
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, // STUN publiczny Google
        {
          'urls': 'turn:your_turn_server.com:3478', // Serwer TURN (do połączeń za NAT)
          'username': 'user',
          'credential': 'pass'
        },
      ],
    };

    // Parametry oferty SDP
    final offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    // Jeśli był wcześniej ustawiony lokalny strumień, usuń go
    if (localRenderer.srcObject != null) {
      for (var track in localRenderer.srcObject!.getTracks()) {
        track.stop();
      }
      localRenderer.srcObject = null;
    }

    // Tworzenie połączenia WebRTC
    _peerConnection = await createPeerConnection(configuration, offerSdpConstraints);

    // Wysyłanie ICE candidate do drugiej strony
    _peerConnection.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null && candidate.candidate != null) {
        print('We send ICE candidate: ${candidate.candidate}');
        db.child('calls/$remoteUserId/candidates').push().set(candidate.toMap());
      }
    };

    // Odbieranie strumienia od rozmówcy
    _peerConnection.onTrack = (RTCTrackEvent event) {
      print('Track received: ${event.track.kind}');
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        print('Setting up a remote video stream');
        // Jeśli był już jakiś strumień, zatrzymaj go
        if (remoteRenderer.srcObject != null) {
          for (var track in remoteRenderer.srcObject!.getTracks()) {
            track.stop();
          }
        }
        // Ustaw nowy strumień wideo
        remoteRenderer.srcObject = event.streams[0];
        if (onRemoteStreamSet != null) {
          onRemoteStreamSet!();
        }
      }
    };

    // Pobranie lokalnego audio/wideo z kamery i mikrofonu
    final mediaStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    // Podgląd lokalnego wideo
    localRenderer.srcObject = mediaStream;

    // Dodanie lokalnych tracków do połączenia
    for (var track in mediaStream.getTracks()) {
      await _peerConnection.addTrack(track, mediaStream);
      print('Local track added: ${track.kind}');
    }
  }

  // Tworzy ofertę połączenia i wysyła ją do drugiego użytkownika
  Future<void> makeCall() async {
    await initializePeerConnection();

    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    // Zapis oferty w Firebase
    await db.child('calls/$remoteUserId/offer').set({
      'sdp': offer.sdp,
      'type': offer.type,
      'callerId': currentUserId,
    });

    // Oczekiwanie na odpowiedź (answer)
    _answerSubscription = db.child('calls/$currentUserId/answer').onValue.listen((event) async {
      final val = event.snapshot.value;
      if (val is Map && val['sdp'] != null && val['type'] != null) {
        final answer = RTCSessionDescription(val['sdp'], val['type']);
        await _peerConnection.setRemoteDescription(answer);
      }
    });

    _listenForCandidates();
  }

  // Odbiera ofertę i wysyła odpowiedź (answer)
  Future<void> answerCall() async {
    await initializePeerConnection();
    _listenForCandidates();

    _offerSubscription = db.child('calls/$currentUserId/offer').onValue.listen((event) async {
      final offerDataRaw = event.snapshot.value;
      if (offerDataRaw is Map && offerDataRaw['sdp'] != null && offerDataRaw['type'] != null) {
        print('Received offer');
        final offer = RTCSessionDescription(offerDataRaw['sdp'], offerDataRaw['type']);
        await _peerConnection.setRemoteDescription(offer);

        // Tworzymy odpowiedź
        final answer = await _peerConnection.createAnswer();
        await _peerConnection.setLocalDescription(answer);

        print('Sending answer');
        await db.child('calls/$remoteUserId/answer').set(answer.toMap());

        // Po odpowiedzi przestajemy nasłuchiwać oferty
        await _offerSubscription?.cancel();
        _offerSubscription = null;
      }
    });
  }

  // Nasłuchiwanie kandydatów ICE od drugiej strony
  void _listenForCandidates() {
    _candidatesSubscription = db.child('calls/$currentUserId/candidates').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data is Map && data['candidate'] != null) {
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );
        print('Adding an ICE candidate: ${candidate.candidate}');
        _peerConnection.addCandidate(candidate);
      }
    });
  }

  // Kończy połączenie, usuwa dane z Firebase i czyści zasoby
  Future<void> endCall() async {
    await _peerConnection.close();
    await db.child('calls/$currentUserId').remove();
    await db.child('calls/$remoteUserId').remove();
    disposeRenderers();
    _cancelSubscriptions();
  }

  // Usuwa zasoby rendererów wideo
  void disposeRenderers() {
    localRenderer.dispose();
    remoteRenderer.dispose();
  }

  // Anuluje wszystkie subskrypcje zdarzeń z Firebase
  void _cancelSubscriptions() {
    _candidatesSubscription?.cancel();
    _answerSubscription?.cancel();
    _offerSubscription?.cancel();
  }

  // Pełne zwolnienie zasobów
  Future<void> dispose() async {
    _cancelSubscriptions();
    await _peerConnection.close();
    disposeRenderers();
  }
}
