// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findCupertinoOverflowNextButton() {
  return find.byWidgetPredicate((Widget widget) {
    return widget is CustomPaint &&
        '${widget.painter?.runtimeType}' == '_RightCupertinoChevronPainter';
  });
}

Finder findCupertinoOverflowBackButton() {
  return find.byWidgetPredicate((Widget widget) {
    return widget is CustomPaint &&
        '${widget.painter?.runtimeType}' == '_LeftCupertinoChevronPainter';
  });
}

Future<void> tapCupertinoOverflowNextButton(WidgetTester tester) async {
  await tester.tapAt(tester.getCenter(findCupertinoOverflowNextButton()));
  await tester.pumpAndSettle();
}
