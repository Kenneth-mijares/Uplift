// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Password reset link sent! Check your Email'),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                e.message.toString(),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              "Enter your Email, You'll receive a password reset link",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          //Email textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: 'Email Address',
                      border: InputBorder.none,
                    )),
              ),
            ),
          ),
          const SizedBox(height: 10),
          MaterialButton(
            onPressed: passwordReset,
            color: const Color.fromARGB(255, 168, 131, 173),
            child: const Text('Reset Password'),
          )
        ],
      ),
    );
  }
}