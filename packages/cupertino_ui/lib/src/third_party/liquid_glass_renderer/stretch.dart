// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'glass_drag_builder.dart';
import '../renderer/liquid_glass_self_scale_scope.dart';
import '../../utils/glass_spring.dart';

/// Configuration for the anchor stretch effect on interactive glass widgets.
///
/// This bundles the fine-tuning parameters for how a widget stretches when
/// the user presses and drags — just like [LiquidGlassSettings] bundles
/// glass rendering parameters.
///
/// Most developers won't need to change these — the defaults match iOS 26
/// button behaviour. Use this when you want to fine-tune the feel:
///
/// ```dart
/// GlassButton(
///   anchorStretchSettings: AnchorStretchSettings(
///     intensity: 0.8,  // more stretchy
///     bounciness: 0.2, // more elastic snap-back
///   ),
/// )
/// ```
class AnchorStretchSettings {
  /// Creates anchor stretch settings.
  ///
  /// All values have sensible defaults matching iOS 26 behaviour.
  const AnchorStretchSettings({
    this.intensity = 0.5,
    this.squashFactor = 0.3,
    this.translationDamping = 0.15,
    this.bounciness = 0.15,
  });

  /// How much the widget elongates in the drag direction.
  ///
  /// `0.0` = no elongation, `1.0` = matches drag distance 1:1 relative
  /// to widget size. Higher values = stretchier.
  ///
  /// Defaults to `0.5`.
  final double intensity;

  /// How much the perpendicular dimension compresses during stretch.
  ///
  /// `0.0` = no squash (shape stays round), `1.0` = full volume-preserving
  /// squash. Lower values keep content (text, icons) from distorting.
  ///
  /// Defaults to `0.3`.
  final double squashFactor;

  /// How far the widget's center shifts toward the finger.
  ///
  /// `0.0` = perfectly anchored, `1.0` = follows finger fully.
  /// Small values (0.1–0.2) give a satisfying bounce-back.
  ///
  /// Defaults to `0.15`.
  final double translationDamping;

  /// Extra bounciness added to the release spring.
  ///
  /// `0.0` = standard elastic snap-back. `0.1`–`0.3` = more pronounced
  /// overshoot that makes the widget visibly bounce past rest.
  ///
  /// Defaults to `0.15` — a subtle overshoot matching native iOS 26 buttons.
  final double bounciness;

  /// The stretch a native iOS 26 button shows on a long drag: no more than
  /// ~5 % of elongation with matching squash, a few points of travel, and no
  /// rebound of its own — the release bounce lives in the press scale.
  static const AnchorStretchSettings nativeTremor = AnchorStretchSettings(
    intensity: 0.1,
    squashFactor: 0.1,
    translationDamping: 0.1,
    bounciness: 0.0,
  );
}

/// A widget that provides a squash and stretch effect to its child based on
/// user interaction.
///
/// Will listen to drag gestures from the user without interfering with other
/// gestures.
class LiquidStretch extends StatelessWidget {
  /// Creates a new [LiquidStretch] widget with the given [child],
  /// [interactionScale], and [stretch].
  const LiquidStretch({
    required this.child,
    this.interactionScale = 1.05,
    this.pressGrowth,
    this.stretch = .5,
    this.resistance = .01,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.axis,
    this.allowPositive = true,
    this.allowNegative = true,
    this.allowPositiveX,
    this.allowNegativeX,
    this.allowPositiveY,
    this.allowNegativeY,
    this.suppressInteractionOnChildren = true,
    this.anchorStretch = true,
    this.anchorStretchSettings = const AnchorStretchSettings(),
    super.key,
  });

  /// The scale factor to apply when the user is interacting with the widget.
  ///
  /// A value of 1.0 means no scaling.
  ///
  /// A value greater than 2.0 means the widget will grow to double its
  /// original size.
  ///
  /// A value less than 1.0 means the widget will scale down.
  ///
  /// Defaults to 1.05.
  final double interactionScale;

