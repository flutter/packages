// ignore_for_file: comment_references

import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Semantic phase of the liquid glass morph lifecycle.
///
/// Consuming widgets can use this to react to *where* in the animation
/// lifecycle the morph currently is — without re-deriving it from raw
/// animation values.
///
/// State machine (open direction):
/// ```
/// idle → detaching → travelling → arriving → settled
/// ```
/// State machine (close direction, spring bounces back):
/// ```
/// settled → arriving → travelling → detaching → [bounce] → idle
/// ```
enum MorphPhase {
  /// The morph has not started or has fully settled at its origin.
  idle,

  /// The anchor blob is shrinking and Blob B is just beginning to pull away.
  /// In practice this covers animation values `0.0 – 0.4`.
  detaching,

  /// Blob B is in mid-travel — the teardrop neck is at maximum stretch.
  /// Animation values `0.4 – 0.8`.
  travelling,

  /// Blob B is approaching its destination and the neck is retracting.
  /// Animation values [0.8 – 1.0).
  arriving,

  /// Blob B has fully settled at its target position.
  /// Animation value ≥ 1.0.
  settled,
}

/// The fully computed render state for one frame of a liquid morph animation.
///
/// All values are pre-calculated and ready to be applied directly to widget
/// geometry. Consumers must not re-derive values from the raw animation value.
class LiquidMorphState {
  /// Creates a new [LiquidMorphState].
  const LiquidMorphState({
    required this.pathT,
    required this.sizeT,
    required this.currentDx,
    required this.currentDy,
    required this.pushDx,
    required this.pushDy,
    required this.anchorScale,
    required this.blend,
    required this.containerScale,
    required this.phase,
  });

  /// Position interpolation value — drives the J-curve overshoot.
  ///
  /// Computed by [_BackOutCurve]. Can legitimately exceed `[0, 1]` during the
  /// close undershoot phase. Use this to position Blob B.
  final double pathT;

  /// Size interpolation value — drives the teardrop size expansion.
  ///
  /// Computed by [Curves.linearToEaseOut] (small-scale morphs) or a
  /// smootherstep sigmoid (large-scale morphs, `scaleDelta > 3.0`). Stays
  /// within `[0, 1]` during normal operation (any close undershoot is added
  /// additively).
  final double sizeT;

  /// Absolute horizontal displacement of the menu body (Blob B) from the
  /// trigger center, in logical pixels.
  final double currentDx;

  /// Absolute vertical displacement of the menu body (Blob B) from the
  /// trigger center, in logical pixels.
  final double currentDy;

  /// Horizontal displacement applied to the anchor blob (Blob A) during the
  /// underdamped closing bounce. Zero during the opening animation.
  final double pushDx;

  /// Vertical displacement applied to the anchor blob (Blob A) during the
  /// underdamped closing bounce. Zero during the opening animation.
  final double pushDy;

  /// Scale factor for the anchor (ghost trigger) blob in `[0.0 – 1.0]`.
  ///
  /// Shrinks to `0.0` over the first 40 % of the opening animation so the
  /// liquid bridge detaches cleanly. Grows back during closing so the real
  /// trigger button is ready to "catch" the returning menu.
  final double anchorScale;

  /// Metaball merge intensity in SDF blur units, clamped to `[0.0 – 28.0]`.
  ///
  /// Derived from the separation between [pathT] and [sizeT]: zero when the
  /// blobs perfectly overlap (no swell needed), and maximum when the teardrop
  /// bridge is at peak stretch. Attenuated proportionally for large-scale
  /// morphs to prevent excessive SDF merging.
  final double blend;

  /// Scale pulse applied to the menu container (Blob B) during the spring
  /// overshoot phases.
  ///
  /// - `1.0` during normal travel.
  /// - Slightly above `1.0` on open overshoot (negligible — overdamped).
  /// - Drops below `1.0` on close undershoot to produce the visible squeeze.
  final double containerScale;

  /// Semantic lifecycle phase of the morph for this frame.
  final MorphPhase phase;
}

