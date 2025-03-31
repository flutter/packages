// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import '../../vector_graphics_compiler.dart';
import 'node.dart';
import 'path_ops.dart' as path_ops;
import 'visitor.dart';

class _Result {
  _Result(this.node, {this.deleteMaskNode = true});

  final Node node;
  final List<Node> children = <Node>[];
  Node parent = Node.empty;
  final bool deleteMaskNode;
}

/// Converts a vector_graphics PathFillType to a path_ops FillType.
path_ops.FillType toPathOpsFillTyle(PathFillType fill) {
  switch (fill) {
    case PathFillType.evenOdd:
      return path_ops.FillType.evenOdd;

    case PathFillType.nonZero:
      return path_ops.FillType.nonZero;
  }
}

/// Converts a path_ops FillType to a vector_graphics PathFillType
PathFillType toVectorGraphicsFillType(path_ops.FillType fill) {
  switch (fill) {
    case path_ops.FillType.evenOdd:
      return PathFillType.evenOdd;

    case path_ops.FillType.nonZero:
      return PathFillType.nonZero;
  }
}

/// Converts vector_graphics Path to path_ops Path.
path_ops.Path toPathOpsPath(Path path) {
  final path_ops.Path newPath = path_ops.Path(toPathOpsFillTyle(path.fillType));

  for (final PathCommand command in path.commands) {
    switch (command.type) {
      case PathCommandType.line:
        final LineToCommand lineToCommand = command as LineToCommand;
        newPath.lineTo(lineToCommand.x, lineToCommand.y);
      case PathCommandType.cubic:
        final CubicToCommand cubicToCommand = command as CubicToCommand;
        newPath.cubicTo(cubicToCommand.x1, cubicToCommand.y1, cubicToCommand.x2,
            cubicToCommand.y2, cubicToCommand.x3, cubicToCommand.y3);
      case PathCommandType.move:
        final MoveToCommand moveToCommand = command as MoveToCommand;
        newPath.moveTo(moveToCommand.x, moveToCommand.y);
      case PathCommandType.close:
        newPath.close();
    }
  }

  return newPath;
}

/// Converts path_ops Path to VectorGraphicsPath.
Path toVectorGraphicsPath(path_ops.Path path) {
  final List<PathCommand> newCommands = <PathCommand>[];

  int index = 0;
  final Float32List points = path.points;
  for (final path_ops.PathVerb verb in path.verbs.toList()) {
    switch (verb) {
      case path_ops.PathVerb.moveTo:
        newCommands.add(MoveToCommand(points[index++], points[index++]));
      case path_ops.PathVerb.lineTo:
        newCommands.add(LineToCommand(points[index++], points[index++]));
      case path_ops.PathVerb.quadTo:
        final double cpX = points[index++];
        final double cpY = points[index++];
        newCommands.add(CubicToCommand(
          cpX,
          cpY,
          cpX,
          cpY,
          points[index++],
          points[index++],
        ));
      case path_ops.PathVerb.cubicTo:
        newCommands.add(CubicToCommand(
          points[index++],
          points[index++],
          points[index++],
          points[index++],
          points[index++],
          points[index++],
        ));
      case path_ops.PathVerb.close:
        newCommands.add(const CloseCommand());
    }
  }

  final Path newPath = Path(
      commands: newCommands, fillType: toVectorGraphicsFillType(path.fillType));

  return newPath;
}

/// Gets the single child recursively,
/// returns null if there are 0 children or more than 1.
ResolvedPathNode? getSingleChild(Node node) {
  if (node is ResolvedPathNode) {
    return node;
  } else if (node is ParentNode && node.children.length == 1) {
    return getSingleChild(node.children.first);
  }
  return null;
}

