// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
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
  })  : _api = api ?? LocalAuthApi(),
        _useMacOSAuthMessages =
            overrideUseMacOSAuthMessages ?? Platform.isMacOS;

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
            useErrorDialogs: options.useErrorDialogs),
        _useMacOSAuthMessages
            ? _pigeonStringsFromMacOSAuthMessages(localizedReason, authMessages)
            : _pigeonStringsFromiOSAuthMessages(localizedReason, authMessages));
    // TODO(stuartmorgan): Replace this with structured errors, coordinated
    // across all platform implementations, per
    // https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#platform-exception-handling
    // The PlatformExceptions thrown here are for compatibiilty with the
    // previous Objective-C implementation.
    switch (resultDetails.result) {
      case AuthResult.success:
        return true;
      case AuthResult.failure:
        return false;
      case AuthResult.errorNotAvailable:
        throw PlatformException(
            code: 'NotAvailable',
            message: resultDetails.errorMessage,
            details: resultDetails.errorDetails);
      case AuthResult.errorNotEnrolled:
        throw PlatformException(
            code: 'NotEnrolled',
            message: resultDetails.errorMessage,
            details: resultDetails.errorDetails);
      case AuthResult.errorPasscodeNotSet:
        throw PlatformException(
            code: 'PasscodeNotSet',
            message: resultDetails.errorMessage,
            details: resultDetails.errorDetails);
    }
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
      String localizedReason, Iterable<AuthMessages> messagesList) {
    IOSAuthMessages? messages;
    for (final AuthMessages entry in messagesList) {
      if (entry is IOSAuthMessages) {
        messages = entry;
        break;
      }
    }
    return AuthStrings(
      reason: localizedReason,
      lockOut: messages?.lockOut ?? iOSLockOut,
      goToSettingsButton: messages?.goToSettingsButton ?? goToSettings,
      goToSettingsDescription:
          messages?.goToSettingsDescription ?? iOSGoToSettingsDescription,
      // TODO(stuartmorgan): The default's name is confusing here for legacy
      // reasons; this should be fixed as part of some future breaking change.
      cancelButton: messages?.cancelButton ?? iOSOkButton,
      localizedFallbackTitle: messages?.localizedFallbackTitle,
    );
  }

  AuthStrings _pigeonStringsFromMacOSAuthMessages(
      String localizedReason, Iterable<AuthMessages> messagesList) {
    MacOSAuthMessages? messages;
    for (final AuthMessages entry in messagesList) {
      if (entry is MacOSAuthMessages) {
        messages = entry;
        break;
      }
    }
    return AuthStrings(
      reason: localizedReason,
      lockOut: messages?.lockOut ?? macOSLockOut,
      goToSettingsDescription:
          messages?.goToSettingsDescription ?? macOSGoToSettingsDescription,
      cancelButton: messages?.cancelButton ?? macOSCancelButton,
      localizedFallbackTitle: messages?.localizedFallbackTitle,
    );
  }
}
