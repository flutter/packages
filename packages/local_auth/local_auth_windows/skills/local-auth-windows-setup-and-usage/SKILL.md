---
name: local-auth-windows-setup-and-usage
description: Set up and use local_auth_windows for Windows Hello authentication on Windows 10 and higher.
---

# Setting Up and Using local_auth_windows

`local_auth_windows` is the endorsed Windows implementation of the Flutter [`local_auth`](https://pub.dev/packages/local_auth) plugin using Windows Hello (`UserConsentVerifier`).

## 1. Installation and Setup

Because this package is endorsed, adding `local_auth` to your `pubspec.yaml` automatically includes `local_auth_windows`. If you import `local_auth_windows` directly (for example, to use `WindowsAuthMessages`), add it to `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^3.0.2
  local_auth_windows: ^2.0.2
```

## 2. Platform-Specific Configuration

- **Minimum OS**: Windows 10 or higher with Windows Hello configured (PIN, fingerprint, or facial recognition).
- **`biometricOnly` Limitation**: Windows Hello does not support restricting authentication exclusively to biometric sensors. Passing `biometricOnly: true` to `authenticate()` on Windows throws an `UnsupportedError`. Always pass `biometricOnly: false` (the default) when targeting Windows.

## 3. Usage and API Examples

### Authenticating with Windows Hello
Use `LocalAuthentication` to check Windows Hello availability and prompt the user:

```dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

Future<bool> authenticateOnWindows() async {
  final LocalAuthentication auth = LocalAuthentication();

  final bool isSupported = await auth.isDeviceSupported();
  if (!isSupported) {
    return false;
  }

  try {
    return await auth.authenticate(
      localizedReason: 'Verify your Windows Hello credentials to continue',
      biometricOnly: false,
      authMessages: const <AuthMessages>[
        WindowsAuthMessages(),
      ],
    );
  } on LocalAuthException catch (e) {
    if (e.code == LocalAuthExceptionCode.noBiometricsEnrolled) {
      // Windows Hello is not configured on this user account
    }
    return false;
  }
}
```
