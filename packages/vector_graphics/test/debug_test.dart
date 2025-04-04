// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/debug.dart';

void main() {
  test('debugSkipRaster is false by default', () {
    expect(debugSkipRaster, false);
  });
}
