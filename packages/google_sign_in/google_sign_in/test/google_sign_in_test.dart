// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'google_sign_in_test.mocks.dart';

/// Verify that [GoogleSignInAccount] can be mocked even though it's unused
// ignore: avoid_implementing_value_types, must_be_immutable, unreachable_from_main
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

// Add the mixin to make the platform interface accept the mock.
class TestMockGoogleSignInPlatform extends MockGoogleSignInPlatform
    with MockPlatformInterfaceMixin {}

@GenerateMocks(<Type>[GoogleSignInPlatform])
void main() {
  const GoogleSignInUserData defaultUser = GoogleSignInUserData(
    email: 'john.doe@gmail.com',
    id: '8162538176523816253123',
    photoUrl: 'https://lh5.googleusercontent.com/photo.jpg',
    displayName: 'John Doe',
  );

  late MockGoogleSignInPlatform mockPlatform;

  setUp(() {
    mockPlatform = TestMockGoogleSignInPlatform();
    when(mockPlatform.authenticationEvents).thenReturn(null);

    GoogleSignInPlatform.instance = mockPlatform;
  });

  group('initialize', () {
    test('passes nulls by default', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final VerificationResult verification = verify(
        mockPlatform.init(captureAny),
      );
      final InitParameters params = verification.captured[0] as InitParameters;
      expect(params.clientId, null);
      expect(params.serverClientId, null);
      expect(params.nonce, null);
      expect(params.hostedDomain, null);
    });

    test('passes all paramaters', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String clientId = 'clientId';
      const String serverClientId = 'serverClientId';
      const String nonce = 'nonce';
      const String hostedDomain = 'example.com';
      await googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
        nonce: nonce,
        hostedDomain: hostedDomain,
      );

      final VerificationResult verification = verify(
        mockPlatform.init(captureAny),
      );
      final InitParameters params = verification.captured[0] as InitParameters;
      expect(params.clientId, clientId);
      expect(params.serverClientId, serverClientId);
      expect(params.nonce, nonce);
      expect(params.hostedDomain, hostedDomain);
    });
  });

  group('authenticationEvents', () {
    test('reports success from attemptLightweightAuthentication', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String idToken = 'idToken';
      when(mockPlatform.attemptLightweightAuthentication(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: idToken),
        ),
      );

      final Future<GoogleSignInAuthenticationEvent> eventFuture =
          googleSignIn.authenticationEvents.first;
      await googleSignIn.initialize();
      await googleSignIn.attemptLightweightAuthentication();
      final GoogleSignInAuthenticationEvent event = await eventFuture;

      expect(event, isA<GoogleSignInAuthenticationEventSignIn>());
      final GoogleSignInAuthenticationEventSignIn signIn =
          event as GoogleSignInAuthenticationEventSignIn;
      expect(signIn.user.id, defaultUser.id);
      expect(signIn.user.authentication.idToken, idToken);
    });

    test(
      'reports sync exceptions from attemptLightweightAuthentication',
      () async {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        const GoogleSignInException exception = GoogleSignInException(
          code: GoogleSignInExceptionCode.interrupted,
        );
        when(
          mockPlatform.attemptLightweightAuthentication(any),
        ).thenThrow(exception);

        final Completer<Object> errorCompleter = Completer<Object>();
        final StreamSubscription<GoogleSignInAuthenticationEvent> subscription =
            googleSignIn.authenticationEvents
                .handleError((Object e) => errorCompleter.complete(e))
                .listen((_) => fail('The only event should be an error'));
        await googleSignIn.initialize();
        // This doesn't throw, since reportAllExceptions is false.
        await googleSignIn.attemptLightweightAuthentication();

        final Object e = await errorCompleter.future;
        expect(e, exception);
        await subscription.cancel();
      },
    );

    test(
      'reports async exceptions from attemptLightweightAuthentication',
      () async {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        const GoogleSignInException exception = GoogleSignInException(
          code: GoogleSignInExceptionCode.interrupted,
        );
        when(
          mockPlatform.attemptLightweightAuthentication(any),
        ).thenAnswer((_) async => throw exception);

        final Completer<Object> errorCompleter = Completer<Object>();
        final StreamSubscription<GoogleSignInAuthenticationEvent> subscription =
            googleSignIn.authenticationEvents
                .handleError((Object e) => errorCompleter.complete(e))
                .listen((_) => fail('The only event should be an error'));
        await googleSignIn.initialize();
        // This doesn't throw, since reportAllExceptions is false.
        await googleSignIn.attemptLightweightAuthentication();

        final Object e = await errorCompleter.future;
        expect(e, exception);
        await subscription.cancel();
      },
    );

    test('reports success from authenticate', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String idToken = 'idToken';
      when(mockPlatform.authenticate(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: idToken),
        ),
      );

      final Future<GoogleSignInAuthenticationEvent> eventFuture =
          googleSignIn.authenticationEvents.first;
      await googleSignIn.initialize();
      await googleSignIn.authenticate();
      final GoogleSignInAuthenticationEvent event = await eventFuture;

      expect(event, isA<GoogleSignInAuthenticationEventSignIn>());
      final GoogleSignInAuthenticationEventSignIn signIn =
          event as GoogleSignInAuthenticationEventSignIn;
      expect(signIn.user.id, defaultUser.id);
      expect(signIn.user.authentication.idToken, idToken);
    });

    test('reports sync exceptions from authenticate', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const GoogleSignInException exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.interrupted,
      );
      when(mockPlatform.authenticate(any)).thenThrow(exception);

      final Completer<Object> errorCompleter = Completer<Object>();
      final StreamSubscription<GoogleSignInAuthenticationEvent> subscription =
          googleSignIn.authenticationEvents
              .handleError((Object e) => errorCompleter.complete(e))
              .listen((_) => fail('The only event should be an error'));
      await googleSignIn.initialize();
      await expectLater(
        googleSignIn.authenticate(),
        throwsA(isA<GoogleSignInException>()),
      );

      final Object e = await errorCompleter.future;
      expect(e, exception);
      await subscription.cancel();
    });

    test('reports async exceptions from authenticate', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const GoogleSignInException exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.interrupted,
      );
      when(
        mockPlatform.authenticate(any),
      ).thenAnswer((_) async => throw exception);

      final Completer<Object> errorCompleter = Completer<Object>();
      final StreamSubscription<GoogleSignInAuthenticationEvent> subscription =
          googleSignIn.authenticationEvents
              .handleError((Object e) => errorCompleter.complete(e))
              .listen((_) => fail('The only event should be an error'));
      await googleSignIn.initialize();
      await expectLater(
        googleSignIn.authenticate(),
        throwsA(isA<GoogleSignInException>()),
      );

      final Object e = await errorCompleter.future;
      expect(e, exception);
      await subscription.cancel();
    });

    test('reports sign out from signOut', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      final Future<GoogleSignInAuthenticationEvent> eventFuture =
          googleSignIn.authenticationEvents.first;
      await googleSignIn.initialize();
      await googleSignIn.signOut();
      final GoogleSignInAuthenticationEvent event = await eventFuture;

      expect(event, isA<GoogleSignInAuthenticationEventSignOut>());
    });

    test('reports sign out from disconnect', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      final Future<GoogleSignInAuthenticationEvent> eventFuture =
          googleSignIn.authenticationEvents.first;
      await googleSignIn.initialize();
      await googleSignIn.disconnect();
      final GoogleSignInAuthenticationEvent event = await eventFuture;

      expect(event, isA<GoogleSignInAuthenticationEventSignOut>());
    });
  });

  group('supportsAuthenticate', () {
    for (final bool support in <bool>[true, false]) {
      test('reports $support from platform', () async {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        when(mockPlatform.supportsAuthenticate()).thenReturn(support);

        expect(googleSignIn.supportsAuthenticate(), support);
      });
    }
  });

  group('authorizationRequiresUserInteraction', () {
    for (final bool support in <bool>[true, false]) {
      test('reports $support from platform', () async {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        when(
          mockPlatform.authorizationRequiresUserInteraction(),
        ).thenReturn(support);

        expect(googleSignIn.authorizationRequiresUserInteraction(), support);
      });
    }
  });

  group('attemptLightweightAuthentication', () {
    test('returns successful authentication', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String idToken = 'idToken';
      when(mockPlatform.attemptLightweightAuthentication(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: idToken),
        ),
      );

      final Future<GoogleSignInAccount?>? signInFuture =
          googleSignIn.attemptLightweightAuthentication();
      expect(signInFuture, isNotNull);
      final GoogleSignInAccount? signIn = await signInFuture;
      expect(signIn?.displayName, defaultUser.displayName);
      expect(signIn?.email, defaultUser.email);
      expect(signIn?.id, defaultUser.id);
      expect(signIn?.photoUrl, defaultUser.photoUrl);
      expect(signIn?.authentication.idToken, idToken);
    });

    test('reports all exceptions when requested - sync', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const GoogleSignInException exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
      when(
        mockPlatform.attemptLightweightAuthentication(any),
      ).thenThrow(exception);

      await googleSignIn.initialize();
      expect(
        googleSignIn.attemptLightweightAuthentication(
          reportAllExceptions: true,
        ),
        throwsA(
          isA<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.canceled,
          ),
        ),
      );
    });

    test(
      'reports serious exceptions even when all exceptions are not requested - sync',
      () async {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        const GoogleSignInException exception = GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        );
        when(
          mockPlatform.attemptLightweightAuthentication(any),
        ).thenThrow(exception);

        await googleSignIn.initialize();
        expect(
          googleSignIn.attemptLightweightAuthentication(),
          throwsA(
            isA<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.clientConfigurationError,
            ),
          ),
        );
      },
    );

    test('reports all exceptions when requested - async', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const GoogleSignInException exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
      when(
        mockPlatform.attemptLightweightAuthentication(any),
      ).thenAnswer((_) async => throw exception);

      await googleSignIn.initialize();
      expect(
        googleSignIn.attemptLightweightAuthentication(
          reportAllExceptions: true,
        ),
        throwsA(
          isA<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.canceled,
          ),
        ),
      );
    });

    test(
      'reports serious exceptions even when all exceptions are not requested - async',
      () async {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        const GoogleSignInException exception = GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        );
        when(
          mockPlatform.attemptLightweightAuthentication(any),
        ).thenAnswer((_) async => throw exception);

        await googleSignIn.initialize();
        expect(
          googleSignIn.attemptLightweightAuthentication(),
          throwsA(
            isA<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.clientConfigurationError,
            ),
          ),
        );
      },
    );

    test('returns a null future from the platform', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(mockPlatform.attemptLightweightAuthentication(any)).thenReturn(null);

      final Future<GoogleSignInAccount?>? signInFuture =
          googleSignIn.attemptLightweightAuthentication();
      expect(signInFuture, isNull);
    });

    test('returns a future that resolves to null from the platform', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(
        mockPlatform.attemptLightweightAuthentication(any),
      ).thenAnswer((_) async => null);

      final Future<GoogleSignInAccount?>? signInFuture =
          googleSignIn.attemptLightweightAuthentication();
      expect(signInFuture, isNotNull);
      final GoogleSignInAccount? signIn = await signInFuture;
      expect(signIn, isNull);
    });
  });

  group('authenticate', () {
    test('passes expected paramaters', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const List<String> scopes = <String>['scope1', 'scope2'];
      when(mockPlatform.authenticate(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: 'idToken'),
        ),
      );

      await googleSignIn.initialize();
      await googleSignIn.authenticate(scopeHint: scopes);

      final VerificationResult verification = verify(
        mockPlatform.authenticate(captureAny),
      );
      final AuthenticateParameters params =
          verification.captured[0] as AuthenticateParameters;
      expect(params.scopeHint, scopes);
    });

    test('returns successful authentication', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String idToken = 'idToken';
      when(mockPlatform.authenticate(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: idToken),
        ),
      );

      final GoogleSignInAccount signIn = await googleSignIn.authenticate();
      expect(signIn.displayName, defaultUser.displayName);
      expect(signIn.email, defaultUser.email);
      expect(signIn.id, defaultUser.id);
      expect(signIn.photoUrl, defaultUser.photoUrl);
      expect(signIn.authentication.idToken, idToken);
    });

    test('reports exceptions', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const GoogleSignInException exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.interrupted,
      );
      when(mockPlatform.authenticate(any)).thenThrow(exception);

      await googleSignIn.initialize();
      expect(
        googleSignIn.authenticate(),
        throwsA(
          isA<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.interrupted,
          ),
        ),
      );
    });
  });

  group('authorizationForScopes', () {
    test('passes expected paramaters when called for a user', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(mockPlatform.authenticate(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: 'idToken'),
        ),
      );
      when(
        mockPlatform.clientAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      await googleSignIn.initialize();
      final GoogleSignInAccount authentication =
          await googleSignIn.authenticate();
      const List<String> scopes = <String>['scope1', 'scope2'];
      await authentication.authorizationClient.authorizationForScopes(scopes);

      final VerificationResult verification = verify(
        mockPlatform.clientAuthorizationTokensForScopes(captureAny),
      );
      final ClientAuthorizationTokensForScopesParameters params =
          verification.captured[0]
              as ClientAuthorizationTokensForScopesParameters;
      expect(params.request.scopes, scopes);
      expect(params.request.userId, defaultUser.id);
      expect(params.request.email, defaultUser.email);
      expect(params.request.promptIfUnauthorized, false);
    });

    test('passes expected paramaters when called without a user', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(
        mockPlatform.clientAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      const List<String> scopes = <String>['scope1', 'scope2'];
      await googleSignIn.authorizationClient.authorizationForScopes(scopes);

      final VerificationResult verification = verify(
        mockPlatform.clientAuthorizationTokensForScopes(captureAny),
      );
      final ClientAuthorizationTokensForScopesParameters params =
          verification.captured[0]
              as ClientAuthorizationTokensForScopesParameters;
      expect(params.request.scopes, scopes);
      expect(params.request.userId, null);
      expect(params.request.email, null);
      expect(params.request.promptIfUnauthorized, false);
    });

    test('reports tokens', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String accessToken = 'accessToken';
      when(mockPlatform.clientAuthorizationTokensForScopes(any)).thenAnswer(
        (_) async =>
            const ClientAuthorizationTokenData(accessToken: accessToken),
      );

      const List<String> scopes = <String>['scope1', 'scope2'];
      final GoogleSignInClientAuthorization? auth = await googleSignIn
          .authorizationClient
          .authorizationForScopes(scopes);
      expect(auth?.accessToken, accessToken);
    });

    test('reports null', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(
        mockPlatform.clientAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      const List<String> scopes = <String>['scope1', 'scope2'];
      expect(
        await googleSignIn.authorizationClient.authorizationForScopes(scopes),
        null,
      );
    });
  });

  group('authorizeScopes', () {
    test('passes expected paramaters when called for a user', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(mockPlatform.authenticate(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: 'idToken'),
        ),
      );
      when(mockPlatform.clientAuthorizationTokensForScopes(any)).thenAnswer(
        (_) async =>
            const ClientAuthorizationTokenData(accessToken: 'accessToken'),
      );

      await googleSignIn.initialize();
      final GoogleSignInAccount authentication =
          await googleSignIn.authenticate();
      const List<String> scopes = <String>['scope1', 'scope2'];
      await authentication.authorizationClient.authorizeScopes(scopes);

      final VerificationResult verification = verify(
        mockPlatform.clientAuthorizationTokensForScopes(captureAny),
      );
      final ClientAuthorizationTokensForScopesParameters params =
          verification.captured[0]
              as ClientAuthorizationTokensForScopesParameters;
      expect(params.request.scopes, scopes);
      expect(params.request.userId, defaultUser.id);
      expect(params.request.email, defaultUser.email);
      expect(params.request.promptIfUnauthorized, true);
    });

    test('passes expected paramaters when called without a user', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(mockPlatform.clientAuthorizationTokensForScopes(any)).thenAnswer(
        (_) async =>
            const ClientAuthorizationTokenData(accessToken: 'accessToken'),
      );

      const List<String> scopes = <String>['scope1', 'scope2'];
      await googleSignIn.authorizationClient.authorizeScopes(scopes);

      final VerificationResult verification = verify(
        mockPlatform.clientAuthorizationTokensForScopes(captureAny),
      );
      final ClientAuthorizationTokensForScopesParameters params =
          verification.captured[0]
              as ClientAuthorizationTokensForScopesParameters;
      expect(params.request.scopes, scopes);
      expect(params.request.userId, null);
      expect(params.request.email, null);
      expect(params.request.promptIfUnauthorized, true);
    });

    test('reports tokens', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String accessToken = 'accessToken';
      when(mockPlatform.clientAuthorizationTokensForScopes(any)).thenAnswer(
        (_) async =>
            const ClientAuthorizationTokenData(accessToken: accessToken),
      );

      const List<String> scopes = <String>['scope1', 'scope2'];
      final GoogleSignInClientAuthorization auth = await googleSignIn
          .authorizationClient
          .authorizeScopes(scopes);
      expect(auth.accessToken, accessToken);
    });

    test('throws for unexpected null', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(
        mockPlatform.clientAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      const List<String> scopes = <String>['scope1', 'scope2'];
      await expectLater(
        googleSignIn.authorizationClient.authorizeScopes(scopes),
        throwsA(
          isA<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.unknownError,
          ),
        ),
      );
    });
  });

  group('authorizeServer', () {
    test('passes expected paramaters when called for a user', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(mockPlatform.authenticate(any)).thenAnswer(
        (_) async => const AuthenticationResults(
          user: defaultUser,
          authenticationTokens: AuthenticationTokenData(idToken: 'idToken'),
        ),
      );
      when(
        mockPlatform.serverAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      await googleSignIn.initialize();
      final GoogleSignInAccount authentication =
          await googleSignIn.authenticate();
      const List<String> scopes = <String>['scope1', 'scope2'];
      await authentication.authorizationClient.authorizeServer(scopes);

      final VerificationResult verification = verify(
        mockPlatform.serverAuthorizationTokensForScopes(captureAny),
      );
      final ServerAuthorizationTokensForScopesParameters params =
          verification.captured[0]
              as ServerAuthorizationTokensForScopesParameters;
      expect(params.request.scopes, scopes);
      expect(params.request.userId, defaultUser.id);
      expect(params.request.email, defaultUser.email);
      expect(params.request.promptIfUnauthorized, true);
    });

    test('passes expected paramaters when called without a user', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(
        mockPlatform.serverAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      const List<String> scopes = <String>['scope1', 'scope2'];
      await googleSignIn.authorizationClient.authorizeServer(scopes);

      final VerificationResult verification = verify(
        mockPlatform.serverAuthorizationTokensForScopes(captureAny),
      );
      final ServerAuthorizationTokensForScopesParameters params =
          verification.captured[0]
              as ServerAuthorizationTokensForScopesParameters;
      expect(params.request.scopes, scopes);
      expect(params.request.userId, null);
      expect(params.request.email, null);
      expect(params.request.promptIfUnauthorized, true);
    });

    test('reports tokens', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String authCode = 'authCode';
      when(mockPlatform.serverAuthorizationTokensForScopes(any)).thenAnswer(
        (_) async =>
            const ServerAuthorizationTokenData(serverAuthCode: authCode),
      );

      const List<String> scopes = <String>['scope1', 'scope2'];
      final GoogleSignInServerAuthorization? auth = await googleSignIn
          .authorizationClient
          .authorizeServer(scopes);
      expect(auth?.serverAuthCode, authCode);
    });

    test('reports null', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      when(
        mockPlatform.serverAuthorizationTokensForScopes(any),
      ).thenAnswer((_) async => null);

      const List<String> scopes = <String>['scope1', 'scope2'];
      expect(
        await googleSignIn.authorizationClient.authorizeServer(scopes),
        null,
      );
    });
  });

  group('clearAuthorizationToken', () {
    test('passes expected paramaters', () async {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      const String token = 'someAccessToken';
      await googleSignIn.authorizationClient.clearAuthorizationToken(
        accessToken: token,
      );

      final VerificationResult verification = verify(
        mockPlatform.clearAuthorizationToken(captureAny),
      );
      final ClearAuthorizationTokenParams params =
          verification.captured[0] as ClearAuthorizationTokenParams;
      expect(params.accessToken, token);
    });
  });
}
