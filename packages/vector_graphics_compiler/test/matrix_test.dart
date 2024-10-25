// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/parsers.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('scaleStrokeWidth', () {
    expect(AffineMatrix.identity.scaleStrokeWidth(null), null);
    expect(AffineMatrix.identity.scaleStrokeWidth(1), 1);
    expect(AffineMatrix.identity.scaleStrokeWidth(2), 2);
    expect(AffineMatrix.identity.rotated(1.2).scaleStrokeWidth(1), 1);
    expect(AffineMatrix.identity.rotated(1.2).scaleStrokeWidth(2), 2);

    expect(AffineMatrix.identity.scaled(2.0).scaleStrokeWidth(1), 2);
    expect(AffineMatrix.identity.scaled(2.0).scaleStrokeWidth(2), 4);
    expect(
        AffineMatrix.identity.scaled(2.0).rotated(1.2).scaleStrokeWidth(1), 2);
    expect(
        AffineMatrix.identity.scaled(2.0).rotated(1.2).scaleStrokeWidth(2), 4);

    expect(AffineMatrix.identity.scaled(2.0, 1.0).scaleStrokeWidth(1), 1.5);
    expect(AffineMatrix.identity.scaled(2.0, 1.0).scaleStrokeWidth(2), 3);
    expect(
        AffineMatrix.identity.scaled(2.0, 1.0).rotated(1.2).scaleStrokeWidth(1),
        1.5);
    expect(
        AffineMatrix.identity.scaled(2.0, 1.0).rotated(1.2).scaleStrokeWidth(2),
        3);
  });

  test('Parse rotate and scale', () {
    // Regression test for https://github.com/dnfield/flutter_svg/issues/801
    final AffineMatrix mat = parseTransform('rotate(-1 4 -12) scale(2)')!;
    expect(
      mat,
      AffineMatrix.identity
          .translated(4, -12)
          .rotated(radians(-1))
          .translated(-4, 12)
          .scaled(2),
    );
  });

  test('Identity matrix', () {
    expect(AffineMatrix.identity.toMatrix4(), Matrix4.identity().storage);
  });

  test('Multiply', () {
    const AffineMatrix matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);
    const AffineMatrix matrix2 = AffineMatrix(7, 8, 9, 10, 11, 12);

    final Matrix4 matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    final Matrix4 matrix4_2 = Matrix4.fromFloat64List(matrix2.toMatrix4());
    expect(
      matrix1.multiplied(matrix2).toMatrix4(),
      matrix4_1.multiplied(matrix4_2).storage,
    );
  });

  test('Scale', () {
    const AffineMatrix matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);

    final Matrix4 matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    expect(
      matrix1.scaled(2, 3).toMatrix4(),
      matrix4_1.scaled(2.0, 3.0).storage,
    );

    expect(
      matrix1.scaled(2).toMatrix4(),
      matrix4_1.scaled(2.0, 2.0).storage,
    );
  });

  test('Scale and multiply', () {
    const AffineMatrix matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);
    const AffineMatrix matrix2 = AffineMatrix(7, 8, 9, 10, 11, 12);

    final Matrix4 matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    final Matrix4 matrix4_2 = Matrix4.fromFloat64List(matrix2.toMatrix4());
    expect(
      matrix1.scaled(2, 3).multiplied(matrix2).toMatrix4(),
      matrix4_1.scaled(2.0, 3.0).multiplied(matrix4_2).storage,
    );
  });

  test('Multiply handles the extra matrix4 scale value', () {
    final AffineMatrix matrix1 = AffineMatrix.identity.scaled(2, 3);
    final AffineMatrix matrix2 = AffineMatrix.identity.multiplied(matrix1);

    expect(matrix1, matrix2);
  });

  test('Translate', () {
    const AffineMatrix matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);

    final Matrix4 matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    matrix4_1.translate(2.0, 3.0);
    expect(
      matrix1.translated(2, 3).toMatrix4(),
      matrix4_1.storage,
    );
  });

  test('Rotate', () {
    const AffineMatrix matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);

    final Matrix4 matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4())
      ..rotateZ(31.0);
    expect(
      matrix1.rotated(31).toMatrix4(),
      matrix4_1.storage,
    );
  });

  test('transformRect', () {
    const double epsillon = .0000001;
    const Rect rectangle20x20 = Rect.fromLTRB(10, 20, 30, 40);

    // Identity
    expect(
      AffineMatrix.identity.transformRect(rectangle20x20),
      rectangle20x20,
    );

    // 2D Scaling
    expect(
      AffineMatrix.identity.scaled(2).transformRect(rectangle20x20),
      const Rect.fromLTRB(20, 40, 60, 80),
    );

    // Rotation
    final Rect rotatedRect = AffineMatrix.identity
        .rotated(math.pi / 2.0)
        .transformRect(rectangle20x20);
    expect(rotatedRect.left + 40, lessThan(epsillon));
    expect(rotatedRect.top - 10, lessThan(epsillon));
    expect(rotatedRect.right + 20, lessThan(epsillon));
    expect(rotatedRect.bottom - 30, lessThan(epsillon));

    // Translation
    final Rect shiftedRect =
        AffineMatrix.identity.translated(10, 20).transformRect(rectangle20x20);

    expect(shiftedRect.left, rectangle20x20.left + 10);
    expect(shiftedRect.top, rectangle20x20.top + 20);
    expect(shiftedRect.right, rectangle20x20.right + 10);
    expect(shiftedRect.bottom, rectangle20x20.bottom + 20);
  });

  test('== and hashCode account for hidden field', () {
    const AffineMatrix matrixA = AffineMatrix.identity;
    const AffineMatrix matrixB = AffineMatrix(1, 0, 0, 1, 0, 0, 0);

    expect(matrixA != matrixB, true);
    expect(matrixA.hashCode != matrixB.hashCode, true);
  });

  test('encodableInRect', () {
    final AffineMatrix matrixA = AffineMatrix.identity.scaled(2, 3);
    final AffineMatrix matrixB = AffineMatrix.identity.scaled(2, -2);
    final AffineMatrix matrixC = AffineMatrix.identity.xSkewed(5);
    final AffineMatrix matrixD = AffineMatrix.identity.ySkewed(5);
    final AffineMatrix matrixE = AffineMatrix.identity.rotated(1.3);

    expect(matrixA.encodableInRect, true);
    expect(matrixB.encodableInRect, false);
    expect(matrixC.encodableInRect, false);
    expect(matrixD.encodableInRect, false);
    expect(matrixE.encodableInRect, false);
  });
}
