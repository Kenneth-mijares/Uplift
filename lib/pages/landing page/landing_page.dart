

import 'package:capstone/pages/landing%20page/widgets/buttons/button%201/big_Button.dart';
import 'package:flutter/material.dart';

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
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              SizedBox(height: 18),
              BigButton(),
           
              SizedBox(height: 18),
           
              SizedBox(height: 18),
          
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
