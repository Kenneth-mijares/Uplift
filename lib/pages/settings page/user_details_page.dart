import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    super.dispose();
  }

 Future<void> updateUserDetails() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      await userDocRef.update({
        'first name': _firstNameController.text.trim(),
        'last name': _lastNameController.text.trim(),
        'gender': _genderController.text.trim(),
      });
    } else {
      await userDocRef.set({
        'first name': _firstNameController.text.trim(),
        'last name': _lastNameController.text.trim(),
        'email': user.email,
        'gender': _genderController.text.trim(),
      });
    }

    // Return to previous screen with a true result to indicate data was updated
    Navigator.pop(context, true);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserDetails,
              child: const Text('Update Details'),
            ),
          ],
        ),
      ),
    );
  }
}
