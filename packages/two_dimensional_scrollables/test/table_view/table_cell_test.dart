// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/table_view.dart';

void main() {
  test('TableVicinity converts ChildVicinity', () {
    const TableVicinity vicinity = TableVicinity(column: 5, row: 10);
    expect(vicinity.xIndex, 5);
    expect(vicinity.yIndex, 10);
    expect(vicinity.toString(), '(row: 10, column: 5)');
  });

  // TableViewCell tests for merged cells, follow up change.
}
