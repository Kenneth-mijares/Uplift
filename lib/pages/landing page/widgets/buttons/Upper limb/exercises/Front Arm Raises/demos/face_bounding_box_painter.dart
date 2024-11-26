import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceBoundingBoxPainter extends CustomPainter {
  final List<Face> faces;
  final double imageWidth;
  final double imageHeight;

  FaceBoundingBoxPainter(this.faces, this.imageWidth, this.imageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      // Scale the bounding box to the size of the displayed camera image
      final scaleX = size.width / imageWidth;
      final scaleY = size.height / imageHeight;

      final scaledRect = Rect.fromLTWH(
        boundingBox.left * scaleX,
        boundingBox.top * scaleY,
        boundingBox.width * scaleX,
        boundingBox.height * scaleY,
      );

      canvas.drawRect(scaledRect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
