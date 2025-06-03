// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Imports the Flutter Driver API.
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pointer_interceptor_web_example/main.dart' as app;
import 'package:web/web.dart' as web;

final Finder nonClickableButtonFinder =
    find.byKey(const Key('transparent-button'));
final Finder clickableWrappedButtonFinder =
    find.byKey(const Key('wrapped-transparent-button'));
final Finder clickableButtonFinder = find.byKey(const Key('clickable-button'));
final Finder backgroundFinder = find.byKey(const Key('background-widget'));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Without semantics', () {
    testWidgets(
        'on wrapped elements, the browser does not hit the background-html-view',
        (WidgetTester tester) async {
      await _fullyRenderApp(tester);

      final web.Element element =
          _getHtmlElementAtCenter(clickableButtonFinder, tester);

      expect(element.id, isNot('background-html-view'));
    }, semanticsEnabled: false);

    testWidgets(
        'on wrapped elements with intercepting set to false, the browser hits the background-html-view',
        (WidgetTester tester) async {
      await _fullyRenderApp(tester);

      final web.Element element =
          _getHtmlElementAtCenter(clickableWrappedButtonFinder, tester);

      expect(element.id, 'background-html-view');
    }, semanticsEnabled: false);

    testWidgets(
        'on unwrapped elements, the browser hits the background-html-view',
        (WidgetTester tester) async {
      await _fullyRenderApp(tester);

      final web.Element element =
          _getHtmlElementAtCenter(nonClickableButtonFinder, tester);

      expect(element.id, 'background-html-view');
    }, semanticsEnabled: false);

    testWidgets('on background directly', (WidgetTester tester) async {
      await _fullyRenderApp(tester);

      final web.Element element =
          _getHtmlElementAt(tester.getTopLeft(backgroundFinder));

      expect(element.id, 'background-html-view');
    }, semanticsEnabled: false);

    // Regression test for https://github.com/flutter/flutter/issues/157920
    testWidgets(
      'prevents default action of mousedown events',
      (WidgetTester tester) async {
        await _fullyRenderApp(tester);

        final web.Element element =
            _getHtmlElementAtCenter(clickableButtonFinder, tester);
        expect(element.tagName.toLowerCase(), 'div');

        for (int i = 0; i <= 4; i++) {
          final web.MouseEvent event = web.MouseEvent(
            'mousedown',
            web.MouseEventInit(button: i, cancelable: true),
          );
          element.dispatchEvent(event);
          expect(event.target, element);
          expect(event.defaultPrevented, isTrue);
        }
      },
      semanticsEnabled: false,
    );
  });
}

Future<void> _fullyRenderApp(WidgetTester tester) async {
  await tester.pumpWidget(const app.MyApp());
  // Pump 2 frames so the framework injects the platform view into the DOM.
  await tester.pump();
  // Give the browser some time to perform DOM operations (for Wasm code)
  await tester.pump(const Duration(milliseconds: 500));
}

// Calls [_getHtmlElementAt] passing it the center of the widget identified by
// the `finder`.
web.Element _getHtmlElementAtCenter(Finder finder, WidgetTester tester) {
  final Offset point = tester.getCenter(finder);
  return _getHtmlElementAt(point);
}

// Locates the DOM element at the given `point` using `elementFromPoint`.
//
// `elementFromPoint` is an approximate proxy for a hit test, although it's
// sensitive to the presence of shadow roots and browser quirks (not all
// browsers agree on what it should return in all situations). Since this test
// runs only in Chromium, it relies on Chromium's behavior.
web.Element _getHtmlElementAt(Offset point) {
  // Probe at the shadow so the browser reports semantics nodes in addition to
  // platform view elements. If probed from `html.document` the browser hides
  // the contents of <flt-glass-name> as an implementation detail.
  final web.ShadowRoot glassPaneShadow =
      web.document.querySelector('flt-glass-pane')!.shadowRoot!;
  // Use `round` below to ensure clicks always fall *inside* the located
  // element, rather than truncating the decimals.
  // Truncating decimals makes some tests fail when a centered element (in high
  // DPI) is not exactly aligned to the pixel grid (because the browser *rounds*)
  return glassPaneShadow.elementFromPoint(point.dx.round(), point.dy.round());
}

/// Shady API: https://github.com/w3c/csswg-drafts/issues/556
extension ElementFromPointInShadowRoot on web.ShadowRoot {
  external web.Element elementFromPoint(int x, int y);
}
