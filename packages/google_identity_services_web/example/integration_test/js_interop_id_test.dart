// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:integration_test/integration_test.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util show getProperty;

import 'src/dom.dart';
import 'utils.dart' as utils;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load web/mock-gis.js in the page
    await utils.installGisMock();
  });

  group('renderButton', () {
    testWidgets('supports a js-interop target from any library', (_) async {
      final DomElement target = createDomElement('div');

      id.renderButton(target);

      final DomElement? button = target.querySelector('button');
      expect(button, isNotNull);
    });
  });

  group('IdConfig', () {
    testWidgets('passes values from Dart to JS', (_) async {
      final IdConfiguration config = IdConfiguration(
        client_id: 'testing_1-2-3',
        auto_select: false,
        callback: allowInterop((_) {}),
        login_uri: Uri.parse('https://www.example.com/login'),
        native_callback: allowInterop((_) {}),
        cancel_on_tap_outside: false,
        prompt_parent_id: 'some_dom_id',
        nonce: 's0m3_r4ndOM_vALu3',
        context: OneTapContext.signin,
        state_cookie_domain: 'subdomain.example.com',
        ux_mode: UxMode.popup,
        allowed_parent_origin: <String>['allowed', 'another'],
        intermediate_iframe_close_callback: allowInterop((_) {}),
        itp_support: true,
        login_hint: 'login-hint@example.com',
        hd: 'hd_value',
        use_fedcm_for_prompt: true,
      );

      // Save some keystrokes below by partially applying to the 'config' above.
      void expectConfigValue(String name, Object? matcher) {
        expect(js_util.getProperty(config, name), matcher, reason: name);
      }

      expectConfigValue('allowed_parent_origin', hasLength(2));
      expectConfigValue('auto_select', isFalse);
      expectConfigValue('callback', isA<Function>());
      expectConfigValue('cancel_on_tap_outside', isFalse);
      expectConfigValue('client_id', 'testing_1-2-3');
      expectConfigValue('context', isA<OneTapContext>());
      expectConfigValue('hd', 'hd_value');
      expectConfigValue('intermediate_iframe_close_callback', isA<Function>());
      expectConfigValue('itp_support', isTrue);
      expectConfigValue('login_hint', 'login-hint@example.com');
      expectConfigValue('login_uri', isA<Uri>());
      expectConfigValue('native_callback', isA<Function>());
      expectConfigValue('nonce', 's0m3_r4ndOM_vALu3');
      expectConfigValue('prompt_parent_id', 'some_dom_id');
      expectConfigValue('state_cookie_domain', 'subdomain.example.com');
      expectConfigValue('use_fedcm_for_prompt', isTrue);
      expectConfigValue('ux_mode', isA<UxMode>());
    });
  });

  group('prompt', () {
    testWidgets('supports a moment notification callback', (_) async {
      id.initialize(IdConfiguration(client_id: 'testing_1-2-3'));

      final StreamController<PromptMomentNotification> controller =
          StreamController<PromptMomentNotification>();

      id.prompt(allowInterop(controller.add));

      final PromptMomentNotification moment = await controller.stream.first;

      // These defaults are set in mock-gis.js
      expect(moment.getMomentType(), MomentType.skipped);
      expect(moment.getSkippedReason(), MomentSkippedReason.user_cancel);
    });

    testWidgets('calls config callback with credential response', (_) async {
      const String expected = 'should_be_a_proper_jwt_token';
      utils.setMockCredentialResponse(expected);

      final StreamController<CredentialResponse> controller =
          StreamController<CredentialResponse>();

      id.initialize(IdConfiguration(
        client_id: 'testing_1-2-3',
        callback: allowInterop(controller.add),
      ));

      id.prompt();

      final CredentialResponse response = await controller.stream.first;

      expect(response.credential, expected);
    });
  });
}
