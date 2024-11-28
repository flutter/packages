// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'debug.dart';
import 'listener.dart';

/// The cache key for a rasterized vector graphic.
@immutable
class RasterKey {
  /// Create a new [RasterKey].
  const RasterKey(this.assetKey, this.width, this.height);

  /// An object that is used to identify the raster data this key will store.
  ///
  /// Typically this is the value returned from [BytesLoader.cacheKey].
  final Object assetKey;

  /// The height of this vector graphic raster, in physical pixels.
  final int width;

  /// The width of this vector graphic raster, in physical pixels.
  final int height;

  @override
  bool operator ==(Object other) {
    return other is RasterKey &&
        other.assetKey == assetKey &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(assetKey, width, height);
}

/// The cache entry for a rasterized vector graphic.
class RasterData {
  /// Create a new [RasterData].
  RasterData(this._image, this.count, this.key);

  /// The rasterized vector graphic.
  ui.Image get image => _image!;
  ui.Image? _image;

  /// The cache key used to identify this vector graphic.
  final RasterKey key;

  /// The number of render objects currently using this
  /// vector graphic raster data.
  int count = 0;

  /// Dispose this raster data.
  void dispose() {
    _image?.dispose();
    _image = null;
  }
}

/// For testing only, clear all pending rasters.
@visibleForTesting
void debugClearRasteCaches() {
  if (!kDebugMode) {
    return;
  }
  RenderVectorGraphic._liveRasterCache.clear();
}

/// A render object which draws a vector graphic instance as a raster.
class RenderVectorGraphic extends RenderBox {
  /// Create a new [RenderVectorGraphic].
  RenderVectorGraphic(
    this._pictureInfo,
    this._assetKey,
    this._colorFilter,
    this._devicePixelRatio,
    this._opacity,
    this._scale,
  ) {
    _opacity?.addListener(_updateOpacity);
    _updateOpacity();
  }

  static final Map<RasterKey, RasterData> _liveRasterCache =
      <RasterKey, RasterData>{};

  /// A key that uniquely identifies the [pictureInfo] used for this vg.
  Object get assetKey => _assetKey;
  Object _assetKey;
  set assetKey(Object value) {
    if (value == assetKey) {
      return;
    }
    _assetKey = value;
    // Dont call mark needs paint here since a change in just the asset key
    // isn't sufficient to force a re-draw.
  }

  /// The [PictureInfo] which contains the vector graphic and size to draw.
  PictureInfo get pictureInfo => _pictureInfo;
  PictureInfo _pictureInfo;
  set pictureInfo(PictureInfo value) {
    if (identical(value, _pictureInfo)) {
      return;
    }
    _pictureInfo = value;
    markNeedsPaint();
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
    markNeedsPaint();
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

  static RasterData _createRaster(
      RasterKey key, double scaleFactor, PictureInfo info) {
    final int scaledWidth = key.width;
    final int scaledHeight = key.height;
    // In order to scale a picture, it must be placed in a new picture
    // with a transform applied. Surprisingly, the height and width
    // arguments of Picture.toImage do not control the resolution that the
    // picture is rendered at, instead it controls how much of the picture to
    // capture in a raster.
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    canvas.scale(scaleFactor);
    canvas.drawPicture(info.picture);
    final ui.Picture rasterPicture = recorder.endRecording();

    final ui.Image pending =
        rasterPicture.toImageSync(scaledWidth, scaledHeight);
    return RasterData(pending, 0, key);
  }

  void _maybeReleaseRaster(RasterData? data) {
    if (data == null) {
      return;
    }
    data.count -= 1;
    if (data.count == 0 && _liveRasterCache.containsKey(data.key)) {
      _liveRasterCache.remove(data.key);
      data.dispose();
    }
  }

  // Re-create the raster for a given vector graphic if the target size
  // is sufficiently different. Returns `null` if rasterData has been
  // updated immediately.
  void _maybeUpdateRaster() {
    final int scaledWidth =
        (pictureInfo.size.width * devicePixelRatio / scale).round();
    final int scaledHeight =
        (pictureInfo.size.height * devicePixelRatio / scale).round();
    final RasterKey key = RasterKey(assetKey, scaledWidth, scaledHeight);

    // First check if the raster is available synchronously. This also handles
    // a no-op change that would resolve to an identical picture.
    if (_liveRasterCache.containsKey(key)) {
      final RasterData data = _liveRasterCache[key]!;
      if (data != _rasterData) {
        _maybeReleaseRaster(_rasterData);
        data.count += 1;
      }
      _rasterData = data;
      return;
    }
    final RasterData data =
        _createRaster(key, devicePixelRatio / scale, pictureInfo);
    data.count += 1;

    assert(!_liveRasterCache.containsKey(key));
    assert(data.count == 1);
    assert(!debugDisposed!);

    _liveRasterCache[key] = data;
    _maybeReleaseRaster(_rasterData);
    _rasterData = data;
  }

  RasterData? _rasterData;

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
    _maybeReleaseRaster(_rasterData);
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

    _maybeUpdateRaster();
    final ui.Image image = _rasterData!.image;
    final int width = _rasterData!.key.width;
    final int height = _rasterData!.key.height;

    // Use `FilterQuality.low` to scale the image, which corresponds to
    // bilinear interpolation.
    final Paint colorPaint = Paint()..filterQuality = ui.FilterQuality.low;
    if (colorFilter != null) {
      colorPaint.colorFilter = colorFilter;
    }
    colorPaint.color = Color.fromRGBO(0, 0, 0, _opacityValue);
    final Rect src = ui.Rect.fromLTWH(
      0,
      0,
      width.toDouble(),
      height.toDouble(),
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

/// A render object which draws a vector graphic instance as a picture.
class RenderPictureVectorGraphic extends RenderBox {
  /// Create a new [RenderPictureVectorGraphic].
  RenderPictureVectorGraphic(
    this._pictureInfo,
    this._colorFilter,
    this._opacity,
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
    markNeedsPaint();
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

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }

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
    _opacity?.removeListener(_updateOpacity);
    super.dispose();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    assert(size == pictureInfo.size);
    if (_opacityValue <= 0.0) {
      return;
    }

    final Paint colorPaint = Paint();
    if (colorFilter != null) {
      colorPaint.colorFilter = colorFilter;
    }
    colorPaint.color = Color.fromRGBO(0, 0, 0, _opacityValue);
    final int saveCount = context.canvas.getSaveCount();
    if (offset != Offset.zero) {
      context.canvas.save();
      context.canvas.translate(offset.dx, offset.dy);
    }
    if (_opacityValue != 1.0 || colorFilter != null) {
      context.canvas.save();
      context.canvas.clipRect(Offset.zero & size);
      context.canvas.saveLayer(Offset.zero & size, colorPaint);
    }
    context.canvas.drawPicture(pictureInfo.picture);
    context.canvas.restoreToCount(saveCount);
  }
}
