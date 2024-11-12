
import 'package:capstone/pages/landing%20page/widgets/buttons/Lower%20Limb/lower_limb_button.dart';
import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/upper_limb_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Exercises',
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        backgroundColor: const Color.fromARGB(255, 111, 128, 222),
      ),
      body: SingleChildScrollView(
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Container(
              color: const Color.fromARGB(255, 111, 128, 222),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/icons/exerciseIcon.png',
                    width: 400,
                    height: 130,
                  ),
                  const SizedBox(height: 10),
                              
                  const Text(
                    'Welcome Home! View available Exercises for your Stroke Recovery.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
             
                ],
              ),
            ),
      
            //DISCOVER ARTICLES
      
            // Text(
            //   'DISCOVER',
            //      style: GoogleFonts.kanit(
            //           textStyle: const TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.w600,
            //             color:  Color.fromARGB(255, 111, 128, 222), 
            //           ),
            //         ), 
              
            // ),
            // const SizedBox(height: 12),
      
            // const UpperLimbButton(), // TODO: edit this one out eg replace
          
            // const SizedBox(height: 20),
      
      
            // RECOMMENDED WORK OUTS
      
            // Text(
            //   'Recommended Workout',
            //      style: GoogleFonts.kanit(
            //           textStyle: const TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.w600,
            //             color:  Color.fromARGB(255, 111, 128, 222), 
            //           ),
            //         ), 
              
            // ),
            // const SizedBox(height: 12),
      
            // const UpperLimbButton(), // TODO: edit this one out eg replace, make it so that it reflects the needs of the user based on pre assessment
      
            // const SizedBox(height: 20),
      
      
      
      
      
            // AVAILABLE EXERCISES
      
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Exercises',
                       style: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color:  Color.fromARGB(255, 111, 128, 222), 
                            ),
                          ), 
                    
                  ),

                  const SizedBox(height: 12),
                  const UpperLimbButton(),
              
                  const SizedBox(height: 18),
                  const LowerLimbButton(),
              
                  const SizedBox(height: 18),
              
                  const SizedBox(height: 18),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
