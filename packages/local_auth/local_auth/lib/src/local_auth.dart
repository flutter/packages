// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a temporary ignore to allow us to land a new set of linter rules in a
// series of manageable patches instead of one gigantic PR. It disables some of
// the new lints that are already failing on this plugin, for this plugin. It
// should be deleted and the failing lints addressed as soon as possible.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

/// A Flutter plugin for authenticating the user identity locally.
class LocalAuthentication {
  /// Authenticates the user with biometrics available on the device while also
  /// allowing the user to use device authentication - pin, pattern, passcode.
  ///
  /// Returns true if the user successfully authenticated.
  ///
  /// If the user fails the authentication challenge without any side effects,
  /// returns false. For other other failures cases, throws a
  /// [LocalAuthException] with details about the reason it did not succeed.
  ///
  /// [localizedReason] is the message to show to user while prompting them
  /// for authentication. This is typically along the lines of: 'Authenticate
  /// to access MyApp.'. This must not be empty.
  ///
  /// Provide [authMessages] if you want to customize messages in the dialogs.
  ///
  /// Set [biometricOnly] to true to prevent authentications from using
  /// non-biometric local authentication such as pin, passcode, or pattern.
  ///
  /// [sensitiveTransaction], which defaults to true, controls whether
  /// platform-specific precautions are enabled, such as showing a confirmation
  /// dialog after face unlock is recognized to make sure the user meant to
  /// unlock their device.
  ///
  /// On mobile platforms, authentication may be stopped by the system when the
  /// app is backgrounded during an authentication. Set
  /// [persistAcrossBackgrounding] to true to have the plugin automatically
  /// retry the authentication on foregrounding instead of failing with an error
  /// on backgrounding.
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[
      IOSAuthMessages(),
      AndroidAuthMessages(),
      WindowsAuthMessages(),
    ],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) {
    return LocalAuthPlatform.instance.authenticate(
      localizedReason: localizedReason,
      authMessages: authMessages,
      options: AuthenticationOptions(
        stickyAuth: persistAcrossBackgrounding,
        biometricOnly: biometricOnly,
        sensitiveTransaction: sensitiveTransaction,
        // This is a legacy option; implementations compatible with 3.x plus
        // should always assume this is false, so set it accordingly.
        useErrorDialogs: false,
      ),
    );
  }

  /// Cancels any in-progress authentication, returning true if auth was
  /// canceled successfully.
  ///
  /// This API may not be supported by all platforms.
  ///
  /// Returns false if there was some error, no authentication is in progress,
  /// or the current platform lacks support.
  Future<bool> stopAuthentication() async {
    return LocalAuthPlatform.instance.stopAuthentication();
  }

  /// Returns true if device is capable of checking biometrics.
  Future<bool> get canCheckBiometrics =>
      LocalAuthPlatform.instance.deviceSupportsBiometrics();

  /// Returns true if device is capable of checking biometrics or is able to
  /// fail over to device credentials.
  Future<bool> isDeviceSupported() async =>
      LocalAuthPlatform.instance.isDeviceSupported();

  /// Returns a list of enrolled biometrics.
  Future<List<BiometricType>> getAvailableBiometrics() =>
      LocalAuthPlatform.instance.getEnrolledBiometrics();
}
