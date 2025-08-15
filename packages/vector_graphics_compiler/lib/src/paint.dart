// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'geometry/basic_types.dart';
import 'geometry/matrix.dart';
import 'util.dart';

// The enumerations in this file must match the ordering and index valuing of
// the similarly named enumerations in dart:ui.

/// An immutable representation of a 32 bit color.
@immutable
class Color {
  /// Creates an immutable representation of a 32 bit color.
  ///
  /// The first 8 bits are the alpha value, the next 8 red, the next 8 green,
  /// and the last 8 blue.
  const Color(this.value);

  /// Creates an immutable representation of color from its red, green, blue,
  /// and 0..1 opacity parts.
  const Color.fromRGBO(int r, int g, int b, double opacity)
      : value = ((((opacity * 0xff ~/ 1) & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;

  /// Creates an immutable representation of color from its alpha, red, green,
  /// and blue parts.
  ///
  /// Each part is represented by an integer from 0..255.
  const Color.fromARGB(int a, int r, int g, int b)
      : value = (((a & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;

  /// Fully opaque black.
  static const Color opaqueBlack = Color(0xFF000000);

  /// Creates a new color based on this color with the specified opacity,
  /// unpremultiplied.
  Color withOpacity(double opacity) {
    return Color.fromRGBO(r, g, b, opacity);
  }

  /// The raw 32 bit color value.
  ///
  /// The first 8 bits are the alpha value, the next 8 red, the next 8 green,
  /// and the last 8 blue.
  final int value;

  /// The red channel value from 0..255.
  int get r => (0x00ff0000 & value) >> 16;

  /// The green channel value from 0..255.
  int get g => (0x0000ff00 & value) >> 8;

  /// The blue channel value from 0..255.
  int get b => (0x000000ff & value) >> 0;

  /// The opacity channel value from 0..255.
  int get a => value >> 24;

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) {
    return other is Color && other.value == value;
  }
}

/// A shading program to apply to a [Paint]. Implemented in [LinearGradient] and
/// [RadialGradient].
@immutable
abstract class Gradient {
  /// Allows subclasses to be const.
  const Gradient._(
    this.id,
    this.colors,
    this.offsets,
    this.tileMode,
    this.unitMode,
    this.transform,
  );

  /// The reference identifier for this gradient.
  final String id;

  /// The colors to blend from the start to end points.
  final List<Color>? colors;

  /// The positions to apply [colors] to. Must be the same length as [colors].
  final List<double>? offsets;

  /// Specifies the meaning of [from] and [to].
  final TileMode? tileMode;

  /// Whether the coordinates in this gradient should be transformed by the
  /// space this object occupies or by the root bounds.
  final GradientUnitMode? unitMode;

  /// The transform, if any, to apply to the gradient.
  final AffineMatrix? transform;

  /// Apply the bounds and transform the shader.
  Gradient applyBounds(Rect bounds, AffineMatrix transform);

  /// Creates a new gradient
  Gradient applyProperties(Gradient ref);
}

/// A [Gradient] that describes a linear gradient from [from] to [to].
///
/// If [offsets] is provided, `offsets[i]` is a number from 0.0 to 1.0
/// that specifies where `offsets[i]` begins in the gradient. If [offsets] is
/// not provided, then only two stops, at 0.0 and 1.0, are implied (and
/// [colors] must therefore only have two entries).
///
/// The behavior before [from] and after [to] is described by the [tileMode]
/// argument. For details, see the [TileMode] enum.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_linear.png)
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_linear.png)
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_linear.png)
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_linear.png)
///
/// If [transform] is provided, the gradient fill will be transformed by the
/// specified affine matrix relative to the local coordinate system.
class LinearGradient extends Gradient {
  /// Creates a new linear gradient shader.
  const LinearGradient({
    required String id,
    required this.from,
    required this.to,
    List<Color>? colors,
    List<double>? offsets,
    TileMode? tileMode,
    GradientUnitMode? unitMode,
    AffineMatrix? transform,
  }) : super._(id, colors, offsets, tileMode, unitMode, transform);

  /// The start point of the gradient, as specified by [tileMode].
  final Point from;

  /// The end point of the gradient, as specified by [tileMode].
  final Point to;

  @override
  LinearGradient applyBounds(Rect bounds, AffineMatrix transform) {
    assert(offsets != null);
    assert(colors != null);
    AffineMatrix accumulatedTransform = this.transform ?? AffineMatrix.identity;
    switch (unitMode ?? GradientUnitMode.objectBoundingBox) {
      case GradientUnitMode.objectBoundingBox:
        accumulatedTransform = transform
            .translated(bounds.left, bounds.top)
            .scaled(bounds.width, bounds.height)
            .multiplied(accumulatedTransform);
      case GradientUnitMode.userSpaceOnUse:
        accumulatedTransform = transform.multiplied(accumulatedTransform);
      case GradientUnitMode.transformed:
        break;
    }

    return LinearGradient(
      id: id,
      from: accumulatedTransform.transformPoint(from),
      to: accumulatedTransform.transformPoint(to),
      colors: colors,
      offsets: offsets,
      tileMode: tileMode ?? TileMode.clamp,
      unitMode: GradientUnitMode.transformed,
    );
  }

  @override
  LinearGradient applyProperties(Gradient ref) {
    return LinearGradient(
      id: id,
      from: from,
      to: to,
      colors: colors ?? ref.colors,
      offsets: offsets ?? ref.offsets,
      tileMode: tileMode ?? ref.tileMode,
      unitMode: unitMode ?? ref.unitMode,
      transform: transform ?? ref.transform,
    );
  }

  @override
  int get hashCode => Object.hash(
      id,
      from,
      to,
      Object.hashAll(colors ?? <Color>[]),
      Object.hashAll(offsets ?? <double>[]),
      tileMode,
      unitMode);

  @override
  bool operator ==(Object other) {
    return other is LinearGradient &&
        other.id == id &&
        other.from == from &&
        other.to == to &&
        listEquals(other.colors, colors) &&
        listEquals(other.offsets, offsets) &&
        other.tileMode == tileMode &&
        other.unitMode == unitMode;
  }

  @override
  String toString() {
    return 'LinearGradient('
        "id: '$id', "
        'from: $from, '
        'to: $to, '
        'colors: <Color>$colors, '
        'offsets: <double>$offsets, '
        'tileMode: $tileMode, '
        '${transform == null ? '' : 'Float64List.fromList(${transform!.toMatrix4()}), '}'
        'unitMode: $unitMode)';
  }
}

/// Determines how to transform the points given for a gradient.
enum GradientUnitMode {
  /// The gradient vector(s) are transformed by the space in the object
  /// containing the gradient.
  objectBoundingBox,

  /// The gradient vector(s) are transformed by the root bounds of the drawing.
  userSpaceOnUse,

  /// The gradient vectors are already transformed.
  transformed,
}

/// Creates a radial gradient centered at [center] that ends at [radius]
/// distance from the center.
///
/// If [offsets] is provided, `offsets[i]` is a number from 0.0 to 1.0
/// that specifies where `colors[i]` begins in the gradient. If [offsets] is
/// not provided, then only two stops, at 0.0 and 1.0, are implied (and
/// [colors] must therefore only have two entries).
///
/// The behavior before and after the radius is described by the [tileMode]
/// argument. For details, see the [TileMode] enum.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_radial.png)
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_radial.png)
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_radial.png)
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_radial.png)
///
/// If [transform] is provided, the gradient fill will be transformed by the
/// specified affine matrix relative to the local coordinate system.
///
/// If [focalPoint] is provided and not equal to [center] and [focalRadius]
/// is provided and not equal to 0.0, the generated shader will be a two point
/// conical radial gradient, with [focalPoint] being the center of the focal
/// circle. If [focalPoint] is provided and not equal to [center], at least one
/// of the two offsets must not be equal to [Point.zero].
class RadialGradient extends Gradient {
  /// Creates a new radial gradient object with the specified properties.
  ///
  /// See [RadialGradient].
  const RadialGradient({
    required String id,
    required this.center,
    required this.radius,
    List<Color>? colors,
    List<double>? offsets,
    TileMode? tileMode,
    AffineMatrix? transform,
    this.focalPoint,
    GradientUnitMode? unitMode,
  }) : super._(id, colors, offsets, tileMode, unitMode, transform);

