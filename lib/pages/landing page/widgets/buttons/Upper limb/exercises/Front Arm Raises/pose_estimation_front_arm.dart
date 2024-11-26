import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teachable/teachable.dart';
import 'package:capstone/pages/landing%20page/widgets/service/firestore_service.dart';

class PoseEstimationFrontArm extends StatefulWidget {
  const PoseEstimationFrontArm({super.key});

  @override
  State<PoseEstimationFrontArm> createState() => _PoseEstimationFrontArmState();
}

class _PoseEstimationFrontArmState extends State<PoseEstimationFrontArm> {
  final FirestoreService _firestoreService = FirestoreService();
  String? poseResult;
  String? firstpose;
  String? secondpose; // Store the pose estimation results
  String displayText = ''; // This will hold the message to display

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
        completionStatus: 'Partial',
      );

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Report Saved'),
            content:
                const Text('Your exercise report has been saved successfully.'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pose Estimation"),
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
                      firstpose = (resp['arm lowered'] * 100.0).toInt().toString(); // Convert to int
                      secondpose = (resp['arm raised'] * 100.0).toInt().toString(); // Convert to int
                    });

                    // Update the display text with a delay
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
                      'Pose:\n arms lowered $firstpose\n arms raised $secondpose ',
                      style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ),
              // Display the text based on pose comparison
              if (displayText.isNotEmpty)
                Positioned(
                  bottom: 80,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.greenAccent,
                    child: Text(
                      displayText,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
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
