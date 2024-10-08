
import 'package:capstone/pages/landing%20page/landing_page.dart';
import 'package:capstone/pages/maps%20page/maps_page.dart';
import 'package:capstone/pages/reports%20page/reports_page.dart';
import 'package:capstone/pages/settings%20page/settings_page.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

    int _currentIndex = 0;

  final List<Widget> _pages = [
     const LandingPage(), 
     const MapsPage(), 
     const ReportsPage(), 
     const SettingsPage(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(user.email!),
      //   backgroundColor: const Color.fromARGB(255, 129, 110, 150),
      //   actions: [
      //     GestureDetector(
      //         onTap: () {
      //           FirebaseAuth.instance.signOut();
      //         },
      //         child: (const Icon(Icons.logout)))
      //   ],
      // ),

      body: IndexedStack(
        
        
        index: _currentIndex,
        children: _pages,
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.local_hospital),
      //       label: 'Maps',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.trending_up),
      //       label: 'Reports',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      //   currentIndex: _currentIndex,
      //   onTap: _onItemTapped,
      // ),

      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
          child: GNav(
    
            gap: 8, // the tab button gap between icon and text 
            color: const Color.fromARGB(255, 118, 118, 118),
            activeColor: const Color.fromARGB(255, 111, 128, 222), // selected icon and text color
            iconSize: 24, // tab button icon size
            tabBackgroundColor: Colors.purple.withOpacity(0.1), // selected tab background color
            padding: const EdgeInsets.all(16), // navigation bar padding
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.map,
                text: 'Maps',
              ),
              GButton(
                icon: Icons.trending_up,
                text: 'Reports',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
              )
            ],
            selectedIndex: _currentIndex,
            onTabChange: _onItemTapped,
          
          ),
        ),
      ),
        
      
    );
  }
  

}