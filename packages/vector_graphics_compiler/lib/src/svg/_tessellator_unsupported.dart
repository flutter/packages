// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'node.dart';
import 'resolver.dart';
import 'tessellator.dart' as api;
import 'visitor.dart';

/// Whether or not tesselation should be used.
bool get isTesselatorInitialized => false;

/// Initialize the libtesselator dynamic library.
///
/// This method must be called before [VerticesBuilder] can be used or
/// constructed.
void initializeLibTesselator(String path) {}

/// A visitor that replaces fill paths with tesselated vertices.
class Tessellator extends Visitor<Node, void>
    with ErrorOnUnResolvedNode<Node, void>
    implements api.Tessellator {
  @override
  Node visitEmptyNode(Node node, void data) {
    return node;
  }

  @override
  Node visitParentNode(ParentNode parentNode, void data) {
    return parentNode;
  }

  @override
  Node visitResolvedClipNode(ResolvedClipNode clipNode, void data) {
    return clipNode;
  }

  @override
  Node visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    return maskNode;
  }

  @override
  Node visitResolvedPath(ResolvedPathNode pathNode, void data) {
    return pathNode;
  }

  @override
  Node visitResolvedText(ResolvedTextNode textNode, void data) {
    return textNode;
  }

  @override
  Node visitSaveLayerNode(SaveLayerNode layerNode, void data) {
    return layerNode;
  }

  @override
  Node visitViewportNode(ViewportNode viewportNode, void data) {
    return viewportNode;
  }

  @override
  Node visitResolvedVerticesNode(ResolvedVerticesNode verticesNode, void data) {
    return verticesNode;
  }

  @override
  Node visitResolvedImageNode(ResolvedImageNode resolvedImageNode, void data) {
    return resolvedImageNode;
  }

  @override
  Node visitResolvedPatternNode(ResolvedPatternNode patternNode, void data) {
    return patternNode;
  }

  @override
  Node visitResolvedTextPositionNode(
      ResolvedTextPositionNode textPositionNode, void data) {
    return textPositionNode;
  }
}
