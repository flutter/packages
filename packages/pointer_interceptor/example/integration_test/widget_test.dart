// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

// Imports the Flutter Driver API.
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pointer_interceptor_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Widget', () {
    final Finder nonClickableButtonFinder =
        find.byKey(const Key('transparent-button'));
    final Finder clickableWrappedButtonFinder =
        find.byKey(const Key('wrapped-transparent-button'));
    final Finder clickableButtonFinder =
        find.byKey(const Key('clickable-button'));

    testWidgets(
        'on wrapped elements, the browser does not hit the background-html-view',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final html.Element? element =
          _getHtmlElementFromFinder(clickableButtonFinder, tester);

      if (html.document.querySelector('flt-glass-pane')?.shadowRoot != null) {
        // In flutter master...
        expect(element?.id, isNot('background-html-view'));
      } else {
        // In previous versions (--web-renderer=html only)...
        expect(element?.tagName.toLowerCase(), 'flt-platform-view');
        final html.Element? platformViewRoot =
            element?.shadowRoot?.getElementById('background-html-view');
        expect(platformViewRoot, isNull);
      }
    });

    testWidgets(
        'on wrapped elements with intercepting set to false, the browser hits the background-html-view',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final html.Element? element =
          _getHtmlElementFromFinder(clickableWrappedButtonFinder, tester);

      if (html.document.querySelector('flt-glass-pane')?.shadowRoot != null) {
        // In flutter master...
        expect(element?.id, 'background-html-view');
      } else {
        // In previous versions (--web-renderer=html only)...
        expect(element?.tagName.toLowerCase(), 'flt-platform-view');
        final html.Element? platformViewRoot =
            element?.shadowRoot?.getElementById('background-html-view');
        expect(platformViewRoot, isNotNull);
      }
    });

    testWidgets(
        'on unwrapped elements, the browser hits the background-html-view',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final html.Element? element =
          _getHtmlElementFromFinder(nonClickableButtonFinder, tester);

      if (html.document.querySelector('flt-glass-pane')?.shadowRoot != null) {
        // In flutter master...
        expect(element?.id, 'background-html-view');
      } else {
        // In previous versions (--web-renderer=html only)...
        expect(element?.tagName.toLowerCase(), 'flt-platform-view');
        final html.Element? platformViewRoot =
            element?.shadowRoot?.getElementById('background-html-view');
        expect(platformViewRoot, isNotNull);
      }
    });
  });
}

// This functions locates a widget from a Finder, and asks the browser what's the
// DOM element in the center of the coordinates of the widget. (Returns *which*
// DOM element will handle Mouse interactions first at those coordinates.)
html.Element? _getHtmlElementFromFinder(Finder finder, WidgetTester tester) {
  final Offset point = tester.getCenter(finder);
  return html.document.elementFromPoint(point.dx.toInt(), point.dy.toInt());
}
