import 'package:capstone/pages/settings%20page/user_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String gender = "";

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['first name'] ?? "";
          lastName = userDoc['last name'] ?? "";
          email = userDoc['email'] ?? "";
          gender = userDoc['gender'] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: firstName.isEmpty ? _buildAddDetailsPrompt() : _buildUserDetails(),
      ),
    );
  }

  Widget _buildAddDetailsPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hello User!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'To personalize your experience, we recommend adding some details about you.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
  onPressed: () async {
    // Navigate to UserDetailsPage and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailsPage()),
    );

    // Check if details were updated
    if (result == true) {
      fetchUserDetails(); // Refresh user details
    }
  },
  child: const Text('Start now?'),
),

      ],
    );
  }

  Widget _buildUserDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
        const SizedBox(height: 20),
        Text(
          'Hello $firstName!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          'Your email: $email',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Gender: $gender',
          style: const TextStyle(fontSize: 16),
        ),
        // You can add more user details here
      ],
    );
  }
}
