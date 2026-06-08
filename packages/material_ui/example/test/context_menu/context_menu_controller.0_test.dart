// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/context_menu/context_menu_controller.0.dart'
    as example;

void main() {
  testWidgets('showing and hiding the custom context menu in the whole app', (
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

    await tester.pumpWidget(const example.ContextMenuControllerExampleApp());

    expect(BrowserContextMenu.enabled, !kIsWeb);
    expect(disabledWasCalled, kIsWeb);

    expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

    // Right clicking the middle of the app shows the custom context menu.
    final Offset center = tester.getCenter(find.byType(Scaffold));
    final TestGesture gesture = await tester.startGesture(
      center,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);

    // Tap to dismiss.
    await tester.tapAt(center);
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

    // Long pressing also shows the custom context menu.
    await tester.longPressAt(center);

    expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });
}
