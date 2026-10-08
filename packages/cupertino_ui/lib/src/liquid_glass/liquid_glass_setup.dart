import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'theme/glass_theme.dart';
import 'theme/glass_theme_data.dart';
import 'types/glass_quality.dart';
import 'utils/accessibility_config.dart' as glass_config;
import 'utils/glass_brightness.dart' show glassExternalBrightnessResolver;
import 'utils/glass_performance_monitor.dart';
import 'src/renderer/liquid_glass_renderer.dart';
import 'src/engine/shaders.dart';

import 'src/engine/multi_shader_builder.dart';
import 'widgets/shared/glass_adaptive_scope.dart';
import 'widgets/shared/glass_effect.dart';
import 'widgets/shared/glass_accessibility_scope.dart';
import 'widgets/shared/lightweight_liquid_glass.dart';
import 'widgets/effects/progressive_blur.dart';

/// Entry point and configuration for the Liquid Glass Widgets library.
///
/// ## Setup
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await LiquidGlassWidgets.initialize(); // pre-warms shaders
///
///   runApp(LiquidGlassWidgets.wrap(
///     child: const MyApp(),
///     adaptiveQuality: true,
///     theme: GlassThemeData(
///       light: GlassThemeVariant(settings: GlassThemeSettings(blur: 10)),
///       dark:  GlassThemeVariant(settings: GlassThemeSettings(blur: 14)),
///     ),
///   ));
/// }
/// ```
class LiquidGlassWidgets {
  LiquidGlassWidgets._();

  // ── Global accessors ───────────────────────────────────────────────────────

  /// Whether glass widgets automatically respect system accessibility settings
  /// (Reduce Motion, Reduce Transparency / High Contrast).
  ///
  /// Set via [wrap]. Defaults to `true`. Read by glass widgets at build time
  /// via [GlassAccessibilityScope] or a direct [MediaQuery] fallback.
  ///
  /// The setter is provided as an escape hatch for tests and advanced runtime
  /// overrides. In production code, prefer setting this through [wrap].
  static bool get respectSystemAccessibility =>
      glass_config.respectSystemAccessibility;
  static set respectSystemAccessibility(bool value) =>
      glass_config.respectSystemAccessibility = value;

  /// Global [LiquidGlassSettings] override for the entire application.
  ///
  /// When set, these settings are used as the base for all glass widgets
  /// unless overridden at the widget or layer level.
  static LiquidGlassSettings? globalSettings;

  // ── initialize() ───────────────────────────────────────────────────────────

  /// Initializes platform-level resources for the Liquid Glass library.
  ///
  /// **Responsibility**: async platform / engine setup only. Call once in
  /// `main()` before [runApp]. All behavioral configuration belongs in [wrap].
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await LiquidGlassWidgets.initialize();
  ///   runApp(LiquidGlassWidgets.wrap(const MyApp()));
  /// }
  /// ```
  ///
  /// ### Parameters
  ///
  /// **`enablePerformanceMonitor`** (default `true`)\
  /// In debug and profile builds, the library registers a
  /// `SchedulerBinding.addTimingsCallback` that watches raster durations while
  /// [GlassQuality.premium] surfaces are mounted. When frames consistently
  /// exceed the GPU budget, a single [FlutterError] is emitted with actionable
  /// guidance. The monitor is **automatically disabled in release builds** —
  /// zero overhead in shipped apps. Set to `false` to suppress it during
  /// profiling sessions where the warning would be a false positive.
  ///
  /// ### Tasks performed
  ///
  /// 1. Pre-warms / precaches the lightweight fragment shader.
  /// 2. Pre-warms the interactive indicator shader (custom refraction).
  /// 3. Pre-warms the Impeller rendering pipeline (iOS / Android / macOS).
  /// 4. Optionally registers the debug performance monitor.
  ///
  /// ### Shaders pre-warmed
  ///
  /// | Shader | Role |
  /// |---|---|
  /// | `lightweight_glass.frag` | Minimal glass layer |
  /// | `interactive_indicator.frag` | Custom refraction effect |
  /// | `liquid_glass_geometry_blended.frag` | Geometry / SDF pass |
  /// | `liquid_glass_render.frag` | Final composite pass |
  /// Controls shader preloading and warm-up behaviour during [initialize].
  static Future<void> initialize({
    bool enablePerformanceMonitor = true,
    GlassWarmUpMode warmUpMode = GlassWarmUpMode.auto,
  }) async {
    debugPrint('[LiquidGlass] Initializing library...');

    // 1. Pre-warm shader programs in parallel — fast, async disk I/O only.
    // Loads FragmentProgram objects into RAM so widgets render without
    // placeholder frames / white flash.
    final precacheFutures = <Future<void>>[
      LightweightLiquidGlass.preWarm(),
      GlassEffect.preWarm(),
      ProgressiveBlur.preload(),
    ];

    // On platforms that support premium glass rendering (iOS Metal, macOS Metal,
    // Android Vulkan/GLES), preload the multi-pass shaders as well.
    // Web, Windows, and Linux skip premium preload by default as they are
    // capped at standard quality by the GlassAdaptiveScope static probe.
    final bool shouldPreloadPremium = warmUpMode == GlassWarmUpMode.always ||
        (warmUpMode == GlassWarmUpMode.auto && !_shouldSkipPremiumPreload());

    if (shouldPreloadPremium) {
      precacheFutures.add(
        MultiShaderBuilder.precacheShaders([
          ShaderKeys.blendedGeometry,
          ShaderKeys.liquidGlassRender,
        ]),
      );
    }

    await Future.wait(precacheFutures);

    // 2. Register the debug performance monitor (no-op in release builds).
    if (enablePerformanceMonitor && !kReleaseMode) {
      GlassPerformanceMonitor.start();
    }

    debugPrint('[LiquidGlass] Initialization complete.');
  }

