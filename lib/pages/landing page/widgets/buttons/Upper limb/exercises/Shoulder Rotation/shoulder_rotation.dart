
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/exercises/Shoulder%20Rotation/camera_page_shoulder_rotation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShoulderRotation extends StatefulWidget {
  const ShoulderRotation({super.key});

  @override
  State<ShoulderRotation> createState() => _ShoulderRotationState();
}

class _ShoulderRotationState extends State<ShoulderRotation> {
  final videoUrl = "https://www.youtube.com/watch?v=FYSOPmPyhlo"; // add youtube url
  
  late YoutubePlayerController _controller;
  final int startAt = 227; // Start the video 
  final int endAt = 276;   // Pause the video 

  @override
  void initState() {
    final videoID = YoutubePlayer.convertUrlToId(videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoID!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        startAt: startAt,
      ),
    );

    // Add a listener to the controller to monitor the current playback position
    _controller.addListener(() {
      // Check if the video time has reached or exceeded the endAt time
      if (_controller.value.position.inSeconds >= endAt) {
        _controller.pause();  // Pause the video at the specified time
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shoulder Rotation'), // add appbar title
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    width: 350,
                  ),
                ),
              ),

              const SizedBox(height: 23),

              Text(
                'INSTRUCTIONS',
                   style: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Sit or stand with your back straight and your shoulders relaxed. Keep your arms at your sides, with elbows bent at 90 degrees (a 'goalpost' position).",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ), 
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Slowly rotate your shoulders to open your arms outward, bringing your forearms away from your body while keeping elbows bent at 90 degrees.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Slowly bring your arms back toward the starting position (closed), keeping control of the motion.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                'COMMON MISTAKES',
                   style: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
              ),
              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.looks_one_outlined,
                   color: Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pushing the arms too far open can cause discomfort, especially after a stroke.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.looks_two_outlined,
                   color: Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tension in the neck or shoulders can affect movement and cause strain.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                'EFFECTIVE TIPS',
                   style: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.task_alt,
                   color: Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Open the arms only as far as is comfortable, increasing range gradually over time.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.task_alt,
                   color: Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "If adding resistance, start with no weight or a light resistance band to avoid strain.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.task_alt,
                   color: Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Maintain a relaxed posture with your chest open, shoulders back, and core engaged.",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(),
              const SizedBox(height: 5),

              Row(
              // Aligns buttons to the ends
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle close action
                      Navigator.of(context).pop(); // Closes the current screen
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 111, 128, 222), minimumSize: const Size(80, 50),
                      side: const BorderSide(color:Color.fromARGB(255, 111, 128, 222),
                       ),
                    
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12,),
                Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Navigate to the CameraPage when "Start" is pressed
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CameraPageShoulderRotation(),
                          ),
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 50),
                      backgroundColor: const Color.fromARGB(255, 111, 128, 222),
                      foregroundColor: const Color.fromARGB(255, 250, 250, 250),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                      child: const Text('Start'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
