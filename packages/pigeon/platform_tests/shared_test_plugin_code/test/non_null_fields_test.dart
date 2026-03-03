// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/non_null_fields.gen.dart';

void main() {
  test('test constructor', () {
    final request = NonNullFieldSearchRequest(query: 'what?');
    expect(request.query, 'what?');
  });

  test('test equality', () {
    final request1 = NonNullFieldSearchRequest(query: 'hello');
    final request2 = NonNullFieldSearchRequest(query: 'hello');
    final request3 = NonNullFieldSearchRequest(query: 'world');

    expect(request1, request2);
    expect(request1, isNot(request3));
    expect(request1.hashCode, request2.hashCode);
  });
}
