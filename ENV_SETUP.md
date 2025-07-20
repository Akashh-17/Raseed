# Environment Variables Setup

This project uses environment variables to manage sensitive configuration data securely.

## Setup Instructions

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your actual values in the `.env` file:**
   - `FIREBASE_PROJECT_ID`: Your Firebase project ID
   - `FIREBASE_API_KEY`: Your Firebase API key
   - `FIREBASE_APP_ID`: Your Firebase app ID
   - `GOOGLE_OAUTH_CLIENT_ID`: Your Google OAuth client ID (Android)
   - `GOOGLE_WEB_CLIENT_ID`: Your Google Web client ID

## Important Notes

- **Never commit the `.env` file** to version control
- The `.env` file is already added to `.gitignore`
- Use `.env.example` as a template for other developers
- The app will validate configuration on startup

## Using Environment Variables in Code

```dart
import '../config/app_config.dart';

// Access configuration values
String projectId = AppConfig.firebaseProjectId;
String appName = AppConfig.appName;
bool isDebug = AppConfig.isDebugMode;
```

## Configuration Validation

The app automatically validates that all required environment variables are loaded on startup. If any are missing, you'll see error messages in the console.
