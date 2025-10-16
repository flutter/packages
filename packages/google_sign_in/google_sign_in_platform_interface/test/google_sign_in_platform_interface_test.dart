// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group('GoogleSignInPlatform', () {
    test('cannot be implemented with `implements`', () {
      expect(() {
        GoogleSignInPlatform.instance = ImplementsGoogleSignInPlatform();
        // In versions of `package:plugin_platform_interface` prior to fixing
        // https://github.com/flutter/flutter/issues/109339, an attempt to
        // implement a platform interface using `implements` would sometimes
        // throw a `NoSuchMethodError` and other times throw an
        // `AssertionError`.  After the issue is fixed, an `AssertionError` will
        // always be thrown.  For the purpose of this test, we don't really care
        // what exception is thrown, so just allow any exception.
      }, throwsA(anything));
    });

    test('can be extended', () {
      GoogleSignInPlatform.instance = ExtendsGoogleSignInPlatform();
    });

    test('can be mocked with `implements`', () {
      GoogleSignInPlatform.instance = MockImplementation();
    });

    test('implements authenticationEvents to return null by default', () {
      // This uses ExtendsGoogleSignInPlatform since that's within the control
      // of the test file, and doesn't override authenticationEvents; using
      // the default `.instance` would only validate that the placeholder has
      // this behavior, which could be implemented in the subclass.
      expect(ExtendsGoogleSignInPlatform().authenticationEvents, null);
    });

    test(
      'Default implementation of clearAuthorizationToken throws unimplemented error',
      () {
        final ExtendsGoogleSignInPlatform platform =
            ExtendsGoogleSignInPlatform();

        expect(
          () => platform.clearAuthorizationToken(
            const ClearAuthorizationTokenParams(accessToken: 'someToken'),
          ),
          throwsUnimplementedError,
        );
      },
    );
  });

  group('GoogleSignInUserData', () {
    test('can be compared by == operator', () {
      const GoogleSignInUserData firstInstance = GoogleSignInUserData(
        email: 'email',
        id: 'id',
        displayName: 'displayName',
        photoUrl: 'photoUrl',
      );
      const GoogleSignInUserData secondInstance = GoogleSignInUserData(
        email: 'email',
        id: 'id',
        displayName: 'displayName',
        photoUrl: 'photoUrl',
      );
      expect(firstInstance == secondInstance, isTrue);
    });
  });

  group('AuthenticationTokenData', () {
    test('can be compared by == operator', () {
      const AuthenticationTokenData firstInstance = AuthenticationTokenData(
        idToken: 'idToken',
      );
      const AuthenticationTokenData secondInstance = AuthenticationTokenData(
        idToken: 'idToken',
      );
      expect(firstInstance == secondInstance, isTrue);
    });
  });

  group('ClientAuthorizationTokenData', () {
    test('can be compared by == operator', () {
      const ClientAuthorizationTokenData firstInstance =
          ClientAuthorizationTokenData(accessToken: 'accessToken');
      const ClientAuthorizationTokenData secondInstance =
          ClientAuthorizationTokenData(accessToken: 'accessToken');
      expect(firstInstance == secondInstance, isTrue);
    });
  });

  group('ServerAuthorizationTokenData', () {
    test('can be compared by == operator', () {
      const ServerAuthorizationTokenData firstInstance =
          ServerAuthorizationTokenData(serverAuthCode: 'serverAuthCode');
      const ServerAuthorizationTokenData secondInstance =
          ServerAuthorizationTokenData(serverAuthCode: 'serverAuthCode');
      expect(firstInstance == secondInstance, isTrue);
    });
  });
}

class MockImplementation extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleSignInPlatform {}

class ImplementsGoogleSignInPlatform extends Mock
    implements GoogleSignInPlatform {}

class ExtendsGoogleSignInPlatform extends GoogleSignInPlatform {
  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async {
    return null;
  }

  @override
  bool supportsAuthenticate() => false;

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) {
    throw UnimplementedError();
  }

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async {
    return null;
  }

  @override
  Future<void> disconnect(DisconnectParams params) async {}

  @override
  Future<void> init(InitParameters params) async {}

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async {
    return null;
  }

  @override
  Future<void> signOut(SignOutParams params) async {}
}
