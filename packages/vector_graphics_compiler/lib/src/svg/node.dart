// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import '../image/image_info.dart';
import '../paint.dart';
import 'parser.dart' show SvgAttributes;
import 'visitor.dart';

/// Signature of a method that resolves a string identifier to an object.
///
/// Used by [ClipNode] and [MaskNode] to defer resolution of clips and masks.
typedef Resolver<T> = T Function(String id);

/// A node in a tree of graphics operations.
///
/// Nodes describe painting attributes, clips, transformations, paths, and
/// vertices to draw in depth-first order.
abstract class Node {
  /// Allows subclasses to be const.
  const Node();

  /// A node with no properties or operations, used for replacing `null` values
  /// in the tree or nodes that cannot be resolved correctly.
  static const Node empty = _EmptyNode();

  /// Subclasses that have additional transformation information will
  /// concatenate their transform to the supplied `currentTransform`.
  AffineMatrix concatTransform(AffineMatrix currentTransform) {
    return currentTransform;
  }

  /// Calls `visitor` for each child node of this parent group.
  ///
  /// This call does not recursively call `visitChildren`. Callers must decide
  /// whether to do BFS or DFS by calling `visitChildren` if the visited child
  /// is a [ParentNode].
  void visitChildren(NodeCallback visitor);

  /// Accept a [Visitor] implementation.
  S accept<S, V>(Visitor<S, V> visitor, V data);

  /// Creates a new compatible new node with attribute inheritence.
  ///
  /// If [replace] is true, treats the application of attributes as if this node
  /// is the parent. Otherwise, treats the application of the attributes as if
  /// the [newAttributes] are from the parent.
  ///
  /// By default, returns this.
  Node applyAttributes(SvgAttributes newAttributes, {bool replace = false}) =>
      this;
}

class _EmptyNode extends Node {
  const _EmptyNode();

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitEmptyNode(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {}
}

/// A node that contains a transform operation in the tree of graphics
/// operations.
abstract class TransformableNode extends Node {
  /// Constructs a new tree node with [transform].
  TransformableNode(this.transform);

  /// The descendant child's transform
  final AffineMatrix transform;

  @override
  @mustCallSuper
  AffineMatrix concatTransform(AffineMatrix currentTransform) {
    if (transform == AffineMatrix.identity) {
      return currentTransform;
    }
    return currentTransform.multiplied(transform);
  }
}

/// A node that has attributes in the tree of graphics operations.
abstract class AttributedNode extends TransformableNode {
  /// Constructs a new tree node with [attributes].
  AttributedNode(this.attributes, {AffineMatrix? precalculatedTransform})
      : super(precalculatedTransform ?? attributes.transform);

  /// A collection of painting attributes.
  ///
  /// Painting attributes inherit down the tree.
  final SvgAttributes attributes;
}

/// A graphics node describing a viewport area, which has a [width] and [height]
/// for the viewable portion it describes.
///
/// A viewport node is effectively a [ParentNode] with a width and height to
/// describe child coordinate space. It is typically used as the root of a tree,
/// but may also appear as a subtree root.
class ViewportNode extends ParentNode {
  /// Creates a new viewport node.
  ///
  /// See [ViewportNode].
  ViewportNode(
    super.attributes, {
    required this.width,
    required this.height,
    required AffineMatrix transform,
    super.children,
  }) : super(
          precalculatedTransform: transform,
        );

  /// The width of the viewport in pixels.
  final double width;

  /// The height of the viewport in pixels.
  final double height;

  /// The viewport rect described by [width] and [height].
  Rect get viewport => Rect.fromLTWH(0, 0, width, height);

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitViewportNode(this, data);
  }
}

/// The signature for a visitor callback to [ParentNode.visitChildren].
typedef NodeCallback = void Function(Node child);

/// A node that contains children, transformed by [transform].
class ParentNode extends AttributedNode {
  /// Creates a new [ParentNode].
  ParentNode(
    super.attributes, {
    super.precalculatedTransform,
    List<Node>? children,
  }) : _children = children ?? <Node>[];

  /// The child nodes of this node.
  final List<Node> _children;

