// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../vector_graphics_compiler.dart';
import 'masking_optimizer.dart';
import 'node.dart';
import 'parser.dart';
import 'path_ops.dart' as path_ops;
import 'visitor.dart';

class _Result {
  _Result(this.node);

  final Node node;
  final List<Node> children = <Node>[];
  Node parent = Node.empty;
}

/// Removes unnecessary overlappping.
class OverdrawOptimizer extends Visitor<_Result, Node>
    with ErrorOnUnResolvedNode<_Result, Node> {
  /// Applies visitor to given node.
  Node apply(Node node) {
    final Node newNode = node.accept(this, null).node;
    return newNode;
  }

  /// Removes overlap between top and bottom path from bottom.
  ResolvedPathNode removeOverlap(
      ResolvedPathNode bottomPathNode, ResolvedPathNode topPathNode) {
    final path_ops.Path topPathOpsPath = toPathOpsPath(topPathNode.path);
    final path_ops.Path bottomPathOpsPath = toPathOpsPath(bottomPathNode.path);
    final path_ops.Path intersection =
        bottomPathOpsPath.applyOp(topPathOpsPath, path_ops.PathOp.intersect);
    final path_ops.Path newBottomPath =
        bottomPathOpsPath.applyOp(intersection, path_ops.PathOp.difference);
    final Path newPath = toVectorGraphicsPath(newBottomPath);
    final ResolvedPathNode newPathNode = ResolvedPathNode(
        paint: bottomPathNode.paint,
        bounds: bottomPathNode.bounds,
        path: newPath);

    bottomPathOpsPath.dispose();
    topPathOpsPath.dispose();
    intersection.dispose();
    newBottomPath.dispose();

    return newPathNode;
  }

  /// Calculates the resulting [Color] when two semi-transparent
  /// colors are stacked on top of eachother.
  Color calculateOverlapColor(Color bottomColor, Color topColor) {
    final double a0 = topColor.a / 255;
    final double a1 = bottomColor.a / 255;
    final int r0 = topColor.r;
    final int b0 = topColor.b;
    final int g0 = topColor.g;
    final int r1 = bottomColor.r;
    final int b1 = bottomColor.b;
    final int g1 = bottomColor.g;

    final double a = (1 - a0) * a1 + a0;
    final double r = ((1 - a0) * a1 * r1 + a0 * r0) / a;
    final double g = ((1 - a0) * a1 * g1 + a0 * g0) / a;
    final double b = ((1 - a0) * a1 * b1 + a0 * b0) / a;

    final Color overlapColor =
        Color.fromARGB((a * 255).round(), r.round(), g.round(), b.round());
    return overlapColor;
  }

  /// Resolves overlapping between top and bottom path on
  /// nodes where opacity is not 1 or null.
  List<ResolvedPathNode> resolveOpacityOverlap(
      ResolvedPathNode bottomPathNode, ResolvedPathNode topPathNode) {
    final Color? bottomColor = bottomPathNode.paint.fill?.color;
    final Color? topColor = topPathNode.paint.fill?.color;
    if (bottomColor != null && topColor != null) {
      final Color overlapColor = calculateOverlapColor(bottomColor, topColor);
      final path_ops.Path topPathOpsPath = toPathOpsPath(topPathNode.path);
      final path_ops.Path bottomPathOpsPath =
          toPathOpsPath(bottomPathNode.path);
      final path_ops.Path intersection =
          bottomPathOpsPath.applyOp(topPathOpsPath, path_ops.PathOp.intersect);
      final path_ops.Path newBottomPath =
          bottomPathOpsPath.applyOp(intersection, path_ops.PathOp.difference);
      final path_ops.Path newTopPath =
          topPathOpsPath.applyOp(intersection, path_ops.PathOp.difference);

      final Path newBottomVGPath = toVectorGraphicsPath(newBottomPath);
      final Path newTopVGPath = toVectorGraphicsPath(newTopPath);
      final Path newOverlapVGPath = toVectorGraphicsPath(intersection);

      final ResolvedPathNode newBottomPathNode = ResolvedPathNode(
          paint: bottomPathNode.paint,
          bounds: bottomPathNode.bounds,
          path: newBottomVGPath);
      final ResolvedPathNode newTopPathNode = ResolvedPathNode(
          paint: topPathNode.paint,
          bounds: bottomPathNode.bounds,
          path: newTopVGPath);
      final ResolvedPathNode newOverlapPathNode = ResolvedPathNode(
          paint: Paint(
              blendMode: bottomPathNode.paint.blendMode,
              stroke: bottomPathNode.paint.stroke,
              fill: Fill(
                  color: overlapColor,
                  shader: bottomPathNode.paint.fill?.shader)),
          bounds: bottomPathNode.bounds,
          path: newOverlapVGPath);

      bottomPathOpsPath.dispose();
      topPathOpsPath.dispose();
      intersection.dispose();
      newBottomPath.dispose();

      return <ResolvedPathNode>[
        newBottomPathNode,
        newTopPathNode,
        newOverlapPathNode
      ];
    }
    return <ResolvedPathNode>[bottomPathNode, topPathNode];
  }

  /// Determines if node is optimizable.
  bool isOptimizable(Node node) {
    return node is ResolvedPathNode &&
        node.paint.stroke?.width == null &&
        node.paint.stroke?.color == null &&
        node.paint.fill?.shader == null;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitEmptyNode(Node node, void data) {
    final _Result result = _Result(node);
    return result;
  }

  /// Visits applies optimizer to all children of ParentNode.
  // ignore: library_private_types_in_public_api
  _Result visitChildren(Node node, _Result data) {
    if (node is ParentNode) {
      data = node.accept(this, data);
    }
    return data;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitParentNode(ParentNode parentNode, Node data) {
    int pathNodeCount = 0;
    final List<List<Node>> newChildList = <List<Node>>[];
    final List<Node> newChildren = <Node>[];

    for (final Node child in parentNode.children) {
      if (child is ResolvedPathNode) {
        pathNodeCount++;
      }
      newChildList.add(<Node>[child]);
    }

    int index = 0;
    ResolvedPathNode? lastPathNode;
    int? lastPathNodeIndex;

    /// If the group opacity is set the children path nodes
    /// cannot be optimized.
    if (!parentNode.attributes.hasOpacity) {
      /// If there are not at least 2 path nodes, an optimization cannot be
      /// performed since 2 nodes are required for an 'overlap' to occur.
      if (pathNodeCount >= 2) {
        for (Node child in parentNode.children) {
          if (isOptimizable(child)) {
            child = child as ResolvedPathNode;

            /// If there is no previous path node to calculate
            /// the overlap with, the current optimizable child will
            /// be assigned as the lastPathNode.
            if (lastPathNode == null || lastPathNodeIndex == null) {
              lastPathNode = child;
              lastPathNodeIndex = index;
            } else {
              /// If it is the case that the current node, which is
              /// the "top" path, is opaque, the removeOverlap function
              /// will be used.
              if (child.paint.fill?.color.a == 255) {
                newChildList[lastPathNodeIndex] = <Node>[
                  removeOverlap(lastPathNode, child)
                ];
                lastPathNode = child;
                lastPathNodeIndex = index;
              } else {
                /// If it is the case that the current node, which is
                /// the "top" path, is semi-transparent, the
                /// resolveOpacityOverlap function will be used.
                /// Note: The "top" and "intersection" path nodes that
                /// are returned will not be further optimized.
                newChildList[lastPathNodeIndex] = resolveOpacityOverlap(
                    newChildList[lastPathNodeIndex].first as ResolvedPathNode,
                    child);
                newChildList[index] = <Node>[];
                lastPathNode = null;
                lastPathNodeIndex = null;
              }
            }
            // } else {
            //   // Conservatively bail out here. There's some child that isn't
            //   // optimizable, and there aren't sufficient checks to make sure
            //   // we can make sense of what's actually going on anymore.
            //   return _Result(parentNode);
          }
          index++;
        }
        index = 0;

        /// Here the 2-dimensional list of new children is flattened.
        for (final List<Node> child in newChildList) {
          if (child.isNotEmpty) {
            if (child.first is ResolvedPathNode) {
              newChildren.addAll(child);
            } else {
              newChildren.add(child.first.accept(this, parentNode).node);
            }
          }
        }
      } else {
        /// If there's less than 2 path nodes, the parent node's direct children
        /// cannot be optimized, but it may have grand children that can be optimized,
        /// so accept will be called on the children.
        for (final Node child in parentNode.children) {
          newChildren.add(child.accept(this, parentNode).node);
        }
      }
    } else {
      /// If group opacity is set, the parent nodes children cannot be optimized.
      return _Result(parentNode);
    }
    final _Result result = _Result(ParentNode(parentNode.attributes,
        children: newChildren, precalculatedTransform: parentNode.transform));

    return result;
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitMaskNode(MaskNode maskNode, Node data) {
    return _Result(maskNode);
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitPathNode(PathNode pathNode, Node data) {
    return _Result(pathNode);
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    final _Result childResult = maskNode.child.accept(this, maskNode);
    final ResolvedMaskNode newMaskNode = ResolvedMaskNode(
        child: childResult.node,
        mask: maskNode.mask,
        blendMode: maskNode.blendMode);
    final _Result result = _Result(newMaskNode);
    result.children.add(childResult.node);
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
    return _Result(pathNode);
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedText(ResolvedTextNode textNode, Node data) {
    return _Result(textNode);
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitResolvedVerticesNode(
      ResolvedVerticesNode verticesNode, Node data) {
    return _Result(verticesNode);
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
  _Result visitResolvedImageNode(
      ResolvedImageNode resolvedImageNode, Node data) {
    return _Result(resolvedImageNode);
  }

  @override
  // ignore: library_private_types_in_public_api
  _Result visitViewportNode(ViewportNode viewportNode, void data) {
    final List<Node> children = <Node>[];

    final ParentNode parentNode = ParentNode(SvgAttributes.empty,
        children: viewportNode.children.toList());

    final _Result childResult = parentNode.accept(this, viewportNode);
    children.addAll((childResult.node as ParentNode).children);

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