/// Simplifies masking operations into PathNodes.
/// Note this will not optimize cases where 'stroke-width' is set,
/// there are multiple path nodes in a mask or cases where
/// the intersection of the mask and the path results in
/// Path.commands being empty.
class MaskingOptimizer extends Visitor<_Result, Node>
    with ErrorOnUnResolvedNode<_Result, Node> {
  /// List of masks to add.
  final List<ResolvedPathNode> masksToApply = <ResolvedPathNode>[];

  /// Applies visitor to given node.
  Node apply(Node node) {
    final Node newNode = node.accept(this, null).node;
    return newNode;
  }

  /// Applies mask to a path node, and returns resulting path node.
  ResolvedPathNode applyMask(
      ResolvedPathNode pathNode, ResolvedPathNode maskPathNode) {
    final path_ops.Path maskPathOpsPath = toPathOpsPath(maskPathNode.path);
    final path_ops.Path pathPathOpsPath = toPathOpsPath(pathNode.path);
    final path_ops.Path intersection =
        pathPathOpsPath.applyOp(maskPathOpsPath, path_ops.PathOp.intersect);
    final Path newPath = toVectorGraphicsPath(intersection);
    final ResolvedPathNode newPathNode = ResolvedPathNode(
        paint: pathNode.paint, bounds: maskPathNode.bounds, path: newPath);

    maskPathOpsPath.dispose();
    pathPathOpsPath.dispose();
    intersection.dispose();

    return newPathNode;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitEmptyNode(Node node, void data) {
    final _Result result = _Result(node);
    return result;
  }

  /// Visits applies optimizer to all children of ResolvedMaskNode.
  // ignore: library_private_types_in_public_api
  _Result visitChildren(Node node, _Result data) {
    if (node is ResolvedMaskNode) {
      data = node.child.accept(this, data);
    }
    return data;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitParentNode(ParentNode parentNode, Node data) {
    final List<Node> newChildren = <Node>[];

    for (final Node child in parentNode.children) {
      final _Result childResult = child.accept(this, parentNode);
      newChildren.add(childResult.node);
      if (!childResult.deleteMaskNode) {
        return _Result(parentNode, deleteMaskNode: false);
      }
    }

    final ParentNode newParentNode = ParentNode(parentNode.attributes,
        precalculatedTransform: parentNode.transform, children: newChildren);

    final _Result result = _Result(newParentNode);

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitMaskNode(MaskNode maskNode, Node data) {
    final _Result result = _Result(maskNode);

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitPathNode(PathNode pathNode, Node data) {
    final _Result result = _Result(pathNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    _Result result = _Result(maskNode);
    final ResolvedPathNode? singleMaskPathNode = getSingleChild(maskNode.mask);

    if (singleMaskPathNode != null) {
      masksToApply.add(singleMaskPathNode);
      final _Result childResult = maskNode.child.accept(this, maskNode);
      masksToApply.removeLast();

      if (childResult.deleteMaskNode) {
        result = _Result(childResult.node);
      } else {
        final ResolvedMaskNode newMaskNode = ResolvedMaskNode(
            child: childResult.node,
            mask: maskNode.mask,
            blendMode: maskNode.blendMode);
        result = _Result(newMaskNode);
      }
    } else {
      final _Result childResult = maskNode.child.accept(this, maskNode);
      final ResolvedMaskNode newMaskNode = ResolvedMaskNode(
          child: childResult.node,
          mask: maskNode.mask,
          blendMode: maskNode.blendMode);
      result = _Result(newMaskNode);
    }

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedClipNode(ResolvedClipNode clipNode, Node data) {
    final _Result childResult = clipNode.child.accept(this, clipNode);
    final ResolvedClipNode newClipNode =
        ResolvedClipNode(clips: clipNode.clips, child: childResult.node);
    final _Result result = _Result(newClipNode);
    result.children.add(childResult.node);

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedPath(ResolvedPathNode pathNode, Node data) {
    _Result result = _Result(pathNode);

    if (pathNode.paint.stroke?.width != null) {
      return _Result(pathNode, deleteMaskNode: false);
    }

    if (masksToApply.isNotEmpty) {
      ResolvedPathNode newPathNode = pathNode;
      for (final ResolvedPathNode maskPathNode in masksToApply) {
        final ResolvedPathNode intersection =
            applyMask(newPathNode, maskPathNode);
        if (intersection.path.commands.isNotEmpty) {
          newPathNode = intersection;
        } else {
          return _Result(pathNode, deleteMaskNode: false);
        }
      }
      result = _Result(newPathNode);
    }

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedText(ResolvedTextNode textNode, Node data) {
    final _Result result = _Result(textNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedVerticesNode(
      ResolvedVerticesNode verticesNode, Node data) {
    final _Result result = _Result(verticesNode);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitSaveLayerNode(SaveLayerNode layerNode, Node data) {
    final List<Node> newChildren = <Node>[];
    for (final Node child in layerNode.children) {
      final _Result childResult = child.accept(this, layerNode);
      newChildren.add(childResult.node);
    }
    final SaveLayerNode newLayerNode = SaveLayerNode(layerNode.attributes,
        paint: layerNode.paint, children: newChildren);

    final _Result result = _Result(newLayerNode);
    result.children.addAll(newChildren);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitViewportNode(ViewportNode viewportNode, void data) {
    final List<Node> children = <Node>[];
    for (final Node child in viewportNode.children) {
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

    final _Result result = _Result(node);
    result.children.addAll(children);
    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedImageNode(
      ResolvedImageNode resolvedImageNode, Node data) {
    final _Result result = _Result(resolvedImageNode, deleteMaskNode: false);

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
      ResolvedTextPositionNode textPositionNode, void data) {
    return _Result(
      ResolvedTextPositionNode(
        textPositionNode.textPosition,
        <Node>[
          for (final Node child in textPositionNode.children)
            child.accept(this, data).node
        ],
      ),
    );
  }
}
