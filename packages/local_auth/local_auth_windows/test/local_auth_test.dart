// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/src/services/binary_messenger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:local_auth_windows/local_auth_windows.dart';
import 'package:local_auth_windows/src/messages.g.dart';

void main() {
  group('authenticate', () {
    late _FakeLocalAuthApi api;
    late LocalAuthWindows plugin;

    setUp(() {
      api = _FakeLocalAuthApi();
      plugin = LocalAuthWindows(api: api);
    });

    test('authenticate handles success', () async {
      api.authReturnValue = AuthResult.success;

      final bool result = await plugin.authenticate(
        authMessages: <AuthMessages>[const WindowsAuthMessages()],
        localizedReason: 'My localized reason',
      );

      expect(result, true);
      expect(api.passedReason, 'My localized reason');
    });

    test('authenticate handles failure', () async {
      api.authReturnValue = AuthResult.failure;

      final bool result = await plugin.authenticate(
        authMessages: <AuthMessages>[const WindowsAuthMessages()],
        localizedReason: 'My localized reason',
      );

      expect(result, false);
      expect(api.passedReason, 'My localized reason');
    });

    test('authenticate handles no hardware', () async {
      api.authReturnValue = AuthResult.noHardware;

      await expectLater(
        plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason',
        ),
        throwsA(
          isA<LocalAuthException>().having(
            (LocalAuthException e) => e.code,
            'code',
            LocalAuthExceptionCode.noBiometricHardware,
          ),
        ),
      );
    });

    test('authenticate handles not enrolled', () async {
      api.authReturnValue = AuthResult.notEnrolled;

      await expectLater(
        plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason',
        ),
        throwsA(
          isA<LocalAuthException>().having(
            (LocalAuthException e) => e.code,
            'code',
            LocalAuthExceptionCode.noBiometricsEnrolled,
          ),
        ),
      );
    });

    test('authenticate handles busy', () async {
      api.authReturnValue = AuthResult.deviceBusy;

      await expectLater(
        plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason',
        ),
        throwsA(
          isA<LocalAuthException>().having(
            (LocalAuthException e) => e.code,
            'code',
            LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable,
          ),
        ),
      );
    });

    test('authenticate handles disabled by policy', () async {
      api.authReturnValue = AuthResult.disabledByPolicy;

      await expectLater(
        plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason',
        ),
        throwsA(
          isA<LocalAuthException>()
              .having(
                (LocalAuthException e) => e.code,
                'code',
                // Currently there is no specific error code for this case; it can
                // be added if there is user demand for it.
                LocalAuthExceptionCode.unknownError,
              )
              .having(
                (LocalAuthException e) => e.description,
                'description',
                contains('Group policy has disabled the authentication device'),
              ),
        ),
      );
    });

    test('authenticate handles generic error', () async {
      api.authReturnValue = AuthResult.unavailable;

      await expectLater(
        plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason',
        ),
        throwsA(
          isA<LocalAuthException>().having(
            (LocalAuthException e) => e.code,
            'code',
            LocalAuthExceptionCode.unknownError,
          ),
        ),
      );
    });

    test('authenticate throws for biometricOnly', () async {
      expect(
        plugin.authenticate(
          authMessages: <AuthMessages>[const WindowsAuthMessages()],
          localizedReason: 'My localized reason',
          options: const AuthenticationOptions(biometricOnly: true),
        ),
        throwsA(isUnsupportedError),
      );
    });

    test('isDeviceSupported handles supported', () async {
      api.supportedReturnValue = true;

      final bool result = await plugin.isDeviceSupported();

      expect(result, true);
    });

    test('isDeviceSupported handles unsupported', () async {
      api.supportedReturnValue = false;

      final bool result = await plugin.isDeviceSupported();

      expect(result, false);
    });

    test('deviceSupportsBiometrics handles supported', () async {
      api.supportedReturnValue = true;

      final bool result = await plugin.deviceSupportsBiometrics();

      expect(result, true);
    });

    test('deviceSupportsBiometrics handles unsupported', () async {
      api.supportedReturnValue = false;

      final bool result = await plugin.deviceSupportsBiometrics();

      expect(result, false);
    });

    test(
      'getEnrolledBiometrics returns expected values when supported',
      () async {
        api.supportedReturnValue = true;

        final List<BiometricType> result = await plugin.getEnrolledBiometrics();

        expect(result, <BiometricType>[
          BiometricType.weak,
          BiometricType.strong,
        ]);
      },
    );

    test('getEnrolledBiometrics returns nothing when unsupported', () async {
      api.supportedReturnValue = false;

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, isEmpty);
    });

    test('stopAuthentication returns false', () async {
      final bool result = await plugin.stopAuthentication();

      expect(result, false);
    });
  });
}

class _FakeLocalAuthApi implements LocalAuthApi {
  /// The return value for [authenticate].
  AuthResult authReturnValue = AuthResult.success;

  /// The return value for [isDeviceSupported].
  bool supportedReturnValue = false;

  /// The argument that was passed to [authenticate].
  String? passedReason;

  @override
  Future<AuthResult> authenticate(String localizedReason) async {
    passedReason = localizedReason;
    return authReturnValue;
  }

  @override
  Future<bool> isDeviceSupported() async {
    return supportedReturnValue;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
