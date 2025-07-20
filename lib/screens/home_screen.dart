// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Import the AuthService to handle signing out

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get an instance of the AuthService
    final AuthService authService = AuthService();

    // Get the current user from Firebase Authentication
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RASEED Dashboard'),
        // Add an actions list to the AppBar for buttons
        actions: [
          // This is the sign-out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out', // Provides text on hover/long-press
            onPressed: () {
              // Call the signOut method from your service.
              // The AuthGate will automatically detect the change in auth state
              // and redirect the user back to the login screen.
              authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        // Display a personalized welcome message
        child: Text(
          'Welcome, ${currentUser?.displayName ?? currentUser?.email ?? 'User'}!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
