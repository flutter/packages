// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

/// A helper extension on [ui.FragmentShader] that allows you to set uniforms
/// in a more convenient way, without having to manage indices manually.
///
/// Example:
/// ```dart
/// shader.setFloatUniforms((setter) {
///  setter.setFloat(1.0);
///  setter.setFloats([1.0, 2.0, 3.0]);
///  setter.setSize(const Size(1.0, 2.0));
///  setter.setSizes([const Size(1.0, 2.0), const Size(3.0, 4.0)]);
///  setter.setOffset(const Offset(1.0, 2.0));
///  setter.setOffsets([const Offset(1.0, 2.0), const Offset(3.0, 4.0)]);
///  setter.setMatrix(Matrix4.identity());
///  setter.setMatrices([Matrix4.identity(), Matrix4.identity()]);
///  setter.setColor(Colors.red);
///  setter.setColors([Colors.red, Colors.green]);
/// });
/// ```
///
/// The receiving end of this script should be:
/// ```glsl
/// uniform float u0; // 1.0
/// uniform float[3] uFloats; // float[3](1.0, 2.0, 3.0)
/// uniform vec2 size; // vec2(1.0, 2.0)
/// uniform vec2[2] sizes; // vec2[2](vec2(1.0, 2.0), vec2(3.0, 4.0))
/// uniform vec2 offset; // vec2(1.0, 2.0)
/// uniform vec2[2] offsets; // vec2[2](vec2(1.0, 2.0), vec2(3.0, 4.0))
/// uniform mat4 matrix; // mat4(1.0)
/// uniform mat4[2] matrices; // mat4[2](mat4(1.0), mat4(1.0))
/// uniform vec4 color; // vec4(1.0, 0.0, 0.0, 1.0)
/// uniform vec4[2] colors; // vec4[2](vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0))
/// ```
///
/// The [initialIndex] parameter allows you to set the index of the first
/// uniform. Defaults to 0.
///
/// Returns the index of the last uniform that was set.
extension SetUniforms on ui.FragmentShader {
  /// Sets float uniforms on this shader sequentially using [callback].
  ///
  /// The [initialIndex] parameter specifies the index of the first uniform to
  /// set (defaults to 0). Returns the next uniform index after all uniforms in
  /// [callback] have been set.
  int setFloatUniforms(ValueSetter<UniformsSetter> callback, {int initialIndex = 0}) {
    final setter = UniformsSetter(this, initialIndex);
    callback(setter);
    return setter._index;
  }
}

/// Helper class for sequentially configuring float uniforms on a fragment shader.
class UniformsSetter {
  /// Creates a [UniformsSetter] for the given [shader] starting at [_index].
  UniformsSetter(this.shader, this._index);

  int _index;

  /// The fragment shader being configured.
  final ui.FragmentShader shader;

  /// Sets a single float uniform at the current index.
  void setFloat(double value) {
    shader.setFloat(_index++, value);
  }

  /// Sets a list of float uniforms sequentially.
  void setFloats(List<double> values) {
    for (final value in values) {
      setFloat(value);
    }
  }

  /// Sets a [Size] uniform (width and height) at the current index.
  void setSize(Size size) {
    shader
      ..setFloat(_index++, size.width)
      ..setFloat(_index++, size.height);
  }

  /// Sets a list of [Size] uniforms sequentially.
  void setSizes(List<Size> sizes) {
    for (final size in sizes) {
      setSize(size);
    }
  }

  /// Sets a [Color] uniform as normalized RGBA floats.
  ///
  /// If [premultiply] is true, RGB components are multiplied by opacity.
  void setColor(Color color, {bool premultiply = false}) {
    final double multiplier;
    if (premultiply) {
      multiplier = color.opacity;
    } else {
      multiplier = 1.0;
    }

    setFloat(color.red / 255 * multiplier);
    setFloat(color.green / 255 * multiplier);
    setFloat(color.blue / 255 * multiplier);
    setFloat(color.opacity);
  }

  /// Sets a list of [Color] uniforms sequentially.
  ///
  /// If [premultiply] is true, RGB components are multiplied by opacity.
  void setColors(List<Color> colors, {bool premultiply = false}) {
    for (final color in colors) {
      setColor(color, premultiply: premultiply);
    }
  }

  /// Sets an [Offset] uniform (dx and dy) at the current index.
  void setOffset(Offset offset) {
    shader
      ..setFloat(_index++, offset.dx)
      ..setFloat(_index++, offset.dy);
  }

  /// Sets a list of [Offset] uniforms sequentially.
  void setOffsets(List<Offset> offsets) {
    for (final offset in offsets) {
      setOffset(offset);
    }
  }

  /// Sets a [Vector] uniform from its underlying storage floats.
  void setVector(Vector vector) {
    setFloats(vector.storage);
  }

  /// Sets a list of [Vector] uniforms sequentially.
  void setVectors(List<Vector> vectors) {
    for (final vector in vectors) {
      setVector(vector);
    }
  }

  /// Sets a 2x2 matrix uniform from its underlying storage floats.
  void setMatrix2(Matrix2 matrix2) {
    setFloats(matrix2.storage);
  }

  /// Sets a list of 2x2 matrix uniforms sequentially.
  void setMatrix2s(List<Matrix2> matrix2s) {
    for (final matrix2 in matrix2s) {
      setMatrix2(matrix2);
    }
  }

  /// Sets a 3x3 matrix uniform from its underlying storage floats.
  void setMatrix3(Matrix3 matrix3) {
    setFloats(matrix3.storage);
  }

  /// Sets a list of 3x3 matrix uniforms sequentially.
  void setMatrix3s(List<Matrix3> matrix3s) {
    for (final matrix3 in matrix3s) {
      setMatrix3(matrix3);
    }
  }

  /// Sets a 4x4 matrix uniform from its underlying storage floats.
  void setMatrix4(Matrix4 matrix4) {
    setFloats(matrix4.storage);
  }

  /// Sets a list of 4x4 matrix uniforms sequentially.
  void setMatrix4s(List<Matrix4> matrix4s) {
    for (final matrix4 in matrix4s) {
      setMatrix4(matrix4);
    }
  }
}