  /// The child nodes for the given parent node.
  Iterable<Node> get children => _children;

  @override
  void visitChildren(NodeCallback visitor) {
    _children.forEach(visitor);
  }

  /// Adds a child to this parent node.
  ///
  /// If `clips` is empty, the child is directly appended. Otherwise, a
  /// [ClipNode] is inserted.
  void addChild(
    AttributedNode child, {
    String? clipId,
    String? maskId,
    String? patternId,
    required Resolver<List<Path>> clipResolver,
    required Resolver<AttributedNode?> maskResolver,
    required Resolver<AttributedNode?> patternResolver,
  }) {
    Node wrappedChild = child;
    if (clipId != null) {
      wrappedChild = ClipNode(
        resolver: clipResolver,
        clipId: clipId,
        child: wrappedChild,
        transform: child.attributes.transform,
      );
    }
    if (maskId != null) {
      wrappedChild = MaskNode(
        resolver: maskResolver,
        maskId: maskId,
        child: wrappedChild,
        blendMode: child.attributes.blendMode,
        transform: child.attributes.transform,
      );
    }
    if (patternId != null) {
      wrappedChild = PatternNode(
        resolver: patternResolver,
        patternId: patternId,
        child: wrappedChild,
        transform: child.attributes.transform,
      );
    }
    _children.add(wrappedChild);
  }

  @override
  AttributedNode applyAttributes(
    SvgAttributes newAttributes, {
    bool replace = false,
  }) {
    return ParentNode(
      attributes.applyParent(newAttributes),
      precalculatedTransform: transform,
    ).._children.addAll(_children);
  }

  /// Create the paint required to draw a save layer, or `null` if none is
  /// required.
  Paint? createLayerPaint() {
    final double? fillOpacity = attributes.fill?.opacity;
    final bool needsLayer = (attributes.blendMode != null) ||
        (fillOpacity != null && fillOpacity != 1.0 && fillOpacity != 0.0);

    if (needsLayer) {
      return Paint(
        blendMode: attributes.blendMode,
        fill: attributes.fill?.toFill(Rect.largest, transform) ??
            Fill(
              color: Color.opaqueBlack.withOpacity(fillOpacity ?? 1.0),
            ),
      );
    }
    return null;
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitParentNode(this, data);
  }
}

/// A node describing an update to the [TextPosition], including any applicable
/// transformation matrix.
class TextPositionNode extends ParentNode {
  /// See [TextPositionNode].
  TextPositionNode(super.attributes, {required this.reset});

  /// Whether this node represents a reset of the current text position or not.
  final bool reset;

  /// Computes a [TextPosition] to encode for this node.
  TextPosition computeTextPosition(Rect bounds, AffineMatrix transform) {
    final AffineMatrix computedTransform = concatTransform(transform);

    double? x = attributes.x?.calculate(bounds.width);
    double? y = attributes.y?.calculate(bounds.height);
    double? dx = attributes.dx?.calculate(bounds.width);
    double? dy = attributes.dy?.calculate(bounds.height);

    final bool hasXY = x != null && y != null;
    final bool hasDxDy = dx != null && dy != null;
    final bool consumeTransform = computedTransform == AffineMatrix.identity ||
        (computedTransform.encodableInRect && (hasXY || hasDxDy));

    if (hasXY) {
      final Point baseline = consumeTransform
          ? computedTransform.transformPoint(Point(x, y))
          : Point(x, y);
      x = baseline.x;
      y = baseline.y;
    }

    if (hasDxDy) {
      final Point baseline = consumeTransform
          ? computedTransform.transformPoint(Point(dx, dy))
          : Point(dx, dy);
      dx = baseline.x;
      dy = baseline.y;
    }

    return TextPosition(
      x: x,
      y: y,
      dx: dx,
      dy: dy,
      reset: reset,
      transform: consumeTransform ? null : computedTransform,
    );
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitTextPositionNode(this, data);
  }

  @override
  AttributedNode applyAttributes(
    SvgAttributes newAttributes, {
    bool replace = false,
  }) {
    return TextPositionNode(attributes.applyParent(newAttributes), reset: reset)
      .._children.addAll(_children);
  }
}

