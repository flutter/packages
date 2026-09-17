---
name: local-auth-darwin
description: Configure and use local_auth_darwin for iOS and macOS Face ID, Touch ID, and passcode authentication, including Info.plist NSFaceIDUsageDescription and IOSAuthMessages.
---

# Setting Up and Using local_auth_darwin

`local_auth_darwin` is the endorsed iOS and macOS implementation of the Flutter [`local_auth`](https://pub.dev/packages/local_auth) plugin using Apple's LocalAuthentication framework.

## 1. Installation and Setup

Because this package is endorsed, adding `local_auth` to your `pubspec.yaml` automatically includes it. However, if you import `local_auth_darwin` directly to customize Apple authentication dialogs via `IOSAuthMessages`, add it to `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^3.0.2
  local_auth_darwin: ^2.0.4
```

## 2. Platform-Specific Configuration

### Info.plist Configuration (`NSFaceIDUsageDescription`)
To support Face ID on iOS devices, you must declare `NSFaceIDUsageDescription` in `ios/Runner/Info.plist`. Without this key, Face ID requests will fail or crash on iOS.

```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to securely authenticate your identity.</string>
```

## 3. Usage and API Examples

### Customizing iOS and macOS Authentication Dialogs
Import `package:local_auth_darwin/local_auth_darwin.dart` and pass `IOSAuthMessages` to customize fallback button titles and prompt messages:

```dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

Future<bool> authenticateOnApple() async {
  final LocalAuthentication auth = LocalAuthentication();

  return auth.authenticate(
    localizedReason: 'Authenticate to access your vault',
    biometricOnly: false,
    authMessages: const <AuthMessages>[
      IOSAuthMessages(
        cancelButton: 'Cancel',
        localizedFallbackTitle: 'Enter Passcode',
      ),
    ],
  );
}
```
