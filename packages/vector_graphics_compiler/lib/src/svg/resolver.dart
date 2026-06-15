// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:meta/meta.dart';
import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import '../geometry/vertices.dart';
import '../image/image_info.dart';
import '../paint.dart';
import '../util.dart';
import 'constants.dart';
import 'node.dart';
import 'parser.dart';
import 'visitor.dart';

/// A visitor class that processes relative coordinates in the tree into a
/// single coordinate space, removing extra attributes, empty nodes, resolving
/// references/masks/clips.
class ResolvingVisitor extends Visitor<Node, AffineMatrix> {
  /// Creates a new [ResolvingVisitor].
  ResolvingVisitor([this._filterResolver]);

  final SvgFilter? Function(String)? _filterResolver;
  late Rect _bounds;
  SvgFilterLayer? _currentLayer;
  final Map<Gradient, Gradient> _blackenedGradients = <Gradient, Gradient>{};

  final Set<String> _activeMasks = <String>{};
  final Set<String> _activeDeferred = <String>{};
  final Set<String> _activePatterns = <String>{};
  int _deferredExpansionCount = 0;

  @override
  Node visitClipNode(ClipNode clipNode, AffineMatrix data) {
    final AffineMatrix childTransform = clipNode.concatTransform(data);
    final transformedClips = <Path>[
      for (final Path clip in clipNode.resolver(clipNode.clipId)) clip.transformed(childTransform),
    ];
    if (transformedClips.isEmpty) {
      return clipNode.child.accept(this, data);
    }
    return ResolvedClipNode(clips: transformedClips, child: clipNode.child.accept(this, data));
  }

