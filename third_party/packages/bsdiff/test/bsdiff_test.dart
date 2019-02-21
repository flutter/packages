// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:bsdiff/bsdiff.dart';
import 'package:test/test.dart';

void main() {
  test('roundtrip', () {
    final Uint8List a = Uint8List.fromList('Hello'.runes.toList());
    final Uint8List b = Uint8List.fromList('Hello World'.runes.toList());
    final Uint8List c = bsdiff(a, b);
    expect(bspatch(a, c), equals(b));
  });
}
