import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _initializeFaceSDK().then((_) {
      startLiveness();
    });
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
      
      // Save the image in the format needed for facial recognition
      await _saveImageForFacialRecognition(result.image!);
      
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
  
  Future<void> _saveImageForFacialRecognition(Uint8List imageBytes) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Get current user ID - use the one passed in the widget or from Firebase Auth
      String userId = widget.userId;
      if (userId.isEmpty && FirebaseAuth.instance.currentUser != null) {
        userId = FirebaseAuth.instance.currentUser!.uid;
      }
      
      // Save the image with the user ID as the filename (matching PoseEstimationWithFaceMatching)
      final imagePath = '${directory.path}/$userId.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      
      // Also save a copy in the temporary directory for returning to registration page
      final tempDirectory = await getApplicationDocumentsDirectory();
      final tempUserDir = Directory('${tempDirectory.path}/temp_${userId}');
      if (!await tempUserDir.exists()) {
        await tempUserDir.create(recursive: true);
      }
      final tempImagePath = '${tempUserDir.path}/profile_image.jpg';
      final tempImageFile = File(tempImagePath);
      await tempImageFile.writeAsBytes(imageBytes);
      
      setState(() {
        _imagePath = imagePath; // Return the permanent path
      });
      
      print("Reference image saved at: $imagePath");
      print("Temporary image saved at: $tempImagePath");
    } catch (e) {
      print("Error saving image: $e");
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
                  "Please look at the camera and follow the on-screen instructions for face verification.\nThis image will be used for facial recognition during exercises.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}