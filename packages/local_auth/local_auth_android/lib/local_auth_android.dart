// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import 'src/auth_messages_android.dart';
import 'src/messages.g.dart';

export 'package:local_auth_android/src/auth_messages_android.dart';
export 'package:local_auth_platform_interface/types/auth_messages.dart';
export 'package:local_auth_platform_interface/types/auth_options.dart';
export 'package:local_auth_platform_interface/types/biometric_type.dart';

/// The implementation of [LocalAuthPlatform] for Android.
class LocalAuthAndroid extends LocalAuthPlatform {
  /// Creates a new plugin implementation instance.
  LocalAuthAndroid({@visibleForTesting LocalAuthApi? api})
    : _api = api ?? LocalAuthApi();

  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthAndroid();
  }

  final LocalAuthApi _api;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    assert(localizedReason.isNotEmpty);
    final AuthResult result = await _api.authenticate(
      AuthOptions(
        biometricOnly: options.biometricOnly,
        sensitiveTransaction: options.sensitiveTransaction,
        sticky: options.stickyAuth,
      ),
      _pigeonStringsFromAuthMessages(localizedReason, authMessages),
    );
    switch (result.code) {
      case AuthResultCode.success:
        return true;
      case AuthResultCode.negativeButton:
      case AuthResultCode.userCanceled:
        // Variants of user cancelation format are not currently distinguished,
        // but could be if there's a use case for it in the future.
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.userCanceled,
        );
      case AuthResultCode.systemCanceled:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.systemCanceled,
        );
      case AuthResultCode.timeout:
        throw const LocalAuthException(code: LocalAuthExceptionCode.timeout);
      case AuthResultCode.alreadyInProgress:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.authInProgress,
        );
      case AuthResultCode.noActivity:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.uiUnavailable,
          description: 'No Activity available.',
        );
      case AuthResultCode.notFragmentActivity:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.uiUnavailable,
          description: 'The current Activity must be a FragmentActivity.',
        );
      case AuthResultCode.noCredentials:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.noCredentialsSet,
        );
      case AuthResultCode.noHardware:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricHardware,
        );
      case AuthResultCode.hardwareUnavailable:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable,
        );
      case AuthResultCode.notEnrolled:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricsEnrolled,
        );
      case AuthResultCode.lockedOutTemporarily:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.temporaryLockout,
        );
      case AuthResultCode.lockedOutPermanently:
        throw const LocalAuthException(
          code: LocalAuthExceptionCode.biometricLockout,
        );
      case AuthResultCode.noSpace:
        throw LocalAuthException(
          code: LocalAuthExceptionCode.deviceError,
          description: 'Not enough space available: ${result.errorMessage}',
        );
      case AuthResultCode.securityUpdateRequired:
        throw LocalAuthException(
          code: LocalAuthExceptionCode.deviceError,
          description: 'Security update required: ${result.errorMessage}',
        );
      case AuthResultCode.unknownError:
        throw LocalAuthException(
          code: LocalAuthExceptionCode.unknownError,
          description: result.errorMessage,
        );
    }
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    return _api.deviceCanSupportBiometrics();
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    final List<AuthClassification>? result = await _api.getEnrolledBiometrics();
    if (result == null) {
      throw const LocalAuthException(
        code: LocalAuthExceptionCode.uiUnavailable,
        description: 'No Activity available.',
      );
    }
    return result.map((AuthClassification value) {
      switch (value) {
        case AuthClassification.weak:
          return BiometricType.weak;
        case AuthClassification.strong:
          return BiometricType.strong;
      }
    }).toList();
  }

  @override
  Future<bool> isDeviceSupported() async => _api.isDeviceSupported();

  @override
  Future<bool> stopAuthentication() async => _api.stopAuthentication();

  AuthStrings _pigeonStringsFromAuthMessages(
    String localizedReason,
    Iterable<AuthMessages> messagesList,
  ) {
    AndroidAuthMessages? messages;
    for (final entry in messagesList) {
      if (entry is AndroidAuthMessages) {
        messages = entry;
      }
    }
    return AuthStrings(
      reason: localizedReason,
      signInHint: messages?.signInHint ?? androidSignInHint,
      cancelButton: messages?.cancelButton ?? androidCancelButton,
      signInTitle: messages?.signInTitle ?? androidSignInTitle,
    );
  }
}
