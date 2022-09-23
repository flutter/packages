// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:vector_graphics_compiler/src/isolate_processor.dart';

void main() {
  test('Can run with isolate processor', () async {
    final File output = File('test_data/example.vec');
    try {
      final IsolateProcessor processor = IsolateProcessor(null, null, 4);
      final bool result = await processor.process(
        <Pair>[
          Pair('test_data/example.svg', output.path),
        ],
        maskingOptimizerEnabled: false,
        clippingOptimizerEnabled: false,
        overdrawOptimizerEnabled: false,
        tessellate: false,
      );
      expect(result, isTrue);
      expect(output.existsSync(), isTrue);
    } finally {
      if (output.existsSync()) {
        output.deleteSync();
      }
    }
  });
}
