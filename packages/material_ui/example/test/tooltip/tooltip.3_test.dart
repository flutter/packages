// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/tooltip/tooltip.3.dart' as example;

void main() {
  testWidgets('Tooltip is visible when tapping button', (
    WidgetTester tester,
  ) async {
    const String tooltipText = 'I am a Tooltip';

    await tester.pumpWidget(const example.TooltipExampleApp());

    // Tooltip is not visible before tapping the button.
    expect(find.text(tooltipText), findsNothing);
    // Tap on the button and wait for the tooltip to appear.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text(tooltipText), findsOneWidget);
    // Tap on the tooltip and wait for the tooltip to disappear.
    await tester.tap(findByTooltip(tooltipText));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(tooltipText), findsNothing);
  });
}

/// Finds [RawTooltip] or [Tooltip] widgets with the given `message`.
///
/// ## Sample code
///
/// ```dart
/// expect(findByTooltip('Back'), findsOneWidget);
/// expect(findByTooltip(RegExp('Back.*')), findsNWidgets(2));
/// ```
///
/// If the `skipOffstage` argument is true (the default), then this skips
/// nodes that are [Offstage] or that are from inactive [Route]s.
///
/// This was copied from flutter_test, which uses flutter/material.dart.
///
Finder findByTooltip(Pattern message, {bool skipOffstage = true}) {
  return find.byWidgetPredicate((Widget widget) {
    // Compare RawTooltip's semantics tooltip with the given message.
    // However, Tooltip's message needs to be checked directly if:
    // 1. Tooltip.excludeFromSemantics is true, since in this case Tooltip
    //    provides no semantics tooltip to the underlying RawTooltip.
    // 2. Tooltip.message and Tooltip.richMessage are empty, since in this
    //    case no RawTooltip is created.
    if (widget is Tooltip) {
      final String tooltipMessage =
          widget.message ?? widget.richMessage!.toPlainText();
      if ((widget.excludeFromSemantics ?? false) || tooltipMessage.isEmpty) {
        return message is RegExp
            ? message.hasMatch(tooltipMessage)
            : tooltipMessage == message;
      }
    }
    return widget is RawTooltip &&
        (message is RegExp
            ? message.hasMatch(widget.semanticsTooltip ?? '')
            : widget.semanticsTooltip == message);
  }, skipOffstage: skipOffstage);
}
