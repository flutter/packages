// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  swiftOut:
      'darwin/local_auth_darwin/Sources/local_auth_darwin/messages.g.swift',
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
    this.goToSettingsButton,
    required this.goToSettingsDescription,
    required this.cancelButton,
    required this.localizedFallbackTitle,
  });

  final String reason;
  final String lockOut;
  final String? goToSettingsButton;
  final String goToSettingsDescription;
  final String cancelButton;
  final String? localizedFallbackTitle;
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

  /// The user cancelled the authentication.
  errorUserCancelled,

  /// The user tapped the "Enter Password" fallback.
  errorUserFallback,

  /// The user biometrics is disabled.
  errorBiometricNotAvailable,
}

class AuthOptions {
  AuthOptions(
      {required this.biometricOnly,
      required this.sticky,
      required this.useErrorDialogs});
  final bool biometricOnly;
  final bool sticky;
  final bool useErrorDialogs;
}

class AuthResultDetails {
  AuthResultDetails(
      {required this.result, this.errorMessage, this.errorDetails});

  /// The result of authenticating.
  final AuthResult result;

  /// A system-provided error message, if any.
  final String? errorMessage;

  /// System-provided error details, if any.
  // TODO(stuartmorgan): Remove this when standardizing errors plugin-wide in
  // a breaking change. This is here only to preserve the existing error format
  // exactly for compatibility, in case clients were checking PlatformException
  // details.
  final String? errorDetails;
}

/// Pigeon equivalent of the subset of BiometricType used by iOS.
enum AuthBiometric { face, fingerprint }

@HostApi()
abstract class LocalAuthApi {
  /// Returns true if this device supports authentication.
  bool isDeviceSupported();

  /// Returns true if this device can support biometric authentication, whether
  /// any biometrics are enrolled or not.
  bool deviceCanSupportBiometrics();

  /// Returns the biometric types that are enrolled, and can thus be used
  /// without additional setup.
  List<AuthBiometric> getEnrolledBiometrics();

  /// Attempts to authenticate the user with the provided [options], and using
  /// [strings] for any UI.
  @async
  AuthResultDetails authenticate(AuthOptions options, AuthStrings strings);
}
