// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:dart_ui_web_shim/ui.dart' as ui;

import 'package:dart_ui_web_shim_integration_tests/main.dart' as app;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const String expectedContents = 'Contents defined in test!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('platformViewRegistry', () {
    testWidgets('registerViewFactory works', (WidgetTester tester) async {
      ui.platformViewRegistry.registerViewFactory(app.viewId, (int id) {
        return html.DivElement()
          ..id = 'test-passed'
          ..innerText = expectedContents
          ..style.width = '100%'
          ..style.height = '100%';
      });

      app.main();
      await tester.pumpAndSettle();

      // Expect that the DOM contains a div with id = #test-passed
      final html.Element? element = html.document.querySelector('#test-passed');

      expect(element, isNotNull);
      expect(element!.innerText, expectedContents);
    });
  });

  group('webOnlyAssetManager', () {
    testWidgets('assetURL is valid in web', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final String result = ui.webOnlyAssetManager.getAssetUrl('file.txt');

      expect(result, 'assets/file.txt');
    });
  });
}
