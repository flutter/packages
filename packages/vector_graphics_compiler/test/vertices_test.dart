// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('Vertices.fromFloat32List', () {
    final Vertices vertices = Vertices.fromFloat32List(Float32List.fromList(
      <double>[1, 2, 3, 4, 5, 6],
    ));

    expect(
      vertices.vertexPoints,
      const <Point>[Point(1, 2), Point(3, 4), Point(5, 6)],
    );

    expect(
      () => Vertices.fromFloat32List(Float32List.fromList(<double>[1])),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('IndexedVertices - creates valid index', () {
    final Vertices vertices = Vertices.fromFloat32List(Float32List.fromList(
      <double>[
        1,
        1,
        2,
        2,
        3,
        3,
        1,
        1,
        4,
        4,
        2,
        2,
        3,
        3,
        5,
        5,
        4,
        4,
        1,
        1,
        2,
        2,
        3,
        3
      ],
    ));

    final IndexedVertices indexedVertices = vertices.createIndex();
    expect(indexedVertices.vertices.length, 10);
    expect(indexedVertices.indices!.length, 12);
    expect(indexedVertices.vertices, <double>[1, 1, 2, 2, 3, 3, 4, 4, 5, 5]);
    expect(
        indexedVertices.indices, <double>[0, 1, 2, 0, 3, 1, 2, 4, 3, 0, 1, 2]);
  });

  test('IndexedVertices - does not index if index is larger', () {
    final Float32List original = Float32List.fromList(
      <double>[1, 1, 2, 2, 3, 3, 1, 2, 4, 4, 2, 3, 3, 4, 5, 5, 4, 5],
    );
    final Vertices vertices = Vertices.fromFloat32List(original);

    final IndexedVertices indexedVertices = vertices.createIndex();
    expect(indexedVertices.vertices, original);
    expect(indexedVertices.indices, null);
  });
}
