// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/draw_command_builder.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('DrawCommandBuilder does not emit empty paths', () {
    final DrawCommandBuilder builder = DrawCommandBuilder();
    builder.addPath(Path(), const Paint(), null, null);
    expect(builder.toInstructions(100, 100).commands, isEmpty);
  });
}
