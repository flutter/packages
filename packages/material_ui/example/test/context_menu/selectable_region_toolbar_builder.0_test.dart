// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/context_menu/selectable_region_toolbar_builder.0.dart'
    as example;

void main() {
  testWidgets('showing and hiding the custom context menu on SelectionArea', (
    WidgetTester tester,
  ) async {
    bool disabledWasCalled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.contextMenu, (
          MethodCall methodCall,
        ) {
          if (methodCall.method == 'disableContextMenu') {
            expect(methodCall.arguments, isNull);
            disabledWasCalled = true;
          }
          return;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.contextMenu, null);
    });

    await tester.pumpWidget(
      const example.SelectableRegionToolbarBuilderExampleApp(),
    );

    expect(BrowserContextMenu.enabled, !kIsWeb);
    expect(disabledWasCalled, kIsWeb);

    // Allow the selection overlay geometry to be created.
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

    // Right clicking the Text in the SelectionArea shows the custom context
    // menu.
    final TestGesture primaryMouseButtonGesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text(example.text)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);

    // Tap to dismiss.
    await primaryMouseButtonGesture.down(
      tester.getCenter(find.byType(Scaffold)),
    );
    await tester.pump();
    await primaryMouseButtonGesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
  });
}
