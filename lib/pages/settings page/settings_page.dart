import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_details_page.dart'; // Import the EditDetailsPage

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String firstName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        setState(() {
          firstName = userDoc['first name'] ?? 'User';
        });
      }
    } catch (e) {
      print("Error loading user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 111, 128, 222),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Image.asset(
            'assets/icons/settingIcon.png',
            width: 400,
            height: 130,
          ),
          const SizedBox(height: 20),
          Text(
            'Hello $firstName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 13),
          const Text(
            'This page allows you to customize your personal Details. Adjust settings to your preferences.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Personal Details'),
            onTap: () async {
              // Navigate to EditDetailsPage and wait for the result
              bool? detailsUpdated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditDetailsPage()),
              );

              // If details were updated, reload user details
              if (detailsUpdated == true) {
                _loadUserDetails();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: FirebaseAuth.instance.signOut,
          ),
        ],
      ),
    );
  }
}
