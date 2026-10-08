import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import '../src/renderer/liquid_glass_renderer.dart';
import '../utils/glass_brightness.dart';
import 'glass_interaction_settings.dart';
import 'glass_theme_settings.dart';

import '../types/glass_quality.dart';
import 'glass_theme_helpers.dart';

/// Color palette for glass glow effects.
///
/// Provides semantic colors for different interaction states and contexts.
/// Colors are used for glow effects on buttons, active states, and highlights.
@immutable
class GlassGlowColors {
  /// Creates a glow color palette.
  const GlassGlowColors({
    this.primary,
    this.secondary,
    this.success,
    this.warning,
    this.danger,
    this.info,
    this.glowBlurRadius = 4.0,
    this.glowSpreadRadius = 0,
    this.glowOpacity = 1,
  });

  /// Primary brand color for default interactive elements
  final Color? primary;

  /// Secondary brand color for alternative actions
  final Color? secondary;

  /// Success state color (typically green)
  final Color? success;

  /// Warning state color (typically orange/yellow)
  final Color? warning;

  /// Danger/error state color (typically red)
  final Color? danger;

  /// Informational color (typically blue)
  final Color? info;

  /// Gaussian blur sigma applied to the glow halo.
  ///
  /// Defaults to `4.0` — softens the glow edge into a natural, liquid-glass
  /// specular halo. Set to `0` for a crisp hard edge.
  /// Values in the 4–16 range give progressively more diffuse softening.
  /// Applied via [MaskFilter.blur] on the additive paint layer inside
  /// [GlassGlowLayer]; guarded so no GPU work occurs when the value is 0.
  ///
  /// Passed directly to [GlassGlow.glowBlurRadius].
  final double glowBlurRadius;

  /// Extra spread added to the drawn glow circle as a fraction of the
  /// layer's shortest side.
  ///
  /// 0 (the default) keeps the circle at the physics radius. A value of
  /// 0.2 expands it by 20 % of the layer's height (or width, whichever
  /// is smaller), making the glow bleed further without inflating the
  /// spring animation radius.
  ///
  /// Passed directly to [GlassGlow.glowSpreadRadius].
  final double glowSpreadRadius;

  /// Master opacity multiplier applied on top of the glow color's own alpha.
  ///
  /// Range 0–1, defaults to 1 (no change). Use this to uniformly dim the
  /// glow across all semantic colors without touching the raw color values.
  ///
  /// Passed directly to [GlassGlow.glowOpacity].
  final double glowOpacity;

  /// Creates a copy with overridden values.
  GlassGlowColors copyWith({
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    double? glowBlurRadius,
    double? glowSpreadRadius,
    double? glowOpacity,
  }) {
    return GlassGlowColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      glowBlurRadius: glowBlurRadius ?? this.glowBlurRadius,
      glowSpreadRadius: glowSpreadRadius ?? this.glowSpreadRadius,
      glowOpacity: glowOpacity ?? this.glowOpacity,
    );
  }

  /// Linearly interpolates between two glow palettes.
  ///
  /// Color fields that are non-null on both sides interpolate smoothly via
  /// [Color.lerp]; a field that is null on either side switches discretely at
  /// the midpoint, because `null` means "resolve a brightness-aware default
  /// at runtime" (see [GlassThemeData.glowColorsFor]) — fading through
  /// transparent would misrepresent that. The appearance scalars
  /// ([glowBlurRadius], [glowSpreadRadius], [glowOpacity]) always
  /// interpolate smoothly.
  ///
  /// Returns null when both [a] and [b] are null. Used by
  /// [GlassThemeVariant.lerp] to cross-fade between light and dark theme
  /// variants during content-aware brightness flips.
  static GlassGlowColors? lerp(
    GlassGlowColors? a,
    GlassGlowColors? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (a == null || b == null) return t < 0.5 ? a : b;
    return GlassGlowColors(
      primary: _lerpColorField(a.primary, b.primary, t),
      secondary: _lerpColorField(a.secondary, b.secondary, t),
      success: _lerpColorField(a.success, b.success, t),
      warning: _lerpColorField(a.warning, b.warning, t),
      danger: _lerpColorField(a.danger, b.danger, t),
      info: _lerpColorField(a.info, b.info, t),
      glowBlurRadius: lerpDouble(a.glowBlurRadius, b.glowBlurRadius, t)!,
      glowSpreadRadius: lerpDouble(a.glowSpreadRadius, b.glowSpreadRadius, t)!,
      glowOpacity: lerpDouble(a.glowOpacity, b.glowOpacity, t)!,
    );
  }

  static Color? _lerpColorField(Color? a, Color? b, double t) {
    if (a != null && b != null) return Color.lerp(a, b, t);
    return t < 0.5 ? a : b;
  }

  /// Fallback glow colors with sensible defaults.
  ///
  /// The primary color is intentionally left null here so that
  /// [GlassThemeData.glowColorsFor] can substitute a brightness-aware warm
  /// specular highlight at runtime (more visible in light mode, more restrained
  /// in dark mode where the glass surface is already luminous).
  static const GlassGlowColors fallback = GlassGlowColors(
    // primary is null — resolved at runtime by glowColorsFor() based on
    // current brightness. See GlassThemeData.glowColorsFor.
    secondary: Color(0xFF5856D6), // iOS purple
    success: Color(0xFF34C759), // iOS green
    warning: Color(0xFFFF9500), // iOS orange
    danger: Color(0xFFFF3B30), // iOS red
    info: Color(0xFF5AC8FA), // iOS light blue
    // Appearance defaults — sigma-4 blur softens the glow edge for a natural
    // liquid-glass feel. Zero-cost when inactive (guarded by > 0 check).
    glowBlurRadius: 4.0,
    glowSpreadRadius: 0,
    glowOpacity: 1,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassGlowColors &&
          runtimeType == other.runtimeType &&
          primary == other.primary &&
          secondary == other.secondary &&
          success == other.success &&
          warning == other.warning &&
          danger == other.danger &&
          info == other.info &&
          glowBlurRadius == other.glowBlurRadius &&
          glowSpreadRadius == other.glowSpreadRadius &&
          glowOpacity == other.glowOpacity;

  @override
  int get hashCode => Object.hash(
        primary,
        secondary,
        success,
        warning,
        danger,
        info,
        glowBlurRadius,
        glowSpreadRadius,
        glowOpacity,
      );
}

