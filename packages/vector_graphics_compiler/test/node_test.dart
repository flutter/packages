// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('TextNode returns null for Paint if stroke and fill are missing', () {
    final TextNode node = TextNode(
      'text',
      SvgAttributes.empty,
    );
    expect(node.computePaint(Rect.largest, AffineMatrix.identity), null);
  });

  test('PathNode returns null for Paint if stroke and fill are missing', () {
    final PathNode node = PathNode(
      Path(),
      SvgAttributes.empty,
    );
    expect(node.computePaint(Rect.largest, AffineMatrix.identity), null);
  });
}
