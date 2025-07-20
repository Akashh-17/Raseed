// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Your login/signup UI
import 'home_screen.dart'; // Your main app dashboard

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // This stream listens for any change in the user's login state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is not logged in, show the authentication screen
        if (!snapshot.hasData) {
          return const AuthScreen();
        }
        // If the user is logged in, show the home screen
        return const HomeScreen();
      },
    );
  }
}
