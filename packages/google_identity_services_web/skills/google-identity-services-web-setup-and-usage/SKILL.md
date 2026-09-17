---
name: google-identity-services-web-setup-and-usage
description: Use google_identity_services_web as a Dart JS-interop layer for the Google Identity Services (GIS) Web SDK to handle One Tap sign-in and OAuth 2.0 token flows.
---

# Setting Up and Using google_identity_services_web

`google_identity_services_web` is a low-level Dart JS-interop wrapper around the [Google Identity Services (GIS) JavaScript SDK](https://developers.google.com/identity/gsi/web). It exposes two primary sub-libraries:
- `package:google_identity_services_web/id.dart`: Authentication (Sign In With Google button, One Tap prompt, and JWT ID tokens).
- `package:google_identity_services_web/oauth2.dart`: Authorization (OAuth 2.0 implicit token flows and authorization code flows).

> **Note**: For standard cross-platform Flutter apps, prefer using the high-level [`google_sign_in`](https://pub.dev/packages/google_sign_in) plugin. Use `google_identity_services_web` when you need direct access to GIS web-specific features such as One Tap prompts, FedCM configuration, or custom OAuth token clients.

## 1. Installation

Add `google_identity_services_web` to your `pubspec.yaml`:

```yaml
dependencies:
  google_identity_services_web: ^0.3.3+1
```

## 2. Platform-Specific Configuration

### Loading the Google Identity Services JS SDK

You can load the GIS JavaScript library either statically in `web/index.html` (recommended for performance) or dynamically at runtime using `loadWebSdk()`.

#### Option A: Modify `web/index.html` (Recommended)
Add the GIS client script to the `<head>` of `web/index.html`:

```html
<head>
  <script src="https://accounts.google.com/gsi/client" async defer></script>
</head>
```

#### Option B: Load On-Demand in Dart (`loader.dart`)
Call `gis.loadWebSdk()` before invoking any `id` or `oauth2` APIs:

```dart
import 'package:google_identity_services_web/loader.dart' as gis;

Future<void> main() async {
  await gis.loadWebSdk();
  // GIS SDK is now ready to use.
}
```

### Authorized JavaScript Origins
In the [Google Cloud Console](https://console.cloud.google.com/apis/credentials), ensure your Web OAuth 2.0 Client ID includes both `http://localhost` and `http://localhost:<port>` under **Authorized JavaScript origins** for local development.

## 3. Usage and API Examples

### One Tap Sign-In and ID Token Authentication (`id.dart`)

```dart
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/loader.dart' as gis;

Future<void> initOneTapSignIn() async {
  await gis.loadWebSdk();

  final IdConfiguration config = IdConfiguration(
    client_id: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    callback: (CredentialResponse response) {
      final String? jwtIdToken = response.credential;
      print('Received ID Token: $jwtIdToken');
    },
    use_fedcm_for_prompt: true,
  );

  id.initialize(config);

  // Display the One Tap prompt
  id.prompt((PromptMomentNotification notification) {
    print('Prompt moment type: ${notification.getMomentType()}');
  });
}
```

### Requesting an OAuth 2.0 Access Token (`oauth2.dart`)

```dart
import 'package:google_identity_services_web/oauth2.dart';

void requestAccessToken() {
  final TokenClientConfig config = TokenClientConfig(
    client_id: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    scope: 'https://www.googleapis.com/auth/calendar.readonly',
    callback: (TokenResponse response) {
      if (response.error != null) {
        print('OAuth error: ${response.error}');
        return;
      }
      print('Access Token: ${response.access_token}');
    },
  );

  final TokenClient client = oauth2.initTokenClient(config);
  client.requestAccessToken();
}
```
