// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_android/google_sign_in_android.dart';
import 'package:google_sign_in_android/src/messages.g.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_sign_in_android_test.mocks.dart';

const GoogleSignInUserData _testUser = GoogleSignInUserData(
  email: 'john.doe@gmail.com',
  id: '8162538176523816253123',
  photoUrl: 'https://lh5.googleusercontent.com/photo.jpg',
  displayName: 'John Doe',
);
final AuthenticationTokenData _testAuthnToken = AuthenticationTokenData(
  // This is just real enough to test the id-from-idToken extraction logic, with
  // the middle (payload) section having an actual base-64 encoded JSON
  // dictionary with only the "sub":"id" entry needed by the plugin code.
  idToken:
      'header.${base64UrlEncode(JsonUtf8Encoder().convert(<String, Object>{'sub': _testUser.id}))}.signatune',
);

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<GoogleSignInApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleSignInAndroid googleSignIn;
  late MockGoogleSignInApi mockApi;

  setUp(() {
    mockApi = MockGoogleSignInApi();
    googleSignIn = GoogleSignInAndroid(api: mockApi);

    provideDummy<GetCredentialResult>(
      GetCredentialSuccess(
        credential: PlatformGoogleIdTokenCredential(id: '', idToken: ''),
      ),
    );
    provideDummy<AuthorizeResult>(
      PlatformAuthorizationResult(grantedScopes: <String>[]),
    );
  });

  test('registered instance', () {
    GoogleSignInAndroid.registerWith();
    expect(GoogleSignInPlatform.instance, isA<GoogleSignInAndroid>());
  });

  group('support queries', () {
    test('reports support for authenticate', () {
      expect(googleSignIn.supportsAuthenticate(), true);
    });

    test('reports no requirement for user interaction to authorize', () {
      expect(googleSignIn.authorizationRequiresUserInteraction(), false);
    });
  });

  group('attemptLightweightAuthentication', () {
    test('passes explicit server client ID', () async {
      const String serverClientId = 'aServerClient';

      await googleSignIn.init(
        const InitParameters(serverClientId: serverClientId),
      );
      await googleSignIn.attemptLightweightAuthentication(
        const AttemptLightweightAuthenticationParameters(),
      );

      verifyNever(mockApi.getGoogleServicesJsonServerClientId());
      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.serverClientId, serverClientId);
    });

    test('passes JSON server client ID if not overridden', () async {
      const String serverClientId = 'aServerClient';
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => serverClientId);

      // Passing no server client ID should cause it to be queried via
      // getGoogleServicesJsonServerClientId().
      await googleSignIn.init(const InitParameters());
      await googleSignIn.attemptLightweightAuthentication(
        const AttemptLightweightAuthenticationParameters(),
      );

      verify(mockApi.getGoogleServicesJsonServerClientId());
      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.serverClientId, serverClientId);
    });

    test('passes nonce if provided', () async {
      const String nonce = 'nonce';

      await googleSignIn.init(
        const InitParameters(nonce: nonce, serverClientId: 'id'),
      );
      await googleSignIn.attemptLightweightAuthentication(
        const AttemptLightweightAuthenticationParameters(),
      );

      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.nonce, nonce);
    });

    test('passes success data to caller', () async {
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async => GetCredentialSuccess(
          credential: PlatformGoogleIdTokenCredential(
            displayName: _testUser.displayName,
            profilePictureUri: _testUser.photoUrl,
            id: _testUser.email,
            idToken: _testAuthnToken.idToken!,
          ),
        ),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      final AuthenticationResults? result = await googleSignIn
          .attemptLightweightAuthentication(
            const AttemptLightweightAuthenticationParameters(),
          );

      expect(result?.user, _testUser);
      expect(result?.authenticationTokens, _testAuthnToken);
    });

    test('returns null for missing auth', () async {
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.noCredential),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      final AuthenticationResults? result = await googleSignIn
          .attemptLightweightAuthentication(
            const AttemptLightweightAuthenticationParameters(),
          );

      expect(result, null);
    });

    test('calls with and without filterToAuthorized', () async {
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.noCredential),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      await googleSignIn.attemptLightweightAuthentication(
        const AttemptLightweightAuthenticationParameters(),
      );

      final List<VerificationResult> verifications = verifyInOrder(
        <Future<GetCredentialResult>>[
          mockApi.getCredential(captureAny),
          mockApi.getCredential(captureAny),
        ],
      );
      final GetCredentialRequestParams firstParams =
          verifications[0].captured[0] as GetCredentialRequestParams;
      final GetCredentialRequestParams secondParams =
          verifications[1].captured[0] as GetCredentialRequestParams;
      expect(firstParams.useButtonFlow, isFalse);
      expect(firstParams.googleIdOptionParams.filterToAuthorized, isTrue);
      expect(firstParams.googleIdOptionParams.autoSelectEnabled, isTrue);
      expect(secondParams.useButtonFlow, isFalse);
      expect(secondParams.googleIdOptionParams.filterToAuthorized, isFalse);
      expect(secondParams.googleIdOptionParams.autoSelectEnabled, isFalse);
    });

    test(
      'only calls with filterToAuthorized if hosted domain is set',
      () async {
        when(mockApi.getCredential(any)).thenAnswer(
          (_) async =>
              GetCredentialFailure(type: GetCredentialFailureType.noCredential),
        );

        await googleSignIn.init(
          const InitParameters(
            serverClientId: 'id',
            hostedDomain: 'example.com',
          ),
        );
        await googleSignIn.attemptLightweightAuthentication(
          const AttemptLightweightAuthenticationParameters(),
        );

        final VerificationResult verification = verify(
          mockApi.getCredential(captureAny),
        );
        expect(verification.callCount, 1);
        final GetCredentialRequestParams params =
            verification.captured[0] as GetCredentialRequestParams;
        expect(params.useButtonFlow, isFalse);
        expect(params.googleIdOptionParams.filterToAuthorized, isTrue);
        expect(params.googleIdOptionParams.autoSelectEnabled, isTrue);
      },
    );
  });

  group('authenticate', () {
    test('passes explicit server client ID', () async {
      const String serverClientId = 'aServerClient';

      await googleSignIn.init(
        const InitParameters(serverClientId: serverClientId),
      );
      await googleSignIn.authenticate(const AuthenticateParameters());

      verifyNever(mockApi.getGoogleServicesJsonServerClientId());
      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.serverClientId, serverClientId);
    });

    test('passes JSON server client ID if not overridden', () async {
      const String serverClientId = 'aServerClient';
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => serverClientId);

      // Passing no server client ID should cause it to be queried via
      // getGoogleServicesJsonServerClientId().
      await googleSignIn.init(const InitParameters());
      await googleSignIn.authenticate(const AuthenticateParameters());

      verify(mockApi.getGoogleServicesJsonServerClientId());
      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.serverClientId, serverClientId);
    });

    test('passes hosted domain if provided', () async {
      const String hostedDomain = 'example.com';

      await googleSignIn.init(const InitParameters(hostedDomain: hostedDomain));
      await googleSignIn.authenticate(const AuthenticateParameters());

      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.hostedDomain, hostedDomain);
    });

    test('passes nonce if provided', () async {
      const String nonce = 'nonce';

      await googleSignIn.init(const InitParameters(nonce: nonce));
      await googleSignIn.authenticate(const AuthenticateParameters());

      final VerificationResult verification = verify(
        mockApi.getCredential(captureAny),
      );
      final GetCredentialRequestParams hostParams =
          verification.captured[0] as GetCredentialRequestParams;
      expect(hostParams.nonce, nonce);
    });

    test('passes success data to caller', () async {
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async => GetCredentialSuccess(
          credential: PlatformGoogleIdTokenCredential(
            displayName: _testUser.displayName,
            profilePictureUri: _testUser.photoUrl,
            id: _testUser.email,
            idToken: _testAuthnToken.idToken!,
          ),
        ),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      final AuthenticationResults result = await googleSignIn.authenticate(
        const AuthenticateParameters(),
      );

      expect(result.user, _testUser);
      expect(result.authenticationTokens, _testAuthnToken);
    });

    test('throws unknown for missing auth', () async {
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.noCredential),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.authenticate(const AuthenticateParameters()),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.unknownError,
          ),
        ),
      );
    });

    test(
      'throws client configuration error for missing server client ID',
      () async {
        when(
          mockApi.getGoogleServicesJsonServerClientId(),
        ).thenAnswer((_) async => null);
        when(mockApi.getCredential(any)).thenAnswer(
          (_) async => GetCredentialFailure(
            type: GetCredentialFailureType.missingServerClientId,
          ),
        );

        await googleSignIn.init(const InitParameters());
        expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(
            isInstanceOf<GoogleSignInException>()
                .having(
                  (GoogleSignInException e) => e.code,
                  'code',
                  GoogleSignInExceptionCode.clientConfigurationError,
                )
                .having(
                  (GoogleSignInException e) => e.description,
                  'description',
                  contains('serverClientId must be provided'),
                ),
          ),
        );
      },
    );

    test(
      'throws provider configuration error for wrong credential type',
      () async {
        when(
          mockApi.getGoogleServicesJsonServerClientId(),
        ).thenAnswer((_) async => null);
        when(mockApi.getCredential(any)).thenAnswer(
          (_) async => GetCredentialFailure(
            type: GetCredentialFailureType.unexpectedCredentialType,
          ),
        );

        await googleSignIn.init(const InitParameters());
        expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(
            isInstanceOf<GoogleSignInException>()
                .having(
                  (GoogleSignInException e) => e.code,
                  'code',
                  GoogleSignInExceptionCode.providerConfigurationError,
                )
                .having(
                  (GoogleSignInException e) => e.description,
                  'description',
                  contains('Unexpected credential type'),
                ),
          ),
        );
      },
    );

    test('throws provider configuration error if device does not '
        'support Credential Manager', () async {
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => null);
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.unsupported),
      );

      await googleSignIn.init(const InitParameters());
      expect(
        googleSignIn.authenticate(const AuthenticateParameters()),
        throwsA(
          isInstanceOf<GoogleSignInException>()
              .having(
                (GoogleSignInException e) => e.code,
                'code',
                GoogleSignInExceptionCode.providerConfigurationError,
              )
              .having(
                (GoogleSignInException e) => e.description,
                'description',
                contains('Credential Manager not supported'),
              ),
        ),
      );
    });

    test('throws provider configuration error for SDK-reported '
        'provider configuration error', () async {
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => null);
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async => GetCredentialFailure(
          type: GetCredentialFailureType.providerConfigurationIssue,
        ),
      );

      await googleSignIn.init(const InitParameters());
      expect(
        googleSignIn.authenticate(const AuthenticateParameters()),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.providerConfigurationError,
          ),
        ),
      );
    });

    test('throws interrupted from SDK', () async {
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => null);
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.interrupted),
      );

      await googleSignIn.init(const InitParameters());
      expect(
        googleSignIn.authenticate(const AuthenticateParameters()),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.interrupted,
          ),
        ),
      );
    });

    test('throws canceled from SDK', () async {
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => null);
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.canceled),
      );

      await googleSignIn.init(const InitParameters());
      expect(
        googleSignIn.authenticate(const AuthenticateParameters()),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.canceled,
          ),
        ),
      );
    });

    test('throws unknown from SDK', () async {
      when(
        mockApi.getGoogleServicesJsonServerClientId(),
      ).thenAnswer((_) async => null);
      when(mockApi.getCredential(any)).thenAnswer(
        (_) async =>
            GetCredentialFailure(type: GetCredentialFailureType.unknown),
      );

      await googleSignIn.init(const InitParameters());
      expect(
        googleSignIn.authenticate(const AuthenticateParameters()),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.unknownError,
          ),
        ),
      );
    });
  });

  group('clientAuthorizationTokensForScopes', () {
    // Request details used when the details of the request are not relevant to
    // the test.
    const AuthorizationRequestDetails defaultAuthRequest =
        AuthorizationRequestDetails(
          scopes: <String>['a'],
          userId: null,
          email: null,
          promptIfUnauthorized: false,
        );

    test('passes expected values', () async {
      const List<String> scopes = <String>['a', 'b'];
      const String userId = '12345';
      const String userEmail = 'user@example.com';
      const bool promptIfUnauthorized = false;
      const String hostedDomain = 'example.com';

      when(
        mockApi.authorize(any, promptIfUnauthorized: promptIfUnauthorized),
      ).thenAnswer(
        (_) async => PlatformAuthorizationResult(grantedScopes: <String>[]),
      );

      await googleSignIn.init(
        const InitParameters(serverClientId: 'id', hostedDomain: hostedDomain),
      );
      await googleSignIn.clientAuthorizationTokensForScopes(
        const ClientAuthorizationTokensForScopesParameters(
          request: AuthorizationRequestDetails(
            scopes: scopes,
            userId: userId,
            email: userEmail,
            promptIfUnauthorized: promptIfUnauthorized,
          ),
        ),
      );

      final VerificationResult verification = verify(
        mockApi.authorize(
          captureAny,
          promptIfUnauthorized: promptIfUnauthorized,
        ),
      );
      final PlatformAuthorizationRequest hostParams =
          verification.captured[0] as PlatformAuthorizationRequest;
      expect(hostParams.scopes, scopes);
      expect(hostParams.accountEmail, userEmail);
      expect(hostParams.hostedDomain, hostedDomain);
      expect(hostParams.serverClientIdForForcedRefreshToken, null);
    });

    test('passes true promptIfUnauthorized when requested', () async {
      const List<String> scopes = <String>['a', 'b'];
      const bool promptIfUnauthorized = true;

      when(
        mockApi.authorize(any, promptIfUnauthorized: promptIfUnauthorized),
      ).thenAnswer(
        (_) async => PlatformAuthorizationResult(grantedScopes: <String>[]),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      await googleSignIn.clientAuthorizationTokensForScopes(
        const ClientAuthorizationTokensForScopesParameters(
          request: AuthorizationRequestDetails(
            scopes: scopes,
            userId: null,
            email: null,
            promptIfUnauthorized: promptIfUnauthorized,
          ),
        ),
      );

      verify(
        mockApi.authorize(any, promptIfUnauthorized: promptIfUnauthorized),
      );
    });

    test('passes success data to caller', () async {
      const String accessToken = 'token';

      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => PlatformAuthorizationResult(
          grantedScopes: <String>[],
          accessToken: accessToken,
        ),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      final ClientAuthorizationTokenData? result = await googleSignIn
          .clientAuthorizationTokensForScopes(
            const ClientAuthorizationTokensForScopesParameters(
              request: defaultAuthRequest,
            ),
          );

      expect(result?.accessToken, accessToken);
    });

    test('returns null when unauthorized', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => AuthorizeFailure(type: AuthorizeFailureType.unauthorized),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        await googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        null,
      );
    });

    test('thows canceled if pending intent fails', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async =>
            AuthorizeFailure(type: AuthorizeFailureType.pendingIntentException),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.canceled,
          ),
        ),
      );
    });

    test('throws unknown if authorization fails', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async =>
            AuthorizeFailure(type: AuthorizeFailureType.authorizeFailure),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.unknownError,
          ),
        ),
      );
    });

    test('throws unknown for API exception', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => AuthorizeFailure(type: AuthorizeFailureType.apiException),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>()
              .having(
                (GoogleSignInException e) => e.code,
                'code',
                GoogleSignInExceptionCode.unknownError,
              )
              .having(
                (GoogleSignInException e) => e.description,
                'description',
                contains('SDK reported an exception'),
              ),
        ),
      );
    });

    test('throws UI unavailable if there is no activity available', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => AuthorizeFailure(type: AuthorizeFailureType.noActivity),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.uiUnavailable,
          ),
        ),
      );
    });
  });

  group('serverAuthorizationTokensForScopes', () {
    // Request details used when the details of the request are not relevant to
    // the test.
    const AuthorizationRequestDetails defaultAuthRequest =
        AuthorizationRequestDetails(
          scopes: <String>['a'],
          userId: null,
          email: null,
          promptIfUnauthorized: false,
        );

    test('serverAuthorizationTokensForScopes passes expected values', () async {
      const List<String> scopes = <String>['a', 'b'];
      const String userId = '12345';
      const String userEmail = 'user@example.com';
      const bool promptIfUnauthorized = false;
      const String hostedDomain = 'example.com';
      const String serverClientId = 'serverClientId';

      when(
        mockApi.authorize(any, promptIfUnauthorized: promptIfUnauthorized),
      ).thenAnswer(
        (_) async => PlatformAuthorizationResult(grantedScopes: <String>[]),
      );

      await googleSignIn.init(
        const InitParameters(
          serverClientId: serverClientId,
          hostedDomain: hostedDomain,
        ),
      );
      await googleSignIn.serverAuthorizationTokensForScopes(
        const ServerAuthorizationTokensForScopesParameters(
          request: AuthorizationRequestDetails(
            scopes: scopes,
            userId: userId,
            email: userEmail,
            promptIfUnauthorized: promptIfUnauthorized,
          ),
        ),
      );

      final VerificationResult verification = verify(
        mockApi.authorize(
          captureAny,
          promptIfUnauthorized: promptIfUnauthorized,
        ),
      );
      final PlatformAuthorizationRequest hostParams =
          verification.captured[0] as PlatformAuthorizationRequest;
      expect(hostParams.scopes, scopes);
      expect(hostParams.accountEmail, userEmail);
      expect(hostParams.hostedDomain, hostedDomain);
      expect(hostParams.serverClientIdForForcedRefreshToken, serverClientId);
    });

    test(
      'serverAuthorizationTokensForScopes passes true promptIfUnauthorized when requested',
      () async {
        const List<String> scopes = <String>['a', 'b'];
        const bool promptIfUnauthorized = true;

        when(
          mockApi.authorize(any, promptIfUnauthorized: promptIfUnauthorized),
        ).thenAnswer(
          (_) async => PlatformAuthorizationResult(grantedScopes: <String>[]),
        );

        await googleSignIn.init(const InitParameters(serverClientId: 'id'));
        await googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
            request: AuthorizationRequestDetails(
              scopes: scopes,
              userId: null,
              email: null,
              promptIfUnauthorized: promptIfUnauthorized,
            ),
          ),
        );

        verify(
          mockApi.authorize(any, promptIfUnauthorized: promptIfUnauthorized),
        );
      },
    );

    test(
      'serverAuthorizationTokensForScopes passes success data to caller',
      () async {
        const List<String> scopes = <String>['a', 'b'];
        const String authCode = 'code';

        when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
          (_) async => PlatformAuthorizationResult(
            grantedScopes: <String>[],
            accessToken: 'token',
            serverAuthCode: authCode,
          ),
        );

        await googleSignIn.init(const InitParameters(serverClientId: 'id'));
        final ServerAuthorizationTokenData? result = await googleSignIn
            .serverAuthorizationTokensForScopes(
              const ServerAuthorizationTokensForScopesParameters(
                request: AuthorizationRequestDetails(
                  scopes: scopes,
                  userId: null,
                  email: null,
                  promptIfUnauthorized: false,
                ),
              ),
            );

        expect(result?.serverAuthCode, authCode);
      },
    );

    test('returns null when unauthorized', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => AuthorizeFailure(type: AuthorizeFailureType.unauthorized),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        await googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        null,
      );
    });

    test('thows canceled if pending intent fails', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async =>
            AuthorizeFailure(type: AuthorizeFailureType.pendingIntentException),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.canceled,
          ),
        ),
      );
    });

    test('throws unknown if authorization fails', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async =>
            AuthorizeFailure(type: AuthorizeFailureType.authorizeFailure),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.unknownError,
          ),
        ),
      );
    });

    test('throws unknown for API exception', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => AuthorizeFailure(type: AuthorizeFailureType.apiException),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>()
              .having(
                (GoogleSignInException e) => e.code,
                'code',
                GoogleSignInExceptionCode.unknownError,
              )
              .having(
                (GoogleSignInException e) => e.description,
                'description',
                contains('SDK reported an exception'),
              ),
        ),
      );
    });

    test('throws UI unavailable if there is no activity available', () async {
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => AuthorizeFailure(type: AuthorizeFailureType.noActivity),
      );

      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      expect(
        googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
            request: defaultAuthRequest,
          ),
        ),
        throwsA(
          isInstanceOf<GoogleSignInException>().having(
            (GoogleSignInException e) => e.code,
            'code',
            GoogleSignInExceptionCode.uiUnavailable,
          ),
        ),
      );
    });
  });

  test('signOut calls through', () async {
    await googleSignIn.signOut(const SignOutParams());

    verify(mockApi.clearCredentialState());
  });

  group('disconnect', () {
    test('calls through with previously authorized accounts', () async {
      // Populate the cache of users.
      const String userEmail = 'user@example.com';
      const String aScope = 'grantedScope';
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => PlatformAuthorizationResult(
          grantedScopes: <String>[aScope],
          accessToken: 'token',
        ),
      );
      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      await googleSignIn.clientAuthorizationTokensForScopes(
        const ClientAuthorizationTokensForScopesParameters(
          request: AuthorizationRequestDetails(
            scopes: <String>[aScope],
            userId: null,
            email: userEmail,
            promptIfUnauthorized: false,
          ),
        ),
      );

      await googleSignIn.disconnect(const DisconnectParams());

      final VerificationResult verification = verify(
        mockApi.revokeAccess(captureAny),
      );
      final PlatformRevokeAccessRequest hostParams =
          verification.captured[0] as PlatformRevokeAccessRequest;
      expect(hostParams.accountEmail, userEmail);
      expect(hostParams.scopes.first, aScope);
    });

    test(
      'calls through with non-authorized accounts, using "openid"',
      () async {
        // Populate the cache of users.
        when(mockApi.getCredential(any)).thenAnswer(
          (_) async => GetCredentialSuccess(
            credential: PlatformGoogleIdTokenCredential(
              displayName: _testUser.displayName,
              profilePictureUri: _testUser.photoUrl,
              id: _testUser.email,
              idToken: _testAuthnToken.idToken!,
            ),
          ),
        );
        await googleSignIn.init(const InitParameters(serverClientId: 'id'));
        await googleSignIn.authenticate(const AuthenticateParameters());

        await googleSignIn.disconnect(const DisconnectParams());

        final VerificationResult verification = verify(
          mockApi.revokeAccess(captureAny),
        );
        final PlatformRevokeAccessRequest hostParams =
            verification.captured[0] as PlatformRevokeAccessRequest;
        expect(hostParams.accountEmail, _testUser.email);
        expect(hostParams.scopes.first, 'openid');
      },
    );

    test('does not re-revoke for repeated disconnect', () async {
      // Populate the cache of users.
      const String userEmail = 'user@example.com';
      const String aScope = 'grantedScope';
      when(mockApi.authorize(any, promptIfUnauthorized: false)).thenAnswer(
        (_) async => PlatformAuthorizationResult(
          grantedScopes: <String>[aScope],
          accessToken: 'token',
        ),
      );
      await googleSignIn.init(const InitParameters(serverClientId: 'id'));
      await googleSignIn.clientAuthorizationTokensForScopes(
        const ClientAuthorizationTokensForScopesParameters(
          request: AuthorizationRequestDetails(
            scopes: <String>[aScope],
            userId: null,
            email: userEmail,
            promptIfUnauthorized: false,
          ),
        ),
      );

      await googleSignIn.disconnect(const DisconnectParams());

      verify(mockApi.revokeAccess(any));

      reset(mockApi);

      // Since no accounts have authorized since the last disconnect, this
      // should not attempt to revoke anything.
      await googleSignIn.disconnect(const DisconnectParams());

      verifyNever(mockApi.revokeAccess(any));
    });

    test('also signs out', () async {
      await googleSignIn.disconnect(const DisconnectParams());

      verify(mockApi.clearCredentialState());
    });
  });

  // Returning null triggers the app-facing package to create stream events,
  // per GoogleSignInPlatform docs, so it's important that this returns null
  // unless the platform implementation is changed to create all necessary
  // notifications.
  test('authenticationEvents returns null', () async {
    expect(googleSignIn.authenticationEvents, null);
  });
}
