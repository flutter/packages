// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/non_null_fields.gen.dart';

void main() {
  test('test constructor', () {
    final SearchRequest request = SearchRequest(query: 'what?');
    expect(request.query, 'what?');
  });
}
