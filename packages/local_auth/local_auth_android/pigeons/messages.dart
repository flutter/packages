// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOut: 'android/src/main/java/io/flutter/plugins/localauth/Messages.java',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.localauth'),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon version of AndroidAuthStrings, plus the authorization reason.
///
/// See auth_messages_android.dart for details.
class AuthStrings {
  /// Constructs a new instance.
  const AuthStrings({
    required this.reason,
    required this.biometricHint,
    required this.biometricNotRecognized,
    required this.biometricRequiredTitle,
    required this.cancelButton,
    required this.deviceCredentialsRequiredTitle,
    required this.deviceCredentialsSetupDescription,
    required this.goToSettingsButton,
    required this.goToSettingsDescription,
    required this.signInTitle,
  });

  final String reason;
  final String biometricHint;
  final String biometricNotRecognized;
  final String biometricRequiredTitle;
  final String cancelButton;
  final String deviceCredentialsRequiredTitle;
  final String deviceCredentialsSetupDescription;
  final String goToSettingsButton;
  final String goToSettingsDescription;
  final String signInTitle;
}

/// Possible outcomes of an authentication attempt.
enum AuthResult {
  /// The user authenticated successfully.
  success,

  /// The user failed to successfully authenticate.
  failure,

  /// An authentication was already in progress.
  errorAlreadyInProgress,

  /// There is no foreground activity.
  errorNoActivity,

  /// The foreground activity is not a FragmentActivity.
  errorNotFragmentActivity,

  /// The authentication system was not available.
  errorNotAvailable,

  /// No biometrics are enrolled.
  errorNotEnrolled,

  /// The user is locked out temporarily due to too many failed attempts.
  errorLockedOutTemporarily,

  /// The user is locked out until they log in another way due to too many
  /// failed attempts.
  errorLockedOutPermanently,
}

class AuthOptions {
  AuthOptions(
      {required this.biometricOnly,
      required this.sensitiveTransaction,
      required this.sticky,
      required this.useErrorDialgs});
  final bool biometricOnly;
  final bool sensitiveTransaction;
  final bool sticky;
  final bool useErrorDialgs;
}

// TODO(stuartmorgan): Remove this when
// https://github.com/flutter/flutter/issues/87307 is implemented.
class AuthResultWrapper {
  AuthResultWrapper({required this.value});
  final AuthResult value;
}

/// Pigeon equivalent of the subset of BiometricType used by Android.
enum AuthClassification { weak, strong }

// TODO(stuartmorgan): Remove this when
// https://github.com/flutter/flutter/issues/87307 is implemented.
class AuthClassificationWrapper {
  AuthClassificationWrapper({required this.value});
  final AuthClassification value;
}

@HostApi()
abstract class LocalAuthApi {
  /// Returns true if this device supports authentication.
  bool isDeviceSupported();

  /// Returns true if this device can support biometric authentication, whether
  /// any biometrics are enrolled or not.
  bool deviceCanSupportBiometrics();

  /// Cancels any in-progress authentication.
  ///
  /// Returns true only if authentication was in progress, and was successfully
  /// cancelled.
  bool stopAuthentication();

  /// Returns the biometric types that are enrolled, and can thus be used
  /// without additional setup.
  List<AuthClassificationWrapper> getEnrolledBiometrics();

  /// Attempts to authenticate the user with the provided [options], and using
  /// [strings] for any UI.
  @async
  AuthResultWrapper authenticate(AuthOptions options, AuthStrings strings);
}
