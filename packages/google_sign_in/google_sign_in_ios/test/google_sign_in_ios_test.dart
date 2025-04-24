// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_ios/google_sign_in_ios.dart';
import 'package:google_sign_in_ios/src/messages.g.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_sign_in_ios_test.mocks.dart';

final GoogleSignInUserData _user = GoogleSignInUserData(
    email: 'john.doe@gmail.com',
    id: '8162538176523816253123',
    photoUrl: 'https://lh5.googleusercontent.com/photo.jpg',
    displayName: 'John Doe',
    serverAuthCode: '789',
    idToken: '123');

final GoogleSignInTokenData _token = GoogleSignInTokenData(
  idToken: '123',
  accessToken: '456',
);

@GenerateMocks(<Type>[GoogleSignInApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleSignInIOS googleSignIn;
  late MockGoogleSignInApi api;

  setUp(() {
    api = MockGoogleSignInApi();
    googleSignIn = GoogleSignInIOS(api: api);
  });

  test('registered instance', () {
    GoogleSignInIOS.registerWith();
    expect(GoogleSignInPlatform.instance, isA<GoogleSignInIOS>());
  });

  test('init throws for SignInOptions.games', () async {
    expect(
        () => googleSignIn.init(
            hostedDomain: 'example.com',
            signInOption: SignInOption.games,
            clientId: 'fakeClientId'),
        throwsA(isInstanceOf<PlatformException>().having(
            (PlatformException e) => e.code, 'code', 'unsupported-options')));
  });

  test('init throws for forceAccountName', () async {
    expect(
        () => googleSignIn.initWithParams(
              const SignInInitParameters(
                hostedDomain: 'example.com',
                clientId: 'fakeClientId',
                forceAccountName: 'fakeEmailAddress@example.com',
              ),
            ),
        throwsA(isInstanceOf<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            'Force account name is not supported on iOS')));
  });

  test('signInSilently transforms platform data to GoogleSignInUserData',
      () async {
    when(api.signInSilently()).thenAnswer((_) async => UserData(
          email: _user.email,
          userId: _user.id,
          photoUrl: _user.photoUrl,
          displayName: _user.displayName,
          serverAuthCode: _user.serverAuthCode,
          idToken: _user.idToken,
        ));

    final dynamic response = await googleSignIn.signInSilently();

    expect(response, _user);
  });

  test('signInSilently Exceptions -> throws', () async {
    when(api.signInSilently())
        .thenAnswer((_) async => throw PlatformException(code: 'fail'));

    expect(googleSignIn.signInSilently(),
        throwsA(isInstanceOf<PlatformException>()));
  });

  test('signIn transforms platform data to GoogleSignInUserData', () async {
    when(api.signIn()).thenAnswer((_) async => UserData(
          email: _user.email,
          userId: _user.id,
          photoUrl: _user.photoUrl,
          displayName: _user.displayName,
          serverAuthCode: _user.serverAuthCode,
          idToken: _user.idToken,
        ));

    final dynamic response = await googleSignIn.signIn();

    expect(response, _user);
  });

  test('signIn Exceptions -> throws', () async {
    when(api.signIn())
        .thenAnswer((_) async => throw PlatformException(code: 'fail'));

    expect(googleSignIn.signIn(), throwsA(isInstanceOf<PlatformException>()));
  });

  test('getTokens transforms platform data to GoogleSignInTokenData', () async {
    const bool recoverAuth = false;
    when(api.getAccessToken()).thenAnswer((_) async =>
        TokenData(idToken: _token.idToken, accessToken: _token.accessToken));

    final GoogleSignInTokenData response = await googleSignIn.getTokens(
        email: _user.email, shouldRecoverAuth: recoverAuth);

    expect(response, _token);
  });

  test('clearAuthCache silently no-ops', () async {
    expect(googleSignIn.clearAuthCache(token: 'abc'), completes);
  });

  test('initWithParams passes arguments', () async {
    const SignInInitParameters initParams = SignInInitParameters(
      hostedDomain: 'example.com',
      scopes: <String>['two', 'scopes'],
      clientId: 'fakeClientId',
    );

    await googleSignIn.init(
      hostedDomain: initParams.hostedDomain,
      scopes: initParams.scopes,
      signInOption: initParams.signInOption,
      clientId: initParams.clientId,
    );

    final VerificationResult result = verify(api.init(captureAny));
    final InitParams passedParams = result.captured[0] as InitParams;
    expect(passedParams.hostedDomain, initParams.hostedDomain);
    expect(passedParams.scopes, initParams.scopes);
    expect(passedParams.clientId, initParams.clientId);
    // This should use whatever the SignInInitParameters defaults are.
    expect(passedParams.serverClientId, initParams.serverClientId);
  });

  test('initWithParams passes arguments', () async {
    const SignInInitParameters initParams = SignInInitParameters(
      hostedDomain: 'example.com',
      scopes: <String>['two', 'scopes'],
      clientId: 'fakeClientId',
      serverClientId: 'fakeServerClientId',
      forceCodeForRefreshToken: true,
    );

    await googleSignIn.initWithParams(initParams);

    final VerificationResult result = verify(api.init(captureAny));
    final InitParams passedParams = result.captured[0] as InitParams;
    expect(passedParams.hostedDomain, initParams.hostedDomain);
    expect(passedParams.scopes, initParams.scopes);
    expect(passedParams.clientId, initParams.clientId);
    expect(passedParams.serverClientId, initParams.serverClientId);
  });

  test('requestScopes passes arguments', () async {
    const List<String> scopes = <String>['newScope', 'anotherScope'];
    when(api.requestScopes(scopes)).thenAnswer((_) async => true);

    final bool response = await googleSignIn.requestScopes(scopes);

    expect(response, true);
  });

  test('signOut calls through', () async {
    await googleSignIn.signOut();

    verify(api.signOut());
  });

  test('disconnect calls through', () async {
    await googleSignIn.disconnect();

    verify(api.disconnect());
  });

  test('isSignedIn passes true response', () async {
    when(api.isSignedIn()).thenAnswer((_) async => true);

    expect(await googleSignIn.isSignedIn(), true);
  });

  test('isSignedIn passes false response', () async {
    when(api.isSignedIn()).thenAnswer((_) async => false);

    expect(await googleSignIn.isSignedIn(), false);
  });
}
