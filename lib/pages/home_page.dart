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
    // Optionally force reload of a specific page's state here
    // For example, you could add custom page-specific refresh logic
    if (_currentIndex == 0) {
      // Trigger refresh for LandingPage if selected
      // e.g., LandingPage().key = UniqueKey(); to force rebuild
    } else if (_currentIndex == 1) {
      // Trigger refresh for MapsPage if selected
    } else if (_currentIndex == 2) {
      // Trigger refresh for ReportsPage if selected
    } else if (_currentIndex == 3) {
      // Trigger refresh for SettingsPage if selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: GNav(
            gap: 8,
            color: const Color.fromARGB(255, 118, 118, 118),
            activeColor: const Color.fromARGB(255, 111, 128, 222),
            iconSize: 24,
            tabBackgroundColor: Colors.purple.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
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
              ),
            ],
            selectedIndex: _currentIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
