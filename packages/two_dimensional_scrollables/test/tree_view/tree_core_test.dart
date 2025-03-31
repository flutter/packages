// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('TreeViewIndentationType', () {
    test('Values are properly reflected', () {
      double value = TreeViewIndentationType.standard.value;
      expect(value, 10.0);

      value = TreeViewIndentationType.none.value;
      expect(value, 0.0);

      value = TreeViewIndentationType.custom(50.0).value;
      expect(value, 50.0);
    });
  });
}
