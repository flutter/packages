// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/src/js_interop/dom.dart';

import 'package:integration_test/integration_test.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('window')
external Object get domWindow;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load web/mock-gis.js in the page
    await installGisMock();
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
      setMockCredentialResponse(expected);

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

/// Installs mock-gis.js in the page.
/// Returns a future that completes when the 'load' event of the script fires.
Future<void> installGisMock() {
  final Completer<void> completer = Completer<void>();
  final DomHtmlScriptElement script =
      document.createElement('script') as DomHtmlScriptElement;
  script.src = 'mock-gis.js';
  setProperty(script, 'type', 'module');
  callMethod(script, 'addEventListener', <Object>[
    'load',
    allowInterop((_) {
      completer.complete();
    })
  ]);
  document.head.appendChild(script);
  return completer.future;
}

void setMockCredentialResponse([String value = 'default_value']) {
  callMethod(
    _getGoogleAccountsId(),
    'setMockCredentialResponse',
    <Object>[value, 'auto'],
  );
}

Object _getGoogleAccountsId() {
  return _getDeepProperty<Object>(domWindow, 'google.accounts.id');
}

// Attempts to retrieve a deeply nested property from a jsObject (or die tryin')
T _getDeepProperty<T>(Object jsObject, String deepProperty) {
  final List<String> properties = deepProperty.split('.');
  return properties.fold(
    jsObject,
    (Object jsObj, String prop) => getProperty<Object>(jsObj, prop),
  ) as T;
}
