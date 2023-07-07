// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_android/google_sign_in_android.dart';
import 'package:google_sign_in_android/src/messages.g.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_sign_in_android_test.mocks.dart';

final GoogleSignInUserData _user = GoogleSignInUserData(
  email: 'john.doe@gmail.com',
  id: '8162538176523816253123',
  photoUrl: 'https://lh5.googleusercontent.com/photo.jpg',
  displayName: 'John Doe',
  idToken: '123',
  serverAuthCode: '789',
);
final GoogleSignInTokenData _token = GoogleSignInTokenData(
  accessToken: '456',
);

@GenerateMocks(<Type>[GoogleSignInApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleSignInAndroid googleSignIn;
  late MockGoogleSignInApi api;

  setUp(() {
    api = MockGoogleSignInApi();
    googleSignIn = GoogleSignInAndroid(api: api);
  });

  test('registered instance', () {
    GoogleSignInAndroid.registerWith();
    expect(GoogleSignInPlatform.instance, isA<GoogleSignInAndroid>());
  });

  test('signInSilently transforms platform data to GoogleSignInUserData',
      () async {
    when(api.signInSilently()).thenAnswer((_) async => UserData(
          email: _user.email,
          id: _user.id,
          photoUrl: _user.photoUrl,
          displayName: _user.displayName,
          idToken: _user.idToken,
          serverAuthCode: _user.serverAuthCode,
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
          id: _user.id,
          photoUrl: _user.photoUrl,
          displayName: _user.displayName,
          idToken: _user.idToken,
          serverAuthCode: _user.serverAuthCode,
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
    when(api.getAccessToken(_user.email, recoverAuth))
        .thenAnswer((_) async => _token.accessToken!);

    final GoogleSignInTokenData response = await googleSignIn.getTokens(
        email: _user.email, shouldRecoverAuth: recoverAuth);

    expect(response, _token);
  });

  test('getTokens will not pass null for shouldRecoverAuth', () async {
    when(api.getAccessToken(_user.email, true))
        .thenAnswer((_) async => _token.accessToken!);

    final GoogleSignInTokenData response = await googleSignIn.getTokens(
        email: _user.email, shouldRecoverAuth: null);

    expect(response, _token);
  });

  test('initWithParams passes arguments', () async {
    const SignInInitParameters initParams = SignInInitParameters(
      hostedDomain: 'example.com',
      scopes: <String>['two', 'scopes'],
      signInOption: SignInOption.games,
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
    expect(passedParams.signInType, SignInType.games);
    expect(passedParams.clientId, initParams.clientId);
    // These should use whatever the SignInInitParameters defaults are.
    expect(passedParams.serverClientId, initParams.serverClientId);
    expect(passedParams.forceCodeForRefreshToken,
        initParams.forceCodeForRefreshToken);
  });

  test('initWithParams passes arguments', () async {
    const SignInInitParameters initParams = SignInInitParameters(
      hostedDomain: 'example.com',
      scopes: <String>['two', 'scopes'],
      signInOption: SignInOption.games,
      clientId: 'fakeClientId',
      serverClientId: 'fakeServerClientId',
      forceCodeForRefreshToken: true,
    );

    await googleSignIn.initWithParams(initParams);

    final VerificationResult result = verify(api.init(captureAny));
    final InitParams passedParams = result.captured[0] as InitParams;
    expect(passedParams.hostedDomain, initParams.hostedDomain);
    expect(passedParams.scopes, initParams.scopes);
    expect(passedParams.signInType, SignInType.games);
    expect(passedParams.clientId, initParams.clientId);
    expect(passedParams.serverClientId, initParams.serverClientId);
    expect(passedParams.forceCodeForRefreshToken,
        initParams.forceCodeForRefreshToken);
  });

  test('clearAuthCache passes arguments', () async {
    const String token = 'abc';

    await googleSignIn.clearAuthCache(token: token);

    verify(api.clearAuthCache(token));
  });

  test('requestScopens passes arguments', () async {
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
