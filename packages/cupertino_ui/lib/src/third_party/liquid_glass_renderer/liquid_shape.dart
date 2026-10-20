// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../constants/glass_defaults.dart';

/// Represents a shape that can be used by a [LiquidGlass] widget.
// ignore: deprecated_member_use
sealed class LiquidShape extends OutlinedBorder {
  const LiquidShape({super.side = BorderSide.none});

  @protected
  OutlinedBorder get _equivalentOutlinedBorder;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _equivalentOutlinedBorder.getInnerPath(
      rect,
      textDirection: textDirection,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _equivalentOutlinedBorder.getOuterPath(
      rect,
      textDirection: textDirection,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    _equivalentOutlinedBorder.paint(canvas, rect, textDirection: textDirection);
  }

  /// The effective corner radius passed to the shader for this shape.
  ///
  /// For symmetric shapes this is the single corner radius value. For
  /// asymmetric shapes (e.g. [LiquidVerticalRoundedRectangle]) it is the
  /// dominant / largest corner radius; the shader receives the per-corner
  /// breakdown separately. For shapes that are inherently circular (e.g.
  /// [LiquidOval]) this returns [double.infinity], which callers clamp to
  /// `min(width, height) / 2`.
  ///
  /// This getter is the single source of truth consumed by all rendering paths
  /// and is obfuscation-safe — unlike `runtimeType.toString()` heuristics or
  /// `dynamic` property access, which break under `--obfuscate`.
  double get effectiveRadius;

  /// Returns the [BorderRadius] associated with this shape if it has rounded
  /// corners, or `null` if the shape is inherently non-rectangular (e.g. [LiquidOval]).
  ///
  /// Non-finite radii (such as [double.infinity]) are safely guarded via
  /// [GlassDefaults.safeRadius] so that Flutter's RRect scaling algorithm does
  /// not collapse the corners to zero.
  BorderRadius? toBorderRadius() => null;

  /// Returns whether this shape is a superellipse (squircle) rather than a
  /// standard rounded rectangle.
  bool get isSuperellipse => false;

  /// Returns the equivalent standard Flutter [OutlinedBorder] representing this shape.
  OutlinedBorder toOutlinedBorder() => _equivalentOutlinedBorder;
}

/// Represents a squircle shape that can be used by a [LiquidGlass] widget.
///
/// Works like a [RoundedSuperellipseBorder].
class LiquidRoundedSuperellipse extends LiquidShape {
  /// Creates a new [LiquidRoundedSuperellipse] with the given [borderRadius].
  const LiquidRoundedSuperellipse({
    required this.borderRadius,
    super.side = BorderSide.none,
  });

  /// The radius of the squircle.
  ///
  /// This is the radius of the corners of the squircle.
  final double borderRadius;

  @override
  double get effectiveRadius => borderRadius;

  @override
  BorderRadius toBorderRadius() => GlassDefaults.safeBorderRadius(borderRadius);

  @override
  bool get isSuperellipse => true;

  @override
  OutlinedBorder get _equivalentOutlinedBorder => RoundedSuperellipseBorder(
        borderRadius: toBorderRadius(),
        side: side,
      );

