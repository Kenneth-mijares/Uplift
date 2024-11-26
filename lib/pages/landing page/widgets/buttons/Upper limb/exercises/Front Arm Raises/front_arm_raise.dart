
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/exercises/Front%20Arm%20Raises/demos/face_detection_screen.dart';
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/exercises/Front%20Arm%20Raises/demos/flask.dart';
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/exercises/Front%20Arm%20Raises/pose_estimation_front_arm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FrontArmRaise extends StatefulWidget {
  const FrontArmRaise({super.key});

  @override
  State<FrontArmRaise> createState() => _FrontArmRaiseState();
}

class _FrontArmRaiseState extends State<FrontArmRaise> {
  final videoUrl = "https://www.youtube.com/watch?v=FYSOPmPyhlo"; // add youtube url
  final flaskUrl = "http://192.168.177.116:5000"; // flask url
  
  late YoutubePlayerController _controller;
  final int startAt = 173; // Start the video 
  final int endAt = 225;   // Pause the video 

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
        title: const Text('Lateral Arm Raises'), // add appbar title
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
                    child: 
                    Text("Start by sitting or standing with your back straight and feet shoulder-width apart. Slowly raise your arm out to the side with a slight bend in the elbow until it's parallel to the ground.",
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
                    child: 
                    Text("Pause briefly at the top, then lower your arm back down. Focus on controlled movements and stop if you feel pain.",
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
                    child: 
                    
                    Text("Slouching or leaning forward can strain the back and reduce effectiveness. ",
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
                    child: 
                    
                    Text("Pushing through pain can worsen injury.",
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
                    child: 
                    
                    Text("Swinging the arms instead of lifting them with control can lead to injury. ",
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

              // Row(
              //   children: [
              //     Expanded(
              //       child: 
              //       Text("lorem",
              //         style: GoogleFonts.nunito(
              //           textStyle: const TextStyle(
              //             fontSize: 15,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

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
                    child: 
                    
                    Text("Maintain a straight spine.",
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
                    child: 
                    
                    Text("If pain occurs, stop and reassess the technique.",
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
                    child: 
                    
                    Text("Focus on slow, controlled movements.",
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
                            //builder: (context) =>  const PoseEstimationFrontArm(),
                            builder: (context) =>   PoseEstimationFrontArm(),
                          ),
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 50),
                      backgroundColor: const Color.fromARGB(255, 111, 128, 222),
                      foregroundColor:  const Color.fromARGB(255, 250, 250, 250),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Start'),
                  ),
                ),

                // Expanded(
                //     child: ElevatedButton(
                //       onPressed: () async {
                //         final uri = Uri.parse(flaskUrl);
                //         if (await canLaunchUrl(uri)) {
                //           await launchUrl(uri);
                //         } else {
                //           ScaffoldMessenger.of(context).showSnackBar(
                //             const SnackBar(content: Text('Could not launch URL')),
                //           );
                //         }
                //       },

                //       style: ElevatedButton.styleFrom(
                //         minimumSize: const Size(80, 50),
                //         backgroundColor: const Color.fromARGB(255, 111, 128, 222),
                //         foregroundColor: const Color.fromARGB(255, 250, 250, 250),
                //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //       ),
                //       child: const Text('Start'),
                //     ),
                //   ),
              ],
            ),
         

   
            ],
          ),
        ),
      ),
    );
  }
}
