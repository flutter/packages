import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../liquid_glass_setup.dart';
import '../src/renderer/liquid_glass_renderer.dart';
import '../types/glass_quality.dart';
import '../widgets/shared/glass_adaptive_scope.dart';
import '../widgets/shared/glass_isolation_scope.dart';
import '../widgets/shared/inherited_liquid_glass.dart';
import 'glass_theme.dart';
import 'glass_theme_data.dart';

/// Helper functions for working with Glass Theme.
class GlassThemeHelpers {
  GlassThemeHelpers._();

  /// Retrieves the theme data from the widget tree.
  ///
  /// Returns the current [GlassThemeData] from the nearest [GlassTheme]
  /// ancestor. If no theme is found, returns [GlassThemeData.fallback].
  static GlassThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<GlassTheme>();
    return theme?.data ?? GlassThemeData.fallback();
  }

  /// Resolves the effective [GlassQuality] for a widget.
  ///
  /// Every glass widget calls this once per build to determine its actual
  /// rendering quality. The resolution follows a strict five-level priority
  /// chain. Read from highest to lowest priority:
  ///
  /// ---
  ///
  /// ### Level 1 — Widget-level explicit quality
  ///
  /// The `quality:` parameter on an individual widget.
  ///
  /// ```dart
  /// GlassButton(quality: GlassQuality.minimal, ...) // always resolved first
  /// ```
  ///
  /// **Wins over**: theme, inherited, and widget-class defaults.
  /// **Subject to**: [GlassAdaptiveScope] ceiling (see Level 3).
  ///
  /// `quality: GlassQuality.premium` means *"I want premium **if the device can
  /// handle it**"*. The adaptive scope is the arbiter of device capability and
  /// will cap this down when necessary. This is the correct mental model — you
  /// are expressing intent, not issuing a guarantee.
  ///
  /// ---
  ///
  /// ### Level 2 — Inherited ancestor quality
  ///
  /// The [GlassQuality] provided by the nearest [AdaptiveLiquidGlassLayer]
  /// ancestor via [InheritedLiquidGlass]. Only consulted if Level 1 is null.
  ///
  /// ```dart
  /// AdaptiveLiquidGlassLayer(
  ///   quality: GlassQuality.standard, // all descendants without explicit quality get standard
  ///   child: ...,
  /// )
  /// ```
  ///
  /// ---
  ///
  /// ### Level 3 — GlassAdaptiveScope ceiling (applied uniformly to all levels)
  ///
  /// If a [GlassAdaptiveScope] ancestor is present, the quality resolved at
  /// any of Levels 1, 2, 4, or 5 is **capped** to the scope's
  /// [GlassAdaptiveScopeData.effectiveQuality]. The scope never raises quality —
  /// it only lowers it.
  ///
  /// ```dart
  /// // Scope decides device can sustain standard.
  /// // A premium widget gets standard. A minimal widget stays minimal.
  /// GlassAdaptiveScope(
  ///   child: Column(children: [
  ///     GlassTabBar.bottom(quality: GlassQuality.premium),// → standard (capped)
  ///     GlassButton(quality: GlassQuality.minimal),  // → minimal  (not raised)
  ///     GlassButton(),                               // → standard (from fallback, capped)
  ///   ]),
  /// )
  /// ```
  ///
  /// To **bypass the scope ceiling** on a specific subtree — for a hero widget
  /// you've verified runs well on the target device — wrap it in its own
  /// locked scope:
  ///
  /// ```dart
  /// GlassAdaptiveScope(
  ///   minQuality: GlassQuality.premium, // floor = premium
  ///   maxQuality: GlassQuality.premium, // ceiling = premium → locked
  ///   child: GlassTabBar.bottom(quality: GlassQuality.premium),
  /// )
  /// ```
  ///
  /// ---
  ///
  /// ### Level 4 — GlassTheme quality
  ///
  /// The `quality` field of the [GlassThemeVariant] from the nearest [GlassTheme]
  /// ancestor. Controls all widgets in the subtree that don't have a
  /// widget-level or inherited quality set.
  ///
  /// ```dart
  /// GlassTheme(
  ///   data: GlassThemeData(
  ///     light: GlassThemeVariant(quality: GlassQuality.standard), // all widgets → standard
  ///     dark:  GlassThemeVariant(quality: GlassQuality.standard),
  ///   ),
  ///   child: ...,
  /// )
  /// ```
  ///
  /// **Default theme variants** ([GlassThemeVariant.light] and
  /// [GlassThemeVariant.dark]) have `quality: null`, so theme quality is
  /// transparent by default and falls through to Level 5.
  ///
  /// ---
  ///
  /// ### Level 5 — Widget-class default (the `fallback` parameter)
  ///
  /// The last resort. Each widget class hard-codes the quality that makes
  /// sense for its role when nothing else is specified:
  ///
  /// | Widget class | Default quality | Rationale |
  /// |---|---|---|
  /// | [GlassTabBar.bottom] | `premium` | Static footer — full quality expected |
  /// | [GlassToolbar] | `premium` | Static surface |
  /// | [GlassTabBar] | `standard` | May be in a scrollable context |
  /// | [GlassButton] | `standard` | Interactive, potentially many on screen |
  /// | [GlassTextField] | `standard` | Interactive |
  /// | [GlassSlider] | `standard` | Animated during interaction |
  /// | [GlassDialog] | `standard` | Overlay |
  /// | [GlassSheet] | `standard` | Overlay |
  /// | [GlassContainer] | `standard` | General purpose container |
  ///
  /// Widgets pass their own default as the [fallback] parameter when calling
  /// [resolveQuality]. You do not set this — it is an implementation detail.
  ///
  /// ---
  ///
  /// ### Complete priority summary
  ///
  /// ```
  /// Highest priority
  ///   1. widget explicit quality:  GlassButton(quality: GlassQuality.minimal)
  ///   2. inherited ancestor:       AdaptiveLiquidGlassLayer(quality: ...)
  ///   ── GlassAdaptiveScope ceiling applied to levels 1 & 2 above ──
  ///   3. theme quality:            GlassThemeVariant(quality: GlassQuality.standard)
  ///   4. widget-class default:     GlassTabBar.bottom → premium, GlassButton → standard
  ///   ── GlassAdaptiveScope ceiling applied to levels 3 & 4 above ──
  /// Lowest priority
  /// ```
  ///
  /// Note: Level 2 ([AdaptiveLiquidGlassLayer]) is a lower-level internal
  /// mechanism. In most apps you will only interact with Levels 1, 3, 4, and
  /// the scope ceiling.
  ///
  static GlassQuality resolveQuality(
    BuildContext context, {
    GlassQuality? widgetQuality,
    GlassQuality fallback = GlassQuality.standard,
  }) {
    // Read the adaptive ceiling once — applied uniformly to every step.
    final adaptiveData = GlassAdaptiveScopeData.maybeOf(context);

    // Step 1: Widget-level quality wins over theme and inherited.
    //
    // It is NOT exempt from the adaptive scope. `quality: GlassQuality.premium`
    // means "I want premium if the device can handle it." GlassAdaptiveScope
    // is the arbiter of device capability and caps the result when necessary.
    //
    // To unconditionally force a quality floor on a specific subtree regardless
    // of the enclosing ceiling, wrap it with:
    //   GlassAdaptiveScope(minQuality: GlassQuality.premium, child: ...)
    if (widgetQuality != null) {
      return adaptiveData != null
          ? _applyCeiling(widgetQuality, adaptiveData.effectiveQuality)
          : widgetQuality;
    }

    // Step 2: inherited ancestor quality (e.g. from AdaptiveLiquidGlassLayer).
    //
    // SKIP when:
    // - Inside a GlassIsolationScope with `isolated: true` — isolated surfaces
    //   create their own glass layers and should not inherit from the page layer.
    // - A GlassIsolationScope provides a `defaultQuality` — the scope is
    //   explicitly overriding the ambient quality (e.g. GlassScaffold wraps bars
    //   with `defaultQuality: premium`). Without this guard, the page-level
    //   `standard` quality would short-circuit before the scope's premium hint
    //   at Step 4 can take effect.
    final scopeDefault = GlassIsolationScope.defaultQualityOf(context);
    GlassQuality? resolved;
    if (!GlassIsolationScope.isIsolated(context) && scopeDefault == null) {
      final inherited =
          context.dependOnInheritedWidgetOfExactType<InheritedLiquidGlass>();
      if (inherited != null) resolved = inherited.quality;
    }

    // Step 3: cap inherited quality by adaptive ceiling.
    if (adaptiveData != null && resolved != null) {
      resolved = _applyCeiling(resolved, adaptiveData.effectiveQuality);
    }

    if (resolved != null) return resolved;

    // Step 4: theme-level quality, capped by adaptive ceiling.
    //
    // scopeDefault was already resolved above (Step 2). GlassScaffold sets
    // `defaultQuality: premium` on bar wrappers. This ensures buttons in bars
    // default to premium without requiring explicit quality.
    // GlassAdaptiveScope ceiling still caps this on low-end devices.
    final themeData = GlassThemeData.of(context);
    GlassQuality result =
        themeData.qualityFor(context) ?? scopeDefault ?? fallback;
    if (adaptiveData != null) {
      result = _applyCeiling(result, adaptiveData.effectiveQuality);
    }

    return result;
  }

  /// Returns the lower of [quality] and [ceiling] using the correct ordinal.
  static GlassQuality _applyCeiling(
      GlassQuality quality, GlassQuality ceiling) {
    return _qualityOrdinal(quality) > _qualityOrdinal(ceiling)
        ? ceiling
        : quality;
  }

  /// Quality ordinal for comparison. Higher = better visual quality.
  ///
  /// **Must NOT use [GlassQuality.index]** — the enum declaration order is
  /// `standard=0, premium=1, minimal=2` which is non-monotonic with quality.
  static int _qualityOrdinal(GlassQuality q) {
    switch (q) {
      case GlassQuality.premium:
        return 2;
      case GlassQuality.standard:
        return 1;
      case GlassQuality.minimal:
        return 0;
    }
  }

  /// Resolves [LiquidGlassSettings] for a widget using the full priority chain.
  ///
  /// This is the theme-aware counterpart to [InheritedLiquidGlass.ofOrDefault].
  /// Unlike that method, it adds a final [GlassThemeData] fallback so that
  /// standalone widgets (not wrapped in [AdaptiveLiquidGlassLayer]) still
  /// receive a visible `glassColor` on light and dark backgrounds.
  ///
  /// **Priority chain (highest → lowest):**
  /// 1. `explicit` — the widget's own `settings:` parameter (non-null wins).
  /// 2. [InheritedLiquidGlass] — settings from nearest parent layer.
  /// 3. [LiquidGlassWidgets.globalSettings] — app-level global override.
  /// 4. [GlassThemeData] — brightness-aware theme settings (light/dark).
  /// 5. [LiquidGlassSettings] default — absolute last resort.
  ///
  /// Call sites in [GlassButton], [GlassContainer], and [GlassTextField] use
  /// this instead of `InheritedLiquidGlass.ofOrDefault()` so that a standalone
  /// `GlassButton(useOwnLayer: true)` is never invisible on a white background.
  static LiquidGlassSettings resolveSettings(
    BuildContext context, {
    LiquidGlassSettings? explicit,
    LiquidGlassSettings fallback = const LiquidGlassSettings(),
  }) {
    // 1. Widget-level explicit setting wins unconditionally.
    if (explicit != null) return explicit;

    // 2. Inherited settings from the nearest AdaptiveLiquidGlassLayer.
    final inherited = InheritedLiquidGlass.of(context);
    if (inherited != null) return inherited;

    // 3. App-level global override (set via LiquidGlassWidgets.globalSettings).
    if (LiquidGlassWidgets.globalSettings != null) {
      return LiquidGlassWidgets.globalSettings!;
    }

    // 4. Theme fallback — ensures glass is visible even when no settings are
    //    provided anywhere.  Mirrors the logic in AdaptiveLiquidGlassLayer:
    //    start from the zero-alpha default, then overlay any non-null fields
    //    from the theme's brightness-appropriate variant.
    final themeOverride = GlassThemeData.of(context).settingsFor(context);
    return themeOverride?.applyTo(fallback) ?? fallback;
  }

  /// Resolves an adaptive border radius based on the device's physical geometry.
  ///
  /// This algorithm uses [MediaQuery] safe area insets to infer the ideal
  /// corner radius, handling Dynamic Island, Notch iPhones, and Android devices
  /// without hardcoding specific model names.
  static double resolveAdaptiveRadius(BuildContext context) {
    // D2: Use scoped MediaQuery accessors instead of MediaQuery.of(context).
    // MediaQuery.of() subscribes to ALL MediaQuery changes (keyboard, status bar,
    // orientation, text scale, etc.) — causing every glass widget to rebuild when
    // the keyboard appears/dismisses. We only need viewPadding and screen height.
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottom = viewPadding.bottom;
    final top = viewPadding.top;
    final theme = GlassThemeData.of(context);
    final themeRadius = theme.borderRadiusFor(context);

    // 0. If user specified a global radius in the theme, respect it.
    if (themeRadius != null) return themeRadius;

    final platform = defaultTargetPlatform;
    final height = MediaQuery.sizeOf(context).height;
    final isIOS = platform == TargetPlatform.iOS;

    // 1. Devices with physical home buttons or desktop (no bottom safe area)
    if (bottom == 0) return 0.0;

    if (isIOS) {
      // 2. iPhone Pro Max / Plus with Dynamic Island (e.g. 15 Pro Max: height 932)
      // Height is the most reliable indicator; top padding can fluctuate.
      if (height >= 900) return 54.0;

      // 3. iPhone Pro / Base with Dynamic Island (e.g. 15 Pro: height 852)
      if (height >= 800 || top >= 54) return 46.0;

      // 4. iPhone with Notch (typically top padding between 44 and 50)
      return 46.0;
    } else {
      // 4. Android devices with gesture navigation (bottom > 0)
      // Android flags often have softer, smaller curves than Apple.
      return 28.0;
    }
  }
}
