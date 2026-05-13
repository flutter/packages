// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import 'src/messages.g.dart';
import 'types/auth_messages_ios.dart';
import 'types/auth_messages_macos.dart';

export 'package:local_auth_darwin/types/auth_messages_ios.dart';
export 'package:local_auth_platform_interface/types/auth_messages.dart';
export 'package:local_auth_platform_interface/types/auth_options.dart';
export 'package:local_auth_platform_interface/types/biometric_type.dart';

/// The implementation of [LocalAuthPlatform] for iOS and macOS.
class LocalAuthDarwin extends LocalAuthPlatform {
  /// Creates a new plugin implementation instance.
  LocalAuthDarwin({
    @visibleForTesting LocalAuthApi? api,
    @visibleForTesting bool? overrideUseMacOSAuthMessages,
  }) : _api = api ?? LocalAuthApi(),
       _useMacOSAuthMessages = overrideUseMacOSAuthMessages ?? Platform.isMacOS;

  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthDarwin();
  }

  final LocalAuthApi _api;
  final bool _useMacOSAuthMessages;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    assert(localizedReason.isNotEmpty);
    final AuthResultDetails resultDetails = await _api.authenticate(
      AuthOptions(
        biometricOnly: options.biometricOnly,
        sticky: options.stickyAuth,
      ),
      _useMacOSAuthMessages
          ? _pigeonStringsFromMacOSAuthMessages(localizedReason, authMessages)
          : _pigeonStringsFromiOSAuthMessages(localizedReason, authMessages),
    );
    LocalAuthExceptionCode code;
    switch (resultDetails.result) {
      case AuthResult.success:
        return true;
      case AuthResult.authenticationFailed:
        return false;
      case AuthResult.appCancel:
        // If the plugin client intentionally canceled authentication, no need
        // to return a specific error.
        return false;
      case AuthResult.uiUnavailable:
        code = LocalAuthExceptionCode.uiUnavailable;
      case AuthResult.systemCancel:
        code = LocalAuthExceptionCode.systemCanceled;
      case AuthResult.userCancel:
        code = LocalAuthExceptionCode.userCanceled;
      case AuthResult.biometryDisconnected:
        code = LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable;
      case AuthResult.biometryLockout:
        code = LocalAuthExceptionCode.biometricLockout;
      case AuthResult.biometryNotAvailable:
      // Treated as no hardware since docs suggest that this means that there is
      // no known device; paired but not connected is biometryDisconnected.
      case AuthResult.biometryNotPaired:
        code = LocalAuthExceptionCode.noBiometricHardware;
      case AuthResult.biometryNotEnrolled:
        code = LocalAuthExceptionCode.noBiometricsEnrolled;
      case AuthResult.invalidContext:
      case AuthResult.invalidDimensions:
      case AuthResult.notInteractive:
        code = LocalAuthExceptionCode.uiUnavailable;
      case AuthResult.passcodeNotSet:
        code = LocalAuthExceptionCode.noCredentialsSet;
      case AuthResult.userFallback:
        code = LocalAuthExceptionCode.userRequestedFallback;
      case AuthResult.unknownError:
        code = LocalAuthExceptionCode.unknownError;
    }
    throw LocalAuthException(
      code: code,
      description: resultDetails.errorMessage,
      details: resultDetails.errorDetails,
    );
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    return _api.deviceCanSupportBiometrics();
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    final List<AuthBiometric> result = await _api.getEnrolledBiometrics();
    return result.map((AuthBiometric value) {
      switch (value) {
        case AuthBiometric.face:
          return BiometricType.face;
        case AuthBiometric.fingerprint:
          return BiometricType.fingerprint;
      }
    }).toList();
  }

  @override
  Future<bool> isDeviceSupported() async => _api.isDeviceSupported();

  /// Always returns false as this method is not supported on iOS or macOS.
  @override
  Future<bool> stopAuthentication() async => false;

  AuthStrings _pigeonStringsFromiOSAuthMessages(
    String localizedReason,
    Iterable<AuthMessages> messagesList,
  ) {
    IOSAuthMessages? messages;
    for (final entry in messagesList) {
      if (entry is IOSAuthMessages) {
        messages = entry;
        break;
      }
    }
    return AuthStrings(
      reason: localizedReason,
      cancelButton: messages?.cancelButton ?? iOSCancelButton,
      localizedFallbackTitle: messages?.localizedFallbackTitle,
    );
  }

  AuthStrings _pigeonStringsFromMacOSAuthMessages(
    String localizedReason,
    Iterable<AuthMessages> messagesList,
  ) {
    MacOSAuthMessages? messages;
    for (final entry in messagesList) {
      if (entry is MacOSAuthMessages) {
        messages = entry;
        break;
      }
    }
    return AuthStrings(
      reason: localizedReason,
      cancelButton: messages?.cancelButton ?? macOSCancelButton,
      localizedFallbackTitle: messages?.localizedFallbackTitle,
    );
  }
}
