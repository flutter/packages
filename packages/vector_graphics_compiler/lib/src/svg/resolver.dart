// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import '../geometry/vertices.dart';
import '../image/image_info.dart';
import '../paint.dart';
import 'node.dart';
import 'parser.dart';
import 'visitor.dart';

/// A visitor class that processes relative coordinates in the tree into a
/// single coordinate space, removing extra attributes, empty nodes, resolving
/// references/masks/clips.
class ResolvingVisitor extends Visitor<Node, AffineMatrix> {
  late Rect _bounds;

  @override
  Node visitClipNode(ClipNode clipNode, AffineMatrix data) {
    final AffineMatrix childTransform = clipNode.concatTransform(data);
    final List<Path> transformedClips = <Path>[
      for (final Path clip in clipNode.resolver(clipNode.clipId))
        clip.transformed(childTransform)
    ];
    if (transformedClips.isEmpty) {
      return clipNode.child.accept(this, data);
    }
    return ResolvedClipNode(
      clips: transformedClips,
      child: clipNode.child.accept(this, data),
    );
  }

  @override
  Node visitMaskNode(MaskNode maskNode, AffineMatrix data) {
    final AttributedNode? resolvedMask = maskNode.resolver(maskNode.maskId);
    if (resolvedMask == null) {
      return maskNode.child.accept(this, data);
    }
    final Node child = maskNode.child.accept(this, data);
    final AffineMatrix childTransform = maskNode.concatTransform(data);
    final Node mask = resolvedMask.accept(this, childTransform);

    return ResolvedMaskNode(
      child: child,
      mask: mask,
      blendMode: maskNode.blendMode,
    );
  }

  @override
  Node visitParentNode(ParentNode parentNode, AffineMatrix data) {
    final AffineMatrix nextTransform = parentNode.concatTransform(data);

    final Paint? saveLayerPaint = parentNode.createLayerPaint();

    final Node result;
    if (saveLayerPaint == null) {
      result = ParentNode(
        SvgAttributes.empty,
        precalculatedTransform: AffineMatrix.identity,
        children: <Node>[
          for (final Node child in parentNode.children)
            child
                .applyAttributes(parentNode.attributes)
                .accept(this, nextTransform),
        ],
      );
    } else {
      result = SaveLayerNode(
        SvgAttributes.empty,
        paint: saveLayerPaint,
        children: <Node>[
          for (final Node child in parentNode.children)
            child
                .applyAttributes(parentNode.attributes.forSaveLayer())
                .accept(this, nextTransform),
        ],
      );
    }
    return result;
  }

  @override
  Node visitPathNode(PathNode pathNode, AffineMatrix data) {
    final AffineMatrix transform = data.multiplied(
      pathNode.attributes.transform,
    );
    final Path transformedPath = pathNode.path
        .transformed(transform)
        .withFillType(pathNode.attributes.fillRule ?? pathNode.path.fillType);
    final Rect originalBounds = pathNode.path.bounds();
    final Rect newBounds = transformedPath.bounds();
    final Paint? paint = pathNode.computePaint(originalBounds, transform);
    if (paint != null) {
      if (pathNode.attributes.stroke?.dashArray != null) {
        final List<Node> children = <Node>[];
        final ParentNode parent = ParentNode(
          pathNode.attributes,
          children: children,
        );
        if (paint.fill != null) {
          children.add(ResolvedPathNode(
            paint: Paint(blendMode: paint.blendMode, fill: paint.fill),
            bounds: newBounds,
            path: transformedPath,
          ));
        }
        if (paint.stroke != null) {
          children.add(ResolvedPathNode(
            paint: Paint(blendMode: paint.blendMode, stroke: paint.stroke),
            bounds: newBounds,
            path: transformedPath.dashed(
              pathNode.attributes.stroke!.dashArray!,
            ),
          ));
        }
        return parent;
      }
      return ResolvedPathNode(
        paint: paint,
        bounds: newBounds,
        path: transformedPath,
      );
    }
    return Node.empty;
  }

  @override
  Node visitTextPositionNode(
    TextPositionNode textPositionNode,
    AffineMatrix data,
  ) {
    final AffineMatrix nextTransform = textPositionNode.concatTransform(data);

    return ResolvedTextPositionNode(
      textPositionNode.computeTextPosition(_bounds, data),
      <Node>[
        for (final Node child in textPositionNode.children)
          child
              .applyAttributes(textPositionNode.attributes)
              .accept(this, nextTransform),
      ],
    );
  }

  @override
  Node visitTextNode(TextNode textNode, AffineMatrix data) {
    final Paint? paint = textNode.computePaint(_bounds, data);
    final TextConfig textConfig = textNode.computeTextConfig(_bounds, data);

    if (paint != null && textConfig.text.trim().isNotEmpty) {
      return ResolvedTextNode(
        textConfig: textConfig,
        paint: paint,
      );
    }
    return Node.empty;
  }

