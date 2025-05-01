import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'dart:async';

class SplashScreen extends StatefulWidget {
  static const routeName = "/splash";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds, then navigate to the appropriate screen
    Timer(const Duration(seconds: 2), () {
      // Check authentication state after 2 seconds
      _checkAuthStateAndNavigate(context);
    });
  }

  // Method to check authentication state and navigate
  void _checkAuthStateAndNavigate(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate to HomeScreen
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User is not logged in, navigate to GetStarted screen
      Navigator.of(context).pushReplacementNamed('/getStarted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/name.png",
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}