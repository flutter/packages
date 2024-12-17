// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// the following ignore is needed for downgraded analyzer (casts to JSObject).
// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:integration_test/integration_test.dart';

import 'utils.dart' as utils;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load web/mock-gis.js in the page
    await utils.installGisMock();
  });

  group('Config objects pass values from Dart to JS - ', () {
    testWidgets('TokenClientConfig', (_) async {
      final TokenClientConfig config = TokenClientConfig(
        client_id: 'testing_1-2-3',
        callback: (TokenResponse _) {},
        scope: <String>['one', 'two', 'three'],
        include_granted_scopes: true,
        prompt: 'some-prompt',
        enable_granular_consent: true,
        login_hint: 'login-hint@example.com',
        hd: 'hd_value',
        state: 'some-state',
        error_callback: (GoogleIdentityServicesError? _) {},
      );

      final utils.ExpectConfigValueFn expectConfigValue =
          utils.createExpectConfigValue(config as JSObject);

      expectConfigValue('client_id', 'testing_1-2-3');
      expectConfigValue('callback', utils.isAJs('function'));
      expectConfigValue('scope', 'one two three');
      expectConfigValue('include_granted_scopes', true);
      expectConfigValue('prompt', 'some-prompt');
      expectConfigValue('enable_granular_consent', true);
      expectConfigValue('login_hint', 'login-hint@example.com');
      expectConfigValue('hd', 'hd_value');
      expectConfigValue('state', 'some-state');
      expectConfigValue('error_callback', utils.isAJs('function'));
    });

    testWidgets('OverridableTokenClientConfig', (_) async {
      final OverridableTokenClientConfig config = OverridableTokenClientConfig(
        scope: <String>['one', 'two', 'three'],
        include_granted_scopes: true,
        prompt: 'some-prompt',
        enable_granular_consent: true,
        login_hint: 'login-hint@example.com',
        state: 'some-state',
      );

      final utils.ExpectConfigValueFn expectConfigValue =
          utils.createExpectConfigValue(config as JSObject);

      expectConfigValue('scope', 'one two three');
      expectConfigValue('include_granted_scopes', true);
      expectConfigValue('prompt', 'some-prompt');
      expectConfigValue('enable_granular_consent', true);
      expectConfigValue('login_hint', 'login-hint@example.com');
      expectConfigValue('state', 'some-state');
    });

    testWidgets('CodeClientConfig', (_) async {
      final CodeClientConfig config = CodeClientConfig(
        client_id: 'testing_1-2-3',
        scope: <String>['one', 'two', 'three'],
        include_granted_scopes: true,
        redirect_uri: Uri.parse('https://www.example.com/login'),
        callback: (CodeResponse _) {},
        state: 'some-state',
        enable_granular_consent: true,
        login_hint: 'login-hint@example.com',
        hd: 'hd_value',
        ux_mode: UxMode.popup,
        select_account: true,
        error_callback: (GoogleIdentityServicesError? _) {},
      );

      final utils.ExpectConfigValueFn expectConfigValue =
          utils.createExpectConfigValue(config as JSObject);

      expectConfigValue('scope', 'one two three');
      expectConfigValue('include_granted_scopes', true);
      expectConfigValue('redirect_uri', 'https://www.example.com/login');
      expectConfigValue('callback', utils.isAJs('function'));
      expectConfigValue('state', 'some-state');
      expectConfigValue('enable_granular_consent', true);
      expectConfigValue('login_hint', 'login-hint@example.com');
      expectConfigValue('hd', 'hd_value');
      expectConfigValue('ux_mode', 'popup');
      expectConfigValue('select_account', true);
      expectConfigValue('error_callback', utils.isAJs('function'));
    });
  });

  group('initTokenClient', () {
    testWidgets('returns a tokenClient', (_) async {
      final TokenClient client = oauth2.initTokenClient(TokenClientConfig(
        client_id: 'for-tests',
        callback: (TokenResponse _) {},
        scope: <String>['some_scope', 'for_tests', 'not_real'],
      ));

      expect(client, isNotNull);
    });
  });

  group('requestAccessToken', () {
    testWidgets('passes through configuration', (_) async {
      final StreamController<TokenResponse> controller =
          StreamController<TokenResponse>();

      final List<String> scopes = <String>['some_scope', 'another', 'more'];

      final TokenClient client = oauth2.initTokenClient(TokenClientConfig(
        client_id: 'for-tests',
        callback: controller.add,
        scope: scopes,
      ));

      utils.setMockTokenResponse(client, 'some-non-null-auth-token-value');

      client.requestAccessToken();

      final TokenResponse response = await controller.stream.first;

      expect(response, isNotNull);
      expect(response.error, isNull);
      expect(response.scope, scopes);
    });

    testWidgets('configuration can be overridden', (_) async {
      final StreamController<TokenResponse> controller =
          StreamController<TokenResponse>();

      final List<String> scopes = <String>['some_scope', 'another', 'more'];

      final TokenClient client = oauth2.initTokenClient(TokenClientConfig(
        client_id: 'for-tests',
        callback: controller.add,
        scope: <String>['blank'],
      ));

      utils.setMockTokenResponse(client, 'some-non-null-auth-token-value');

      client.requestAccessToken(OverridableTokenClientConfig(
        scope: scopes,
      ));

      final TokenResponse response = await controller.stream.first;

      expect(response, isNotNull);
      expect(response.error, isNull);
      expect(response.scope, scopes);
    });
  });

  group('hasGranted...Scopes', () {
    // mock-gis.js returns false for scopes that start with "not-granted-".
    const String notGranted = 'not-granted-scope';

    testWidgets('all scopes granted', (_) async {
      final List<String> scopes = <String>['some_scope', 'another', 'more'];

      final TokenResponse response = await utils.fakeAuthZWithScopes(scopes);

      final bool all = oauth2.hasGrantedAllScopes(response, scopes);
      final bool any = oauth2.hasGrantedAnyScopes(response, scopes);

      expect(all, isTrue);
      expect(any, isTrue);
    });

    testWidgets('some scopes granted', (_) async {
      final List<String> scopes = <String>['some_scope', notGranted, 'more'];

      final TokenResponse response = await utils.fakeAuthZWithScopes(scopes);

      final bool all = oauth2.hasGrantedAllScopes(response, scopes);
      final bool any = oauth2.hasGrantedAnyScopes(response, scopes);

      expect(all, isFalse, reason: 'Scope: $notGranted should not be granted!');
      expect(any, isTrue);
    });

    testWidgets('no scopes granted', (_) async {
      final List<String> scopes = <String>[notGranted, '$notGranted-2'];

      final TokenResponse response = await utils.fakeAuthZWithScopes(scopes);

      final bool all = oauth2.hasGrantedAllScopes(response, scopes);
      final bool any = oauth2.hasGrantedAnyScopes(response, scopes);

      expect(all, isFalse);
      expect(any, isFalse, reason: 'No scopes were granted.');
    });
  });
}