  @override
  Node visitMaskNode(MaskNode maskNode, AffineMatrix data) {
    _deferredExpansionCount++;
    if (_deferredExpansionCount > kMaxReferenceExpansions) {
      throw StateError(kMaxReferenceExpansionsErrorMessage);
    }
    if (!_activeMasks.add(maskNode.maskId)) {
      // Recursive loop detected.
      return maskNode.child.accept(this, data);
    }
    try {
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
        maskType: resolvedMask.attributes.maskType,
      );
    } finally {
      _activeMasks.remove(maskNode.maskId);
    }
  }

  @override
  Node visitParentNode(ParentNode parentNode, AffineMatrix data) {
    final AffineMatrix nextTransform = parentNode.concatTransform(data);

    SvgFilter? filter;
    final String? filterId = parentNode.attributes.filterId;
    if (filterId != null && _filterResolver != null) {
      filter = _filterResolver(filterId);
    }

    if (filter != null && filter.layers.isNotEmpty) {
      if (filter.layers.length == 1) {
        return _resolveParentNodeForLayer(parentNode, nextTransform, filter.layers.first);
      }

      final children = <Node>[];
      for (final SvgFilterLayer layer in filter.layers) {
        children.add(_resolveParentNodeForLayer(parentNode, nextTransform, layer));
      }
      return ParentNode(SvgAttributes.empty, children: children);
    }

    return _resolveParentNodeNoFilter(parentNode, nextTransform);
  }

  Node _resolveParentNodeForLayer(
    ParentNode parentNode,
    AffineMatrix nextTransform,
    SvgFilterLayer layer,
  ) {
    final AffineMatrix layerTransform = (layer.dx == 0 && layer.dy == 0)
        ? nextTransform
        : nextTransform.translated(layer.dx, layer.dy);

    final bool hasBlur = layer.sigmaX > 0 || layer.sigmaY > 0;

    final SvgFilterLayer? previousLayer = _currentLayer;
    _currentLayer = SvgFilterLayer(
      isSourceAlpha: layer.isSourceAlpha || (previousLayer?.isSourceAlpha ?? false),
      sigmaX: 0,
      sigmaY: 0,
      dx: 0,
      dy: 0,
    );

    try {
      final Paint? saveLayerPaint = parentNode.createLayerPaint(
        filterBlurX: hasBlur ? layer.sigmaX * nextTransform.xScale : null,
        filterBlurY: hasBlur ? layer.sigmaY * nextTransform.yScale : null,
      );

      final Node resolved;
      if (saveLayerPaint == null) {
        resolved = ParentNode(
          SvgAttributes.empty,
          precalculatedTransform: AffineMatrix.identity,
          children: <Node>[
            for (final Node child in parentNode.children)
              child.applyAttributes(parentNode.attributes).accept(this, layerTransform),
          ],
        );
      } else {
        resolved = SaveLayerNode(
          SvgAttributes.empty,
          paint: saveLayerPaint,
          children: <Node>[
            for (final Node child in parentNode.children)
              child
                  .applyAttributes(parentNode.attributes.forSaveLayer())
                  .accept(this, layerTransform),
          ],
        );
      }
      return resolved;
    } finally {
      _currentLayer = previousLayer;
    }
  }

  Node _resolveParentNodeNoFilter(ParentNode parentNode, AffineMatrix nextTransform) {
    final Paint? saveLayerPaint = parentNode.createLayerPaint();
    if (saveLayerPaint == null) {
      return ParentNode(
        SvgAttributes.empty,
        precalculatedTransform: AffineMatrix.identity,
        children: <Node>[
          for (final Node child in parentNode.children)
            child.applyAttributes(parentNode.attributes).accept(this, nextTransform),
        ],
      );
    }
    return SaveLayerNode(
      SvgAttributes.empty,
      paint: saveLayerPaint,
      children: <Node>[
        for (final Node child in parentNode.children)
          child.applyAttributes(parentNode.attributes.forSaveLayer()).accept(this, nextTransform),
      ],
    );
  }

  @override
  Node visitPathNode(PathNode pathNode, AffineMatrix data) {
    final AffineMatrix transform = data.multiplied(pathNode.attributes.transform);
    final Path transformedPath = pathNode.path
        .transformed(transform)
        .withFillType(pathNode.attributes.fillRule ?? pathNode.path.fillType);
    final Rect originalBounds = pathNode.path.bounds();
    final Rect newBounds = transformedPath.bounds();
    SvgFilter? filter;
    final String? filterId = pathNode.attributes.filterId;
    if (filterId != null && _filterResolver != null) {
      filter = _filterResolver(filterId);
    }

    if (filter != null && filter.layers.isNotEmpty) {
      final Paint? originalPaint = pathNode.computePaint(originalBounds, transform);
      if (originalPaint == null) {
        return Node.empty;
      }

      if (filter.layers.length == 1) {
        return _resolvePathNodeForLayer(
          pathNode,
          originalPaint,
          transform,
          transformedPath,
          newBounds,
          filter.layers.first,
        );
      }

      final children = <Node>[];
      for (final SvgFilterLayer layer in filter.layers) {
        children.add(
          _resolvePathNodeForLayer(
            pathNode,
            originalPaint,
            transform,
            transformedPath,
            newBounds,
            layer,
          ),
        );
      }
      return ParentNode(SvgAttributes.empty, children: children);
    }

    if (_currentLayer != null &&
        (_currentLayer!.isSourceAlpha || _currentLayer!.sigmaX > 0 || _currentLayer!.sigmaY > 0)) {
      final Paint? originalPaint = pathNode.computePaint(originalBounds, transform);
      if (originalPaint == null) {
        return Node.empty;
      }
      return _resolvePathNodeForLayer(
        pathNode,
        originalPaint,
        transform,
        transformedPath,
        newBounds,
        _currentLayer!,
      );
    }

    final Paint? paint = pathNode.computePaint(originalBounds, transform);
    if (paint != null) {
      return _resolvePathNode(pathNode, paint, transformedPath, newBounds);
    }
    return Node.empty;
  }

  Node _resolvePathNodeForLayer(
    PathNode pathNode,
    Paint originalPaint,
    AffineMatrix transform,
    Path transformedPath,
    Rect newBounds,
    SvgFilterLayer layer,
  ) {
    final Path layerPath = (layer.dx == 0 && layer.dy == 0)
        ? transformedPath
        : pathNode.path
              .transformed(transform.translated(layer.dx, layer.dy))
              .withFillType(pathNode.attributes.fillRule ?? pathNode.path.fillType);
    final Rect layerBounds = (layer.dx == 0 && layer.dy == 0) ? newBounds : layerPath.bounds();

    final Paint paint = _createLayerPaint(originalPaint, layer, transform);

    return _resolvePathNode(pathNode, paint, layerPath, layerBounds);
  }

  Node _resolvePathNode(PathNode pathNode, Paint paint, Path transformedPath, Rect newBounds) {
    if (pathNode.attributes.stroke?.dashArray != null) {
      final children = <Node>[];
      final parent = ParentNode(pathNode.attributes, children: children);
      if (paint.fill != null) {
        children.add(
          ResolvedPathNode(
            paint: Paint(
              blendMode: paint.blendMode,
              fill: paint.fill,
              filterBlurX: paint.filterBlurX,
              filterBlurY: paint.filterBlurY,
            ),
            bounds: newBounds,
            path: transformedPath,
          ),
        );
      }
      if (paint.stroke != null) {
        children.add(
          ResolvedPathNode(
            paint: Paint(
              blendMode: paint.blendMode,
              stroke: paint.stroke,
              filterBlurX: paint.filterBlurX,
              filterBlurY: paint.filterBlurY,
            ),
            bounds: newBounds,
            path: transformedPath.dashed(pathNode.attributes.stroke!.dashArray!),
          ),
        );
      }
      return parent;
    }
    return ResolvedPathNode(paint: paint, bounds: newBounds, path: transformedPath);
  }

  @override
  Node visitTextPositionNode(TextPositionNode textPositionNode, AffineMatrix data) {
    final AffineMatrix nextTransform = textPositionNode.concatTransform(data);

    SvgFilter? filter;
    final String? filterId = textPositionNode.attributes.filterId;
    if (filterId != null && _filterResolver != null) {
      filter = _filterResolver(filterId);
    }

    if (filter != null && filter.layers.isNotEmpty) {
      if (filter.layers.length == 1) {
        final SvgFilterLayer layer = filter.layers.first;
        final SvgFilterLayer? previousLayer = _currentLayer;
        _currentLayer = SvgFilterLayer(
          isSourceAlpha: layer.isSourceAlpha || (previousLayer?.isSourceAlpha ?? false),
          sigmaX: layer.sigmaX,
          sigmaY: layer.sigmaY,
          dx: 0,
          dy: 0,
        );
        try {
          final AffineMatrix layerData = data.translated(layer.dx, layer.dy);
          final AffineMatrix layerNextTransform = textPositionNode.concatTransform(layerData);

          final resolvedChildren = <Node>[
            for (final Node child in textPositionNode.children)
              child.applyAttributes(textPositionNode.attributes).accept(this, layerNextTransform),
          ];
          return ResolvedTextPositionNode(
            textPositionNode.computeTextPosition(_bounds, layerData),
            resolvedChildren,
          );
        } finally {
          _currentLayer = previousLayer;
        }
      }

      final children = <Node>[];
      final SvgFilterLayer? previousLayer = _currentLayer;
      try {
        for (final SvgFilterLayer layer in filter.layers) {
          _currentLayer = SvgFilterLayer(
            isSourceAlpha: layer.isSourceAlpha || (previousLayer?.isSourceAlpha ?? false),
            sigmaX: layer.sigmaX,
            sigmaY: layer.sigmaY,
            dx: 0,
            dy: 0,
          );
          final AffineMatrix layerData = data.translated(layer.dx, layer.dy);
          final AffineMatrix layerNextTransform = textPositionNode.concatTransform(layerData);

          final resolvedChildren = <Node>[
            for (final Node child in textPositionNode.children)
              child.applyAttributes(textPositionNode.attributes).accept(this, layerNextTransform),
          ];

          children.add(
            ResolvedTextPositionNode(
              textPositionNode.computeTextPosition(_bounds, layerData),
              resolvedChildren,
            ),
          );
        }
        return ParentNode(SvgAttributes.empty, children: children);
      } finally {
        _currentLayer = previousLayer;
      }
    }

    return ResolvedTextPositionNode(textPositionNode.computeTextPosition(_bounds, data), <Node>[
      for (final Node child in textPositionNode.children)
        child.applyAttributes(textPositionNode.attributes).accept(this, nextTransform),
    ]);
  }

  @override
  Node visitTextNode(TextNode textNode, AffineMatrix data) {
    if (_currentLayer != null &&
        (_currentLayer!.isSourceAlpha || _currentLayer!.sigmaX > 0 || _currentLayer!.sigmaY > 0)) {
      final Paint? originalPaint = textNode.computePaint(_bounds, data);
      if (originalPaint == null) {
        return Node.empty;
      }
      final TextConfig textConfig = textNode.computeTextConfig(_bounds, data);
      if (textConfig.text.trim().isEmpty) {
        return Node.empty;
      }

      final Paint paint = _createLayerPaint(originalPaint, _currentLayer!, data);

      return ResolvedTextNode(textConfig: textConfig, paint: paint);
    }

    SvgFilter? filter;
    final String? filterId = textNode.attributes.filterId;
    if (filterId != null && _filterResolver != null) {
      filter = _filterResolver(filterId);
    }

    if (filter != null && filter.layers.isNotEmpty) {
      final Paint? originalPaint = textNode.computePaint(_bounds, data);
      if (originalPaint == null) {
        return Node.empty;
      }
      final TextConfig textConfig = textNode.computeTextConfig(_bounds, data);
      if (textConfig.text.trim().isEmpty) {
        return Node.empty;
      }

      if (filter.layers.length == 1) {
        return _resolveTextNodeForLayer(
          textNode,
          originalPaint,
          data,
          textConfig,
          filter.layers.first,
        );
      }

      final children = <Node>[];
      for (final SvgFilterLayer layer in filter.layers) {
        children.add(_resolveTextNodeForLayer(textNode, originalPaint, data, textConfig, layer));
      }
      return ParentNode(SvgAttributes.empty, children: children);
    }

    final Paint? paint = textNode.computePaint(_bounds, data);
    final TextConfig textConfig = textNode.computeTextConfig(_bounds, data);
    if (paint != null && textConfig.text.trim().isNotEmpty) {
      return ResolvedTextNode(textConfig: textConfig, paint: paint);
    }
    return Node.empty;
  }

  Node _resolveTextNodeForLayer(
    TextNode textNode,
    Paint originalPaint,
    AffineMatrix data,
    TextConfig textConfig,
    SvgFilterLayer layer,
  ) {
    final AffineMatrix layerData = data.translated(layer.dx, layer.dy);
    final TextConfig layerTextConfig = (layer.dx == 0 && layer.dy == 0)
        ? textConfig
        : textNode.computeTextConfig(_bounds, layerData);

    final Paint paint = _createLayerPaint(originalPaint, layer, data);

    return ResolvedTextNode(textConfig: layerTextConfig, paint: paint);
  }
  Gradient _blackenGradient(Gradient gradient) {
    if (gradient.colors == null) {
      return gradient;
    }
    if (_blackenedGradients.containsKey(gradient)) {
      return _blackenedGradients[gradient]!;
    }
    final List<Color> colors =
        gradient.colors!.map((Color c) => Color.fromARGB(c.a, 0, 0, 0)).toList();
    final Gradient newGradient;
    if (gradient is LinearGradient) {
      newGradient = LinearGradient(
        id: gradient.id,
        from: gradient.from,
        to: gradient.to,
        colors: colors,
        offsets: gradient.offsets,
        tileMode: gradient.tileMode,
        unitMode: gradient.unitMode,
        transform: gradient.transform,
      );
    } else if (gradient is RadialGradient) {
      newGradient = RadialGradient(
        id: gradient.id,
        center: gradient.center,
        radius: gradient.radius,
        colors: colors,
        offsets: gradient.offsets,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
        focalPoint: gradient.focalPoint,
        unitMode: gradient.unitMode,
      );
    } else {
      newGradient = gradient;
    }
    _blackenedGradients[gradient] = newGradient;
    return newGradient;
  }

  Paint _createLayerPaint(Paint originalPaint, SvgFilterLayer layer, [AffineMatrix transform = AffineMatrix.identity]) {
    final bool hasBlur = layer.sigmaX > 0 || layer.sigmaY > 0;
    final bool isSourceAlpha = layer.isSourceAlpha || (_currentLayer?.isSourceAlpha ?? false);
    return Paint(
      blendMode: originalPaint.blendMode,
      fill: isSourceAlpha
          ? (originalPaint.fill != null
                ? Fill(
                    color: Color.fromARGB(originalPaint.fill!.color.a, 0, 0, 0),
                    shader: originalPaint.fill!.shader != null
                        ? _blackenGradient(originalPaint.fill!.shader!)
                        : null,
                  )
                : null)
          : originalPaint.fill,
      stroke: isSourceAlpha
          ? (originalPaint.stroke != null
                ? Stroke(
                    color: Color.fromARGB(originalPaint.stroke!.color.a, 0, 0, 0),
                    shader: originalPaint.stroke!.shader != null
                        ? _blackenGradient(originalPaint.stroke!.shader!)
                        : null,
                    width: originalPaint.stroke!.width,
                    cap: originalPaint.stroke!.cap,
                    join: originalPaint.stroke!.join,
                    miterLimit: originalPaint.stroke!.miterLimit,
                  )
                : null)
          : originalPaint.stroke,
      filterBlurX: hasBlur ? layer.sigmaX * transform.xScale : null,
      filterBlurY: hasBlur ? layer.sigmaY * transform.yScale : null,
    );
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
          child.applyAttributes(viewportNode.attributes).accept(this, transform),
      ],
    );
  }

  @override
  Node visitDeferredNode(DeferredNode deferredNode, AffineMatrix data) {
    _deferredExpansionCount++;
    if (_deferredExpansionCount > kMaxReferenceExpansions) {
      throw StateError(kMaxReferenceExpansionsErrorMessage);
    }
    if (!_activeDeferred.add(deferredNode.refId)) {
      // Recursive loop detected.
      return Node.empty;
    }
    try {
      final AttributedNode? resolvedNode = deferredNode.resolver(deferredNode.refId);
      if (resolvedNode == null) {
        return Node.empty;
      }
      final Node concreteRef = resolvedNode.applyAttributes(deferredNode.attributes, replace: true);
      return concreteRef.accept(this, data);
    } finally {
      _activeDeferred.remove(deferredNode.refId);
    }
  }

  @override
  Node visitEmptyNode(Node node, AffineMatrix data) => node;

  @override
  Node visitResolvedText(ResolvedTextNode textNode, AffineMatrix data) {
    assert(false);
    return textNode;
  }

  @override
  Node visitResolvedTextPositionNode(ResolvedTextPositionNode textPositionNode, AffineMatrix data) {
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
  Node visitResolvedVerticesNode(ResolvedVerticesNode verticesNode, AffineMatrix data) {
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
      final data = ImageSizeData.fromBytes(imageNode.data);
      width ??= data.width.toDouble();
      height ??= data.height.toDouble();
    }
    final rect = Rect.fromLTWH(left, top, width, height);

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
  Node visitResolvedImageNode(ResolvedImageNode resolvedImageNode, AffineMatrix data) {
    assert(false);
    return resolvedImageNode;
  }

  @override
  Node visitPatternNode(PatternNode patternNode, AffineMatrix data) {
    _deferredExpansionCount++;
    if (_deferredExpansionCount > kMaxReferenceExpansions) {
      throw StateError(kMaxReferenceExpansionsErrorMessage);
    }
    if (!_activePatterns.add(patternNode.patternId)) {
      // Recursive loop detected.
      return patternNode.child.accept(this, data);
    }
    try {
      final AttributedNode? resolvedPattern = patternNode.resolver(patternNode.patternId);
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
    } finally {
      _activePatterns.remove(patternNode.patternId);
    }
  }

  @override
  Node visitResolvedPatternNode(ResolvedPatternNode patternNode, AffineMatrix data) {
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
  ResolvedTextNode({required this.textConfig, required this.paint});

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
  ResolvedPathNode({required this.paint, required this.bounds, required this.path});

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
  ResolvedVerticesNode({required this.paint, required this.vertices, required this.bounds})
    : assert(paint.stroke == null);

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
  ResolvedClipNode({required this.clips, required this.child});

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
    this.maskType,
  });

  /// The child to apply as a mask.
  final Node mask;

  /// The child of this mask layer.
  final Node child;

  /// The blend mode to apply when saving a layer for the mask, if any.
  final BlendMode? blendMode;

  /// The `mask-type` attribute of the mask, if any.
  final String? maskType;

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