/// A parent node that applies a save layer to its children.
class SaveLayerNode extends ParentNode {
  /// Create a new [SaveLayerNode]
  SaveLayerNode(
    super.attributes, {
    required this.paint,
    super.children,
  }) : super(precalculatedTransform: AffineMatrix.identity);

  /// The paint to apply to the saved layer.
  final Paint paint;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitSaveLayerNode(this, data);
  }
}

/// A parent node that applies a clip to its children.
class ClipNode extends TransformableNode {
  /// Creates a new clip node that applies clip paths to [child].
  ClipNode({
    required this.resolver,
    required this.child,
    required this.clipId,
    required AffineMatrix transform,
  }) : super(transform);

  /// Called by visitors to resolve [clipId] to a list of paths.
  final Resolver<List<Path>> resolver;

  /// The clips to apply to the child node.
  ///
  /// Normally, there will only be one clip to apply. However, if multiple paths
  /// with differeing [PathFillType]s are used, multiple clips must be
  /// specified.
  final String clipId;

  /// The child to clip.
  final Node child;

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitClipNode(this, data);
  }

  @override
  Node applyAttributes(SvgAttributes newAttributes, {bool replace = false}) {
    return ClipNode(
      resolver: resolver,
      clipId: clipId,
      transform: transform,
      child: child.applyAttributes(newAttributes, replace: replace),
    );
  }
}

/// A parent node that applies a mask to its child.
class MaskNode extends TransformableNode {
  /// Creates a new mask node that applies [mask] to [child] using [blendMode].
  MaskNode({
    required this.child,
    required this.maskId,
    this.blendMode,
    required this.resolver,
    required AffineMatrix transform,
  }) : super(transform);

  /// The mask to apply.
  final String maskId;

  /// The child to mask.
  final Node child;

  /// The blend mode to apply when saving a layer for the mask, if any.
  final BlendMode? blendMode;

  /// Called by visitors to resolve [maskId] to an [AttributedNode].
  final Resolver<AttributedNode?> resolver;

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitMaskNode(this, data);
  }

  @override
  Node applyAttributes(SvgAttributes newAttributes, {bool replace = false}) {
    return MaskNode(
      resolver: resolver,
      maskId: maskId,
      blendMode: blendMode,
      transform: transform,
      child: child.applyAttributes(newAttributes, replace: replace),
    );
  }
}

/// A leaf node in the graphics tree.
///
/// Leaf nodes get added with all paint and transform accumulations from their
/// parents applied.
class PathNode extends AttributedNode {
  /// Creates a new leaf node for the graphics tree with the specified [path]
  /// and attributes
  PathNode(this.path, super.attributes);

  /// The description of the geometry this leaf node draws.
  final Path path;

  /// Compute the paint used by this Path.
  Paint? computePaint(Rect bounds, AffineMatrix transform) {
    final Stroke? stroke = attributes.stroke?.toStroke(bounds, transform);
    final Fill? fill = attributes.fill?.toFill(
      bounds,
      transform,
      defaultColor: Color.opaqueBlack,
    );
    if (fill == null && stroke == null) {
      return null;
    }
    return Paint(
      blendMode: attributes.blendMode,
      fill: fill,
      stroke: stroke,
    );
  }

  @override
  AttributedNode applyAttributes(
    SvgAttributes newAttributes, {
    bool replace = false,
  }) {
    return PathNode(
      path,
      replace
          ? newAttributes.applyParent(attributes, transformOverride: transform)
          : attributes.applyParent(newAttributes),
    );
  }

  @override
  void visitChildren(NodeCallback visitor) {}

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitPathNode(this, data);
  }
}

/// A node that refers to another node, and supplies a [resolver] for visitors
/// to materialize the referenced node into the tree.
class DeferredNode extends AttributedNode {
  /// Creates a new deferred node with [attributes] that will call [resolver]
  /// with [refId] when visited.
  DeferredNode(
    super.attributes, {
    required this.refId,
    required this.resolver,
  });

  /// The reference id to pass to [resolver].
  final String refId;

  /// The callback that materializes an [AttributedNode] for [refId] when
  /// visited.
  final Resolver<AttributedNode?> resolver;

