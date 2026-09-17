---
name: local-auth-setup-and-usage
description: Set up and use the local_auth plugin for on-device biometric (Face ID, Touch ID, fingerprint) and device credential authentication across Android, iOS, macOS, and Windows.
---

# Setting Up and Using local_auth

`local_auth` enables local, on-device user authentication using biometrics (such as fingerprint or facial recognition) or device credentials (PIN, pattern, or passcode) across Android, iOS, macOS, and Windows.

## 1. Installation and Setup

Add `local_auth` to your `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^3.0.2
```

If you need custom dialog messages (`AndroidAuthMessages`, `IOSAuthMessages`, or `WindowsAuthMessages`), also add the relevant endorsed platform packages:

```yaml
dependencies:
  local_auth: ^3.0.2
  local_auth_android: ^2.1.0
  local_auth_darwin: ^2.0.4
  local_auth_windows: ^2.0.2
```

## 2. Platform-Specific Configuration

### Android
1. **Use `FlutterFragmentActivity`**: BiometricPrompt requires a `FragmentActivity`. Update `MainActivity.kt` to inherit from `FlutterFragmentActivity`:
   ```kotlin
   import io.flutter.embedding.android.FlutterFragmentActivity

   class MainActivity : FlutterFragmentActivity()
   ```
2. **Declare Permission**: Add `USE_BIOMETRIC` to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
   ```
3. **AppCompat Theme**: Ensure your activity's `LaunchTheme` (or theme in `AndroidManifest.xml`) inherits from `Theme.AppCompat` (such as `Theme.AppCompat.DayNight`) so the system biometric dialog renders properly.

### iOS and macOS
Add `NSFaceIDUsageDescription` to `ios/Runner/Info.plist` (and `macos/Runner/Info.plist` if applicable) explaining why your app uses Face ID:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Authenticate using Face ID to access your secure account data.</string>
```

### Windows
Uses Windows Hello automatically on Windows 10+. Note that `biometricOnly: true` is not supported on Windows because Windows Hello does not allow restricting authentication exclusively to biometrics.

## 3. Usage and API Examples

### Checking Device Capabilities and Enrolled Biometrics
Check whether biometric hardware or device-level authentication is supported before prompting:

```dart
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> checkDeviceSupport() async {
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  final List<BiometricType> availableBiometrics =
      await auth.getAvailableBiometrics();
  return canAuthenticate && availableBiometrics.isNotEmpty;
}
```

### Authenticating the User and Handling Exceptions
Call `authenticate()` with a non-empty `localizedReason`. Handle failure cases using `LocalAuthException` and `LocalAuthExceptionCode`:

```dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

Future<bool> authenticateUser() async {
  final LocalAuthentication auth = LocalAuthentication();
  try {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to view your account balance',
      biometricOnly: false,
      persistAcrossBackgrounding: true,
      authMessages: const <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'Biometric authentication required',
          cancelButton: 'Cancel',
        ),
        IOSAuthMessages(
          cancelButton: 'Cancel',
        ),
      ],
    );
    return didAuthenticate;
  } on LocalAuthException catch (e) {
    switch (e.code) {
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        // Prompt user to enroll credentials in device settings
        return false;
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        // Too many failed attempts; locked out temporarily or until PIN entry
        return false;
      default:
        return false;
    }
  }
}
```