  @override
  Node visitViewportNode(ViewportNode viewportNode, AffineMatrix data) {
    _bounds = Rect.fromLTWH(0, 0, viewportNode.width, viewportNode.height);
    final AffineMatrix transform = viewportNode.concatTransform(data);
    return ViewportNode(
      SvgAttributes.empty,
      width: viewportNode.width,
      height: viewportNode.height,
      transform: AffineMatrix.identity,
      children: <Node>[
        for (final Node child in viewportNode.children)
          child
              .applyAttributes(viewportNode.attributes)
              .accept(this, transform),
      ],
    );
  }

  @override
  Node visitDeferredNode(DeferredNode deferredNode, AffineMatrix data) {
    final AttributedNode? resolvedNode =
        deferredNode.resolver(deferredNode.refId);
    if (resolvedNode == null) {
      return Node.empty;
    }
    final Node concreteRef = resolvedNode.applyAttributes(
      deferredNode.attributes,
      replace: true,
    );
    return concreteRef.accept(this, data);
  }

  @override
  Node visitEmptyNode(Node node, AffineMatrix data) => node;

  @override
  Node visitResolvedText(ResolvedTextNode textNode, AffineMatrix data) {
    assert(false);
    return textNode;
  }

  @override
  Node visitResolvedTextPositionNode(
      ResolvedTextPositionNode textPositionNode, AffineMatrix data) {
    assert(false);
    return textPositionNode;
  }

  @override
  Node visitResolvedPath(ResolvedPathNode pathNode, AffineMatrix data) {
    assert(false);
    return pathNode;
  }

  @override
  Node visitResolvedClipNode(ResolvedClipNode clipNode, AffineMatrix data) {
    assert(false);
    return clipNode;
  }

  @override
  Node visitResolvedMaskNode(ResolvedMaskNode maskNode, AffineMatrix data) {
    assert(false);
    return maskNode;
  }

  @override
  Node visitSaveLayerNode(SaveLayerNode layerNode, AffineMatrix data) {
    assert(false);
    return layerNode;
  }

  @override
  Node visitResolvedVerticesNode(
      ResolvedVerticesNode verticesNode, AffineMatrix data) {
    assert(false);
    return verticesNode;
  }

  @override
  Node visitImageNode(ImageNode imageNode, AffineMatrix data) {
    final AffineMatrix childTransform = imageNode.concatTransform(data);

    final SvgAttributes attributes = imageNode.attributes;
    final double left = double.parse(attributes.raw['x'] ?? '0');
    final double top = double.parse(attributes.raw['y'] ?? '0');

    double? width = double.tryParse(attributes.raw['width'] ?? '');
    double? height = double.tryParse(attributes.raw['height'] ?? '');
    if (width == null || height == null) {
      final ImageSizeData data = ImageSizeData.fromBytes(imageNode.data);
      width ??= data.width.toDouble();
      height ??= data.height.toDouble();
    }
    final Rect rect = Rect.fromLTWH(left, top, width, height);

    // Determine if this image can be drawn without any transforms because
    // it only has an offset and/or scale.
    if (childTransform.encodableInRect) {
      // trivial transform.
      return ResolvedImageNode(
        data: imageNode.data,
        format: imageNode.format,
        rect: childTransform.transformRect(rect),
        transform: null,
      );
    }

    // Non-trivial transform.
    return ResolvedImageNode(
      data: imageNode.data,
      format: imageNode.format,
      rect: rect,
      transform: childTransform,
    );
  }

  @override
  Node visitResolvedImageNode(
      ResolvedImageNode resolvedImageNode, AffineMatrix data) {
    assert(false);
    return resolvedImageNode;
  }

  @override
  Node visitPatternNode(PatternNode patternNode, AffineMatrix data) {
    final AttributedNode? resolvedPattern =
        patternNode.resolver(patternNode.patternId);
    if (resolvedPattern == null) {
      return patternNode.child.accept(this, data);
    }
    final Node child = patternNode.child.accept(this, data);
    final AffineMatrix childTransform = patternNode.concatTransform(data);
    final Node pattern = resolvedPattern.accept(this, childTransform);

    return ResolvedPatternNode(
      child: child,
      pattern: pattern,
      x: resolvedPattern.attributes.x?.calculate(0) ?? 0,
      y: resolvedPattern.attributes.y?.calculate(0) ?? 0,
      width: resolvedPattern.attributes.width!,
      height: resolvedPattern.attributes.height!,
      transform: data,
      id: patternNode.patternId,
    );
  }

  @override
  Node visitResolvedPatternNode(
      ResolvedPatternNode patternNode, AffineMatrix data) {
    assert(false);
    return patternNode;
  }
}

