
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/exercises/Side%20Arm%20Raises/camera_page_side_arm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SideArmRaises extends StatefulWidget {
  const SideArmRaises({super.key});

  @override
  State<SideArmRaises> createState() => _SideArmRaisesState();
}

class _SideArmRaisesState extends State<SideArmRaises> {
  final videoUrl = "https://www.youtube.com/watch?v=FYSOPmPyhlo"; // add youtube url
  final flaskUrl = "http://192.168.177.116:5000"; // flask url
  
  late YoutubePlayerController _controller;
  final int startAt = 120; // Start the video 
  final int endAt = 170;   // Pause the video 

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

    _controller.addListener(() {
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
        title: const Text('Side Arm Raises'), // add appbar title
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
                          color:  Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Text("Slowly raise your arm out to the side, keeping your elbow slightly bent. Lift to shoulder height or as high as comfortable.",
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
                    child: Text("Slowly lower the arm back down to the starting position. Exhale as you raise the arm, inhale as you lower it.",
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
                          color:  Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.looks_one_outlined,
                   color:  Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Starting with a weight that is too heavy can strain muscles and lead to poor form.",
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
                   color:  Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Raising the arm too fast can cause jerky motions and increase the risk of injury.",
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
                  const Icon(Icons.looks_3_outlined,
                   color:  Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Pushing the arm beyond a comfortable range can cause discomfort, especially after a stroke.",
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
                          color:  Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.task_alt,
                   color:  Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Begin with no weight or a very light weight and increase as tolerated.",
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
                   color:  Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Watch your posture in a mirror or ask a caregiver to monitor the arm for proper form.",
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
                   color:  Color.fromARGB(255, 111, 128, 222),
                   size: 30,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Practice the exercise regularly to build strength and improve mobility over time.",
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
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
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
                        final uri = Uri.parse(flaskUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                        
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch URL')),
                          );
                        }
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
            ],
          ),
        ),
      ),
    );
  }
}