  /// The central point of the gradient.
  final Point center;

  /// The colors to blend from the start to end points.
  final double radius;

  /// If specified, creates a two-point conical gradient using [center] and the
  /// [focalPoint].
  final Point? focalPoint;

  @override
  RadialGradient applyBounds(Rect bounds, AffineMatrix transform) {
    assert(offsets != null);
    assert(colors != null);
    AffineMatrix accumulatedTransform = this.transform ?? AffineMatrix.identity;
    switch (unitMode ?? GradientUnitMode.objectBoundingBox) {
      case GradientUnitMode.objectBoundingBox:
        accumulatedTransform = transform
            .translated(bounds.left, bounds.top)
            .scaled(bounds.width, bounds.height)
            .multiplied(accumulatedTransform);
      case GradientUnitMode.userSpaceOnUse:
        accumulatedTransform = transform.multiplied(accumulatedTransform);
      case GradientUnitMode.transformed:
        break;
    }

    return RadialGradient(
      id: id,
      center: center,
      radius: radius,
      colors: colors,
      offsets: offsets,
      tileMode: tileMode ?? TileMode.clamp,
      transform: accumulatedTransform,
      focalPoint: focalPoint,
      unitMode: GradientUnitMode.transformed,
    );
  }

  @override
  RadialGradient applyProperties(Gradient ref) {
    return RadialGradient(
      id: id,
      center: center,
      radius: radius,
      focalPoint: focalPoint,
      colors: colors ?? ref.colors,
      offsets: offsets ?? ref.offsets,
      transform: transform ?? ref.transform,
      unitMode: unitMode ?? ref.unitMode,
      tileMode: tileMode ?? ref.tileMode,
    );
  }

  @override
  int get hashCode => Object.hash(
      id,
      center,
      radius,
      Object.hashAll(colors ?? <Color>[]),
      Object.hashAll(offsets ?? <double>[]),
      tileMode,
      transform,
      focalPoint,
      unitMode);

