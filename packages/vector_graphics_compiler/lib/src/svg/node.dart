import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
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

/// A node that has attributes in the tree of graphics operations.
abstract class AttributedNode extends Node {
  /// Constructs a new tree node with [id] and [paint].
  AttributedNode(this.attributes);

  /// A collection of painting attributes.
  ///
  /// Painting attributes inherit down the tree.
  final SvgAttributes attributes;

  /// Creates a new compatible node with this as if the `newPaint` had
  /// the current paint applied as a parent.
  AttributedNode applyAttributes(SvgAttributes newAttributes);
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
    SvgAttributes attributes, {
    required this.width,
    required this.height,
    required AffineMatrix transform,
    List<Node>? children,
  }) : super(
          attributes,
          precalculatedTransform: transform,
          children: children,
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
    SvgAttributes attributes, {
    AffineMatrix? precalculatedTransform,
    List<Node>? children,
  })  : transform = precalculatedTransform ?? attributes.transform,
        _children = children ?? <Node>[],
        super(attributes);

  /// The transform to apply to this subtree, if any.
  final AffineMatrix transform;

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
    required Resolver<List<Path>> clipResolver,
    required Resolver<AttributedNode?> maskResolver,
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
    _children.add(wrappedChild);
  }

  @override
  AffineMatrix concatTransform(AffineMatrix currentTransform) {
    if (transform == AffineMatrix.identity) {
      return currentTransform;
    }
    return currentTransform.multiplied(transform);
  }

  @override
  AttributedNode applyAttributes(SvgAttributes newAttributes) {
    return ParentNode(
      newAttributes.applyParent(attributes),
      precalculatedTransform: transform,
    ).._children.addAll(_children);
  }

  /// Create the paint required to draw a save layer, or `null` if none is
  /// required.
  Paint? createLayerPaint() {
    final bool needsLayer = attributes.blendMode != null ||
        (attributes.opacity != null &&
            attributes.opacity != 1.0 &&
            attributes.opacity != 0.0);
    if (needsLayer) {
      return Paint(
        blendMode: attributes.blendMode,
        fill: attributes.fill!.toFill(Rect.largest, transform) ??
            Fill(
              color: Color.opaqueBlack.withOpacity(attributes.opacity ?? 1.0),
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

/// A parent node that applies a save layer to its children.
class SaveLayerNode extends ParentNode {
  /// Create a new [SaveLayerNode]
  SaveLayerNode(
    SvgAttributes attributes, {
    required this.paint,
    List<Node>? children,
  }) : super(attributes,
            children: children, precalculatedTransform: AffineMatrix.identity);

  /// The paint to apply to the saved layer.
  final Paint paint;

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitSaveLayerNode(this, data);
  }
}

/// A parent node that applies a clip to its children.
class ClipNode extends Node {
  /// Creates a new clip node that applies clip paths to [child].
  ClipNode({
    required this.resolver,
    required this.child,
    required this.clipId,
    required this.transform,
    String? id,
  });

  /// Called by [build] to resolve [clipId] to a list of paths.
  final Resolver<List<Path>> resolver;

  /// The clips to apply to the child node.
  ///
  /// Normally, there will only be one clip to apply. However, if multiple paths
  /// with differeing [PathFillType]s are used, multiple clips must be
  /// specified.
  final String clipId;

  /// The child to clip.
  final Node child;

  /// The decendant child's transform
  final AffineMatrix transform;

  @override
  AffineMatrix concatTransform(AffineMatrix currentTransform) {
    if (transform == AffineMatrix.identity) {
      return currentTransform;
    }
    return currentTransform.multiplied(transform);
  }

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitClipNode(this, data);
  }
}

/// A parent node that applies a mask to its child.
class MaskNode extends Node {
  /// Creates a new mask node that applies [mask] to [child] using [blendMode].
  MaskNode({
    required this.child,
    required this.maskId,
    this.blendMode,
    required this.resolver,
    required this.transform,
  });

  /// The mask to apply.
  final String maskId;

  /// The child to mask.
  final Node child;

  /// The blend mode to apply when saving a layer for the mask, if any.
  final BlendMode? blendMode;

  /// The decendant child's transform
  final AffineMatrix transform;

  /// Called by [build] to resolve [maskId] to an [AttributedNode].
  final Resolver<AttributedNode?> resolver;

  @override
  AffineMatrix concatTransform(AffineMatrix currentTransform) {
    if (transform == AffineMatrix.identity) {
      return currentTransform;
    }
    return currentTransform.multiplied(transform);
  }

  @override
  void visitChildren(NodeCallback visitor) {
    visitor(child);
  }

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitMaskNode(this, data);
  }
}

/// A leaf node in the graphics tree.
///
/// Leaf nodes get added with all paint and transform accumulations from their
/// parents applied.
class PathNode extends AttributedNode {
  /// Creates a new leaf node for the graphics tree with the specified [path]
  /// and attributes
  PathNode(this.path, SvgAttributes attributes) : super(attributes);

  /// The description of the geometry this leaf node draws.
  final Path path;

  /// Compute the paint used by this Path.
  Paint? computePaint(Rect bounds, AffineMatrix transform) {
    final Fill? fill = attributes.fill?.toFill(bounds, transform);
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

  @override
  AttributedNode applyAttributes(SvgAttributes newAttributes) {
    return PathNode(
      path,
      attributes.applyParent(newAttributes),
    );
  }

  @override
  void visitChildren(NodeCallback visitor) {}

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitPathNode(this, data);
  }
}

/// A node that refers to another node, and uses [resolver] at [build] time
/// to materialize the referenced node into the tree.
class DeferredNode extends AttributedNode {
  /// Creates a new deferred node with [attributes] that will call [resolver]
  /// with [refId] at [build] time.
  DeferredNode(
    SvgAttributes attributes, {
    required this.refId,
    required this.resolver,
  }) : super(attributes);

  /// The reference id to pass to [resolver].
  final String refId;

  /// The callback that materializes an [AttributedNode] for [refId] at [build]
  /// time.
  final Resolver<AttributedNode?> resolver;

  @override
  AttributedNode applyAttributes(SvgAttributes newAttributes) {
    return DeferredNode(
      attributes.applyParent(newAttributes),
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
    this.baseline,
    this.absolute,
    this.fontSize,
    this.fontWeight,
    SvgAttributes attributes,
  ) : super(attributes);

  /// The text this node contains.
  final String text;

  /// The x, y coordinate of the starting point of the text baseline.
  final Point baseline;

  /// Whether the [baseline] is in absolute or relative units.
  final bool absolute;

  /// The font weight to use.
  final FontWeight fontWeight;

  /// The text node's font size.
  final double fontSize;

  /// Compute the [Paint] that this text node uses.
  Paint? computePaint(Rect bounds, AffineMatrix transform) {
    final Fill? fill = attributes.fill?.toFill(bounds, transform);
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
    final Point newBaseline = absolute
        ? baseline
        : Point(baseline.x * bounds.width, baseline.y * bounds.height);

    return TextConfig(
      text,
      transform.transformPoint(newBaseline),
      attributes.fontFamily,
      fontWeight,
      fontSize,
      attributes.transform,
    );
  }

  @override
  AttributedNode applyAttributes(SvgAttributes newAttributes) {
    return TextNode(
      text,
      baseline,
      absolute,
      fontSize,
      fontWeight,
      attributes.applyParent(newAttributes),
    );
  }

  @override
  void visitChildren(NodeCallback visitor) {}

  @override
  S accept<S, V>(Visitor<S, V> visitor, V data) {
    return visitor.visitTextNode(this, data);
  }
}
