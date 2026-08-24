// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// A callback used by the [ShaderInkFeature] to configure the fragment shader
/// on each frame of the inkwell animation.
///
/// [animation] represents the animation progress, starting at `0` and ending
/// at `1` when the animation is complete.
///
/// See also:
///
///   * [ShaderInkFeature] for more information on the available configuration.
typedef ShaderConfigCallback = void Function(
  ui.FragmentShader shader, {
  required double animation,
  required Size referenceBoxSize,
  required Color color,
  required Offset position,
  required TextDirection textDirection,
  required double targetRadius,
});

/// Allows customization of the material inkwell effect with a user authored
/// fragment shader.
///
/// On each frame of the inkwell animation, the provided [callback] will be
/// invoked with a fragment shader instance, as well as the configuration for
/// the particular inkwell splash that is occuring. It is the responsibility
/// of the developer to supply both a fragment program and a callback that
/// delivers the ink well effect.
///
/// Example:
///
/// Configuring all inkwells in a material application with a fragment program.
///
/// ```glsl
/// #include <flutter/runtime_effect.glsl>
///
/// uniform float uAnimation;
/// uniform vec4 uColor;
/// uniform float uRadius;
/// uniform vec2 uCenter;
///
/// out vec4 fragColor;
///
/// void main() {
///  float scale = distance(FlutterFragCoord(), uCenter) / uRadius;
///  fragColor = mix(vec4(1.0), uColor, scale) * (1.0 - uAnimation);
/// }
/// ```
///
/// ```dart
/// Widget build(BuildContext context) {
///   return MaterialApp(
///     title: 'Flutter Demo',
///     theme: ThemeData(
///       primarySwatch: Colors.blue,
///       splashFactory: ShaderInkFeatureFactory(program, (
///         shader, {
///           required double animation,
///           required Color color,
///           required Offset position,
///           required Size referenceBoxSize,
///           required double targetRadius,
///           required TextDirection textDirection,
///         }) {
///           shader
///             ..setFloat(0, animation)
///             ..setFloat(1, color.red / 255.0 * color.opacity)
///             ..setFloat(2, color.green / 255.0 * color.opacity)
///             ..setFloat(3, color.blue / 255.0 * color.opacity)
///             ..setFloat(4, color.opacity)
///             ..setFloat(5, targetRadius)
///             ..setFloat(6, position.dx)
///             ..setFloat(7, position.dy);
///         })),
///      home: const MyHomePage(title: 'Flutter Demo Home Page'),
///    );
///  }
/// ```
///
/// See also:
///
///   * [ShaderInkFeature] for more information on the available configuration.
class ShaderInkFeatureFactory extends InteractiveInkFeatureFactory {
  const ShaderInkFeatureFactory(
    this.program,
    this.callback, {
    this.animationDuration = const Duration(milliseconds: 617),
  });

  final ui.FragmentProgram program;
  final ShaderConfigCallback callback;
  final Duration animationDuration;

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return ShaderInkFeature(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      textDirection: textDirection,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      animationDuration: animationDuration,
      callback: callback,
      fragmentShader: program.fragmentShader(),
    );
  }
}