  /// Returns `true` if the current platform is statically capped at standard
  /// quality by [GlassAdaptiveScope] and does not need multi-pass premium shaders
  /// preloaded during startup.
  static bool _shouldSkipPremiumPreload() {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.windows) return true;
    if (defaultTargetPlatform == TargetPlatform.linux) return true;
    return false;
  }

  // ── wrap() ─────────────────────────────────────────────────────────────────

  /// Wraps [child] in the Liquid Glass infrastructure scopes and applies all
  /// behavioral configuration.
  ///
  /// **Responsibility**: widget-tree composition and runtime behavior. All
  /// configuration that affects how glass widgets behave lives here — explicit,
  /// visible, and co-located with the widget tree entry point.
  ///
  /// **Optional** — provides app-wide theming and adaptive quality.
  /// `GlassBackdropScope` is no longer needed (each glass layer manages its own
  /// backdrop); `wrap()` is only required if you use `theme:` or
  /// `adaptiveQuality:`.
  ///
  /// ```dart
  /// // Zero-config (most apps):
  /// runApp(LiquidGlassWidgets.wrap(const MyApp()));
  ///
  /// // Recommended for Android / broad device support:
  /// runApp(LiquidGlassWidgets.wrap(
  ///   child: const MyApp(),
  ///   adaptiveQuality: true,
  ///   theme: GlassThemeData(...),
  /// ));
  ///
  /// // Game / experience — bypass accessibility, conservative quality start:
  /// runApp(LiquidGlassWidgets.wrap(
  ///   child: const MyApp(),
  ///   respectSystemAccessibility: false,
  ///   adaptiveQuality: true,
  ///   adaptiveConfig: GlassAdaptiveScopeConfig(
  ///     initialQuality: GlassQuality.standard,
  ///     allowStepUp: true,
  ///   ),
  /// ));
  /// ```
  ///
  /// ### Parameters
  ///
  /// **`respectSystemAccessibility`** (default `true`)\
  /// When `true`, system Reduce Motion and Reduce Transparency flags are
  /// respected automatically — no extra setup required. All glass widgets read
  /// `MediaQuery` directly and degrade gracefully. Set to `false` to ignore
  /// system accessibility flags globally (e.g. for a game where full glass
  /// fidelity is intentional regardless of OS settings). A
  /// [GlassAccessibilityScope] placed anywhere in the widget tree always takes
  /// precedence over this flag, allowing per-subtree overrides.
  ///
  /// **`adaptiveQuality`** (default `false`, **experimental**)\
  /// When `true`, inserts a root [GlassAdaptiveScope] that automatically
  /// benchmarks the device and adjusts the global glass quality ceiling in real
  /// time. Three phases:
  ///
  /// - **Phase 1** (synchronous): forces `minimal` where shaders are
  ///   unsupported; caps at `standard` on web.
  /// - **Phase 2** (~180 frames ≈ 3 s at 60 fps): measures real P75 raster
  ///   durations and sets the initial quality tier.
  /// - **Phase 3** (ongoing, near-zero overhead): degrades when P95 exceeds
  ///   1.5× the frame budget for 3 consecutive windows; recovers when P95
  ///   drops below 0.6× budget for 10 consecutive windows.
  ///
  /// **Experimental in 0.8.0** — Phase 2 thresholds (12 ms / 20 ms P75) are
  /// based on reasoning, not yet validated across the full Android device
  /// landscape. Enable this feature and report unexpected quality degradation
  /// or promotion to help us tune the thresholds.
  ///
  /// Acts as an app-wide *quality ceiling* — individual widgets with an
  /// explicit `quality:` parameter are still capped by it. When no
  /// [adaptiveConfig] is provided, the scope starts at [GlassQuality.standard]
  /// to prevent jank during the warm-up window on mid-range devices.
  ///
  /// For per-screen control, use [GlassAdaptiveScope] directly in the tree.

  ///
  /// **`adaptiveConfig`** (optional)\
  /// Custom [GlassAdaptiveScopeConfig] for the root [GlassAdaptiveScope].
  /// Ignored when [adaptiveQuality] is `false`. Defaults to
  /// `GlassAdaptiveScopeConfig(initialQuality: GlassQuality.standard)`.
  ///
  /// ### Scope nesting order (outermost → innermost → child)
  ///
  /// `GlassAdaptiveScope` (when enabled) → `GlassTheme` (when provided) → `child`
  static Widget wrap({
    required Widget child,
    GlassThemeData? theme,
    bool respectSystemAccessibility = true,
    bool adaptiveQuality = false,
    GlassAdaptiveScopeConfig? adaptiveConfig,

    /// Optional brightness resolver for MaterialApp integration.
    ///
    /// When using `MaterialApp`, pass `Theme.maybeBrightnessOf` here so glass
    /// widgets correctly honour `ThemeMode.light` / `.dark` / `.system` even
    /// when the device OS and the app theme disagree:
    ///
    /// ```dart
    /// runApp(LiquidGlassWidgets.wrap(
    ///   child: const MyApp(),
    ///   brightnessResolver: Theme.maybeBrightnessOf,
    /// ));
    /// ```
    ///
    /// This package has zero `flutter/material.dart` imports (required for the
    /// `cupertino_ui` split). The callback pattern lets you bridge Material's
    /// `ThemeMode` into the glass brightness cascade without coupling the
    /// package to Material. `CupertinoApp` users can omit this parameter.
    Brightness? Function(BuildContext)? brightnessResolver,
  }) {
    // Apply global accessibility preference.
    glass_config.respectSystemAccessibility = respectSystemAccessibility;

    // Register the optional Material brightness resolver.
    // This lets MaterialApp users pass Theme.maybeBrightnessOf without this
    // package needing to import flutter/material.dart.
    glassExternalBrightnessResolver = brightnessResolver;

    Widget result = child;

    if (theme != null) {
      result = GlassTheme(data: theme, child: result);
    }

    if (adaptiveQuality) {
      // When no adaptiveConfig is given: GlassAdaptiveScope.initState() seeds
      // the first frame at GlassQuality.standard while Phase 2 benchmarks the
      // device (~3 s). Phase 2 then promotes to `premium` if the device passes
      // the warmup threshold — no caller config needed.
      //
      // When the caller provides adaptiveConfig: use their settings as-is.
      // If initialQuality is null, Phase 2 still runs fresh and promotes/demotes
      // from the conservative standard starting point.
      final config = adaptiveConfig ?? const GlassAdaptiveScopeConfig();

      result = GlassAdaptiveScope(
        minQuality: config.minQuality,
        maxQuality: config.maxQuality,
        initialQuality: config.initialQuality,
        targetFrameMs: config.targetFrameMs,
        allowStepUp: config.allowStepUp,
        warmupPremiumThresholdMs: config.warmupPremiumThresholdMs,
        warmupStandardThresholdMs: config.warmupStandardThresholdMs,
        frostStep: config.frostStep,
        onQualityChanged: config.onQualityChanged,
        onDiagnostic: config.onDiagnostic,
        debugLogDiagnostics: config.debugLogDiagnostics,
        child: result,
      );
    }

    return result;
  }

  // ── Private helpers ────────────────────────────────────────────────────────
}

/// Controls shader preloading and warm-up behaviour during [LiquidGlassWidgets.initialize].
enum GlassWarmUpMode {
  /// Automatic selection: preloads all shaders on iOS, macOS, and Android (including Vulkan),
  /// while skipping unused premium multi-pass shaders on Web, Windows, and Linux
  /// where quality is statically capped at standard.
  auto,

  /// Force preloading of all shaders on all platforms.
  always,

  /// Skip preloading heavy multi-pass shaders, loading them on demand when rendered.
  never,
}
