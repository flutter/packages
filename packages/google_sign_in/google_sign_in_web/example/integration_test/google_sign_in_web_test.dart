// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:google_sign_in_web/src/gis_client.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:web/web.dart' as web;

import 'google_sign_in_web_test.mocks.dart';

// Mock GisSdkClient so we can simulate any response from the JS side.
@GenerateMocks(
  <Type>[],
  customMocks: <MockSpec<dynamic>>[
    MockSpec<GisSdkClient>(onMissingStub: OnMissingStub.returnDefault),
  ],
)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Constructor', () {
    const expectedClientId = '3xp3c73d_c113n7_1d';

    testWidgets('Loads clientId when set in a meta', (_) async {
      final plugin = GoogleSignInPlugin(debugOverrideLoader: true);

      expect(plugin.autoDetectedClientId, isNull);

      // Add it to the test page now, and try again
      final meta = web.document.createElement('meta') as web.HTMLMetaElement
        ..name = clientIdMetaName
        ..content = expectedClientId;

      web.document.head!.appendChild(meta);

      final another = GoogleSignInPlugin(debugOverrideLoader: true);

      expect(another.autoDetectedClientId, expectedClientId);

      // cleanup
      meta.remove();
    });
  });

  group('init', () {
    late GoogleSignInPlugin plugin;
    late MockGisSdkClient mockGis;

    setUp(() {
      mockGis = MockGisSdkClient();
      plugin = GoogleSignInPlugin(
        debugOverrideLoader: true,
        debugOverrideGisSdkClient: mockGis,
      );
    });

    testWidgets('initializes if all is OK', (_) async {
      await plugin.init(
        const InitParameters(clientId: 'some-non-null-client-id'),
      );

      expect(plugin.initialized, completes);
    });

    testWidgets('asserts clientId is not null', (_) async {
      expect(() async {
        await plugin.init(const InitParameters());
      }, throwsAssertionError);
    });

    testWidgets('asserts serverClientId must be null', (_) async {
      expect(() async {
        await plugin.init(
          const InitParameters(
            clientId: 'some-non-null-client-id',
            serverClientId: 'unexpected-non-null-client-id',
          ),
        );
      }, throwsAssertionError);
    });

    testWidgets('must be called for most of the API to work', (_) async {
      expect(() async {
        await plugin.attemptLightweightAuthentication(
          const AttemptLightweightAuthenticationParameters(),
        );
      }, throwsStateError);

      expect(() async {
        await plugin.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
            request: AuthorizationRequestDetails(
              scopes: <String>[],
              userId: null,
              email: null,
              promptIfUnauthorized: false,
            ),
          ),
        );
      }, throwsStateError);

      expect(() async {
        await plugin.signOut(const SignOutParams());
      }, throwsStateError);

      expect(() async {
        await plugin.disconnect(const DisconnectParams());
      }, throwsStateError);
    });
  });

  group('support queries', () {
    testWidgets('reports lack of support for authenticate', (_) async {
      final plugin = GoogleSignInPlugin(debugOverrideLoader: true);

      expect(plugin.supportsAuthenticate(), false);
    });

    testWidgets('reports requirement for user interaction to authorize', (
      _,
    ) async {
      final plugin = GoogleSignInPlugin(debugOverrideLoader: true);

      expect(plugin.authorizationRequiresUserInteraction(), true);
    });
  });

  group('(with mocked GIS)', () {
    late GoogleSignInPlugin plugin;
    late MockGisSdkClient mockGis;
    const options = InitParameters(clientId: 'some-non-null-client-id');

    setUp(() {
      mockGis = MockGisSdkClient();
      plugin = GoogleSignInPlugin(
        debugOverrideLoader: true,
        debugOverrideGisSdkClient: mockGis,
      );
    });

    group('attemptLightweightAuthentication', () {
      setUp(() {
        plugin.init(options);
      });

      testWidgets('Calls requestOneTap on GIS client', (_) async {
        mockito
            .when(mockGis.requestOneTap())
            .thenAnswer((_) => Future<void>.value());

        final Future<AuthenticationResults?>? future = plugin
            .attemptLightweightAuthentication(
              const AttemptLightweightAuthenticationParameters(),
            );

        expect(future, null);

        // Since the implementation intentionally doesn't return a future, just
        // given the async call a chance to be made.
        await pumpEventQueue();

        mockito.verify(mockGis.requestOneTap());
      });
    });

    group('clientAuthorizationTokensForScopes', () {
      const someAccessToken = '50m3_4cc35_70k3n';
      const scopes = <String>['scope1', 'scope2'];

      setUp(() {
        plugin.init(options);
      });

      testWidgets('calls requestScopes on GIS client', (_) async {
        mockito
            .when(
              mockGis.requestScopes(
                mockito.any,
                promptIfUnauthorized: mockito.anyNamed('promptIfUnauthorized'),
                userHint: mockito.anyNamed('userHint'),
              ),
            )
            .thenAnswer((_) => Future<String>.value(someAccessToken));

        final ClientAuthorizationTokenData? token = await plugin
            .clientAuthorizationTokensForScopes(
              const ClientAuthorizationTokensForScopesParameters(
                request: AuthorizationRequestDetails(
                  scopes: scopes,
                  userId: null,
                  email: null,
                  promptIfUnauthorized: false,
                ),
              ),
            );

        final List<Object?> arguments = mockito
            .verify(
              mockGis.requestScopes(
                mockito.captureAny,
                promptIfUnauthorized: mockito.captureAnyNamed(
                  'promptIfUnauthorized',
                ),
                userHint: mockito.captureAnyNamed('userHint'),
              ),
            )
            .captured;

        expect(token?.accessToken, someAccessToken);

        expect(arguments.elementAt(0), scopes);
        expect(arguments.elementAt(1), false);
        expect(arguments.elementAt(2), null);
      });

      testWidgets('passes expected values to requestScopes', (_) async {
        const someUserId = 'someUser';
        mockito
            .when(
              mockGis.requestScopes(
                mockito.any,
                promptIfUnauthorized: mockito.anyNamed('promptIfUnauthorized'),
                userHint: mockito.anyNamed('userHint'),
              ),
            )
            .thenAnswer((_) => Future<String>.value(someAccessToken));

        final ClientAuthorizationTokenData? token = await plugin
            .clientAuthorizationTokensForScopes(
              const ClientAuthorizationTokensForScopesParameters(
                request: AuthorizationRequestDetails(
                  scopes: scopes,
                  userId: someUserId,
                  email: 'someone@example.com',
                  promptIfUnauthorized: true,
                ),
              ),
            );

        final List<Object?> arguments = mockito
            .verify(
              mockGis.requestScopes(
                mockito.captureAny,
                promptIfUnauthorized: mockito.captureAnyNamed(
                  'promptIfUnauthorized',
                ),
                userHint: mockito.captureAnyNamed('userHint'),
              ),
            )
            .captured;

        expect(token?.accessToken, someAccessToken);

        expect(arguments.elementAt(0), scopes);
        expect(arguments.elementAt(1), true);
        expect(arguments.elementAt(2), someUserId);
      });

      testWidgets('asserts no scopes have any spaces', (_) async {
        expect(
          plugin.clientAuthorizationTokensForScopes(
            const ClientAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
                scopes: <String>['bad scope', ...scopes],
                userId: 'user',
                email: 'someone@example.com',
                promptIfUnauthorized: true,
              ),
            ),
          ),
          throwsAssertionError,
        );
      });
    });

    group('serverAuthorizationTokensForScopes', () {
      const someAuthCode = 'abc123';
      const scopes = <String>['scope1', 'scope2'];

      setUp(() {
        plugin.init(options);
      });

      testWidgets('calls requestServerAuthCode on GIS client', (_) async {
        mockito
            .when(mockGis.requestServerAuthCode(mockito.any))
            .thenAnswer((_) => Future<String>.value(someAuthCode));

        const request = AuthorizationRequestDetails(
          scopes: scopes,
          userId: null,
          email: null,
          promptIfUnauthorized: true,
        );
        final ServerAuthorizationTokenData? token = await plugin
            .serverAuthorizationTokensForScopes(
              const ServerAuthorizationTokensForScopesParameters(
                request: request,
              ),
            );

        final List<Object?> arguments = mockito
            .verify(mockGis.requestServerAuthCode(mockito.captureAny))
            .captured;

        expect(token?.serverAuthCode, someAuthCode);

        final passedRequest = arguments.first! as AuthorizationRequestDetails;
        expect(passedRequest.scopes, request.scopes);
        expect(passedRequest.userId, request.userId);
        expect(passedRequest.email, request.email);
        expect(
          passedRequest.promptIfUnauthorized,
          request.promptIfUnauthorized,
        );
      });

      testWidgets('asserts no scopes have any spaces', (_) async {
        expect(
          plugin.serverAuthorizationTokensForScopes(
            const ServerAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
                scopes: <String>['bad scope', ...scopes],
                userId: 'user',
                email: 'someone@example.com',
                promptIfUnauthorized: true,
              ),
            ),
          ),
          throwsAssertionError,
        );
      });
    });

    group('clearAuthorizationToken', () {
      setUp(() {
        plugin.init(options);
      });

      testWidgets('calls clearAuthorizationToken on GIS client', (_) async {
        const someToken = 'someToken';
        await plugin.clearAuthorizationToken(
          const ClearAuthorizationTokenParams(accessToken: someToken),
        );

        final List<Object?> arguments = mockito
            .verify(mockGis.clearAuthorizationToken(mockito.captureAny))
            .captured;

        expect(arguments.first, someToken);
      });
    });
  });

  group('userDataEvents', () {
    final controller = StreamController<AuthenticationEvent>.broadcast();
    late GoogleSignInPlugin plugin;

    setUp(() {
      plugin = GoogleSignInPlugin(
        debugOverrideLoader: true,
        debugAuthenticationController: controller,
      );
    });

    testWidgets('accepts async user data events from GIS.', (_) async {
      final Future<AuthenticationEvent> event =
          plugin.authenticationEvents.first;

      const AuthenticationEvent expected = AuthenticationEventSignIn(
        user: GoogleSignInUserData(email: 'someone@example.com', id: 'user_id'),
        authenticationTokens: AuthenticationTokenData(idToken: 'someToken'),
      );
      controller.add(expected);

      expect(
        await event,
        expected,
        reason: 'Sign-in events should be propagated',
      );

      final Future<AuthenticationEvent?> nextEvent =
          plugin.authenticationEvents.first;
      controller.add(AuthenticationEventSignOut());

      expect(
        await nextEvent,
        isA<AuthenticationEventSignOut>(),
        reason: 'Sign-out events can also be propagated',
      );
    });
  });
}
