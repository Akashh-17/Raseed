// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class AuthService {
  // Use lazy getters to avoid calling Firebase instances before initialization
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Use the GoogleSignIn singleton instance with explicit configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // Add the Web OAuth client ID from environment variables
    serverClientId: AppConfig.googleWebClientId,
  );

  // Handles the entire Google Sign-In flow
  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign-In process...");

      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("GoogleSignInAccount: $googleUser");

      // If the user cancels the process, return null
      if (googleUser == null) {
        print("Google Sign-In was cancelled by user");
        return null;
      }

      print("Getting Google authentication tokens...");
      // Await the 'authentication' Future to get the auth object
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print(
          "Access Token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}");
      print("ID Token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}");

      // Create a new credential for Firebase using the tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in to Firebase with Google credential...");
      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      print("Firebase sign-in successful! User: ${user?.email}");

      // If this is a new user, create their document in Firestore
      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        print("Creating new user document in Firestore...");
        await _createUserDocument(user);
      }

      return user;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      print("Error type: ${e.runtimeType}");

      // Check for specific Google Sign-In errors
      if (e.toString().contains('PlatformException')) {
        print("This is a PlatformException - likely a configuration issue");
        if (e.toString().contains('network_error')) {
          print("Network error detected - this could be:");
          print("1. SHA-1 fingerprint mismatch");
          print("2. Package name mismatch");
          print("3. OAuth client configuration issue");
          print("4. Google Play Services issue on device");
        }
      }

      return null;
    }
  }

  // Handles signing out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Private helper function to create a new user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final usersRef = _firestore.collection('users');
    await usersRef.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
