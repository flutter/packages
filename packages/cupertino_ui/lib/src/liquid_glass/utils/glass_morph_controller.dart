import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';

import 'liquid_morph_physics.dart';

export 'liquid_morph_physics.dart' show LiquidMorphState, MorphPhase;

/// Controls the speed profile of a liquid glass morph animation.
///
/// Each case maps to a tuned spring description that preserves the 0.73
/// underdamped ratio — so the rubber-band closing bounce is present at every
/// speed, just scaled proportionally.
enum MorphSpeed {
  /// Slow, deliberate morph. Suitable for tutorials or accessibility contexts.
  slow,

  /// Default iOS 26 speed with native-parity spring response (375 ms profile).
  normal,

  /// Fast, snappy morph. Suitable for power users or high-frequency interactions.
  fast,

  /// Near-instant transition. Use when the user has enabled Reduce Motion, or for testing.
  instant,
}

/// Describes the visual shape style of the liquid glass morph transition.
///
/// Additional styles (e.g. [bloom]) are planned for future releases and will
/// be powered by the same [LiquidMorphPhysics] engine with a different curve
/// profile.
enum MorphStyle {
  /// Classic iOS 26 liquid teardrop — Blob B pulls away from Blob A along a
  /// J-curve trajectory while the SDF metaball shader creates the bridging neck.
  teardrop,

  /// Radial bloom expansion originating from the trigger center outward.
  ///
  /// Intended for long-press / force-touch context menus (future release).
  bloom,
}

/// A Flutter-idiomatic controller for liquid glass morph animations.
///
/// Works like [AnimationController] but encapsulates the iOS 26 spring physics,
/// J-curve interpolation, and [LiquidMorphState] computation behind a clean,
/// semantic API.
///
/// ## Lifecycle
///
/// [GlassMorphController] must be created inside a [State] that mixes in
/// [TickerProviderStateMixin] and disposed in [State.dispose].
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
///   late final GlassMorphController _morph;
///
///   @override
///   void initState() {
///     super.initState();
///     _morph = GlassMorphController(vsync: this);
///     _morph.addListener(_onFrame);
///   }
///
///   @override
///   void dispose() {
///     _morph.dispose();
///     super.dispose();
///   }
///
///   void _open()  => _morph.open();
///   void _close() => _morph.close();
///
///   void _onFrame() {
///     if (!mounted) return;
///     setState(() {});
///   }
/// }
/// ```
///
/// ## Computing render state
///
/// ```dart
/// final state = _morph.computeState(
///   finalDx: finalDx,
///   finalDy: finalDy,
///   horizontalOffset: _horizontalOffset,
///   verticalOffset: _verticalOffset,
/// );
///
/// // Use state.pathT, state.anchorScale, state.blend, etc. in your layout.
/// ```
///
/// ## Customisation
///
/// Use [speed] and [style] for safe, semantic control. Avoid constructing
/// [LiquidMorphPhysics] manually with custom spring constants — the physics
/// parameters are interdependent and incorrect values produce unstable
/// animations.
class GlassMorphController extends ChangeNotifier {
  /// Creates a [GlassMorphController].
  ///
  /// [vsync] must be a valid [TickerProvider], typically obtained from
  /// [TickerProviderStateMixin].
  GlassMorphController({
    required TickerProvider vsync,
    MorphSpeed speed = MorphSpeed.normal,
    this.style = MorphStyle.teardrop,
  })  : _speed = speed,
        _animationController = AnimationController.unbounded(vsync: vsync) {
    _animationController.addListener(_onTick);
    _animationController.addStatusListener(_onStatusChange);
  }

  // ─── Public parameters ────────────────────────────────────────────────────

  /// Speed profile for the morph animation.
  ///
  /// Maps to a tuned spring description that preserves the 0.73 underdamped
  /// ratio. Use [setSpeed] to update this after construction.
  MorphSpeed get speed => _speed;
  MorphSpeed _speed;

  /// Updates the speed profile on a live controller.
  ///
  /// Safe to call at any time, including while an animation is running. The
  /// new spring profile takes effect on the *next* [open] or [close] call —
  /// the current simulation is not interrupted.
  void setSpeed(MorphSpeed speed) {
    _speed = speed;
  }

