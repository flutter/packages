---
name: google-sign-in-android-setup-and-usage
description: Set up and configure google_sign_in_android, the Android implementation of google_sign_in built on Android Credential Manager.
---

# Setting Up and Using google_sign_in_android

`google_sign_in_android` is the endorsed Android platform implementation of the [`google_sign_in`](https://pub.dev/packages/google_sign_in) plugin, built using Android's Credential Manager API.

## 1. Installation

Because `google_sign_in_android` is endorsed, adding `google_sign_in` to your `pubspec.yaml` automatically includes it:

```yaml
dependencies:
  google_sign_in: ^7.2.0
```

If you need to depend on `google_sign_in_android` directly, add it to `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in: ^7.2.0
  google_sign_in_android: ^7.2.17
```

## 2. Platform-Specific Configuration

To authenticate users on Android, you must register your Android app and configure an OAuth 2.0 **Web application** client ID (`serverClientId`), which Credential Manager requires to issue ID tokens.

### Option A: Using Firebase (`google-services.json`)

1. Register your Android app in the [Firebase Console](https://console.firebase.google.com/), providing your Android package name and SHA-1 signing certificate fingerprint (`./gradlew signingReport`).
2. Enable **Google Sign-In** in Firebase Authentication. This automatically generates a Web OAuth 2.0 client ID.
3. Download `google-services.json` and place it at `android/app/google-services.json`. Ensure it contains an `oauth_client` entry with `"client_type": 3` (Web client).
4. With `google-services.json` configured via the Google Services Gradle plugin, no explicit `serverClientId` needs to be passed in Dart code.

### Option B: Without `google-services.json` (Google Cloud Console)

1. In the [Google Cloud Console Credentials page](https://console.cloud.google.com/apis/credentials), create:
   - An **Android** OAuth 2.0 Client ID with your package name and SHA-1 certificate fingerprint.
   - A **Web application** OAuth 2.0 Client ID.
2. Pass the **Web application** client ID as `serverClientId` when calling `GoogleSignIn.instance.initialize(...)` in Dart.

## 3. Usage and Troubleshooting

### Initializing with Explicit `serverClientId`

```dart
import 'package:google_sign_in/google_sign_in.dart';

Future<void> initializeAndroidSignIn() async {
  final GoogleSignIn signIn = GoogleSignIn.instance;

  await signIn.initialize(
    // Pass the Web OAuth 2.0 Client ID (required if not using google-services.json)
    serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  await signIn.attemptLightweightAuthentication();
}
```

### Common Troubleshooting on Android

- **`GoogleSignInExceptionCode.clientConfigurationError` or `serverClientId must be provided on Android`**:
  Ensure either `serverClientId` is passed to `initialize()` or `android/app/google-services.json` contains a web OAuth client (`client_type: 3`).
- **`GoogleSignInExceptionCode.canceled` immediately after selecting an account**:
  Android's Credential Manager returns a cancellation error when the app's SHA-1 signing certificate or package name does not match any Android OAuth client registered in Google Cloud Console for your debug or release keystore. Verify your SHA-1 fingerprint for the active build variant.
