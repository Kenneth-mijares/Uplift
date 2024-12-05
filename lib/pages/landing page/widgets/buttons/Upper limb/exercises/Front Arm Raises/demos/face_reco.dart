import 'dart:math';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


class FaceReco extends StatefulWidget {
  @override
  _FaceRecoState createState() => _FaceRecoState();
}

class _FaceRecoState extends State<FaceReco> {
  late Interpreter interpreter;
  bool isFaceDetected = false;
  String verificationResult = "";

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TFLite model for face embedding extraction
  Future<void> _loadModel() async {
    interpreter = await Interpreter.fromAsset('mobilefacerecogntiion.tflite');
  }

  // Pick an image and detect face
  Future<void> _detectFace() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    final faces = await faceDetector.processImage(inputImage);

    setState(() {
      isFaceDetected = faces.isNotEmpty;
    });

    if (faces.isNotEmpty) {
      print("Face detected");
      final embeddings = await _extractEmbeddings(image.path);
      await _saveFaceEmbeddings(embeddings);
    } else {
      print("No faces detected");
    }
  }

  // Extract embeddings from the image
  Future<List<double>> _extractEmbeddings(String imagePath) async {
    final imageInput = await _processImage(imagePath);
    var output = List<double>.filled(128, 0); // Size depends on your model output

    interpreter.run(imageInput, output);

    return output;
  }

  // Preprocess the image for the model
  Future<List<List<int>>> _processImage(String imagePath) async {
    // Add your image preprocessing here (resize, normalization, etc.)
    // Here, it's assumed that the image is processed into an appropriate format.
    return [[]]; // Just a placeholder for the image processing function
  }

  // Save the embeddings to Firebase
  Future<void> _saveFaceEmbeddings(List<double> embeddings) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'face_embeddings': embeddings,
      });
      print("Embeddings saved to Firebase");
    }
  }

  // Compare face embeddings
  Future<void> _verifyFace(String imagePath) async {
    final newEmbeddings = await _extractEmbeddings(imagePath);
    final storedEmbeddings = await _getStoredEmbeddings();

    if (newEmbeddings.isEmpty || storedEmbeddings.isEmpty) {
      setState(() {
        verificationResult = "No embeddings to compare.";
      });
      return;
    }

    final distance = _calculateCosineDistance(newEmbeddings, storedEmbeddings);
    setState(() {
      verificationResult = distance < 0.5 ? "Face matched!" : "Face not matched!";
    });
  }

  // Get stored embeddings from Firebase
  Future<List<double>> _getStoredEmbeddings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return List<double>.from(snapshot['face_embeddings']);
    }
    return [];
  }

  // Calculate cosine distance between two embedding vectors
  double _calculateCosineDistance(List<double> embedding1, List<double> embedding2) {
    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    return 1 - (dotProduct / (sqrt(norm1) * sqrt(norm2)));
  }

  @override
  void dispose() {
    interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _detectFace,
              child: Text("Detect Face and Save Embedding"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  await _verifyFace(image.path);
                }
              },
              child: Text("Verify Face"),
            ),
            SizedBox(height: 20),
            Text(
              isFaceDetected ? "Face Detected!" : "No face detected.",
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              verificationResult,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
