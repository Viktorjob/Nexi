import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nexi/camera/function_camera/function_camera.dart';

class UiCamera extends StatefulWidget {
  final String currentUserId;
  final String remoteUserId;

  const UiCamera({super.key, required this.currentUserId, required this.remoteUserId});

  @override
  State<UiCamera> createState() => _UiCameraState();
}

class _UiCameraState extends State<UiCamera> {
  late CallService _callService;

  @override
  void initState() {
    super.initState();
    _callService = CallService(
      currentUserId: widget.currentUserId,
      remoteUserId: widget.remoteUserId,
    );
    _initCall();
  }

  Future<void> _initCall() async {
    await _callService.initRenderers();
    await _callService.makeCall();
    setState(() {});
  }

  @override
  void dispose() {
    _callService.endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video call')),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_callService.remoteRenderer),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: RTCVideoView(_callService.localRenderer, mirror: true),
          ),
          ElevatedButton(
            onPressed: () {
              _callService.endCall();
              Navigator.pop(context);
            },
            child: const Text('End call'),
          ),
        ],
      ),
    );
  }
}
