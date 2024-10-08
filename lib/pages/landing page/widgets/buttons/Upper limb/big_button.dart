import 'package:capstone/pages/landing%20page/widgets/buttons/Upper%20limb/button_page.dart';

import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  const BigButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ButtonPage()),
        );
      },
      child: Stack(
        alignment: Alignment.centerLeft, // Center the text on the image
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // Rounded edges for the image
            child: Image.asset(
              'assets/images/Stroke-feature-image.jpg',
              width: 400, // Adjust the width of the button (image)
              height: 130, // Adjust the height of the button (image)
              fit: BoxFit.cover, // Ensure the image covers the entire button space
             
            
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'UPPER LIMB',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white, // Text color
                fontWeight: FontWeight.bold,
               
              ),
            ),
          ),
        ],
      ),
    );
  }
}
