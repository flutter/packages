// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('Color tests', () {
    expect(
      const Color.fromRGBO(10, 15, 20, .1),
      const Color.fromARGB(25, 10, 15, 20),
    );

    expect(
      const Color.fromARGB(255, 10, 15, 20).withOpacity(.1),
      const Color.fromARGB(25, 10, 15, 20),
    );

    const Color testColor = Color(0xFFABCDEF);
    expect(testColor.r, 0xAB);
    expect(testColor.g, 0xCD);
    expect(testColor.b, 0xEF);
  });

  test('LinearGradient can be converted to local coordinates', () {
    const LinearGradient gradient = LinearGradient(
      id: 'test',
      from: Point.zero,
      to: Point(1, 1),
      colors: <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
      tileMode: TileMode.mirror,
      offsets: <double>[0.0, 1.0],
      transform: AffineMatrix.identity,
    );

    final LinearGradient transformed = gradient.applyBounds(
      const Rect.fromLTWH(5, 5, 100, 100),
      AffineMatrix.identity,
    );

    expect(transformed.from, const Point(5, 5));
    expect(transformed.to, const Point(105, 105));
  });

  test('LinearGradient applied bounds with userSpaceOnUse', () {
    const LinearGradient gradient = LinearGradient(
      id: 'test',
      from: Point.zero,
      to: Point(1, 1),
      colors: <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
      tileMode: TileMode.mirror,
      offsets: <double>[0.0, 1.0],
      transform: AffineMatrix.identity,
      unitMode: GradientUnitMode.userSpaceOnUse,
    );

    final LinearGradient transformed = gradient.applyBounds(
      const Rect.fromLTWH(5, 5, 100, 100),
      AffineMatrix.identity,
    );

    expect(transformed.from, Point.zero);
    expect(transformed.to, const Point(1, 1));
  });

  test('LinearGradient applied bounds with userSpaceOnUse and transformed', () {
    final LinearGradient gradient = LinearGradient(
      id: 'test',
      from: Point.zero,
      to: const Point(1, 1),
      colors: const <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
      tileMode: TileMode.mirror,
      offsets: const <double>[0.0, 1.0],
      transform: AffineMatrix.identity.scaled(2),
      unitMode: GradientUnitMode.userSpaceOnUse,
    );

    final LinearGradient transformed = gradient.applyBounds(
      const Rect.fromLTWH(5, 5, 100, 100),
      AffineMatrix.identity,
    );

    expect(transformed.from, Point.zero);
    expect(transformed.to, const Point(2, 2));
  });

  test('RadialGradient can be converted to local coordinates', () {
    const RadialGradient gradient = RadialGradient(
      id: 'test',
      center: Point(0.5, 0.5),
      radius: 10,
      colors: <Color>[Color(0xFFFFFFAA), Color(0xFFABCDEF)],
      tileMode: TileMode.clamp,
      transform: AffineMatrix.identity,
      focalPoint: Point(0.6, 0.6),
      offsets: <double>[.1, .9],
    );

    final RadialGradient transformed = gradient.applyBounds(
      const Rect.fromLTWH(5, 5, 100, 100),
      AffineMatrix.identity.translated(5, 5).scaled(100, 100),
    );

    expect(transformed.center, const Point(.5, .5));
    expect(transformed.focalPoint, const Point(.6, .6));
    expect(
      transformed.transform,
      AffineMatrix.identity
          .translated(5, 5)
          .scaled(100, 100)
          .multiplied(AffineMatrix.identity.translated(5, 5).scaled(100, 100)),
    );
  });

  test('RadialGradient applied bounds with userSpaceOnUse', () {
    const RadialGradient gradient = RadialGradient(
      id: 'test',
      center: Point(0.5, 0.5),
      radius: 10,
      colors: <Color>[Color(0xFFFFFFAA), Color(0xFFABCDEF)],
      tileMode: TileMode.clamp,
      transform: AffineMatrix.identity,
      focalPoint: Point(0.6, 0.6),
      offsets: <double>[.1, .9],
      unitMode: GradientUnitMode.userSpaceOnUse,
    );

    final RadialGradient transformed = gradient.applyBounds(
      const Rect.fromLTWH(5, 5, 100, 100),
      AffineMatrix.identity,
    );

    expect(transformed.center, const Point(0.5, 0.5));
    expect(transformed.focalPoint, const Point(0.6, 0.6));
    expect(transformed.transform, AffineMatrix.identity);
  });
}
