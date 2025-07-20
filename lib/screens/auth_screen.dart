import 'dart:ui';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Uncommented to use the User class

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool isLoading = false;
  String? errorMessage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // --- MODIFICATION START ---
  // A new AuthService instance to use in our methods
  final AuthService _authService = AuthService();
  // --- MODIFICATION END ---

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1A2341); // Blue shade
    final Color accentColor = const Color(0xFF2196F3); // Lighter blue
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: isSignIn
                ? _buildLoginView(primaryColor, accentColor)
                : _buildSignUpView(primaryColor, accentColor),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginView(Color primaryColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 38,
          backgroundColor: accentColor.withOpacity(0.12),
          child: Icon(Icons.receipt_long, color: primaryColor, size: 40),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome to Raseed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 2,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black12.withOpacity(0.12)),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: Image.asset(
              'assets/google_logo.png',
              height: 26,
              width: 26,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.black, size: 28),
            ),
            label: const Text('Sign in with Google'),
            onPressed: isLoading ? null : _onGoogleSignIn,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('OR', style: TextStyle(color: Colors.black45)),
            ),
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                style: TextStyle(color: primaryColor),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                style: TextStyle(color: primaryColor),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: isLoading ? null : _onPrimaryPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Login'),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _onForgotPassword,
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(color: Colors.black87),
            ),
            TextButton(
              onPressed: () => setState(() => isSignIn = false),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpView(Color primaryColor, Color accentColor) {
    // This view remains the same, so I've omitted it for brevity.
    // Your existing code for this widget is correct.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 38,
          backgroundColor: accentColor.withOpacity(0.12),
          child: Icon(Icons.receipt_long, color: primaryColor, size: 40),
        ),
        const SizedBox(height: 18),
        Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 2,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black12.withOpacity(0.12)),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: Image.asset(
              'assets/google_logo.png',
              height: 26,
              width: 26,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.black, size: 28),
            ),
            label: const Text('Sign in with Google'),
            onPressed: isLoading ? null : _onGoogleSignIn,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('OR', style: TextStyle(color: Colors.black45)),
            ),
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                style: TextStyle(color: primaryColor),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                style: TextStyle(color: primaryColor),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                style: TextStyle(color: primaryColor),
                validator: (value) => value == null || value.isEmpty
                    ? 'Confirm your password'
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: isLoading ? null : _onPrimaryPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Sign Up'),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account?",
              style: TextStyle(color: Colors.black87),
            ),
            TextButton(
              onPressed: () => setState(() => isSignIn = true),
              child: Text(
                'Login',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onPrimaryPressed() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    // TODO: Implement Firebase Auth logic for Email/Password here
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);
  }

  // --- MODIFICATION START ---
  void _onGoogleSignIn() async {
    print("Sign in with Google button pressed");
    // Show a loading indicator
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Call the sign-in method from your AuthService
    final User? user = await _authService.signInWithGoogle();

    // Hide the loading indicator
    // A 'mounted' check is good practice to ensure the widget is still in the tree
    if (mounted) {
      setState(() => isLoading = false);
    }

    // If sign-in fails, show an error message
    if (user == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Google Sign-In failed. Please try again.')),
      );
    }
    // If sign-in is successful, the AuthGate will automatically navigate to HomeScreen.
  }
  // --- MODIFICATION END ---

  void _onForgotPassword() {
    // Your existing code for this is correct.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text('Password reset functionality coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
