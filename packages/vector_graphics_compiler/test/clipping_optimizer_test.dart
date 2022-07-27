// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/clipping_optimizer.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/src/svg/resolver.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';
import 'test_svg_strings.dart';

Future<Node> parseAndResolve(String source) async {
  final Node node = await parseToNodeTree(source);
  final ResolvingVisitor visitor = ResolvingVisitor();
  return node.accept(visitor, AffineMatrix.identity);
}

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

void main() {
  setUpAll(() {
    if (!initializePathOpsFromFlutterCache()) {
      fail('error in setup');
    }
  });
  test('Only resolve ClipNode if .clips has one PathNode', () async {
    final Node node = await parseAndResolve(
        ''' <svg width="200px" height="200x" viewBox="0 0 200 200">
  <defs>
    <clipPath id="a">
      <rect x="0" y="0" width="200" height="100" />
    </clipPath>
  </defs>

  <circle cx="100" cy="100" r="100" clip-path="url(#a)" fill="white" />
</svg>''');

    final ClippingOptimizer visitor = ClippingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedClipNode> clipNodesNew =
        queryChildren<ResolvedClipNode>(newNode);

    expect(clipNodesNew.length, 0);
  });

  test(
      "Don't resolve a ClipNode if one of the PathNodes it's applied to has stroke.width set",
      () async {
    final Node node = await parseAndResolve(''' <svg width="10" height="10">
  <clipPath id="clip0">
    <path d="M2 3h7.9v2H1" />
  </clipPath>
  <path d="M2, 5L8,6" stroke="black" stroke-linecap="round" stroke-width="2" clip-path="url(#clip0)" />
</svg>''');

    final ClippingOptimizer visitor = ClippingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedClipNode> clipNodesNew =
        queryChildren<ResolvedClipNode>(newNode);

    expect(clipNodesNew.length, 1);
  });

  test("Don't resolve ClipNode if intersection of Clip and Path is empty",
      () async {
    final Node node = await parseAndResolve(
        '''<svg width="200px" height="200x" viewBox="0 0 200 200">
  <defs>
    <clipPath id="a">
      <rect x="300" y="300" width="200" height="100" />
    </clipPath>
  </defs>
  <path clip-path="url(#a)" d="M0 0 z"/>
</svg>

''');
    final ClippingOptimizer visitor = ClippingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedClipNode> clipNodesNew =
        queryChildren<ResolvedClipNode>(newNode);

    expect(clipNodesNew.length, 1);
  });

  test('ParentNode and PathNode count should stay the same', () async {
    final Node node = await parseAndResolve(pathAndParent);

    final List<ResolvedPathNode> pathNodesOld =
        queryChildren<ResolvedPathNode>(node);
    final List<ParentNode> parentNodesOld = queryChildren<ParentNode>(node);

    final ClippingOptimizer visitor = ClippingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);
    final List<ParentNode> parentNodesNew = queryChildren<ParentNode>(newNode);

    expect(pathNodesOld.length, pathNodesNew.length);
    expect(parentNodesOld.length, parentNodesNew.length);
  });
}
