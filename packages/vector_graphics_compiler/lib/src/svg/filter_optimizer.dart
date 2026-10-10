// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'node.dart';
import 'parser.dart';
import 'resolver.dart';

/// Optimizes independent subtrees without crossing filter source boundaries.
///
/// A filter needs the original source geometry even where no pixels are painted.
/// Surrounding masks, clips, patterns and opacity layers retain their structure.
Node optimizeFilterSubtrees(Node root, Node Function(Node) optimize) {
  final filtered = Map<Node, bool>.identity();
  bool hasFilter(Node node) => filtered.putIfAbsent(node, () {
    if (node is FilterNode) {
      return true;
    }
    var result = false;
    node.visitChildren((Node child) => result |= hasFilter(child));
    if (node is ResolvedMaskNode) {
      result |= hasFilter(node.mask);
    }
    if (node is ResolvedPatternNode) {
      result |= hasFilter(node.pattern);
    }
    return result;
  });

  late Node Function(Node) visit;
  List<Node> children(Iterable<Node> source) {
    final result = <Node>[];
    var run = <Node>[];
    void flush() {
      if (run.isNotEmpty) {
        result.add(optimize(ParentNode(SvgAttributes.empty, children: run)));
        run = <Node>[];
      }
    }

    for (final child in source) {
      if (hasFilter(child)) {
        flush();
        result.add(visit(child));
      } else {
        run.add(child);
      }
    }
    flush();
    return result;
  }

  visit = (Node node) {
    if (!hasFilter(node)) {
      return optimize(node);
    }
    return switch (node) {
      FilterNode() => node,
      ViewportNode() => ViewportNode(
        node.attributes,
        width: node.width,
        height: node.height,
        transform: node.transform,
        children: children(node.children),
      ),
      SaveLayerNode() => SaveLayerNode(
        node.attributes,
        paint: node.paint,
        children: children(node.children),
      ),
      ParentNode() => ParentNode(
        node.attributes,
        precalculatedTransform: node.transform,
        children: children(node.children),
      ),
      ResolvedClipNode() => ResolvedClipNode(clips: node.clips, child: visit(node.child)),
      ResolvedMaskNode() => ResolvedMaskNode(
        child: visit(node.child),
        mask: visit(node.mask),
        blendMode: node.blendMode,
      ),
      ResolvedPatternNode() => ResolvedPatternNode(
        child: visit(node.child),
        pattern: visit(node.pattern),
        x: node.x,
        y: node.y,
        width: node.width,
        height: node.height,
        transform: node.transform,
        id: node.id,
      ),
      ResolvedTextPositionNode() => ResolvedTextPositionNode(
        node.textPosition,
        children(node.children),
      ),
      _ => throw StateError('Unexpected parent of an SVG filter: ${node.runtimeType}'),
    };
  };
  return visit(root);
}
