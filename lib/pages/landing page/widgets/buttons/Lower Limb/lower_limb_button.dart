import 'package:capstone/pages/landing%20page/widgets/buttons/Lower%20Limb/lower_limb_page.dart';


import 'package:flutter/material.dart';

class LowerLimbButton extends StatelessWidget {
  const LowerLimbButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LowerLimbPage()),
        );
      },
      child: Stack(
        alignment: Alignment.centerLeft, // Center the text on the image
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // Rounded edges for the image
            child: Image.asset(
              'assets/images/lowerLimb.png',
              width: 400, // Adjust the width of the button (image)
              height: 130, // Adjust the height of the button (image)
              fit: BoxFit.cover, // Ensure the image covers the entire button space
             
            
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOWER LIMB',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold,
                   
                  ),
                ),
                Text(
                  '3 workouts | 1 min',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold,
                   
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
