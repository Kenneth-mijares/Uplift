// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class UserDetailsPage extends StatefulWidget {
//   final String userId;

//   const UserDetailsPage({super.key, required this.userId});

//   @override
//   State<UserDetailsPage> createState() => _UserDetailsPageState();
// }

// class _UserDetailsPageState extends State<UserDetailsPage> {
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _genderController = TextEditingController();
//   final _birthDateController = TextEditingController();

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _genderController.dispose();
//     _birthDateController.dispose();
//     super.dispose();
//   }

//   Future saveUserDetails(String firstName, String lastName, String gender, String birthDate, String email) async {
    
//     await FirebaseFirestore.instance.collection('users').add({
//       'firstName': firstName,
//       'lastName': lastName,
//       'gender': gender,
//       'birthdate': birthDate,
//       'email': FirebaseAuth.instance.currentUser?.email,
//     });

//     Navigator.pop(context); // Return to the SettingsPage
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Additional Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _firstNameController,
//               decoration: const InputDecoration(labelText: "First Name"),
//             ),
//             TextField(
//               controller: _lastNameController,
//               decoration: const InputDecoration(labelText: "Last Name"),
//             ),
//             TextField(
//               controller: _genderController,
//               decoration: const InputDecoration(labelText: "Gender"),
//             ),
//             TextField(
//               controller: _birthDateController,
//               decoration: const InputDecoration(labelText: "Birthdate"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: saveUserDetails,
//               child: const Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