/// Pure, stateless math engine for liquid glass morphing animations.
///
/// This class implements the J-curve back-out position curve and
/// [Curves.linearToEaseOut] / smootherstep size curve that together create the
/// iOS 26 liquid teardrop morphing effect.
///
/// It is **intentionally stateless** — feed it the raw animation value plus
/// the source/destination geometry and it returns a fully computed
/// [LiquidMorphState] for that frame. No `BuildContext`, no `State`, no
/// `ChangeNotifier` dependencies.
///
/// ## Design
///
/// Two conceptual blobs drive the morph:
///
/// - **Blob A** (anchor / ghost trigger) stays at the trigger position and
///   shrinks away over the first 40 % of the animation to cleanly break the
///   liquid bridge.
/// - **Blob B** (menu body) travels from the trigger center to the menu
///   center along a J-curve overshoot trajectory, expanding from trigger size
///   to menu size.
///
/// The metaball SDF shader automatically creates the teardrop neck between the
/// two blobs — there is no explicit neck geometry.
///
/// ## Auto-Scaling
///
/// When [compute] receives a `scaleDelta` greater than `1.5`, the engine
/// engages **adaptive mode**:
///
/// - The J-curve back-out amplitude is reduced inversely with vertical travel
///   so the physical overshoot stays within ~10–14 px regardless of the
///   destination size. This eliminates the 35–40 px "plunge" seen when a
///   large menu or full-sheet morph uses the small-menu constant.
/// - The size curve switches from [Curves.linearToEaseOut] to a smootherstep
///   sigmoid (for `scaleDelta > 3.0`) that keeps the droplet compact through
///   the detach/travel phases and blossoms rapidly only as it lands.
/// - Blend attenuation prevents excessive SDF merging at extreme scale ratios.
/// - Push momentum is bounded to a physical maximum so the trigger bounces
///   with native-grade subtlety rather than a jarring multi-pixel jolt.
///
/// ## Usage
///
/// ```dart
/// // Typically called from an AnimatedBuilder or addListener callback.
/// final state = LiquidMorphPhysics.compute(
///   rawValue: controller.value,
///   finalDx: finalDx,
///   finalDy: finalDy,
///   horizontalOffset: _horizontalOffset,
///   verticalOffset: _verticalOffset,
/// );
///
/// // Apply to the UI:
/// Positioned(
///   left: triggerX + state.pushDx,
///   top:  triggerY + state.pushDy,
///   child: Transform.scale(scale: state.anchorScale, child: blobA),
/// )
/// ```
class LiquidMorphPhysics {
  // Pure utility class — no instances.
  const LiquidMorphPhysics._();

  // ─── iOS 26 Spring Constants ───────────────────────────────────────────────
  //
  // Both open and close use the same underdamped spring profile:
  //   mass: 1.0, stiffness: 120.0, damping: 16.0
  //   ω₀ = √(120/1) ≈ 11 rad/s,  ζ = 16/(2×11) ≈ 0.73 — slightly underdamped.
  //
  // The underdamping is intentional: it lets the spring overshoot past 0.0 on
  // close, which drives the physical "bump" on the trigger icon. The J-curve
  // position curve and the [closeVelocityHint] amplify this into the satisfying
  // iOS-native rubber-band momentum feel.

  /// Spring profile for the iOS 26 liquid morph **opening** animation.
  static const SpringDescription openSpring = SpringDescription(
    mass: 1.0,
    stiffness: 120.0,
    damping: 16.0,
  );

