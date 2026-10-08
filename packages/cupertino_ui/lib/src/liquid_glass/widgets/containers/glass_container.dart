import 'package:flutter/widgets.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../types/glass_quality.dart';
import '../shared/adaptive_glass.dart';
import '../shared/inherited_liquid_glass.dart';
import '../../theme/glass_theme_helpers.dart';

/// A foundational glass container widget following Apple's liquid glass design.
///
/// This is the base primitive for all container-based glass widgets. It
/// provides a simple glass surface with configurable dimensions, padding,
/// and shape.
///
/// ## Usage Modes
///
/// ### Grouped Mode (default)
/// Uses [LiquidGlass.grouped] and inherits settings from parent
/// [LiquidGlassLayer]:
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(...),
///   child: Column(
///     children: [
///       GlassContainer(
///         child: Text('Hello'),
///       ),
///       GlassContainer(
///         child: Text('World'),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Standalone Mode
/// Creates its own layer with [LiquidGlass.withOwnLayer]:
/// ```dart
/// GlassContainer(
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 10,
///   ),
///   child: Text('Standalone'),
/// )
/// ```
///
/// ## Customization Examples
///
/// ### Custom padding and shape:
/// ```dart
/// GlassContainer(
///   padding: EdgeInsets.all(20),
///   shape: LiquidRoundedSuperellipse(borderRadius: 16),
///   child: Text('Padded content'),
/// )
/// ```
///
/// ### With constraints:
/// ```dart
/// GlassContainer(
///   width: 200,
///   height: 100,
///   child: Center(child: Text('Fixed size')),
/// )
/// ```
///
/// ### With clipping:
/// ```dart
/// GlassContainer(
///   clipBehavior: Clip.antiAlias,
///   child: Image.network('...'),
/// )
/// ```
///
/// ## ⚠️ Anti-Pattern: Do Not Place Glass Controls Inside a GlassContainer
///
/// [GlassContainer] is a **foundational surface**, not a generic wrapper.
/// Placing interactive glass controls inside it causes two problems:
///
/// 1. **Visual degradation** — [GlassContainer] sets
///    [InheritedLiquidGlass.avoidsRefraction] to `true` for its entire child
///    subtree. Any [GlassEffect] descendant falls back to a non-refracting
///    path — the inner glass effect is degraded by design.
///
/// 2. **Jelly-physics clipping** — With [useOwnLayer] `= true` on Impeller,
///    the container routes through `LiquidGlass.withOwnLayer` which applies
///    its own internal shape clip. Interactive indicator widgets overshoot
///    their bounds during spring animations — that overshoot gets cut.
///
/// Interactive glass controls already manage their own surface appearance via
/// `backgroundColor` and `indicatorColor` — no outer container is needed.
///
/// ```dart
/// // ✅ Correct — control manages its own surface
/// GlassSegmentedControl(
///   segments: [...],
///   selectedIndex: _index,
///   onSegmentSelected: (i) => setState(() => _index = i),
/// )
///
/// // ❌ Anti-pattern — degrades refraction, clips jelly animation
/// GlassContainer(
///   child: GlassSegmentedControl(...),
/// )
/// ```
class GlassContainer extends StatelessWidget {
  /// Creates a glass container.
  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.shape = const LiquidRoundedSuperellipse(borderRadius: 16),
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.clipBehavior = Clip.none,
    this.alignment,
    this.allowElevation = false,
    this.glowIntensity = 0.0,
    this.platformViewBackdrop = false,
  });

  // ===========================================================================
  // Content Properties
  // ===========================================================================

  /// The widget below this widget in the tree.
  ///
  /// This is the content that will be displayed inside the glass container.
  final Widget? child;

  /// The alignment of the [child] within the container.
  ///
  /// If null, the child is positioned according to its natural size.
  final AlignmentGeometry? alignment;

  // ===========================================================================
  // Sizing Properties
  // ===========================================================================

  /// Width of the container in logical pixels.
  ///
  /// If null, the container will size itself to fit its child.
  final double? width;

  /// Height of the container in logical pixels.
  ///
  /// If null, the container will size itself to fit its child.
  final double? height;

  /// Empty space to inscribe inside the glass container.
  ///
  /// The child is placed inside this padding.
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the glass container.
  ///
  /// The glass effect is not applied to the margin area.
  final EdgeInsetsGeometry? margin;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Shape of the glass container.
  ///
  /// Can be [LiquidOval], [LiquidRoundedRectangle], or
  /// [LiquidRoundedSuperellipse].
  ///
  /// Defaults to [LiquidRoundedSuperellipse] with 16px border radius, matching
  /// Apple's standard corner radius for cards and containers.
  final LiquidShape shape;

  /// Glass effect settings for this container.
  ///
  /// Controls the visual appearance of the glass effect including thickness,
  /// blur radius, color tint, lighting, and more.
  ///
  /// **Important:** In grouped mode (default), per-widget settings are
  /// ignored — the parent layer's settings are used instead. To apply
  /// per-widget settings, set `useOwnLayer: true`.
  ///
  /// For the best of both worlds, set `settings` on [GlassPage] or
  /// [AdaptiveLiquidGlassLayer] — all grouped children inherit them
  /// without the performance cost of separate layers.
  ///
  /// If null, inherits settings from the nearest parent layer or theme.
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass within an existing
  /// layer.
  ///
  /// - `false` (default): Uses [LiquidGlass.grouped], must be inside a
  /// [LiquidGlassLayer]. This is more performant when you have multiple glass
  /// elements that can share the same rendering context. Per-widget [settings]
  /// are ignored in this mode.
  ///
  /// - `true`: Uses [LiquidGlass.withOwnLayer], can be used anywhere.
  ///   Creates an independent glass rendering context. Per-widget [settings]
  ///   are applied in this mode.
  ///
  /// Defaults to false.
  final bool useOwnLayer;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent [InheritedLiquidGlass] or defaults to
  /// [GlassQuality.standard], which uses the lightweight fragment shader.
  /// This is 5-10x faster than BackdropFilter and works reliably in all
  /// contexts, including scrollable lists.
  ///
  /// Use [GlassQuality.premium] for full-pipeline shader with texture capture
  /// and chromatic aberration (Impeller only) in static layouts.
  final GlassQuality? quality;

  /// The clipping behavior for the container.
  ///
  /// Controls how content is clipped at the container's bounds:
  /// - [Clip.none]: No clipping (default, best performance)
  /// - [Clip.antiAlias]: Smooth anti-aliased clipping
  /// - [Clip.hardEdge]: Sharp clipping without anti-aliasing
  ///
  /// Use [Clip.antiAlias] or [Clip.hardEdge] when the child extends beyond
  /// the container's bounds (e.g., images, overflowing content).
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// Whether to allow elevation effects when in a grouped context.
  ///
  /// When false (default), the container won't darken or add rim effects
  /// when inside another glass container. This is correct for most containers
  /// as they are surfaces, not interactive elements.
  ///
  /// Set to true only for special cases where elevation is needed.
  ///
  /// Defaults to false.
  final bool allowElevation;

  /// Interactive glow intensity for Skia/Web (0.0–1.0).
  ///
  /// On Impeller, [GlassGlow] is the preferred mechanism. On Skia/Web this
  /// drives a shader-based highlight layer. Defaults to 0.0 (no glow).
  final double glowIntensity;

  /// When true (typically for iOS PlatformViews), forces the BackdropFilter
  /// fallback render path instead of the Impeller-native shader. Forwarded to
  /// the underlying [AdaptiveGlass].
  final bool platformViewBackdrop;

  @override
  Widget build(BuildContext context) {
    // Inherit quality from parent layer if not explicitly set
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
    );

    // 1. Start with the child content
    var content = child ?? const SizedBox.shrink();

    // 2. Apply padding inside the container (before glass effect)
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // 3. Apply alignment if provided
    if (alignment != null) {
      content = Align(
        alignment: alignment!,
        child: content,
      );
    }

    // 4. Apply glass effect with adaptive fallback
    // Premium quality uses Impeller on iOS/macOS, falls back to lightweight shader on web
    // Standard quality always uses lightweight shader

    // Debug-only: warn when per-widget settings differ from the parent layer's
    // settings in grouped mode. This catches the common mistake of passing
    // custom settings to a grouped container and expecting them to apply.
    // Internal widgets that pass through resolved settings won't trigger this.
    assert(() {
      if (settings != null && !useOwnLayer) {
        final inherited = InheritedLiquidGlass.of(context);
        if (inherited != null && inherited != settings) {
          debugPrint(
            'GlassContainer: `settings` provided without `useOwnLayer: true`. '
            'In grouped mode, per-widget settings are ignored — the parent '
            'layer\'s settings are used instead.\n'
            '  → To apply these settings, add `useOwnLayer: true` (creates a '
            'separate rendering layer).\n'
            '  → For better performance, set `settings` on GlassPage or '
            'AdaptiveLiquidGlassLayer so all grouped children inherit them.',
          );
        }
      }
      return true;
    }());

    final effectiveSettings = GlassThemeHelpers.resolveSettings(
      context,
      explicit: settings,
    );
    Widget glassWidget = AdaptiveGlass(
      shape: shape,
      settings: effectiveSettings,
      quality: effectiveQuality,
      useOwnLayer: useOwnLayer,
      clipBehavior: clipBehavior,
      allowElevation: allowElevation, // Configurable elevation behavior
      glowIntensity: glowIntensity,
      platformViewBackdrop: platformViewBackdrop,
      child: InheritedLiquidGlass(
        settings: effectiveSettings,
        quality: effectiveQuality,
        avoidsRefraction:
            true, // Containers block children from refracting background
        child: content,
      ),
    );

    // 5. Apply width/height constraints
    if (width != null || height != null) {
      glassWidget = SizedBox(
        width: width,
        height: height,
        child: glassWidget,
      );
    }

    // 6. Apply margin outside the glass effect
    if (margin != null) {
      glassWidget = Padding(
        padding: margin!,
        child: glassWidget,
      );
    }

    return glassWidget;
  }
}
