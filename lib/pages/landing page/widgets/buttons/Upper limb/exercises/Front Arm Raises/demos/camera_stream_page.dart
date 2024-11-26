import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CameraStreamPage extends StatefulWidget {
  final String serverUrl;

  const CameraStreamPage({required this.serverUrl, super.key});

  @override
  _CameraStreamPageState createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;

  bool _isStreaming = true;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.medium);

    await _controller.initialize();
    setState(() {});

    // Start streaming frames to the server
    streamFrames();
  }

  Future<void> streamFrames() async {
    while (_isStreaming) {
      try {
        // Capture frame
        final XFile image = await _controller.takePicture();
        final Uint8List imageBytes = await image.readAsBytes();

        // Send the frame to the server
        final response = await http.post(
          Uri.parse(widget.serverUrl),
          headers: {'Content-Type': 'application/octet-stream'},
          body: imageBytes,
        );

        if (response.statusCode != 200) {
          print("Error from server: ${response.statusCode}");
        }
      } catch (e) {
        print("Error streaming frame: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Stream"),
        actions: [
          IconButton(
            icon: Icon(_isStreaming ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isStreaming = !_isStreaming;
              });
            },
          ),
        ],
      ),
      body: CameraPreview(_controller),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
