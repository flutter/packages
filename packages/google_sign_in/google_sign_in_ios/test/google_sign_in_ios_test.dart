// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_ios/google_sign_in_ios.dart';
import 'package:google_sign_in_ios/src/messages.g.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_sign_in_ios_test.mocks.dart';

const GoogleSignInUserData _testUser = GoogleSignInUserData(
  email: 'john.doe@gmail.com',
  id: '8162538176523816253123',
  photoUrl: 'https://lh5.googleusercontent.com/photo.jpg',
  displayName: 'John Doe',
);

@GenerateMocks(<Type>[GoogleSignInApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleSignInIOS googleSignIn;
  late MockGoogleSignInApi mockApi;

  setUp(() {
    mockApi = MockGoogleSignInApi();
    googleSignIn = GoogleSignInIOS(api: mockApi);
  });

  test('registered instance', () {
    GoogleSignInIOS.registerWith();
    expect(GoogleSignInPlatform.instance, isA<GoogleSignInIOS>());
  });

  group('support queries', () {
    test('reports support for authenticate', () {
      expect(googleSignIn.supportsAuthenticate(), true);
    });

    test('reports no requirement for user interaction to authorize', () {
      expect(googleSignIn.authorizationRequiresUserInteraction(), false);
    });
  });

  group('init', () {
    test('passes expected values', () async {
      const String clientId = 'aClient';
      const String serverClientId = 'aServerClient';
      const String hostedDomain = 'example.com';

      await googleSignIn.init(const InitParameters(
        clientId: clientId,
        serverClientId: serverClientId,
        hostedDomain: hostedDomain,
      ));

      final VerificationResult verification =
          verify(mockApi.configure(captureAny));
      final PlatformConfigurationParams hostParams =
          verification.captured[0] as PlatformConfigurationParams;
      expect(hostParams.clientId, clientId);
      expect(hostParams.serverClientId, serverClientId);
      expect(hostParams.hostedDomain, hostedDomain);
    });
  });

  group('attemptLightweightAuthentication', () {
    test('passes success data to caller', () async {
      const String idToken = 'idToken';
      when(mockApi.restorePreviousSignIn())
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: idToken,
                ),
                accessToken: '',
                grantedScopes: <String>[],
              )));

      final AuthenticationResults? result =
          await googleSignIn.attemptLightweightAuthentication(
              const AttemptLightweightAuthenticationParameters());

      expect(result?.user, _testUser);
      expect(result?.authenticationTokens.idToken, idToken);
    });

    test('returns null for missing auth', () async {
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));

      final AuthenticationResults? result =
          await googleSignIn.attemptLightweightAuthentication(
              const AttemptLightweightAuthenticationParameters());

      expect(result, null);
    });

    test('throws for other errors', () async {
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error: SignInFailure(type: GoogleSignInErrorCode.keychainError)));

      expect(
          googleSignIn.attemptLightweightAuthentication(
              const AttemptLightweightAuthenticationParameters()),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.providerConfigurationError)));
    });
  });

  group('authenticate', () {
    test('passes nonce if provided', () async {
      const String nonce = 'nonce';
      when(mockApi.signIn(any, nonce)).thenAnswer((_) async => SignInResult(
              success: SignInSuccess(
            user: UserData(
              displayName: _testUser.displayName,
              email: _testUser.email,
              userId: _testUser.id,
              photoUrl: _testUser.photoUrl,
              idToken: '',
            ),
            accessToken: '',
            grantedScopes: <String>[],
          )));

      await googleSignIn.init(const InitParameters(nonce: nonce));
      await googleSignIn.authenticate(const AuthenticateParameters());

      verify(mockApi.signIn(any, nonce));
    });

    test('passes success data to caller', () async {
      const String idToken = 'idToken';
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
              success: SignInSuccess(
            user: UserData(
              displayName: _testUser.displayName,
              email: _testUser.email,
              userId: _testUser.id,
              photoUrl: _testUser.photoUrl,
              idToken: idToken,
            ),
            accessToken: '',
            grantedScopes: <String>[],
          )));

      final AuthenticationResults result =
          await googleSignIn.authenticate(const AuthenticateParameters());

      expect(result.user, _testUser);
      expect(result.authenticationTokens.idToken, idToken);
    });

    test('throws unknown for missing auth', () async {
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));

      expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(isInstanceOf<GoogleSignInException>()
              .having((GoogleSignInException e) => e.code, 'code',
                  GoogleSignInExceptionCode.unknownError)
              .having((GoogleSignInException e) => e.description, 'description',
                  contains('No auth reported'))));
    });

    test('throws provider configuration error for keychain error', () async {
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.keychainError)));

      expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.providerConfigurationError)));
    });

    test('throws provider configuration error for EEM error', () async {
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.eemError)));

      expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.providerConfigurationError)));
    });

    test('throws canceled from SDK', () async {
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.canceled)));

      expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.canceled)));
    });

    test('throws user mismatch from SDK', () async {
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.userMismatch)));

      expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.userMismatch)));
    });

    test('throws unknown from SDK', () async {
      when(mockApi.signIn(any, null)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.unknown)));

      expect(
          googleSignIn.authenticate(const AuthenticateParameters()),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.unknownError)));
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

    test('passes expected values to addScopes if interaction is allowed',
        () async {
      const List<String> scopes = <String>['a', 'b'];
      when(mockApi.addScopes(any, _testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: '',
                ),
                accessToken: '',
                grantedScopes: scopes,
              )));

      await googleSignIn.clientAuthorizationTokensForScopes(
          ClientAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      final VerificationResult verification =
          verify(mockApi.addScopes(captureAny, _testUser.id));
      final List<String> passedScopes =
          verification.captured[0] as List<String>;
      expect(passedScopes, scopes);
    });

    test(
        'passes expected values to getRefreshedAuthorizationTokens if '
        'interaction is not allowed', () async {
      const List<String> scopes = <String>['a', 'b'];
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: '',
                ),
                accessToken: '',
                grantedScopes: scopes,
              )));

      await googleSignIn.clientAuthorizationTokensForScopes(
          ClientAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: false,
      )));

      verify(mockApi.getRefreshedAuthorizationTokens(_testUser.id));
    });

    test('attempts to restore previous sign in if no user is provided',
        () async {
      const List<String> scopes = <String>['a', 'b'];
      final SignInResult signInResult = SignInResult(
          success: SignInSuccess(
        user: UserData(
          displayName: _testUser.displayName,
          email: _testUser.email,
          userId: _testUser.id,
          photoUrl: _testUser.photoUrl,
          idToken: '',
        ),
        accessToken: '',
        grantedScopes: <String>[],
      ));
      when(mockApi.restorePreviousSignIn())
          .thenAnswer((_) async => signInResult);
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => signInResult);

      await googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: null,
        email: null,
        promptIfUnauthorized: false,
      )));

      // With no user ID provided to clientAuthorizationTokensForScopes, the
      // implementation should attempt to restore an existing sign-in, and then
      // when that succeeds, get the authorization tokens for that user.
      verify(mockApi.restorePreviousSignIn());
      verify(mockApi.getRefreshedAuthorizationTokens(_testUser.id));
    });

    test('returns null if unauthenticated and interaction is not allowed',
        () async {
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));

      final ClientAuthorizationTokenData? result =
          await googleSignIn.clientAuthorizationTokensForScopes(
              const ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: <String>['a', 'b'],
        userId: null,
        email: null,
        promptIfUnauthorized: false,
      )));

      // With no user ID provided to clientAuthorizationTokensForScopes, the
      // implementation should attempt to restore an existing sign-in, and then
      // when that fails, return null since without prompting, there is no way
      // to authenticate.
      verify(mockApi.restorePreviousSignIn());
      expect(result, null);
    });

    test(
        'attempts to authenticate if no user is provided or already signed in '
        'and interaction is allowed', () async {
      const List<String> scopes = <String>['a', 'b'];
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));
      when(mockApi.signIn(scopes, null)).thenAnswer((_) async => SignInResult(
              success: SignInSuccess(
            user: UserData(
              displayName: _testUser.displayName,
              email: _testUser.email,
              userId: _testUser.id,
              photoUrl: _testUser.photoUrl,
              idToken: '',
            ),
            accessToken: '',
            grantedScopes: <String>[],
          )));

      await googleSignIn.clientAuthorizationTokensForScopes(
          const ClientAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: null,
        email: null,
        promptIfUnauthorized: true,
      )));

      // With no user ID provided to clientAuthorizationTokensForScopes, the
      // implementation should attempt to restore an existing sign-in, and when
      // that fails, prompt for a combined authn+authz.
      verify(mockApi.restorePreviousSignIn());
      verify(mockApi.signIn(scopes, null));
    });

    test('passes success data to caller when refreshing existing auth',
        () async {
      const List<String> scopes = <String>['a', 'b'];
      const String accessToken = 'token';
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: accessToken,
                grantedScopes: scopes,
              )));

      final ClientAuthorizationTokenData? result =
          await googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: false,
      )));

      expect(result?.accessToken, accessToken);
    });

    test('passes success data to caller when calling addScopes', () async {
      const List<String> scopes = <String>['a', 'b'];
      const String accessToken = 'token';
      when(mockApi.addScopes(scopes, _testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: accessToken,
                grantedScopes: scopes,
              )));

      final ClientAuthorizationTokenData? result =
          await googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      expect(result?.accessToken, accessToken);
    });

    test(
        'successfully returns refreshed tokens if addScopes indicates the '
        'requested scopes are already granted', () async {
      const List<String> scopes = <String>['a', 'b'];
      const String accessToken = 'token';
      when(mockApi.addScopes(scopes, _testUser.id)).thenAnswer((_) async =>
          SignInResult(
              error: SignInFailure(
                  type: GoogleSignInErrorCode.scopesAlreadyGranted)));
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: accessToken,
                grantedScopes: scopes,
              )));

      final ClientAuthorizationTokenData? result =
          await googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      verify(mockApi.addScopes(scopes, _testUser.id));
      verify(mockApi.getRefreshedAuthorizationTokens(_testUser.id));

      expect(result?.accessToken, accessToken);
    });

    test('returns null if re-using existing auth and scopes are missing',
        () async {
      const List<String> requestedScopes = <String>['a', 'b'];
      const List<String> grantedScopes = <String>['a'];
      const String accessToken = 'token';
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: accessToken,
                grantedScopes: grantedScopes,
              )));

      final ClientAuthorizationTokenData? result =
          await googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: requestedScopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: false,
      )));

      expect(result, null);
    });

    test('returns null when unauthorized', () async {
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));

      expect(
          await googleSignIn.clientAuthorizationTokensForScopes(
              const ClientAuthorizationTokensForScopesParameters(
                  request: defaultAuthRequest)),
          null);
    });

    test('thows canceled from SDK', () async {
      when(mockApi.addScopes(any, any)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.canceled)));

      expect(
          googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
            scopes: const <String>['a'],
            userId: _testUser.id,
            email: _testUser.email,
            promptIfUnauthorized: true,
          ))),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.canceled)));
    });

    test('throws unknown from SDK', () async {
      when(mockApi.addScopes(any, any)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.unknown)));

      expect(
          googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
            scopes: const <String>['a'],
            userId: _testUser.id,
            email: _testUser.email,
            promptIfUnauthorized: true,
          ))),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.unknownError)));
    });

    test('throws user mismatch from SDK', () async {
      when(mockApi.addScopes(any, any)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.userMismatch)));

      expect(
          googleSignIn.clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
            scopes: const <String>['a'],
            userId: _testUser.id,
            email: _testUser.email,
            promptIfUnauthorized: true,
          ))),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.userMismatch)));
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

    test('passes expected values to addScopes if interaction is allowed',
        () async {
      const List<String> scopes = <String>['a', 'b'];
      when(mockApi.addScopes(any, _testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: '',
                ),
                accessToken: '',
                grantedScopes: scopes,
              )));

      await googleSignIn.serverAuthorizationTokensForScopes(
          ServerAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      final VerificationResult verification =
          verify(mockApi.addScopes(captureAny, _testUser.id));
      final List<String> passedScopes =
          verification.captured[0] as List<String>;
      expect(passedScopes, scopes);
    });

    test(
        'passes expected values to getRefreshedAuthorizationTokens if '
        'interaction is not allowed', () async {
      const List<String> scopes = <String>['a', 'b'];
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: '',
                ),
                accessToken: '',
                grantedScopes: scopes,
              )));

      await googleSignIn.serverAuthorizationTokensForScopes(
          ServerAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: false,
      )));

      verify(mockApi.getRefreshedAuthorizationTokens(_testUser.id));
    });

    test('attempts to restore previous sign in if no user is provided',
        () async {
      const List<String> scopes = <String>['a', 'b'];
      final SignInResult signInResult = SignInResult(
          success: SignInSuccess(
        user: UserData(
          displayName: _testUser.displayName,
          email: _testUser.email,
          userId: _testUser.id,
          photoUrl: _testUser.photoUrl,
          idToken: '',
        ),
        accessToken: '',
        grantedScopes: <String>[],
      ));
      when(mockApi.restorePreviousSignIn())
          .thenAnswer((_) async => signInResult);
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => signInResult);

      await googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: null,
        email: null,
        promptIfUnauthorized: false,
      )));

      // With no user ID provided to serverAuthorizationTokensForScopes, the
      // implementation should attempt to restore an existing sign-in, and then
      // when that succeeds, get the authorization tokens for that user.
      verify(mockApi.restorePreviousSignIn());
      verify(mockApi.getRefreshedAuthorizationTokens(_testUser.id));
    });

    test('returns null if unauthenticated and interaction is not allowed',
        () async {
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));

      final ServerAuthorizationTokenData? result =
          await googleSignIn.serverAuthorizationTokensForScopes(
              const ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: <String>['a', 'b'],
        userId: null,
        email: null,
        promptIfUnauthorized: false,
      )));

      // With no user ID provided to serverAuthorizationTokensForScopes, the
      // implementation should attempt to restore an existing sign-in, and then
      // when that fails, return null since without prompting, there is no way
      // to authenticate.
      verify(mockApi.restorePreviousSignIn());
      expect(result, null);
    });

    test(
        'attempts to authenticate if no user is provided or already signed in '
        'and interaction is allowed', () async {
      const List<String> scopes = <String>['a', 'b'];
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));
      when(mockApi.signIn(scopes, null)).thenAnswer((_) async => SignInResult(
              success: SignInSuccess(
            user: UserData(
              displayName: _testUser.displayName,
              email: _testUser.email,
              userId: _testUser.id,
              photoUrl: _testUser.photoUrl,
              idToken: '',
            ),
            accessToken: '',
            grantedScopes: <String>[],
          )));

      await googleSignIn.serverAuthorizationTokensForScopes(
          const ServerAuthorizationTokensForScopesParameters(
              request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: null,
        email: null,
        promptIfUnauthorized: true,
      )));

      // With no user ID provided to serverAuthorizationTokensForScopes, the
      // implementation should attempt to restore an existing sign-in, and when
      // that fails, prompt for a combined authn+authz.
      verify(mockApi.restorePreviousSignIn());
      verify(mockApi.signIn(scopes, null));
    });

    test('passes success data to caller when refreshing existing auth',
        () async {
      const List<String> scopes = <String>['a', 'b'];
      const String serverAuthCode = 'authCode';
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: 'token',
                serverAuthCode: serverAuthCode,
                grantedScopes: scopes,
              )));

      final ServerAuthorizationTokenData? result =
          await googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: false,
      )));

      expect(result?.serverAuthCode, serverAuthCode);
    });

    test('passes success data to caller when calling addScopes', () async {
      const List<String> scopes = <String>['a', 'b'];
      const String serverAuthCode = 'authCode';
      when(mockApi.addScopes(scopes, _testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: 'token',
                serverAuthCode: serverAuthCode,
                grantedScopes: scopes,
              )));

      final ServerAuthorizationTokenData? result =
          await googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      expect(result?.serverAuthCode, serverAuthCode);
    });

    test(
        'successfully returns refreshed tokens if addScopes indicates the '
        'requested scopes are already granted', () async {
      const List<String> scopes = <String>['a', 'b'];
      const String serverAuthCode = 'authCode';
      when(mockApi.addScopes(scopes, _testUser.id)).thenAnswer((_) async =>
          SignInResult(
              error: SignInFailure(
                  type: GoogleSignInErrorCode.scopesAlreadyGranted)));
      when(mockApi.getRefreshedAuthorizationTokens(_testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: 'token',
                serverAuthCode: serverAuthCode,
                grantedScopes: scopes,
              )));

      final ServerAuthorizationTokenData? result =
          await googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: scopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      verify(mockApi.addScopes(scopes, _testUser.id));
      verify(mockApi.getRefreshedAuthorizationTokens(_testUser.id));

      expect(result?.serverAuthCode, serverAuthCode);
    });

    test('returns null if re-using existing auth and scopes are missing',
        () async {
      const List<String> requestedScopes = <String>['a', 'b'];
      const List<String> grantedScopes = <String>['a'];
      const String accessToken = 'token';
      when(mockApi.addScopes(requestedScopes, _testUser.id))
          .thenAnswer((_) async => SignInResult(
                  success: SignInSuccess(
                user: UserData(
                  displayName: _testUser.displayName,
                  email: _testUser.email,
                  userId: _testUser.id,
                  photoUrl: _testUser.photoUrl,
                  idToken: 'idToken',
                ),
                accessToken: accessToken,
                grantedScopes: grantedScopes,
              )));

      final ServerAuthorizationTokenData? result =
          await googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
        scopes: requestedScopes,
        userId: _testUser.id,
        email: _testUser.email,
        promptIfUnauthorized: true,
      )));

      expect(result, null);
    });

    test('returns null when unauthorized', () async {
      when(mockApi.restorePreviousSignIn()).thenAnswer((_) async =>
          SignInResult(
              error:
                  SignInFailure(type: GoogleSignInErrorCode.noAuthInKeychain)));

      expect(
          await googleSignIn.serverAuthorizationTokensForScopes(
              const ServerAuthorizationTokensForScopesParameters(
                  request: defaultAuthRequest)),
          null);
    });

    test('thows canceled from SDK', () async {
      when(mockApi.addScopes(any, any)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.canceled)));

      expect(
          googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
            scopes: const <String>['a'],
            userId: _testUser.id,
            email: _testUser.email,
            promptIfUnauthorized: true,
          ))),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.canceled)));
    });

    test('throws unknown from SDK', () async {
      when(mockApi.addScopes(any, any)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.unknown)));

      expect(
          googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
            scopes: const <String>['a'],
            userId: _testUser.id,
            email: _testUser.email,
            promptIfUnauthorized: true,
          ))),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.unknownError)));
    });

    test('throws user mismatch from SDK', () async {
      when(mockApi.addScopes(any, any)).thenAnswer((_) async => SignInResult(
          error: SignInFailure(type: GoogleSignInErrorCode.userMismatch)));

      expect(
          googleSignIn.serverAuthorizationTokensForScopes(
              ServerAuthorizationTokensForScopesParameters(
                  request: AuthorizationRequestDetails(
            scopes: const <String>['a'],
            userId: _testUser.id,
            email: _testUser.email,
            promptIfUnauthorized: true,
          ))),
          throwsA(isInstanceOf<GoogleSignInException>().having(
              (GoogleSignInException e) => e.code,
              'code',
              GoogleSignInExceptionCode.userMismatch)));
    });
  });

  test('signOut calls through', () async {
    await googleSignIn.signOut(const SignOutParams());

    verify(mockApi.signOut());
  });

  test('disconnect calls through and also signs out', () async {
    await googleSignIn.disconnect(const DisconnectParams());

    verifyInOrder(<Future<void>>[
      mockApi.disconnect(),
      mockApi.signOut(),
    ]);
  });

  // Returning null triggers the app-facing package to create stream events,
  // per GoogleSignInPlatform docs, so it's important that this returns null
  // unless the platform implementation is changed to create all necessary
  // notifications.
  test('authenticationEvents returns null', () async {
    expect(googleSignIn.authenticationEvents, null);
  });
}
