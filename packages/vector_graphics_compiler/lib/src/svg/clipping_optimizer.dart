// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../vector_graphics_compiler.dart';
import 'masking_optimizer.dart';
import 'node.dart';
import 'path_ops.dart' as path_ops;
import 'visitor.dart';

class _Result {
  _Result(this.node);

  final Node node;
  int childCount = 0;
  List<Node> children = <Node>[];
  Node parent = Node.empty;
  bool deleteClipNode = true;
}

/// Applies and removes trivial cases of clipping.
/// This will not optimize cases where 'stroke-width' is set,
/// there are multiple path nodes in ResolvedClipNode.clips
/// or cases where the intersection of the clip and the path
/// results in Path.commands being empty.
class ClippingOptimizer extends Visitor<_Result, Node>
    with ErrorOnUnResolvedNode<_Result, Node> {
  ///List of clips to apply.
  final List<Path> clipsToApply = <Path>[];

  /// Applies visitor to given node.
  Node apply(Node node) {
    final Node newNode = node.accept(this, null).node;
    return newNode;
  }

  /// Applies clip to a path node, and returns resulting path node.
  ResolvedPathNode applyClip(Node child, Path clipPath) {
    final pathNode = child as ResolvedPathNode;
    final path_ops.Path clipPathOpsPath = toPathOpsPath(clipPath);
    final path_ops.Path pathPathOpsPath = toPathOpsPath(pathNode.path);
    final path_ops.Path intersection = clipPathOpsPath.applyOp(
      pathPathOpsPath,
      path_ops.PathOp.intersect,
    );
    final Path newPath = toVectorGraphicsPath(intersection);
    final newPathNode = ResolvedPathNode(
      paint: pathNode.paint,
      bounds: newPath.bounds(),
      path: newPath,
    );

    clipPathOpsPath.dispose();
    pathPathOpsPath.dispose();
    intersection.dispose();

    return newPathNode;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitEmptyNode(Node node, void data) {
    final result = _Result(node);
    return result;
  }

  /// Visits applies optimizer to all children of ResolvedClipNode.
  // ignore: library_private_types_in_public_api
  _Result visitChildren(Node node, _Result data) {
    if (node is ResolvedClipNode) {
      data = node.child.accept(this, data);
    }
    return data;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitParentNode(ParentNode parentNode, Node data) {
    final newChildren = <Node>[];
    var deleteClipNode = true;

    for (final Node child in parentNode.children) {
      final _Result childResult = child.accept(this, parentNode);
      newChildren.add(childResult.node);
      if (!childResult.deleteClipNode) {
        deleteClipNode = false;
      }
    }

    final newParentNode = ParentNode(
      parentNode.attributes,
      precalculatedTransform: parentNode.transform,
      children: newChildren,
    );

    final result = _Result(newParentNode);

    result.deleteClipNode = deleteClipNode;
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitMaskNode(MaskNode maskNode, Node data) {
    final result = _Result(maskNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitPathNode(PathNode pathNode, Node data) {
    final result = _Result(pathNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    final _Result childResult = maskNode.child.accept(this, maskNode);
    final newMaskNode = ResolvedMaskNode(
      child: childResult.node,
      mask: maskNode.mask,
      blendMode: maskNode.blendMode,
    );
    final result = _Result(newMaskNode);
    result.children.add(childResult.node);
    result.childCount = 1;

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedClipNode(ResolvedClipNode clipNode, Node data) {
    var result = _Result(clipNode);

    Path? singleClipPath;
    if (clipNode.clips.length == 1) {
      singleClipPath = clipNode.clips.single;
    }

    if (singleClipPath != null) {
      clipsToApply.add(singleClipPath);
      final _Result childResult = clipNode.child.accept(this, clipNode);
      clipsToApply.removeLast();

      if (childResult.deleteClipNode) {
        result = _Result(childResult.node);
      } else {
        final newClipNode = ResolvedClipNode(
          child: childResult.node,
          clips: clipNode.clips,
        );
        result = _Result(newClipNode);
      }
    } else {
      final _Result childResult = clipNode.child.accept(this, clipNode);
      final newClipNode = ResolvedClipNode(
        child: childResult.node,
        clips: clipNode.clips,
      );
      result = _Result(newClipNode);
    }
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedPath(ResolvedPathNode pathNode, Node data) {
    var result = _Result(pathNode);
    var hasStrokeWidth = false;
    var deleteClipNode = true;

    if (pathNode.paint.stroke?.width != null) {
      hasStrokeWidth = true;
      result.deleteClipNode = false;
    }

    if (clipsToApply.isNotEmpty && !hasStrokeWidth) {
      var newPathNode = pathNode;
      for (final Path clipPath in clipsToApply) {
        final ResolvedPathNode intersection = applyClip(newPathNode, clipPath);
        if (intersection.path.commands.isNotEmpty) {
          newPathNode = intersection;
        } else {
          result = _Result(pathNode);
          result.deleteClipNode = false;
          deleteClipNode = false;
          break;
        }
      }
      result = _Result(newPathNode);
      result.deleteClipNode = deleteClipNode;
    }
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedText(ResolvedTextNode textNode, Node data) {
    final result = _Result(textNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedVerticesNode(
    ResolvedVerticesNode verticesNode,
    Node data,
  ) {
    final result = _Result(verticesNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitSaveLayerNode(SaveLayerNode layerNode, Node data) {
    final newChildren = <Node>[];
    for (final Node child in layerNode.children) {
      final _Result childResult = child.accept(this, layerNode);
      newChildren.add(childResult.node);
    }
    final newLayerNode = SaveLayerNode(
      layerNode.attributes,
      paint: layerNode.paint,
      children: newChildren,
    );

    final result = _Result(newLayerNode);
    result.children = newChildren;
    result.childCount = newChildren.length;
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitViewportNode(ViewportNode viewportNode, void data) {
    final children = <Node>[];
    for (final Node child in viewportNode.children) {
      final _Result childNode = child.accept(this, viewportNode);
      children.add(childNode.node);
    }

    final node = ViewportNode(
      viewportNode.attributes,
      width: viewportNode.width,
      height: viewportNode.height,
      transform: viewportNode.transform,
      children: children,
    );

    final result = _Result(node);
    result.children = children;
    result.childCount = children.length;
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedImageNode(
    ResolvedImageNode resolvedImageNode,
    Node data,
  ) {
    final result = _Result(resolvedImageNode);
    result.deleteClipNode = false;
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedPatternNode(ResolvedPatternNode patternNode, Node data) {
    return _Result(patternNode);
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedTextPositionNode(
    ResolvedTextPositionNode textPositionNode,
    void data,
  ) {
    return _Result(
      ResolvedTextPositionNode(textPositionNode.textPosition, <Node>[
        for (final Node child in textPositionNode.children)
          child.accept(this, data).node,
      ]),
    );
  }
}
