import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexi/camera/function_camera/function_camera.dart';

class UiCamera extends StatefulWidget {
  final String currentUserId;
  final String remoteUserId;
  final bool isCaller;

  const UiCamera({
    super.key,
    required this.currentUserId,
    required this.remoteUserId,
    required this.isCaller,
  });

  @override
  State<UiCamera> createState() => _UiCameraState();
}

class _UiCameraState extends State<UiCamera> {
  late CallService _callService;
  bool _callAnswered = false;

  @override
  void initState() {
    super.initState();

    _callService = CallService(
      currentUserId: widget.currentUserId,
      remoteUserId: widget.remoteUserId,
    );

    _startCallProcess();
  }

  Future<void> _startCallProcess() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _callService.initRenderers();

      if (widget.isCaller) {

        await _callService.makeCall();
        setState(() {
          _callAnswered = true;
        });
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and microphone permissions required')),
      );
    }
  }

  Future<void> _requestPermissionsAndAnswer() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _callService.answerCall();
      setState(() {
        _callAnswered = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and microphone permissions required')),
      );
    }
  }

  @override
  void dispose() {
    if (_callAnswered) {
      _callService.endCall();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCaller ? 'Outgoing call' : 'Incoming call'),
      ),
      body: Center(
        child: _callAnswered
            ? Column(
          children: [
            Expanded(child: RTCVideoView(_callService.remoteRenderer)),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: RTCVideoView(
                _callService.localRenderer,
                mirror: true,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _callService.endCall();
                Navigator.pop(context);
              },
              child: const Text('End call'),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: _requestPermissionsAndAnswer,
          child: const Text('Answer'),
        ),
      ),
    );
  }
}
