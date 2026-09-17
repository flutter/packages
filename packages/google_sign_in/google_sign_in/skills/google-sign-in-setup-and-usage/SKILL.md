---
name: google-sign-in-setup-and-usage
description: Set up and use the google_sign_in plugin to authenticate users with their Google account and authorize OAuth 2.0 scopes across Android, iOS, macOS, and Web.
---

# Setting Up and Using google_sign_in

`google_sign_in` is a Flutter plugin for Google Sign-In that provides secure authentication with a Google account and OAuth 2.0 scope authorization across Android, iOS, macOS, and Web.

## 1. Installation

Add `google_sign_in` to your `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in: ^7.2.0
```

If your app targets Web and renders the Google Sign-In button widget directly, also add `google_sign_in_web`:

```yaml
dependencies:
  google_sign_in: ^7.2.0
  google_sign_in_web: ^1.1.0
```

## 2. Platform-Specific Configuration

### Android
- Register your app in Firebase or the Google Cloud Console with your Android package name and SHA-1 signing certificate fingerprint.
- If using `android/app/google-services.json`, ensure it includes a Web OAuth 2.0 client ID (`client_type: 3`).
- If not using `google-services.json`, pass your Web OAuth 2.0 client ID as `serverClientId` to `GoogleSignIn.instance.initialize(...)`.

### iOS and macOS (`Info.plist`)
Add your OAuth Client ID and reversed client ID URL scheme to `ios/Runner/Info.plist` (and `macos/Runner/Info.plist` for macOS):

```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

On macOS, also enable Keychain Sharing by adding the `com.google.GIDSignIn` access group in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)com.google.GIDSignIn</string>
</array>
```

### Web (`web/index.html`)
Configure your Web OAuth 2.0 Client ID in `web/index.html` and register your origins (such as `http://localhost` and `http://localhost:7357` for local testing) under **Authorized JavaScript origins** in the Google Cloud Console:

```html
<head>
  <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
</head>
```

## 3. Usage and API Examples

### Initialization and Authentication

Initialize `GoogleSignIn.instance`, listen to `authenticationEvents`, and optionally attempt lightweight authentication (such as One Tap or silent session restoration):

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleSignIn _signIn = GoogleSignIn.instance;
  GoogleSignInAccount? _currentUser;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    await _signIn.initialize(
      clientId: 'YOUR_CLIENT_ID_IF_REQUIRED',
      serverClientId: 'YOUR_SERVER_CLIENT_ID_IF_REQUIRED',
    );

    _authSubscription = _signIn.authenticationEvents.listen(
      (GoogleSignInAuthenticationEvent event) {
        setState(() {
          switch (event) {
            case GoogleSignInAuthenticationEventSignIn():
              _currentUser = event.user;
            case GoogleSignInAuthenticationEventSignOut():
              _currentUser = null;
          }
        });
      },
      onError: (Object error) {
        debugPrint('Authentication error: $error');
      },
    );

    _signIn.attemptLightweightAuthentication();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Signed in as ${user.displayName ?? user.email}'),
          ElevatedButton(
            onPressed: () => _signIn.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      );
    }

    // On mobile/desktop, call authenticate(). On Web, render the SDK button.
    if (_signIn.supportsAuthenticate()) {
      return ElevatedButton(
        onPressed: () async {
          try {
            await _signIn.authenticate();
          } catch (e) {
            debugPrint('Sign in failed: $e');
          }
        },
        child: const Text('Sign in with Google'),
      );
    } else if (kIsWeb) {
      return web.renderButton();
    }
    return const SizedBox.shrink();
  }
}
```

### Requesting OAuth 2.0 Scopes and Authorization

Authentication (verifying identity) and authorization (granting API scopes) are handled separately via `user.authorizationClient`:

```dart
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/contacts.readonly',
];

Future<void> requestContactsAccess(GoogleSignInAccount user) async {
  // Check if scopes are already granted silently
  GoogleSignInClientAuthorization? authorization =
      await user.authorizationClient.authorizationForScopes(scopes);

  // Request scopes interactively if not yet granted
  authorization ??= await user.authorizationClient.authorizeScopes(scopes);

  final String accessToken = authorization.accessToken;
  debugPrint('Access token obtained: ${accessToken.isNotEmpty}');
}
```

### Requesting a Server Auth Code

If your backend server needs to exchange an authorization code for refresh and access tokens:

```dart
Future<void> authorizeBackendServer(GoogleSignInAccount user) async {
  final GoogleSignInServerAuthorization? serverAuth =
      await user.authorizationClient.authorizeServer(scopes);
  final String? serverAuthCode = serverAuth?.serverAuthCode;
  if (serverAuthCode != null) {
    // Send serverAuthCode to your backend server over HTTPS.
  }
}
```
