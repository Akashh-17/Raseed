// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart'; // The file generated by 'flutterfire configure'
import 'screens/app_wrapper.dart'; // Use AppWrapper to handle onboarding/auth logic
import 'config/app_config.dart';

Future<void> main() async {
  // 1. Ensures that Flutter's binding is initialized before running the app.
  // This is a necessary step before initializing Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load environment variables
  await dotenv.load(fileName: ".env");

  // 3. Validate configuration
  if (!AppConfig.validateConfig()) {
    print('⚠️  Configuration validation failed. Please check your .env file.');
  }

  // 4. Runs your app and handles Firebase initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Handle Firebase initialization with FutureBuilder
      home: FutureBuilder<FirebaseApp>(
        // 2. Initialize Firebase
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          // Show loading screen while Firebase is initializing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing Raseed...'),
                  ],
                ),
              ),
            );
          }

          // If there's an error initializing Firebase
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text('Error initializing Firebase: ${snapshot.error}'),
                  ],
                ),
              ),
            );
          }

          // 4. Once Firebase is initialized, show AppWrapper (handles onboarding)
          return const AppWrapper();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
