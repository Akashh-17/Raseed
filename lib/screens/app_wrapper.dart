import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'onboarding_screen.dart';
import 'auth_gate.dart';
import 'dashboard_screen.dart'; // Replace with your actual dashboard file

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeAppFlow();
  }

  Future<void> _initializeAppFlow() async {
    // No need to get SharedPreferences since we're always showing onboarding
    // final prefs = await SharedPreferences.getInstance();

    final User? currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _onboardingCompleted = false; // Always false to always show onboarding
      _isLoggedIn = currentUser != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_onboardingCompleted) {
      return const OnboardingScreen();
    }

    if (!_isLoggedIn) {
      return const AuthGate(); // Your Google/Email login
    }

    return const DashboardScreen(); // Your logged-in homepage
  }
}
