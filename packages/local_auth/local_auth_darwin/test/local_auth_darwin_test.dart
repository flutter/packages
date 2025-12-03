// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
      when(api.getEnrolledBiometrics()).thenAnswer(
        (_) async => <AuthBiometric>[
          AuthBiometric.face,
          AuthBiometric.fingerprint,
        ],
      );

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[
        BiometricType.face,
        BiometricType.fingerprint,
      ]);
    });

    test('handles empty', () async {
      when(
        api.getEnrolledBiometrics(),
      ).thenAnswer((_) async => <AuthBiometric>[]);

      final List<BiometricType> result = await plugin.getEnrolledBiometrics();

      expect(result, <BiometricType>[]);
    });
  });

  group('authenticate', () {
    group('strings', () {
      test('passes default values when nothing is provided', () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
          (_) async => AuthResultDetails(result: AuthResult.success),
        );

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
        // auth_messages_ios.dart
        expect(strings.cancelButton, iOSCancelButton);
        expect(strings.localizedFallbackTitle, null);
      });

      test(
        'passes default values when only other platform values are provided',
        () async {
          plugin = LocalAuthDarwin(
            api: api,
            overrideUseMacOSAuthMessages: false,
          );

          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success),
          );

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
          // auth_messages_ios.dart
          expect(strings.cancelButton, iOSCancelButton);
          expect(strings.localizedFallbackTitle, null);
        },
      );

      test(
        'passes default values when only MacOSAuthMessages platform values are provided',
        () async {
          plugin = LocalAuthDarwin(
            api: api,
            overrideUseMacOSAuthMessages: true,
          );

          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success),
          );

          const reason = 'test reason';
          await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[const MacOSAuthMessages()],
          );

          final VerificationResult result = verify(
            api.authenticate(any, captureAny),
          );
          final strings = result.captured[0] as AuthStrings;
          expect(strings.reason, reason);
          // These should all be the default values from
          // auth_messages_ios.dart
          expect(strings.cancelButton, macOSCancelButton);
          expect(strings.localizedFallbackTitle, null);
        },
      );

      test(
        'passes all non-default values correctly with IOSAuthMessages',
        () async {
          plugin = LocalAuthDarwin(
            api: api,
            overrideUseMacOSAuthMessages: false,
          );

          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success),
          );

          // These are arbitrary values; all that matters is that:
          // - they are different from the defaults, and
          // - they are different from each other.
          const reason = 'A';
          const cancel = 'B';
          const localizedFallbackTitle = 'C';

          await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[
              const IOSAuthMessages(
                cancelButton: cancel,
                localizedFallbackTitle: localizedFallbackTitle,
              ),
              AnotherPlatformAuthMessages(),
            ],
          );

          final VerificationResult result = verify(
            api.authenticate(any, captureAny),
          );
          final strings = result.captured[0] as AuthStrings;
          expect(strings.reason, reason);
          expect(strings.cancelButton, cancel);
          expect(strings.localizedFallbackTitle, localizedFallbackTitle);
        },
      );

      test(
        'passes all non-default values correctly with MacOSAuthMessages',
        () async {
          plugin = LocalAuthDarwin(
            api: api,
            overrideUseMacOSAuthMessages: true,
          );
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(result: AuthResult.success),
          );

          // These are arbitrary values; all that matters is that:
          // - they are different from the defaults, and
          // - they are different from each other.
          const reason = 'A';
          const cancel = 'B';
          const localizedFallbackTitle = 'C';
          await plugin.authenticate(
            localizedReason: reason,
            authMessages: <AuthMessages>[
              const MacOSAuthMessages(
                cancelButton: cancel,
                localizedFallbackTitle: localizedFallbackTitle,
              ),
              AnotherPlatformAuthMessages(),
            ],
          );

          final VerificationResult result = verify(
            api.authenticate(any, captureAny),
          );
          final strings = result.captured[0] as AuthStrings;
          expect(strings.reason, reason);
          expect(strings.cancelButton, cancel);
          expect(strings.localizedFallbackTitle, localizedFallbackTitle);
        },
      );

      test('passes provided messages with default fallbacks', () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
          (_) async => AuthResultDetails(result: AuthResult.success),
        );

        // These are arbitrary values; all that matters is that:
        // - they are different from the defaults, and
        // - they are different from each other.
        const reason = 'A';
        const localizedFallbackTitle = 'B';
        await plugin.authenticate(
          localizedReason: reason,
          authMessages: <AuthMessages>[
            const IOSAuthMessages(
              localizedFallbackTitle: localizedFallbackTitle,
            ),
          ],
        );

        final VerificationResult result = verify(
          api.authenticate(any, captureAny),
        );
        final strings = result.captured[0] as AuthStrings;
        // These should all be the provided values.
        expect(strings.reason, reason);
        expect(strings.localizedFallbackTitle, localizedFallbackTitle);
        // These were not set, so should all be the default values from
        // auth_messages_ios.dart
        expect(strings.cancelButton, iOSCancelButton);
      });
    });

    group('options', () {
      test('passes default values', () async {
        plugin = LocalAuthDarwin(api: api, overrideUseMacOSAuthMessages: false);

        when(api.authenticate(any, any)).thenAnswer(
          (_) async => AuthResultDetails(result: AuthResult.success),
        );

        await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
        );

        final VerificationResult result = verify(
          api.authenticate(captureAny, any),
        );
        final options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, false);
        expect(options.sticky, false);
      });

      test('passes provided non-default values', () async {
        when(api.authenticate(any, any)).thenAnswer(
          (_) async => AuthResultDetails(result: AuthResult.success),
        );

        await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        final VerificationResult result = verify(
          api.authenticate(captureAny, any),
        );
        final options = result.captured[0] as AuthOptions;
        expect(options.biometricOnly, true);
        expect(options.sticky, true);
      });
    });

    group('return values', () {
      test('handles success', () async {
        when(api.authenticate(any, any)).thenAnswer(
          (_) async => AuthResultDetails(result: AuthResult.success),
        );

        final bool result = await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
        );

        expect(result, true);
      });

      test('handles failure', () async {
        when(api.authenticate(any, any)).thenAnswer(
          (_) async =>
              AuthResultDetails(result: AuthResult.authenticationFailed),
        );

        final bool result = await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
        );

        expect(result, false);
      });

      test('handles appCancel as failure', () async {
        when(api.authenticate(any, any)).thenAnswer(
          (_) async => AuthResultDetails(result: AuthResult.appCancel),
        );

        final bool result = await plugin.authenticate(
          localizedReason: 'reason',
          authMessages: <AuthMessages>[],
        );

        expect(result, false);
      });

      test(
        'converts uiUnavailable to LocalAuthExceptionCode.uiUnavailable',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.uiUnavailable,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.uiUnavailable,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts systemCancel to LocalAuthExceptionCode.systemCanceled',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.systemCancel,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.systemCanceled,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts userCancel to LocalAuthExceptionCode.userCanceled',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.userCancel,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.userCanceled,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts biometryDisconnected to LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.biometryDisconnected,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode
                        .biometricHardwareTemporarilyUnavailable,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts biometryLockout to LocalAuthExceptionCode.biometricLockout',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.biometryLockout,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.biometricLockout,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts biometryNotAvailable to LocalAuthExceptionCode.noBiometricHardware',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.biometryNotAvailable,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.noBiometricHardware,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts biometryNotPaired to LocalAuthExceptionCode.noBiometricHardware',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.biometryNotPaired,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.noBiometricHardware,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts biometryNotEnrolled to LocalAuthExceptionCode.noBiometricsEnrolled',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.biometryNotEnrolled,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.noBiometricsEnrolled,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts invalidContext to LocalAuthExceptionCode.uiUnavailable',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.invalidContext,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.uiUnavailable,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts invalidDimensions to LocalAuthExceptionCode.uiUnavailable',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.invalidDimensions,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.uiUnavailable,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts notInteractive to LocalAuthExceptionCode.uiUnavailable',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.notInteractive,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.uiUnavailable,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts passcodeNotSet to LocalAuthExceptionCode.noCredentialsSet',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.passcodeNotSet,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.noCredentialsSet,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts userFallback to LocalAuthExceptionCode.userRequestedFallback',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.userFallback,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                    LocalAuthExceptionCode.userRequestedFallback,
                  )
                  .having(
                    (LocalAuthException e) => e.description,
                    'description',
                    errorMessage,
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
                  ),
            ),
          );
        },
      );

      test(
        'converts unknownError to LocalAuthExceptionCode.unknownError',
        () async {
          const errorMessage = 'a message';
          const errorDetails = 'some details';
          when(api.authenticate(any, any)).thenAnswer(
            (_) async => AuthResultDetails(
              result: AuthResult.unknownError,
              errorMessage: errorMessage,
              errorDetails: errorDetails,
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
                  )
                  .having(
                    (LocalAuthException e) => e.details,
                    'details',
                    errorDetails,
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
