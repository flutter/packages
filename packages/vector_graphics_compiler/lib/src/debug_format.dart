// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'paint.dart';

/// Write an unstable but human readable form of the vector graphics binary
/// package intended to be used for debugging and development.
Uint8List dumpToDebugFormat(Uint8List bytes) {
  const VectorGraphicsCodec codec = VectorGraphicsCodec();
  final _DebugVectorGraphicsListener listener = _DebugVectorGraphicsListener();
  final DecodeResponse response =
      codec.decode(bytes.buffer.asByteData(), listener);
  if (!response.complete) {
    codec.decode(bytes.buffer.asByteData(), listener, response: response);
  }
  // Newer versions of Dart will make this a Uint8List and not require the cast.
  // ignore: unnecessary_cast
  return utf8.encode(listener.buffer.toString()) as Uint8List;
}

String _intToColor(int value) {
  return 'Color(0x${(value & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0')})';
}

class _DebugVectorGraphicsListener extends VectorGraphicsCodecListener {
  final StringBuffer buffer = StringBuffer();

  @override
  void onClipPath(int pathId) {
    buffer.writeln('DrawClip: id:$pathId');
  }

  @override
  void onDrawImage(int imageId, double x, double y, double width, double height,
      Float64List? transform) {
    buffer.writeln(
        'DrawImage: id:$imageId (Rect.fromLTWH($x, $y, $width, $height), transform: $transform)');
  }

  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {
    final String patternContext =
        patternId != null ? ', patternId:$patternId' : '';
    buffer.writeln('DrawPath: id:$pathId (paintId:$paintId$patternContext)');
  }

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {
    buffer.writeln(
        'DrawText: id:$textId (fill: $fillId, stroke: $strokeId, pattern: $patternId)');
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    buffer.writeln('DrawVertices: $vertices ($indices, paintId: $paintId)');
  }

  @override
  void onImage(
    int imageId,
    int format,
    Uint8List data, {
    VectorGraphicsErrorListener? onError,
  }) {
    buffer.writeln(
        'StoreImage: id:$imageId (format:$format, byteLength:${data.lengthInBytes}');
  }

  @override
  void onLinearGradient(double fromX, double fromY, double toX, double toY,
      Int32List colors, Float32List? offsets, int tileMode, int id) {
    buffer.writeln(
      'StoreGradient: id:$id Linear(\n'
      '  from: ($fromX, $fromY)\n'
      '  to: ($toX, $toY)\n'
      '  colors: [${colors.map(_intToColor).join(',')}]\n'
      '  offsets: $offsets\n'
      '  tileMode: ${TileMode.values[tileMode].name}',
    );
  }

  @override
  void onMask() {
    buffer.writeln('BeginMask:');
  }

  @override
  void onPaintObject({
    required int color,
    required int? strokeCap,
    required int? strokeJoin,
    required int blendMode,
    required double? strokeMiterLimit,
    required double? strokeWidth,
    required int paintStyle,
    required int id,
    required int? shaderId,
  }) {
    // Fill
    if (paintStyle == 0) {
      buffer.writeln(
          'StorePaint: id:$id Fill(${_intToColor(color)}, blendMode: ${BlendMode.values[blendMode].name}, shader: $shaderId)');
    } else {
      buffer.writeln(
          'StorePaint: id:$id Stroke(${_intToColor(color)}, strokeCap: $strokeCap, $strokeJoin: $strokeJoin, '
          'blendMode: ${BlendMode.values[blendMode].name}, strokeMiterLimit: $strokeMiterLimit, strokeWidth: $strokeWidth, shader: $shaderId)');
    }
  }

  @override
  void onPathClose() {
    buffer.writeln('  close()');
  }

  @override
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    buffer.writeln('  cubicTo(($x1, $y1), ($x2, $y2), ($x3, $y3)');
  }

  @override
  void onPathFinished() {
    buffer.writeln('EndPath:');
  }

  @override
  void onPathLineTo(double x, double y) {
    buffer.writeln('  lineTo($x, $y)');
  }

  @override
  void onPathMoveTo(double x, double y) {
    buffer.writeln('  moveTo($x, $y)');
  }

  @override
  void onPathStart(int id, int fillType) {
    buffer
        .writeln('PathStart: id:$id ${fillType == 0 ? 'nonZero' : 'evenOdd'}');
  }

  @override
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform) {
    buffer.writeln(
        'StorePattern: $patternId (Rect.fromLTWH($x, $y, $width, $height), transform: $transform)');
  }

  @override
  void onRadialGradient(
      double centerX,
      double centerY,
      double radius,
      double? focalX,
      double? focalY,
      Int32List colors,
      Float32List? offsets,
      Float64List? transform,
      int tileMode,
      int id) {
    final bool hasFocal = focalX != null;
    buffer.writeln(
      'StoreGradient: id:$id Radial(\n'
      'center: ($centerX, $centerY)\n'
      'radius: $radius\n'
      '${hasFocal ? 'focal: ($focalX, $focalY)\n' : ''}'
      'colors: [${colors.map(_intToColor).join(',')}]\n'
      'offsets: $offsets\n'
      'transform: $transform\n'
      'tileMode: ${TileMode.values[tileMode].name}',
    );
  }

  @override
  void onRestoreLayer() {
    buffer.writeln('Restore:');
  }

  @override
  void onSaveLayer(int paintId) {
    buffer.writeln('SaveLayer: $paintId');
  }

  @override
  void onSize(double width, double height) {
    buffer.writeln('RecordSize: Size($width, $height)');
  }

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
    buffer.writeln(
        'RecordText: id:$id ($text, ($xAnchorMultiplier x-anchoring), weight: $fontWeight, size: $fontSize, decoration: $decoration, decorationStyle: $decorationStyle, decorationColor: 0x${decorationColor.toRadixString(16)}, family: $fontFamily)');
  }

  @override
  void onTextPosition(
    int id,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  ) {
    buffer.writeln(
        'StoreTextPosition: id:$id (($x, $y) d($dx, $dy), reset: $reset, transform: $transform)');
  }

  @override
  void onUpdateTextPosition(int id) {
    buffer.writeln('UpdateTextPosition: id:$id');
  }
}
