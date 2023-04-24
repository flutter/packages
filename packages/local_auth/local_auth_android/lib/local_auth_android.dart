// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
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
  LocalAuthAndroid({
    @visibleForTesting LocalAuthApi? api,
  }) : _api = api ?? LocalAuthApi();

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
    final AuthResult result = (await _api.authenticate(
            AuthOptions(
                biometricOnly: options.biometricOnly,
                sensitiveTransaction: options.sensitiveTransaction,
                sticky: options.stickyAuth,
                useErrorDialgs: options.useErrorDialogs),
            _pigeonStringsFromAuthMessages(localizedReason, authMessages)))
        .value;
    // TODO(stuartmorgan): Replace this with structured errors, coordinated
    // across all platform implementations, per
    // https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages#platform-exception-handling
    // The PlatformExceptions thrown here are for compatibiilty with the
    // previous Java implementation.
    switch (result) {
      case AuthResult.success:
        return true;
      case AuthResult.failure:
        return false;
      case AuthResult.errorAlreadyInProgress:
        throw PlatformException(
            code: 'auth_in_progress', message: 'Authentication in progress');
      case AuthResult.errorNoActivity:
        throw PlatformException(
            code: 'no_activity',
            message: 'local_auth plugin requires a foreground activity');
      case AuthResult.errorNotFragmentActivity:
        throw PlatformException(
            code: 'no_fragment_activity',
            message:
                'local_auth plugin requires activity to be a FragmentActivity.');
      case AuthResult.errorNotAvailable:
        throw PlatformException(
            code: 'NotAvailable',
            message: 'Security credentials not available.');
      case AuthResult.errorNotEnrolled:
        throw PlatformException(
            code: 'NotEnrolled',
            message: 'No Biometrics enrolled on this device.');
      case AuthResult.errorLockedOutTemporarily:
        throw PlatformException(
            code: 'LockedOut',
            message: 'The operation was canceled because the API is locked out '
                'due to too many attempts. This occurs after 5 failed '
                'attempts, and lasts for 30 seconds.');
      case AuthResult.errorLockedOutPermanently:
        throw PlatformException(
            code: 'PermanentlyLockedOut',
            message: 'The operation was canceled because ERROR_LOCKOUT '
                'occurred too many times. Biometric authentication is disabled '
                'until the user unlocks with strong authentication '
                '(PIN/Pattern/Password)');
    }
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    return _api.deviceCanSupportBiometrics();
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    final List<AuthClassificationWrapper?> result =
        await _api.getEnrolledBiometrics();
    return result
        .cast<AuthClassificationWrapper>()
        .map((AuthClassificationWrapper entry) {
      switch (entry.value) {
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
      String localizedReason, Iterable<AuthMessages> messagesList) {
    AndroidAuthMessages? messages;
    for (final AuthMessages entry in messagesList) {
      if (entry is AndroidAuthMessages) {
        messages = entry;
      }
    }
    return AuthStrings(
        reason: localizedReason,
        biometricHint: messages?.biometricHint ?? androidBiometricHint,
        biometricNotRecognized:
            messages?.biometricNotRecognized ?? androidBiometricNotRecognized,
        biometricRequiredTitle:
            messages?.biometricRequiredTitle ?? androidBiometricRequiredTitle,
        cancelButton: messages?.cancelButton ?? androidCancelButton,
        deviceCredentialsRequiredTitle:
            messages?.deviceCredentialsRequiredTitle ??
                androidDeviceCredentialsRequiredTitle,
        deviceCredentialsSetupDescription:
            messages?.deviceCredentialsSetupDescription ??
                androidDeviceCredentialsSetupDescription,
        goToSettingsButton: messages?.goToSettingsButton ?? goToSettings,
        goToSettingsDescription:
            messages?.goToSettingsDescription ?? androidGoToSettingsDescription,
        signInTitle: messages?.signInTitle ?? androidSignInTitle);
  }
}
