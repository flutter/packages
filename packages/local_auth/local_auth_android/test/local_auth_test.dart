// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
      when(api.getEnrolledBiometrics()).thenAnswer(
        (_) async => <AuthClassification>[
          AuthClassification.weak,
          AuthClassification.strong,
        ],
      );

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[BiometricType.weak, BiometricType.strong]);
    });

    test('handles empty', () async {
      when(
        api.getEnrolledBiometrics(),
      ).thenAnswer((_) async => <AuthClassification>[]);

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[]);
    });

    test('throws no UI for null', () async {
      when(api.getEnrolledBiometrics()).thenAnswer((_) async => null);

      expect(
        () async => plugin.getEnrolledBiometrics(),
        throwsA(
          isA<LocalAuthException>().having(
            (LocalAuthException e) => e.code,
            'code',
            LocalAuthExceptionCode.uiUnavailable,
          ),
        ),
      );
    });
  });

  group('authenticate', () {
    group('strings', () {
      test('passes default values when nothing is provided', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

        const reason = 'test reason';
        await plugin.authenticate(
          localizedReason: reason,
          authMessages: <AuthMessages>[],
        );

        final VerificationResult result = verify(
          api.authenticate(any, captureAny),
        );
        final strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the default values from
        // auth_messages_android.dart
        expect(strings.signInHint, androidSignInHint);
        expect(strings.cancelButton, androidCancelButton);
        expect(strings.signInTitle, androidSignInTitle);
      });

      test(
        'passes default values when only other platform values are provided',
        () async {
          when(
            api.authenticate(any, any),
          ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

          const reason = 'test reason';
          await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[AnotherPlatformAuthMessages()],
          );

          final VerificationResult result = verify(
            api.authenticate(any, captureAny),
          );
          final strings = result.captured[0] as AuthStrings;
          expect(strings.reason, reason);
          // These should all be the default values from
          // auth_messages_android.dart
          expect(strings.signInHint, androidSignInHint);
          expect(strings.cancelButton, androidCancelButton);
          expect(strings.signInTitle, androidSignInTitle);
        },
      );

      test('passes all non-default values correctly', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const reason = 'A';
        const hint = 'B';
        const cancel = 'C';
        const signInTitle = 'D';
        await plugin.authenticate(
          localizedReason: reason,
          authMessages: <AuthMessages>[
            const AndroidAuthMessages(
              signInHint: hint,
              cancelButton: cancel,
              signInTitle: signInTitle,
            ),
            AnotherPlatformAuthMessages(),
          ],
        );

        final VerificationResult result = verify(
          api.authenticate(any, captureAny),
        );
        final strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        expect(strings.signInHint, hint);
        expect(strings.cancelButton, cancel);
        expect(strings.signInTitle, signInTitle);
      });

      test('passes provided messages with default fallbacks', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const reason = 'A';
        const hint = 'B';
        const cancel = 'C';
        await plugin.authenticate(
          localizedReason: reason,
          authMessages: <AuthMessages>[
            const AndroidAuthMessages(signInHint: hint, cancelButton: cancel),
          ],
        );

        final VerificationResult result = verify(
          api.authenticate(any, captureAny),
        );
        final strings = result.captured[0] as AuthStrings;
        expect(strings.reason, reason);
        // These should all be the provided values.
        expect(strings.signInHint, hint);
        expect(strings.cancelButton, cancel);
        // These were non set, so should all be the default values from
        // auth_messages_android.dart
        expect(strings.signInTitle, androidSignInTitle);
      });
    });

    group('options', () {
      test('passes default values', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

        await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
        );

        final VerificationResult result = verify(
          api.authenticate(captureAny, any),
        );
        final options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, false);
        expect(options.sensitiveTransaction, true);
        expect(options.sticky, false);
      });

      test('passes provided non-default values', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

        await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
          options: const AuthenticationOptions(
            biometricOnly: true,
            sensitiveTransaction: false,
            stickyAuth: true,
          ),
        );

        final VerificationResult result = verify(
          api.authenticate(captureAny, any),
        );
        final options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, true);
        expect(options.sensitiveTransaction, false);
        expect(options.sticky, true);
      });
    });

    group('return values', () {
      test('handles success', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.success));

        final bool result = await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
        );

        expect(result, true);
      });

      test(
        'converts negativeButton to userCanceled LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.negativeButton),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.userCanceled,
              ),
            ),
          );
        },
      );

      test(
        'converts userCanceled to userCanceled LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.userCanceled),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.userCanceled,
              ),
            ),
          );
        },
      );

      test(
        'converts systemCanceled to systemCanceled LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.systemCanceled),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.systemCanceled,
              ),
            ),
          );
        },
      );

      test('converts timeout to timeout LocalAuthException', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.timeout));

        expect(
          () async => plugin.authenticate(
            localizedReason: 'reason',
            authMessages: <AuthMessages>[],
          ),
          throwsA(
            isA<LocalAuthException>().having(
              (LocalAuthException e) => e.code,
              'code',
              LocalAuthExceptionCode.timeout,
            ),
          ),
        );
      });

      test(
        'converts alreadyInProgress to authInProgress LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.alreadyInProgress),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.authInProgress,
              ),
            ),
          );
        },
      );

      test('converts noActivity to uiUnavailable LocalAuthException', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.noActivity));

        expect(
          () async => plugin.authenticate(
            localizedReason: 'reason',
            authMessages: <AuthMessages>[],
          ),
          throwsA(
            isA<LocalAuthException>().having(
              (LocalAuthException e) => e.code,
              'code',
              LocalAuthExceptionCode.uiUnavailable,
            ),
          ),
        );
      });

      test(
        'converts notFragmentActivity to uiUnavailable LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.notFragmentActivity),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.uiUnavailable,
              ),
            ),
          );
        },
      );

      test(
        'converts noCredentials to noCredentialsSet LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.noCredentials),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.noCredentialsSet,
              ),
            ),
          );
        },
      );

      test(
        'converts noHardware to noBiometricHardware LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.noHardware),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.noBiometricHardware,
              ),
            ),
          );
        },
      );

      test(
        'converts hardwareUnavailable to biometricHardwareTemporarilyUnavailable LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.hardwareUnavailable),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable,
              ),
            ),
          );
        },
      );

      test(
        'converts notEnrolled to noBiometricsEnrolled LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.notEnrolled),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.noBiometricsEnrolled,
              ),
            ),
          );
        },
      );

      test(
        'converts lockedOutTemporarily to temporaryLockout LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.lockedOutTemporarily),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.temporaryLockout,
              ),
            ),
          );
        },
      );

      test(
        'converts lockedOutPermanently to biometricLockout LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(code: AuthResultCode.lockedOutPermanently),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>().having(
                (LocalAuthException e) => e.code,
                'code',
                LocalAuthExceptionCode.biometricLockout,
              ),
            ),
          );
        },
      );

      test('converts noSpace to deviceError LocalAuthException', () async {
        when(
          api.authenticate(any, any),
        ).thenAnswer((_) async => AuthResult(code: AuthResultCode.noSpace));

        expect(
          () async => plugin.authenticate(
            localizedReason: 'reason',
            authMessages: <AuthMessages>[],
          ),
          throwsA(
            isA<LocalAuthException>()
                .having(
                  (LocalAuthException e) => e.code,
                  'code',
                  LocalAuthExceptionCode.deviceError,
                )
                .having(
                  (LocalAuthException e) => e.description,
                  'description',
                  startsWith('Not enough space available:'),
                ),
          ),
        );
      });

      test(
        'converts securityUpdateRequired to deviceError LocalAuthException',
        () async {
          when(api.authenticate(any, any)).thenAnswer(
            (_) async =>
                AuthResult(code: AuthResultCode.securityUpdateRequired),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>()
                  .having(
                    (LocalAuthException e) => e.code,
                    'code',
                    LocalAuthExceptionCode.deviceError,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    startsWith('Security update required:'),
                  ),
            ),
          );
        },
      );

      test(
        'converts unknownError to unknownError LocalAuthException, passing error message',
        () async {
          const errorMessage = 'Some error message';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResult(
              code: AuthResultCode.unknownError,
              errorMessage: errorMessage,
            ),
          );

          expect(
            () async => plugin.authenticate(
              localizedReason: 'reason',
              authMessages: <AuthMessages>[],
            ),
            throwsA(
              isA<LocalAuthException>()
                  .having(
                    (LocalAuthException e) => e.code,
                    'code',
                    LocalAuthExceptionCode.unknownError,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  ),
            ),
          );
        },
      );
    });
  });
}

class AnotherPlatformAuthMessages extends AuthMessages {
  @override
  Map<String, String> get args => throw UnimplementedError();
}