/// An ink feature that is driven by a developer authored fragment shader and
/// a configuration callback.
class ShaderInkFeature extends InteractiveInkFeature {
  /// Begin a sparkly ripple effect, centered at [position] relative to
  /// [referenceBox].
  ///
  /// The [color] defines the color of the splash itself. The sparkles are
  /// always white.
  ///
  /// The [controller] argument is typically obtained via
  /// `Material.of(context)`.
  ///
  /// [textDirection] is used by [customBorder] if it is non-null. This allows
  /// the [customBorder]'s path to be properly defined if it was the path was
  /// expressed in terms of "start" and "end" instead of
  /// "left" and "right".
  ///
  /// If [containedInkWell] is true, then the ripple will be sized to fit
  /// the well rectangle, then clipped to it when drawn. The well
  /// rectangle is the box returned by [rectCallback], if provided, or
  /// otherwise is the bounds of the [referenceBox].
  ///
  /// If [containedInkWell] is false, then [rectCallback] should be null.
  /// The ink ripple is clipped only to the edges of the [Material].
  /// This is the default.
  ///
  /// Clipping can happen in 3 different ways:
  ///  1. If [customBorder] is provided, it is used to determine the path for
  ///     clipping.
  ///  2. If [customBorder] is null, and [borderRadius] is provided, then the
  ///     canvas is clipped by an [RRect] created from [borderRadius].
  ///  3. If [borderRadius] is the default [BorderRadius.zero], then the canvas
  ///     is clipped with [rectCallback].
  /// When the ripple is removed, [onRemoved] will be called.
  ShaderInkFeature({
    required super.controller,
    required super.referenceBox,
    required super.color,
    required Offset position,
    required TextDirection textDirection,
    required Duration animationDuration,
    required ui.FragmentShader fragmentShader,
    required ShaderConfigCallback callback,
    bool containedInkWell = true,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    super.onRemoved,
    double? turbulenceSeed,
  })  : _fragmentShader = fragmentShader,
        _callback = callback,
        _animationDuration = animationDuration,
        _position = position,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _textDirection = textDirection,
        _targetRadius = (radius ??
            _getTargetRadius(
              referenceBox,
              containedInkWell,
              rectCallback,
              position,
            )),
        _clipCallback =
            _getClipCallback(referenceBox, containedInkWell, rectCallback) {
    controller.addInkFeature(this);

    // Immediately begin animating the ink.
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: controller.vsync,
    )
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleStatusChanged)
      ..forward();
  }

  late AnimationController _animationController;
  final Offset _position;
  final BorderRadius _borderRadius;
  final ShapeBorder? _customBorder;
  final double _targetRadius;
  final RectCallback? _clipCallback;
  final TextDirection _textDirection;
  final Duration _animationDuration;
  final ui.FragmentShader _fragmentShader;
  final ShaderConfigCallback _callback;

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      dispose();
    }
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    _fragmentShader.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    assert(_animationController.isAnimating);

    canvas.save();
    _transformCanvas(canvas: canvas, transform: transform);
    if (_clipCallback != null) {
      _clipCanvas(
        canvas: canvas,
        clipCallback: _clipCallback!,
        textDirection: _textDirection,
        customBorder: _customBorder,
        borderRadius: _borderRadius,
      );
    }

    _updateFragmentShader();

    final Paint paint = Paint()..shader = _fragmentShader;
    if (_clipCallback != null) {
      canvas.drawRect(_clipCallback!(), paint);
    } else {
      canvas.drawPaint(paint);
    }
    canvas.restore();
  }

  void _updateFragmentShader() {
    _callback(
      _fragmentShader,
      animation: _animationController.value,
      color: color,
      position: _position,
      referenceBoxSize: referenceBox.size,
      targetRadius: _targetRadius,
      textDirection: _textDirection,
    );
  }

  /// Transforms the canvas for an ink feature to be painted on the [canvas].
  ///
  /// This should be called before painting ink features that do not use
  /// [paintInkCircle].
  ///
  /// The [transform] argument is the [Matrix4] transform that typically
  /// shifts the coordinate space of the canvas to the space in which
  /// the ink feature is to be painted.
  ///
  /// For examples on how the function is used, see [InkSparkle] and [paintInkCircle].
  void _transformCanvas({
    required Canvas canvas,
    required Matrix4 transform,
  }) {
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    if (originOffset == null) {
      canvas.transform(transform.storage);
    } else {
      canvas.translate(originOffset.dx, originOffset.dy);
    }
  }

  /// Clips the canvas for an ink feature to be painted on the [canvas].
  ///
  /// This should be called before painting ink features with [paintFeature]
  /// that do not use [paintInkCircle].
  ///
  /// The [clipCallback] is the callback used to obtain the [Rect] used for clipping
  /// the ink effect.
  ///
  /// If [clipCallback] is null, no clipping is performed on the ink circle.
  ///
  /// The [textDirection] is used by [customBorder] if it is non-null. This
  /// allows the [customBorder]'s path to be properly defined if the path was
  /// expressed in terms of "start" and "end" instead of "left" and "right".
  ///
  /// For examples on how the function is used, see [InkSparkle].
  void _clipCanvas({
    required Canvas canvas,
    required RectCallback clipCallback,
    TextDirection? textDirection,
    ShapeBorder? customBorder,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    final Rect rect = clipCallback();
    if (customBorder != null) {
      canvas.clipPath(
          customBorder.getOuterPath(rect, textDirection: textDirection));
    } else if (borderRadius != BorderRadius.zero) {
      canvas.clipRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ));
    } else {
      canvas.clipRect(rect);
    }
  }
}

double _getTargetRadius(
  RenderBox referenceBox,
  bool containedInkWell,
  RectCallback? rectCallback,
  Offset position,
) {
  final Size size =
      rectCallback != null ? rectCallback().size : referenceBox.size;
  final double d1 = size.bottomRight(Offset.zero).distance;
  final double d2 =
      (size.topRight(Offset.zero) - size.bottomLeft(Offset.zero)).distance;
  return math.max(d1, d2) / 2.0;
}

RectCallback? _getClipCallback(
  RenderBox referenceBox,
  bool containedInkWell,
  RectCallback? rectCallback,
) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) {
    return () => Offset.zero & referenceBox.size;
  }
  return null;
}
