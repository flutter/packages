import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import '../paint.dart';
import '../vector_instructions.dart';

/// A node in a tree of graphics operations.
///
/// Nodess describe painting attributes, transformations, paths, and vertices
/// to draw in depth-first order.
abstract class Node {
  /// Constructs a new tree node with
  const Node({
    this.id,
    this.paint,
    this.parent,
  });

  final String? id;
  final Paint? paint;
  final ParentNode? parent;

  /// Creates a new compatible node with this as if the `newPaint` had
  /// the current paint applied as a parent.
  Node adoptPaint(Paint? newPaint);

  bool get hasPaint => paint != null && !paint!.isEmpty;

  void addPaths(VectorInstructions instructions, AffineMatrix transform);
}

class ViewportNode extends ParentNode {
  const ViewportNode({
    String? id,
    required this.width,
    required this.height,
    Paint? paint,
    required List<Node> children,
    ParentNode? parent,
    AffineMatrix? transform,
  }) : super(
          id: id,
          children: children,
          paint: paint,
          transform: transform,
          parent: parent,
        );

  final double width;
  final double height;

  Rect get viewport => Rect.fromLTWH(0, 0, width, height);

  @override
  Node adoptPaint(Paint? newPaint) {
    return ViewportNode(
      width: width,
      height: height,
      children: children,
      id: id,
      transform: transform,
      parent: parent,
      paint: newPaint?.applyParent(paint),
    );
  }
}

class ParentNode extends Node {
  const ParentNode({
    String? id,
    Paint? paint,
    required this.children,
    ParentNode? parent,
    this.transform,
    this.color,
  }) : super(id: id, paint: paint, parent: parent);

  final AffineMatrix? transform;
  final List<Node> children;
  final Color? color;
  @override
  Node adoptPaint(Paint? newPaint) {
    return ParentNode(
      children: children,
      id: id,
      parent: parent,
      transform: transform,
      color: color,
      paint: newPaint?.applyParent(paint),
    );
  }

  @override
  void addPaths(VectorInstructions instructions, AffineMatrix transform) {
    for (final Node child in children) {
      child.addPaths(instructions, transform);
    }
  }
}

class PathNode extends Node {
  PathNode(
    this.path, {
    String? id,
    required ParentNode? parent,
    required Paint paint,
  })  : assert(!paint.isEmpty),
        super(id: id, paint: paint, parent: parent);

  final Path path;

  @override
  Node adoptPaint(Paint? newPaint) {
    return PathNode(
      path,
      id: id,
      parent: parent,
      paint: newPaint?.applyParent(paint!) ?? paint!,
    );
  }

  @override
  void addPaths(VectorInstructions instructions, AffineMatrix transform) {
    // print(transform);
    instructions.addDrawPath(path.transformed(transform), paint!, id);
  }
}