  /// Spring profile for the iOS 26 liquid morph **closing** animation.
  ///
  /// Tuned for Apple iOS 26 "snappy" exit physics: higher natural frequency
  /// (stiffness: 200.0, damping: 21.0, ω₀ ≈ 14.1 rad/s) for a fast, responsive
  /// dismissal (~240 ms) while preserving the signature 0.74 underdamped ratio
  /// for the rubber-band catch on the trigger button.
  static const SpringDescription closeSpring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 21.0,
  );

  /// Initial velocity hint injected when the close animation starts.
  ///
  /// A negative value immediately drives the spring toward zero with
  /// momentum, creating a snappy initial pull and maximising the visible
  /// rubber-band bounce amplitude.
  static const double closeVelocityHint = -3.2;

  // ─── Tuning constants (intentionally not public) ───────────────────────────
  //
  // These constants are calibrated for iOS 26 native parity. Exposing them
  // as public parameters would allow developers to produce physically broken
  // animations. Use [GlassMorphController.speed] for safe speed control.

  /// Amplitude of the J-curve back-out overshoot for position interpolation.
  ///
  /// Applies only for small-scale morphs (scaleDelta ≤ 1.5). Large-scale
  /// morphs compute an adaptive amplitude via [computeAdaptiveBackOutAmplitude]
  /// to keep the physical overshoot within a tight iOS-native envelope.
  static const double _backOutAmplitude = 2.5;

  /// The minimum adaptive back-out amplitude.
  ///
  /// Prevents the overshoot from flattening entirely on very large travel
  /// distances — the teardrop neck still needs a visible pull to read as liquid.
  static const double _minBackOutAmplitude = 0.7;

  /// Vertical travel threshold below which full [_backOutAmplitude] applies.
  ///
  /// Morphs with `|finalDy| <= 100 px` are considered small controls (chips,
  /// buttons, short menus) and receive the unattenuated 2.5 amplitude.
  static const double _adaptiveThresholdDy = 100.0;

  /// Fraction of the animation over which the anchor blob shrinks to zero.
  static const double _anchorEaseDuration = 0.4;

  /// Multiplier from path/size separation to SDF blur units.
  static const double _blendMultiplier = 150.0;

  /// Maximum SDF blend value to prevent excessive merging on small movements.
  static const double _maxBlend = 28.0;

  /// Closing-animation threshold below which the proximity blend re-merge ramp begins.
  ///
  /// When [compute] is called with [isClosing] = `true` and [clampedValue] falls
  /// below this threshold, the SDF blend grows from `0.0` up to [_maxBlend],
  /// simulating the returning droplet re-fusing with the trigger blob — the
  /// iOS 26 metaball absorption effect.
  ///
  /// A wider threshold (0.6) gives the bridge ~150 ms of visibility at the
  /// normal close-spring speed, which is enough to read as a liquid neck
  /// rather than a sub-perceptual flash.
  static const double _closeProximityThreshold = 0.6;

  /// Maximum travel distance (logical pixels) for the full close push.
  ///
  /// When the trigger-to-destination distance exceeds this, the push momentum
  /// applied to Blob A is scaled down proportionally so the trigger's bounce
  /// remains a subtle iOS-native nudge rather than a jarring multi-pixel jolt.
  static const double _maxPushTravelPx = 80.0;

  // ─── Public helpers ────────────────────────────────────────────────────────

  /// Computes the geometric scale ratio from [sourceSize] to [targetSize].
  ///
  /// Uses the square root of the area ratio, which treats width and height
  /// symmetrically:
  ///
  /// ```
  /// Δ_scale = √(targetArea / sourceArea)
  /// ```
  ///
  /// Returns `1.0` when [sourceSize] is zero-area (zero-sized triggers).
  static double computeScaleDelta({
    required Size sourceSize,
    required Size targetSize,
  }) {
    final sourceArea = sourceSize.width * sourceSize.height;
    final targetArea = targetSize.width * targetSize.height;
    if (sourceArea <= 0.0) return 1.0;
    return math.sqrt(targetArea / sourceArea);
  }

  /// Computes the adaptive J-curve back-out amplitude for a given vertical
  /// travel distance.
  ///
  /// For `|finalDy| <= 100 px` (small controls), returns [baseAmplitude] (2.5)
  /// unchanged. For larger travel distances the amplitude is reduced inversely
  /// so the peak physical overshoot stays within ~10–14 px instead of
  /// plunging 35–40 px.
  ///
  /// The result is never lower than [_minBackOutAmplitude] (0.7), preserving
  /// enough J-curve for a visible teardrop neck.
  static double computeAdaptiveBackOutAmplitude({
    required double finalDy,
    double baseAmplitude = _backOutAmplitude,
  }) {
    final absDy = finalDy.abs();
    if (absDy <= _adaptiveThresholdDy) return baseAmplitude;
    return (baseAmplitude * _adaptiveThresholdDy / absDy)
        .clamp(_minBackOutAmplitude, baseAmplitude);
  }

  /// Computes the SDF blend attenuation factor for a given scale ratio.
  ///
  /// Returns `1.0` (full blend) when [scaleDelta] <= 3.0 — small menus and
  /// controls where the teardrop neck should be fully visible. For larger
  /// ratios, the blend is attenuated inversely to prevent excessive SDF
  /// merging that would fill the whole viewport.
  ///
  /// Clamped to a floor of `0.2` so the teardrop bridge never fully
  /// disappears.
  static double computeBlendAttenuation(double scaleDelta) {
    if (scaleDelta <= 3.0) return 1.0;
    return (3.0 / scaleDelta).clamp(0.2, 1.0);
  }

  // ─── Core computation ──────────────────────────────────────────────────────

  /// Computes the full [LiquidMorphState] for a single animation frame.
  ///
  /// ### Parameters
  ///
  /// - [rawValue] — the raw, unclamped value from `AnimationController.unbounded`.
  ///   Legitimately exceeds `[0, 1]` during spring overshoot phases.
  /// - [finalDx] — target horizontal displacement from the trigger center to
  ///   the menu center, in logical pixels.
  /// - [finalDy] — target vertical displacement from the trigger center to
  ///   the menu center, in logical pixels.
  /// - [horizontalOffset] — screen-edge clamping correction for horizontal
  ///   overflow, accumulated by the menu positioning logic.
  /// - [verticalOffset] — screen-edge clamping correction for vertical overflow.
  /// - [scaleDelta] — geometric scale ratio of the morph (target area / source
  ///   area, square-rooted). Use [computeScaleDelta] to derive this from sizes.
  ///   Values > 1.5 engage adaptive damping. Defaults to `1.0` for backward
  ///   compatibility — all existing callers without geometry information are
  ///   unaffected.
  /// - [adaptiveDamping] — explicit opt-in/opt-out override for adaptive mode.
  ///   When `null` (default), adaptive mode is inferred from [scaleDelta].
  /// - [isClosing] — whether the morph animation is closing back to origin.
  ///   Defaults to `false`. When `true`, avoids reverse-direction J-curve launch.
  static LiquidMorphState compute({
    required double rawValue,
    required double finalDx,
    required double finalDy,
    double horizontalOffset = 0.0,
    double verticalOffset = 0.0,
    double scaleDelta = 1.0,
    bool? adaptiveDamping,
    bool isClosing = false,
  }) {
    final clampedValue = rawValue.clamp(0.0, 1.0);

    // Inject the close undershoot so Blob B bounces past the anchor on close.
    // The open-side overshoot (rawValue > 1) is intentionally excluded because
    // it causes an unwanted size wobble during the initial expansion.
    final closeUndershoot = rawValue < 0.0 ? rawValue : 0.0;

    // ── Adaptive mode detection ───────────────────────────────────────────────
    // Engages when explicitly requested or when the scale ratio indicates a
    // large-scale morph (button → sheet, button → tall menu).
    final bool adaptive = adaptiveDamping ?? (scaleDelta > 1.5);

    // ── Effective J-curve amplitude ───────────────────────────────────────────
    // Small morphs (adaptive = false): full 2.5 amplitude for maximum teardrop.
    // Large morphs (adaptive = true): damped inversely with vertical travel so
    // physical overshoot stays within ~10–14 px.
    final double amplitude = adaptive
        ? computeAdaptiveBackOutAmplitude(finalDy: finalDy)
        : _backOutAmplitude;

    // ── J-Curve Position ──────────────────────────────────────────────────────
    // On open: The back-out curve overshoots past 1.0 before settling at 1.0,
    // creating the "string pull" teardrop neck at maximum separation.
    // On close: The surface returns home toward 0.0 following the spring's
    // natural deceleration profile without any reverse-direction launch, plus
    // the closing undershoot bounce past 0.0.
    final double pathT;
    if (isClosing) {
      pathT = clampedValue + closeUndershoot;
    } else {
      pathT =
          _BackOutCurve(amplitude).transform(clampedValue) + closeUndershoot;
    }

    // ── Size ─────────────────────────────────────────────────────────────────
    // On close: smoothly tracks the spring contraction.
    // On open:
    //   Small morphs: linearToEaseOut — starts fast, decelerates to the target.
    //   Large morphs (scaleDelta > 3): smootherstep — keeps early peel controlled
    //     through detach/travel, then blossoms into destination bounds.
    final double rawSizeT;
    if (isClosing) {
      // Ease-in contraction: the droplet contracts rapidly early in the return flight,
      // forming a compact liquid bead rather than shrinking linearly with position.
      rawSizeT = math.pow(clampedValue, 1.4).toDouble();
    } else if (adaptive && scaleDelta > 3.0) {
      rawSizeT = _smootherStep(clampedValue);
    } else {
      rawSizeT = Curves.linearToEaseOut.transform(clampedValue);
    }
    final sizeT = rawSizeT + closeUndershoot;

    // ── Closing Momentum Push (Blob A displacement) ───────────────────────────
    // When the spring overshoots past 0 (rawValue < 0), Blob A is displaced
    // proportionally to mirror the closing momentum.
    //
    // For large-scale morphs the raw displacement would be proportional to the
    // huge travel distance, producing a jarring multi-pixel jolt on the trigger.
    // The pushFactor caps the effective travel to [_maxPushTravelPx] so the
    // bounce remains a subtle iOS-native nudge.
    final double pushFactor;
    if (adaptive) {
      final travelDx = (finalDx + horizontalOffset).abs();
      final travelDy = (finalDy + verticalOffset).abs();
      final travelMag = math.sqrt(travelDx * travelDx + travelDy * travelDy);
      pushFactor = travelMag > 0.0
          ? (_maxPushTravelPx / travelMag).clamp(0.0, 1.0)
          : 1.0;
    } else {
      pushFactor = 1.0;
    }
    final pushDx = rawValue < 0.0
        ? (finalDx + horizontalOffset) * rawValue * pushFactor
        : 0.0;
    final pushDy = rawValue < 0.0
        ? (finalDy + verticalOffset) * rawValue * pushFactor
        : 0.0;

    // ── Blob B Displacement ───────────────────────────────────────────────────
    final currentDx = finalDx * pathT;
    final currentDy = finalDy * pathT;

    // ── Anchor Scale ─────────────────────────────────────────────────────────
    // On open: Shrinks the ghost trigger (Blob A) to 0 over the first 40% of
    // the animation so the droplet cleanly detaches.
    // On close: Blob A forms early (0.85 -> 0.45) so the trigger shape is fully
    // present and receptive at the destination, allowing the incoming droplet
    // to form an authentic SDF metaball bridge as it approaches.
    final double anchorScale;
    if (isClosing) {
      anchorScale = (1.0 - (clampedValue - 0.45) / 0.40).clamp(0.0, 1.0);
    } else {
      anchorScale =
          (1.0 - (clampedValue / _anchorEaseDuration)).clamp(0.0, 1.0);
    }

    // ── Metaball Blend ────────────────────────────────────────────────────────
    final blendAttenuation = computeBlendAttenuation(scaleDelta);
    final double blend;
    if (isClosing) {
      // Proximity re-merge: as the droplet re-enters the trigger's proximity
      // zone (clampedValue < _closeProximityThreshold), ramp the SDF bridge up
      // from 0 → _maxBlend using an easeOut curve.
      //
      // easeOut (fast-at-start) is intentional: the bridge snaps onto screen
      // early as Blob A grows back, holds near peak for most of the window,
      // then the droplet simply "lands" into the trigger shape.  This matches
      // the native iOS surface-tension spike that fires as the two shapes first
      // touch, not as they fully absorb.
      //
      // Using easeIn (slow-at-start) caused the bridge to be a sub-perceptual
      // flash that maxed out only in the last few frames before handoff.
      //
      // NOTE: this value is non-zero only when a LiquidGlassBlendGroup is
      // present (GlassQuality.premium + Impeller).  On standard / minimal
      // quality the blend field is computed but the SDF layer never reads it.
      final proximityT =
          (1.0 - clampedValue / _closeProximityThreshold).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(proximityT);
      blend = (eased * _maxBlend * blendAttenuation).clamp(0.0, _maxBlend);
    } else {
      // Open: separation between pathT (position) and sizeT (size) represents
      // how far Blob B has pulled away from its anchor.  Blend naturally scales
      // with this, attenuated for large-scale morphs.
      final separation = (pathT - sizeT).abs();
      blend = (separation * _blendMultiplier * blendAttenuation)
          .clamp(0.0, _maxBlend);
    }

    // ── Container Scale Pulse ─────────────────────────────────────────────────
    // Subtle squeeze/swell during spring overshoot phases.
    final containerScale = rawValue > 1.0
        ? 1.0 + (rawValue - 1.0) * 0.10 // open overshoot (negligible)
        : rawValue < 0.0
            ? 1.0 + rawValue * 0.55 // close undershoot → visible squeeze
            : 1.0;

    // ── Phase ─────────────────────────────────────────────────────────────────
    final phase = _derivePhase(rawValue, clampedValue);

    return LiquidMorphState(
      pathT: pathT,
      sizeT: sizeT,
      currentDx: currentDx,
      currentDy: currentDy,
      pushDx: pushDx,
      pushDy: pushDy,
      anchorScale: anchorScale,
      blend: blend,
      containerScale: containerScale,
      phase: phase,
    );
  }

  static MorphPhase _derivePhase(double rawValue, double clampedValue) {
    if (rawValue < 0.0) return MorphPhase.detaching; // close bounce
    if (clampedValue < 0.001) return MorphPhase.idle;
    if (clampedValue < 0.4) return MorphPhase.detaching;
    if (clampedValue < 0.8) return MorphPhase.travelling;
    if (clampedValue < 0.999) return MorphPhase.arriving;
    return MorphPhase.settled;
  }

  /// Smootherstep sigmoid: `t^3 * (10 − 15t + 6t^2)`.
  ///
  /// Zero first and second derivatives at t = 0 and t = 1, so the size
  /// curve starts and ends with zero velocity AND zero acceleration. This
  /// keeps the droplet compact through the detach/travel phases (slow
  /// start) and gives it a fast, smooth blossom into the destination.
  static double _smootherStep(double t) {
    final tc = t.clamp(0.0, 1.0);
    return tc * tc * tc * (tc * (tc * 6.0 - 15.0) + 10.0);
  }
}

/// Back-out easing curve for the J-curve position overshoot.
///
/// Creates a pronounced overshoot past `1.0` before snapping back to `1.0`,
/// which manifests as the teardrop "string pull" effect during the liquid morph.
///
/// - [amplitude] controls how far past `1.0` the curve overshoots.
///   The default value of `2.5` is calibrated for iOS 26 native parity.
///   Adaptive morphs pass a smaller value derived by
///   [LiquidMorphPhysics.computeAdaptiveBackOutAmplitude].
class _BackOutCurve extends Curve {
  const _BackOutCurve(this.amplitude);
  final double amplitude;

  @override
  double transformInternal(double t) {
    return (t -= 1.0) * t * ((amplitude + 1.0) * t + amplitude) + 1.0;
  }
}
