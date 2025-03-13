// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'basic_types.dart';

/// A description of vertex points for drawing triangles.
class Vertices {
  /// Creates a new collection of triangle vertices at the specified points.
  const Vertices(this.vertexPoints);

  /// Creates a new collection of triangle vertices from the specified
  /// [Float32List], interpreted as x,y pairs.
  factory Vertices.fromFloat32List(Float32List vertices) {
    if (vertices.length.isOdd) {
      throw ArgumentError(
        'must be an even number of vertex points',
        'vertices',
      );
    }
    final List<Point> vertexPoints = <Point>[];
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
    final Map<Point, int> pointMap = <Point, int>{};
    int index = 0;
    final List<int> indices = <int>[];
    for (final Point point in vertexPoints) {
      indices.add(pointMap.putIfAbsent(point, () => index++));
    }

    Float32List pointsToFloat32List(List<Point> points) {
      final Float32List vertices = Float32List(points.length * 2);
      int vertexIndex = 0;
      for (final Point point in points) {
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
  /// Creates a indexed set of vertices.
  ///
  /// Consider using [Vertices.createIndex].
  const IndexedVertices(this.vertices, this.indices);

  /// The raw vertex points.
  final Float32List vertices;

  /// The order to use vertices from [vertices].
  ///
  /// May be null if [vertices] was not compressable.
  final Uint16List? indices;
}
