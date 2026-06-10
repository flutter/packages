// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/context_menu/editable_text_toolbar_builder.0.dart'
    as example;

void main() {
  testWidgets(
    'showing and hiding the context menu in TextField with custom buttons',
    (WidgetTester tester) async {
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
        const example.EditableTextToolbarBuilderExampleApp(),
      );

      expect(BrowserContextMenu.enabled, !kIsWeb);
      expect(disabledWasCalled, kIsWeb);

      await tester.tap(find.byType(EditableText));
      await tester.pump();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

      // Long pressing the field shows the default context menu but with custom
      // buttons.
      await tester.longPress(find.byType(EditableText));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
      expect(find.byType(CupertinoButton), findsAtLeastNWidgets(1));

      // Tap to dismiss.
      await tester.tapAt(tester.getTopLeft(find.byType(EditableText)));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
      expect(find.byType(CupertinoButton), findsNothing);
    },
  );
}
