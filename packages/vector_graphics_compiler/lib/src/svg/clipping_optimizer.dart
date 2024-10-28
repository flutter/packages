// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'node.dart';
import 'visitor.dart';
import 'masking_optimizer.dart';
import '../../vector_graphics_compiler.dart';
import 'path_ops.dart' as path_ops;

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
    final ResolvedPathNode pathNode = child as ResolvedPathNode;
    final path_ops.Path clipPathOpsPath = toPathOpsPath(clipPath);
    final path_ops.Path pathPathOpsPath = toPathOpsPath(pathNode.path);
    final path_ops.Path intersection =
        clipPathOpsPath.applyOp(pathPathOpsPath, path_ops.PathOp.intersect);
    final Path newPath = toVectorGraphicsPath(intersection);
    final ResolvedPathNode newPathNode = ResolvedPathNode(
        paint: pathNode.paint, bounds: newPath.bounds(), path: newPath);

    clipPathOpsPath.dispose();
    pathPathOpsPath.dispose();
    intersection.dispose();

    return newPathNode;
  }

  @override
  _Result visitEmptyNode(Node node, void data) {
    final _Result _result = _Result(node);
    return _result;
  }

  /// Visits applies optimizer to all children of ResolvedClipNode.
  _Result visitChildren(Node node, _Result data) {
    if (node is ResolvedClipNode) {
      data = node.child.accept(this, data);
    }
    return data;
  }

  @override
  _Result visitParentNode(ParentNode parentNode, Node data) {
    final List<Node> newChildren = <Node>[];
    bool deleteClipNode = true;

    for (Node child in parentNode.children) {
      final _Result childResult = child.accept(this, parentNode);
      newChildren.add(childResult.node);
      if (childResult.deleteClipNode == false) {
        deleteClipNode = false;
      }
    }

    final ParentNode newParentNode = ParentNode(parentNode.attributes,
        precalculatedTransform: parentNode.transform, children: newChildren);

    final _Result _result = _Result(newParentNode);

    _result.deleteClipNode = deleteClipNode;
    return _result;
  }

  @override
  _Result visitMaskNode(MaskNode maskNode, Node data) {
    final _Result _result = _Result(maskNode);
    return _result;
  }

  @override
  _Result visitPathNode(PathNode pathNode, Node data) {
    final _Result _result = _Result(pathNode);
    return _result;
  }

  @override
  _Result visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    final _Result childResult = maskNode.child.accept(this, maskNode);
    final ResolvedMaskNode newMaskNode = ResolvedMaskNode(
        child: childResult.node,
        mask: maskNode.mask,
        blendMode: maskNode.blendMode);
    final _Result _result = _Result(newMaskNode);
    _result.children.add(childResult.node);
    _result.childCount = 1;

    return _result;
  }

  @override
  _Result visitResolvedClipNode(ResolvedClipNode clipNode, Node data) {
    _Result _result = _Result(clipNode);

    Path? singleClipPath;
    if (clipNode.clips.length == 1) {
      singleClipPath = clipNode.clips.single;
    }

    if (singleClipPath != null) {
      clipsToApply.add(singleClipPath);
      final _Result childResult = clipNode.child.accept(this, clipNode);
      clipsToApply.removeLast();

      if (childResult.deleteClipNode == true) {
        _result = _Result(childResult.node);
      } else {
        final ResolvedClipNode newClipNode =
            ResolvedClipNode(child: childResult.node, clips: clipNode.clips);
        _result = _Result(newClipNode);
      }
    } else {
      final _Result childResult = clipNode.child.accept(this, clipNode);
      final ResolvedClipNode newClipNode =
          ResolvedClipNode(child: childResult.node, clips: clipNode.clips);
      _result = _Result(newClipNode);
    }
    return _result;
  }

  @override
  _Result visitResolvedPath(ResolvedPathNode pathNode, Node data) {
    _Result _result = _Result(pathNode);
    bool hasStrokeWidth = false;
    bool deleteClipNode = true;

    if (pathNode.paint.stroke?.width != null) {
      hasStrokeWidth = true;
      _result.deleteClipNode = false;
    }

    if (clipsToApply.isNotEmpty && !hasStrokeWidth) {
      ResolvedPathNode newPathNode = pathNode;
      for (Path clipPath in clipsToApply) {
        final ResolvedPathNode intersection = applyClip(newPathNode, clipPath);
        if (intersection.path.commands.isNotEmpty) {
          newPathNode = intersection;
        } else {
          _result = _Result(pathNode);
          _result.deleteClipNode = false;
          deleteClipNode = false;
          break;
        }
      }
      _result = _Result(newPathNode);
      _result.deleteClipNode = deleteClipNode;
    }
    return _result;
  }

  @override
  _Result visitResolvedText(ResolvedTextNode textNode, Node data) {
    final _Result _result = _Result(textNode);
    return _result;
  }

  @override
  _Result visitResolvedVerticesNode(
      ResolvedVerticesNode verticesNode, Node data) {
    final _Result _result = _Result(verticesNode);
    return _result;
  }

  @override
  _Result visitSaveLayerNode(SaveLayerNode layerNode, Node data) {
    final List<Node> newChildren = <Node>[];
    for (Node child in layerNode.children) {
      final _Result childResult = child.accept(this, layerNode);
      newChildren.add(childResult.node);
    }
    final SaveLayerNode newLayerNode = SaveLayerNode(layerNode.attributes,
        paint: layerNode.paint, children: newChildren);

    final _Result _result = _Result(newLayerNode);
    _result.children = newChildren;
    _result.childCount = newChildren.length;
    return _result;
  }

  @override
  _Result visitViewportNode(ViewportNode viewportNode, void data) {
    final List<Node> children = <Node>[];
    for (Node child in viewportNode.children) {
      final _Result childNode = child.accept(this, viewportNode);
      children.add(childNode.node);
    }

    final ViewportNode node = ViewportNode(
      viewportNode.attributes,
      width: viewportNode.width,
      height: viewportNode.height,
      transform: viewportNode.transform,
      children: children,
    );

    final _Result _result = _Result(node);
    _result.children = children;
    _result.childCount = children.length;
    return _result;
  }

  @override
  _Result visitResolvedImageNode(
      ResolvedImageNode resolvedImageNode, Node data) {
    final _Result _result = _Result(resolvedImageNode);
    _result.deleteClipNode = false;
    return _result;
  }

  @override
  _Result visitResolvedPatternNode(ResolvedPatternNode patternNode, Node data) {
    return _Result(patternNode);
  }

  @override
  _Result visitResolvedTextPositionNode(
      ResolvedTextPositionNode textPositionNode, void data) {
    return _Result(
      ResolvedTextPositionNode(
        textPositionNode.textPosition,
        <Node>[
          for (Node child in textPositionNode.children)
            child.accept(this, data).node
        ],
      ),
    );
  }
}
