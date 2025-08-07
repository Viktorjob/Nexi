import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';

class CallService {
  final String currentUserId;
  final String remoteUserId;

  late RTCPeerConnection _peerConnection;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  CallService({required this.currentUserId, required this.remoteUserId});

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> initializePeerConnection() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    _peerConnection = await createPeerConnection(configuration, offerSdpConstraints);

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        db.child('calls/$remoteUserId/candidates').push().set({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    final mediaStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = mediaStream;
    for (var track in mediaStream.getTracks()) {
      _peerConnection.addTrack(track, mediaStream);
    }
  }


  Future<void> makeCall() async {
    await initializePeerConnection();

    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    db.child('calls/$remoteUserId/offer').set({
      'sdp': offer.sdp,
      'type': offer.type,
    });


    db.child('calls/$currentUserId/answer').onValue.listen((event) async {
      if (event.snapshot.value != null) {
        final answer = RTCSessionDescription(
          (event.snapshot.value as Map)['sdp'],
          (event.snapshot.value as Map)['type'],
        );
        await _peerConnection.setRemoteDescription(answer);
      }
    });

    db.child('calls/$currentUserId/candidates').onChildAdded.listen((event) {
      final data = event.snapshot.value as Map;
      final candidate = RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
      _peerConnection.addCandidate(candidate);
    });
  }

  Future<void> answerCall() async {
    await initializePeerConnection();

    final event = await db.child('calls/$currentUserId/offer').once();
    final offerDataRaw = event.snapshot.value;

    if (offerDataRaw == null) {
      print('Offer data is null — call not found');
      return;
    }

    final offerData = offerDataRaw as Map;
    final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
    await _peerConnection.setRemoteDescription(offer);

    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    await db.child('calls/$remoteUserId/answer').set(answer.toMap());

    db.child('calls/$currentUserId/candidates').onChildAdded.listen((event) {
      final data = event.snapshot.value as Map;
      final candidate = RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
      _peerConnection.addCandidate(candidate);
    });

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        db.child('calls/$remoteUserId/candidates').push().set(candidate.toMap());
      }
    };
  }



  void endCall() {
    _peerConnection.close();
    db.child('calls/$currentUserId').remove();
    db.child('calls/$remoteUserId').remove();
    localRenderer.dispose();
    remoteRenderer.dispose();
  }
}
