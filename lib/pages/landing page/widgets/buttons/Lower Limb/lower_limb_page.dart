import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class LowerLimbPage extends StatelessWidget {
  const LowerLimbPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of page widgets (each from a separate file)
    final List<Widget> pages = [
      // const SideArmRaises(),
      // const FrontArmRaise(),
    ];

    // List of names corresponding to each page
    final List<String> pageNames = [
      'Side Arm Raises',
      'Front Arm Raises',
    ];

    // List of subtitles corresponding to each page
    final List<String> pageSubtitles = [
      '00:30',
      '00:30',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200.0), // Set desired height
        child: AppBar(
          
          flexibleSpace: Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                
                child: Image.asset(
                    'assets/images/lowerLimb.png',
                    height: 250,
                    width: 400,
                    fit: BoxFit.cover, 
                    
                   
                  ),
              ),

              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                   mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                   crossAxisAlignment: CrossAxisAlignment.start,
                
                             
                  children: [

                    SizedBox(height: 40,),

                    Text(
                      'LOWER LIMB EXERCISES',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 20,),

                    Text(
                      '0 min | 0 workouts',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                    '0 min | 0 Workouts',
                       style: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color:  Color.fromARGB(255, 111, 128, 222), 
                            ),
                          ), 
                    
                  ),
                  const SizedBox(height: 20,),
              SizedBox(
                height: 500,
                child: ListView.separated(
                  itemCount: pages.length,
                  separatorBuilder: (context, index) => const Divider(), // Divider between items
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.fitness_center), // Leading icon
                      title: Text(pageNames[index]), // Title
                      subtitle: Text(pageSubtitles[index]), // Subtitle
                      trailing: const Icon(Icons.arrow_forward_ios), // Trailing icon
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pages[index], // Navigate to the selected page
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
