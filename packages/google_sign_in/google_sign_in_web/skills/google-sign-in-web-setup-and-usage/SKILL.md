---
name: google-sign-in-web-setup-and-usage
description: Set up and use google_sign_in_web, the Web implementation of google_sign_in powered by Google Identity Services (GIS), including rendering the web sign-in button.
---

# Setting Up and Using google_sign_in_web

`google_sign_in_web` is the endorsed Web implementation of [`google_sign_in`](https://pub.dev/packages/google_sign_in), built on top of the Google Identity Services (GIS) JavaScript SDK.

## 1. Installation

To use Google Sign-In on Web—and specifically to access the web-only `renderButton()` widget—add both `google_sign_in` and `google_sign_in_web` to your `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in: ^7.2.0
  google_sign_in_web: ^1.1.3
```

## 2. Platform-Specific Configuration (`web/index.html` & Cloud Console)

### 1. Add Client ID Meta Tag (`web/index.html`)

In the `<head>` of your `web/index.html`, add the `google-signin-client_id` meta tag with your Web OAuth 2.0 Client ID:

```html
<head>
  <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
</head>
```

### 2. Configure Authorized JavaScript Origins

In the [Google Cloud Console Credentials page](https://console.cloud.google.com/apis/credentials), edit your Web OAuth 2.0 Client ID and add your domains under **Authorized JavaScript origins**.

For local development, add **both**:
- `http://localhost`
- `http://localhost:7357` (or your chosen fixed port)

Run Flutter Web on that specific port so the origin matches your OAuth configuration:

```bash
flutter run -d chrome --web-hostname localhost --web-port 7357
```

## 3. Usage and Web-Specific Behavior

### Rendering the Google Sign-In Button (`renderButton`)

On Web, `GoogleSignIn.instance.supportsAuthenticate()` returns `false` because the Google Identity Services SDK requires user-initiated sign-in to occur through its rendered HTML button rather than an arbitrary Dart callback.

Import `package:google_sign_in_web/web_only.dart` and display `renderButton()`, while listening to `authenticationEvents` to detect when sign-in completes:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

class WebSignInButtonExample extends StatefulWidget {
  const WebSignInButtonExample({super.key});

  @override
  State<WebSignInButtonExample> createState() => _WebSignInButtonExampleState();
}

class _WebSignInButtonExampleState extends State<WebSignInButtonExample> {
  final GoogleSignIn _signIn = GoogleSignIn.instance;
  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();
    _signIn.initialize().then((_) {
      _signIn.authenticationEvents.listen((GoogleSignInAuthenticationEvent event) {
        setState(() {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            _user = event.user;
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            _user = null;
          }
        });
      });
      // Attempt One Tap / automatic sign-in if available
      _signIn.attemptLightweightAuthentication();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null) {
      return Text('Welcome, ${_user!.displayName ?? _user!.email}');
    }

    if (kIsWeb) {
      return web.renderButton(
        configuration: web.GSIButtonConfiguration(
          theme: web.GSIButtonTheme.filledBlue,
          size: web.GSIButtonSize.large,
          text: web.GSIButtonText.signinWith,
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _signIn.authenticate(),
      child: const Text('Sign in'),
    );
  }
}
```

### Session Expiration on Web
The GIS SDK does not automatically refresh OAuth access tokens on Web. Access tokens expire after 3600 seconds (1 hour). When API calls return `401` or `403`, prompt the user to re-authorize scopes via `user.authorizationClient.authorizeScopes(scopes)` triggered from a user interaction (such as a button press).
