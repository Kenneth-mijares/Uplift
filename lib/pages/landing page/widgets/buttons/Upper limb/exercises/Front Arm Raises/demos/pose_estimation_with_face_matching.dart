import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:teachable/teachable.dart';

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

  @override
  void initState() {
    super.initState();
    loadReferenceImage();
  }

  Future<void> loadReferenceImage() async {
    // Load the reference image from assets
    ByteData assetData = await DefaultAssetBundle.of(context)
        .load("assets/images/reference_face.jpg");
    referenceImage = MatchFacesImage(
        assetData.buffer.asUint8List(), ImageType.PRINTED);
  }

  Future<void> captureAndMatchFace() async {
    // Capture the screen
    Uint8List? capturedImage =
        await screenshotController.capture(pixelRatio: 1.5);

    if (capturedImage == null || referenceImage == null) return;

    // Prepare the captured image for face matching
    MatchFacesImage capturedMatchImage =
        MatchFacesImage(capturedImage, ImageType.PRINTED);

    // Perform face matching
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
            ElevatedButton(
              onPressed: captureAndMatchFace,
              child: Text("Capture and Match Face"),
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
