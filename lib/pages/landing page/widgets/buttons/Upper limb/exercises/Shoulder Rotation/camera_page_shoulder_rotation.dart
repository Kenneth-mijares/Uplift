import 'package:camera/camera.dart';
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/exercises/Shoulder%20Rotation/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPageShoulderRotation extends StatefulWidget {
  const CameraPageShoulderRotation({super.key});

  @override
  State<CameraPageShoulderRotation> createState() => _CameraPageShoulderRotationState();
}

class _CameraPageShoulderRotationState extends State<CameraPageShoulderRotation> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0;

  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  bool _isProcessing = false;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitializeCamera();
  }

  Future<void> _checkPermissionsAndInitializeCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    if (await Permission.camera.isGranted) {
      cameras = await availableCameras();

      if (cameras != null && cameras!.isNotEmpty) {
        await _initializeCamera(selectedCameraIndex: _getFrontCameraIndex());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found on this device.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required.')),
      );
    }
  }

  Future<void> _initializeCamera({required int selectedCameraIndex}) async {
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![selectedCameraIndex],
        ResolutionPreset.medium,
      );
      await _cameraController?.initialize();

      _cameraController?.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          _processImage(image);
        }
      });

      setState(() {});
    }
  }

  int _getFrontCameraIndex() {
    for (int i = 0; i < cameras!.length; i++) {
      if (cameras![i].lensDirection == CameraLensDirection.front) {
        return i;
      }
    }
    return 0;
  }

  int _getBackCameraIndex() {
    for (int i = 0; i < cameras!.length; i++) {
      if (cameras![i].lensDirection == CameraLensDirection.back) {
        return i;
      }
    }
    return 0;
  }

  void _switchCamera() {
    if (cameras != null && cameras!.isNotEmpty) {
      selectedCameraIndex = selectedCameraIndex == _getFrontCameraIndex()
          ? _getBackCameraIndex()
          : _getFrontCameraIndex();

      _initializeCamera(selectedCameraIndex: selectedCameraIndex);
    }
  }

  bool get isFrontCamera => cameras != null && cameras![selectedCameraIndex].lensDirection == CameraLensDirection.front;

  Future<void> _processImage(CameraImage image) async {
    try {
      final faces = await _faceDetectorService.detectFaces(image);
      setState(() {
        _faces = faces;
      });
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Shoulder Rotation Camera'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? Stack(
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(isFrontCamera ? 3.1416 : 0),
                        child: CameraPreview(_cameraController!),
                      ),
                      if (_faces.isNotEmpty)
                        CustomPaint(
                          painter: FacePainter(_faces, _cameraController!.value.previewSize!),
                        ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _switchCamera,
                  child: const Text('Switch Camera'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  FacePainter(this.faces, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * size.width / imageSize.width,
        face.boundingBox.top * size.height / imageSize.height,
        face.boundingBox.right * size.width / imageSize.width,
        face.boundingBox.bottom * size.height / imageSize.height,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
