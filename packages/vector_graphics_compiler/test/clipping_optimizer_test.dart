// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/clipping_optimizer.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'test_svg_strings.dart';

Node parseAndResolve(String source) {
  final Node node = parseToNodeTree(source);
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

  test('Only resolve ClipNode if .clips has one PathNode', () {
    final Node node = parseAndResolve('''
 <svg width="200px" height="200x" viewBox="0 0 200 200">
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
    final Node node = parseAndResolve('''
 <svg width="10" height="10">
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
    final Node node = parseAndResolve('''
<svg width="200px" height="200x" viewBox="0 0 200 200">
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
    final Node node = parseAndResolve(pathAndParent);

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

  test('Does not combine clips with multiple fill rules', () {
    final VectorInstructions instructions = parse(multiClip);
    expect(instructions.paths, <Path>[
      parseSvgPathData(
          'M 250,75 L 323,301 131,161 369,161 177,301 z', PathFillType.evenOdd),
      PathBuilder().addOval(const Rect.fromCircle(400, 200, 150)).toPath(),
      parseSvgPathData('M 250,75 L 323,301 131,161 369,161 177,301 z')
          .transformed(AffineMatrix.identity.translated(250, 0)),
      PathBuilder().addOval(const Rect.fromCircle(450, 300, 150)).toPath(),
    ]);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.clip, objectId: 0),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.clip, objectId: 2),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.clip, objectId: 0),
      DrawCommand(DrawCommandType.path, objectId: 3, paintId: 1),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.clip, objectId: 2),
      DrawCommand(DrawCommandType.path, objectId: 3, paintId: 1),
      DrawCommand(DrawCommandType.restore),
    ]);
  });

  test('Combines clips where possible', () {
    final VectorInstructions instructions =
        parse(basicClip, enableClippingOptimizer: false);
    final VectorInstructions instructionsWithOptimizer = parse(basicClip);

    expect(instructionsWithOptimizer.paths, basicClipsForClippingOptimzer);

    expect(instructions.paths, <Path>[
      PathBuilder()
          .addOval(const Rect.fromCircle(30, 30, 20))
          .addOval(const Rect.fromCircle(70, 70, 20))
          .toPath(),
      PathBuilder().addRect(const Rect.fromLTWH(10, 10, 100, 100)).toPath(),
    ]);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.clip, objectId: 0),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 0),
      DrawCommand(DrawCommandType.restore),
    ]);
  });

  test('Preserves fill type changes', () {
    const String svg = '''
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
    <g clip-path="url(#a)">
        <path fill-rule="evenodd" clip-rule="evenodd" d="M9.99 0C4.47 0 0 4.48 0 10s4.47 10 9.99 10C15.52 20 20 15.52 20 10S15.52 0 9.99 0zM11 11V5H9v6h2zm0 4v-2H9v2h2zm-9-5c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8-8 3.58-8 8z" fill="black" />
    </g>
    <defs>
        <clipPath id="a">
            <path fill="#fff" d="M0 0h20v20H0z" />
        </clipPath>
    </defs>
</svg>''';
    final VectorInstructions instructions = parse(svg);

    expect(
      instructions.paths.single.fillType,
      PathFillType.evenOdd,
    );
  });
}
