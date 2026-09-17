---
name: google-sign-in-platform-interface-setup-and-usage
description: Use google_sign_in_platform_interface to implement custom platform packages or write mock platform implementations for google_sign_in.
---

# Setting Up and Using google_sign_in_platform_interface

`google_sign_in_platform_interface` provides the common platform interface (`GoogleSignInPlatform`) and shared data structures (`InitParameters`, `AuthenticationResults`, `GoogleSignInUserData`, `GoogleSignInTokenData`, etc.) for the [`google_sign_in`](https://pub.dev/packages/google_sign_in) federated plugin.

## 1. Installation

To implement a new platform package or mock `GoogleSignInPlatform` in unit tests, add `google_sign_in_platform_interface` to your `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in_platform_interface: ^3.1.0
```

## 2. Platform-Specific Configuration

This package contains pure Dart interface definitions and requires no native platform configuration.

When creating a platform implementation or mock class, always **extend** `GoogleSignInPlatform` (`extends GoogleSignInPlatform`) rather than implementing it (`implements GoogleSignInPlatform`). Extending ensures your subclass inherits default behavior and remains compatible if new methods are added to `GoogleSignInPlatform`.

## 3. Usage and API Examples

### Implementing a Custom Platform Implementation

```dart
import 'dart:async';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class CustomGoogleSignInPlatform extends GoogleSignInPlatform {
  static void registerWith() {
    GoogleSignInPlatform.instance = CustomGoogleSignInPlatform();
  }

  @override
  Future<void> init(InitParameters params) async {
    // Initialize underlying SDK with params.clientId / params.serverClientId
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    return AuthenticationResults(
      user: GoogleSignInUserData(
        email: 'user@example.com',
        id: '1234567890',
        displayName: 'Example User',
      ),
      authenticationTokens: AuthenticationTokenData(
        idToken: 'sample-id-token',
      ),
    );
  }
}
```

### Mocking `GoogleSignInPlatform` in Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class FakeGoogleSignInPlatform extends GoogleSignInPlatform {
  InitParameters? lastInitParams;

  @override
  Future<void> init(InitParameters params) async {
    lastInitParams = params;
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => false;
}

void main() {
  test('GoogleSignInPlatform instance can be overridden for testing', () async {
    final FakeGoogleSignInPlatform fakePlatform = FakeGoogleSignInPlatform();
    GoogleSignInPlatform.instance = fakePlatform;

    await GoogleSignInPlatform.instance.init(
      const InitParameters(clientId: 'test-client-id'),
    );

    expect(fakePlatform.lastInitParams?.clientId, 'test-client-id');
  });
}
```
