import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_glass.dart';
import '../shared/glass_focus_region.dart';

/// A glass-aesthetic numeric stepper matching iOS 26's `UIStepper` control.
///
/// [GlassStepper] is the Flutter equivalent of iOS 26's `UIStepper`. It
/// renders a compact horizontal pill with a decrement (`−`) button on the
/// left, an increment (`+`) button on the right, and a thin vertical divider
/// between them — all wrapped in a liquid glass material.
///
/// ## Behaviour
///
/// - Tapping `−` or `+` calls [onChanged] with the updated value and fires
///   [HapticFeedback.lightImpact].
/// - Holding either button triggers **auto-repeat** after [autoRepeatDelay],
///   firing every [autoRepeatInterval] until released (matching iOS behaviour).
/// - At [min] the `−` button is visually disabled; at [max] the `+` button is
///   disabled (unless [wraps] is true, in which case the value cycles).
/// - Button sides animate to a slightly pressed scale on touch-down.
///
/// ## Value display
///
/// iOS 26's native `UIStepper` does **not** show the value inside the control
/// — the value is always displayed in a separate label by the app. [GlassStepper]
/// follows this convention. To show the value, place a [Text] widget next to it:
///
/// ```dart
/// Row(
///   mainAxisAlignment: MainAxisAlignment.center,
///   children: [
///     Text(
///       '$_quantity',
///       style: TextStyle(fontSize: 22, color: CupertinoColors.white, fontWeight: FontWeight.w600),
///     ),
///     const SizedBox(width: 16),
///     GlassStepper(
///       value: _quantity.toDouble(),
///       min: 1,
///       max: 99,
///       onChanged: (v) => setState(() => _quantity = v.toInt()),
///     ),
///   ],
/// )
/// ```
///
/// ## Properties
///
/// | Property | iOS equivalent | Default |
/// |---|---|---|
/// | [value] | `value` | — |
/// | [min] | `minimumValue` | `0` |
/// | [max] | `maximumValue` | `100` |
/// | [step] | `stepValue` | `1` |
/// | [wraps] | `wraps` | `false` |
/// | [autoRepeat] | `autorepeat` | `true` |
class GlassStepper extends StatefulWidget {
  /// Creates an iOS 26-style glass stepper.
  const GlassStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.wraps = false,
    this.autoRepeat = true,
    this.autoRepeatDelay = const Duration(milliseconds: 500),
    this.autoRepeatInterval = const Duration(milliseconds: 100),
    this.height = 34.0,
    this.width = 94.0,
    this.dividerWidth = 0.5,
    this.settings,
    this.quality,
  });

  // ===========================================================================
  // Value / Range
  // ===========================================================================

  /// The current numeric value.
  final double value;

  /// Called when the value changes via tap or auto-repeat.
  ///
  /// The supplied value is already clamped (or wrapped) within [min]..[max].
  final ValueChanged<double>? onChanged;

  /// The minimum value. Defaults to `0`.
  final double min;

  /// The maximum value. Defaults to `100`.
  final double max;

  /// The amount added/subtracted on each tap. Defaults to `1`.
  final double step;

  /// When `true`, stepping past [max] wraps back to [min] and vice-versa.
  ///
  /// Defaults to `false`.
  final bool wraps;

  // ===========================================================================
  // Auto-repeat (hold behaviour)
  // ===========================================================================

  /// When `true`, holding a button fires repeated events like iOS.
  ///
  /// Defaults to `true`.
  final bool autoRepeat;

  /// How long to wait after the first tap before auto-repeat begins.
  ///
  /// Defaults to 500 ms.
  final Duration autoRepeatDelay;

  /// Interval between auto-repeat firings once they begin.
  ///
  /// Defaults to 100 ms.
  final Duration autoRepeatInterval;

  // ===========================================================================
  // Sizing
  // ===========================================================================

  /// Height of the control. Defaults to 34 logical pixels (matches iOS 26 pt).
  final double height;

  /// Width of the control. Defaults to 94 logical pixels (matches iOS 26 pt).
  final double width;

  /// Thickness of the vertical divider between the two buttons.
  ///
  /// Defaults to 0.5.
  final double dividerWidth;

  // ===========================================================================
  // Glass
  // ===========================================================================

  /// Glass effect settings for the pill background.
  ///
  /// If null, inherits from the nearest [LiquidGlassLayer] or uses defaults.
  final LiquidGlassSettings? settings;

  /// Rendering quality. Defaults to [GlassQuality.standard].
  final GlassQuality? quality;

  @override
  State<GlassStepper> createState() => _GlassStepperState();
}

class _GlassStepperState extends State<GlassStepper> {
  // Press-state scale for each side
  bool _decrementPressed = false;
  bool _incrementPressed = false;

  // Auto-repeat timers
  Timer? _repeatTimer;
  Timer? _delayTimer;

  @override
  void dispose() {
    _cancelRepeat();
    super.dispose();
  }

  // ===========================================================================
  // Value logic
  // ===========================================================================

  bool get _canDecrement => widget.wraps || widget.value > widget.min + 1e-10;

  bool get _canIncrement => widget.wraps || widget.value < widget.max - 1e-10;

  void _decrement() {
    if (!_canDecrement) return;
    HapticFeedback.lightImpact();
    double next = widget.value - widget.step;
    if (widget.wraps && next < widget.min) {
      next = widget.max - ((widget.min - next) % (widget.max - widget.min));
    }
    widget.onChanged?.call(next.clamp(widget.min, widget.max));
  }

