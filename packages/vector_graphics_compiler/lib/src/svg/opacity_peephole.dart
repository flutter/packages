// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'parser.dart';
import 'resolver.dart';
import 'visitor.dart';
import '../geometry/basic_types.dart';
import '../paint.dart';
import 'node.dart';

class _Result {
  _Result(this.canForwardOpacity, this.node, this.bounds);

  final bool canForwardOpacity;
  final Node node;
  final List<Rect> bounds;
}

class _ForwardResult {
  _ForwardResult(this.opacity, this.blendMode);

  final double opacity;
  final BlendMode? blendMode;
}

class _OpacityForwarder extends Visitor<Node, _ForwardResult>
    with ErrorOnUnResolvedNode<Node, _ForwardResult> {
  const _OpacityForwarder();

  @override
  Node visitEmptyNode(Node node, _ForwardResult data) {
    return node;
  }

  @override
  Node visitParentNode(ParentNode parentNode, _ForwardResult data) {
    return ParentNode(
      SvgAttributes.empty,
      children: <Node>[
        for (Node child in parentNode.children) child.accept(this, data),
      ],
    );
  }

  @override
  Node visitResolvedClipNode(ResolvedClipNode clipNode, _ForwardResult data) {
    assert(clipNode.clips.length == 1);
    return ResolvedClipNode(
      clips: clipNode.clips,
      child: clipNode.child.accept(this, data),
    );
  }

  @override
  Node visitResolvedMaskNode(ResolvedMaskNode maskNode, _ForwardResult data) {
    throw UnsupportedError('Cannot forward opacity through a mask node');
  }

  @override
  Node visitResolvedPath(ResolvedPathNode pathNode, _ForwardResult data) {
    final Fill? oldFill = pathNode.paint.fill;
    final Stroke? oldStroke = pathNode.paint.stroke;
    Fill? fill;
    Stroke? stroke;
    if (oldFill != null) {
      fill = Fill(
        color:
            oldFill.color.withOpacity(data.opacity * (oldFill.color.a / 255)),
        shader: oldFill.shader,
      );
    }
    if (oldStroke != null) {
      stroke = Stroke(
        color: oldStroke.color
            .withOpacity(data.opacity * (oldStroke.color.a / 255)),
        shader: oldStroke.shader,
        cap: oldStroke.cap,
        join: oldStroke.join,
        miterLimit: oldStroke.miterLimit,
        width: oldStroke.width,
      );
    }
    return ResolvedPathNode(
      paint: Paint(
        blendMode: data.blendMode ?? pathNode.paint.blendMode,
        stroke: stroke,
        fill: fill,
      ),
      bounds: pathNode.bounds,
      path: pathNode.path,
    );
  }

  @override
  Node visitResolvedText(ResolvedTextNode textNode, _ForwardResult data) {
    throw UnsupportedError('Cannot forward opacity through a mask node');
  }

  @override
  Node visitSaveLayerNode(SaveLayerNode layerNode, _ForwardResult data) {
    final double opacity = (layerNode.paint.fill?.color.a ?? 255) / 255.0;
    final _ForwardResult result =
        _ForwardResult(data.opacity * opacity, data.blendMode);
    return ParentNode(SvgAttributes.empty, children: <Node>[
      for (Node child in layerNode.children) child.accept(this, result)
    ]);
  }

  @override
  Node visitViewportNode(ViewportNode viewportNode, _ForwardResult data) {
    throw UnsupportedError('Cannot forward opacity through a viewport node');
  }

  @override
  Node visitResolvedVerticesNode(
      ResolvedVerticesNode verticesNode, _ForwardResult data) {
    // TODO: find a way to use tighter bounds from the vertices.
    return ResolvedVerticesNode(
      paint: Paint(
        blendMode: data.blendMode ?? verticesNode.paint.blendMode,
        fill: Fill(
          color: verticesNode.paint.fill!.color.withOpacity(
              data.opacity * (verticesNode.paint.fill!.color.a / 255)),
          shader: verticesNode.paint.fill!.shader,
        ),
      ),
      vertices: verticesNode.vertices,
      bounds: verticesNode.bounds,
    );
  }

  @override
  Node visitResolvedImageNode(
      ResolvedImageNode resolvedImageNode, _ForwardResult data) {
    throw UnsupportedError('Cannot forward opacity through an image node');
  }

  @override
  Node visitResolvedPatternNode(
      ResolvedPatternNode patternNode, _ForwardResult data) {
    throw UnsupportedError('Cannot forward opacity through a pattern node');
  }
}

