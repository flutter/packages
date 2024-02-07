// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import 'src/messages.g.dart';
import 'types/auth_messages_ios.dart';

export 'package:local_auth_ios/types/auth_messages_ios.dart';
export 'package:local_auth_platform_interface/types/auth_messages.dart';
export 'package:local_auth_platform_interface/types/auth_options.dart';
export 'package:local_auth_platform_interface/types/biometric_type.dart';

/// The implementation of [LocalAuthPlatform] for iOS.
class LocalAuthIOS extends LocalAuthPlatform {
  /// Creates a new plugin implementation instance.
  LocalAuthIOS({
    @visibleForTesting LocalAuthApi? api,
  }) : _api = api ?? LocalAuthApi();

  /// Registers this class as the default instance of [LocalAuthPlatform].
  static void registerWith() {
    LocalAuthPlatform.instance = LocalAuthIOS();
  }

  final LocalAuthApi _api;

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
        _pigeonStringsFromAuthMessages(localizedReason, authMessages));
    // TODO(stuartmorgan): Replace this with structured errors, coordinated
    // across all platform implementations, per
    // https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages#platform-exception-handling
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
      // *************************** GTCXM-151 START ***********************
      // Handle other exception cases
      // *******************************************************************
      case AuthResult.callbackSetting:
        throw PlatformException(
            code: 'CallbackSetting',
            message: "callbackSetting",
            details: "callbackSetting");
      case AuthResult.iOSLockedOut:
        throw PlatformException(
            code: 'iOSLockedOut',
            message: "iOSLockedOut",
            details: "iOSLockedOut");
      case AuthResult.errorUserFallback:
        throw PlatformException(
            code: 'ErrorUserFallback',
            message: "errorUserFallback",
            details: "errorUserFallback");  
      case AuthResult.errorUserCancel:
        throw PlatformException(
            code: 'ErrorUserCancel',
            message: "errorUserCancel",
            details: "errorUserCancel");  
      // *************************** GTCXM-151 END ***********************
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
    final List<AuthBiometricWrapper?> result =
        await _api.getEnrolledBiometrics();
    return result
        .cast<AuthBiometricWrapper>()
        .map((AuthBiometricWrapper entry) {
      switch (entry.value) {
        case AuthBiometric.face:
          return BiometricType.face;
        case AuthBiometric.fingerprint:
          return BiometricType.fingerprint;
      }
    }).toList();
  }

  @override
  Future<bool> isDeviceSupported() async => _api.isDeviceSupported();

  /// Always returns false as this method is not supported on iOS.
  @override
  Future<bool> stopAuthentication() async => false;

  AuthStrings _pigeonStringsFromAuthMessages(
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
}
