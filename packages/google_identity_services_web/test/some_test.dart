// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser') // Uses package:js

import 'package:test/test.dart';

void main() {
  group('Group', () {
    test('test', () async {
      expect(true, isTrue);
    });
  });
}
