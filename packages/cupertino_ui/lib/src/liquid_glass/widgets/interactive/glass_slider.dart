import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../constants/glass_defaults.dart';
import '../../src/types/glass_interaction_behavior.dart';
import '../../types/glass_quality.dart';
import '../../utils/draggable_indicator_physics.dart';
import '../../utils/glass_spring.dart';
import '../shared/glass_effect.dart';
import '../shared/glass_focus_region.dart';
import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_helpers.dart';

/// A glass morphism slider following Apple's iOS 26 design patterns.
///
/// [GlassSlider] provides a sophisticated slider with glass track, draggable
/// thumb with jelly physics, and smooth animations. It matches iOS's UISlider
/// appearance and behavior with glass morphism effects.
///
/// ## Key Features
///
/// - **Glass Track**: Background track with glass effect
/// - **Active Track**: Colored portion showing current value
/// - **Jelly Thumb**: Draggable thumb with organic squash/stretch physics
/// - **Haptic Feedback**: Subtle feedback when reaching discrete values
/// - **Continuous or Discrete**: Support for continuous values or divisions
/// - **Customizable**: Full control over colors, sizes, and shapes
///
/// ## Usage
///
/// ### Basic Usage (Continuous)
/// ```dart
/// double volume = 0.5;
///
/// GlassSlider(
///   value: volume,
///   onChanged: (value) {
///     setState(() => volume = value);
///   },
/// )
/// ```
///
/// ### Discrete Values
/// ```dart
/// double brightness = 3.0;
///
/// GlassSlider(
///   value: brightness,
///   min: 0.0,
///   max: 5.0,
///   divisions: 5,
///   onChanged: (value) {
///     setState(() => brightness = value);
///   },
/// )
/// ```
///
/// ### Within LiquidGlassLayer (Grouped Mode)
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 3,
///     refractiveIndex: 1.59,
///   ),
///   child: Column(
///     children: [
///       GlassSlider(
///         value: volume,
///         onChanged: (value) => setVolume(value),
///         label: 'Volume',
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Standalone Mode
/// ```dart
/// GlassSlider(
///   value: brightness,
///   onChanged: (value) => setBrightness(value),
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 3,
///   ),
/// )
/// ```
///
/// ### Custom Styling
/// ```dart
/// GlassSlider(
///   value: temperature,
///   min: 0,
///   max: 100,
///   onChanged: (value) => setTemperature(value),
///   activeColor: Colors.red,
///   thumbColor: Colors.red,
///   trackHeight: 6,
///   thumbRadius: 16,
/// )
/// ```
class GlassSlider extends StatefulWidget {
  /// Creates a glass slider.
  const GlassSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor = CupertinoColors.white,
    this.thumbShadow,
    this.trackHeight = 4.0,
    this.thumbRadius = 15.0,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    // ── iOS 26 interaction ──────────────────────────────────────────────────────
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.glowColor,
    this.glowRadius = 1.5,
    this.focusNode,
    this.autofocus = false,
  });

  // ===========================================================================
  // Slider Properties
  // ===========================================================================

  /// The current value of the slider.
  ///
  /// Must be between [min] and [max].
  final double value;

  /// Called when the user is selecting a new value.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts dragging the slider.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user finishes dragging the slider.
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value of the slider.
  ///
  /// Defaults to 0.0.
  final double min;

  /// The maximum value of the slider.
  ///
  /// Defaults to 1.0.
  final double max;

  /// The number of discrete divisions.
  ///
  /// If null, the slider is continuous. If provided, the slider will snap
  /// to discrete values.
  final int? divisions;

  /// Optional label shown above the thumb.
  final String? label;

  // ===========================================================================
  // Style Properties
  // ===========================================================================

  /// Color of the active track (left of thumb).
  ///
  /// If null, defaults to white with 80% opacity.
  final Color? activeColor;

  /// Color of the inactive track (right of thumb).
  ///
  /// If null, defaults to white with 20% opacity.
  final Color? inactiveColor;

  /// Color of the thumb.
  ///
  /// Defaults to white.
  final Color thumbColor;

  /// Shadows cast by the resting thumb, painted outside the glass clip.
  ///
  /// When null, uses a soft black shadow at 15% opacity with an 8 logical-pixel
  /// blur and a 2 logical-pixel downward offset. An empty list disables it.
  /// Each shadow's color alpha is multiplied by the interaction/material fade;
  /// its blur, spread and offset remain unchanged while pressing and releasing.
  /// This controls the thumb only, independently of glass surface elevation.
  ///
  /// To restore the stronger default used before this option was introduced:
  /// ```dart
  /// thumbShadow: const [
  ///   BoxShadow(
  ///     color: Color.from(alpha: 0.25, red: 0, green: 0, blue: 0),
  ///     blurRadius: 8,
  ///     offset: Offset(0, 2),
  ///   ),
  /// ],
  /// ```
  final List<BoxShadow>? thumbShadow;

  /// Height of the track.
  ///
  /// Defaults to 4.0.
  final double trackHeight;

  /// Radius of the thumb.
  ///
  /// Defaults to 14.0 (iOS standard).
  final double thumbRadius;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Glass effect settings (only used when [useOwnLayer] is true).
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass.
  ///
  /// Defaults to false (grouped mode).
  final bool useOwnLayer;

  /// Rendering quality for the glass effect.
  ///
  /// Defaults to [GlassQuality.standard], which uses the lightweight fragment
  /// shader. This works reliably in all contexts, including scrollable lists.
  ///
  /// Use [GlassQuality.premium] for full-pipeline shader with texture capture
  /// and chromatic aberration (Impeller only) in static layouts.
  /// Defaults to [GlassQuality.standard].
  final GlassQuality? quality;

  // ── iOS 26 interaction ────────────────────────────────────────────────────

  /// Controls which iOS 26 interaction effects are active on the thumb.
  ///
  /// | Value | Glow on drag |
  /// |---|---|
  /// | `none` | ✗ |
  /// | `glowOnly` | ✓ |
  /// | `scaleOnly` | ✗ |
  /// | `full` *(default)* | ✓ |
  ///
  /// Set to [GlassInteractionBehavior.none] to suppress the drag glow entirely.
  final GlassInteractionBehavior interactionBehavior;

  /// Colour of the drag glow on the thumb.
  ///
  /// Only active when [interactionBehavior] includes glow. Defaults to a
  /// soft white (~12% opacity) — same as [GlassTextField].
  final Color? glowColor;

  /// Spread radius of the drag glow relative to the thumb’s shorter dimension.
  ///
  /// Defaults to `1.5` (150% of thumb height), matching [GlassTextField].
  final double glowRadius;

  /// Externally provided focus node.
  final FocusNode? focusNode;

  /// Whether to request focus immediately.
  final bool autofocus;

  @override
  State<GlassSlider> createState() => _GlassSliderState();
}

