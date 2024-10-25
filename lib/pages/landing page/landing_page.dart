

import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/big_Button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: const Color.fromARGB(255, 111, 128, 222),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              //DISCOVER ARTICLES

              Text(
                'DISCOVER',
                   style: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:  Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
                
              ),
              const SizedBox(height: 12),

              const BigButton(), // TODO: edit this one out eg replace
            
              const SizedBox(height: 20),


              // RECOMMENDED WORK OUTS

              Text(
                'Recommended Workout',
                   style: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:  Color.fromARGB(255, 111, 128, 222), 
                        ),
                      ), 
                
              ),
              const SizedBox(height: 12),

              const BigButton(), // TODO: edit this one out eg replace, make it so that it reflects the needs of the user based on pre assessment

              const SizedBox(height: 20),

              // AVAILABLE EXERCISES

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
              const BigButton(),
           
              const SizedBox(height: 18),
           
              const SizedBox(height: 18),
          
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
