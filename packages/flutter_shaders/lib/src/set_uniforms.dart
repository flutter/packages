import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

extension SetUniforms on ui.FragmentShader {
  int setFloatUniforms(
    ValueSetter<UniformsSetter> callback, {
    int initialIndex = 0,
  }) {
    final setter = UniformsSetter(this, initialIndex);
    callback(setter);
    return setter._index;
  }
}

class UniformsSetter {
  UniformsSetter(this.shader, this._index);

  int _index;
  final ui.FragmentShader shader;

  void setFloat(double value) {
    shader.setFloat(_index++, value);
  }

  void setFloats(List<double> values) {
    for (final value in values) {
      setFloat(value);
    }
  }

  void setSize(Size size) {
    shader
      ..setFloat(_index++, size.width)
      ..setFloat(_index++, size.height);
  }

  void setSizes(List<Size> sizes) {
    for (final size in sizes) {
      setSize(size);
    }
  }

  void setColor(Color color) {
    shader
      ..setFloat(_index++, color.red.toDouble() / 255)
      ..setFloat(_index++, color.green.toDouble() / 255)
      ..setFloat(_index++, color.blue.toDouble() / 255)
      ..setFloat(_index++, color.opacity);
  }

  void setColors(List<Color> colors) {
    for (final color in colors) {
      setColor(color);
    }
  }

  void setOffset(Offset offset) {
    shader
      ..setFloat(_index++, offset.dx)
      ..setFloat(_index++, offset.dy);
  }

  void setOffsets(List<Offset> offsets) {
    for (final offset in offsets) {
      setOffset(offset);
    }
  }

  void setVector(Vector vector) {
    setFloats(vector.storage);
  }

  void setVectors(List<Vector> vectors) {
    for (final vector in vectors) {
      setVector(vector);
    }
  }
  void setMatrix2(Matrix2 matrix2) {
    setFloats(matrix2.storage);
  }

  void setMatrix2s(List<Matrix2> matrix2s) {
    for (final matrix2 in matrix2s) {
      setMatrix2(matrix2);
    }
  }

  void setMatrix3(Matrix3 matrix3) {
    setFloats(matrix3.storage);
  }

  void setMatrix3s(List<Matrix3> matrix3s) {
    for (final matrix3 in matrix3s) {
      setMatrix3(matrix3);
    }
  }

  void setMatrix4(Matrix4 matrix4) {
    setFloats(matrix4.storage);
  }

  void setMatrix4s(List<Matrix4> matrix4s) {
    for (final matrix4 in matrix4s) {
      setMatrix4(matrix4);
    }
  }
}
