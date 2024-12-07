import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:teachable/teachable.dart';
import 'package:path_provider/path_provider.dart';

class PoseEstimationWithFaceMatching extends StatefulWidget {
  @override
  _PoseEstimationWithFaceMatchingState createState() =>
      _PoseEstimationWithFaceMatchingState();
}

class _PoseEstimationWithFaceMatchingState
    extends State<PoseEstimationWithFaceMatching> {
  ScreenshotController screenshotController = ScreenshotController();
  FaceSDK faceSdk = FaceSDK.instance;

  String poseResult = '';
  String similarityStatus = 'Unknown';
  MatchFacesImage? referenceImage;

  Timer? captureTimer;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadReferenceImage();
    startAutoCapture();
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    super.dispose();
  }

  Future<void> loadReferenceImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      Directory appDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDir.path}/${user.uid}.png';

      File referenceFile = File(filePath);
      if (!referenceFile.existsSync()) throw Exception("Reference image not found.");

      Uint8List imageData = await referenceFile.readAsBytes();
      referenceImage = MatchFacesImage(imageData, ImageType.PRINTED);

      print("Reference image loaded successfully.");
    } catch (e) {
      print("Error loading reference image: $e");
      setState(() {
        similarityStatus = 'Reference image loading failed.';
      });
    }
  }

  Future<void> captureAndMatchFace() async {
    if (isProcessing || referenceImage == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      Uint8List? capturedImage =
          await screenshotController.capture(pixelRatio: 1.5);

      if (capturedImage == null) return;

      MatchFacesImage capturedMatchImage =
          MatchFacesImage(capturedImage, ImageType.PRINTED);

      MatchFacesRequest request =
          MatchFacesRequest([referenceImage!, capturedMatchImage]);
      var response = await faceSdk.matchFaces(request);
      var matchedFaces = response.results
          .where((result) => result.similarity > 0.75)
          .toList();

      setState(() {
        similarityStatus = matchedFaces.isNotEmpty
            ? 'Match: ${(matchedFaces[0].similarity * 100).toStringAsFixed(2)}%'
            : 'No Match';
      });
    } catch (e) {
      print("Error during face match: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void startAutoCapture() {
    captureTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      captureAndMatchFace();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Pose Estimation with Face Matching"),
        ),
        body: Column(
          children: [
            Expanded(
              child: Teachable(
                path: "assets/html/index.html",
                results: (res) {
                  setState(() {
                    poseResult = jsonDecode(res).toString();
                  });
                },
              ),
            ),
            if (poseResult.isNotEmpty)
              Text(
                'Pose Result: $poseResult',
                style: TextStyle(fontSize: 16),
              ),
            if (similarityStatus.isNotEmpty)
              Text(
                'Face Match Status: $similarityStatus',
                style: TextStyle(
                    fontSize: 16,
                    color: similarityStatus.contains('Match')
                        ? Colors.green
                        : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
