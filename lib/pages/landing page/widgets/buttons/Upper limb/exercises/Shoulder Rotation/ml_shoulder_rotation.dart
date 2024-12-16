import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:capstone/pages/landing%20page/widgets/service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:screenshot/screenshot.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:teachable/teachable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this for sound alarm

class MlShoulderRotation extends StatefulWidget {
  @override
  _MlShoulderRotationState createState() =>
      _MlShoulderRotationState();
}

class _MlShoulderRotationState
    extends State<MlShoulderRotation> {
  ScreenshotController screenshotController = ScreenshotController();
  FaceSDK faceSdk = FaceSDK.instance;

  final FirestoreService _firestoreService = FirestoreService();
  String? poseResult;
  String? firstpose;
  String? secondpose;

  String displayText = ''; // Message to display
  String countdownText ='';
  int remainingTime = 30; // Timer starts at 30 seconds
  Timer? timer; // Timer instance
  bool isTimerRunning = false;

  String similarityStatus = 'Unknown';
  MatchFacesImage? referenceImage;
  Timer? captureTimer;
  bool isProcessing = false;
  int failedMatchCount = 0; // Counter for failed matches

  Timer? poseCheckTimer;
  String? lastFirstPose;
  String? lastSecondPose;
  DateTime? lastPoseChangeTime;
  final AudioPlayer audioPlayer = AudioPlayer(); // Audio player instance

  String firstName = 'User';

  @override
  void initState() {
    super.initState();
    loadReferenceImage();
    startAutoCapture();
    startPoseCheckTimer();
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    poseCheckTimer?.cancel(); // Cancel pose check timer
    timer?.cancel();
    audioPlayer.dispose(); // Dispose of the audio player
    super.dispose();
  }

  void startPoseCheckTimer() {
    lastPoseChangeTime = DateTime.now();
    poseCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (firstpose != lastFirstPose || secondpose != lastSecondPose) {
        // Reset the timestamp if poses have changed
        lastPoseChangeTime = DateTime.now();
        lastFirstPose = firstpose;
        lastSecondPose = secondpose;
      }

      // Check if poses are unchanged for 20 seconds
      if (DateTime.now().difference(lastPoseChangeTime!).inSeconds >= 20) {
        timer.cancel(); // Stop the timer
        playSoundAlarm();
        showUnchangedPoseDialog();
      }
    });
  }

  Future<void> playSoundAlarm() async {
    try {
      await audioPlayer.play(AssetSource('alarm.mp3')); // Replace with your alarm sound file
    } catch (e) {
      print("Error playing sound: $e");
    }
  }
  Future<void> stopAlarm() async {
    await audioPlayer.stop();
  }

  void showUnchangedPoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pose Unchanged'),
          content: const Text(
              'Your pose has not changed for 20 seconds. Please adjust your posture.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // Restart pose check timer
                startPoseCheckTimer();
                stopAlarm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> startTimerWithDelay() async {
  setState(() {
    countdownText = 'Get ready... 5';  // Show "Get ready... 5"
  });

  // Countdown from 5 to 1
  for (int i = 6; i >= 1; i--) {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      countdownText = 'Get ready... $i'; // Update countdown number
    });
  }

  // After the countdown, start the timer
  await Future.delayed(const Duration(seconds: 1)); // Small delay before starting

  setState(() {
    countdownText = ''; // Clear "Get ready..." message
    isTimerRunning = true;
    remainingTime = 30; // Set the timer to 30 seconds
  });

  timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      if (remainingTime > 0) {
        remainingTime--;
      } else {
        timer.cancel();
        _completeExercise(); // Mark the exercise as completed
      }
    });
  });
}


  Future<void> _completeExercise() async {
    await _firestoreService.saveExerciseReport(
      exerciseName: 'Shoulder Rotation',
      dateOfCompletion: DateTime.now(),
      completionStatus: 'Completed', // Mark as completed
    );

    setState(() {
      isTimerRunning = false; // Reset the timer status
      countdownText = 'Exercise Completed!';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have successfully completed the exercise.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showStopConfirmationDialog() async {
    bool? shouldStop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Stop'),
          content: const Text(
              'Are you sure you want to stop the current exercise? Doing so will set the completion to partial.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      await _firestoreService.saveExerciseReport(
        exerciseName: 'Front Arm Raises',
        dateOfCompletion: DateTime.now(),
        completionStatus: 'Partial', // Mark as partial
      );

      setState(() {
        isTimerRunning = false;
        countdownText = 'Exercise Stopped';
      });

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Report Saved'),
            content: const Text('Your exercise report has been saved successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
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

      String email = FirebaseAuth.instance.currentUser!.email!;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        setState(() {
          firstName = userDoc['first name'] ?? 'User';
        });
      }

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
        if (matchedFaces.isNotEmpty) {
          // Reset the failed match counter on success
          failedMatchCount = 0;
          similarityStatus = '$firstName';
        } else {
          // Increment the failed match counter on failure
          failedMatchCount++;
          similarityStatus = 'Not Recognized';

          // Show alert dialog if failed matches reach six consecutive tries
          if (failedMatchCount >= 6) {
            failedMatchCount = 0; // Reset counter after showing the dialog
            showNotRecognizedDialog();
          }
        }
      });
    } catch (e) {
      print("Error during face match: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void showNotRecognizedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Not Recognized'),
          content: const Text(
              'You have not been recognized for six consecutive tries. Please check your setup or position.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
          title: Text("Shoulder Rotatation"),
        ),
        body: Column(
          children: [
            if (countdownText.isNotEmpty && displayText.isNotEmpty)
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                countdownText,
                style: const TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            
            // Display the pose instruction text
             if (countdownText.isEmpty && displayText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  displayText,
                  style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 111, 128, 222),),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Teachable(
                      path: "assets/html/shoulder_rotation.html",
                      results: (res) {
                        var resp = jsonDecode(res);
                        setState(() {
                          poseResult = resp.toString();
                          firstpose = (resp['open arms'] * 100.0).toInt().toString();
                          secondpose = (resp['close arms'] * 100.0).toInt().toString();
                        });
                                    
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            double firstPoseValue = double.tryParse(firstpose ?? '0') ?? 0;
                            double secondPoseValue = double.tryParse(secondpose ?? '0') ?? 0;
                                    
                            if (firstPoseValue > secondPoseValue) {
                   
                              displayText = 'close arms gently';
                            } else if (secondPoseValue > firstPoseValue) {
              
                              displayText = 'open arms carefully';
                            } 
                          });
                        });
                                    
                        print("Pose Estimation Result: $resp");
                      },
                    ),

                     // Face match status text and icon stacked on the upper left
                if (similarityStatus.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        // Icon for face match status
                        Icon(
                          similarityStatus.contains('$firstName')
                              ? Icons.verified
                              : Icons.cancel,
                          color: similarityStatus.contains('$firstName')
                              ? const Color.fromARGB(255, 109, 165, 233)
                              : Colors.red,
                          size: 30,
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        // Face match status text
                        Text(
                          '$similarityStatus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: similarityStatus.contains('$firstName')
                                ?  const Color.fromARGB(255, 255, 255, 255)
                                : Colors.red
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
              if (poseResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.black54,
                    child: Text(
                      'Pose:\n arms open $firstpose\n arms close $secondpose ',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

   
              
              Row(
                children: [
                  if (isTimerRunning)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Remaining Time: $remainingTime seconds',
                        style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 111, 128, 222),),
                      ),
                    ),
                  if (!isTimerRunning)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        onPressed: startTimerWithDelay,
                        style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 111, 128, 222), 
               
                        side: const BorderSide(color:Color.fromARGB(255, 111, 128, 222),
                        
                        ),
                      
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                        child: const Text('Start Timer'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      onPressed: _showStopConfirmationDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 111, 128, 222), 
               
                        side: const BorderSide(color:Color.fromARGB(255, 111, 128, 222),
                        
                        ),
                      
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Stop'),

                    ),
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }
}


