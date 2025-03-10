import 'dart:io';
import 'package:capstone/pages/a%20logggin/face_capture_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isPasswordVisible = false;
  File? _profileImage; // For storing the captured face image

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // New method to validate user inputs
  bool validateUserInputs() {
    // Check if all required fields are filled
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmpasswordController.text.trim().isEmpty ||
        _genderController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty) {
      showErrorDialog('Please fill in all required fields.');
      return false;
    }

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      showErrorDialog('Please enter a valid email address.');
      return false;
    }

    // Validate password match
    if (!passwordConfirmed()) {
      showErrorDialog('Passwords do not match. Please try again.');
      return false;
    }

    // Validate age is a number
    try {
      int.parse(_ageController.text.trim());
    } catch (e) {
      showErrorDialog('Please enter a valid age.');
      return false;
    }

    return true;
  }

  // New method to handle form submission
  void handleFormSubmission() async {
    if (validateUserInputs()) {
      // All inputs are valid, proceed to face capture
      await navigateToFaceCapture();
      
      // If image was captured successfully, sign up
      if (_profileImage != null) {
        await signUp();
      }
    }
  }

  Future<void> navigateToFaceCapture() async {
    // Generate a temporary ID for the user
    String tempUserId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Navigate to the FaceCapturePage and wait for the result
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceCapturePage(userId: tempUserId),
      ),
    );
    
    // If an image path was returned, update the profile image
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> signUp() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;

      // Save user details to Firestore
      await addUserDetails(
        uid,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _genderController.text.trim(),
        int.parse(_ageController.text.trim()),
      );

      // Save the profile image to the user's permanent directory
      await saveProfileImage(uid, _profileImage!);

      // Close loading dialog
      Navigator.of(context).pop();

      // After registration is complete, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      await showErrorDialog(e.toString());
    }
  }

  Future<void> saveProfileImage(String uid, File image) async {
    try {
      // Create directory for the user if it doesn't exist
      Directory appDir = await getApplicationDocumentsDirectory();
      final userDir = Directory('${appDir.path}/$uid');
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }
      
      // Save the image to the user's directory
      String filePath = '${userDir.path}/profile_image.jpg';
      await image.copy(filePath);
      
      print("Profile image saved for UID: $uid at path: $filePath");
      
      // Update the user document with the image path
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profile_image_path': filePath,
      });
    } catch (e) {
      print("Error saving profile image: $e");
    }
  }

  Future<void> showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign-Up Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future addUserDetails(String uid, String firstName, String lastName, String email, String gender, int age) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'gender': gender,
      'age': age,
    });
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() == _confirmpasswordController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Face Capture Button/Display
                    GestureDetector(
                      onTap: null, // Disabled manual face capture
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null 
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                                  SizedBox(height: 5),
                                  Text(
                                    "Face will be captured after form completion",
                                    style: TextStyle(fontSize: 8, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ) 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First Name TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            hintText: 'First Name',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 111, 128, 222)),
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Last Name TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            hintText: 'Last Name',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 111, 128, 222)),
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Gender Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            hintText: 'Gender',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.wc, color: Color.fromARGB(255, 111, 128, 222)),
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                          value: null,
                          items: ['Male', 'Female'].map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            _genderController.text = newValue ?? '';
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Age TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Age',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.calendar_today, color: Color.fromARGB(255, 111, 128, 222)),
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Email TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email Address',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 111, 128, 222)),
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 111, 128, 222)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: const Color.fromARGB(255, 111, 128, 222),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Confirm Password TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 111, 128, 222),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _confirmpasswordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 111, 128, 222)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: const Color.fromARGB(255, 111, 128, 222),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Sign Up Button - Updated to use handleFormSubmission
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: handleFormSubmission,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 111, 222, 205),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already a member? Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already a member?'),
                        GestureDetector(
                          onTap: widget.showLoginPage,
                          child: const Text(
                            ' Login',
                            style: TextStyle(
                              color: Color.fromARGB(255, 111, 128, 222),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}