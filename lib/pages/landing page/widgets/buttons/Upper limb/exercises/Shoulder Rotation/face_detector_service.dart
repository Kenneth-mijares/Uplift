import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector;

  FaceDetectorService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate,
            enableContours: true,
            enableLandmarks: true,
          ),
        );

  Future<List<Face>> detectFaces(CameraImage image) async {
    try {
      // Convert CameraImage to InputImage
      final WriteBuffer allBytes = WriteBuffer();
      for (var plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      InputImageFormat format = InputImageFormat.nv21;  // Set a format (nv21 or yuv_420_888, etc.)
      int bytesPerRow = image.planes[0].bytesPerRow;

      final inputImage = InputImage.fromBytes(
      bytes: bytes,  // Pass bytes here
      metadata: InputImageMetadata(  // Pass metadata with size, rotation, format, and bytesPerRow
        size: imageSize,
        rotation: InputImageRotation.rotation0deg,  // Change rotation if needed
        format: format,  // Pass image format
        bytesPerRow: bytesPerRow,  // Pass bytes per row
      ),
    );

      // Process image and return detected faces
      return await _faceDetector.processImage(inputImage);
    } catch (e) {
      print('Error detecting faces: $e');
      return [];
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
