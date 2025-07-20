// lib/config/app_config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration class that handles environment variables
/// and provides type-safe access to configuration values.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// Firebase Configuration
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  /// Google OAuth Configuration
  static String get googleOAuthClientId =>
      dotenv.env['GOOGLE_OAUTH_CLIENT_ID'] ?? '';

  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Raseed';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  /// Validation method to check if all required environment variables are loaded
  static bool validateConfig() {
    final requiredVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'GOOGLE_OAUTH_CLIENT_ID',
      'GOOGLE_WEB_CLIENT_ID',
    ];

    for (String varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        print('ERROR: Missing required environment variable: $varName');
        return false;
      }
    }

    print('✅ All required environment variables are loaded');
    return true;
  }

  /// Get all loaded environment variables (for debugging purposes)
  static Map<String, String> getAllEnvVars() {
    return Map<String, String>.from(dotenv.env);
  }
}
