// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A callback for the [AnimatedSamplerBuilder] widget.
typedef AnimatedSamplerBuilder = void Function(
    ui.Image, Size, Offset offset, ui.Canvas);

/// A widget that allows access to a snapshot of the child widgets for painting
/// with a sampler applied to a [FragmentProgram].
///
/// When [enabled] is true, the child widgets will be painted into a texture
/// exposed as a [ui.Image]. This can then be passed to a [FragmentShader]
/// instance via [FragmentShader.setSampler].
///
/// If [enabled] is false, then the child widgets are painted as normal.
///
/// Caveats:
///   * Platform views cannot be captured in a texture. If any are present they
///     will be excluded from the texture. Texture-based platform views are OK.
///   * This widget will not be automatically notified if a child widget needs
///     to repaint. This can lead to delays as the child widget will only be
///     updated when this widget is marked dirty. To avoid this situation, this
///     widget should only have [enabled] set to true when there is an ongoing
///     animation driving a fragment shader.
///
/// Example:
///
/// providing an image to a fragment shader using [FragmentShader.setSampler].
///
/// ```dart
/// Widget build(BuildContext context) {
///  return AnimatedSampler(
///    (ui.Image image, Size size, Canvas canvas) {
///      shader
///        ..setFloat(0, size.width)
///        ..setFloat(1, size.height)
///        ..setSampler(0, ui.ImageShader(image, TileMode.clamp, TileMode.clamp, _identity));
///      canvas.drawImage(image, Offset.zero, Paint()..shader = shader);
///     },
///     child: widget.child,
///    );
/// }
/// ```
///
/// See also:
///   * [SnapshotWidget], which provides a similar API for the purpose of
///      caching during expensive animations.
class AnimatedSampler extends StatelessWidget {
  /// Create a new [AnimatedSampler].
  const AnimatedSampler(
    this.builder, {
    required this.child,
    super.key,
    this.enabled = true,
  });

  /// A callback used by this widget to provide the children captured in
  /// a texture.
  final AnimatedSamplerBuilder builder;

  /// Whether the children should be captured in a texture or displayed as
  /// normal.
  final bool enabled;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ShaderSamplerImpl(
      builder,
      enabled: enabled,
      child: child,
    );
  }
}

class _ShaderSamplerImpl extends SingleChildRenderObjectWidget {
  const _ShaderSamplerImpl(this.builder, {super.child, required this.enabled});

  final AnimatedSamplerBuilder builder;
  final bool enabled;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderShaderSamplerBuilderWidget(
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      builder: builder,
      enabled: enabled,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderShaderSamplerBuilderWidget)
      ..devicePixelRatio = MediaQuery.of(context).devicePixelRatio
      ..builder = builder
      ..enabled = enabled;
  }
}

// A render object that conditionally converts its child into a [ui.Image]
// and then paints it in place of the child.
class _RenderShaderSamplerBuilderWidget extends RenderProxyBox {
  // Create a new [_RenderSnapshotWidget].
  _RenderShaderSamplerBuilderWidget({
    required double devicePixelRatio,
    required AnimatedSamplerBuilder builder,
    required bool enabled,
  })  : _devicePixelRatio = devicePixelRatio,
        _builder = builder,
        _enabled = enabled;

  /// The device pixel ratio used to create the child image.
  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    if (_childRaster == null) {
      return;
    } else {
      _childRaster?.dispose();
      _childRaster = null;
      markNeedsPaint();
    }
  }

  /// The painter used to paint the child snapshot or child widgets.
  AnimatedSamplerBuilder get builder => _builder;
  AnimatedSamplerBuilder _builder;
  set builder(AnimatedSamplerBuilder value) {
    if (value == builder) {
      return;
    }
    _builder = value;
    markNeedsPaint();
  }

  bool get enabled => _enabled;
  bool _enabled;
  set enabled(bool value) {
    if (value == enabled) {
      return;
    }
    _enabled = value;
    markNeedsPaint();
  }

  ui.Image? _childRaster;

  @override
  void detach() {
    _childRaster?.dispose();
    _childRaster = null;
    super.detach();
  }

  @override
  void dispose() {
    _childRaster?.dispose();
    _childRaster = null;
    super.dispose();
  }

  // Paint [child] with this painting context, then convert to a raster and detach all
  // children from this layer.
  ui.Image? _paintAndDetachToImage() {
    final OffsetLayer offsetLayer = OffsetLayer();
    final PaintingContext context =
        PaintingContext(offsetLayer, Offset.zero & size);
    super.paint(context, Offset.zero);
    // This ignore is here because this method is protected by the `PaintingContext`. Adding a new
    // method that performs the work of `_paintAndDetachToImage` would avoid the need for this, but
    // that would conflict with our goals of minimizing painting context.
    // ignore: invalid_use_of_protected_member
    context.stopRecordingIfNeeded();
    final ui.Image image = offsetLayer.toImageSync(Offset.zero & size,
        pixelRatio: devicePixelRatio);
    offsetLayer.dispose();
    return image;
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) {
      _childRaster?.dispose();
      _childRaster = null;
      return;
    }

    if (!enabled) {
      _childRaster?.dispose();
      _childRaster = null;
      return super.paint(context, offset);
    }
    _childRaster?.dispose();
    _childRaster = _paintAndDetachToImage();
    builder(_childRaster!, size, offset, context.canvas);
  }
}