  @override
  AttributedNode applyAttributes(
    SvgAttributes newAttributes, {
    bool replace = false,
  }) {
    return DeferredNode(
      replace
          ? newAttributes.applyParent(attributes, transformOverride: transform)
          : attributes.applyParent(newAttributes),
      refId: refId,
      resolver: resolver,
    );
  }

  @override
  void visitChildren(NodeCallback visitor) {}

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitDeferredNode(this, data);
  }
}

/// A leaf node in the tree that represents inline text.
///
/// Leaf nodes get added with all paint and transform accumulations from their
/// parents applied.
class TextNode extends AttributedNode {
  /// Create a new [TextNode] with the given [text].
  TextNode(
    this.text,
    super.attributes,
  );

  /// The text this node contains.
  final String text;

  /// Compute the [Paint] that this text node uses.
  Paint? computePaint(Rect bounds, AffineMatrix transform) {
    final Fill? fill = attributes.fill
        ?.toFill(bounds, transform, defaultColor: Color.opaqueBlack);
    final Stroke? stroke = attributes.stroke?.toStroke(bounds, transform);
    if (fill == null && stroke == null) {
      return null;
    }
    return Paint(
      blendMode: attributes.blendMode,
      fill: fill,
      stroke: stroke,
    );
  }

  /// Compute the [TextConfig] that this text node uses.
  TextConfig computeTextConfig(Rect bounds, AffineMatrix transform) {
    // Don't concat the transform since it's repeated by the parent group
    // the way the parser is set up.
    return TextConfig(
      text,
      attributes.textAnchorMultiplier ?? 0,
      attributes.fontFamily,
      attributes.fontWeight ?? normalFontWeight,
      attributes.fontSize ?? 16, // default in many browsers
      attributes.textDecoration ?? TextDecoration.none,
      attributes.textDecorationStyle ?? TextDecorationStyle.solid,
      attributes.textDecorationColor ?? Color.opaqueBlack,
    );
  }

  @override
  AttributedNode applyAttributes(
    SvgAttributes newAttributes, {
    bool replace = false,
  }) {
    final SvgAttributes resolvedAttributes = replace
        ? newAttributes.applyParent(attributes, transformOverride: transform)
        : attributes.applyParent(newAttributes);
    return TextNode(
      text,
      resolvedAttributes,
    );
  }

  @override
  void visitChildren(NodeCallback visitor) {}

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitTextNode(this, data);
  }
}

/// A leaf node in the tree that represents an image.
///
/// Leaf nodes get added with all paint and transform accumulations from their
/// parents applied.
class ImageNode extends AttributedNode {
  /// Create a new [ImageNode] with the given [text].
  ImageNode(
    this.data,
    this.format,
    super.attributes,
  );

  /// The image data this node contains.
  final Uint8List data;

  /// The format of [data].
  final ImageFormat format;

  @override
  AttributedNode applyAttributes(
    SvgAttributes newAttributes, {
    bool replace = false,
  }) {
    return ImageNode(
      data,
      format,
      replace
          ? newAttributes.applyParent(attributes, transformOverride: transform)
          : attributes.applyParent(newAttributes),
    );
  }

  @override
  void visitChildren(NodeCallback visitor) {}

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitImageNode(this, data);
  }
}

/// A leaf node in the tree that reprents an patterned-node.
class PatternNode extends TransformableNode {
  /// Creates a new pattern node that aaples [pattern] to [child].
  PatternNode({
    required this.child,
    required this.patternId,
    required this.resolver,
    required AffineMatrix transform,
  }) : super(transform);

  /// A unique identifier for this pattern.
  final String patternId;

  /// The child(ren) to apply the pattern to.
  final Node child;

  /// Called by visitors to resolve [patternId] to an [AttributedNode].
  final Resolver<AttributedNode?> resolver;

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitPatternNode(this, data);
  }

  @override
  Node applyAttributes(SvgAttributes newAttributes, {bool replace = false}) {
    return PatternNode(
      resolver: resolver,
      patternId: patternId,
      transform: transform,
      child: child.applyAttributes(newAttributes, replace: replace),
    );
  }
}