/// A text position update that is final and has a fully known transform.
///
/// Constructed from a [TextPositionNode] by a [ResolvingVisitor].
class ResolvedTextPositionNode extends Node {
  /// Create a new [ResolvedTextPositionNode].
  ResolvedTextPositionNode(this.textPosition, this.children);

  /// The resolved [TextPosition].
  final TextPosition textPosition;

  /// The children of this node.
  final List<Node> children;

  @override
  void visitChildren(NodeCallback visitor) {
    children.forEach(visitor);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedTextPositionNode(this, data);
  }
}

/// A block of text that has its position and final transfrom fully known.
///
/// This should only be constructed from a [TextNode] in a [ResolvingVisitor].
class ResolvedTextNode extends Node {
  /// Create a new [ResolvedTextNode].
  ResolvedTextNode({
    required this.textConfig,
    required this.paint,
  });

  /// The text configuration to draw this piece of text.
  final TextConfig textConfig;

  /// The paint used to draw this piece of text.
  final Paint paint;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedText(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {}
}

/// A path node that has its bounds fully computed.
///
/// This should only be constructed from a [PathNode] in a [ResolvingVisitor].
class ResolvedPathNode extends Node {
  /// Create a new [ResolvedPathNode].
  ResolvedPathNode({
    required this.paint,
    required this.bounds,
    required this.path,
  });

  /// The paint for the current path node.
  final Paint paint;

  /// The bounds estimate for the current path.
  final Rect bounds;

  /// The path to be drawn.
  final Path path;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedPath(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {}
}

/// A node that draws resolved vertices.
class ResolvedVerticesNode extends Node {
  /// Create a new [ResolvedVerticesNode]
  ResolvedVerticesNode({
    required this.paint,
    required this.vertices,
    required this.bounds,
  }) : assert(paint.stroke == null);

  /// The paint (fill only) to draw on the given node.
  final Paint paint;

  /// The vertices to be drawn.
  final IndexedVertices vertices;

  /// The original bounds of the path that created this node.
  final Rect bounds;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedVerticesNode(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {}
}

/// A clip node where all paths are known and transformed in a single
/// coordinate space.
///
/// This should only be constructed from a [ClipNode] in a [ResolvingVisitor].
class ResolvedClipNode extends Node {
  /// Create a new [ResolvedClipNode].
  ResolvedClipNode({
    required this.clips,
    required this.child,
  });

  /// One or more clips to apply to rendered children.
  final List<Path> clips;

  /// The child node.
  final Node child;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedClipNode(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }
}

/// A mask node with child and mask fully resolved.
///
/// This should only be constructed from a [MaskNode] in a [ResolvingVisitor].
class ResolvedMaskNode extends Node {
  /// Create a new [ResolvedMaskNode].
  ResolvedMaskNode({
    required this.child,
    required this.mask,
    required this.blendMode,
  });

  /// The child to apply as a mask.
  final Node mask;

  /// The child of this mask layer.
  final Node child;

  /// The blend mode to apply when saving a layer for the mask, if any.
  final BlendMode? blendMode;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedMaskNode(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }
}

/// An image node that has a fully resolved position and data.
class ResolvedImageNode extends Node {
  /// Create a new [ResolvedImageNode].
  const ResolvedImageNode({
    required this.data,
    required this.format,
    required this.rect,
    required this.transform,
  });

  /// The image [data] encoded as a PNG.
  final Uint8List data;

  /// The format of [data].
  final ImageFormat format;

  /// The region to draw the image to.
  final Rect rect;

  /// An optional transform.
  ///
  /// This is set when the accumulated image transform causes the image rect
  /// to not stay rectangular.
  final AffineMatrix? transform;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedImageNode(this, data);
  }

  @override
  void visitChildren(NodeCallback visitor) {}
}

/// A pattern node that has a fully resolved position and data.
class ResolvedPatternNode extends Node {
  /// Creates a new [ResolvedPatternNode].

  ResolvedPatternNode({
    required this.child,
    required this.pattern,
    required this.width,
    required this.x,
    required this.y,
    required this.height,
    required this.transform,
    required this.id,
  });

  /// The child to apply a pattern to.
  final Node child;

  /// A node that represents the pattern.
  final Node pattern;

  /// The x coordinate shift of the pattern tile.
  final double x;

  /// The y coordinate shift of the pattern tile.
  final double y;

  /// The width of the pattern's viewbox in px.
  /// Values must be > = 1.
  final double width;

  /// The height of the pattern's viewbox in px.
  /// Values must be > = 1.
  final double height;

  /// A unique identifier for the [pattern].
  final Object id;

  /// This is the transform of the pattern that has been created from the children.
  AffineMatrix transform;

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitResolvedPatternNode(this, data);
  }
}
