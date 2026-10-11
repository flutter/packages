// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'listener_adapter.dart';

/// Measures complete anchored chunks before their segments enter paint layers.
class VectorTextLayout extends VectorGraphicsListenerAdapter {
  VectorTextLayout._(this.locale, this.textDirection);

  /// The anchor offset for every text draw command, in command order.
  static List<double> read(ByteData data, Locale? locale, TextDirection? direction) {
    final listener = VectorTextLayout._(locale, direction);
    DecodeResponse? response;
    do {
      response = const VectorGraphicsCodec().decode(data, listener, response: response);
    } while (!response.complete);
    listener._finishChunk();
    return listener._offsets;
  }

  /// Locale used by the renderer's paragraph layout.
  final Locale? locale;

  /// Direction used by the renderer's paragraph layout.
  final TextDirection? textDirection;

  final List<({String text, TextStyle style, double anchor})> _configs = [];
  final List<({double? x, double? y, double? dx, bool reset})> _positions = [];
  final Map<int, double> _widths = {};
  final List<double> _offsets = [];
  int _chunkStart = 0;
  double _x = 0;
  double _origin = 0;
  double _anchor = 0;
  double _advance = 0;

  @override
  void onTextConfig(
    String text,
    String? fontFamily,
    double xAnchorMultiplier,
    int fontWeight,
    double fontSize,
    int decoration,
    int decorationStyle,
    int decorationColor,
    int id,
  ) {
    _configs.add((
      text: text,
      style: TextStyle(
        locale: locale,
        fontFamily: fontFamily,
        fontWeight: FontWeight.values[fontWeight],
        fontSize: fontSize,
      ),
      anchor: xAnchorMultiplier,
    ));
  }

  @override
  void onTextPosition(
    int textPositionId,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  ) {
    _positions.add((x: x, y: y, dx: dx, reset: reset));
  }

  @override
  void onUpdateTextPosition(int textPositionId) {
    final ({double? x, double? y, double? dx, bool reset}) position = _positions[textPositionId];
    if (position.reset || position.x != null || position.y != null) {
      _finishChunk();
    }
    if (position.reset) {
      _x = 0;
    }
    _x = (position.x ?? _x) + (position.dx ?? 0);
  }

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {
    final ({String text, TextStyle style, double anchor}) config = _configs[textId];
    if (_anchor != config.anchor) {
      _finishChunk();
    }
    if (_chunkStart == _offsets.length) {
      _origin = _x;
      _anchor = config.anchor;
    }
    final double width = _widths.putIfAbsent(textId, () {
      final builder = ParagraphBuilder(ParagraphStyle(textDirection: textDirection))
        ..pushStyle(config.style)
        ..addText(config.text);
      final Paragraph paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: double.infinity));
      try {
        return paragraph.maxIntrinsicWidth;
      } finally {
        paragraph.dispose();
      }
    });
    _offsets.add(0);
    _x += width;
    _advance = _x - _origin;
  }

  void _finishChunk() {
    final double offset = _advance * _anchor;
    for (int i = _chunkStart; i < _offsets.length; i++) {
      _offsets[i] = offset;
    }
    _chunkStart = _offsets.length;
  }
}
