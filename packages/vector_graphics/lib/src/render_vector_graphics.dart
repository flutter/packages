// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'listener.dart';
import 'debug.dart';

/// A render object which draws a vector graphic instance as a raster.
class RenderVectorGraphic extends RenderBox {
  /// Create a new [RenderVectorGraphic].
  RenderVectorGraphic(
    this._pictureInfo,
    this._colorFilter,
    this._devicePixelRatio,
    this._opacity,
    this._scale,
  ) {
    _opacity?.addListener(_updateOpacity);
    _updateOpacity();
  }

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

  double _opacityValue = 1.0;

  /// An opacity to draw the rasterized vector graphic with.
  Animation<double>? get opacity => _opacity;
  Animation<double>? _opacity;
  set opacity(Animation<double>? value) {
    if (value == opacity) {
      return;
    }
    _opacity?.removeListener(_updateOpacity);
    _opacity = value;
    _opacity?.addListener(_updateOpacity);
    markNeedsPaint();
  }

  void _updateOpacity() {
    if (opacity == null) {
      return;
    }
    final double newValue = opacity!.value;
    if (newValue == _opacityValue) {
      return;
    }
    _opacityValue = newValue;
    markNeedsPaint();
  }

  /// An additional ratio the picture will be transformed by.
  ///
  /// This value is used to ensure the computed raster does not
  /// have extra pixelation from scaling in the case that a the [BoxFit]
  /// value used in the [VectorGraphic] widget implies a scaling factor
  /// greater than 1.0.
  ///
  /// For example, if the vector graphic widget is sized at 100x100,
  /// the vector graphic itself has a size of 50x50, and [BoxFit.fill]
  /// is used. This will compute a scale of 2.0, which will result in a
  /// raster that is 100x100.
  double get scale => _scale;
  double _scale;
  set scale(double value) {
    assert(value != 0);
    if (value == scale) {
      return;
    }
    _scale = value;
    _invalidateRaster();
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

  // Re-create the raster for a given vector graphic if the target size
  // is sufficiently different.
  Future<void> _maybeUpdateRaster(Size desiredSize) async {
    final int scaledWidth =
        (pictureInfo.size.width * devicePixelRatio / scale).round();
    final int scaledHeight =
        (pictureInfo.size.height * devicePixelRatio / scale).round();
    if (_lastRasterizedSize != null &&
        _lastRasterizedSize!.width == scaledWidth &&
        _lastRasterizedSize!.height == scaledHeight) {
      return;
    }
    // In order to scale a picture, it must be placed in a new picture
    // with a transform applied. Surprisingly, the height and width
    // arguments of Picture.toImage do not control the resolution that the
    // picture is rendered at, instead it controls how much of the picture to
    // capture in a raster.
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    final double totalScale = devicePixelRatio / scale;
    canvas.transform(
        Matrix4.diagonal3Values(totalScale, totalScale, totalScale).storage);
    canvas.drawPicture(pictureInfo.picture);
    final ui.Picture rasterPicture = recorder.endRecording();

    final ui.Image result =
        await rasterPicture.toImage(scaledWidth, scaledHeight);
    _currentImage?.dispose();
    _currentImage = result;
    _lastRasterizedSize = Size(scaledWidth.toDouble(), scaledHeight.toDouble());
    markNeedsPaint();
  }

  Size? _lastRasterizedSize;
  ui.Image? _currentImage;

  @override
  void attach(covariant PipelineOwner owner) {
    _opacity?.addListener(_updateOpacity);
    _updateOpacity();
    super.attach(owner);
  }

  @override
  void detach() {
    _opacity?.removeListener(_updateOpacity);
    super.detach();
  }

  @override
  void dispose() {
    _currentImage?.dispose();
    _currentImage = null;
    _opacity?.removeListener(_updateOpacity);
    super.dispose();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    assert(size == pictureInfo.size);
    if (kDebugMode && debugSkipRaster) {
      context.canvas
          .drawRect(offset & size, Paint()..color = const Color(0xFFFF00FF));
      return;
    }

    if (_opacityValue <= 0.0) {
      return;
    }

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
    colorPaint.color = const Color(0xFFFFFFFF).withOpacity(_opacityValue);
    final Rect src = ui.Rect.fromLTWH(
      0,
      0,
      _lastRasterizedSize!.width,
      _lastRasterizedSize!.height,
    );
    final Rect dst = ui.Rect.fromLTWH(
      offset.dx,
      offset.dy,
      pictureInfo.size.width,
      pictureInfo.size.height,
    );
    context.canvas.drawImageRect(
      image,
      src,
      dst,
      colorPaint,
    );
  }
}