  /// How many logical pixels the widget's longest side grows when pressed.
  ///
  /// When set, the press scale is derived from the widget's size at layout
  /// and [interactionScale] is ignored. A native iOS 26 button grows by about
  /// the same number of points whatever its size — measured at ~17 pt
  /// ([nativePressGrowth]), so a 56 pt circle inflates ~1.3× and a 132 pt
  /// pill ~1.13×.
  ///
  /// Defaults to null (use [interactionScale]).
  final double? pressGrowth;

  /// The [pressGrowth] a native iOS 26 button shows: ~17 pt along its longest
  /// side, measured at 120 fps on a 56 pt circle (1.3×) and a 132 pt pill
  /// (1.13×).
  static const double nativePressGrowth = 17.0;

  /// The factor to multiply the drag offset by to determine the stretch
  /// amount in pixels.
  ///
  /// A value of 0.0 means no stretch, while a value of 1.0 means the stretch
  /// would match the drag offset exactly (which you probably don't want).
  ///
  /// Defaults to 0.5.
  final double stretch;

  /// The resistance factor to apply to the drag offset.
  ///
  /// The higher the resisance, the more sticky the drag will feel.
  /// See [OffsetResistanceExtension.withResistance] for details on how this
  /// works.
  ///
  /// Defaults to 0.01.
  final double resistance;

  /// The hit test behavior for the internal gesture Listener.
  ///
  /// Defaults to [HitTestBehavior.opaque].
  final HitTestBehavior hitTestBehavior;

  /// The child widget to apply the stretch effect to.
  final Widget child;

  /// The axis to constrain the stretch to. If null, stretches in both axes.
  final Axis? axis;

  /// Whether to allow stretch in the positive direction of the axis.
  /// If [axis] is vertical, positive is down. If horizontal, positive is right.
  final bool allowPositive;

  /// Whether to allow stretch in the negative direction of the axis.
  /// If [axis] is vertical, negative is up. If horizontal, negative is left.
  final bool allowNegative;

  /// Per-axis overrides for [allowPositive]. When non-null, overrides
  /// [allowPositive] for that specific axis only.
  final bool? allowPositiveX;

  /// Per-axis overrides for [allowNegative]. When non-null, overrides
  /// [allowNegative] for that specific axis only.
  final bool? allowNegativeX;

  /// Per-axis overrides for [allowPositive]. When non-null, overrides
  /// [allowPositive] for the Y axis only.
  final bool? allowPositiveY;

  /// Per-axis overrides for [allowNegative]. When non-null, overrides
  /// [allowNegative] for the Y axis only.
  final bool? allowNegativeY;

  /// Whether to prevent scaling when interacting with children.
  final bool suppressInteractionOnChildren;

  /// Whether the stretch anchors the widget in place.
  ///
  /// When `true`, the widget's center stays fixed and the shape elongates
  /// toward the drag direction — like pulling taffy with one end pinned.
  /// This matches iOS 26 button behaviour (e.g. phone app X button).
  ///
  /// When `false`, the widget both stretches and translates
  /// toward the finger, matching the original jelly-follow behaviour
  /// used by bottom bars and modals.
  ///
  /// Only affects the unconstrained-axis path (when [axis] is null).
  /// Axis-constrained modes already anchor to the opposite edge.
  ///
  /// Defaults to `true`.
  final bool anchorStretch;

  /// Fine-tuning for the anchor stretch effect.
  ///
  /// Controls intensity, squash, translation damping, and bounciness.
  /// Most developers won't need to change these — the defaults match
  /// iOS 26 button behaviour.
  ///
  /// See [AnchorStretchSettings] for details on each parameter.
  final AnchorStretchSettings anchorStretchSettings;

