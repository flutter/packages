// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Finds [RawTooltip] or [Tooltip] widgets with the given `message`.
///
/// ## Sample code
///
/// ```dart
/// expect(find.byTooltip('Back'), findsOneWidget);
/// expect(find.byTooltip(RegExp('Back.*')), findsNWidgets(2));
/// ```
///
/// If the `skipOffstage` argument is true (the default), then this skips
/// nodes that are [Offstage] or that are from inactive [Route]s.
///
/// This was copied from flutter_test, which uses flutter/material.dart.
///
// TODO(justinmc): Port flutter_test to material_ui, then delete this method and
// use that one. See https://github.com/flutter/flutter/issues/186966
Finder findByTooltip(Pattern message, {bool skipOffstage = true}) {
  return find.byWidgetPredicate((Widget widget) {
    // Compare RawTooltip's semantics tooltip with the given message.
    // However, Tooltip's message needs to be checked directly if:
    // 1. Tooltip.excludeFromSemantics is true, since in this case Tooltip
    //    provides no semantics tooltip to the underlying RawTooltip.
    // 2. Tooltip.message and Tooltip.richMessage are empty, since in this
    //    case no RawTooltip is created.
    if (widget is Tooltip) {
      final String tooltipMessage = widget.message ?? widget.richMessage!.toPlainText();
      if ((widget.excludeFromSemantics ?? false) || tooltipMessage.isEmpty) {
        return message is RegExp ? message.hasMatch(tooltipMessage) : tooltipMessage == message;
      }
    }
    return widget is RawTooltip &&
        (message is RegExp
            ? message.hasMatch(widget.semanticsTooltip ?? '')
            : widget.semanticsTooltip == message);
  }, skipOffstage: skipOffstage);
}