/// Theme configuration for a specific brightness (light or dark).
///
/// Contains all styling information for glass widgets in a single theme mode.
@immutable
class GlassThemeVariant {
  /// Creates a theme variant for light or dark mode.
  const GlassThemeVariant({
    this.settings,
    this.quality,
    this.glowColors,
    this.borderRadius,
  });

  /// Partial glass visual settings applied on top of each widget's own defaults.
  ///
  /// Only non-null fields in the override replace the corresponding widget
  /// default — unset fields are left alone. This prevents a single-property
  /// theme override from silently zeroing out unrelated properties (e.g. setting
  /// only `thickness` no longer clears `glassColor` back to fully transparent).
  ///
  /// To override a specific widget entirely, pass explicit `settings` directly
  /// to that widget constructor.
  final GlassThemeSettings? settings;

  /// Default rendering quality for all widgets.
  ///
  /// Individual widgets can override this via their `quality` parameter.
  final GlassQuality? quality;

  /// Semantic color palette for glow effects.
  final GlassGlowColors? glowColors;

  /// Default corner radius for all glass widgets in this variant.
  ///
  /// If null, widgets will use their own defaults or [GlassThemeHelpers.resolveAdaptiveRadius].
  final double? borderRadius;

  /// Creates a copy with overridden values.
  GlassThemeVariant copyWith({
    GlassThemeSettings? settings,
    GlassQuality? quality,
    GlassGlowColors? glowColors,
    double? borderRadius,
  }) {
    return GlassThemeVariant(
      settings: settings ?? this.settings,
      quality: quality ?? this.quality,
      glowColors: glowColors ?? this.glowColors,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Linearly interpolates between two theme variants.
  ///
  /// Continuous values interpolate smoothly; discrete or optional values
  /// switch at the midpoint:
  ///
  /// - [settings] delegates to [GlassThemeSettings.lerp] (per-field smooth
  ///   lerp with midpoint switching for one-sided `null`s).
  /// - [glowColors] delegates to [GlassGlowColors.lerp].
  /// - [borderRadius] interpolates when set on both sides, otherwise
  ///   switches at the midpoint.
  /// - [quality] is discrete and always switches at the midpoint.
  ///
  /// Used to cross-fade between the light and dark variants when a
  /// content-aware brightness flip animates (see `GlassContentAwareScope`).
  static GlassThemeVariant lerp(
    GlassThemeVariant a,
    GlassThemeVariant b,
    double t,
  ) {
    if (identical(a, b)) return a;
    final double? radius;
    if (a.borderRadius != null && b.borderRadius != null) {
      radius = lerpDouble(a.borderRadius, b.borderRadius, t);
    } else {
      radius = t < 0.5 ? a.borderRadius : b.borderRadius;
    }
    return GlassThemeVariant(
      settings: GlassThemeSettings.lerp(a.settings, b.settings, t),
      quality: t < 0.5 ? a.quality : b.quality,
      glowColors: GlassGlowColors.lerp(a.glowColors, b.glowColors, t),
      borderRadius: radius,
    );
  }

  /// Default light theme variant.
  ///
  /// [quality] is intentionally `null` here so that each widget's own
  /// documented default quality is respected (e.g. [GlassTabBar.bottom] defaults
  /// to [GlassQuality.premium]). Set quality explicitly in your
  /// [GlassThemeVariant] to override all widgets globally.
  static const GlassThemeVariant light = GlassThemeVariant(
    settings: GlassThemeSettings(
      thickness: 12.0, // Slightly thicker than dark — needs more body on white
      blur: 5.0, // Matched with dark for consistency
      glassColor: Color.fromRGBO(210, 220, 240, 0.12), // ~12% cool blue-white
      lightAngle: 2.356, // 0.75 * pi ≈ 135° — upper-left, matches iOS 26
      lightIntensity: 0.85, // Softer — bright backgrounds need less highlight
      ambientStrength: 0.15, // Touch of ambient keeps glass visible on white
      refractiveIndex: 1.2,
      saturation: 1.2,
      chromaticAberration: 0.02, // Subtle prismatic edge, not distracting
    ),
    quality: null,
    glowColors: GlassGlowColors.fallback,
  );

  /// Default dark theme variant.
  ///
  /// [quality] is intentionally `null` here so that each widget's own
  /// documented default quality is respected (e.g. [GlassTabBar.bottom] defaults
  /// to [GlassQuality.premium]). Set quality explicitly in your
  /// [GlassThemeVariant] to override all widgets globally.
  static const GlassThemeVariant dark = GlassThemeVariant(
    settings: GlassThemeSettings(
      thickness: 10.0,
      blur: 4.0,
      glassColor: Color.fromRGBO(255, 255, 255, 0.08),
      lightAngle: 2.356, // 0.75 * pi ≈ 135° — upper-left, matches iOS 26
      lightIntensity: 0.7,
      ambientStrength: 0.0,
      refractiveIndex: 1.2,
      saturation: 1.2,
      chromaticAberration: 0.01,
    ),
    quality: null,
    glowColors: GlassGlowColors.fallback,
  );

  /// Shader-free theme variant for maximum compatibility.
  ///
  /// All glass widgets in this subtree use [GlassQuality.minimal]: plain
  /// BackdropFilter blur with a tinted container. No fragment shaders,
  /// no texture capture, no specular effects.
  ///
  /// Use this as your global theme when targeting pre-iPhone 13 / pre-A15
  /// devices, or when the [GlassPerformanceMonitor] consistently warns about
  /// GPU budget overruns:
  ///
  /// ```dart
  /// GlassTheme(
  ///   data: GlassThemeData(
  ///     light: GlassThemeVariant.minimal,
  ///     dark: GlassThemeVariant.minimal,
  ///   ),
  ///   child: child!,
  /// )
  /// ```
  static const GlassThemeVariant minimal = GlassThemeVariant(
    settings: GlassThemeSettings(
      thickness: 10.0, // Consistent with light/dark
      blur: 8.0, // BackdropFilter sigma — enough frosting to see shapes through
      glassColor: Color.fromRGBO(
          200, 210, 230, 0.15), // Visible tint for the container overlay
    ),
    quality: GlassQuality.minimal,
    glowColors: GlassGlowColors.fallback,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassThemeVariant &&
          runtimeType == other.runtimeType &&
          settings == other.settings &&
          quality == other.quality &&
          glowColors == other.glowColors &&
          borderRadius == other.borderRadius;

  @override
  int get hashCode => Object.hash(settings, quality, glowColors, borderRadius);
}

/// Theme data for liquid glass widgets.
///
/// Provides centralized styling for all glass widgets in your app, with
/// automatic light/dark mode support. Brightness is resolved via a priority
/// cascade: [GlassThemeData.brightness] override → Cupertino explicit pin →
/// Material [ThemeMode] → system/device setting. This ensures glass widgets
/// always follow the **app's** intended brightness, not the device OS setting.
///
/// ## Usage
///
/// Wrap your app with [GlassTheme] to provide theme data:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light(),
///   darkTheme: ThemeData.dark(),
///   builder: (context, child) => GlassTheme(
///     data: GlassThemeData(
///       light: GlassThemeVariant(
///         settings: LiquidGlassSettings(thickness: 30, blur: 3),
///         quality: GlassQuality.standard,
///       ),
///       dark: GlassThemeVariant(
///         settings: LiquidGlassSettings(thickness: 40, blur: 5),
///         quality: GlassQuality.standard,
///       ),
///     ),
///     child: child!,
///   ),
/// )
/// ```
///
/// Access theme data in widgets:
///
/// ```dart
/// final theme = GlassThemeData.of(context);
/// final settings = theme.settings; // Automatically uses light/dark variant
/// ```
@immutable
class GlassThemeData {
  /// Creates glass theme data with separate light and dark configurations.
  ///
  /// Both [light] and [dark] default to sensible values — if you only want
  /// to tweak a single property, use [GlassThemeData.simple] instead.
  const GlassThemeData({
    this.light = GlassThemeVariant.light,
    this.dark = GlassThemeVariant.dark,
    this.interaction = const GlassInteractionSettings(),
    this.brightness,
  });

  /// Creates glass theme data from a flat set of common properties.
  ///
  /// This is the **recommended constructor for most apps**. It applies the
  /// same `settings` and `quality` to both light and dark modes using the
  /// library's built-in light/dark defaults as a base — you only need to
  /// specify what you want to change.
  ///
  /// ```dart
  /// // Minimal — just set blur and thickness, everything else uses defaults:
  /// GlassThemeData.simple(
  ///   blur: 10,
  ///   thickness: 30,
  /// )
  ///
  /// // With quality:
  /// GlassThemeData.simple(
  ///   blur: 10,
  ///   thickness: 30,
  ///   quality: GlassQuality.standard,
  /// )
  /// ```
  ///
  /// For fine-grained per-mode control (different blur in dark mode, custom
  /// glow colors, etc.) use the default [GlassThemeData] constructor instead.
  factory GlassThemeData.simple({
    double? blur,
    double? thickness,
    GlassQuality? quality,
    double? chromaticAberration,
    double? lightIntensity,
    double? ambientStrength,
    double? refractiveIndex,
    double? saturation,
    double? borderRadius,
    GlassInteractionSettings? interaction,
    Brightness? brightness,
  }) {
    final settings = GlassThemeSettings(
      blur: blur,
      thickness: thickness,
      chromaticAberration: chromaticAberration,
      lightIntensity: lightIntensity,
      ambientStrength: ambientStrength,
      refractiveIndex: refractiveIndex,
      saturation: saturation,
    );

    return GlassThemeData(
      light: GlassThemeVariant.light.copyWith(
        settings: GlassThemeVariant.light.settings?.copyWith(
              blur: blur,
              thickness: thickness,
              chromaticAberration: chromaticAberration,
              lightIntensity: lightIntensity,
              ambientStrength: ambientStrength,
              refractiveIndex: refractiveIndex,
              saturation: saturation,
            ) ??
            settings,
        quality: quality,
        borderRadius: borderRadius,
      ),
      dark: GlassThemeVariant.dark.copyWith(
        settings: GlassThemeVariant.dark.settings?.copyWith(
              blur: blur,
              thickness: thickness,
              chromaticAberration: chromaticAberration,
              lightIntensity: lightIntensity,
              ambientStrength: ambientStrength,
              refractiveIndex: refractiveIndex,
              saturation: saturation,
            ) ??
            settings,
        quality: quality,
        borderRadius: borderRadius,
      ),
      interaction: interaction ?? const GlassInteractionSettings(),
      brightness: brightness,
    );
  }

  /// Theme variant for light mode.
  final GlassThemeVariant light;

  /// Theme variant for dark mode.
  final GlassThemeVariant dark;

  /// Interaction physics settings (brightness-agnostic).
  ///
  /// Controls stretch, press scale, drag resistance, and anchor stretch
  /// for all interactive glass widgets. Individual widgets can override
  /// any parameter via their constructor.
  ///
  /// Lives at the top level (not per-variant) because interaction physics
  /// don't change between light and dark mode.
  final GlassInteractionSettings interaction;

  /// Explicit brightness override for all glass widgets under this theme.
  ///
  /// When non-null, **all** glass widgets in this subtree render at this
  /// fixed brightness, regardless of the device OS setting, Material
  /// [ThemeMode], or Cupertino theme brightness.
  ///
  /// This is the highest-priority level in the four-level brightness cascade:
  /// `GlassThemeData.brightness` → Cupertino pin → Material ThemeMode → system.
  ///
  /// **Use cases**
  /// - Force a specific section of your UI to always render in light mode
  ///   (e.g. a camera viewfinder overlay that should always be dark).
  /// - Testing: pin brightness to a known value in widget tests.
  ///
  /// When null (default), brightness resolves automatically through the
  /// cascade. See [GlassTheme.brightnessOf] for the resolution logic.
  final Brightness? brightness;

  /// Retrieves the theme data from the widget tree.
  ///
  /// Returns the current [GlassThemeData] from the nearest GlassTheme
  /// ancestor. If no theme is found, returns [GlassThemeData.fallback].
  static GlassThemeData of(BuildContext context) {
    return GlassThemeHelpers.of(context);
  }

  /// Retrieves the appropriate theme variant based on the resolved brightness.
  ///
  /// Uses the four-level cascade: [brightness] override → Cupertino pin →
  /// Material [ThemeMode] → system/device. This ensures the correct variant
  /// is selected even when the device OS and app theme differ.
  GlassThemeVariant variantFor(BuildContext context) {
    // Level 1: own brightness override takes absolute priority.
    // Levels 2-4: delegated to the package-private utility.
    final b = brightness ?? resolveGlassBrightness(context);
    return b == Brightness.dark ? dark : light;
  }

  /// Gets the partial glass settings override for the current brightness.
  ///
  /// Returns a [GlassThemeSettings] rather than a full
  /// [LiquidGlassSettings] — callers should merge this on top of their own
  /// defaults via [GlassThemeSettings.applyTo].
  GlassThemeSettings? settingsFor(BuildContext context) {
    return variantFor(context).settings;
  }

  /// Gets rendering quality for current brightness.
  GlassQuality? qualityFor(BuildContext context) {
    return variantFor(context).quality;
  }

  /// Gets default corner radius for current brightness.
  double? borderRadiusFor(BuildContext context) {
    return variantFor(context).borderRadius;
  }

  /// Gets glow colors for current brightness.
  ///
  /// If the caller has not set an explicit [GlassGlowColors.primary], this
  /// method substitutes a brightness-aware neutral white specular highlight
  /// matching the iOS 26 press feedback model. iOS 26 glass surfaces produce
  /// a bright, grey-white highlight on interaction — like light diffracting
  /// through frosted glass — not a colored or dim tint.
  ///
  /// Opacity is higher in light mode (glass is more transparent, highlight
  /// needs more presence) and slightly lower in dark mode (the glass surface
  /// is already luminous from the dark blurred background).
  GlassGlowColors glowColorsFor(BuildContext context) {
    final colors = variantFor(context).glowColors ?? GlassGlowColors.fallback;

    // Only inject the adaptive primary when the caller has not provided one.
    if (colors.primary != null) return colors;

    // Resolve brightness consistently with variantFor — own override first,
    // then the package cascade. Do NOT call MediaQuery.platformBrightnessOf
    // directly here, or the glow and the variant would use different sources.
    final isDark =
        (brightness ?? resolveGlassBrightness(context)) == Brightness.dark;
    // 0x3D = ~24% opacity in light mode (matches the pre-0.9.1 Colors.white24
    // default that GlassButton used before theme propagation was introduced).
    // 0x2A = ~16% opacity in dark mode — dark glass surfaces are already
    // luminous, so a slightly dimmer highlight looks more natural.
    // BlendMode.plus compositing keeps both from blowing out.
    final adaptivePrimary =
        isDark ? const Color(0x2AFFFFFF) : const Color(0x3DFFFFFF);

    return colors.copyWith(primary: adaptivePrimary);
  }

  /// Creates a copy with overridden values.
  GlassThemeData copyWith({
    GlassThemeVariant? light,
    GlassThemeVariant? dark,
    GlassInteractionSettings? interaction,
    Object? brightness = _sentinel,
  }) {
    return GlassThemeData(
      light: light ?? this.light,
      dark: dark ?? this.dark,
      interaction: interaction ?? this.interaction,
      // Use sentinel so callers can explicitly clear the override with null.
      brightness:
          brightness == _sentinel ? this.brightness : brightness as Brightness?,
    );
  }

  static const Object _sentinel = Object();

  /// Default fallback theme when no [GlassTheme] is present in widget tree.
  factory GlassThemeData.fallback() {
    return const GlassThemeData(
      light: GlassThemeVariant.light,
      dark: GlassThemeVariant.dark,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassThemeData &&
          runtimeType == other.runtimeType &&
          light == other.light &&
          dark == other.dark &&
          interaction == other.interaction &&
          brightness == other.brightness;

  @override
  int get hashCode => Object.hash(light, dark, interaction, brightness);
}
