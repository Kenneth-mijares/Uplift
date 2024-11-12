import 'package:camera/camera.dart';
import 'package:capstone/pages/landing%20page/widgets/service/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // For handling camera permissions

class CameraPageSideArm extends StatefulWidget {
  const CameraPageSideArm({super.key});

  @override
  State<CameraPageSideArm> createState() => _CameraPageSideArmState();
}

class _CameraPageSideArmState extends State<CameraPageSideArm> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0; // Keep track of which camera is being used

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitializeCamera();
  }

  // Check camera permission and initialize
  Future<void> _checkPermissionsAndInitializeCamera() async {
    // Request camera permission if not already granted
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    // If permission is granted, initialize the camera
    if (await Permission.camera.isGranted) {
      cameras = await availableCameras(); // Make sure we await the availableCameras function

      if (cameras != null && cameras!.isNotEmpty) {
        await _initializeCamera(selectedCameraIndex: _getFrontCameraIndex()); // Start with front camera
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

  // Initialize the camera with the selected camera index
  Future<void> _initializeCamera({required int selectedCameraIndex}) async {
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![selectedCameraIndex], 
        ResolutionPreset.medium,
      );
      await _cameraController?.initialize();
      setState(() {}); // Refresh the UI when the camera is ready
    }
  }

  // Get the index of the front camera
  int _getFrontCameraIndex() {
    for (int i = 0; i < cameras!.length; i++) {
      if (cameras![i].lensDirection == CameraLensDirection.front) {
        return i;
      }
    }
    return 0; // Default to back camera if no front camera found
  }

  // Get the index of the back camera
  int _getBackCameraIndex() {
    for (int i = 0; i < cameras!.length; i++) {
      if (cameras![i].lensDirection == CameraLensDirection.back) {
        return i;
      }
    }
    return 0; // Default to front camera if no back camera found
  }

  // Switch between front and back camera
  void _switchCamera() {
    if (cameras != null && cameras!.isNotEmpty) {
      selectedCameraIndex = selectedCameraIndex == _getFrontCameraIndex()
          ? _getBackCameraIndex()
          : _getFrontCameraIndex();

      _initializeCamera(selectedCameraIndex: selectedCameraIndex); // Reinitialize camera with new index
    }
  }

  // Check if the current camera is front-facing
  bool get isFrontCamera => cameras != null && cameras![selectedCameraIndex].lensDirection == CameraLensDirection.front;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Function to show the confirmation dialog when the user presses Stop and save to Firestore
  Future<void> _showStopConfirmationDialog() async {
    bool? shouldStop = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Stop'),
          content: const Text('Are you sure you want to stop the current Exercise now?/nDoing so will set the completion to partial'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels the action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms the action
              },
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );

    // If the user confirms, stop the camera, save the report, and navigate back
    if (shouldStop == true) {
      // Save the exercise report
      await _firestoreService.saveExerciseReport(
        exerciseName: 'Side Arm Raises', //change the name of the exercise
        dateOfCompletion: DateTime.now(),
        completionStatus: 'Partial', // Specify the completion status
      );

      // Navigate back to the previous screen
      Navigator.of(context).pop(); 

      // Show a confirmation dialog indicating that the report was saved
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Report Saved'),
            content: const Text('Your exercise report has been saved successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(isFrontCamera ? 3.1416 : 0), // Mirror front camera
                    child: CameraPreview(_cameraController!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showStopConfirmationDialog, // Show confirmation dialog when pressed
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: _switchCamera, // Switch camera when pressed
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
