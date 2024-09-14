// ignore_for_file: unused_local_variable, avoid_print, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:i_need/SosPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  SignInWithEmailandPassword(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Enter Email or Password'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      UserCredential? userCredential;

      try {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) => print("User Logged In"))
            .then((value) => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SosPage())));
      } on FirebaseAuthException catch (e) {
        setState(() {
          // Show an error message using SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Not Found: Please Enter Correct Data : $e"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red, // Set the behavior to floating
            ),
          );
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }
GooleSignin(){ }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Center(
            child: TextButton(
              child: const Text("Google Sigin"),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
