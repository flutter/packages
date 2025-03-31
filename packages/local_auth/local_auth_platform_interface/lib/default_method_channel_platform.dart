// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'local_auth_platform_interface.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/local_auth');

/// The default interface implementation acting as a placeholder for
/// the native implementation to be set.
///
/// This implementation is not used by any of the implementations in this
/// repository, and exists only for backward compatibility with any
/// clients that were relying on internal details of the method channel
/// in the pre-federated plugin.
class DefaultLocalAuthPlatform extends LocalAuthPlatform {
  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    assert(localizedReason.isNotEmpty);
    final Map<String, Object> args = <String, Object>{
      'localizedReason': localizedReason,
      'useErrorDialogs': options.useErrorDialogs,
      'stickyAuth': options.stickyAuth,
      'sensitiveTransaction': options.sensitiveTransaction,
      'biometricOnly': options.biometricOnly,
    };
    for (final AuthMessages messages in authMessages) {
      args.addAll(messages.args);
    }
    return (await _channel.invokeMethod<bool>('authenticate', args)) ?? false;
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    final List<String> result = (await _channel.invokeListMethod<String>(
          'getAvailableBiometrics',
        )) ??
        <String>[];
    final List<BiometricType> biometrics = <BiometricType>[];
    for (final String value in result) {
      switch (value) {
        case 'face':
          biometrics.add(BiometricType.face);
        case 'fingerprint':
          biometrics.add(BiometricType.fingerprint);
        case 'iris':
          biometrics.add(BiometricType.iris);
        case 'undefined':
          // Sentinel value for the case when nothing is enrolled, but hardware
          // support for biometrics is available.
          break;
      }
    }
    return biometrics;
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    final List<String> availableBiometrics =
        (await _channel.invokeListMethod<String>(
              'getAvailableBiometrics',
            )) ??
            <String>[];
    // If anything, including the 'undefined' sentinel, is returned, then there
    // is device support for biometrics.
    return availableBiometrics.isNotEmpty;
  }

  @override
  Future<bool> isDeviceSupported() async =>
      (await _channel.invokeMethod<bool>('isDeviceSupported')) ?? false;

  @override
  Future<bool> stopAuthentication() async =>
      await _channel.invokeMethod<bool>('stopAuthentication') ?? false;
}