  /// Visual shape style of the morph transition.
  ///
  /// Currently only [MorphStyle.teardrop] is fully implemented.
  final MorphStyle style;

  // ─── Internal state ───────────────────────────────────────────────────────

  final AnimationController _animationController;
  bool _isClosing = false;
  bool _hasHandedOff = false;

  /// Whether the reduced-motion accessibility flag is currently active.
  ///
  /// When `true`, [_effectiveSpring] returns the [MorphSpeed.instant] spring
  /// regardless of the [speed] parameter, producing a near-instant transition
  /// that respects the platform accessibility setting.
  ///
  /// Set this from `didChangeDependencies()` in your widget using
  /// `MediaQuery.of(context).disableAnimations`.
  bool _disableAnimations = false;

  // ─── Public accessors ─────────────────────────────────────────────────────

  /// The raw, unclamped spring simulation value.
  ///
  /// Mirrors [AnimationController.value]. Can legitimately exceed `[0, 1]`
  /// during underdamped overshoot phases.
  double get value => _animationController.value;

  /// Instantaneous velocity of the spring simulation.
  double get velocity => _animationController.velocity;

  /// Current [AnimationStatus] of the underlying controller.
  AnimationStatus get status => _animationController.status;

  /// The underlying [AnimationController] for callers that need to listen to
  /// [AnimationStatus] changes or drive additional [Animation]s from it.
  AnimationController get animation => _animationController;

  /// Whether the morph overlay should currently be visible.
  ///
  /// `true` from the moment [open] is called until the spring has fully
  /// settled back at `0.0` after [close].
  bool get isShowing =>
      _animationController.value > 0.001 || (_isClosing && !_hasSettled);

  /// Whether the controller is in the closing phase.
  bool get isClosing => _isClosing;

  /// Whether the anchor blob has handed off back to the real trigger.
  ///
  /// Latches `true` on the first zero-crossing during close, remaining `true`
  /// until the next [open] call. Use this to swap the ghost overlay for the
  /// real trigger widget at the exact right moment.
  bool get hasHandedOff => _hasHandedOff;

  // ─── Accessibility ────────────────────────────────────────────────────────

  /// Updates the reduced-motion override.
  ///
  /// Call this from `State.didChangeDependencies()` to automatically respect
  /// the platform accessibility setting:
  ///
  /// ```dart
  /// @override
  /// void didChangeDependencies() {
  ///   super.didChangeDependencies();
  ///   _morph.setDisableAnimations(
  ///     MediaQuery.of(context).disableAnimations,
  ///   );
  /// }
  /// ```
  ///
  /// When [disableAnimations] is `true`, both [open] and [close] use the
  /// [MorphSpeed.instant] spring profile — the overlay appears and disappears
  /// in a single frame with no bouncing. This satisfies iOS and Android
  /// "Reduce Motion" / "Remove Animations" accessibility requirements.
  void setDisableAnimations(bool disableAnimations) {
    if (_disableAnimations == disableAnimations) return;
    _disableAnimations = disableAnimations;
  }

  /// Whether reduced-motion override is currently active.
  bool get disableAnimations => _disableAnimations;

  /// Opens the morph animation from the current position.
  ///
  /// Resets the handoff latch and runs the spring toward `1.0` from rest.
  /// Safe to call while the close animation is still running.
  void open() {
    _isClosing = false;
    _hasHandedOff = false;
    _runSpring(1.0, velocityHint: 0.0);
  }

  /// Closes the morph animation with the iOS 26 rubber-band bounce.
  ///
  /// Injects [LiquidMorphPhysics.closeVelocityHint] to immediately drive the
  /// spring toward zero with momentum, creating the satisfying "snap-back" feel.
  void close() {
    _isClosing = true;
    _runSpring(0.0, velocityHint: LiquidMorphPhysics.closeVelocityHint);
  }

  /// Immediately resets the controller to its resting closed state (value = 0.0,
  /// velocity = 0.0) without running an animation.
  void reset() {
    _animationController.stop();
    _isClosing = false;
    _hasHandedOff = false;
    _animationController.value = 0.0;
    notifyListeners();
  }

  // ─── Physics computation ──────────────────────────────────────────────────

