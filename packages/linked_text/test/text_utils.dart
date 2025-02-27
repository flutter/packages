// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

// Returns the Rect in global coordinates of the given String located in a Text
// or RichText widget.
Rect getTextRect(WidgetTester tester, String substring) {
  expect(find.byType(RichText), findsAtLeast(1));

  final Iterable<RenderParagraph> renderParagraphs = tester.renderObjectList(find.byType(RichText));
  for (final RenderParagraph renderParagraph in renderParagraphs) {
    final String text = renderParagraph.text.toPlainText();
    final int index = text.indexOf(substring);
    if (index >= 0) {
      final List<TextBox> boxes = renderParagraph.getBoxesForSelection(
        TextSelection(
          baseOffset: index,
          extentOffset: index + substring.length,
        ),
      );
      expect(boxes, hasLength(1));
      final TextBox box = boxes.first;
      return Rect.fromLTRB(box.left, box.top, box.right, box.bottom);
    }
  }
  throw FlutterError('The substring was not found in the tester.');
}
