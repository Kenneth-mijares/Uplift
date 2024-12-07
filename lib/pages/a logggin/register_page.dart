import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _profileImage; // For storing the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

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

  Future<void> pickImage() async {
    // Pick an image from the gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the application's directory to save the file
      Directory appDir = await getApplicationDocumentsDirectory();
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
      String filePath = '${appDir.path}/$fileName';

      // Save the image locally
      File localFile = File(pickedFile.path);
      localFile.copy(filePath).then((File savedFile) {
        setState(() {
          _profileImage = savedFile;
        });
      }).catchError((e) {
        print('Error saving image: $e');
      });
    }
  }

  Future<void> signUp() async {
    if (passwordConfirmed()) {
      try {
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

        // If a profile image is selected, upload it
        if (_profileImage != null) {
          await uploadProfileImage(uid, _profileImage!);
        }

        // After registration, you can navigate to the login page or home screen.
      } catch (e) {
        await showErrorDialog(e.toString());
      }
    } else {
      await showErrorDialog('Passwords do not match. Please try again.');
    }
  }

  Future<void> uploadProfileImage(String uid, File image) async {
    try {
      // Save the profile image to Firebase Storage (optional)
      // If you want to upload the image to Firebase Storage, you can replace the following line with Firebase Storage code.
      // FirebaseStorage storage = FirebaseStorage.instance;
      // Reference ref = storage.ref().child('profile_images/$uid.png');
      // await ref.putFile(image);
      // String downloadURL = await ref.getDownloadURL();
      
      // For now, save the image locally with the UID
      String filePath = '${(await getApplicationDocumentsDirectory()).path}/$uid.png';
      image.copy(filePath);

      print("Profile image saved locally for UID: $uid");
    } catch (e) {
      print("Error uploading profile image: $e");
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
                    // Display Profile Image or Camera Icon if no image is selected
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null ? Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
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
                    const SizedBox(height: 5),

                    // Sign Up Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: signUp,
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