class _GlassSliderState extends State<GlassSlider>
    with TickerProviderStateMixin {
  static const _defaultThumbShadow = [
    BoxShadow(
      color: Color.from(alpha: 0.15, red: 0, green: 0, blue: 0),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  double? _dragValue;
  bool _isDragging = false;
  // Scale (squash/stretch) and jelly controller
  late AnimationController _scaleController;
  late CurvedAnimation _scaleCurve;
  late Animation<double> _scaleAnimation;
  late SingleSpringController _jellyController;

  final ValueNotifier<bool> _isHovered = ValueNotifier(false);
  final ValueNotifier<bool> _isFocused = ValueNotifier(false);

  late AnimationController _thicknessController;
  late CurvedAnimation _thicknessCurve;
  late Animation<double> _thicknessAnimation;

  @override
  void initState() {
    super.initState();

    // Scale controller for thumb size change when dragging
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // iOS 26: Thumb "balloons in size" when dragging (1.25x = 25% larger)
    _scaleCurve = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack, // Slight overshoot for organic feel
      reverseCurve: Curves.easeInBack,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.35, // More dramatic balloon effect
    ).animate(_scaleCurve);

    // Simple 0→1 hold: fades the white pill out on press-down and
    // keeps it clear for the entire drag. Reverses back on release.
    _thicknessController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _thicknessCurve = CurvedAnimation(
      parent: _thicknessController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _thicknessAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_thicknessCurve);

    // Jelly spring: snappy with slight bounce for organic squash/stretch.
    // The controller drives a normalised position; its VELOCITY is what
    // feeds buildJellyTransform for the squash/stretch matrix.
    _jellyController = SingleSpringController(
      vsync: this,
      spring: GlassSpring.snappy(
        duration: const Duration(milliseconds: 350),
      ),
      initialValue: 0.0,
    );
  }

  @override
  void dispose() {
    _scaleCurve.dispose();
    _thicknessCurve.dispose();
    _scaleController.dispose();
    _thicknessController.dispose();
    _jellyController.dispose();
    _isHovered.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  double _normalizedToValue(double normalized) {
    return widget.min + (normalized * (widget.max - widget.min));
  }

  void _handleDragDown(DragDownDetails details) {
    // Instant visual response on touch down (iOS 26)
    if (_isDragging) return;

    setState(() {
      _isDragging = true;
    });
    unawaited(_scaleController.forward());
    // Fade the white pill out; stays clear for the whole drag
    unawaited(_thicknessController.forward());
  }

  void _handleDragStart(DragStartDetails details) {
    // Only call onChangeStart once per interaction
    widget.onChangeStart?.call(widget.value);
  }

  void _handleDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    final box = context.findRenderObject()! as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    // Calculate normalized position (0-1)
    final trackWidth = constraints.maxWidth - (widget.thumbRadius * 2);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final rawNormalizedX =
        ((localPosition.dx - widget.thumbRadius) / trackWidth).clamp(0.0, 1.0);
    final normalizedX = isRtl ? 1.0 - rawNormalizedX : rawNormalizedX;

    // Feed the spring controller with the new normalised position.
    // Its velocity property produces smooth, spring-based values that
    // buildJellyTransform can use for organic squash/stretch.
    _jellyController.animateTo(normalizedX);

    // Convert to value
    var newValue = _normalizedToValue(normalizedX);

    // Snap to divisions if provided
    if (widget.divisions != null) {
      final stepSize = (widget.max - widget.min) / widget.divisions!;
      newValue =
          ((newValue - widget.min) / stepSize).round() * stepSize + widget.min;
      newValue = newValue.clamp(widget.min, widget.max);

      // Haptic feedback on division change
      if (_dragValue != null && newValue != _dragValue) {
        unawaited(HapticFeedback.selectionClick());
      }
    }

    setState(() {
      _dragValue = newValue;
    });

    widget.onChanged?.call(newValue);
  }

  void _handleDragEnd(DragEndDetails details) {
    _cleanupDrag();
    widget.onChangeEnd?.call(widget.value);
  }

  void _handleDragCancel() {
    _cleanupDrag();
  }

  void _cleanupDrag() {
    if (!_isDragging) return;

    setState(() {
      _isDragging = false;
      _dragValue = null;
    });

    // Scale down thumb when ending drag
    unawaited(_scaleController.reverse());

    // Fade the white pill back in on release
    unawaited(_thicknessController.reverse());

    // Let the spring settle — this produces the elastic bounce-back jelly
    // animation as the velocity decays through the spring curve.
    // (No need to reset; the spring naturally settles to its current target.)
  }

  // Cache effectiveQuality at state level to make it accessible in _buildThumbGlass
  GlassQuality? _effectiveQuality;

  @override
  Widget build(BuildContext context) {
    // Inherit quality from parent layer or theme if not explicitly set
    _effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    final effectiveValue = _dragValue ?? widget.value;
    final normalizedValue =
        ((effectiveValue - widget.min) / (widget.max - widget.min))
            .clamp(0.0, 1.0);

    // Performance: Cache color calculations - these allocate on every build
    final brightness = GlassTheme.brightnessOf(context);
    final isDark = brightness == Brightness.dark;
    final activeColor = widget.activeColor ??
        (brightness == Brightness.light
            ? CupertinoColors.black.withValues(alpha: 0.8)
            : CupertinoColors.white.withValues(alpha: 0.8));
    final inactiveColor = widget.inactiveColor ??
        (brightness == Brightness.light
            ? CupertinoColors.black.withValues(alpha: 0.2)
            : CupertinoColors.white.withValues(alpha: 0.2));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final trackWidth = constraints.maxWidth - (widget.thumbRadius * 2);
        final thumbPosition = widget.thumbRadius +
            (trackWidth * (isRtl ? 1.0 - normalizedValue : normalizedValue));

        final step = (widget.max - widget.min) / (widget.divisions ?? 10);
        final increasedValue =
            (widget.value + step).clamp(widget.min, widget.max);
        final decreasedValue =
            (widget.value - step).clamp(widget.min, widget.max);

        final normalizedIncreased =
            ((increasedValue - widget.min) / (widget.max - widget.min))
                .clamp(0.0, 1.0);
        final normalizedDecreased =
            ((decreasedValue - widget.min) / (widget.max - widget.min))
                .clamp(0.0, 1.0);

        final thumbHeight = widget.thumbRadius * 1.6;

        return GlassFocusRegion(
          enabled: widget.onChanged != null,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          semanticLabel: widget.label ?? 'Slider',
          isSlider: true,
          semanticValue: '${(normalizedValue * 100).round()}%',
          semanticIncreasedValue: '${(normalizedIncreased * 100).round()}%',
          semanticDecreasedValue: '${(normalizedDecreased * 100).round()}%',
          semanticOnIncrease: widget.onChanged != null
              ? () {
                  widget.onChanged!(increasedValue);
                }
              : null,
          semanticOnDecrease: widget.onChanged != null
              ? () {
                  widget.onChanged!(decreasedValue);
                }
              : null,
          shape: const StadiumBorder(),
          isFocusedNotifier: _isFocused,
          isHoveredNotifier: _isHovered,
          // Sliders are adjusted with arrow keys, Space/Enter don't activate them natively
          onKeyboardActivate: null,
          child: RepaintBoundary(
            child: GestureDetector(
              onHorizontalDragDown: _handleDragDown,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: (details) =>
                  _handleDragUpdate(details, constraints),
              onHorizontalDragEnd: _handleDragEnd,
              onHorizontalDragCancel: _handleDragCancel,
              child: SizedBox(
                height: widget.thumbRadius * 2 + 16,
                width: constraints.maxWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track (centered vertically)
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          height: widget.trackHeight,
                          child: Stack(
                            children: [
                              // Full inactive track (iOS 26 style)
                              // Plain semi-transparent bar — no rim, no shader.
                              // Matches the real iOS 26 slider exactly.
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: inactiveColor,
                                    borderRadius: BorderRadius.circular(
                                      widget.trackHeight / 2,
                                    ),
                                  ),
                                ),
                              ),

                              // Active track
                              if (normalizedValue > 0)
                                Positioned(
                                  left: isRtl
                                      ? constraints.maxWidth *
                                          (1 - normalizedValue)
                                      : 0,
                                  right: isRtl
                                      ? 0
                                      : constraints.maxWidth *
                                          (1 - normalizedValue),
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: activeColor,
                                      borderRadius: BorderRadius.horizontal(
                                        left: isRtl
                                            ? (normalizedValue >= 1.0
                                                ? Radius.circular(
                                                    widget.trackHeight / 2)
                                                : Radius.zero)
                                            : Radius.circular(
                                                widget.trackHeight / 2),
                                        right: isRtl
                                            ? Radius.circular(
                                                widget.trackHeight / 2)
                                            : (normalizedValue >= 1.0
                                                ? Radius.circular(
                                                    widget.trackHeight / 2)
                                                : Radius.zero),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Thumb (iOS 26: premium hardware aligned + jelly physics)
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _scaleController,
                        _thicknessController,
                        _jellyController,
                      ]),
                      builder: (context, child) {
                        final scale = _scaleAnimation.value;

                        // Calculate actual thumb size after scaling for centering
                        final scaledThumbHeight = thumbHeight * scale;
                        // Adjust top position to keep thumb centered as it grows
                        final topPosition =
                            (widget.thumbRadius * 2 + 16 - scaledThumbHeight) /
                                2;

                        // Spring-based jelly: velocity from the spring controller
                        // produces smooth squash/stretch with natural deceleration
                        // and elastic bounce-back — matching tab bar/bottom bar.
                        final jellyVelocity = _jellyController.velocity;
                        final jellyTransform =
                            DraggableIndicatorPhysics.buildJellyTransform(
                          velocity: Offset(jellyVelocity, 0),
                          maxDistortion: 0.6,
                          // Slider spring tracks 0→1 normalised position,
                          // producing velocities of ~1-3 units/sec (vs tab bar's
                          // 10-20+). Scale down so these smaller velocities
                          // produce visible squash/stretch.
                          velocityScale: 2,
                        );

                        return Positioned(
                          left: thumbPosition - widget.thumbRadius,
                          top: topPosition,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: jellyTransform,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildThumbGlass(scale, isDark),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbGlass(double scale, bool isDark) {
    final thumbWidth = widget.thumbRadius * 2.6;
    final thumbHeight = widget.thumbRadius * 1.6;
    final borderRadius = thumbHeight / 2;

    // Calculate transition value (0 = at rest, 1 = fully dragging)
    final transition = _thicknessAnimation.value;

    // Standard: same rim/light math as AnimatedGlassIndicator pill.
    //   Dampeners in GlassEffect.build(): rimThickness×0.35, lightIntensity×0.6.
    // Premium: original values preserved exactly — no change to Premium rendering.
    final isStdPath =
        (_effectiveQuality ?? GlassQuality.standard) == GlassQuality.standard;

    // iOS 26: Dynamic size matching GlassSwitch pattern
    // The glass shell grows with the scale animation
    final totalWidth = thumbWidth * scale;
    final totalHeight = thumbHeight * scale;

    // iOS 26: Material content wrapped in Opacity (matches GlassSwitch pattern).
    // Using Opacity widget (not color alpha) is critical for Impeller: it
    // properly removes the child from the compositing tree, allowing the
    // native LiquidGlass refraction to show through when the material fades.
    final materialOpacity = (1.0 - transition * 1.2).clamp(0.0, 1.0);
    final thumbShadow = widget.thumbShadow ?? _defaultThumbShadow;
    final shadowOpacity = (1.0 - transition) * materialOpacity;
    final materialContent = Opacity(
      opacity: materialOpacity,
      child: Container(
        width: thumbWidth,
        height: thumbHeight,
        decoration: BoxDecoration(
          color: widget.thumbColor.withValues(alpha: 1.0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    // Use exact stadium SDF for the thumb — eliminates squircle drift.
    final thumbShape = LiquidRoundedRectangle(
      borderRadius: totalHeight / 2,
    );

    // CRITICAL: Outer SizedBox with dynamic size ensures proper premium rendering
    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Paint outside GlassEffect's shape clip, in the same thumb transform.
          // Fold the material fade into each shadow's alpha to avoid an
          // extra opacity layer around the blurred shadow on Impeller.
          if (thumbShadow.isNotEmpty)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: thumbWidth,
                  height: thumbHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: [
                        for (final shadow in thumbShadow)
                          shadow.copyWith(
                            color: shadow.color.withValues(
                              alpha: shadow.color.a * shadowOpacity,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          GlassEffect(
            shape: thumbShape,
            // Light mode: clear refractive glass with thicker body — visibility comes
            // from optical distortion and edge highlights.
            settings: LiquidGlassSettings(
              glassColor: isDark
                  ? const Color.from(alpha: 0.08, red: 1, green: 1, blue: 1)
                  : const Color.from(
                      alpha: 0.12, red: 0.88, green: 0.88, blue: 0.90),
              refractiveIndex: isDark ? 1.3 : 1.4,
              thickness: isDark ? 13 : 17,
              lightIntensity: isStdPath
                  ? 0.0
                  : 1.8, // no specular on synthetic path; premium unchanged
              blur: 0,
              lightAngle: GlassDefaults.lightAngle,
            ),
            rimThickness: isStdPath
                ? (isDark ? 0.5 : 0.7)
                : 0.5, // slightly thicker rim in light mode
            ambientRim: isStdPath
                ? (isDark ? 0.08 : 0.15)
                : 0.1, // stronger ambient ring in light mode
            baseAlphaMultiplier: isStdPath
                ? (isDark ? 0.08 : 0.12)
                : 0.08, // near-clear body — refraction provides visibility
            edgeAlphaMultiplier: isStdPath
                ? (isDark ? 0.15 : 0.28)
                : 0, // stronger edge contrast in light mode
            quality: _effectiveQuality ?? GlassQuality.standard,
            interactionIntensity: transition,
            child: SizedBox(
              width: totalWidth,
              height: totalHeight,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Glass shell footprint (crucial for proper shader rendering)
                  Positioned.fill(
                      child: Container(color: const Color(0x00000000))),

                  // Physical material content (centered, original size)
                  materialContent,

                  // Glowing element — only when interactionBehavior includes glow.
                  if (transition > 0.05 && widget.interactionBehavior.hasGlow)
                    Opacity(
                      opacity: transition,
                      child: GlassGlow(
                        glowColor:
                            widget.glowColor ?? Color(0x1FFFFFFF), // white ~12%
                        glowRadius: widget.glowRadius,
                        child: SizedBox(
                          width: thumbWidth,
                          height: thumbHeight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
