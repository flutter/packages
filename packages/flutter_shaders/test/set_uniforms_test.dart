import 'dart:ui';

import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

class _MockFragmentShader implements FragmentShader {
  final floats = <int, double>{};
  final images = <int, Image>{};

  @override
  noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }

  @override
  void setFloat(int index, double value) {
    floats[index] = value;
  }
}

void main() {
  group('SetUniforms', () {
    test('setFloat', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setFloat(1.0);
      });

      expect(shader.floats, {
        0: 1.0,
      });
    });

    test('setFloats', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setFloats([1.0, 2.0, 3.0]);
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
      });
    });

    test('setSize', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setSize(const Size(1.0, 2.0));
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
      });
    });

    test('setSizes', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setSizes(const [
          Size(1.0, 2.0),
          Size(3.0, 4.0),
          Size(5.0, 6.0),
        ]);
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
      });
    });

    test('setColor', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setColor(const Color(0xFF006600));
      });

      expect(shader.floats, {
        0: 0.0,
        1: 0.4,
        2: 0.0,
        3: 1.0,
      });
    });

    test('setColor w/ premultiply', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setColor(const Color(0x00006600), premultiply: true);
      });

      expect(shader.floats, {
        0: 0.0,
        1: 0.0,
        2: 0.0,
        3: 0.0,
      });
    });

    test('setColors', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setColors(const [
          Color(0xFF006600),
          Color(0xFF660000),
          Color(0x66000066),
        ]);
      });

      expect(shader.floats, {
        0: 0.0,
        1: 0.4,
        2: 0.0,
        3: 1.0,
        4: 0.4,
        5: 0.0,
        6: 0.0,
        7: 1.0,
        8: 0.0,
        9: 0.0,
        10: 0.4,
        11: 0.4
      });
    });

    test('setColors w/ premultiply', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setColors(
          premultiply: true,
          const [
            Color(0xFF006600),
            Color(0xFF660000),
            Color(0x00000066),
          ],
        );
      });

      expect(shader.floats, {
        0: 0.0,
        1: 0.4,
        2: 0.0,
        3: 1.0,
        4: 0.4,
        5: 0.0,
        6: 0.0,
        7: 1.0,
        8: 0.0,
        9: 0.0,
        10: 0.0,
        11: 0.4
      });
    });

    test('setOffset', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setOffset(const Offset(1.0, 2.0));
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
      });
    });

    test('setOffsets', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setOffsets(const [
          Offset(1.0, 2.0),
          Offset(3.0, 4.0),
          Offset(5.0, 6.0),
        ]);
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
      });
    });

    test('setVector', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setVector(Vector2(1.0, 2.0));
        setter.setVector(Vector3(3.0, 4.0, 5.0));
        setter.setVector(Vector4(6.0, 7.0, 8.0, 9.0));
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
        6: 7.0,
        7: 8.0,
        8: 9.0,
      });
    });

    test('setMatrix2', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setMatrix2(Matrix2(1.0, 2.0, 3.0, 4.0));
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
      });
    });

    test('setMatrix2s', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setMatrix2s([
          Matrix2(1.0, 2.0, 3.0, 4.0),
          Matrix2(5.0, 6.0, 7.0, 8.0),
          Matrix2(9.0, 10.0, 11.0, 12.0),
        ]);
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
        6: 7.0,
        7: 8.0,
        8: 9.0,
        9: 10.0,
        10: 11.0,
        11: 12.0,
      });
    });

    test('setMatrix3', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setMatrix3(Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0));
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
        6: 7.0,
        7: 8.0,
        8: 9.0,
      });
    });

    test('setMatrix3s', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setMatrix3s([
          Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0),
          Matrix3(10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0),
          Matrix3(19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0),
        ]);
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
        6: 7.0,
        7: 8.0,
        8: 9.0,
        9: 10.0,
        10: 11.0,
        11: 12.0,
        12: 13.0,
        13: 14.0,
        14: 15.0,
        15: 16.0,
        16: 17.0,
        17: 18.0,
        18: 19.0,
        19: 20.0,
        20: 21.0,
        21: 22.0,
        22: 23.0,
        23: 24.0,
        24: 25.0,
        25: 26.0,
        26: 27.0,
      });
    });

    test('setMatrix4', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setMatrix4(Matrix4(
          1.0,
          2.0,
          3.0,
          4.0,
          5.0,
          6.0,
          7.0,
          8.0,
          9.0,
          10.0,
          11.0,
          12.0,
          13.0,
          14.0,
          15.0,
          16.0,
        ));
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
        6: 7.0,
        7: 8.0,
        8: 9.0,
        9: 10.0,
        10: 11.0,
        11: 12.0,
        12: 13.0,
        13: 14.0,
        14: 15.0,
        15: 16.0,
      });
    });

    test('setMatrix4s', () {
      final shader = _MockFragmentShader();

      shader.setFloatUniforms((setter) {
        setter.setMatrix4s([
          Matrix4(
            1.0,
            2.0,
            3.0,
            4.0,
            5.0,
            6.0,
            7.0,
            8.0,
            9.0,
            10.0,
            11.0,
            12.0,
            13.0,
            14.0,
            15.0,
            16.0,
          ),
          Matrix4(
            17.0,
            18.0,
            19.0,
            20.0,
            21.0,
            22.0,
            23.0,
            24.0,
            25.0,
            26.0,
            27.0,
            28.0,
            29.0,
            30.0,
            31.0,
            32.0,
          ),
        ]);
      });

      expect(shader.floats, {
        0: 1.0,
        1: 2.0,
        2: 3.0,
        3: 4.0,
        4: 5.0,
        5: 6.0,
        6: 7.0,
        7: 8.0,
        8: 9.0,
        9: 10.0,
        10: 11.0,
        11: 12.0,
        12: 13.0,
        13: 14.0,
        14: 15.0,
        15: 16.0,
        16: 17.0,
        17: 18.0,
        18: 19.0,
        19: 20.0,
        20: 21.0,
        21: 22.0,
        22: 23.0,
        23: 24.0,
        24: 25.0,
        25: 26.0,
        26: 27.0,
        27: 28.0,
        28: 29.0,
        29: 30.0,
        30: 31.0,
        31: 32.0,
      });
    });
  });
}
