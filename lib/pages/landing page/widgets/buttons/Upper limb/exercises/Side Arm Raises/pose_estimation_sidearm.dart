import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teachable/teachable.dart';
import 'package:capstone/pages/landing%20page/widgets/service/firestore_service.dart';

class PoseEstimationSidearm extends StatefulWidget {
  const PoseEstimationSidearm({super.key});

  @override
  State<PoseEstimationSidearm> createState() => _PoseEstimationSidearmState();
}

class _PoseEstimationSidearmState extends State<PoseEstimationSidearm> {
  final FirestoreService _firestoreService = FirestoreService();
  String? poseResult;
  String? firstpose;
  String? secondpose;
  String displayText = ''; // Message to display
  int remainingTime = 30; // Timer starts at 30 seconds
  Timer? timer; // Timer instance
  bool isTimerRunning = false; // To track if the timer has started

  Future<void> startTimerWithDelay() async {
    setState(() {
      displayText = 'Get ready...';
    });

    // Add a 5-second delay before starting the timer
    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      displayText = ''; // Clear "Get ready..." message
      isTimerRunning = true;
      remainingTime = 30;
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
      displayText = 'Exercise Completed!';
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
        exerciseName: 'Shoulder Rotation',
        dateOfCompletion: DateTime.now(),
        completionStatus: 'Partial', // Mark as partial
      );

      setState(() {
        isTimerRunning = false;
        displayText = 'Exercise Stopped';
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

  @override
  void dispose() {
    timer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Side Arm Raises"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Teachable(
                  path: "assets/html/index.html",
                  results: (res) {
                    var resp = jsonDecode(res);
                    setState(() {
                      poseResult = resp.toString();
                      firstpose = (resp['arm lowered'] * 100.0).toInt().toString();
                      secondpose = (resp['arm raised'] * 100.0).toInt().toString();
                    });

                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() {
                        double firstPoseValue = double.tryParse(firstpose ?? '0') ?? 0;
                        double secondPoseValue = double.tryParse(secondpose ?? '0') ?? 0;

                        if (firstPoseValue > secondPoseValue) {
                          displayText = 'Raise arms gently';
                        } else if (secondPoseValue > firstPoseValue) {
                          displayText = 'Lower arms carefully';
                        } else {
                          displayText = '';
                        }
                      });
                    });

                    print("Pose Estimation Result: $resp");
                  },
                ),
              ),
              if (poseResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.black54,
                    child: Text(
                      'Pose:\n arm down $firstpose\n arm raised $secondpose ',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              if (isTimerRunning)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Remaining Time: $remainingTime seconds',
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              if (!isTimerRunning)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: startTimerWithDelay,
                    child: const Text('Start Timer'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _showStopConfirmationDialog,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
