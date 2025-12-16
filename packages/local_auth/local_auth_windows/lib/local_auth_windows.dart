// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import 'src/messages.g.dart';

export 'package:local_auth_platform_interface/types/auth_messages.dart';
export 'package:local_auth_platform_interface/types/auth_options.dart';
export 'package:local_auth_platform_interface/types/biometric_type.dart';
export 'package:local_auth_windows/types/auth_messages_windows.dart';

/// The implementation of [LocalAuthPlatform] for Windows.
class LocalAuthWindows extends LocalAuthPlatform {
  /// Creates a new plugin implementation instance.
  LocalAuthWindows({@visibleForTesting LocalAuthApi? api})
    : _api = api ?? LocalAuthApi();

  final LocalAuthApi _api;

  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthWindows();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    assert(localizedReason.isNotEmpty);

    if (options.biometricOnly) {
      throw UnsupportedError(
        "Windows doesn't support the biometricOnly parameter.",
      );
    }

    return switch (await _api.authenticate(localizedReason)) {
      AuthResult.success => true,
      AuthResult.failure => false,
      AuthResult.noHardware => throw const LocalAuthException(
        code: LocalAuthExceptionCode.noBiometricHardware,
      ),
      AuthResult.notEnrolled => throw const LocalAuthException(
        code: LocalAuthExceptionCode.noBiometricsEnrolled,
      ),
      AuthResult.deviceBusy => throw const LocalAuthException(
        code: LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable,
      ),
      AuthResult.disabledByPolicy =>
        // This error is niche enough that it doesn't warrant a specific
        // mapping, so just use unknownError with a description.
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.unknownError,
          description: 'Group policy has disabled the authentication device.',
        ),
      AuthResult.unavailable => throw const LocalAuthException(
        code: LocalAuthExceptionCode.unknownError,
        description: 'Authentication failed with an unsupported result code.',
      ),
    };
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    // Biometrics are supported on any supported device.
    return isDeviceSupported();
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    // Windows doesn't support querying specific biometric types. Since the
    // OS considers this a strong authentication API, return weak+strong on
    // any supported device.
    if (await isDeviceSupported()) {
      return <BiometricType>[BiometricType.weak, BiometricType.strong];
    }
    return <BiometricType>[];
  }

  @override
  Future<bool> isDeviceSupported() async => _api.isDeviceSupported();

  /// Always returns false as this method is not supported on Windows.
  @override
  Future<bool> stopAuthentication() async => false;
}