  @override
  bool operator ==(Object other) {
    return other is RadialGradient &&
        other.id == id &&
        other.center == center &&
        other.radius == radius &&
        other.focalPoint == focalPoint &&
        listEquals(other.colors, colors) &&
        listEquals(other.offsets, offsets) &&
        other.transform == transform &&
        other.tileMode == tileMode &&
        other.unitMode == unitMode;
  }

  @override
  String toString() {
    return 'RadialGradient('
        "id: '$id', "
        'center: $center, '
        'radius: $radius, '
        'colors: <Color>$colors, '
        'offsets: <double>$offsets, '
        'tileMode: $tileMode, '
        '${transform == null ? '' : 'transform: Float64List.fromList(<double>${transform!.toMatrix4()}) ,'}'
        'focalPoint: $focalPoint, '
        'unitMode: $unitMode)';
  }
}

/// An immutable collection of painting attributes.
///
/// Null attribute values indicate that a value is expected to inherit from
/// parent or accept a child's painting value.
///
/// Leaf nodes in a painting graph must have a non-null [fill] or a non-null
/// [stroke]. If both [stroke] and [fill] are not null, the expected painting
/// order is [fill] followed by [stroke].
@immutable
class Paint {
  /// Creates a new collection of painting attributes.
  ///
  /// See [Paint].
  const Paint({
    BlendMode? blendMode,
    this.stroke,
    this.fill,
  }) : blendMode = blendMode ?? BlendMode.srcOver;

  /// The Porter-Duff algorithm to use when compositing this painting object
  /// with any objects painted under it.
  ///
  /// Defaults to [BlendMode.srcOver].
  final BlendMode blendMode;

  /// The stroke properties, if any, to apply to shapes drawn with this paint.
  ///
  /// If both stroke and [fill] are non-null, the fill is painted first,
  /// followed by stroke.
  final Stroke? stroke;

  /// The fill properties, if any, to apply to shapes drawn with this paint.
  ///
  /// If both [stroke] and fill are non-null, the fill is painted first,
  /// followed by stroke.
  final Fill? fill;

  @override
  int get hashCode => Object.hash(blendMode, stroke, fill);

  @override
  bool operator ==(Object other) {
    return other is Paint &&
        other.blendMode == blendMode &&
        other.stroke == stroke &&
        other.fill == fill;
  }

