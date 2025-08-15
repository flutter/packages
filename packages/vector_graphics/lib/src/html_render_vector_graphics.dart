// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'debug.dart';
import 'listener.dart';

/// A render object which draws a vector graphic instance as a picture
/// for HTML compatibility.
class RenderWebVectorGraphic extends RenderBox {
  /// Create a new [RenderWebVectorGraphic].
  RenderWebVectorGraphic(
    this._pictureInfo,
    this._assetKey,
    this._colorFilter,
    this._opacity,
  ) {
    _opacity?.addListener(_updateOpacity);
    _updateOpacity();
  }

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
  bool get alwaysNeedsCompositing => true;

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
    _transformLayer.layer = null;
    _opacityHandle.layer = null;
    _filterLayer.layer = null;
    super.dispose();
  }

  final LayerHandle<TransformLayer> _transformLayer =
      LayerHandle<TransformLayer>();
  final LayerHandle<OpacityLayer> _opacityHandle = LayerHandle<OpacityLayer>();
  final LayerHandle<ColorFilterLayer> _filterLayer =
      LayerHandle<ColorFilterLayer>();
  final Matrix4 _transform = Matrix4.identity();

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

    // The HTML backend cannot correctly draw saveLayer opacity or color
    // filters. Nor does it support toImageSync.
    _transformLayer.layer = context.pushTransform(
      true,
      offset,
      _transform,
      (PaintingContext context, Offset offset) {
        _opacityHandle.layer = context.pushOpacity(
          offset,
          (_opacityValue * 255).round(),
          (PaintingContext context, Offset offset) {
            if (colorFilter != null) {
              _filterLayer.layer = context.pushColorFilter(
                offset,
                colorFilter!,
                (PaintingContext context, Offset offset) {
                  context.canvas.drawPicture(pictureInfo.picture);
                },
                oldLayer: _filterLayer.layer,
              );
            } else {
              _filterLayer.layer = null;
              context.canvas.drawPicture(pictureInfo.picture);
            }
          },
          oldLayer: _opacityHandle.layer,
        );
      },
      oldLayer: _transformLayer.layer,
    );
  }
}
