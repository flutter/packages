// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'listener.dart';

/// A render object which draws a vector graphic instance as a raster.
class RenderVectorGraphic extends RenderBox {
  /// Create a new [RenderVectorGraphic].
  RenderVectorGraphic(
    this._pictureInfo,
    this._colorFilter,
    this._devicePixelRatio,
    this._opacity,
  );

  /// The [PictureInfo] which contains the vector graphic and size to draw.
  PictureInfo get pictureInfo => _pictureInfo;
  PictureInfo _pictureInfo;
  set pictureInfo(PictureInfo value) {
    if (identical(value, _pictureInfo)) {
      return;
    }
    _pictureInfo = value;
    _invalidateRaster();
  }

  /// An optional [ColorFilter] to apply to the rasterized vector graphic.
  ColorFilter? get colorFilter => _colorFilter;
  ColorFilter? _colorFilter;
  set colorFilter(ColorFilter? value) {
    if (colorFilter == value) {
      return;
    }
    _colorFilter = value;
    markNeedsPaint();
  }

  /// The device pixel ratio the vector graphic should be rasterized at.
  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    _invalidateRaster();
  }

  /// An opacity to draw the rasterized vector graphic with.
  double get opacity => _opacity;
  double _opacity;
  set opacity(double value) {
    assert(value >= 0.0 && value <= 1.0);
    if (value == opacity) {
      return;
    }
    _opacity = value;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }

  void _invalidateRaster() {
    _lastRasterizedSize = null;
    markNeedsPaint();
  }

  /// Visible for testing only.
  @visibleForTesting
  Future<void>? get pendingRasterUpdate {
    if (kReleaseMode) {
      return null;
    }
    return _pendingRasterUpdate;
  }

  Future<void>? _pendingRasterUpdate;

  // Re-create the raster for a given SVG if the target size
  // is sufficiently different.
  Future<void> _maybeUpdateRaster(Size desiredSize) async {
    double scale = 1.0;
    if (desiredSize != pictureInfo.size) {
      scale = math.min(
        desiredSize.width / pictureInfo.size.width,
        desiredSize.height / pictureInfo.size.height,
      );
    }
    final int scaledWidth = (pictureInfo.size.width * scale).round();
    final int scaledHeight = (pictureInfo.size.height * scale).round();
    if (_lastRasterizedSize != null &&
        _lastRasterizedSize!.width == scaledWidth &&
        _lastRasterizedSize!.height == scaledHeight) {
      return;
    }
    final ui.Image result = await pictureInfo.picture.toImage(
        (scaledWidth * devicePixelRatio).round(),
        (scaledHeight * devicePixelRatio).round());
    _currentImage?.dispose();
    _currentImage = result;
    _lastRasterizedSize = Size(scaledWidth.toDouble(), scaledHeight.toDouble());
    markNeedsPaint();
  }

  Size? _lastRasterizedSize;
  ui.Image? _currentImage;

  @override
  void dispose() {
    _currentImage?.dispose();
    _currentImage = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (opacity <= 0.0) {
      return;
    }

    final Offset pictureOffset = _pictureOffset(size, pictureInfo.size);
    final ui.Image? image = _currentImage;
    _pendingRasterUpdate = _maybeUpdateRaster(size);
    if (image == null || _lastRasterizedSize == null) {
      return;
    }

    // Use `FilterQuality.low` to scale the image, which corresponds to
    // bilinear interpolation.
    final Paint colorPaint = Paint()..filterQuality = ui.FilterQuality.low;
    if (colorFilter != null) {
      colorPaint.colorFilter = colorFilter!;
    }
    colorPaint.color = const Color(0xFFFFFFFF).withOpacity(opacity);
    final Offset dstOffset = offset + pictureOffset;
    final Rect src = ui.Rect.fromLTWH(
      0,
      0,
      pictureInfo.size.width,
      pictureInfo.size.height,
    );
    final Rect dst = ui.Rect.fromLTWH(
      dstOffset.dx,
      dstOffset.dy,
      _lastRasterizedSize!.width,
      _lastRasterizedSize!.height,
    );
    context.canvas.drawImageRect(
      image,
      src,
      dst,
      colorPaint,
    );
  }
}

Offset _pictureOffset(
  Size desiredSize,
  Size pictureSize,
) {
  if (desiredSize == pictureSize) {
    return Offset.zero;
  }
  final double scale = math.min(
    desiredSize.width / pictureSize.width,
    desiredSize.height / pictureSize.height,
  );
  final Size scaledHalfViewBoxSize = pictureSize * scale / 2.0;
  final Size halfDesiredSize = desiredSize / 2.0;
  final Offset shift = Offset(
    halfDesiredSize.width - scaledHalfViewBoxSize.width,
    halfDesiredSize.height - scaledHalfViewBoxSize.height,
  );
  return shift;
}
