// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_unit_tests/null_safe_pigeon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('with values filled', () {
    final SearchReply reply = SearchReply()
      ..result = 'foo'
      ..error = 'bar';
    final Object encoded = reply.encode();
    final SearchReply decoded = SearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });

  test('with null value', () {
    final SearchReply reply = SearchReply()
      ..result = 'foo'
      ..error = null;
    final Object encoded = reply.encode();
    final SearchReply decoded = SearchReply.decode(encoded);
    expect(reply.result, decoded.result);
    expect(reply.error, decoded.error);
  });
}