  @override
  LiquidRoundedSuperellipse copyWith({
    BorderSide? side,
    double? borderRadius,
  }) {
    return LiquidRoundedSuperellipse(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return LiquidRoundedSuperellipse(
      borderRadius: borderRadius * t,
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LiquidRoundedSuperellipse &&
        other.side == side &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius);
}

/// Represents an ellipse shape that can be used by a [LiquidGlass] widget.
///
/// Works like an [OvalBorder].
class LiquidOval extends LiquidShape {
  /// Creates a new [LiquidOval] with the given [side].
  const LiquidOval({super.side = BorderSide.none});

  /// Returns [double.infinity] — callers clamp to `min(width, height) / 2`.
  @override
  double get effectiveRadius => double.infinity;

  @override
  OutlinedBorder get _equivalentOutlinedBorder => const OvalBorder();

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return LiquidOval(
      side: side ?? this.side,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return LiquidOval(
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LiquidOval && other.side == side;
  }

  @override
  int get hashCode => side.hashCode;
}

/// Represents a rounded rectangle shape that can be used by a [LiquidGlass]
/// widget.
///
/// Works like a [RoundedRectangleBorder].
class LiquidRoundedRectangle extends LiquidShape {
  /// Creates a new [LiquidRoundedRectangle] with the given [borderRadius].
  const LiquidRoundedRectangle({
    required this.borderRadius,
    super.side = BorderSide.none,
  });

  /// The radius of the rounded rectangle.
  ///
  /// This is the radius of the corners of the rounded rectangle.
  final double borderRadius;

  @override
  double get effectiveRadius => borderRadius;

  @override
  BorderRadius toBorderRadius() => GlassDefaults.safeBorderRadius(borderRadius);

  @override
  OutlinedBorder get _equivalentOutlinedBorder => RoundedRectangleBorder(
        borderRadius: toBorderRadius(),
        side: side,
      );

  @override
  LiquidRoundedRectangle copyWith({
    BorderSide? side,
    double? borderRadius,
  }) {
    return LiquidRoundedRectangle(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return LiquidRoundedRectangle(
      borderRadius: borderRadius * t,
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LiquidRoundedRectangle &&
        other.side == side &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius);
}

/// Represents a rounded rectangle shape with different radii for top and bottom.
class LiquidVerticalRoundedRectangle extends LiquidShape {
  /// Creates a new [LiquidVerticalRoundedRectangle].
  const LiquidVerticalRoundedRectangle({
    required this.topRadius,
    required this.bottomRadius,
    super.side = BorderSide.none,
  });

  /// The radius of the top corners.
  final double topRadius;

  /// The radius of the bottom corners.
  final double bottomRadius;

  /// Returns the larger of [topRadius] and [bottomRadius].
  ///
  /// The shader receives individual per-corner radii separately via the
  /// asymmetric data path; this value is used only when a single representative
  /// radius is needed (e.g. for the lightweight shader fallback).
  @override
  double get effectiveRadius => math.max(topRadius, bottomRadius);

  @override
  BorderRadius toBorderRadius() =>
      GlassDefaults.safeVerticalBorderRadius(topRadius, bottomRadius);

  @override
  OutlinedBorder get _equivalentOutlinedBorder => RoundedRectangleBorder(
        borderRadius: toBorderRadius(),
        side: side,
      );

  @override
  LiquidVerticalRoundedRectangle copyWith({
    BorderSide? side,
    double? topRadius,
    double? bottomRadius,
  }) {
    return LiquidVerticalRoundedRectangle(
      side: side ?? this.side,
      topRadius: topRadius ?? this.topRadius,
      bottomRadius: bottomRadius ?? this.bottomRadius,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return LiquidVerticalRoundedRectangle(
      topRadius: topRadius * t,
      bottomRadius: bottomRadius * t,
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LiquidVerticalRoundedRectangle &&
        other.side == side &&
        other.topRadius == topRadius &&
        other.bottomRadius == bottomRadius;
  }

  @override
  int get hashCode => Object.hash(side, topRadius, bottomRadius);
}

/// Represents a squircle shape with different radii for top and bottom.
///
/// Works like a [RoundedSuperellipseBorder] with vertical border radii.
class LiquidVerticalRoundedSuperellipse extends LiquidShape {
  /// Creates a new [LiquidVerticalRoundedSuperellipse].
  const LiquidVerticalRoundedSuperellipse({
    required this.topRadius,
    required this.bottomRadius,
    super.side = BorderSide.none,
  });

  /// The radius of the top corners.
  final double topRadius;

  /// The radius of the bottom corners.
  final double bottomRadius;

  /// Returns the larger of [topRadius] and [bottomRadius].
  ///
  /// The shader receives individual per-corner radii separately via the
  /// asymmetric data path; this value is used only when a single representative
  /// radius is needed.
  @override
  double get effectiveRadius => math.max(topRadius, bottomRadius);

  @override
  BorderRadius toBorderRadius() =>
      GlassDefaults.safeVerticalBorderRadius(topRadius, bottomRadius);

  @override
  bool get isSuperellipse => true;

  @override
  OutlinedBorder get _equivalentOutlinedBorder => RoundedSuperellipseBorder(
        borderRadius: toBorderRadius(),
        side: side,
      );

  @override
  LiquidVerticalRoundedSuperellipse copyWith({
    BorderSide? side,
    double? topRadius,
    double? bottomRadius,
  }) {
    return LiquidVerticalRoundedSuperellipse(
      side: side ?? this.side,
      topRadius: topRadius ?? this.topRadius,
      bottomRadius: bottomRadius ?? this.bottomRadius,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return LiquidVerticalRoundedSuperellipse(
      topRadius: topRadius * t,
      bottomRadius: bottomRadius * t,
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LiquidVerticalRoundedSuperellipse &&
        other.side == side &&
        other.topRadius == topRadius &&
        other.bottomRadius == bottomRadius;
  }

  @override
  int get hashCode => Object.hash(side, topRadius, bottomRadius);
}
