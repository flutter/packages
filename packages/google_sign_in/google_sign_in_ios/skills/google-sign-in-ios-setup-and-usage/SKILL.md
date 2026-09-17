---
name: google-sign-in-ios-setup-and-usage
description: Set up and configure google_sign_in_ios, the iOS and macOS implementation of google_sign_in, including Info.plist URL schemes and macOS keychain entitlements.
---

# Setting Up and Using google_sign_in_ios

`google_sign_in_ios` is the endorsed iOS and macOS platform implementation of the [`google_sign_in`](https://pub.dev/packages/google_sign_in) plugin.

## 1. Installation

Because this package is endorsed for both iOS and macOS, adding `google_sign_in` to your `pubspec.yaml` automatically includes `google_sign_in_ios`:

```yaml
dependencies:
  google_sign_in: ^7.2.0
```

If you need to depend on `google_sign_in_ios` directly:

```yaml
dependencies:
  google_sign_in: ^7.2.0
  google_sign_in_ios: ^6.3.3
```

## 2. Platform-Specific Configuration

### iOS and macOS `Info.plist` Configuration

1. Create an iOS OAuth 2.0 Client ID in the [Google Cloud Console](https://console.cloud.google.com/apis/credentials) or via Firebase (`GoogleService-Info.plist`).
2. Add the `CFBundleURLTypes` URL scheme containing your **reversed client ID** to `ios/Runner/Info.plist` (and `macos/Runner/Info.plist` if supporting macOS):

```xml
<!-- Inside ios/Runner/Info.plist (and macos/Runner/Info.plist) -->
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>

<!-- Optional: Include if authenticating with a backend server -->
<key>GIDServerClientID</key>
<string>YOUR_WEB_SERVER_CLIENT_ID.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID_PREFIX</string>
    </array>
  </dict>
</array>
```

> **Note**: You can omit `GIDClientID` and `GIDServerClientID` from `Info.plist` if you pass `clientId` and `serverClientId` directly to `GoogleSignIn.instance.initialize(...)` in Dart, but `CFBundleURLTypes` (`CFBundleURLSchemes`) is **always required** in `Info.plist`.

### Additional macOS Requirement: Keychain Sharing Entitlements

On macOS, the Google Sign-In SDK requires keychain sharing. Add the `com.google.GIDSignIn` keychain access group to both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)com.google.GIDSignIn</string>
</array>
```

Without this entitlement on macOS, sign-in attempts will fail with a keychain `PlatformException`.

## 3. Usage and API Examples

### Initializing with Dart Configuration

You can pass your iOS/macOS OAuth Client ID directly in Dart when initializing `GoogleSignIn`:

```dart
import 'package:google_sign_in/google_sign_in.dart';

Future<void> initDarwinGoogleSignIn() async {
  final GoogleSignIn signIn = GoogleSignIn.instance;

  await signIn.initialize(
    clientId: 'YOUR_IOS_OR_MACOS_CLIENT_ID.apps.googleusercontent.com',
    serverClientId: 'YOUR_WEB_SERVER_CLIENT_ID.apps.googleusercontent.com',
  );

  // Trigger interactive sign-in
  final GoogleSignInAccount account = await signIn.authenticate();
  print('Signed in user: ${account.email}');
}
```
