// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Handles the entire Google Sign-In flow
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 2. If the user cancels the process, return null
      if (googleUser == null) {
        return null;
      }

      // 3. Obtain the auth details (tokens) from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Create a new credential for Firebase using the Google token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      // 6. If this is the user's first time, create a document for them in Firestore
      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _createUserDocument(user);
      }

      return user;
    } catch (e) {
      // You can add more specific error handling here if you want
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  // Handles signing out
  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // Sign out from Google
    await _auth.signOut(); // Sign out from Firebase
  }

  // Private helper function to create a new user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final usersRef = _firestore.collection('users');
    // Use the user's unique UID from Firebase as the document ID
    await usersRef.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(), // Records the time of sign-up
    });
  }
}
