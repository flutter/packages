// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('opacity quantization matches dart:ui throughout the unit interval', () {
    for (var step = 0; step <= 1000; step++) {
      final double opacity = step / 1000;
      final int expected = ui.Color.fromRGBO(10, 15, 20, opacity).toARGB32() >> 24;
      expect(Color.fromRGBO(10, 15, 20, opacity).a, expected, reason: 'opacity=$opacity');
    }
  });
  test('all encoded alpha bytes survive an opacity round trip', () {
    for (var alpha = 0; alpha <= 255; alpha++) {
      expect(Color.fromRGBO(10, 15, 20, alpha / 255).a, alpha);
    }
  });
  test('opacity around a half-alpha threshold is rounded consistently', () {
    expect(const Color.fromRGBO(0, 0, 0, .499).a, 127);
    expect(const Color.fromRGBO(0, 0, 0, .5).a, 128);
    expect(const Color.fromRGBO(0, 0, 0, .501).a, 128);
  });
  test('Color tests', () {
    expect(const Color.fromRGBO(10, 15, 20, .1), const Color.fromARGB(26, 10, 15, 20));

    expect(
      const Color.fromARGB(255, 10, 15, 20).withOpacity(.1),
      const Color.fromARGB(26, 10, 15, 20),
    );

    const testColor = Color(0xFFABCDEF);
    expect(testColor.r, 0xAB);
    expect(testColor.g, 0xCD);
    expect(testColor.b, 0xEF);
  });

  test('LinearGradient can be converted to local coordinates', () {
    const gradient = LinearGradient(
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
    const gradient = LinearGradient(
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
    final gradient = LinearGradient(
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
    const gradient = RadialGradient(
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
    const gradient = RadialGradient(
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
