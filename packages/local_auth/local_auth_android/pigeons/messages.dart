// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    javaOut: 'android/src/main/java/io/flutter/plugins/localauth/Messages.java',
    javaOptions: JavaOptions(package: 'io.flutter.plugins.localauth'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Pigeon version of AndroidAuthStrings, plus the authorization reason.
///
/// See auth_messages_android.dart for details.
class AuthStrings {
  /// Constructs a new instance.
  const AuthStrings({
    required this.reason,
    required this.signInHint,
    required this.cancelButton,
    required this.signInTitle,
  });

  final String reason;
  final String signInHint;
  final String cancelButton;
  final String signInTitle;
}

/// Possible outcomes of an authentication attempt.
enum AuthResultCode {
  /// The user authenticated successfully.
  success,

  /// The user pressed the negative button, which corresponds to
  /// [AuthStrings.cancelButton].
  negativeButton,

  /// The user canceled authentication without pressing the negative button.
  ///
  /// This may be triggered by a swipe or a back button, for example.
  userCanceled,

  /// Authentication was caneceled by the system.
  systemCanceled,

  /// Authentication timed out.
  timeout,

  /// An authentication was already in progress.
  alreadyInProgress,

  /// There is no foreground activity.
  noActivity,

  /// The foreground activity is not a FragmentActivity.
  notFragmentActivity,

  /// The device does not have any credentials available.
  noCredentials,

  /// No biometric hardware is present.
  noHardware,

  /// The biometric is temporarily unavailable.
  hardwareUnavailable,

  /// No biometrics are enrolled.
  notEnrolled,

  /// The user is locked out temporarily due to too many failed attempts.
  lockedOutTemporarily,

  /// The user is locked out until they log in another way due to too many
  /// failed attempts.
  lockedOutPermanently,

  /// The device does not have enough storage to complete authentication.
  noSpace,

  /// The hardware is unavailable until a security update is performed.
  securityUpdateRequired,

  /// Some unrecognized error case was encountered
  unknownError,
}

/// The results of an authentication request.
class AuthResult {
  const AuthResult({required this.code, this.errorMessage});

  /// The specific result returned from the SDK.
  final AuthResultCode code;

  /// The error message associated with the result, if any.
  final String? errorMessage;
}

class AuthOptions {
  AuthOptions({
    required this.biometricOnly,
    required this.sensitiveTransaction,
    required this.sticky,
  });
  final bool biometricOnly;
  final bool sensitiveTransaction;
  final bool sticky;
}

/// Pigeon equivalent of the subset of BiometricType used by Android.
enum AuthClassification { weak, strong }

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
  ///
  /// Returns null if there is no activity, in which case the enrolled
  /// biometrics can't be determined.
  List<AuthClassification>? getEnrolledBiometrics();

  /// Attempts to authenticate the user with the provided [options], and using
  /// [strings] for any UI.
  @async
  AuthResult authenticate(AuthOptions options, AuthStrings strings);
}
