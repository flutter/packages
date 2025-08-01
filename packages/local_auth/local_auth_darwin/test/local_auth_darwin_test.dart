// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_darwin/src/messages.g.dart';
import 'package:local_auth_darwin/types/auth_messages_macos.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_auth_darwin_test.mocks.dart';

@GenerateMocks(<Type>[LocalAuthApi])
void main() {
  late MockLocalAuthApi api;
  late LocalAuthDarwin plugin;

  setUp(() {
    api = MockLocalAuthApi();
    plugin = LocalAuthDarwin(api: api);
  });

  test('registers instance', () {
    LocalAuthDarwin.registerWith();
    expect(LocalAuthPlatform.instance, isA<LocalAuthDarwin>());
  });

  group('deviceSupportsBiometrics', () {
    test('handles true', () async {
      when(api.deviceCanSupportBiometrics()).thenAnswer((_) async => true);
      expect(await plugin.deviceSupportsBiometrics(), true);
    });

    test('handles false', () async {
      when(api.deviceCanSupportBiometrics()).thenAnswer((_) async => false);
      expect(await plugin.deviceSupportsBiometrics(), false);
    });
  });

  group('isDeviceSupported', () {
    test('handles true', () async {
      when(api.isDeviceSupported()).thenAnswer((_) async => true);
      expect(await plugin.isDeviceSupported(), true);
    });

    test('handles false', () async {
      when(api.isDeviceSupported()).thenAnswer((_) async => false);
      expect(await plugin.isDeviceSupported(), false);
    });
  });

  group('stopAuthentication', () {
    test('always returns false', () async {
      expect(await plugin.stopAuthentication(), false);
    });
  });

  group('getEnrolledBiometrics', () {
    test('translates values', () async {
      when(api.getEnrolledBiometrics()).thenAnswer((_) async => <AuthBiometric>[
            AuthBiometric.face,
            AuthBiometric.fingerprint,
          ]);

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[
        BiometricType.face,
        BiometricType.fingerprint,
      ]);
    });

    test('handles empty', () async {
      when(api.getEnrolledBiometrics())
          .thenAnswer((_) async => <AuthBiometric>[]);

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[]);
    });
  });

  group('authenticate', () {
    group('strings', () {
      test('passes default values when nothing is provided', () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        const String reason = 'test reason';
        await plugin.authenticate(
            localizedReason: reason, authMessages: <AuthMessages>[]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the default values from
        // auth_messages_ios.dart
        expect(strings.lockOut, iOSLockOut);
        expect(strings.goToSettingsButton, goToSettings);
        expect(strings.goToSettingsDescription, iOSGoToSettingsDescription);
        expect(strings.cancelButton, iOSOkButton);
        expect(strings.localizedFallbackTitle, null);
      });

      test('passes default values when only other platform values are provided',
          () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        const String reason = 'test reason';
        await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[AnotherPlatformAuthMessages()]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the default values from
        // auth_messages_ios.dart
        expect(strings.lockOut, iOSLockOut);
        expect(strings.goToSettingsButton, goToSettings);
        expect(strings.goToSettingsDescription, iOSGoToSettingsDescription);
        expect(strings.cancelButton, iOSOkButton);
        expect(strings.localizedFallbackTitle, null);
      });

      test(
          'passes default values when only MacOSAuthMessages platform values are provided',
          () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: true);

        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        const String reason = 'test reason';
        await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[const MacOSAuthMessages()]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the default values from
        // auth_messages_ios.dart
        expect(strings.lockOut, macOSLockOut);
        expect(strings.goToSettingsDescription, macOSGoToSettingsDescription);
        expect(strings.cancelButton, macOSCancelButton);
        expect(strings.localizedFallbackTitle, null);
      });

      test(
        'passes all non-default values correctly with IOSAuthMessages',
        () async {
          plugin =
              LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

          when(api.authenticate(any, any)).thenAnswer(
              (_) async => AuthResultDetails(result: AuthResult.success));

          // These are arbitrary values; all that matters is that:
          // - they are different from the defaults, and
          // - they are different from each other.
          const String reason = 'A';
          const String lockOut = 'B';
          const String goToSettingsButton = 'C';
          const String gotToSettingsDescription = 'D';
          const String cancel = 'E';
          const String localizedFallbackTitle = 'F';

          await plugin.authenticate(
              localizedReason: reason,
              authMessages: <AuthMessages>[
                const IOSAuthMessages(
                  lockOut: lockOut,
                  goToSettingsButton: goToSettingsButton,
                  goToSettingsDescription: gotToSettingsDescription,
                  cancelButton: cancel,
                  localizedFallbackTitle: localizedFallbackTitle,
                ),
                AnotherPlatformAuthMessages(),
              ]);

          final VerificationResult result =
              verify(api.authenticate(any, captureAny));
          final AuthStrings strings = result.captured[0] as AuthStrings;
          expect(strings.reason, reason);
          expect(strings.lockOut, lockOut);
          expect(strings.goToSettingsButton, goToSettingsButton);
          expect(strings.goToSettingsDescription, gotToSettingsDescription);
          expect(strings.cancelButton, cancel);
          expect(strings.localizedFallbackTitle, localizedFallbackTitle);
        },
      );

      test('passes all non-default values correctly with MacOSAuthMessages',
          () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: true);
        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const String reason = 'A';
        const String lockOut = 'B';
        const String cancel = 'E';
        const String localizedFallbackTitle = 'F';
        await plugin
            .authenticate(localizedReason: reason, authMessages: <AuthMessages>[
          const MacOSAuthMessages(
            lockOut: lockOut,
            cancelButton: cancel,
            localizedFallbackTitle: localizedFallbackTitle,
          ),
          AnotherPlatformAuthMessages(),
        ]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        expect(strings.lockOut, lockOut);
        expect(strings.cancelButton, cancel);
        expect(strings.localizedFallbackTitle, localizedFallbackTitle);
      });

      test('passes provided messages with default fallbacks', () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const String reason = 'A';
        const String lockOut = 'B';
        const String localizedFallbackTitle = 'C';
        const String cancel = 'D';
        await plugin
            .authenticate(localizedReason: reason, authMessages: <AuthMessages>[
          const IOSAuthMessages(
            lockOut: lockOut,
            localizedFallbackTitle: localizedFallbackTitle,
            cancelButton: cancel,
          ),
        ]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the provided values.
        expect(strings.lockOut, lockOut);
        expect(strings.localizedFallbackTitle, localizedFallbackTitle);
        expect(strings.cancelButton, cancel);
        // These were not set, so should all be the default values from
        // auth_messages_ios.dart
        expect(strings.goToSettingsButton, goToSettings);
        expect(strings.goToSettingsDescription, iOSGoToSettingsDescription);
      });
    });

    group('options', () {
      test('passes default values', () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        await plugin.authenticate(
            localizedReason: 'reason', authMessages: <AuthMessages>[]);

        final VerificationResult result =
            verify(api.authenticate(captureAny, any));
        final AuthOptions options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, false);
        expect(options.sticky, false);
        expect(options.useErrorDialogs, true);
      });

      test('passes provided non-default values', () async {
        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        await plugin.authenticate(
            localizedReason: 'reason',
            authMessages: <AuthMessages>[],
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
              useErrorDialogs: false,
            ));

        final VerificationResult result =
            verify(api.authenticate(captureAny, any));
        final AuthOptions options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, true);
        expect(options.sticky, true);
        expect(options.useErrorDialogs, false);
      });
    });

    group('return values', () {
      test('handles success', () async {
        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success));

        final bool result = await plugin.authenticate(
            localizedReason: 'reason', authMessages: <AuthMessages>[]);

        expect(result, true);
      });

      test('handles failure', () async {
        when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.failure));

        final bool result = await plugin.authenticate(
            localizedReason: 'reason', authMessages: <AuthMessages>[]);

        expect(result, false);
      });

      test('converts errorNotAvailable to legacy PlatformException', () async {
        const String errorMessage = 'a message';
        const String errorDetails = 'some details';
        when(api.authenticate(any, any)).thenAnswer((_) async =>
            AuthResultDetails(
                result: AuthResult.errorNotAvailable,
                errorMessage: errorMessage,
                errorDetails: errorDetails));

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'NotAvailable')
                .having(
                    (PlatformException e) => e.message, 'message', errorMessage)
                .having((PlatformException e) => e.details, 'details',
                    errorDetails)));
      });

      test('converts errorNotEnrolled to legacy PlatformException', () async {
        const String errorMessage = 'a message';
        const String errorDetails = 'some details';
        when(api.authenticate(any, any)).thenAnswer((_) async =>
            AuthResultDetails(
                result: AuthResult.errorNotEnrolled,
                errorMessage: errorMessage,
                errorDetails: errorDetails));

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'NotEnrolled')
                .having(
                    (PlatformException e) => e.message, 'message', errorMessage)
                .having((PlatformException e) => e.details, 'details',
                    errorDetails)));
      });

      test('converts errorUserCancelled to PlatformException', () async {
        const String errorMessage = 'The user cancelled authentication.';
        const String errorDetails = 'com.apple.LocalAuthentication';
        when(api.authenticate(any, any)).thenAnswer((_) async =>
            AuthResultDetails(
                result: AuthResult.errorUserCancelled,
                errorMessage: errorMessage,
                errorDetails: errorDetails));

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having(
                    (PlatformException e) => e.code, 'code', 'UserCancelled')
                .having(
                    (PlatformException e) => e.message, 'message', errorMessage)
                .having((PlatformException e) => e.details, 'details',
                    errorDetails)));
      });

      test('converts errorUserFallback to PlatformException', () async {
        const String errorMessage = 'The user chose to use the fallback.';
        const String errorDetails = 'com.apple.LocalAuthentication';
        when(api.authenticate(any, any)).thenAnswer((_) async =>
            AuthResultDetails(
                result: AuthResult.errorUserFallback,
                errorMessage: errorMessage,
                errorDetails: errorDetails));

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'UserFallback')
                .having(
                    (PlatformException e) => e.message, 'message', errorMessage)
                .having((PlatformException e) => e.details, 'details',
                    errorDetails)));
      });

      test('converts errorBiometricNotAvailable to PlatformException',
          () async {
        const String errorMessage =
            'Biometrics are not available on this device.';
        const String errorDetails = 'com.apple.LocalAuthentication';
        when(api.authenticate(any, any)).thenAnswer((_) async =>
            AuthResultDetails(
                result: AuthResult.errorBiometricNotAvailable,
                errorMessage: errorMessage,
                errorDetails: errorDetails));

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                // The code here should match what you defined in your Dart switch statement.
                .having((PlatformException e) => e.code, 'code',
                    'BiometricNotAvailable')
                .having(
                    (PlatformException e) => e.message, 'message', errorMessage)
                .having((PlatformException e) => e.details, 'details',
                    errorDetails)));
      });

      test('converts errorPasscodeNotSet to legacy PlatformException',
          () async {
        const String errorMessage = 'a message';
        const String errorDetails = 'some details';
        when(api.authenticate(any, any)).thenAnswer((_) async =>
            AuthResultDetails(
                result: AuthResult.errorPasscodeNotSet,
                errorMessage: errorMessage,
                errorDetails: errorDetails));

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having(
                    (PlatformException e) => e.code, 'code', 'PasscodeNotSet')
                .having(
                    (PlatformException e) => e.message, 'message', errorMessage)
                .having((PlatformException e) => e.details, 'details',
                    errorDetails)));
      });
    });
  });
}

class AnotherPlatformAuthMessages extends AuthMessages {
  @override
  Map<String, String> get args => throw UnimplementedError();
}
