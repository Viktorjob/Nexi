import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';

class CallService {
  final String currentUserId;
  final String remoteUserId;
  Function? onRemoteStreamSet;
  late RTCPeerConnection _peerConnection;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  final DatabaseReference db = FirebaseDatabase.instance.ref();

  StreamSubscription? _candidatesSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _offerSubscription;

  CallService({required this.currentUserId, required this.remoteUserId});

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> initializePeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:your_turn_server.com:3478',
          'username': 'user',
          'credential': 'pass'
        },
      ],
    };

    final offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };
    if (localRenderer.srcObject != null) {
      for (var track in localRenderer.srcObject!.getTracks()) {
        track.stop();
      }
      localRenderer.srcObject = null;
    }
    _peerConnection = await createPeerConnection(configuration, offerSdpConstraints);

    _peerConnection.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null && candidate.candidate != null) {
        print('We send ICE candidate: ${candidate.candidate}');
        db.child('calls/$remoteUserId/candidates').push().set(candidate.toMap());
      }
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      print('Track received: ${event.track.kind}');
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        print('Setting up a remote video stream');
        if (remoteRenderer.srcObject != null) {
          for (var track in remoteRenderer.srcObject!.getTracks()) {
            track.stop();
          }
        }
        remoteRenderer.srcObject = event.streams[0];
        if (onRemoteStreamSet != null) {
          onRemoteStreamSet!();
        }
      }
    };

    final mediaStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = mediaStream;

    for (var track in mediaStream.getTracks()) {
      await _peerConnection.addTrack(track, mediaStream);
      print('Local track added: ${track.kind}');
    }
  }

  Future<void> makeCall() async {
    await initializePeerConnection();

    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    await db.child('calls/$remoteUserId/offer').set({
      'sdp': offer.sdp,
      'type': offer.type,
      'callerId': currentUserId,
    });

    _answerSubscription = db.child('calls/$currentUserId/answer').onValue.listen((event) async {
      final val = event.snapshot.value;
      if (val is Map && val['sdp'] != null && val['type'] != null) {
        final answer = RTCSessionDescription(val['sdp'], val['type']);
        await _peerConnection.setRemoteDescription(answer);
      }
    });

    _listenForCandidates();
  }

  Future<void> answerCall() async {
    await initializePeerConnection();
    _listenForCandidates();

    _offerSubscription = db.child('calls/$currentUserId/offer').onValue.listen((event) async {
      final offerDataRaw = event.snapshot.value;
      if (offerDataRaw is Map && offerDataRaw['sdp'] != null && offerDataRaw['type'] != null) {
        print('Received offer');
        final offer = RTCSessionDescription(offerDataRaw['sdp'], offerDataRaw['type']);
        await _peerConnection.setRemoteDescription(offer);

        final answer = await _peerConnection.createAnswer();
        await _peerConnection.setLocalDescription(answer);

        print('Sending answer');
        await db.child('calls/$remoteUserId/answer').set(answer.toMap());

        await _offerSubscription?.cancel();
        _offerSubscription = null;
      }
    });
  }

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

  Future<void> endCall() async {
    await _peerConnection.close();
    await db.child('calls/$currentUserId').remove();
    await db.child('calls/$remoteUserId').remove();
    disposeRenderers();
    _cancelSubscriptions();
  }

  void disposeRenderers() {
    localRenderer.dispose();
    remoteRenderer.dispose();
  }

  void _cancelSubscriptions() {
    _candidatesSubscription?.cancel();
    _answerSubscription?.cancel();
    _offerSubscription?.cancel();
  }

  Future<void> dispose() async {
    _cancelSubscriptions();
    await _peerConnection.close();
    disposeRenderers();
  }
}