import 'dart:typed_data';

import 'basic_types.dart';

/// A description of vertex points for drawing triangles.
class Vertices {
  const Vertices(this.vertexPoints);

  factory Vertices.fromFloat32List(Float32List vertices) {
    if (vertices.length.isOdd) {
      throw ArgumentError(
        'must be an even number of vertex points',
        'vertices',
      );
    }
    final List<Point> vertexPoints = [];
    for (int index = 0; index < vertices.length; index += 2) {
      vertexPoints.add(Point(vertices[index], vertices[index + 1]));
    }
    return Vertices(vertexPoints);
  }

  /// A list of vertex points descibing this triangular mesh.
  ///
  /// The vertex points are assumed to be in VertexMode.triangle.
  final List<Point> vertexPoints;

  /// Creates an optimized version of [vertexPoints] where the points are
  /// deduplicated via an index buffer.
  IndexedVertices createIndex() {
    final pointMap = <Point, int>{};
    int index = 0;
    final List<int> indices = [];
    for (final point in vertexPoints) {
      indices.add(pointMap.putIfAbsent(point, () => index++));
    }

    Float32List pointsToFloat32List(List<Point> points) {
      final Float32List vertices = Float32List(points.length * 2);
      int vertexIndex = 0;
      for (final point in points) {
        vertices[vertexIndex++] = point.x;
        vertices[vertexIndex++] = point.y;
      }
      return vertices;
    }

    final List<Point> compressedPoints = pointMap.keys.toList();
    if (compressedPoints.length * 2 + indices.length >
        vertexPoints.length * 2) {
      return IndexedVertices(pointsToFloat32List(vertexPoints), null);
    }

    return IndexedVertices(
      pointsToFloat32List(compressedPoints),
      Uint16List.fromList(indices),
    );
  }
}

/// An optimized version of [Vertices] that uses an index buffer to specify
/// reused vertex points.
class IndexedVertices {
  const IndexedVertices(this.vertices, this.indices);

  /// The raw vertex points.
  final Float32List vertices;

  /// The order to use vertices from [vertuces].
  ///
  /// May be null if [vertices] was not compressable.
  final Uint16List? indices;
}