  @override
  Widget build(BuildContext context) {
    // NOTE: Do NOT add a fast-path that returns `child` directly when
    // `stretch == 0 && interactionScale == 1.0`.  The GlassModalSheet lerps
    // these values through 0 / 1.0 as the sheet expands, so a fast-path
    // causes the widget type at this slot to switch between the bare child
    // widget and `GlassDragBuilder` on the frame where the lerp crosses the
    // threshold.  That type change forces Flutter to deactivate the entire
    // existing element subtree (firing `initState` on all descendants) and
    // mount a fresh one — which is exactly the regression we fixed in
    // lightweight_liquid_glass.dart.  Always returning `GlassDragBuilder`
    // keeps the tree structure stable throughout the animation.

    return GlassDragBuilder(
      behavior: hitTestBehavior,
      suppressInteractionOnChildren: suppressInteractionOnChildren,
      builder: (context, value, child) {
        final pressed = value != null;
        // With pressGrowth the spring drives a 0→1 progress and the render
        // object sizes the scale; otherwise it drives the scale itself.
        final pressTarget = pressGrowth != null
            ? (pressed ? 1.0 : 0.0)
            : (pressed ? interactionScale : 1.0);
        // The native sizing brings the native springs, measured on 56 pt
        // circle and 132 pt pill glass (iOS 26/27): the press reaches its
        // scale in ~150 ms with a small overshoot and settles by ~250 ms; the
        // release is back through rest in ~60–90 ms, dips a few percent of
        // its travel at ~150 ms and is still by ~250 ms on the pill, ~500 ms
        // on the circle — one clean undershoot, no second wobble. A fixed
        // factor keeps the critically damped spring it always had.
        final pressSpring = pressGrowth == null
            ? GlassSpring.smooth(duration: const Duration(milliseconds: 300))
            : pressed
                ? GlassSpring.snappy(
                    duration: const Duration(milliseconds: 250),
                    extraBounce: 0.1,
                  )
                : GlassSpring.bouncy(
                    duration: const Duration(milliseconds: 280),
                    extraBounce: 0.15,
                  );
        return OffsetSpringBuilder(
          value: () {
            if (value == null) return Offset.zero;
            Offset o = value.withResistance(resistance);
            if (axis == Axis.horizontal) {
              o = Offset(o.dx, 0);
            } else if (axis == Axis.vertical) {
              o = Offset(0, o.dy);
            }
            // Apply per-axis overrides, falling back to the shared flags.
            final effectiveAllowPositiveX = allowPositiveX ?? allowPositive;
            final effectiveAllowNegativeX = allowNegativeX ?? allowNegative;
            final effectiveAllowPositiveY = allowPositiveY ?? allowPositive;
            final effectiveAllowNegativeY = allowNegativeY ?? allowNegative;
            o = Offset(
              (!effectiveAllowPositiveX && o.dx > 0)
                  ? 0
                  : (!effectiveAllowNegativeX && o.dx < 0)
                      ? 0
                      : o.dx,
              (!effectiveAllowPositiveY && o.dy > 0)
                  ? 0
                  : (!effectiveAllowNegativeY && o.dy < 0)
                      ? 0
                      : o.dy,
            );
            return o;
          }(),
          spring: value == null
              ? GlassSpring.bouncy(
                  extraBounce: anchorStretchSettings.bounciness,
                )
              : (anchorStretchSettings.bounciness == 0.0
                  ? GlassSpring.smooth(
                      duration: const Duration(milliseconds: 150),
                    )
                  : GlassSpring.interactive(
                      extraBounce: anchorStretchSettings.bounciness - 0.14,
                    )),
          builder: (context, offset, child) => SpringBuilder(
            value: pressTarget,
            spring: pressSpring,
            builder: (context, press, child) {
              final growth = pressGrowth;
              final stretched = RawLiquidStretch(
                stretchPixels: offset * stretch,
                pressGrowthPixels: growth == null ? 0.0 : press * growth,
                axis: axis,
                anchorStretch: anchorStretch,
                anchorStretchIntensity: anchorStretchSettings.intensity,
                anchorSquashFactor: anchorStretchSettings.squashFactor,
                anchorTranslationDamping:
                    anchorStretchSettings.translationDamping,
                child: child,
              );
              // A surface scaling itself keeps its backdrop where it was;
              // declare so, or the release undershoot below 1.0 reads as a
              // sheet push-back and freezes the premium refraction until
              // the scale is back at rest. An ancestor's declaration (a
              // swiped sheet, a materializing shell) is carried through, as
              // the glass below resolves only the nearest scope.
              return LiquidGlassSelfScaleScope(
                selfScaled: LiquidGlassSelfScaleScope.of(context) ||
                    (growth == null
                        ? press < LiquidGlassSelfScaleScope.freezeScaleThreshold
                        : press < 0.0),
                child: growth == null
                    ? Transform.scale(
                        // Avoid exact 1.0 to prevent RenderTransform layer
                        // drops on resting
                        scale: press == 1.0 ? 1.00001 : press,
                        child: stretched,
                      )
                    : stretched,
              );
            },
            child: child,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// {@template raw_liquid_stretch}
/// Use this widget to apply a custom stretch effect in pixels to its child.
///
/// You can control the stretch effect by providing an [Offset] in pixels
/// via the [stretchPixels] property.
///
/// If you simply want to apply a stretch effect based on user drag gestures,
/// consider using [LiquidStretch] instead, which provides built-in drag
/// handling and resistance.
/// {@endtemplate}
class RawLiquidStretch extends SingleChildRenderObjectWidget {
  /// Creates a new [RawLiquidStretch].
  const RawLiquidStretch({
    required this.stretchPixels,
    required super.child,
    this.pressGrowthPixels = 0.0,
    this.axis,
    this.anchorStretch = false,
    this.anchorStretchIntensity = 0.5,
    this.anchorSquashFactor = 0.3,
    this.anchorTranslationDamping = 0.15,
    super.key,
  });

  /// The stretch offset in pixels.
  final Offset stretchPixels;

  /// How many logical pixels the longest side is currently inflated by.
  ///
  /// Applied as a uniform scale about the centre before the stretch.
  final double pressGrowthPixels;

  /// The axis to constrain the stretch to.
  final Axis? axis;

  /// Whether to anchor the stretch at center (no translation).
  final bool anchorStretch;

  /// How much the shape elongates along the drag direction.
  final double anchorStretchIntensity;

  /// How much the perpendicular dimension compresses.
  final double anchorSquashFactor;

  /// How far the center shifts toward the finger (0 = fixed, 1 = follows).
  final double anchorTranslationDamping;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRawLiquidStretch(
      stretchPixels: stretchPixels,
      pressGrowthPixels: pressGrowthPixels,
      axis: axis,
      anchorStretch: anchorStretch,
      anchorStretchIntensity: anchorStretchIntensity,
      anchorSquashFactor: anchorSquashFactor,
      anchorTranslationDamping: anchorTranslationDamping,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRawLiquidStretch renderObject,
  ) {
    renderObject.stretchPixels = stretchPixels;
    renderObject.pressGrowthPixels = pressGrowthPixels;
    renderObject.axis = axis;
    renderObject.anchorStretch = anchorStretch;
    renderObject.anchorStretchIntensity = anchorStretchIntensity;
    renderObject.anchorSquashFactor = anchorSquashFactor;
    renderObject.anchorTranslationDamping = anchorTranslationDamping;
  }
}

class RenderRawLiquidStretch extends RenderProxyBox {
  RenderRawLiquidStretch({
    required Offset stretchPixels,
    double pressGrowthPixels = 0.0,
    Axis? axis,
    bool anchorStretch = false,
    double anchorStretchIntensity = 0.5,
    double anchorSquashFactor = 0.3,
    double anchorTranslationDamping = 0.15,
  })  : _stretchPixels = stretchPixels,
        _pressGrowthPixels = pressGrowthPixels,
        _axis = axis,
        _anchorStretch = anchorStretch,
        _anchorStretchIntensity = anchorStretchIntensity,
        _anchorSquashFactor = anchorSquashFactor,
        _anchorTranslationDamping = anchorTranslationDamping;

  Offset _stretchPixels;
  double _pressGrowthPixels;
  Axis? _axis;
  bool _anchorStretch;
  double _anchorStretchIntensity;
  double _anchorSquashFactor;
  double _anchorTranslationDamping;

  /// The axis to constrain the stretch to.
  Axis? get axis => _axis;
  set axis(Axis? value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsPaint();
  }

  /// Whether to anchor the stretch at center (no translation).
  bool get anchorStretch => _anchorStretch;
  set anchorStretch(bool value) {
    if (_anchorStretch == value) return;
    _anchorStretch = value;
    markNeedsPaint();
  }

  /// How much the shape elongates along the drag direction.
  double get anchorStretchIntensity => _anchorStretchIntensity;
  set anchorStretchIntensity(double value) {
    if (_anchorStretchIntensity == value) return;
    _anchorStretchIntensity = value;
    markNeedsPaint();
  }

  /// How much the perpendicular dimension compresses.
  double get anchorSquashFactor => _anchorSquashFactor;
  set anchorSquashFactor(double value) {
    if (_anchorSquashFactor == value) return;
    _anchorSquashFactor = value;
    markNeedsPaint();
  }

  /// How far the center shifts toward the finger.
  double get anchorTranslationDamping => _anchorTranslationDamping;
  set anchorTranslationDamping(double value) {
    if (_anchorTranslationDamping == value) return;
    _anchorTranslationDamping = value;
    markNeedsPaint();
  }

  /// The stretch offset in pixels.
  Offset get stretchPixels => _stretchPixels;
  set stretchPixels(Offset value) {
    if (_stretchPixels == value) {
      return;
    }
    _stretchPixels = value;
    markNeedsPaint();
  }

  /// How many logical pixels the longest side is currently inflated by.
  double get pressGrowthPixels => _pressGrowthPixels;
  set pressGrowthPixels(double value) {
    if (_pressGrowthPixels == value) return;
    _pressGrowthPixels = value;
    markNeedsPaint();
  }

  /// The uniform press scale, from [pressGrowthPixels] and the longest side.
  double get _pressScale {
    final longest = math.max(size.width, size.height);
    return longest > 0 ? 1.0 + _pressGrowthPixels / longest : 1.0;
  }

  /// Signed smoothstep: maps [-edge..+edge] → [-1..+1] with smooth
  /// cubic easing. Values beyond ±edge clamp to ±1.
  /// Used for pivot interpolation to prevent position jumps.
  static double _signedSmoothStep(double x, double edge) {
    final t = (x / edge).clamp(-1.0, 1.0);
    final a = t.abs();
    final smooth = a * a * (3.0 - 2.0 * a);
    return t >= 0 ? smooth : -smooth;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final transform = _getEffectiveTransform();
    if (transform == null) {
      return super.hitTestChildren(result, position: position);
    }

    return result.addWithPaintTransform(
      transform: transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }

    final transform = _getEffectiveTransform();
    if (transform == null) {
      super.paint(context, offset);
      return;
    }

    // Check if the matrix is singular or produces near-zero scale.
    // A determinant of 0 or NaN signals a degenerate transform; painting
    // through it causes Impeller glyph-bounds crashes on extreme stretch.
    final det = transform.determinant();
    if (det == 0 || !det.isFinite) {
      layer = null;
      return;
    }

    // Guard against extreme squash that produces sub-pixel glyph rects.
    final scale = getScale(stretchPixels: _stretchPixels, size: size);
    if (scale.dx < 0.0001 || scale.dy < 0.0001) {
      layer = null;
      return;
    }

    layer = context.pushTransform(
      needsCompositing,
      offset,
      transform,
      super.paint,
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final effectiveTransform = _getEffectiveTransform();
    if (effectiveTransform != null) {
      transform.multiply(effectiveTransform);
    }
  }

  Matrix4? _getEffectiveTransform() {
    final matrix = Matrix4.identity();

    // Press inflation: a uniform scale about the centre, under the stretch.
    final pressScale = _pressScale;
    if (pressScale != 1.0) {
      matrix
        ..translateByDouble(size.width / 2, size.height / 2, 0.0, 1.0)
        ..scaleByDouble(pressScale, pressScale, 1.0, 1.0)
        ..translateByDouble(-size.width / 2, -size.height / 2, 0.0, 1.0);
    }

    if (_stretchPixels == Offset.zero) {
      // Avoid exact identity to prevent TransformLayer detachment on rest
      // ignore: deprecated_member_use
      return matrix..translateByDouble(0.0001, 0.0, 0.0, 1.0);
    }

    final scale = getScale(
      stretchPixels: _stretchPixels,
      size: size,
    );

    // If axis is constrained, scale from the opposite edge
    if (_axis == Axis.vertical) {
      // Scale from bottom if stretching up, or top if stretching down
      // Actually, for a bottom sheet, we usually want to scale from the bottom
      final pivotY = _stretchPixels.dy <= 0 ? size.height : 0.0;
      matrix
        ..translateByDouble(size.width / 2, pivotY, 0.0, 1.0)
        ..scaleByDouble(scale.dx, scale.dy, 1.0, 1.0)
        ..translateByDouble(-size.width / 2, -pivotY, 0.0, 1.0);
    } else if (_axis == Axis.horizontal) {
      final pivotX = _stretchPixels.dx <= 0 ? size.width : 0.0;
      matrix
        ..translateByDouble(pivotX, size.height / 2, 0.0, 1.0)
        ..scaleByDouble(scale.dx, scale.dy, 1.0, 1.0)
        ..translateByDouble(-pivotX, -size.height / 2, 0.0, 1.0);
    } else {
      if (_anchorStretch) {
        // iOS 26 anchored stretch: the button stays mostly in place but
        // elongates toward the finger from its opposite edge.
        //
        // Algorithm: scale X and Y independently based on their respective
        // drag components, pivoting from the opposite boundary edge.
        // Drag down → only Y stretches from top edge.
        // Drag right → only X stretches from left edge.
        // Drag diagonal → both stretch from the opposite corner.
        final absDx = _stretchPixels.dx.abs();
        final absDy = _stretchPixels.dy.abs();

        if (absDx > 0.001 || absDy > 0.001) {
          // Normalise both axes against the SAME reference dimension
          // (the larger of width/height). This prevents extreme aspect-ratio
          // buttons from producing exaggerated stretch on the short axis.
          //
          // For round buttons (w ≈ h) this is identical to per-axis division.
          // For wide buttons (w >> h) a 20 px vertical drag now produces the
          // same relative value as a 20 px drag on a square button of side
          // max(w, h), preventing the "merge & twitch" reported on full-width
          // buttons between two small buttons.
          final refDim = math.max(size.width, size.height);
          final relativeX = refDim > 0 ? absDx / refDim : 0.0;
          final relativeY = refDim > 0 ? absDy / refDim : 0.0;

          // Aspect-ratio correction: dampen stretch along the already-long
          // axis. A 300×56 wide button has aspectRatio ≈ 5.36, so horizontal
          // stretch is reduced to ~19% while vertical stays at 100%.
          // For square buttons (AR=1), both corrections are 1.0 (no change).
          final aspectRatio = size.width > 0 && size.height > 0
              ? size.width / size.height
              : 1.0;
          final xDamping = aspectRatio > 1.0 ? 1.0 / aspectRatio : 1.0;
          final yDamping = aspectRatio < 1.0 ? aspectRatio : 1.0;

          // Elongate along the drag direction.
          // Cap at 30% to prevent extreme transforms on long drags.
          final stretchX = 1.0 +
              (relativeX * _anchorStretchIntensity * xDamping).clamp(0.0, 0.3);
          final stretchY = 1.0 +
              (relativeY * _anchorStretchIntensity * yDamping).clamp(0.0, 0.3);

          // Perpendicular compression (balloon-squeeze): dragging right
          // elongates X and compresses Y, and vice versa.
          // Cap squash at 15% to avoid extreme narrowing on wide buttons.
          final squashX = 1.0 -
              (relativeY * _anchorSquashFactor * xDamping).clamp(0.0, 0.15);
          final squashY = 1.0 -
              (relativeX * _anchorSquashFactor * yDamping).clamp(0.0, 0.15);

          final scaleX = (stretchX * squashX).clamp(0.01, double.infinity);
          final scaleY = (stretchY * squashY).clamp(0.01, double.infinity);

          // Smooth pivot: instead of snapping between edges (which causes
          // a visible position jump when drag direction reverses near zero),
          // glide the pivot through center using a signed smoothstep.
          //
          // At ±20px the pivot is fully at the target edge. Near zero it
          // passes through center, and the stretch itself is negligible
          // so the pivot position doesn't produce visible artifacts.
          final pivotX = size.width *
              (0.5 - _signedSmoothStep(_stretchPixels.dx, 20.0) * 0.5);
          final pivotY = size.height *
              (0.5 - _signedSmoothStep(_stretchPixels.dy, 20.0) * 0.5);

          matrix
            ..translateByDouble(pivotX, pivotY, 0.0, 1.0)
            ..scaleByDouble(scaleX, scaleY, 1.0, 1.0)
            ..translateByDouble(-pivotX, -pivotY, 0.0, 1.0);

          // Small dampened translation so the button shifts slightly
          // toward the finger — gives bounce-back something to snap.
          // Apply aspect-ratio correction to prevent wide buttons from
          // sliding too far horizontally.
          if (_anchorTranslationDamping > 0) {
            matrix.translateByDouble(
              _stretchPixels.dx * _anchorTranslationDamping * xDamping,
              _stretchPixels.dy * _anchorTranslationDamping * yDamping,
              0.0,
              1.0,
            );
          }
        }
      } else {
        // Original behaviour: scale from center + translate toward the finger.
        matrix
          ..translateByDouble(size.width / 2, size.height / 2, 0.0, 1.0)
          ..scaleByDouble(scale.dx, scale.dy, 1.0, 1.0)
          ..translateByDouble(-size.width / 2, -size.height / 2, 0.0, 1.0)
          ..translateByDouble(_stretchPixels.dx, _stretchPixels.dy, 0.0, 1.0);
      }
    }

    return matrix;
  }

  Offset getScale({
    required Offset stretchPixels,
    required Size size,
  }) {
    if (size.isEmpty) {
      return const Offset(1, 1);
    }

    final stretchX = stretchPixels.dx.abs();
    final stretchY = stretchPixels.dy.abs();

    // Convert pixel stretch to relative stretch based on size
    final relativeStretchX = size.width > 0 ? stretchX / size.width : 0.0;
    final relativeStretchY = size.height > 0 ? stretchY / size.height : 0.0;

    // Use a consistent stretch factor for both dimensions
    const stretchFactor = 1.0;
    const volumeFactor = 0.5;

    final baseScaleX = 1 + relativeStretchX * stretchFactor;
    final baseScaleY = 1 + relativeStretchY * stretchFactor;

    // Calculate magnitude in relative space for volume preservation
    final magnitude = math.sqrt(
      relativeStretchX * relativeStretchX + relativeStretchY * relativeStretchY,
    );
    final targetVolume = 1 + magnitude * volumeFactor;
    final currentVolume = baseScaleX * baseScaleY;
    final volumeCorrection = math.sqrt(targetVolume / currentVolume);

    var finalScaleX = baseScaleX * volumeCorrection;
    var finalScaleY = baseScaleY * volumeCorrection;

    // If axis is constrained, don't affect the other dimension
    if (_axis == Axis.vertical) {
      finalScaleX = 1.0;
    } else if (_axis == Axis.horizontal) {
      finalScaleY = 1.0;
    }

    // Clamp to a safe minimum so the transform never becomes degenerate.
    // Values below 0.01 produce near-singular matrices that cause
    // Impeller glyph-bounds assertions on extreme stretch.
    finalScaleX = finalScaleX.clamp(0.01, double.infinity);
    finalScaleY = finalScaleY.clamp(0.01, double.infinity);

    return Offset(finalScaleX, finalScaleY);
  }
}

/// Provides [withResistance] method to apply drag resistance to an [Offset].
extension OffsetResistanceExtension on Offset {
  /// Returns a new [Offset] with a given [resistance] applied, which will
  /// hold it back the further it deviates from [Offset.zero].
  ///
  /// Applies a non-linear damping effect that reduces the offset's magnitude
  /// while preserving its direction. Higher resistance values create stronger
  /// damping.
  /// Larger offsets are reduced more aggressively than smaller ones,
  /// creating a natural "stretch resistance" effect commonly used in scrolling.
  Offset withResistance(double resistance) {
    if (resistance == 0) return this;

    final magnitude = math.sqrt(dx * dx + dy * dy);
    if (magnitude == 0) return Offset.zero;

    final resistedMagnitude = magnitude / (1 + magnitude * resistance);
    final scale = resistedMagnitude / magnitude;

    return Offset(dx * scale, dy * scale);
  }
}
