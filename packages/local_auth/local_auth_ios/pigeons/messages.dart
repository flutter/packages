// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FLA',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon version of IOSAuthMessages, plus the authorization reason.
///
/// See auth_messages_ios.dart for details.
class AuthStrings {
  /// Constructs a new instance.
  const AuthStrings({
    required this.reason,
    required this.lockOut,
    required this.goToSettingsButton,
    required this.goToSettingsDescription,
    required this.cancelButton,
    required this.localizedFallbackTitle,
  });

  final String reason;
  final String lockOut;
  final String goToSettingsButton;
  final String goToSettingsDescription;
  final String cancelButton;
  final String localizedFallbackTitle;
}

/// Possible outcomes of an authentication attempt.
enum AuthResult {
  /// The user authenticated successfully.
  success,

  /// The user failed to successfully authenticate.
  failure,

  /// The authentication system was not available.
  errorNotAvailable,

  /// No biometrics are enrolled.
  errorNotEnrolled,

  /// No passcode is set.
  errorPasscodeNotSet,
}

class AuthOptions {
  AuthOptions(
      {required this.biometricOnly,
      required this.sticky,
      required this.useErrorDialgs});
  final bool biometricOnly;
  final bool sticky;
  final bool useErrorDialgs;
}

// TODO(stuartmorgan): Remove this when
// https://github.com/flutter/flutter/issues/87307 is implemented.
class AuthResultWrapper {
  AuthResultWrapper({required this.value});
  final AuthResult value;
}

/// Pigeon equivalent of the subset of BiometricType used by iOS.
enum AuthBiometrics { weak, strong }

// TODO(stuartmorgan): Remove this when
// https://github.com/flutter/flutter/issues/87307 is implemented.
class AuthClassificationWrapper {
  AuthClassificationWrapper({required this.value});
  final AuthBiometrics value;
}

@HostApi()
abstract class LocalAuthApi {
  /// Returns true if this device supports authentication.
  bool isDeviceSupported();

  /// Returns true if this device can support biometric authentication, whether
  /// any biometrics are enrolled or not.
  bool deviceCanSupportBiometrics();

  /// Returns the biometric types that are enrolled, and can thus be used
  /// without additional setup.
  List<AuthClassificationWrapper> getEnrolledBiometrics();

  /// Attempts to authenticate the user with the provided [options], and using
  /// [strings] for any UI.
  @async
  AuthResultWrapper authenticate(AuthOptions options, AuthStrings strings);
}
