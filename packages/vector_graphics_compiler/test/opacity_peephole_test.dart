// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:vector_graphics_compiler/src/geometry/matrix.dart';
import 'package:vector_graphics_compiler/src/paint.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/opacity_peephole.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/src/svg/resolver.dart';

List<T> queryChildren<T extends Node>(Node node) {
  final List<T> children = <T>[];
  void visitor(Node child) {
    if (child is T) {
      children.add(child);
    }
    child.visitChildren(visitor);
  }

  node.visitChildren(visitor);
  return children;
}

Future<Node> parseAndResolve(String source) async {
  final Node node = await parseToNodeTree(source);
  final ResolvingVisitor visitor = ResolvingVisitor();
  return node.accept(visitor, AffineMatrix.identity);
}

void main() {
  test('Applies opacity to single child path', () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5">
    <rect x="0" y="0" width="10" height="10" fill="white" />
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final ResolvedPathNode pathNode =
        queryChildren<ResolvedPathNode>(newNode).single;

    expect(pathNode.paint.fill?.color, const Color(0x7fffffff));
  });

  test('Applies opacity and blend mode to single child path', () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5" style="mix-blend-mode:color-burn">
    <rect x="0" y="0" width="10" height="10" fill="white" />
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final ResolvedPathNode pathNode =
        queryChildren<ResolvedPathNode>(newNode).single;

    expect(pathNode.paint.fill?.color, const Color(0x7fffffff));
    expect(pathNode.paint.blendMode, BlendMode.colorBurn);
  });

  test('Applies opacity to non-overlapping child paths', () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5">
    <rect x="0" y="0" width="10" height="10" fill="white" />
    <rect x="30" y="40" width="10" height="10" fill="white" />
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final List<ResolvedPathNode> pathNodes =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodes[0].paint.fill?.color, const Color(0x7fffffff));
    expect(pathNodes[1].paint.fill?.color, const Color(0x7fffffff));
  });

  test(
      'Does not apply opacity and blend mode to single child path with own blend mode',
      () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5" style="mix-blend-mode:color-burn">
    <rect x="0" y="0" width="10" height="10" fill="white" style="mix-blend-mode:darken"/>
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final ResolvedPathNode pathNode =
        queryChildren<ResolvedPathNode>(newNode).single;

    expect(pathNode.paint.fill?.color, const Color(0xffffffff));
    expect(pathNode.paint.blendMode, BlendMode.darken);
  });

  test('Does not apply opacity to overlapping child paths', () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5">
    <rect x="0" y="0" width="10" height="10" fill="white" />
    <rect x="5" y="5" width="10" height="10" fill="white" />
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final List<ResolvedPathNode> pathNodes =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodes[0].paint.fill?.color, const Color(0xffffffff));
    expect(pathNodes[1].paint.fill?.color, const Color(0xffffffff));
  });

  test('Does not apply opacity to text nodes', () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5">
    <text x="0" y="0" fill="white">Hello</text>
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final ResolvedTextNode textNode =
        queryChildren<ResolvedTextNode>(newNode).single;

    expect(textNode.paint.fill?.color, const Color(0xffffffff));
  });

  test('Collapses nested opacity groups multiplicatively', () async {
    final Node node = await parseAndResolve('''
<svg viewBox="0 0 200 200">
  <g opacity="0.5">
    <g opacity="0.3">
      <g opacity="0.2">
        <rect x="0" y="0" width="10" height="10" fill="white" />
      </g>
    </g>
  </g>
</svg>''');

    final OpacityPeepholeOptimizer visitor = OpacityPeepholeOptimizer();
    final Node newNode = visitor.apply(node);
    final ResolvedPathNode textNode =
        queryChildren<ResolvedPathNode>(newNode).single;

    expect(textNode.paint.fill?.color, const Color(0x07ffffff));
  });
}
