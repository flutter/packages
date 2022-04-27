// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:vector_graphics_compiler/src/geometry/basic_types.dart';
import 'package:vector_graphics_compiler/src/geometry/matrix.dart';
import 'package:vector_graphics_compiler/src/geometry/path.dart';
import 'package:vector_graphics_compiler/src/paint.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/src/svg/resolver.dart';

import 'helpers.dart';

void main() {
  test(
      'Resolves PathNodes to ResolvedPathNodes by flattening the transform '
      'and computing bounds', () async {
    final Node node = await parseToNodeTree('''
<svg viewBox="0 0 200 200">
  <g transform="translate(10, 10)">
    <rect x="0" y="0" width="10" height="10" fill="white" />
  </g>
</svg>''');
    final Node resolvedNode =
        node.accept(ResolvingVisitor(), AffineMatrix.identity);
    final List<ResolvedPathNode> nodes =
        queryChildren<ResolvedPathNode>(resolvedNode);

    expect(nodes.length, 1);

    final ResolvedPathNode resolvedPathNode = nodes[0];

    expect(resolvedPathNode.bounds, const Rect.fromLTWH(10, 10, 10, 10));
    expect(
      resolvedPathNode.path,
      Path(
        commands: const <PathCommand>[
          MoveToCommand(10.0, 10.0),
          LineToCommand(20.0, 10.0),
          LineToCommand(20.0, 20.0),
          LineToCommand(10.0, 20.0),
          CloseCommand(),
        ],
      ),
    );
  });

  test('Resolving Nodes replaces empty text with Node.zero', () async {
    final Node node = await parseToNodeTree('''
  <svg viewBox="0 0 200 200">
    <text></text>
  </svg>''');
    final Node resolvedNode =
        node.accept(ResolvingVisitor(), AffineMatrix.identity);
    final List<ResolvedTextNode> nodes =
        queryChildren<ResolvedTextNode>(resolvedNode);

    expect(nodes, isEmpty);
  });

  test('Resolving Nodes removes unresolved masks', () async {
    final Node node = await parseToNodeTree('''
<svg viewBox="0 0 200 200">
  <g mask="foo">
    <rect x="0" y="0" width="100" height="100" fill="white" />
  </g>
</svg>''');

    final Node resolvedNode =
        node.accept(ResolvingVisitor(), AffineMatrix.identity);
    final List<ResolvedMaskNode> nodes =
        queryChildren<ResolvedMaskNode>(resolvedNode);

    expect(nodes, isEmpty);
  });

  test('visitChildren on clips and masks', () {
    final ResolvedClipNode clip = ResolvedClipNode(
      clips: <Path>[],
      child: Node.empty,
    );

    final ResolvedMaskNode mask = ResolvedMaskNode(
      child: Node.empty,
      mask: Node.empty,
      blendMode: BlendMode.color,
    );

    int visitCount = 0;
    clip.visitChildren((Node child) {
      visitCount += 1;
      expect(child, Node.empty);
    });
    mask.visitChildren((Node child) {
      visitCount += 1;
      expect(child, Node.empty);
    });

    expect(visitCount, 2);
  });
}
