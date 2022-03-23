import 'package:vector_graphics_compiler/src/svg/parser.dart';

import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import '../paint.dart';

/// A node in a tree of graphics operations.
///
/// Nodes describe painting attributes, clips, transformations, paths, and
/// vertices to draw in depth-first order.
abstract class Node {
  /// Constructs a new tree node with [id].
  const Node({this.id});

  /// An identifier for this path, generally taken from the original SVG file.
  ///
  /// This ID is unique for conformant SVGs. However, uniqueness is not enforced
  /// or guaranteed.
  final String? id;

  /// Calls `build` for all nodes contained in this subtree with the
  /// specified `transform` in painting order.
  ///
  /// The transform will be multiplied with any transforms present on
  /// [ParentNode]s in the subtree, and applied to any [Path] objects in leaf
  /// nodes in the tree. It may be [AffineMatrix.identity] to indicate that no
  /// additional transformation is needed.
  void build(DrawCommandBuilder builder, AffineMatrix transform);
}

/// A node that has painting properties in the tree of graphics operations.
abstract class PaintingNode extends Node {
  /// Constructs a new tree node with [id] and [paint].
  const PaintingNode({
    String? id,
    this.paint,
  }) : super(id: id);

  /// A collection of painting attributes.
  ///
  /// Painting attributes inherit down the tree. Leaf nodes have non-null paints
  /// and must not have empty fills or strokes, but may have a null fill or a
  /// null stroke.
  final Paint? paint;

  /// Creates a new compatible node with this as if the `newPaint` had
  /// the current paint applied as a parent.
  Node adoptPaint(Paint? newPaint);
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
  ViewportNode({
    String? id,
    required this.width,
    required this.height,
    Paint? paint,
    AffineMatrix? transform,
  }) : super(
          id: id,
          paint: paint,
          transform: transform,
        );

  /// The width of the viewport in pixels.
  final double width;

  /// The height of the viewport in pixels.
  final double height;

  /// The viewport rect described by [width] and [height].
  Rect get viewport => Rect.fromLTWH(0, 0, width, height);

  @override
  Node adoptPaint(Paint? newPaint) {
    return ViewportNode(
      width: width,
      height: height,
      id: id,
      transform: transform,
      paint: newPaint?.applyParent(paint),
    ).._children.addAll(_children);
  }
}

/// The signature for a visitor callback to [ParentNode.visitChildren].
typedef NodeCallback = void Function(Node child);

/// A node that contains children, transformed by [transform] and provided a
/// default [color].
class ParentNode extends PaintingNode {
  /// Creates a new [ParentNode].
  ParentNode({
    String? id,
    Paint? paint,
    this.transform,
    this.color,
  }) : super(id: id, paint: paint);

  /// The transform to apply to this subtree, if any.
  final AffineMatrix? transform;

  /// The child nodes of this node.
  final List<Node> _children = <Node>[];

  /// The color, if any, to pass on to children for inheritence purposes.
  ///
  /// This color will be applied to any [Stroke] or [Fill] properties on child
  /// paints.
  final Color? color;

  /// Calls `visitor` for each child node of this parent group.
  ///
  /// This call does not recursively call `visitChildren`. Callers must decide
  /// whether to do BFS or DFS by calling `visitChildren` if the visited child
  /// is a [ParentNode].
  void visitChildren(NodeCallback visitor) {
    _children.forEach(visitor);
  }

  /// Adds a child to this parent node.
  ///
  /// If `clips` is empty, the child is directly appended. Otherwise, a
  /// [ClipNode] is inserted.
  void addChild(Node child, List<Path> clips) {
    if (clips.isEmpty) {
      _children.add(child);
    } else {
      _children.add(ClipNode(clips: clips, child: child));
    }
  }

  @override
  Node adoptPaint(Paint? newPaint) {
    return ParentNode(
      id: id,
      transform: transform,
      color: color,
      paint: newPaint?.applyParent(paint),
    ).._children.addAll(_children);
  }

  // Whether or not a save layer should be inserted at this node.
  bool _requiresSaveLayer() {
    final Paint? localPaint = paint;
    if (localPaint == null) {
      return false;
    }
    final Fill? fill = localPaint.fill;
    if (fill == null) {
      return false;
    }
    if (fill.shader != null) {
      return true;
    }
    if (localPaint.blendMode == null) {
      return false;
    }
    return fill.color == null || fill.color != const Color(0xFF000000);
  }

  @override
  void build(DrawCommandBuilder builder, AffineMatrix transform) {
    final bool requiresLayer = _requiresSaveLayer();
    if (requiresLayer) {
      builder.addSaveLayer(paint!);
    }
    final AffineMatrix nextTransform = this.transform == null
        ? transform
        : transform.multiplied(this.transform!);
    for (final Node child in _children) {
      child.build(builder, nextTransform);
    }

    if (requiresLayer) {
      builder.restore();
    }
  }
}

/// A parent node that applies a clip to its children.
class ClipNode extends Node {
  /// Creates a new clip node that applies [clip] to [child].
  ClipNode({required this.child, required this.clips, String? id})
      : assert(
          clips.isNotEmpty,
          'Do not use a ClipNode without any clip paths.',
        ),
        super(id: id);

  /// The clips to apply to the child node.
  ///
  /// Normally, there will only be one clip to apply. However, if multiple paths
  /// with differeing [PathFillType]s are used, multiple clips must be
  /// specified.
  final List<Path> clips;

  /// The child to clip.
  final Node child;

  @override
  void build(DrawCommandBuilder builder, AffineMatrix transform) {
    for (final Path clip in clips) {
      final Path transformedClip = clip.transformed(transform);
      builder.addClip(transformedClip);
      child.build(builder, transform);
      builder.restore();
    }
  }
}

/// A leaf node in the graphics tree.
///
/// Leaf nodes get added with all paint and transform accumulations from their
/// parents applied.
class PathNode extends PaintingNode {
  /// Creates a new leaf node for the graphics tree with the specified [path],
  /// [id], and [paint].
  PathNode(
    this.path, {
    String? id,
    required Paint paint,
  })  : assert(
          paint != Paint.empty,
          'Do not use empty paints on leaf nodes',
        ),
        assert(
          paint.fill != Fill.empty || paint.stroke != Stroke.empty,
          'Do not use empty fills on leaf nodes',
        ),
        super(id: id, paint: paint);

  /// The description of the geometry this leaf node draws.
  final Path path;

  @override
  Node adoptPaint(Paint? newPaint) {
    return PathNode(
      path,
      id: id,
      paint: newPaint?.applyParent(paint!) ?? paint!,
    );
  }

  @override
  void build(DrawCommandBuilder builder, AffineMatrix transform) {
    final Path transformedPath = path.transformed(transform);
    final Rect bounds = transformedPath.bounds();
    builder.addPath(transformedPath, paint!.applyBounds(bounds, transform), id);
  }
}
