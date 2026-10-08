import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_data.dart';
import '../../types/glass_quality.dart';
import '../../utils/glass_performance_monitor.dart';
import 'glass_isolation_scope.dart';
import 'inherited_liquid_glass.dart';

/// An adaptive liquid glass layer that provides a glass background with proper
/// fallback handling across all platforms.
///
/// This is a custom replacement for `LiquidGlassLayer` that uses `AdaptiveGlass`
/// for rendering, ensuring the background uses the lightweight shader on web/Skia
/// instead of falling back to FakeGlass.
///
/// **Fallback chain for background:**
/// - Premium + Impeller → Full shader (best quality) + blending support
/// - Premium + Skia/web → Lightweight shader (not FakeGlass!)
/// - Standard → Lightweight shader
///
/// **Blending:**
/// - `blendAmount` parameter only works on Impeller (requires full renderer)
/// - On Skia, blending is ignored (widgets render separately)
/// - This matches chromatic aberration behavior (Impeller-only features)
///
/// **Usage:**
/// ```dart
/// // With explicit settings:
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(...),
///   quality: GlassQuality.premium,
///   shape: LiquidRoundedSuperellipse(borderRadius: 32),
///   blendAmount: 10.0, // Impeller-only
///   child: YourContent(),
/// )
///
/// // Or use theme (recommended):
/// AdaptiveLiquidGlassLayer(
///   child: YourContent(), // Uses GlassTheme settings automatically
/// )
/// ```
class AdaptiveLiquidGlassLayer extends StatefulWidget {
  /// Creates a new [AdaptiveLiquidGlassLayer].
  const AdaptiveLiquidGlassLayer({
    required this.child,
    this.shape = const LiquidRoundedSuperellipse(borderRadius: 0),
    this.settings,
    this.quality,
    this.clipBehavior = Clip.antiAlias,
    this.clipExpansion = EdgeInsets.zero,
    this.blendAmount = 10.0,
    this.platformViewBackdrop = false,
    super.key,
  });

  /// The widget to display inside the glass layer.
  final Widget child;

  /// The shape of the glass background.
  final LiquidShape shape;

  /// Glass effect settings for the background.
  ///
  /// If null, uses settings from [GlassTheme] based on current brightness.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  ///
  /// If null, uses quality from [GlassTheme].
  final GlassQuality? quality;

  /// Clip behavior for the glass shape.
  final Clip clipBehavior;

  /// Expansion margin for the compositor clip rect to allow jelly physics to exceed bounds.
  final EdgeInsets clipExpansion;

  /// Blend amount for smooth glass transitions (Impeller-only).
  ///
  /// Higher values create smoother blending between overlapping glass elements.
  /// Only works on Impeller - ignored on Skia (like chromatic aberration).
  ///
  /// Defaults to 10.0.
  final double blendAmount;

  /// When true (typically for iOS PlatformViews), forces the fallback rendering
  /// path (BackdropFilter) instead of the Impeller-native shader.
  final bool platformViewBackdrop;

  /// Detects if Impeller rendering engine is active.
  static bool get _canUseImpeller => ui.ImageFilter.isShaderFilterSupported;

  @override
  State<AdaptiveLiquidGlassLayer> createState() =>
      _AdaptiveLiquidGlassLayerState();
}

class _AdaptiveLiquidGlassLayerState extends State<AdaptiveLiquidGlassLayer> {
  // Stable identity for the child subtree across the structural wrapper toggle
  // in build(). `useFullRenderer` (which flips with [platformViewBackdrop])
  // decides whether the child is wrapped in a [LiquidGlassBlendGroup]. Without a
  // stable key, toggling the flag changes the child's depth in the element tree,
  // so Flutter REMOUNTS the whole subtree — re-running initState on any
  // animation controllers inside it. For a bottom bar that re-seeds the
  // selected-indicator springs at their settled value, so the indicator SNAPS
  // to the new tab instead of morphing. A GlobalKey lets Flutter reparent the
  // subtree across the wrapper change (preserving the live controllers) instead.
  final GlobalKey _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Resolve settings: start with base defaults, apply theme partial override
    // (only non-null fields), then let explicit widget settings win entirely.
    final themeData = GlassThemeData.of(context);
    const baseSettings = LiquidGlassSettings();
    final themeOverride = themeData.settingsFor(context);
    final withTheme = themeOverride?.applyTo(baseSettings) ?? baseSettings;
    final effectiveSettings = widget.settings ?? withTheme;
    final effectiveQuality = widget.quality ??
        themeData.qualityFor(context) ??
        GlassQuality.standard;

    // ---- TRANSPARENT PASS-THROUGH FAST-PATHS --------------------------------
    // Two cases share the same pass-through structure (no LiquidGlassLayer
    // wrapper, no blend group — just InheritedLiquidGlass so descendants can
    // read settings and quality):
    //
    // 1. GlassQuality.minimal:
    //    Skips LiquidGlassLayer entirely. The layer has no shape — it wraps
    //    the full bounds including any padding around pill/circle children.
    //    Painting a BackdropFilter + tinted Container here bleeds into that
    //    padding area, creating the dark rectangle visible above/around the
    //    individual glass shapes. Glass tinting and blur come entirely from
    //    child AdaptiveGlass widgets, each rendered as _FrostedFallback with
    //    correct shape-aware clipping.
    //
    // 2. platformViewBackdrop == true (e.g. glass over an iOS map/video):
    //    LiquidGlassLayer pushes an Impeller fragment-shader ImageFilter layer.
    //    Attempting to run a shader filter over a UIKitView crashes on iOS.
    //    We bypass it entirely; child AdaptiveGlass widgets already route to
    //    _FrostedFallback (live BackdropFilter) when platformViewBackdrop is
    //    set, which correctly samples through the PlatformView compositor.
    // -------------------------------------------------------------------------
    if (effectiveQuality == GlassQuality.minimal ||
        widget.platformViewBackdrop) {
      return GlassIsolationScope(
        isolated: false,
        child: InheritedLiquidGlass(
          settings: effectiveSettings,
          quality: effectiveQuality,
          isBlurProvidedByAncestor: false,
          child: KeyedSubtree(key: _contentKey, child: widget.child),
        ),
      );
    }

    // Detect if we should use the full Impeller-native rendering pipeline.
    // platformViewBackdrop is never true here — that case returned above.
    final bool useFullRenderer = AdaptiveLiquidGlassLayer._canUseImpeller &&
        effectiveQuality == GlassQuality.premium;

    // Resolve shadow for SDF rendering. Shadows only apply in light mode.
    final bool isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final List<BoxShadow> resolvedShadows =
        isDark ? const <BoxShadow>[] : effectiveSettings.effectiveShadow;

    // Keep the child subtree's element identity stable across the wrapper toggle
    // below (see [_contentKey]) so its animation controllers survive.
    final Widget keyedContent =
        KeyedSubtree(key: _contentKey, child: widget.child);

    return PremiumGlassTracker(
      child: LiquidGlassLayer(
        settings: effectiveSettings,
        shadows: resolvedShadows,
        clipExpansion: widget.clipExpansion,
        child: GlassIsolationScope(
          isolated: false,
          child: InheritedLiquidGlass(
            settings: effectiveSettings,
            quality: effectiveQuality,
            isBlurProvidedByAncestor:
                false, // Root never provides the blur; containers do.
            child: useFullRenderer
                ? LiquidGlassBlendGroup(
                    blend: widget.blendAmount,
                    child: keyedContent,
                  )
                : keyedContent,
          ),
        ),
      ),
    );
  }
}
