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

  /// Visit a [TextNode].
  S visitTextNode(TextNode textNode, V data);

  /// Visit a [PathNode].
  S visitPathNode(PathNode pathNode, V data);

  /// Visit a [ParentNode].
  S visitParentNode(ParentNode parentNode, V data);

  /// Visit a [DeferredNode].
  S visitDeferredNode(DeferredNode deferredNode, V data);

  /// Visit a [Node] that has no meaningful content.
  S visitEmptyNode(Node node, V data);

  /// Visit a [ResolvedTextNode].
  S visitResolvedText(ResolvedTextNode textNode, V data);

  /// Visit a [ResolvedPathNode].
  S visitResolvedPath(ResolvedPathNode pathNode, V data);

  /// Visit a [ResolvedClipNode].
  S visitResolvedClipNode(ResolvedClipNode clipNode, V data);

  /// Visit a [ResolvedMaskNode].
  S visitResolvedMaskNode(ResolvedMaskNode maskNode, V data);

  /// Visit a [SaveLayerNode].
  S visitSaveLayerNode(SaveLayerNode layerNode, V data);
}

/// A visitor that builds up a [VectorInstructions] for binary encoding.
class CommandBuilderVisitor extends Visitor<void, void> {
  final DrawCommandBuilder _builder = DrawCommandBuilder();
  late double _width;
  late double _height;

  /// Return the vector instructions encoded by the visitor given to this tree.
  VectorInstructions toInstructions() {
    return _builder.toInstructions(_width, _height);
  }

  @override
  void visitClipNode(ClipNode clipNode, void data) {
    assert(false);
  }

  @override
  void visitDeferredNode(DeferredNode deferredNode, void data) {
    assert(false);
  }

  @override
  void visitEmptyNode(Node node, void data) {}

  @override
  void visitMaskNode(MaskNode maskNode, void data) {
    assert(false);
  }

  @override
  void visitParentNode(ParentNode parentNode, void data) {
    for (Node child in parentNode.children) {
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
    _builder.addPath(pathNode.path, pathNode.paint, null);
  }

  @override
  void visitResolvedText(ResolvedTextNode textNode, void data) {
    _builder.addText(textNode.textConfig, textNode.paint, null);
  }

  @override
  void visitTextNode(TextNode textNode, void data) {
    assert(false);
  }

  @override
  void visitViewportNode(ViewportNode viewportNode, void data) {
    _width = viewportNode.width;
    _height = viewportNode.height;
    for (Node child in viewportNode.children) {
      child.accept(this, data);
    }
  }

  @override
  void visitSaveLayerNode(SaveLayerNode layerNode, void data) {
    _builder.addSaveLayer(layerNode.paint);
    for (Node child in layerNode.children) {
      child.accept(this, data);
    }
    _builder.restore();
  }
}