/// Represents a layer in an SVG filter.
@immutable
class SvgFilterLayer {
  /// Creates a new [SvgFilterLayer].
  const SvgFilterLayer({
    required this.isSourceAlpha,
    required this.sigmaX,
    required this.sigmaY,
    required this.dx,
    required this.dy,
  });

  /// Whether this layer is derived from the alpha channel of the source.
  final bool isSourceAlpha;

  /// The standard deviation along the X axis for the blur.
  final double sigmaX;

  /// The standard deviation along the Y axis for the blur.
  final double sigmaY;

  /// The horizontal offset.
  final double dx;

  /// The vertical offset.
  final double dy;

  /// Whether this layer has any visual effect (blur or offset).
  bool get hasEffect => sigmaX > 0 || sigmaY > 0 || dx != 0 || dy != 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SvgFilterLayer &&
          runtimeType == other.runtimeType &&
          isSourceAlpha == other.isSourceAlpha &&
          sigmaX == other.sigmaX &&
          sigmaY == other.sigmaY &&
          dx == other.dx &&
          dy == other.dy;

  @override
  int get hashCode => Object.hash(isSourceAlpha, sigmaX, sigmaY, dx, dy);
}

/// Represents an SVG filter containing one or more layers.
@immutable
class SvgFilter {
  /// Creates a new [SvgFilter] with the given [layers].
  const SvgFilter(this.layers);

  /// The layers of this filter, to be drawn sequentially.
  final List<SvgFilterLayer> layers;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SvgFilter && runtimeType == other.runtimeType && listEquals(layers, other.layers);

  @override
  int get hashCode => Object.hashAll(layers);
}