  /// Computes the current [LiquidMorphState] for the given layout geometry.
  ///
  /// Call this once per frame from your [AnimatedBuilder] or [addListener]
  /// callback to get pre-calculated render values.
  ///
  /// - [finalDx] / [finalDy] — target displacement from trigger center to
  ///   menu center, in logical pixels.
  /// - [horizontalOffset] / [verticalOffset] — screen-edge clamping
  ///   corrections from the menu positioning logic.
  /// - [scaleDelta] — geometric scale ratio (see [LiquidMorphPhysics.computeScaleDelta]).
  ///   Values > 1.5 engage adaptive damping. Defaults to `1.0` (unchanged
  ///   baseline behaviour) for backward compatibility.
  /// - [adaptiveDamping] — explicit override; when `null` (default), inferred
  ///   from [scaleDelta].
  /// - [isClosing] — explicit override; when `null` (default), inferred from
  ///   this controller's own [_isClosing] state.
  LiquidMorphState computeState({
    required double finalDx,
    required double finalDy,
    double horizontalOffset = 0.0,
    double verticalOffset = 0.0,
    double scaleDelta = 1.0,
    bool? adaptiveDamping,
    bool? isClosing,
  }) {
    return LiquidMorphPhysics.compute(
      rawValue: _animationController.value,
      finalDx: finalDx,
      finalDy: finalDy,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
      scaleDelta: scaleDelta,
      adaptiveDamping: adaptiveDamping,
      isClosing: isClosing ?? _isClosing,
    );
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  bool get _hasSettled =>
      _animationController.value <= 0.001 &&
      _animationController.velocity.abs() < 0.5;

  /// Returns the spring description for the current [speed].
  ///
  /// All springs share the 0.73 underdamped ratio
  /// (ζ = damping / (2 × √(stiffness × mass))).
  SpringDescription get _effectiveSpring {
    // Reduced-motion override: always use the instant (stiffest) spring so the
    // animation completes in a single frame — no bounce, no teardrop neck.
    if (_disableAnimations) {
      return const SpringDescription(
          mass: 1.0, stiffness: 500.0, damping: 32.4);
    }
    switch (_speed) {
      case MorphSpeed.slow:
        // ω₀ ≈ 7.7 rad/s open, ω₀ ≈ 10.0 rad/s close
        return _isClosing
            ? const SpringDescription(
                mass: 1.0, stiffness: 100.0, damping: 14.6)
            : const SpringDescription(
                mass: 1.0, stiffness: 60.0, damping: 11.3);
      case MorphSpeed.normal:
        // iOS 26 native asymmetric springs:
        // Open: ω₀ ≈ 11.0 rad/s, ζ ≈ 0.73 — buoyant, lush fluid expansion (~350 ms)
        // Close: ω₀ ≈ 14.1 rad/s, ζ ≈ 0.74 — snappy, crisp magnetic retraction (~240 ms)
        return _isClosing
            ? LiquidMorphPhysics.closeSpring
            : LiquidMorphPhysics.openSpring;
      case MorphSpeed.fast:
        // ω₀ ≈ 14.1 rad/s open, ω₀ ≈ 17.3 rad/s close
        return _isClosing
            ? const SpringDescription(
                mass: 1.0, stiffness: 300.0, damping: 25.1)
            : const SpringDescription(
                mass: 1.0, stiffness: 200.0, damping: 20.5);
      case MorphSpeed.instant:
        // ω₀ ≈ 22 rad/s, ζ ≈ 0.73 — very stiff, near-instant
        return const SpringDescription(
            mass: 1.0, stiffness: 500.0, damping: 32.4);
    }
  }

  void _runSpring(double target, {required double velocityHint}) {
    final sim = SpringSimulation(
      _effectiveSpring,
      _animationController.value,
      target,
      velocityHint,
    );
    _animationController.animateWith(sim);
  }

  void _onTick() {
    // Handoff latch: fires exactly once when the spring first crosses zero
    // during a close animation. The latch prevents it from re-triggering if
    // the underdamped spring bounces back above zero briefly.
    if (_isClosing && _animationController.value <= 0.0 && !_hasHandedOff) {
      _hasHandedOff = true;
    }
    notifyListeners();
  }

  void _onStatusChange(AnimationStatus status) {
    notifyListeners();
  }
}