  void _increment() {
    if (!_canIncrement) return;
    HapticFeedback.lightImpact();
    double next = widget.value + widget.step;
    if (widget.wraps && next > widget.max) {
      next = widget.min + ((next - widget.max) % (widget.max - widget.min));
    }
    widget.onChanged?.call(next.clamp(widget.min, widget.max));
  }

  // ===========================================================================
  // Auto-repeat
  // ===========================================================================

  void _startRepeat(VoidCallback action) {
    if (!widget.autoRepeat) return;
    _delayTimer = Timer(widget.autoRepeatDelay, () {
      _repeatTimer = Timer.periodic(widget.autoRepeatInterval, (_) => action());
    });
  }

  void _cancelRepeat() {
    _delayTimer?.cancel();
    _repeatTimer?.cancel();
    _delayTimer = null;
    _repeatTimer = null;
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.height / 2);

    // Format current value for VoiceOver — show integer if whole, else decimal.
    final valueStr = widget.value == widget.value.truncateToDouble()
        ? widget.value.toInt().toString()
        : widget.value.toStringAsFixed(1);

    return Semantics(
      // iOS UIStepper VoiceOver: announces value and supports swipe-up/down
      // gestures to increment/decrement, matching native UIAccessibility.
      label: 'Stepper',
      value: valueStr,
      increasedValue: _canIncrement
          ? '${(widget.value + widget.step).clamp(widget.min, widget.max)}'
          : null,
      decreasedValue: _canDecrement
          ? '${(widget.value - widget.step).clamp(widget.min, widget.max)}'
          : null,
      onIncrease: _canIncrement ? _increment : null,
      onDecrease: _canDecrement ? _decrement : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AdaptiveGlass(
          shape: LiquidRoundedRectangle(
            borderRadius: widget.height / 2,
          ),
          settings: widget.settings ?? const LiquidGlassSettings(),
          quality: widget.quality ?? GlassQuality.standard,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Row(
              children: [
                // ── Decrement side ──────────────────────────────────────────────
                Expanded(
                  child: _StepperSide(
                    icon: CupertinoIcons.minus,
                    semanticLabel: 'Decrement',
                    isPressed: _decrementPressed,
                    isEnabled: _canDecrement,
                    // Single-fire keyboard action — no repeat timer.
                    onKeyboardActivate: _canDecrement ? _decrement : null,
                    onTapDown: () {
                      setState(() => _decrementPressed = true);
                      _decrement();
                      _startRepeat(_decrement);
                    },
                    onTapUp: () {
                      setState(() => _decrementPressed = false);
                      _cancelRepeat();
                    },
                    onTapCancel: () {
                      setState(() => _decrementPressed = false);
                      _cancelRepeat();
                    },
                  ),
                ),

                // ── Vertical divider ────────────────────────────────────────────
                SizedBox(
                  width: widget.dividerWidth,
                  height: widget.height,
                  child: ColoredBox(
                    color: GlassTheme.brightnessOf(context) == Brightness.light
                        ? CupertinoColors.black.withValues(alpha: 0.25)
                        : CupertinoColors.white.withValues(alpha: 0.25),
                  ),
                ),

                // ── Increment side ──────────────────────────────────────────────
                Expanded(
                  child: _StepperSide(
                    icon: CupertinoIcons.plus,
                    semanticLabel: 'Increment',
                    isPressed: _incrementPressed,
                    isEnabled: _canIncrement,
                    // Single-fire keyboard action — no repeat timer.
                    onKeyboardActivate: _canIncrement ? _increment : null,
                    onTapDown: () {
                      setState(() => _incrementPressed = true);
                      _increment();
                      _startRepeat(_increment);
                    },
                    onTapUp: () {
                      setState(() => _incrementPressed = false);
                      _cancelRepeat();
                    },
                    onTapCancel: () {
                      setState(() => _incrementPressed = false);
                      _cancelRepeat();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Private: one side (− or +)
// =============================================================================

class _StepperSide extends StatefulWidget {
  const _StepperSide({
    required this.icon,
    required this.semanticLabel,
    required this.isPressed,
    required this.isEnabled,
    required this.onKeyboardActivate,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  final IconData icon;
  final String semanticLabel;
  final bool isPressed;
  final bool isEnabled;

  /// Single-fire callback for keyboard Space/Enter activation.
  /// Intentionally does NOT start the repeat timer — that is a pointer-only
  /// behaviour driven by a sustained press gesture, not a discrete key event.
  final VoidCallback? onKeyboardActivate;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  @override
  State<_StepperSide> createState() => _StepperSideState();
}

class _StepperSideState extends State<_StepperSide> {
  @override
  Widget build(BuildContext context) {
    return GlassFocusRegion(
      enabled: widget.isEnabled,
      isButton: true,
      semanticLabel: widget.semanticLabel,
      // Circular shape matches the half-pill boundary of each stepper side.
      shape: const CircleBorder(),
      // Use the dedicated single-fire callback — NOT onTapDown — so the
      // repeat timer is never started by a keyboard Space/Enter press.
      onKeyboardActivate: widget.onKeyboardActivate,
      semanticOnTap: widget.onKeyboardActivate,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.isEnabled ? (_) => widget.onTapDown() : null,
        onTapUp: (_) => widget.onTapUp(),
        onTapCancel: widget.onTapCancel,
        child: AnimatedScale(
          scale: (widget.isPressed && widget.isEnabled) ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: widget.isEnabled ? 1.0 : 0.3,
              child: Icon(
                widget.icon,
                color: CupertinoTheme.of(context).textTheme.textStyle.color ??
                    CupertinoColors.label,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