/// This visitor will process the tree and apply opacity forward.
class OpacityPeepholeOptimizer extends Visitor<_Result, void>
    with ErrorOnUnResolvedNode<_Result, void> {
  /// Apply the optimization to the given node tree.
  Node apply(Node node) {
    final _Result _result = node.accept(this, null);
    return _result.node;
  }

  @override
  _Result visitEmptyNode(Node node, void data) {
    return _Result(true, node, <Rect>[Rect.zero]);
  }

  @override
  _Result visitParentNode(ParentNode parentNode, void data) {
    final List<_Result> childResults = <_Result>[
      for (Node child in parentNode.children) child.accept(this, data)
    ];
    bool canForwardOpacity = true;
    for (_Result result in childResults) {
      if (!result.canForwardOpacity) {
        canForwardOpacity = false;
      }
    }
    final List<Node> children =
        childResults.map((_Result result) => result.node).toList();
    final List<Rect> bounds = childResults
        .map((_Result result) => result.bounds)
        .expand((List<Rect> bounds) => bounds)
        .toList();

    return _Result(
      canForwardOpacity,
      ParentNode(
        SvgAttributes.empty,
        children: children,
      ),
      bounds,
    );
  }

  @override
  _Result visitResolvedClipNode(ResolvedClipNode clipNode, void data) {
    // If there are multiple clip paths, then we don't currently know how to calculate
    // the exact bounds.
    final Node child = clipNode.child.accept(this, data).node;
    if (clipNode.clips.length > 1) {
      return _Result(
        false,
        ResolvedClipNode(
          child: child,
          clips: clipNode.clips,
        ),
        <Rect>[],
      );
    }
    return _Result(
      true,
      ResolvedClipNode(
        child: child,
        clips: clipNode.clips,
      ),
      <Rect>[
        clipNode.clips.single.bounds(),
      ],
    );
  }

  @override
  _Result visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    // We don't currently know how to compute bounds for a mask.
    // Don't process children to avoid breaking mask.
    return _Result(false, maskNode, <Rect>[]);
  }

  @override
  _Result visitResolvedPath(ResolvedPathNode pathNode, void data) {
    return _Result(
      pathNode.paint.blendMode == BlendMode.srcOver,
      pathNode,
      <Rect>[pathNode.bounds],
    );
  }

  @override
  _Result visitResolvedText(ResolvedTextNode textNode, void data) {
    // Text cannot apply the opacity optimization since we cannot accurately
    // learn its bounds ahead of time.
    return _Result(false, textNode, <Rect>[]);
  }

  @override
  _Result visitSaveLayerNode(SaveLayerNode layerNode, void data) {
    final List<_Result> childResults = <_Result>[
      for (Node child in layerNode.children) child.accept(this, data)
    ];
    bool canForwardOpacity = true;
    for (_Result result in childResults) {
      if (!result.canForwardOpacity) {
        canForwardOpacity = false;
      }
    }

    final List<Rect> flattenedBounds = childResults
        .map((_Result result) => result.bounds)
        .expand((List<Rect> rects) => rects)
        .toList();
    for (int i = 0; i < flattenedBounds.length; i++) {
      final Rect current = flattenedBounds[i];
      for (int j = 0; j < flattenedBounds.length; j++) {
        if (i == j) {
          continue;
        }
        final Rect candidate = flattenedBounds[j];
        if (candidate.intersects(current)) {
          canForwardOpacity = false;
        }
      }
    }

    if (!canForwardOpacity) {
      return _Result(
        false,
        SaveLayerNode(SvgAttributes.empty,
            paint: layerNode.paint,
            children: <Node>[for (_Result result in childResults) result.node]),
        <Rect>[],
      );
    }
    final double opacity = layerNode.paint.fill!.color.a / 255;
    final Node result = ParentNode(
      SvgAttributes.empty,
      children: <Node>[
        for (_Result result in childResults)
          result.node.accept(
            const _OpacityForwarder(),
            _ForwardResult(
              opacity,
              layerNode.paint.blendMode,
            ),
          ),
      ],
    );
    return _Result(canForwardOpacity, result, flattenedBounds);
  }

  @override
  _Result visitViewportNode(ViewportNode viewportNode, void data) {
    final ViewportNode node = ViewportNode(
      viewportNode.attributes,
      width: viewportNode.width,
      height: viewportNode.height,
      transform: viewportNode.transform,
      children: <Node>[
        for (Node child in viewportNode.children) child.accept(this, null).node
      ],
    );
    return _Result(false, node, <Rect>[]);
  }

  @override
  _Result visitResolvedVerticesNode(
      ResolvedVerticesNode verticesNode, void data) {
    return _Result(
      verticesNode.paint.blendMode == BlendMode.srcOver,
      verticesNode,
      <Rect>[verticesNode.bounds],
    );
  }

  @override
  _Result visitResolvedImageNode(
      ResolvedImageNode resolvedImageNode, void data) {
    return _Result(false, resolvedImageNode, <Rect>[]);
  }

  @override
  _Result visitResolvedPatternNode(ResolvedPatternNode patternNode, void data) {
    return _Result(false, patternNode, <Rect>[]);
  }
}
