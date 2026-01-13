// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart'
    show GoogleSignInPlugin;
import 'package:google_sign_in_web/src/gis_client.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'web_only_test.mocks.dart';

// Mock GisSdkClient so we can simulate any response from the JS side.
@GenerateMocks(
  <Type>[],
  customMocks: <MockSpec<dynamic>>[
    MockSpec<GisSdkClient>(onMissingStub: OnMissingStub.returnDefault),
  ],
)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('non-web plugin instance', () {
    setUp(() {
      GoogleSignInPlatform.instance = NonWebImplementation();
    });

    testWidgets('renderButton throws', (WidgetTester _) async {
      expect(() {
        web.renderButton();
      }, throwsAssertionError);
    });
  });

  group('web plugin instance', () {
    late MockGisSdkClient mockGis;

    setUp(() async {
      mockGis = MockGisSdkClient();
      GoogleSignInPlatform.instance = GoogleSignInPlugin(
        debugOverrideLoader: true,
        debugOverrideGisSdkClient: mockGis,
      );
      await GoogleSignInPlatform.instance.init(
        const InitParameters(clientId: 'does-not-matter'),
      );
    });

    testWidgets('renderButton returns successfully', (WidgetTester _) async {
      when(
        mockGis.renderButton(any, any),
      ).thenAnswer((_) => Future<void>.value());

      final Widget button = web.renderButton();

      expect(button, isNotNull);
    });
  });
}

/// Fake non-web implementation used to verify that the web_only methods
/// throw when the wrong type of instance is configured.
class NonWebImplementation extends GoogleSignInPlatform {
  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) {
    throw UnimplementedError();
  }

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect(DisconnectParams params) {
    throw UnimplementedError();
  }

  @override
  Future<void> init(InitParameters params) {
    throw UnimplementedError();
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut(SignOutParams params) {
    throw UnimplementedError();
  }

  @override
  bool authorizationRequiresUserInteraction() {
    throw UnimplementedError();
  }

  @override
  bool supportsAuthenticate() {
    throw UnimplementedError();
  }
}
