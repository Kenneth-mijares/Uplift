import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_bounding_box_painter.dart';  // Custom Painter for drawing the bounding box

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  late List<Face> _faces;
  late Size _imageSize;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _faces = [];

    // Initialize the camera and load available cameras
    _initializeCamera();
    
    // Initialize the FaceDetector
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
      ),
    );
  }

  // Fetch available cameras and initialize the controller
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras(); // Get the list of available cameras

    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras[0], // Use the first camera in the list (adjust if you want a different one)
        ResolutionPreset.high,
      );
      await _cameraController.initialize();

      if (!mounted) return;

      setState(() {}); // Refresh UI when the camera is initialized

      // Start the image stream after initializing the camera
      _cameraController.startImageStream(_processCameraImage);
    } else {
      // Handle error if no cameras are available
      print("No cameras available");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  // Process camera frames and detect faces
  void _processCameraImage(CameraImage image) async {
  if (_cameraController.value.isStreamingImages) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Get the format and bytes per row from the camera image planes
    InputImageFormat format = InputImageFormat.nv21;  // Set a format (nv21 or yuv_420_888, etc.)
    int bytesPerRow = image.planes[0].bytesPerRow;

    // Correct the use of InputImage and InputImageMetadata
    final inputImage = InputImage.fromBytes(
      bytes: bytes,  // Pass bytes here
      metadata: InputImageMetadata(  // Pass metadata with size, rotation, format, and bytesPerRow
        size: imageSize,
        rotation: InputImageRotation.rotation0deg,  // Change rotation if needed
        format: format,  // Pass image format
        bytesPerRow: bytesPerRow,  // Pass bytes per row
      ),
    );

    // Detect faces in the image
    final faces = await _faceDetector.processImage(inputImage);

    // Check if the widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        _faces = faces;
        _imageSize = imageSize;  // Keep track of the image size
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Face Detection'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController), // Display camera preview
          CustomPaint(
            painter: FaceBoundingBoxPainter(_faces, _imageSize.width, _imageSize.height),
          ), // Custom painter to draw bounding boxes around faces
        ],
      ),
    );
  }
}
