---
name: local-auth-android
description: Configure and use local_auth_android for Android biometric authentication, including FlutterFragmentActivity, USE_BIOMETRIC permission, AppCompat theme, and AndroidAuthMessages.
---

# Setting Up and Using local_auth_android

`local_auth_android` is the endorsed Android implementation of the Flutter [`local_auth`](https://pub.dev/packages/local_auth) plugin, using Android's `BiometricPrompt` API.

## 1. Installation and Setup

Because this package is endorsed, adding `local_auth` to your `pubspec.yaml` automatically includes it. However, if you import `local_auth_android` directly to customize dialog strings with `AndroidAuthMessages`, add it to `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^3.0.2
  local_auth_android: ^2.1.0
```

## 2. Platform-Specific Configuration

### 1. Inherit from `FlutterFragmentActivity`
`BiometricPrompt` requires a `FragmentActivity` rather than a standard `Activity`. Update your `MainActivity` (`android/app/src/main/kotlin/.../MainActivity.kt`):

```kotlin
package com.example.myapp

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

Or if using `FlutterActivity` directly in `AndroidManifest.xml`, replace it with `io.flutter.embedding.android.FlutterFragmentActivity`.

### 2. Declare Biometric Permission
Add the `USE_BIOMETRIC` permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
  <application ...>
    ...
  </application>
</manifest>
```

### 3. Configure AppCompat Theme
Your activity theme must inherit from a `Theme.AppCompat` parent (such as `Theme.AppCompat.DayNight`) so the biometric dialog renders properly without crashing. Update `android/app/src/main/res/values/styles.xml`:

```xml
<resources>
  <style name="LaunchTheme" parent="Theme.AppCompat.DayNight">
    <item name="android:windowBackground">@drawable/launch_background</item>
  </style>
</resources>
```

## 3. Usage and API Examples

### Customizing Android Biometric Dialogs
Import `package:local_auth_android/local_auth_android.dart` and pass an `AndroidAuthMessages` instance to `authenticate`:

```dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

Future<bool> authenticateOnAndroid() async {
  final LocalAuthentication auth = LocalAuthentication();

  return auth.authenticate(
    localizedReason: 'Scan your fingerprint or face to unlock',
    persistAcrossBackgrounding: true,
    authMessages: const <AuthMessages>[
      AndroidAuthMessages(
        signInTitle: 'Security Verification',
        biometricHint: 'Touch the fingerprint sensor',
        cancelButton: 'Use Password Instead',
      ),
    ],
  );
}
```
