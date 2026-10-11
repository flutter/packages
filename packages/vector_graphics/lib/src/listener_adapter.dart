// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

/// A base for passes that consume selected codec commands without rendering.
abstract class VectorGraphicsListenerAdapter extends VectorGraphicsCodecListener {
  @override
  void onPathGeometry(int pathId) {}

  @override
  void onBeginFilter(VectorFilter filter, Float64List transform, double width, double height) {}

  @override
  void onEndFilter() {}

  @override
  void onSize(double width, double height) {}

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
  }) {}

  @override
  void onPathStart(int id, int fillType) {}

  @override
  void onPathMoveTo(double x, double y) {}

  @override
  void onPathLineTo(double x, double y) {}

  @override
  void onPathCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {}

  @override
  void onPathClose() {}

  @override
  void onPathFinished() {}

  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {}

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {}

  @override
  void onSaveLayer(int paintId) {}

  @override
  void onClipPath(int pathId) {}

  @override
  void onRestoreLayer() {}

  @override
  void onMask() {}

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
    int id,
  ) {}

  @override
  void onLinearGradient(
    double fromX,
    double fromY,
    double toX,
    double toY,
    Int32List colors,
    Float32List? offsets,
    int tileMode,
    int id,
  ) {}

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
  ) {}

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {}

  @override
  void onImage(int imageId, int format, Uint8List data, {VectorGraphicsErrorListener? onError}) {}

  @override
  void onDrawImage(
    int imageId,
    double x,
    double y,
    double width,
    double height,
    Float64List? transform,
  ) {}

  @override
  void onPatternStart(
    int patternId,
    double x,
    double y,
    double width,
    double height,
    Float64List transform,
  ) {}

  @override
  void onTextPosition(
    int textPositionId,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  ) {}

  @override
  void onUpdateTextPosition(int textPositionId) {}
}
