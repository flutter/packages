// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    cppOptions: CppOptions(namespace: 'local_auth_windows'),
    cppHeaderOut: 'windows/messages.g.h',
    cppSourceOut: 'windows/messages.g.cpp',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Possible outcomes of an authentication attempt.
enum AuthResult {
  /// The user authenticated successfully.
  success,

  /// The user failed to successfully authenticate.
  failure,

  /// No biometric hardware is available.
  noHardware,

  /// No biometrics are enrolled.
  notEnrolled,

  /// The biometric hardware is currently in use.
  deviceBusy,

  /// Device policy does not allow using the authentication system.
  disabledByPolicy,

  /// Authentication is unavailable for an unknown reason.
  unavailable,
}

@HostApi()
abstract class LocalAuthApi {
  /// Returns true if this device supports authentication.
  @async
  bool isDeviceSupported();

  /// Attempts to authenticate the user with the provided [localizedReason] as
  /// the user-facing explanation for the authorization request.
  @async
  AuthResult authenticate(String localizedReason);
}
