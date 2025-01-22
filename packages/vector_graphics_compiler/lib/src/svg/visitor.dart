// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../draw_command_builder.dart';
import '../geometry/path.dart';
import '../paint.dart';
import '../vector_instructions.dart';
import 'node.dart';
import 'resolver.dart';

/// A visitor implementation used to process the tree.
abstract class Visitor<S, V> {
  /// Const constructor so subclasses can be const.
  const Visitor();

  /// Visit a [ViewportNode].
  S visitViewportNode(ViewportNode viewportNode, V data);

  /// Visit a [MaskNode].
  S visitMaskNode(MaskNode maskNode, V data);

  /// Visit a [ClipNode].
  S visitClipNode(ClipNode clipNode, V data);

  /// Visit a [TextPositionNode].
  S visitTextPositionNode(TextPositionNode textPositionNode, V data);

  /// Visit a [TextNode].
  S visitTextNode(TextNode textNode, V data);

  /// VIsit an [ImageNode].
  S visitImageNode(ImageNode imageNode, V data);

  /// Visit a [PathNode].
  S visitPathNode(PathNode pathNode, V data);

  /// Visit a [ParentNode].
  S visitParentNode(ParentNode parentNode, V data);

  /// Visit a [DeferredNode].
  S visitDeferredNode(DeferredNode deferredNode, V data);

  /// Visit a [Node] that has no meaningful content.
  S visitEmptyNode(Node node, V data);

  /// Visit a [PatternNode].
  S visitPatternNode(PatternNode patternNode, V data);

  /// Visit a [ResolvedTextPositionNode].
  S visitResolvedTextPositionNode(
      ResolvedTextPositionNode textPositionNode, V data);

  /// Visit a [ResolvedTextNode].
  S visitResolvedText(ResolvedTextNode textNode, V data);

  /// Visit a [ResolvedPathNode].
  S visitResolvedPath(ResolvedPathNode pathNode, V data);

  /// Visit a [ResolvedClipNode].
  S visitResolvedClipNode(ResolvedClipNode clipNode, V data);

  /// Visit a [ResolvedMaskNode].
  S visitResolvedMaskNode(ResolvedMaskNode maskNode, V data);

  /// Visit a [ResolvedImageNode].
  S visitResolvedImageNode(ResolvedImageNode resolvedImageNode, V data);

  /// Visit a [SaveLayerNode].
  S visitSaveLayerNode(SaveLayerNode layerNode, V data);

  /// Visit a [ResolvedVerticesNode].
  S visitResolvedVerticesNode(ResolvedVerticesNode verticesNode, V data);

  /// Visit a [ResolvedPatternNode].
  S visitResolvedPatternNode(ResolvedPatternNode patternNode, V data);
}

/// A mixin that can be applied to a [Visitor] that makes visiting an
/// unreloved [Node] an error.
mixin ErrorOnUnResolvedNode<S, V> on Visitor<S, V> {
  String get _message => 'Cannot visit unresolved nodes with $this';

  @override
  S visitDeferredNode(DeferredNode deferredNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitMaskNode(MaskNode maskNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitClipNode(ClipNode clipNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitTextPositionNode(TextPositionNode textPositionNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitTextNode(TextNode textNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitPathNode(PathNode pathNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitImageNode(ImageNode imageNode, V data) {
    throw UnsupportedError(_message);
  }

  @override
  S visitPatternNode(PatternNode patternNode, V data) {
    throw UnsupportedError(_message);
  }
}

/// A visitor that builds up a [VectorInstructions] for binary encoding.
class CommandBuilderVisitor extends Visitor<void, void>
    with ErrorOnUnResolvedNode<void, void> {
  final DrawCommandBuilder _builder = DrawCommandBuilder();
  late double _width;
  late double _height;

  /// The current patternId. This will be `null` if
  /// there is no current pattern.
  Object? currentPatternId;

  /// Return the vector instructions encoded by the visitor given to this tree.
  VectorInstructions toInstructions() {
    return _builder.toInstructions(_width, _height);
  }

  @override
  void visitEmptyNode(Node node, void data) {}

  @override
  void visitParentNode(ParentNode parentNode, void data) {
    for (final Node child in parentNode.children) {
      child.accept(this, data);
    }
  }

  @override
  void visitPathNode(PathNode pathNode, void data) {
    assert(false);
  }

  @override
  void visitResolvedClipNode(ResolvedClipNode clipNode, void data) {
    for (final Path clip in clipNode.clips) {
      _builder.addClip(clip);
      clipNode.child.accept(this, data);
      _builder.restore();
    }
  }

  @override
  void visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    _builder.addSaveLayer(Paint(
      blendMode: maskNode.blendMode,
      fill: const Fill(),
    ));
    maskNode.child.accept(this, data);
    _builder.addMask();
    maskNode.mask.accept(this, data);
    _builder.restore();
    _builder.restore();
  }

  @override
  void visitResolvedPath(ResolvedPathNode pathNode, void data) {
    _builder.addPath(pathNode.path, pathNode.paint, null, currentPatternId);
  }

  @override
  void visitResolvedTextPositionNode(
      ResolvedTextPositionNode textPositionNode, void data) {
    _builder.updateTextPosition(textPositionNode.textPosition);
    textPositionNode.visitChildren((Node child) {
      child.accept(this, data);
    });
  }

  @override
  void visitResolvedText(ResolvedTextNode textNode, void data) {
    _builder.addText(
        textNode.textConfig, textNode.paint, null, currentPatternId);
  }

  @override
  void visitViewportNode(ViewportNode viewportNode, void data) {
    _width = viewportNode.width;
    _height = viewportNode.height;
    for (final Node child in viewportNode.children) {
      child.accept(this, data);
    }
  }

  @override
  void visitSaveLayerNode(SaveLayerNode layerNode, void data) {
    _builder.addSaveLayer(layerNode.paint);
    for (final Node child in layerNode.children) {
      child.accept(this, data);
    }
    _builder.restore();
  }

  @override
  void visitResolvedVerticesNode(ResolvedVerticesNode verticesNode, void data) {
    _builder.addVertices(verticesNode.vertices, verticesNode.paint);
  }

  @override
  void visitResolvedImageNode(ResolvedImageNode resolvedImageNode, void data) {
    _builder.addImage(resolvedImageNode, null);
  }

  @override
  void visitResolvedPatternNode(ResolvedPatternNode patternNode, void data) {
    _builder.addPattern(
      patternNode.id,
      x: patternNode.x,
      y: patternNode.y,
      width: patternNode.width,
      height: patternNode.height,
      transform: patternNode.transform,
    );
    patternNode.pattern.accept(this, data);
    _builder.restore();
    currentPatternId = patternNode.id;
    patternNode.child.accept(this, data);
    currentPatternId = null;
  }
}
