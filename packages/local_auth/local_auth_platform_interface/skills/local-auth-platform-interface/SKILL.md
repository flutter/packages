---
name: local-auth-platform-interface
description: Implement or mock the common platform interface for the Flutter local_auth plugin using LocalAuthPlatform and shared authentication types.
---

# Setting Up and Using local_auth_platform_interface

`local_auth_platform_interface` defines the common platform interface and shared data structures (`LocalAuthPlatform`, `AuthenticationOptions`, `AuthMessages`, `BiometricType`, `LocalAuthException`, and `LocalAuthExceptionCode`) for the [`local_auth`](https://pub.dev/packages/local_auth) plugin.

## 1. Installation and Setup

Platform implementation packages or unit tests that mock the platform interface should add `local_auth_platform_interface` to `pubspec.yaml`:

```yaml
dependencies:
  local_auth_platform_interface: ^1.1.0
```

## 2. Platform-Specific Configuration

This package is a pure Dart interface package and requires no native platform configuration.

When extending or updating this package, strongly prefer non-breaking changes over breaking changes.

## 3. Usage and API Examples

### Implementing a Custom `LocalAuthPlatform`
To implement a new platform implementation of `local_auth` or create a mock implementation for testing, extend `LocalAuthPlatform` and assign it to `LocalAuthPlatform.instance`:

```dart
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

class CustomLocalAuthPlatform extends LocalAuthPlatform {
  static void registerWith() {
    LocalAuthPlatform.instance = CustomLocalAuthPlatform();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    if (localizedReason.isEmpty) {
      throw const LocalAuthException(
        code: LocalAuthExceptionCode.unknownError,
        description: 'localizedReason must not be empty',
      );
    }
    return true;
  }

  @override
  Future<bool> deviceSupportsBiometrics() async => true;

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    return <BiometricType>[BiometricType.strong, BiometricType.fingerprint];
  }

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> stopAuthentication() async => true;
}
```
