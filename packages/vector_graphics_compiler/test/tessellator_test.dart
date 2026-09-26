// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/src/svg/tessellator.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    if (!initializeTessellatorFromFlutterCache()) {
      fail('error in setup');
    }
  });

  test('Can convert simple shape to indexed vertices', () async {
    final Node node = parseToNodeTree('''
<svg viewBox="0 0 200 200">
  <rect x="0" y="0" width="10" height="10" fill="white" />
</svg>''');
    Node resolvedNode = node.accept(ResolvingVisitor(), AffineMatrix.identity);
    resolvedNode = resolvedNode.accept(Tessellator(), null);

    final ResolvedVerticesNode verticesNode = queryChildren<ResolvedVerticesNode>(
      resolvedNode,
    ).single;

    expect(verticesNode.bounds, const Rect.fromLTWH(0, 0, 10, 10));
    expect(verticesNode.vertices.vertices, <double>[
      0.0,
      10.0,
      10.0,
      0.0,
      10.0,
      10.0,
      10.0,
      0.0,
      0.0,
      10.0,
      0.0,
      0.0,
    ]);
    expect(verticesNode.vertices.indices, null);
  });

  test('Preserves filterBlurX and filterBlurY on tessellated fill and stroke', () {
    const svg = '''
<svg viewBox="0 0 200 200">
  <filter id="blur">
    <feGaussianBlur stdDeviation="4 6" />
  </filter>
  <rect x="0" y="0" width="10" height="10" fill="white" stroke="black" stroke-width="2" filter="url(#blur)" />
</svg>''';
    final VectorInstructions instructions = parseWithoutOptimizers(svg);
    expect(
      instructions.paints,
      containsAll(const <Paint>[
        Paint(fill: Fill(color: Color(0xffffffff)), filterBlurX: 4.0, filterBlurY: 6.0),
        Paint(
          stroke: Stroke(color: Color(0xff000000), width: 2.0),
          filterBlurX: 4.0,
          filterBlurY: 6.0,
        ),
      ]),
    );
  });
}
