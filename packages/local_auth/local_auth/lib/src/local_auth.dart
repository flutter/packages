// Copyright 2013 The Flutter Authors. All rights reserved.
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
  /// returns false. For other all other failures cases, throws a
  /// [LocalAuthException] with details about the reason it did not succeed.
  ///
  /// [localizedReason] is the message to show to user while prompting them
  /// for authentication. This is typically along the lines of: 'Authenticate
  /// to access MyApp.'. This must not be empty.
  ///
  /// Provide [authMessages] if you want to
  /// customize messages in the dialogs.
  ///
  /// Provide [options] for configuring further authentication related options.
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[
      IOSAuthMessages(),
      AndroidAuthMessages(),
      WindowsAuthMessages(),
    ],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) {
    return LocalAuthPlatform.instance.authenticate(
      localizedReason: localizedReason,
      authMessages: authMessages,
      options: options,
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
