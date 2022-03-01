import 'dart:math' as math;

import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('Identity matrix', () {
    expect(AffineMatrix.identity.toMatrix4(), Matrix4.identity().storage);
  });

  test('Multiply', () {
    const matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);
    const matrix2 = AffineMatrix(7, 8, 9, 10, 11, 12);

    final matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    final matrix4_2 = Matrix4.fromFloat64List(matrix2.toMatrix4());
    expect(
      matrix1.multiplied(matrix2).toMatrix4(),
      matrix4_1.multiplied(matrix4_2).storage,
    );
  });

  test('Scale', () {
    const matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);

    final matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
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
    const matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);
    const matrix2 = AffineMatrix(7, 8, 9, 10, 11, 12);

    final matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    final matrix4_2 = Matrix4.fromFloat64List(matrix2.toMatrix4());
    expect(
      matrix1.scaled(2, 3).multiplied(matrix2).toMatrix4(),
      matrix4_1.scaled(2.0, 3.0).multiplied(matrix4_2).storage,
    );
  });

  test('Translate', () {
    const matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);

    final matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    matrix4_1.translate(2.0, 3.0);
    expect(
      matrix1.translated(2, 3).toMatrix4(),
      matrix4_1.storage,
    );
  });

  test('Rotate', () {
    const matrix1 = AffineMatrix(2, 2, 3, 4, 5, 6);

    final matrix4_1 = Matrix4.fromFloat64List(matrix1.toMatrix4());
    matrix4_1.rotateZ(31.0);
    expect(
      matrix1.rotated(31).toMatrix4(),
      matrix4_1.storage,
    );
  });

  test('transformRect', () {
    const epsillon = .0000001;
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
    final rotatedRect = AffineMatrix.identity
        .rotated(math.pi / 2.0)
        .transformRect(rectangle20x20);
    expect(rotatedRect.left + 40, lessThan(epsillon));
    expect(rotatedRect.top - 10, lessThan(epsillon));
    expect(rotatedRect.right + 20, lessThan(epsillon));
    expect(rotatedRect.bottom - 30, lessThan(epsillon));
  });
}
