// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('TextPosition uses computed transform', () {
    final TextPositionNode node = TextPositionNode(
      SvgAttributes.forTest(
        x: DoubleOrPercentage.fromString('5'),
        y: DoubleOrPercentage.fromString('3'),
        dx: DoubleOrPercentage.fromString('2'),
        dy: DoubleOrPercentage.fromString('1'),
        transform: AffineMatrix.identity.translated(10, 10),
      ),
      reset: false,
    );

    final TextPosition position = node.computeTextPosition(
      const Rect.fromLTWH(0, 0, 500, 500),
      AffineMatrix.identity,
    );

    expect(position.x, 15);
    expect(position.y, 13);
    expect(position.dx, 12);
    expect(position.dy, 11);
  });

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
