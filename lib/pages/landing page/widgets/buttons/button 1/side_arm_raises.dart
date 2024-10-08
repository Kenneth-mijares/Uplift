import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SideArmRaises extends StatefulWidget {
  const SideArmRaises({super.key});

  @override
  State<SideArmRaises> createState() => _SideArmRaisesState();
}

class _SideArmRaisesState extends State<SideArmRaises> {
  final videoUrl = "https://www.youtube.com/watch?v=FYSOPmPyhlo"; // add youtube url
  
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

              // Text(
              //   'COMMON MISTAKES',
              //      style: GoogleFonts.kanit(
              //           textStyle: const TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w600,
              //             color:  Color.fromARGB(255, 111, 128, 222), 
              //           ),
              //         ), 
                
              // ),

              // const SizedBox(height: 18),

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

              // const SizedBox(height: 12),

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

              // const SizedBox(height: 18),

   
            ],
          ),
        ),
      ),
    );
  }
}
