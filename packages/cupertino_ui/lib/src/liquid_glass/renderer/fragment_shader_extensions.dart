// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Helper to sequentially write uniform values to a [ui.FragmentShader].
class UniformValues {
  UniformValues._(this._shader, this._index);

  final ui.FragmentShader _shader;
  int _index;

  /// Current uniform index.
  int get index => _index;

  /// Writes a single float uniform.
  void setFloat(double value) {
    _shader.setFloat(_index++, value);
  }

  /// Writes multiple float uniforms sequentially.
  void setFloats(Iterable<double> values) {
    for (final value in values) {
      _shader.setFloat(_index++, value);
    }
  }

  /// Writes a [Size] (width, height) as two consecutive float uniforms.
  void setSize(Size size) {
    _shader.setFloat(_index++, size.width);
    _shader.setFloat(_index++, size.height);
  }

  /// Writes an [Offset] (dx, dy) as two consecutive float uniforms.
  void setOffset(Offset offset) {
    _shader.setFloat(_index++, offset.dx);
    _shader.setFloat(_index++, offset.dy);
  }

  /// Writes an [Offset] as a point (dx, dy) as two consecutive float uniforms.
  void setPoint(Offset point) => setOffset(point);

  /// Writes a [Color] (r, g, b, a in straight float values) as four consecutive float uniforms.
  void setColor(Color color) {
    _shader.setFloat(_index++, color.r);
    _shader.setFloat(_index++, color.g);
    _shader.setFloat(_index++, color.b);
    _shader.setFloat(_index++, color.a);
  }
}

/// Extension methods on [ui.FragmentShader] for fluent uniform population.
extension FragmentShaderUniformsExtension on ui.FragmentShader {
  /// Sets float uniforms starting at [initialIndex] using a [callback].
  void setFloatUniforms(
    void Function(UniformValues values) callback, {
    int initialIndex = 0,
  }) {
    callback(UniformValues._(this, initialIndex));
  }
}
