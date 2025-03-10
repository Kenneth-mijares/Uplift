import 'dart:io';
import 'package:capstone/pages/a%20logggin/face_capture_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _imagePath; // For storing the path to the captured face image
  File? _profileImage; // For displaying the captured face image

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
  
    bool _privacyPolicyAccepted = false;
  
  @override
  void initState() {
    super.initState();
    // Check if user has previously accepted privacy policy
    _checkPrivacyPolicyStatus();
    // If not, show the privacy policy dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_privacyPolicyAccepted) {
        _showPrivacyPolicyDialog();
      }
    });
  }

  Future<void> _checkPrivacyPolicyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _privacyPolicyAccepted = prefs.getBool('privacy_policy_accepted') ?? false;
    });
  }

  Future<void> _savePrivacyPolicyStatus(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_policy_accepted', accepted);
    setState(() {
      _privacyPolicyAccepted = accepted;
    });
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Data Privacy Agreement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 111, 128, 222),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'In compliance with Republic Act No. 10173, also known as the Data Privacy Act of 2012, we are committed to protecting your personal information.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'By using this application, you agree to the collection and processing of your personal information for the following purposes:',
                ),
                SizedBox(height: 10),
                Text('• User authentication and account management'),
                Text('• Facial recognition for secure login'),
                Text('• Providing and improving our services'),
                Text('• Compliance with legal obligations'),
                SizedBox(height: 10),
                Text(
                  'The personal information we collect includes:',
                ),
                SizedBox(height: 10),
                Text('• Name and contact information'),
                Text('• Age and gender'),
                Text('• Facial biometric data'),
                Text('• Account credentials'),
                SizedBox(height: 10),
                Text(
                  'Your Rights:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('• Right to be informed about the collection and processing of your personal data'),
                Text('• Right to access your personal data'),
                Text('• Right to object to the processing of your personal data'),
                Text('• Right to erasure or blocking of your personal data'),
                Text('• Right to damages for privacy violations'),
                SizedBox(height: 10),
                Text(
                  'We implement reasonable and appropriate security measures to protect your personal information from unauthorized access, use, or disclosure.',
                ),
                SizedBox(height: 10),
                Text(
                  'We will retain your personal information only for as long as necessary to fulfill the purposes outlined in this agreement, unless a longer retention period is required by law.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the registration page
              },
              child: const Text(
                'Decline',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _savePrivacyPolicyStatus(true);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 111, 222, 205),
              ),
              child: const Text(
                'Accept & Continue',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Modified handleFormSubmission to check for privacy policy acceptance
  void handleFormSubmission() async {
    if (!_privacyPolicyAccepted) {
      _showPrivacyPolicyDialog();
      return;
    }
    
    if (validateUserInputs()) {
      await navigateToFaceCapture();
      
      if (_imagePath != null) {
        await signUp();
      }
    }
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
        _imagePath = imagePath;
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

      // Update the reference image to use the user's actual UID
      await updateFaceReferenceImage(uid);

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

  Future<void> updateFaceReferenceImage(String uid) async {
    try {
      if (_imagePath == null || _profileImage == null) {
        print("Error: No profile image captured");
        return;
      }
      
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      // Create a file with the user's UID in the appDir (this is what the face recognition expects)
      final String newFilePath = '${appDir.path}/$uid.png';
      final File newFile = File(newFilePath);
      
      // Copy the image data from the temporary file to the new location
      await _profileImage!.copy(newFilePath);
      
      print("Updated face reference image for UID: $uid at path: $newFilePath");
      
      // Update the user document with the reference to the face image
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'face_reference_path': newFilePath,
      });
      
      // Verify file exists and is readable
      if (await newFile.exists()) {
        final fileStats = await newFile.stat();
        print("Reference image saved successfully at: $newFilePath");
        print("Reference image file size: ${fileStats.size} bytes");
      } else {
        print("Failed to save reference image at: $newFilePath");
      }
    } catch (e) {
      print("Error updating face reference image: $e");
      if (e is FileSystemException) {
        print("File system error: ${e.message}, path: ${e.path}, osError: ${e.osError}");
      }
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
    return WillPopScope(
      onWillPop: () async {
        // If privacy policy not accepted, allow back navigation
        return !_privacyPolicyAccepted;
      },
      child: Scaffold(
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
      
                      // Rest of the UI remains the same...
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
            Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.privacy_tip_outlined,
                                  size: 16,
                                  color: Color.fromARGB(255, 111, 128, 222),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'By signing up, you agree to our ',
                                  style: TextStyle(fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: _showPrivacyPolicyDialog,
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 111, 128, 222),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
              ),

          ],
        ),
      ),
    );
  }
}