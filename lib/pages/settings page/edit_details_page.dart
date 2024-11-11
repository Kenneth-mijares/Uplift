import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditDetailsPage extends StatefulWidget {
  const EditDetailsPage({super.key});

  @override

  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user's email
      String email = FirebaseAuth.instance.currentUser!.email!;

      // Query Firestore to find the document with this email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        _firstNameController.text = userDoc['first name'] ?? '';
        _lastNameController.text = userDoc['last name'] ?? '';
        _emailController.text = userDoc['email'] ?? '';
        _genderController.text = userDoc['gender'] ?? '';
        _ageController.text = userDoc['age']?.toString() ?? '';
      }
    } catch (e) {
      print("Error loading user details: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserDetails() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Get the current user's email
    String email = FirebaseAuth.instance.currentUser!.email!;

    // Query Firestore to find the document with this email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDocId = querySnapshot.docs.first.id;

      // Update the document with new details
      await FirebaseFirestore.instance.collection('users').doc(userDocId).update({
        'first name': _firstNameController.text.trim(),
        'last name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _genderController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully!')),
      );

      // Pop and indicate that details were updated
      Navigator.pop(context, true);
    }
  } catch (e) {
    print("Error updating user details: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update details: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Personal Details'),
        backgroundColor: const Color.fromARGB(255, 111, 128, 222),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      readOnly: true, // Make email read-only
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _genderController.text.isEmpty ? null : _genderController.text,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _genderController.text = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 111, 222, 205),
                      ),
                      child: const Text('Update Details'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
