import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexi/camera/function_camera/function_camera.dart';

// Ekran obsługujący UI połączenia wideo.
// Wykorzystuje CallService do logiki połączenia WebRTC.
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
  late CallService _callService; // Obsługa logiki połączenia
  bool _callAnswered = false;
  String callStatus = '';

  @override
  void initState() {
    super.initState();

    // Tworzymy instancję serwisu połączeń
    _callService = CallService(
      currentUserId: widget.currentUserId,
      remoteUserId: widget.remoteUserId,
    );

    // Po zbudowaniu widżetu rozpoczynamy proces połączenia
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _startCallProcess();
    });
  }

  Future<void> _startCallProcess() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    // Sprawdzamy, czy użytkownik przyznał oba uprawnienia
    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _callService.initRenderers();

      // Ustawiamy callback po otrzymaniu strumienia od rozmówcy
      _callService.onRemoteStreamSet = () {
        if (mounted) setState(() {});
      };

      // W zależności od trybu — dzwonimy lub odbieramy
      if (widget.isCaller) {
        await _callService.makeCall();
      } else {
        await _callService.answerCall();
      }

      // Ustawiamy status po połączeniu
      setState(() {
        _callAnswered = true;
        callStatus = 'Call connected';
      });
    } else {
      // Brak wymaganych uprawnień
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and microphone permissions required')),
      );
    }
  }

  @override
  void dispose() {
    // Jeżeli połączenie było aktywne, zakończ je
    if (_callAnswered) {
      _callService.endCall();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Nagłówek zależy od tego, czy to my dzwonimy, czy odbieramy
        title: Text(widget.isCaller ? 'Outgoing call' : 'Incoming call'),
      ),
      body: Center(
        child: _callAnswered
            ? Column(
          children: [

            Expanded(
              child: _callService.remoteRenderer.srcObject != null
                  ? RTCVideoView(_callService.remoteRenderer)
                  : const Center(child: Text("Connecting video...")),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 150,
              child: RTCVideoView(
                _callService.localRenderer,
                mirror: true, // Odbicie jak w lustrze
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
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(callStatus),
          ],
        ),
      ),
    );
  }
}