  /// Apply the bounds to the given paint.
  ///
  /// May be a no-op if no properties of the paint are impacted by
  /// the bounds.
  Paint applyBounds(Rect bounds, AffineMatrix transform) {
    final Gradient? shader = fill?.shader;
    if (shader == null) {
      return this;
    }
    final Gradient newShader = shader.applyBounds(bounds, transform);
    return Paint(
      blendMode: blendMode,
      stroke: stroke,
      fill: Fill(
        color: fill!.color,
        shader: newShader,
      ),
    );
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('Paint(blendMode: $blendMode');
    const String leading = ', ';
    if (stroke != null) {
      buffer.write('${leading}stroke: $stroke');
    }
    if (fill != null) {
      buffer.write('${leading}fill: $fill');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// An immutable collection of stroking properties for a [Paint].
///
/// See also [Paint.stroke].
@immutable
class Stroke {
  /// Creates a new collection of stroking properties.
  const Stroke({
    Color? color,
    this.shader,
    this.cap,
    this.join,
    this.miterLimit,
    this.width,
  }) : color = color ?? Color.opaqueBlack;

  /// The color to use for this stroke.
  ///
  /// Defaults to [Color.opaqueBlack].
  ///
  /// If [shader] is not null, only the opacity is used.
  final Color color;

  /// The [Gradient] to use when stroking.
  final Gradient? shader;

  /// The cap style to use for strokes.
  ///
  /// Defaults to [StrokeCap.butt].
  final StrokeCap? cap;

  /// The join style to use for strokes.
  ///
  /// Defaults to [StrokeJoin.miter].
  final StrokeJoin? join;

  /// The limit where stroke joins drawn with [StrokeJoin.miter] switch to being
  /// drawn as [StrokeJoin.bevel].
  final double? miterLimit;

  /// The width of the stroke, if [style] is [PaintingStyle.stroke].
  final double? width;

  @override
  int get hashCode => Object.hash(
      PaintingStyle.stroke, color, shader, cap, join, miterLimit, width);

  @override
  bool operator ==(Object other) {
    return other is Stroke &&
        other.color == color &&
        other.shader == shader &&
        other.cap == cap &&
        other.join == join &&
        other.miterLimit == miterLimit &&
        other.width == width;
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('Stroke(color: $color');
    const String leading = ', ';
    if (shader != null) {
      buffer.write('${leading}shader: $shader');
    }
    if (cap != null) {
      buffer.write('${leading}cap: $cap');
    }
    if (join != null) {
      buffer.write('${leading}join: $join');
    }
    if (miterLimit != null) {
      buffer.write('${leading}miterLimit: $miterLimit');
    }
    if (width != null) {
      buffer.write('${leading}width: $width');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// An immutable representation of filling attributes for a [Paint].
///
/// See also [Paint.fill].
@immutable
class Fill {
  /// Creates a new immutable set of drawing attributes for a [Paint].
  const Fill({
    Color? color,
    this.shader,
  }) : color = color ?? Color.opaqueBlack;

  /// The color to use for this stroke.
  ///
  /// Defaults to [Color.opaqueBlack].
  ///
  /// If [shader] is not null, only the opacity is used.
  final Color color;

  /// The [Gradient] to use when filling.
  final Gradient? shader;

  @override
  int get hashCode => Object.hash(PaintingStyle.fill, color, shader);

  @override
  bool operator ==(Object other) {
    return other is Fill && other.color == color && other.shader == shader;
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('Fill(color: $color');
    const String leading = ', ';

    if (shader != null) {
      buffer.write('${leading}shader: $shader');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// The Porter-Duff algorithm to use for blending.
///
/// The values in this enum are expected to match exactly the values of the
/// similarly named enum from dart:ui. They must not be removed even if they
/// are unused.
enum BlendMode {
  // This list comes from Skia's SkXfermode.h and the values (order) should be
  // kept in sync.
  // See: https://skia.org/docs/user/api/skpaint_overview/#SkXfermode

  /// Drop both the source and destination images, leaving nothing.
  ///
  /// This corresponds to the "clear" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_clear.png)
  clear,

  /// Drop the destination image, only paint the source image.
  ///
  /// Conceptually, the destination is first cleared, then the source image is
  /// painted.
  ///
  /// This corresponds to the "Copy" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_src.png)
  src,

  /// Drop the source image, only paint the destination image.
  ///
  /// Conceptually, the source image is discarded, leaving the destination
  /// untouched.
  ///
  /// This corresponds to the "Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dst.png)
  dst,

  /// Composite the source image over the destination image.
  ///
  /// This is the default value. It represents the most intuitive case, where
  /// shapes are painted on top of what is below, with transparent areas showing
  /// the destination layer.
  ///
  /// This corresponds to the "Source over Destination" Porter-Duff operator,
  /// also known as the Painter's Algorithm.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcOver.png)
  srcOver,

  /// Composite the source image under the destination image.
  ///
  /// This is the opposite of [srcOver].
  ///
  /// This corresponds to the "Destination over Source" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstOver.png)
  ///
  /// This is useful when the source image should have been painted before the
  /// destination image, but could not be.
  dstOver,

  /// Show the source image, but only where the two images overlap. The
  /// destination image is not rendered, it is treated merely as a mask. The
  /// color channels of the destination are ignored, only the opacity has an
  /// effect.
  ///
  /// To show the destination image instead, consider [dstIn].
  ///
  /// To reverse the semantic of the mask (only showing the source where the
  /// destination is absent, rather than where it is present), consider
  /// [srcOut].
  ///
  /// This corresponds to the "Source in Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcIn.png)
  srcIn,

  /// Show the destination image, but only where the two images overlap. The
  /// source image is not rendered, it is treated merely as a mask. The color
  /// channels of the source are ignored, only the opacity has an effect.
  ///
  /// To show the source image instead, consider [srcIn].
  ///
  /// To reverse the semantic of the mask (only showing the source where the
  /// destination is present, rather than where it is absent), consider [dstOut].
  ///
  /// This corresponds to the "Destination in Source" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstIn.png)
  dstIn,

  /// Show the source image, but only where the two images do not overlap. The
  /// destination image is not rendered, it is treated merely as a mask. The color
  /// channels of the destination are ignored, only the opacity has an effect.
  ///
  /// To show the destination image instead, consider [dstOut].
  ///
  /// To reverse the semantic of the mask (only showing the source where the
  /// destination is present, rather than where it is absent), consider [srcIn].
  ///
  /// This corresponds to the "Source out Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcOut.png)
  srcOut,

  /// Show the destination image, but only where the two images do not overlap. The
  /// source image is not rendered, it is treated merely as a mask. The color
  /// channels of the source are ignored, only the opacity has an effect.
  ///
  /// To show the source image instead, consider [srcOut].
  ///
  /// To reverse the semantic of the mask (only showing the destination where the
  /// source is present, rather than where it is absent), consider [dstIn].
  ///
  /// This corresponds to the "Destination out Source" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstOut.png)
  dstOut,

  /// Composite the source image over the destination image, but only where it
  /// overlaps the destination.
  ///
  /// This corresponds to the "Source atop Destination" Porter-Duff operator.
  ///
  /// This is essentially the [srcOver] operator, but with the output's opacity
  /// channel being set to that of the destination image instead of being a
  /// combination of both image's opacity channels.
  ///
  /// For a variant with the destination on top instead of the source, see
  /// [dstATop].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_srcATop.png)
  srcATop,

  /// Composite the destination image over the source image, but only where it
  /// overlaps the source.
  ///
  /// This corresponds to the "Destination atop Source" Porter-Duff operator.
  ///
  /// This is essentially the [dstOver] operator, but with the output's opacity
  /// channel being set to that of the source image instead of being a
  /// combination of both image's opacity channels.
  ///
  /// For a variant with the source on top instead of the destination, see
  /// [srcATop].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_dstATop.png)
  dstATop,

  /// Apply a bitwise `xor` operator to the source and destination images. This
  /// leaves transparency where they would overlap.
  ///
  /// This corresponds to the "Source xor Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_xor.png)
  xor,

  /// Sum the components of the source and destination images.
  ///
  /// Transparency in a pixel of one of the images reduces the contribution of
  /// that image to the corresponding output pixel, as if the color of that
  /// pixel in that image was darker.
  ///
  /// This corresponds to the "Source plus Destination" Porter-Duff operator.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_plus.png)
  plus,

  /// Multiply the color components of the source and destination images.
  ///
  /// This can only result in the same or darker colors (multiplying by white,
  /// 1.0, results in no change; multiplying by black, 0.0, results in black).
  ///
  /// When compositing two opaque images, this has similar effect to overlapping
  /// two transparencies on a projector.
  ///
  /// For a variant that also multiplies the alpha channel, consider [multiply].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_modulate.png)
  ///
  /// See also:
  ///
  ///  * [screen], which does a similar computation but inverted.
  ///  * [overlay], which combines [modulate] and [screen] to favor the
  ///    destination image.
  ///  * [hardLight], which combines [modulate] and [screen] to favor the
  ///    source image.
  modulate,

  // Following blend modes are defined in the CSS Compositing standard.

  /// Multiply the inverse of the components of the source and destination
  /// images, and inverse the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// This is essentially the same as [modulate] blend mode, but with the values
  /// of the colors inverted before the multiplication and the result being
  /// inverted back before rendering.
  ///
  /// This can only result in the same or lighter colors (multiplying by black,
  /// 1.0, results in no change; multiplying by white, 0.0, results in white).
  /// Similarly, in the alpha channel, it can only result in more opaque colors.
  ///
  /// This has similar effect to two projectors displaying their images on the
  /// same screen simultaneously.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_screen.png)
  ///
  /// See also:
  ///
  ///  * [modulate], which does a similar computation but without inverting the
  ///    values.
  ///  * [overlay], which combines [modulate] and [screen] to favor the
  ///    destination image.
  ///  * [hardLight], which combines [modulate] and [screen] to favor the
  ///    source image.
  screen, // The last coeff mode.

  /// Multiply the components of the source and destination images after
  /// adjusting them to favor the destination.
  ///
  /// Specifically, if the destination value is smaller, this multiplies it with
  /// the source value, whereas is the source value is smaller, it multiplies
  /// the inverse of the source value with the inverse of the destination value,
  /// then inverts the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_overlay.png)
  ///
  /// See also:
  ///
  ///  * [modulate], which always multiplies the values.
  ///  * [screen], which always multiplies the inverses of the values.
  ///  * [hardLight], which is similar to [overlay] but favors the source image
  ///    instead of the destination image.
  overlay,

  /// Composite the source and destination image by choosing the lowest value
  /// from each color channel.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_darken.png)
  darken,

  /// Composite the source and destination image by choosing the highest value
  /// from each color channel.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_lighten.png)
  lighten,

  /// Divide the destination by the inverse of the source.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_colorDodge.png)
  colorDodge,

  /// Divide the inverse of the destination by the source, and inverse the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_colorBurn.png)
  colorBurn,

  /// Multiply the components of the source and destination images after
  /// adjusting them to favor the source.
  ///
  /// Specifically, if the source value is smaller, this multiplies it with the
  /// destination value, whereas is the destination value is smaller, it
  /// multiplies the inverse of the destination value with the inverse of the
  /// source value, then inverts the result.
  ///
  /// Inverting the components means that a fully saturated channel (opaque
  /// white) is treated as the value 0.0, and values normally treated as 0.0
  /// (black, transparent) are treated as 1.0.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_hardLight.png)
  ///
  /// See also:
  ///
  ///  * [modulate], which always multiplies the values.
  ///  * [screen], which always multiplies the inverses of the values.
  ///  * [overlay], which is similar to [hardLight] but favors the destination
  ///    image instead of the source image.
  hardLight,

  /// Use [colorDodge] for source values below 0.5 and [colorBurn] for source
  /// values above 0.5.
  ///
  /// This results in a similar but softer effect than [overlay].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_softLight.png)
  ///
  /// See also:
  ///
  ///  * [color], which is a more subtle tinting effect.
  softLight,

  /// Subtract the smaller value from the bigger value for each channel.
  ///
  /// Compositing black has no effect; compositing white inverts the colors of
  /// the other image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// The effect is similar to [exclusion] but harsher.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_difference.png)
  difference,

  /// Subtract double the product of the two images from the sum of the two
  /// images.
  ///
  /// Compositing black has no effect; compositing white inverts the colors of
  /// the other image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver].
  ///
  /// The effect is similar to [difference] but softer.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_exclusion.png)
  exclusion,

  /// Multiply the components of the source and destination images, including
  /// the alpha channel.
  ///
  /// This can only result in the same or darker colors (multiplying by white,
  /// 1.0, results in no change; multiplying by black, 0.0, results in black).
  ///
  /// Since the alpha channel is also multiplied, a fully-transparent pixel
  /// (opacity 0.0) in one image results in a fully transparent pixel in the
  /// output. This is similar to [dstIn], but with the colors combined.
  ///
  /// For a variant that multiplies the colors but does not multiply the alpha
  /// channel, consider [modulate].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_multiply.png)
  multiply, // The last separable mode.

  /// Take the hue of the source image, and the saturation and luminosity of the
  /// destination image.
  ///
  /// The effect is to tint the destination image with the source image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their hue from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_hue.png)
  ///
  /// See also:
  ///
  ///  * [color], which is a similar but stronger effect as it also applies the
  ///    saturation of the source image.
  ///  * [HSVColor], which allows colors to be expressed using Hue rather than
  ///    the red/green/blue channels of [Color].
  hue,

  /// Take the saturation of the source image, and the hue and luminosity of the
  /// destination image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their saturation from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_hue.png)
  ///
  /// See also:
  ///
  ///  * [color], which also applies the hue of the source image.
  ///  * [luminosity], which applies the luminosity of the source image to the
  ///    destination.
  saturation,

  /// Take the hue and saturation of the source image, and the luminosity of the
  /// destination image.
  ///
  /// The effect is to tint the destination image with the source image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their hue and saturation from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_color.png)
  ///
  /// See also:
  ///
  ///  * [hue], which is a similar but weaker effect.
  ///  * [softLight], which is a similar tinting effect but also tints white.
  ///  * [saturation], which only applies the saturation of the source image.
  color,

  /// Take the luminosity of the source image, and the hue and saturation of the
  /// destination image.
  ///
  /// The opacity of the output image is computed in the same way as for
  /// [srcOver]. Regions that are entirely transparent in the source image take
  /// their luminosity from the destination.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/blend_mode_luminosity.png)
  ///
  /// See also:
  ///
  ///  * [saturation], which applies the saturation of the source image to the
  ///    destination.
  ///  * [ImageFilter.blur], which can be used with [BackdropFilter] for a
  ///    related effect.
  luminosity,
}

/// Strategies for painting shapes and paths on a canvas.
///
/// See [Paint.style].
// These enum values must be kept in sync with SkPaint::Style.
enum PaintingStyle {
  // This list comes from Skia's SkPaint.h and the values (order) should be kept
  // in sync.

  /// Apply the [Paint] to the inside of the shape. For example, when
  /// applied to the [Canvas.drawCircle] call, this results in a disc
  /// of the given size being painted.
  fill,

  /// Apply the [Paint] to the edge of the shape. For example, when
  /// applied to the [Canvas.drawCircle] call, this results is a hoop
  /// of the given size being painted. The line drawn on the edge will
  /// be the width given by the [Paint.width] property.
  stroke,
}

/// Styles to use for line endings.
///
/// See also:
///
///  * [Paint.strokeCap] for how this value is used.
///  * [StrokeJoin] for the different kinds of line segment joins.
// These enum values must be kept in sync with SkPaint::Cap.
enum StrokeCap {
  /// Begin and end contours with a flat edge and no extension.
  ///
  /// ![A butt cap ends line segments with a square end that stops at the end of
  /// the line segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/butt_cap.png)
  ///
  /// Compare to the [square] cap, which has the same shape, but extends past
  /// the end of the line by half a stroke width.
  butt,

  /// Begin and end contours with a semi-circle extension.
  ///
  /// ![A round cap adds a rounded end to the line segment that protrudes
  /// by one half of the thickness of the line (which is the radius of the cap)
  /// past the end of the segment.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  round,

  /// Begin and end contours with a half square extension. This is
  /// similar to extending each contour by half the stroke width (as
  /// given by [Paint.width]).
  ///
  /// ![A square cap has a square end that effectively extends the line length
  /// by half of the stroke width.](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/square_cap.png)
  ///
  /// The cap is colored in the diagram above to highlight it: in normal use it
  /// is the same color as the line.
  ///
  /// Compare to the [butt] cap, which has the same shape, but doesn't extend
  /// past the end of the line.
  square,
}

/// Styles to use for line segment joins.
///
/// This only affects line joins for polygons drawn by [Canvas.drawPath] and
/// rectangles, not points drawn as lines with [Canvas.drawPoints].
///
/// See also:
///
/// * [Paint.join] and [Paint.miterLimit] for how this value is
///   used.
/// * [StrokeCap] for the different kinds of line endings.
// These enum values must be kept in sync with SkPaint::Join.
enum StrokeJoin {
  /// Joins between line segments form sharp corners.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/miter_4_join.mp4}
  ///
  /// The center of the line segment is colored in the diagram above to
  /// highlight the join, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///   * [Paint.join], used to set the line segment join style to this
  ///     value.
  ///   * [Paint.miterLimit], used to define when a miter is drawn instead
  ///     of a bevel when the join is set to this value.
  miter,

  /// Joins between line segments are semi-circular.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/round_join.mp4}
  ///
  /// The center of the line segment is colored in the diagram above to
  /// highlight the join, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///   * [Paint.join], used to set the line segment join style to this
  ///     value.
  round,

  /// Joins between line segments connect the corners of the butt ends of the
  /// line segments to give a beveled appearance.
  ///
  /// {@animation 300 300 https://flutter.github.io/assets-for-api-docs/assets/dart-ui/bevel_join.mp4}
  ///
  /// The center of the line segment is colored in the diagram above to
  /// highlight the join, but in normal usage the join is the same color as the
  /// line.
  ///
  /// See also:
  ///
  ///   * [Paint.join], used to set the line segment join style to this
  ///     value.
  bevel,
}

/// Defines what happens at the edge of a gradient or the sampling of a source image
/// in an [ImageFilter].
///
/// A gradient is defined along a finite inner area. In the case of a linear
/// gradient, it's between the parallel lines that are orthogonal to the line
/// drawn between two points. In the case of radial gradients, it's the disc
/// that covers the circle centered on a particular point up to a given radius.
///
/// An image filter reads source samples from a source image and performs operations
/// on those samples to produce a result image. An image defines color samples only
/// for pixels within the bounds of the image but some filter operations, such as a blur
/// filter, read samples over a wide area to compute the output for a given pixel. Such
/// a filter would need to combine samples from inside the image with hypothetical
/// color values from outside the image.
///
/// This enum is used to define how the gradient or image filter should treat the regions
/// outside that defined inner area.
///
/// See also:
///
///  * [painting.Gradient], the superclass for [LinearGradient] and
///    [RadialGradient], as used by [BoxDecoration] et al, which works in
///    relative coordinates and can create a [Shader] representing the gradient
///    for a particular [Rect] on demand.
///  * [dart:ui.Gradient], the low-level class used when dealing with the
///    [Paint.shader] property directly, with its [Gradient.linear] and
///    [Gradient.radial] constructors.
///  * [dart:ui.ImageFilter.blur], an ImageFilter that may sometimes need to
///    read samples from outside an image to combine with the pixels near the
///    edge of the image.
// These enum values must be kept in sync with SkTileMode.
enum TileMode {
  /// Samples beyond the edge are clamped to the nearest color in the defined inner area.
  ///
  /// A gradient will paint all the regions outside the inner area with the
  /// color at the end of the color stop list closest to that region.
  ///
  /// An image filter will substitute the nearest edge pixel for any samples taken from
  /// outside its source image.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_sweep.png)
  clamp,

  /// Samples beyond the edge are repeated from the far end of the defined area.
  ///
  /// For a gradient, this technique is as if the stop points from 0.0 to 1.0 were then
  /// repeated from 1.0 to 2.0, 2.0 to 3.0, and so forth (and for linear gradients, similarly
  /// from -1.0 to 0.0, -2.0 to -1.0, etc).
  ///
  /// An image filter will treat its source image as if it were tiled across the enlarged
  /// sample space from which it reads, each tile in the same orientation as the base image.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_sweep.png)
  repeated,

  /// Samples beyond the edge are mirrored back and forth across the defined area.
  ///
  /// For a gradient, this technique is as if the stop points from 0.0 to 1.0 were then
  /// repeated backwards from 2.0 to 1.0, then forwards from 2.0 to 3.0, then backwards
  /// again from 4.0 to 3.0, and so forth (and for linear gradients, similarly in the
  /// negative direction).
  ///
  /// An image filter will treat its source image as tiled in an alternating forwards and
  /// backwards or upwards and downwards direction across the sample space from which
  /// it is reading.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_sweep.png)
  mirror,

  /// Samples beyond the edge are treated as transparent black.
  ///
  /// A gradient will render transparency over any region that is outside the circle of a
  /// radial gradient or outside the parallel lines that define the inner area of a linear
  /// gradient.
  ///
  /// An image filter will substitute transparent black for any sample it must read from
  /// outside its source image.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_sweep.png)
  decal,
}

/// A description of how to update the current text position.
///
/// If [reset] is true, this update discards the previous current text position.
/// Otherwise, it appends to the previous text position.
@immutable
class TextPosition {
  /// See [TextPosition].
  const TextPosition({
    this.x,
    this.y,
    this.dx,
    this.dy,
    this.reset = false,
    this.transform,
  });

  /// The horizontal axis coordinate for the current text position.
  ///
  /// If null, use the current text position accumulated since the last [reset],
  /// or 0 if this represents a reset.
  final double? x;

  /// The horizontal axis coordinate to add to the current text position.
  ///
  /// If null, use the current text position accumulated since the last [reset],
  /// or 0 if this represents a reset.
  final double? dx;

  /// The vertical axis coordinate for the current text position.
  ///
  /// If null, use the current text position accumulated since the last [reset],
  /// or 0 if this represents a reset.
  final double? y;

  /// The vertical axis coordinate to add to the current text position.
  ///
  /// If null, use the current text position accumulated since the last [reset],
  /// or 0 if this represents a reset.
  final double? dy;

  /// If true, reset the current text position using [x] and [y].
  final bool reset;

  /// A transform applied to the rendered font.
  ///
  /// If `null` this implies no transform.
  final AffineMatrix? transform;

  @override
  int get hashCode => Object.hash(x, y, dx, dy, reset, transform);

  @override
  bool operator ==(Object other) {
    return other is TextPosition &&
        other.x == x &&
        other.y == y &&
        other.dx == dx &&
        other.dy == dy &&
        other.reset == reset &&
        other.transform == transform;
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.write('TextPosition(reset: $reset');
    if (x != null) {
      buffer.write(', x: $x');
    }
    if (y != null) {
      buffer.write(', y: $y');
    }
    if (dx != null) {
      buffer.write(', dx: $dx');
    }
    if (dy != null) {
      buffer.write(', dy: $dy');
    }
    if (transform != null) {
      buffer.write(', transform: $transform');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// Additional text specific configuration that is added to the encoding.
@immutable
class TextConfig {
  /// Create a new [TextStyle] object.
  const TextConfig(
    this.text,
    this.xAnchorMultiplier,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
  );

  /// The text to be rendered.
  final String text;

  /// A multiplier for text anchoring.
  ///
  /// This value should be multiplied by the length of the longest line in the
  /// text and subtracted from x coordinate of the current [TextPosition].
  final double xAnchorMultiplier;

  /// The size of the font, only supported as absolute size.
  final double fontSize;

  /// The name of the font family to select for rendering.
  final String? fontFamily;

  /// The font weight, converted to a weight constant.
  final FontWeight fontWeight;

  /// The decoration to apply to the text.
  final TextDecoration decoration;

  /// The decoration style to apply to the text.
  final TextDecorationStyle decorationStyle;

  /// The color to use for the decoration, if any.
  final Color decorationColor;

  @override
  int get hashCode => Object.hash(
        text,
        xAnchorMultiplier,
        fontSize,
        fontFamily,
        fontWeight,
        decoration,
        decorationStyle,
        decorationColor,
      );

  @override
  bool operator ==(Object other) {
    return other is TextConfig &&
        other.text == text &&
        other.xAnchorMultiplier == xAnchorMultiplier &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily &&
        other.fontWeight == fontWeight &&
        other.decoration == decoration &&
        other.decorationStyle == decorationStyle &&
        other.decorationColor == decorationColor;
  }

  @override
  String toString() {
    return 'TextConfig('
        "'$text', "
        '$xAnchorMultiplier, '
        "'$fontFamily', "
        '$fontWeight, '
        '$fontSize, '
        '$decoration, '
        '$decorationStyle, '
        '$decorationColor,)';
  }
}

/// The value of the font weight.
///
/// This matches the enum values defined in dart:ui.
enum FontWeight {
  /// A font weight of 100,
  w100,

  /// A font weight of 200,
  w200,

  /// A font weight of 300,
  w300,

  /// A font weight of 400,
  w400,

  /// A font weight of 500,
  w500,

  /// A font weight of 600,
  w600,

  /// A font weight of 700,
  w700,

  /// A font weight of 800,
  w800,

  /// A font weight of 900,
  w900,
}

/// The style in which to draw a text decoration
///
/// This matches the enum values defined in dart:ui.
enum TextDecorationStyle {
  /// Draw a solid line
  solid,

  /// Draw two lines
  double,

  /// Draw a dotted line
  dotted,

  /// Draw a dashed line
  dashed,

  /// Draw a sinusoidal line
  wavy
}

/// A linear decoration to draw near the text.
///
/// This matches the enum values defined in dart:ui.
@immutable
class TextDecoration {
  const TextDecoration._(this.mask);

  /// Creates a decoration that paints the union of all the given decorations.
  factory TextDecoration.combine(List<TextDecoration> decorations) {
    int mask = 0;
    for (final TextDecoration decoration in decorations) {
      mask |= decoration.mask;
    }
    return TextDecoration._(mask);
  }

  /// The raw mask for serialization.
  final int mask;

  /// Whether this decoration will paint at least as much decoration as the given decoration.
  bool contains(TextDecoration other) {
    return (mask | other.mask) == mask;
  }

  /// Do not draw a decoration
  static const TextDecoration none = TextDecoration._(kNoTextDecorationMask);

  /// Draw a line underneath each line of text
  static const TextDecoration underline = TextDecoration._(kUnderlineMask);

  /// Draw a line above each line of text
  static const TextDecoration overline = TextDecoration._(kOverlineMask);

  /// Draw a line through each line of text
  static const TextDecoration lineThrough = TextDecoration._(kLineThroughMask);

  @override
  bool operator ==(Object other) {
    return other is TextDecoration && other.mask == mask;
  }

  @override
  int get hashCode => mask.hashCode;

  @override
  String toString() {
    if (mask == 0) {
      return 'TextDecoration.none';
    }
    final List<String> values = <String>[];
    if (mask & underline.mask != 0) {
      values.add('underline');
    }
    if (mask & overline.mask != 0) {
      values.add('overline');
    }
    if (mask & lineThrough.mask != 0) {
      values.add('lineThrough');
    }
    if (values.length == 1) {
      return 'TextDecoration.${values[0]}';
    }
    return 'TextDecoration.combine([${values.join(", ")}])';
  }
}

/// The default font weight.
const FontWeight normalFontWeight = FontWeight.w400;

/// A commonly used font weight that is heavier than normal.
const FontWeight boldFontWeight = FontWeight.w700;
