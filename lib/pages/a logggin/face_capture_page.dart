import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceCapturePage extends StatefulWidget {
  final String userId;
  
  const FaceCapturePage({super.key, required this.userId});
  
  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage> {
  var faceSdk = FaceSDK.instance;
  String _livenessStatus = "Not Started";
  String? _imagePath;
  Image? _uiImage;
  bool _processingComplete = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions().then((_) {
      _initializeFaceSDK().then((_) {
        startLiveness();
      });
    });
  }
  
  Future<void> _checkPermissions() async {
    // Request storage permission for saving to gallery
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }
  
  Future<void> _initializeFaceSDK() async {
    try {
      // Initialize FaceSDK if needed
      var license = await _loadAssetIfExists("assets/regula.license");
      InitConfig? config;
      if (license != null) config = InitConfig(license);
      
      var (success, error) = await faceSdk.initialize(config: config);
      if (!success && error != null) {
        print("${error.code}: ${error.message}");
        setState(() {
          _livenessStatus = "Initialization failed: ${error.message}";
        });
      }
    } catch (e) {
      print("Error initializing SDK: $e");
      setState(() {
        _livenessStatus = "Initialization error";
      });
    }
  }
  
  Future<ByteData?> _loadAssetIfExists(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }
  
  Future<void> startLiveness() async {
    try {
      setState(() {
        _livenessStatus = "Starting liveness check...";
        _processingComplete = false;
      });
      
      var result = await faceSdk.startLiveness(
        config: LivenessConfig(skipStep: [LivenessSkipStep.ONBOARDING_STEP]),
        notificationCompletion: (notification) {
          print("Liveness notification: ${notification.status}");
          setState(() {
            _livenessStatus = notification.status.toString();
          });
        },
      );
      
      if (result.image == null) {
        setState(() {
          _livenessStatus = "Failed to capture image";
          _processingComplete = true;
        });
        return;
      }
      
      // Update UI with the captured image
      setState(() {
        _uiImage = Image.memory(result.image!);
        _livenessStatus = result.liveness.name.toLowerCase();
        _processingComplete = true;
      });
      
      // Save the image for facial recognition
      await _saveReferenceImage(result.image!);
      
      if (_livenessStatus == "passed") {
        // Allow user to see the captured image briefly
        await Future.delayed(const Duration(seconds: 2));
        
        // Automatically return to registration page with image path
        Navigator.pop(context, _imagePath);
      }
    } catch (e) {
      print("Error during liveness check: $e");
      setState(() {
        _livenessStatus = "Error: $e";
        _processingComplete = true;
      });
    }
  }
  
  Future<void> _saveReferenceImage(Uint8List imageBytes) async {
    try {
      // Get the current user's UID from Firebase Auth
      String userId;
      if (FirebaseAuth.instance.currentUser != null) {
        userId = FirebaseAuth.instance.currentUser!.uid;
      } else {
        userId = widget.userId;
      }
      
      print("Saving reference image for user: $userId");
      
      // IMPORTANT: This is the path that PoseEstimationWithFaceMatching uses for face matching
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$userId.png';
      
      // Create the file and write image bytes to it - do not modify this format
      final File referenceFile = File(filePath);
      await referenceFile.writeAsBytes(imageBytes);
      
      // Save a copy to gallery as well (this won't affect the face matching)
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "FaceID_$userId",
      );
      
      print("Saved to gallery: $result");
      
      // Verify the reference file was created correctly
      if (await referenceFile.exists()) {
        final fileStats = await referenceFile.stat();
        print("Reference image saved successfully at: $filePath");
        print("Reference image file size: ${fileStats.size} bytes");
        
        // Double-check that the reference file can be read back
        final testRead = await referenceFile.readAsBytes();
        print("Reference image can be read: ${testRead.length} bytes");
      } else {
        print("Failed to save reference image at: $filePath");
      }
      
      setState(() {
        _imagePath = filePath;
      });
      
      // Also save a temporary copy for the registration flow
      // Make sure the format and location matches what PoseEstimationWithFaceMatching expects
      final tempDir = Directory('${appDir.path}/temp_$userId');
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      final tempImagePath = '${tempDir.path}/profile_image.jpg';
      final tempImageFile = File(tempImagePath);
      await tempImageFile.writeAsBytes(imageBytes);
      
    } catch (e) {
      print("Error saving reference image: $e");
      // Add more detailed error handling to help debug the issue
      if (e is FileSystemException) {
        print("File system error: ${e.message}, path: ${e.path}, osError: ${e.osError}");
      }
    }
  }
  
  void retryCapture() {
    startLiveness();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevents back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Face Capture"),
          automaticallyImplyLeading: false, // Disable back button
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Liveness Status: $_livenessStatus",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _imagePath != null 
                  ? Column(
                      children: [
                        ClipOval(
                          child: _uiImage != null
                              ? SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: _uiImage,
                                )
                              : Image.file(
                                  File(_imagePath!),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 20),
                        Text(_livenessStatus == "passed" 
                            ? "Verification Successful! Returning to signup..." 
                            : "Processing...", 
                          style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        _processingComplete == false
                            ? const CircularProgressIndicator()
                            : Container(),
                        if (_livenessStatus == "failed" && _processingComplete) 
                          ElevatedButton(
                            onPressed: retryCapture,
                            child: const Text("Retry"),
                          ),
                        if (_livenessStatus == "passed" && _processingComplete)
                          const CircularProgressIndicator(),
                      ],
                    ) 
                  : Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        const Text("Preparing camera...", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        const CircularProgressIndicator(),
                      ],
                    ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Please look at the camera and follow the on-screen instructions.\nThis image will be stored for exercise verification and saved to your gallery.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Image saved to both app storage and gallery",
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}