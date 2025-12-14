# local_auth

<?code-excerpt path-base="example/lib"?>

This Flutter plugin provides means to perform local, on-device authentication of
the user.

On supported devices, this includes authentication with biometrics such as
fingerprint or facial recognition.

|             | Android | iOS   | macOS  | Windows     |
|-------------|---------|-------|--------|-------------|
| **Support** | SDK 24+ | 13.0+ | 10.15+ | Windows 10+ |

## Usage

### Device Capabilities

To check whether there is local authentication available on this device or not,
call `canCheckBiometrics` (if you need biometrics support) and/or
`isDeviceSupported()` (if you just need some device-level authentication):

<?code-excerpt "readme_excerpts.dart (CanCheck)"?>
```dart
import 'package:local_auth/local_auth.dart';
// ···
  final LocalAuthentication auth = LocalAuthentication();
  // ···
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
```

Currently the following biometric types are implemented:

- BiometricType.face
- BiometricType.fingerprint
- BiometricType.weak
- BiometricType.strong

### Enrolled Biometrics

`canCheckBiometrics` only indicates whether hardware support is available, not
whether the device has any biometrics enrolled. To get a list of enrolled
biometrics, call `getAvailableBiometrics()`.

The types are device-specific and platform-specific, and other types may be
added in the future, so when possible you should not rely on specific biometric
types and only check that some biometric is enrolled:

<?code-excerpt "readme_excerpts.dart (Enrolled)"?>
```dart
final List<BiometricType> availableBiometrics = await auth
    .getAvailableBiometrics();

if (availableBiometrics.isNotEmpty) {
  // Some biometrics are enrolled.
}

if (availableBiometrics.contains(BiometricType.strong) ||
    availableBiometrics.contains(BiometricType.face)) {
  // Specific types of biometrics are available.
  // Use checks like this with caution!
}
```

### Options

#### Requiring Biometrics

The `authenticate()` method uses biometric authentication when possible, but
by default also allows fallback to pin, pattern, or passcode. To require
biometric authentication, set `biometricOnly` to `true`.

<?code-excerpt "readme_excerpts.dart (AuthBioOnly)"?>
```dart
final bool didAuthenticate = await auth.authenticate(
  localizedReason: 'Please authenticate to show account balance',
  biometricOnly: true,
);
```

*Note*: `biometricOnly` is not supported on Windows since the Windows implementation's underlying API (Windows Hello) doesn't support selecting the authentication method.

#### Background Handling

On mobile platforms, authentication may be canceled by the system if the app
is backgrounded. This might happen if the user receives a phone call before
they get a chance to authenticate, for example. Setting
`persistAcrossBackgrounding` to true will cause the plugin to instead wait until
the app is foregrounded again, retry the authentication, and only return once
that new attempt completes.

#### Dialog customization

If you want to customize the messages in the system dialogs, you can pass
`AuthMessages` for each platform you support. These are platform-specific, so
you will need to import the platform-specific implementation packages. For
instance, to customize Android and iOS:

<?code-excerpt "readme_excerpts.dart (CustomMessages)"?>
```dart
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
// ···
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to show account balance',
      authMessages: const <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'Oops! Biometric authentication required!',
          cancelButton: 'No thanks',
        ),
        IOSAuthMessages(cancelButton: 'No thanks'),
      ],
    );
```

See the platform-specific classes for details about what can be customized on
each platform.

### Exceptions

`authenticate` throws `LocalAuthException`s in most failure cases. See
`LocalAuthExceptionCodes` for known error codes that you may want to have
specific handling for. For example:

<?code-excerpt "readme_excerpts.dart (ErrorHandling)"?>
```dart
import 'package:local_auth/local_auth.dart';
// ···
  final LocalAuthentication auth = LocalAuthentication();
  // ···
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
      );
      // ···
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        // Add handling of no hardware here.
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
        // ...
      } else {
        // ...
      }
    }
```

## iOS Integration

Note that this plugin works with both Touch ID and Face ID. However, to use the latter,
you need to also add:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Why is my app authenticating using face id?</string>
```

to your Info.plist file. Failure to do so results in a dialog that tells the user your
app has not been updated to use Face ID.

## Android Integration

### Activity Changes

`local_auth` requires the use of a `FragmentActivity` instead of an
`Activity`. To update your application:

* If you are using `FlutterActivity` directly, change it to
`FlutterFragmentActivity` in your `AndroidManifest.xml`.
* If you are using a custom activity, update your `MainActivity.java`:

    ```java
    import io.flutter.embedding.android.FlutterFragmentActivity;

    public class MainActivity extends FlutterFragmentActivity {
        // ...
    }
    ```

    or MainActivity.kt:

    ```kotlin
    import io.flutter.embedding.android.FlutterFragmentActivity

    class MainActivity: FlutterFragmentActivity() {
        // ...
    }
    ```

    to inherit from `FlutterFragmentActivity`.

### Permissions

Update your project's `AndroidManifest.xml` file to include the
`USE_BIOMETRIC` permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<manifest>
```

### Compatibility

On Android, you can check only for existence of fingerprint hardware prior
to API 29 (Android Q). Therefore, if you would like to support other biometrics
types (such as face scanning) and you want to support SDKs lower than Q,
_do not_ call `getAvailableBiometrics`. Simply call `authenticate` with `biometricOnly: true`.
This will return an error if there was no hardware available.

#### Android theme

Your `LaunchTheme`'s parent must be a valid `Theme.AppCompat` theme to prevent
crashes on Android 8 and below. For example, use `Theme.AppCompat.DayNight` to
enable light/dark modes for the biometric dialog. To do that go to
`android/app/src/main/res/values/styles.xml` and look for the style with name
`LaunchTheme`. Then change the parent for that style as follows:

```xml
...
<resources>
  <style name="LaunchTheme" parent="Theme.AppCompat.DayNight">
    ...
  </style>
  ...
</resources>
...
```

If you don't have a `styles.xml` file for your Android project you can set up
the Android theme directly in `android/app/src/main/AndroidManifest.xml`:

```xml
...
	<application
		...
		<activity
			...
			android:theme="@style/Theme.AppCompat.DayNight"
			...
		>
		</activity>
	</application>
...
```
