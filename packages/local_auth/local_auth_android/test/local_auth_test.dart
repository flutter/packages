// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_android/src/messages.g.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_auth_test.mocks.dart';

@GenerateMocks(<Type>[LocalAuthApi])
void main() {
  late MockLocalAuthApi api;
  late LocalAuthAndroid plugin;

  setUp(() {
    api = MockLocalAuthApi();
    plugin = LocalAuthAndroid(api: api);
  });

  test('registers instance', () {
    LocalAuthAndroid.registerWith();
    expect(LocalAuthPlatform.instance, isA<LocalAuthAndroid>());
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
    test('handles true', () async {
      when(api.stopAuthentication()).thenAnswer((_) async => true);
      expect(await plugin.stopAuthentication(), true);
    });

    test('handles false', () async {
      when(api.stopAuthentication()).thenAnswer((_) async => false);
      expect(await plugin.stopAuthentication(), false);
    });
  });

  group('getEnrolledBiometrics', () {
    test('translates values', () async {
      when(api.getEnrolledBiometrics())
          .thenAnswer((_) async => <AuthClassification>[
                AuthClassification.weak,
                AuthClassification.strong,
              ]);

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[
        BiometricType.weak,
        BiometricType.strong,
      ]);
    });

    test('handles empty', () async {
      when(api.getEnrolledBiometrics())
          .thenAnswer((_) async => <AuthClassification>[]);

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[]);
    });
  });

  group('authenticate', () {
    group('strings', () {
      test('passes default values when nothing is provided', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        const String reason = 'test reason';
        await plugin.authenticate(
            localizedReason: reason, authMessages: <AuthMessages>[]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the default values from
        // auth_messages_android.dart
        expect(strings.biometricHint, androidBiometricHint);
        expect(strings.biometricNotRecognized, androidBiometricNotRecognized);
        expect(strings.biometricRequiredTitle, androidBiometricRequiredTitle);
        expect(strings.cancelButton, androidCancelButton);
        expect(strings.deviceCredentialsRequiredTitle,
            androidDeviceCredentialsRequiredTitle);
        expect(strings.deviceCredentialsSetupDescription,
            androidDeviceCredentialsSetupDescription);
        expect(strings.goToSettingsButton, goToSettings);
        expect(strings.goToSettingsDescription, androidGoToSettingsDescription);
        expect(strings.signInTitle, androidSignInTitle);
      });

      test('passes default values when only other platform values are provided',
          () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        const String reason = 'test reason';
        await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[AnotherPlatformAuthMessages()]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the default values from
        // auth_messages_android.dart
        expect(strings.biometricHint, androidBiometricHint);
        expect(strings.biometricNotRecognized, androidBiometricNotRecognized);
        expect(strings.biometricRequiredTitle, androidBiometricRequiredTitle);
        expect(strings.cancelButton, androidCancelButton);
        expect(strings.deviceCredentialsRequiredTitle,
            androidDeviceCredentialsRequiredTitle);
        expect(strings.deviceCredentialsSetupDescription,
            androidDeviceCredentialsSetupDescription);
        expect(strings.goToSettingsButton, goToSettings);
        expect(strings.goToSettingsDescription, androidGoToSettingsDescription);
        expect(strings.signInTitle, androidSignInTitle);
      });

      test('passes all non-default values correctly', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const String reason = 'A';
        const String hint = 'B';
        const String bioNotRecognized = 'C';
        const String bioRequired = 'D';
        const String cancel = 'E';
        const String credentialsRequired = 'F';
        const String credentialsSetup = 'G';
        const String goButton = 'H';
        const String goDescription = 'I';
        const String signInTitle = 'J';
        await plugin
            .authenticate(localizedReason: reason, authMessages: <AuthMessages>[
          const AndroidAuthMessages(
            biometricHint: hint,
            biometricNotRecognized: bioNotRecognized,
            biometricRequiredTitle: bioRequired,
            cancelButton: cancel,
            deviceCredentialsRequiredTitle: credentialsRequired,
            deviceCredentialsSetupDescription: credentialsSetup,
            goToSettingsButton: goButton,
            goToSettingsDescription: goDescription,
            signInTitle: signInTitle,
          ),
          AnotherPlatformAuthMessages(),
        ]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        expect(strings.biometricHint, hint);
        expect(strings.biometricNotRecognized, bioNotRecognized);
        expect(strings.biometricRequiredTitle, bioRequired);
        expect(strings.cancelButton, cancel);
        expect(strings.deviceCredentialsRequiredTitle, credentialsRequired);
        expect(strings.deviceCredentialsSetupDescription, credentialsSetup);
        expect(strings.goToSettingsButton, goButton);
        expect(strings.goToSettingsDescription, goDescription);
        expect(strings.signInTitle, signInTitle);
      });

      test('passes provided messages with default fallbacks', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const String reason = 'A';
        const String hint = 'B';
        const String bioNotRecognized = 'C';
        const String bioRequired = 'D';
        const String cancel = 'E';
        await plugin
            .authenticate(localizedReason: reason, authMessages: <AuthMessages>[
          const AndroidAuthMessages(
            biometricHint: hint,
            biometricNotRecognized: bioNotRecognized,
            biometricRequiredTitle: bioRequired,
            cancelButton: cancel,
          ),
        ]);

        final VerificationResult result =
            verify(api.authenticate(any, captureAny));
        final AuthStrings strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the provided values.
        expect(strings.biometricHint, hint);
        expect(strings.biometricNotRecognized, bioNotRecognized);
        expect(strings.biometricRequiredTitle, bioRequired);
        expect(strings.cancelButton, cancel);
        // These were non set, so should all be the default values from
        // auth_messages_android.dart
        expect(strings.deviceCredentialsRequiredTitle,
            androidDeviceCredentialsRequiredTitle);
        expect(strings.deviceCredentialsSetupDescription,
            androidDeviceCredentialsSetupDescription);
        expect(strings.goToSettingsButton, goToSettings);
        expect(strings.goToSettingsDescription, androidGoToSettingsDescription);
        expect(strings.signInTitle, androidSignInTitle);
      });
    });

    group('options', () {
      test('passes default values', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        await plugin.authenticate(
            localizedReason: 'reason', authMessages: <AuthMessages>[]);

        final VerificationResult result =
            verify(api.authenticate(captureAny, any));
        final AuthOptions options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, false);
        expect(options.sensitiveTransaction, true);
        expect(options.sticky, false);
        expect(options.useErrorDialgs, true);
      });

      test('passes provided non-default values', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        await plugin.authenticate(
            localizedReason: 'reason',
            authMessages: <AuthMessages>[],
            options: const AuthenticationOptions(
              biometricOnly: true,
              sensitiveTransaction: false,
              stickyAuth: true,
              useErrorDialogs: false,
            ));

        final VerificationResult result =
            verify(api.authenticate(captureAny, any));
        final AuthOptions options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, true);
        expect(options.sensitiveTransaction, false);
        expect(options.sticky, true);
        expect(options.useErrorDialgs, false);
      });
    });

    group('return values', () {
      test('handles success', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.success);

        final bool result = await plugin.authenticate(
            localizedReason: 'reason', authMessages: <AuthMessages>[]);

        expect(result, true);
      });

      test('handles failure', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.failure);

        final bool result = await plugin.authenticate(
            localizedReason: 'reason', authMessages: <AuthMessages>[]);

        expect(result, false);
      });

      test('converts errorAlreadyInProgress to legacy PlatformException',
          () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorAlreadyInProgress);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having(
                    (PlatformException e) => e.code, 'code', 'auth_in_progress')
                .having((PlatformException e) => e.message, 'message',
                    'Authentication in progress')));
      });

      test('converts errorNoActivity to legacy PlatformException', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorNoActivity);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'no_activity')
                .having((PlatformException e) => e.message, 'message',
                    'local_auth plugin requires a foreground activity')));
      });

      test('converts errorNotFragmentActivity to legacy PlatformException',
          () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorNotFragmentActivity);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code',
                    'no_fragment_activity')
                .having((PlatformException e) => e.message, 'message',
                    'local_auth plugin requires activity to be a FragmentActivity.')));
      });

      test('converts errorNotAvailable to legacy PlatformException', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorNotAvailable);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'NotAvailable')
                .having((PlatformException e) => e.message, 'message',
                    'Security credentials not available.')));
      });

      test('converts errorNotEnrolled to legacy PlatformException', () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorNotEnrolled);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'NotEnrolled')
                .having((PlatformException e) => e.message, 'message',
                    'No Biometrics enrolled on this device.')));
      });

      test('converts errorLockedOutTemporarily to legacy PlatformException',
          () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorLockedOutTemporarily);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'LockedOut')
                .having(
                    (PlatformException e) => e.message,
                    'message',
                    'The operation was canceled because the API is locked out '
                        'due to too many attempts. This occurs after 5 failed '
                        'attempts, and lasts for 30 seconds.')));
      });

      test('converts errorLockedOutPermanently to legacy PlatformException',
          () async {
        when(api.authenticate(any, any))
            .thenAnswer((_) async => AuthResult.errorLockedOutPermanently);

        expect(
            () async => plugin.authenticate(
                localizedReason: 'reason', authMessages: <AuthMessages>[]),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code',
                    'PermanentlyLockedOut')
                .having(
                    (PlatformException e) => e.message,
                    'message',
                    'The operation was canceled because ERROR_LOCKOUT occurred '
                        'too many times. Biometric authentication is disabled '
                        'until the user unlocks with strong '
                        'authentication (PIN/Pattern/Password)')));
      });
    });
  });
}

class AnotherPlatformAuthMessages extends AuthMessages {
  @override
  Map<String, String> get args => throw UnimplementedError();
}
