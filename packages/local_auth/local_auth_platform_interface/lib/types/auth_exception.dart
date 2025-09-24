// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An exception thrown by the plugin when there is authentication failure, or
/// some other error.
@immutable
class LocalAuthException implements Exception {
  /// Creates a new exception with the given information.
  const LocalAuthException({
    required this.code,
    this.description,
    this.details,
  });

  /// The type of failure.
  final LocalAuthExceptionCode code;

  /// A human-readable description of the failure.
  final String? description;

  /// Any additional details about the failure.
  final Object? details;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'LocalAuthException')}(code ${code.name}, $description, $details)';
}

/// Types of [LocalAuthException]s, as indicated by [LocalAuthException.code].
///
/// Adding new values to this enum in the future will *not* be considered a
/// breaking change, so clients should not assume they can exhaustively match
/// exception codes. Clients should always include a default or other fallback.
enum LocalAuthExceptionCode {
  /// An authentication operation is already in progress, and has not completed.
  ///
  /// A new authentication cannot be started while the Future for a previous
  /// authentication is still outstanding.
  authInProgress,

  /// UI needs to be displayed, but could not be.
  ///
  /// For example, this can be returned on Android if a call tries to show UI
  /// when no Activity is available.
  uiUnavailable,

  /// The operation was canceled by the user.
  userCanceled,

  /// The operation was canceled due to a device-specific timeout.
  timeout,

  /// The operation was canceled by a system event.
  ///
  /// For example, on mobile this may be returned if the application is
  /// backgrounded during authentication.
  systemCanceled,

  /// The device has no credentials configured.
  ///
  /// For example, on mobile this would be returned if the device has no
  /// enrolled biometrics and no fallback authentication mechanism set such as
  /// a passcode, pin, or pattern.
  noCredentialsSet,

  /// The device is capable of biometric authentication, but no biometrics are
  /// enrolled.
  noBiometricsEnrolled,

  /// The device does not have biometric hardware.
  noBiometricHardware,

  /// The device has, or can have, biometric hardware, but none is currently
  /// available.
  ///
  /// Examples include:
  /// - Hardware that is currently in use by another application.
  /// - Devices that have previously paired with bluetooth biometric hardware,
  ///   but are not currently paired to it.
  ///
  /// Devices that could have removable hardware attached may return either this
  /// or [noBiometricHardware] depending on the platform implementation.
  /// Platforms should generally only return this code if the system provides
  /// information indicating that the device has previously had such hardware.
  biometricHardwareTemporarilyUnavailable,

  /// Authentication has temporarily been locked out, and should be re-attempted
  /// later.
  ///
  /// For example, devices may return this error after too many failed
  /// authentication attempts.
  temporaryLockout,

  /// Biometric authentication has been locked until some other authentication
  /// has succeeded.
  ///
  /// Applications that do not require biometric authentication should generally
  /// handle this error by re-attempting authentication with fallback to
  /// non-biometrics allowed. Applications that require biometrics should
  /// prompt users to resolve the lockout.
  biometricLockout,

  /// The user indicated via system-provided UI that they want to use a fallback
  /// authentication option instead of biometrics.
  ///
  /// Whether this can be returned depends on the platform implementation and
  /// the authentication configuration options. Applications should generally
  /// handle this error by offering the user an alternate authentication option.
  userRequestedFallback,

  /// The authentication attempt failed due to some device-level error.
  ///
  /// The [LocalAuthException.description] should contain more details about the
  /// error.
  deviceError,

  /// The authentication attempt failed due to some unknown or unexpected error.
  ///
  /// The [LocalAuthException.description] should contain more details about the
  /// error.
  unknownError,
}
