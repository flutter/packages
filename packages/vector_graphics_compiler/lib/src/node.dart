import 'geometry/matrix.dart';
import 'geometry/path.dart';
import 'geometry/vertices.dart';
import 'paint.dart';

abstract class Visitor {
  void pushTransform(AffineMatrix transform);
  void popTransform();

  void pushPaint(Paint paint);
  void popPaint();

  void onPath(Path path);
  void onVertices(IndexedVertices vertices);
}

abstract class Node {
  Node({required this.paint, this.parent}) {
    assert(parent?.children.contains(this) ?? true);
  }

  final Paint paint;
  final ParentNode? parent;

  void visit(Visitor visitor);
}

class ParentNode extends Node {
  ParentNode({
    required Paint paint,
    required this.children,
    ParentNode? parent,
    this.transform,
  }) : super(paint: paint, parent: parent);

  final AffineMatrix? transform;
  final List<Node> children;

  @override
  void visit(Visitor visitor) {
    visitor.pushPaint(paint);

    if (transform != null) {
      visitor.pushTransform(transform!);
    }
    for (final child in children) {
      child.visit(visitor);
    }

    if (transform != null) {
      visitor.popTransform();
    }

    visitor.popPaint();
  }
}

class PathNode extends Node {
  PathNode(
    this.path, {
    required ParentNode? parent,
    required Paint paint,
  }) : super(paint: paint, parent: parent);

  final Path path;

  @override
  void visit(Visitor visitor) {
    visitor.pushPaint(paint);
    visitor.onPath(path);
    visitor.popPaint();
  }
}

class VerticesNode extends Node {
  VerticesNode(
    this.vertices, {
    ParentNode? parent,
    AffineMatrix? transform,
    required Paint paint,
  }) : super(paint: paint, parent: parent);

  final IndexedVertices vertices;

  @override
  void visit(Visitor visitor) {
    visitor.pushPaint(paint);
    visitor.onVertices(vertices);
    visitor.popPaint();
  }
}
