// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/morph.dart';
import 'package:material_ui/src/shapes/rounded_polygon.dart';
import 'package:vector_math/vector_math_64.dart';

import 'test_utils.dart';

void main() {
  group('$Morph', () {
    const radius = 50.0;
    const scale = radius;

    final poly1 = RoundedPolygon.fromVerticesNum(3, centerX: 0.5, centerY: 0.5);
    final poly2 = RoundedPolygon.fromVerticesNum(4, centerX: 0.5, centerY: 0.5);
    final morph11 = Morph(poly1, poly1);
    final morph12 = Morph(poly1, poly2);

    // Simple test to verify that a Morph with the same start and end shape has
    // curves equivalent to those in that shape.
    test('cubics', () {
      final List<CubicBezier> p1Cubics = poly1.cubics;
      final List<CubicBezier> cubics11 = morph11.asCubics(0);
      expect(cubics11, isNotEmpty);

      // The structure of a morph and its component shapes may not match
      // exactly, because morph calculations may optimize some of the
      // zero-length curves out. But in general, every curve in the morph
      // *should* exist somewhere in the shape it is based on, so we do an
      // exhaustive search for such existence. Note that this assertion only
      // works because we constructed the Morph from/to the same shape. A Morph
      // between different shapes may not have the curves replicated exactly.
      for (final morphCubic in cubics11) {
        var matched = false;
        for (final p1Cubic in p1Cubics) {
          if (cubicsEqualish(morphCubic, p1Cubic)) {
            matched = true;
            continue;
          }
        }
        expect(matched, isTrue);
      }
    });

    Future<ui.Image> drawPathToImage(ui.Path path, double side) async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
        ..drawColor(const ui.Color(0xFF000000), ui.BlendMode.src)
        ..drawPath(
          path,
          ui.Paint()
            ..style = ui.PaintingStyle.fill
            ..color = const ui.Color(0xFFFFFFFF),
        );

      final ui.Picture picture = recorder.endRecording();
      return picture.toImage(side.toInt(), side.toInt());
    }

    Future<void> comparePathsVisually(ui.Path a, ui.Path b, double side) async {
      final ui.Image imageA = await drawPathToImage(a, side);
      final ui.Image imageB = await drawPathToImage(b, side);

      final ByteData? bytesA = await imageA.toByteData();
      final ByteData? bytesB = await imageB.toByteData();

      if (bytesA!.lengthInBytes != bytesB!.lengthInBytes) {
        fail('byte data length of a has to be equal to byte data length of b');
      }

      for (var i = 0; i < bytesA.lengthInBytes; i++) {
        if (bytesA.getUint8(i) != bytesB.getUint8(i)) {
          fail('path a is not equal to path b at byte index $i');
        }
      }
    }

    // This test checks to see whether a morph between two different polygons
    // is correct at the start (progress 0) and end (progress 1). The actual
    // cubics of the morph vs the polygons it was constructed from may differ,
    // due to the way the morph is constructed, but the rendering result should
    // be the same.
    test('drawing', () async {
      // Shapes are in canonical size of 2x2 around center (.5, .5).
      // Translate and scale to get a larger path.
      final matrix = Matrix4.identity()
        ..translate(scale / 2, scale / 2)
        ..scale(scale, scale);

      final ui.Path poly1Path = poly1.toPath().transform(matrix.storage);
      final ui.Path poly2Path = poly2.toPath().transform(matrix.storage);
      final ui.Path morph120Path = morph12.toPath(progress: 0).transform(matrix.storage);
      final ui.Path morph121Path = morph12.toPath(progress: 1).transform(matrix.storage);

      await comparePathsVisually(poly1Path, morph120Path, radius * 2);
      await comparePathsVisually(poly2Path, morph121Path, radius * 2);
    });
  });
}
