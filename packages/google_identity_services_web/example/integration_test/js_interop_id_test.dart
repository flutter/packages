// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// the following ignore is needed for downgraded analyzer (casts to JSObject).
// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

import 'utils.dart' as utils;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load web/mock-gis.js in the page
    await utils.installGisMock();
  });

  group('renderButton', () {
    testWidgets('supports a js-interop target from any library', (_) async {
      final web.HTMLDivElement target =
          web.document.createElement('div') as web.HTMLDivElement;

      id.renderButton(target);

      final web.Element? button = target.querySelector('button');
      expect(button, isNotNull);
    });
  });

  group('IdConfig', () {
    testWidgets('passes values from Dart to JS', (_) async {
      final IdConfiguration config = IdConfiguration(
        client_id: 'testing_1-2-3',
        auto_select: false,
        callback: (_) {},
        login_uri: Uri.parse('https://www.example.com/login'),
        native_callback: (_) {},
        cancel_on_tap_outside: false,
        prompt_parent_id: 'some_dom_id',
        nonce: 's0m3_r4ndOM_vALu3',
        context: OneTapContext.signin,
        state_cookie_domain: 'subdomain.example.com',
        ux_mode: UxMode.popup,
        allowed_parent_origin: <String>['allowed', 'another'],
        intermediate_iframe_close_callback: () {},
        itp_support: true,
        login_hint: 'login-hint@example.com',
        hd: 'hd_value',
        use_fedcm_for_prompt: true,
      );

      final utils.ExpectConfigValueFn expectConfigValue =
          utils.createExpectConfigValue(config as JSObject);

      expectConfigValue('client_id', 'testing_1-2-3');
      expectConfigValue('auto_select', false);
      expectConfigValue('callback', utils.isAJs('function'));
      expectConfigValue('login_uri', 'https://www.example.com/login');
      expectConfigValue('native_callback', utils.isAJs('function'));
      expectConfigValue('cancel_on_tap_outside', false);
      expectConfigValue(
          'allowed_parent_origin', <String>['allowed', 'another']);
      expectConfigValue('prompt_parent_id', 'some_dom_id');
      expectConfigValue('nonce', 's0m3_r4ndOM_vALu3');
      expectConfigValue('context', 'signin');
      expectConfigValue('state_cookie_domain', 'subdomain.example.com');
      expectConfigValue('ux_mode', 'popup');
      expectConfigValue(
          'intermediate_iframe_close_callback', utils.isAJs('function'));
      expectConfigValue('itp_support', true);
      expectConfigValue('login_hint', 'login-hint@example.com');
      expectConfigValue('hd', 'hd_value');
      expectConfigValue('use_fedcm_for_prompt', true);
    });
  });

  group('prompt', () {
    testWidgets(
        'supports a moment notification callback with correct type and reason',
        (_) async {
      id.initialize(IdConfiguration(client_id: 'testing_1-2-3'));
      utils.setMockMomentNotification('skipped', 'user_cancel');

      final StreamController<PromptMomentNotification> controller =
          StreamController<PromptMomentNotification>();

      id.prompt(controller.add);

      final PromptMomentNotification moment = await controller.stream.first;

      expect(moment.getMomentType(), MomentType.skipped);
      expect(moment.getSkippedReason(), MomentSkippedReason.user_cancel);
    });

    testWidgets(
        'supports a moment notification callback while handling invalid reason '
        'value gracefully', (_) async {
      id.initialize(IdConfiguration(client_id: 'testing_1-2-3'));
      utils.setMockMomentNotification('skipped', 'random_invalid_reason');

      final StreamController<PromptMomentNotification> controller =
          StreamController<PromptMomentNotification>();

      id.prompt(controller.add);

      final PromptMomentNotification moment = await controller.stream.first;

      expect(moment.getMomentType(), MomentType.skipped);
      expect(moment.getSkippedReason(), isNull);
    });

    testWidgets('calls config callback with credential response', (_) async {
      const String expected = 'should_be_a_proper_jwt_token';
      utils.setMockCredentialResponse(expected);

      final StreamController<CredentialResponse> controller =
          StreamController<CredentialResponse>();

      id.initialize(IdConfiguration(
        client_id: 'testing_1-2-3',
        callback: controller.add,
      ));

      id.prompt();

      final CredentialResponse response = await controller.stream.first;

      expect(response.credential, expected);
    });
  });
}
