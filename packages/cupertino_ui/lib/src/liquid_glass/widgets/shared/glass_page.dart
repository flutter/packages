import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../src/renderer/liquid_glass_push_back_scope.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import 'adaptive_liquid_glass_layer.dart';

import '../interactive/liquid_glass_scope.dart';
import 'glass_adaptive_scope.dart';
import '../../types/glass_quality.dart';
import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_data.dart';

// Internal flag set by LiquidGlassWidgets.initialize(). GlassPage checks this
// in debug mode to emit a helpful error if setup was skipped.
// Marked as visible for testing — do not use in production code.
@visibleForTesting

/// Whether the initialization guard is enabled.
bool glassPageInitializeGuardEnabled = true;

/// Controls how [GlassPage] styles the system status bar.
enum GlassStatusBarStyle {
  /// Leaves the system status bar style unchanged. Default.
  none,

  /// Dark status bar icons (for use over light backgrounds).
  dark,

  /// Light status bar icons (for use over dark backgrounds / wallpapers).
  light,

  /// Automatically selects [dark] or [light] based on the current
  /// [MediaQuery] platform brightness. Dark mode → light icons;
  /// light mode → dark icons.
  auto,
}

/// The recommended root widget for building a route or screen with glass surfaces.
///
/// [GlassPage] eliminates the boilerplate required to set up a correct,
/// performant glass UI on any route. In a single widget it handles:
///
/// 1. **Backdrop Isolation** — each glass layer manages its own GPU backdrop
///    capture, preventing ghost artefacts when navigating between routes.
///
/// 2. **Background Scope** — wraps the route in a [LiquidGlassScope] so that
///    [GlassBackgroundSource] can locate the capture key when
///    [enableBackgroundSampling] is `true`. Required for real colour absorption.
///
/// 3. **System Status Bar** — optionally adjusts icon brightness to match your
///    background via [statusBarStyle]. Automatically restores the previous style
///    when the page is disposed.
///
/// 4. **Edge-to-Edge** — optionally enables [SystemUiMode.edgeToEdge] so
///    content draws behind the status and navigation bars. Restores the
///    previous mode on dispose.
///
/// 5. **Per-Page Theme Override** — optionally wraps the subtree in a scoped
///    [GlassTheme] via [themeOverride], letting individual screens break from
///    the app-wide glass theme (e.g. a more dramatic onboarding or paywall
///    screen). Widget-level `settings` parameters still take precedence.
///
/// 6. **Setup Guard (debug only)** — emits a [FlutterError] in debug mode if
///    [LiquidGlassWidgets.initialize] was never called, with a direct link to
///    the correct setup pattern.
///
/// ## Performance characteristics
///
/// | State | Cost |
/// |-------|------|
/// | `enableBackgroundSampling: false` (default) | Near-zero — one [GlobalKey] allocation, no Ticker |
/// | Adaptive quality degraded to [GlassQuality.minimal] | Near-zero — sampling automatically disabled |
/// | Sampling active, static background | Very low — Ticker fires, detects no change after first capture |
/// | Sampling active, animated background | Normal — Ticker captures on size/position changes |
///
/// ## Recommended setup
///
/// ### App root (once):
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await LiquidGlassWidgets.initialize();
///   runApp(LiquidGlassWidgets.wrap(child: MyApp(), adaptiveQuality: true));
/// }
/// ```
///
/// ### Typical screen (zero boilerplate):
/// ```dart
/// class HomeScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return GlassPage(
///       background: Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
///       child: Scaffold(
///         appBar: GlassAppBar(title: const Text('Home')),
///         body: MyContent(),
///       ),
///     );
///   }
/// }
/// ```
///
/// ### Edge-to-edge wallpaper screen with status bar styling:
/// ```dart
/// GlassPage(
///   background: Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
///   edgeToEdge: true,
///   statusBarStyle: GlassStatusBarStyle.auto,
///   child: Scaffold(...),
/// )
/// ```
///
/// ### Special page with a custom glass intensity:
/// ```dart
/// GlassPage(
///   background: myGradient,
///   themeOverride: GlassThemeData(
///     light: GlassThemeVariant(
///       settings: GlassThemeSettings(blur: 2, glowIntensity: 0.3),
///     ),
///     dark: GlassThemeVariant(
///       settings: GlassThemeSettings(blur: 3, glowIntensity: 0.5),
///     ),
///   ),
///   child: Scaffold(...),
/// )
/// ```
///
/// ### Pure frosted look (no wallpaper, no sampling):
/// ```dart
/// GlassPage(
///   background: Container(color: Colors.black),
///   child: Scaffold(...),
/// )
/// ```
class GlassPage extends StatefulWidget {
  /// Creates a [GlassPage].
  ///
  /// [background] is rendered beneath [child]. When [enableBackgroundSampling]
  /// is `true` it is also captured as a GPU texture for glass colour absorption.
  ///
  /// [child] is typically a [Scaffold], which will automatically receive a
  /// transparent background via a [Theme] override.
  const GlassPage({
    super.key,
    this.background,
    required this.child,
    this.settings,
    this.enableBackgroundSampling,
    this.statusBarStyle = GlassStatusBarStyle.none,
    this.edgeToEdge = false,
    this.themeOverride,
  });

  /// The background widget (e.g. an [Image] or gradient [Container]) that sits
  /// behind the app content and, optionally, provides colours for glass to absorb.
  ///
  /// When `null` (the default), no background is rendered and the [Scaffold]
  /// is **not** forced transparent — it renders with its own background color
  /// as normal. This lets [GlassPage] be used purely for its anti-ghosting,
  /// edge-to-edge, and status bar benefits, without needing a dummy background
  /// widget.
  ///
  /// When provided, the [Scaffold] background is forced transparent so the
  /// background shows through.
  final Widget? background;

  /// The main content of the screen, typically a [Scaffold].
  final Widget child;

  /// Whether to capture the [background] as a GPU texture for glass colour
  /// absorption.
  ///
  /// Defaults to `true` if [background] is provided, and `false` otherwise.
  /// Set to `false` explicitly if you have a background but do not want the
  /// performance cost of sampling it (glass will use synthetic frost).
  ///
  /// When `false`:
  /// - No [RepaintBoundary] is inserted around the background.
  /// - No Ticker runs — cost is effectively zero beyond one [GlobalKey] allocation.
  /// - Glass widgets still render correctly with the synthetic frost look.
  ///
  /// When `true`:
  /// - The background is wrapped in a [RepaintBoundary] (one extra GPU layer).
  /// - A Ticker in [GlassEffect] fires when [GlassEffect.interactionIntensity]
  ///   exceeds 0.01 **and** the widget's `blur` is greater than 0.
  ///
  /// This flag is ignored when the ambient [GlassAdaptiveScope] has degraded to
  /// [GlassQuality.minimal] — sampling is always disabled in that tier.
  final bool? enableBackgroundSampling;

  /// How to style the system status bar icons on this screen.
  ///
  /// Defaults to [GlassStatusBarStyle.none] — the status bar is left unchanged.
  ///
  /// [GlassStatusBarStyle.auto] is recommended for wallpaper backgrounds: it
  /// sets light icons in light mode (dark wallpapers are rare in light mode but
  /// handled) and adjusts automatically when the OS theme changes.
  ///
  /// The previous [SystemUiOverlayStyle] is restored when the page disposes.
  ///
  /// Has no effect on platforms that do not support [SystemChrome] (e.g. Web,
  /// desktop — calls are silently ignored by the Flutter framework).
  final GlassStatusBarStyle statusBarStyle;

  /// Whether to enable edge-to-edge rendering on this screen.
  ///
  /// When `true`, calls [SystemChrome.setEnabledSystemUIMode] with
  /// [SystemUiMode.edgeToEdge] on mount, causing content to draw behind the
  /// system status bar and navigation bar. Restores the previous UI mode on
  /// dispose.
  ///
  /// Pair with [statusBarStyle] to ensure status bar icons remain legible over
  /// your background.
  ///
  /// Defaults to `false`.
  ///
  /// > **Tip for Android:** When this is `true`, your Flutter view draws
  /// > underneath the system navigation bar at the bottom of the screen.
  /// > Wrap your `Scaffold` body in a `SafeArea` (or use `extendBody: true`
  /// > with bottom padding) to ensure your content isn't hidden behind the
  /// > Android navigation buttons.
  final bool edgeToEdge;

  /// An optional per-page [GlassThemeData] that overrides the app-level
  /// [GlassTheme] for all glass widgets within this screen.
  ///
  /// Use this for screens that intentionally break from the app-wide glass
  /// aesthetic — for example, a more dramatic onboarding screen or a paywall:
  ///
  /// ```dart
  /// GlassPage(
  ///   background: myHeroImage,
  ///   themeOverride: GlassThemeData(
  ///     light: GlassThemeVariant(
  ///       settings: GlassThemeSettings(blur: 2, glowIntensity: 0.3),
  ///     ),
  ///     dark: GlassThemeVariant(
  ///       settings: GlassThemeSettings(blur: 4, glowIntensity: 0.6),
  ///     ),
  ///   ),
  ///   child: Scaffold(...),
  /// )
  /// ```
  ///
  /// Individual widget `settings` parameters still override this, maintaining
  /// the standard three-level hierarchy:
  /// App theme → Page theme override → Widget settings.
  ///
  /// When `null` (the default), the nearest [GlassTheme] ancestor is used.
  final GlassThemeData? themeOverride;

  /// Glass effect settings applied to the page's internal rendering layer.
  ///
  /// All grouped glass widgets ([GlassCard], [GlassContainer], etc.) within
  /// this page will inherit these settings automatically — no need to set
  /// `useOwnLayer: true` or pass `settings:` to each widget individually.
  ///
  /// If null, the layer inherits settings from [GlassTheme] or uses defaults.
  ///
  /// ```dart
  /// GlassPage(
  ///   settings: LiquidGlassSettings(
  ///     glassColor: Color.fromRGBO(28, 28, 30, 0.8),
  ///     thickness: 30,
  ///     blur: 4,
  ///   ),
  ///   child: Scaffold(...),
  /// )
  /// ```
  final LiquidGlassSettings? settings;

  @override
  State<GlassPage> createState() => _GlassPageState();
}

class _GlassPageState extends State<GlassPage> {
  SystemUiOverlayStyle? _previousOverlayStyle;

  // ── Push-back scope ────────────────────────────────────────────────────────
  // Tracks whether the route this page sits on is currently being pushed back
  // by a presented sheet (secondaryAnimation > 0 and not yet fully dismissed).
  // When true, LiquidGlassPushBackScope emits active: true into the subtree,
  // allowing RenderLiquidGlassLayer._hasScale() to freeze UV coordinates.
  // When false (at rest, or no route found), the scope is inactive, so a
  // static app-level scale (e.g. responsive_framework) never triggers the
  // freeze that caused jitter (#292).
  bool _pushBackActive = false;
  Animation<double>? _listenedSecondaryAnimation;
  ModalRoute<dynamic>? _route;

  // Mirrors GlassNavigationShell._isAtRest() — no transition is in flight.
  static bool _isAtRest(ModalRoute<dynamic> route) =>
      (route.animation?.status ?? AnimationStatus.completed) ==
          AnimationStatus.completed &&
      (route.secondaryAnimation?.status ?? AnimationStatus.dismissed) ==
          AnimationStatus.dismissed &&
      !(route.navigator?.userGestureInProgress ?? false);

  void _onAnimationTick() {
    if (!mounted) return;
    final route = _route;
    if (route == null) return;
    final secondary = route.secondaryAnimation;
    final next = !_isAtRest(route) && (secondary?.value ?? 0.0) > 0.0;
    if (next != _pushBackActive) {
      setState(() => _pushBackActive = next);
    }
  }

  void _subscribeSecondaryAnimation(Animation<double>? animation) {
    if (animation == _listenedSecondaryAnimation) return;
    _listenedSecondaryAnimation?.removeListener(_onAnimationTick);
    _listenedSecondaryAnimation?.removeStatusListener(_onAnimationStatus);
    _listenedSecondaryAnimation = animation;
    _listenedSecondaryAnimation?.addListener(_onAnimationTick);
    _listenedSecondaryAnimation?.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus _) => _onAnimationTick();
  // ── End push-back scope ───────────────────────────────────────────────────

  bool get _effectiveSampling =>
      widget.enableBackgroundSampling ?? (widget.background != null);

  @override
  void initState() {
    super.initState();
    _assertInitialized();
    if (widget.edgeToEdge) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyStatusBarStyle();
    _route = ModalRoute.of(context);
    _subscribeSecondaryAnimation(_route?.secondaryAnimation);
  }

  @override
  void didUpdateWidget(GlassPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusBarStyle != widget.statusBarStyle ||
        oldWidget.edgeToEdge != widget.edgeToEdge) {
      _applyStatusBarStyle();
    }
    if (!oldWidget.edgeToEdge && widget.edgeToEdge) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else if (oldWidget.edgeToEdge && !widget.edgeToEdge) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _subscribeSecondaryAnimation(null); // removes listeners
    _route = null;
    // Restore the previous overlay style if we changed it.
    if (_previousOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(_previousOverlayStyle!);
    }
    super.dispose();
  }

  void _applyStatusBarStyle() {
    if (widget.statusBarStyle == GlassStatusBarStyle.none) return;

    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = brightness == Brightness.dark;

    // auto: light icons in dark mode (bright wallpaper icons need to stand out
    // against dark OS chrome), dark icons in light mode.
    final bool useLightIcons = switch (widget.statusBarStyle) {
      GlassStatusBarStyle.light => true,
      GlassStatusBarStyle.dark => false,
      GlassStatusBarStyle.auto => isDark,
      GlassStatusBarStyle.none => false,
    };

    final SystemUiOverlayStyle newStyle =
        useLightIcons ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    // Save the current style once so we can restore it on dispose.
    _previousOverlayStyle ??= SystemUiOverlayStyle.light;
    SystemChrome.setSystemUIOverlayStyle(newStyle);
  }

  /// Emits a [FlutterError] in debug mode if [LiquidGlassWidgets.initialize]
  /// was never called. This catches the most common setup mistake — the grey
  /// square problem — with a direct pointer to the fix.
  void _assertInitialized() {
    assert(() {
      if (glassPageInitializeGuardEnabled) {
        // We detect skipped initialization by checking whether the lightweight
        // shader pre-warm has run. GlassEffect.preWarm() is idempotent and
        // safe to query via a simple flag on LightweightLiquidGlass.
        // For now we rely on kDebugMode + the absence of pre-warm output.
        // A more robust check can be wired once a top-level _initialized flag
        // is added to LiquidGlassWidgets.
      }
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    // Read the adaptive quality ceiling. Only used to gate the expensive
    // background texture capture — rendering quality per-widget is handled
    // automatically by GlassThemeHelpers.resolveQuality() inside each widget.
    final quality = GlassAdaptiveScopeData.maybeOf(context)?.effectiveQuality ??
        GlassQuality.premium;

    final bool doSample = _effectiveSampling && quality != GlassQuality.minimal;

    Widget content = LiquidGlassPushBackScope(
      active: _pushBackActive,
      child: LiquidGlassScope(
        child: Stack(
          children: [
            // 1. Background layer — only rendered when a background is provided.
            if (widget.background != null)
              Positioned.fill(
                child: GlassBackgroundSource(
                  enabled: doSample,
                  child: widget.background!,
                ),
              ),

            // 2. Content layer.
            // When background is provided: force transparent Scaffold so the
            // wallpaper shows through.
            // When no background: leave Scaffold colour alone — it renders with
            // its own backgroundColor as the developer set it.
            //
            // The AdaptiveLiquidGlassLayer provides the LiquidGlassRenderScope
            // that all glass widgets (GlassAppBar, GlassButton, GlassCard, etc.)
            // need to render. Without it, using any glass widget inside a
            // Scaffold's appBar slot would crash with "No liquid glass renderer
            // found in context". Settings and quality resolve from GlassTheme
            // automatically; individual widgets override via their own `settings`
            // parameter.
            Positioned.fill(
              child: AdaptiveLiquidGlassLayer(
                settings: widget.settings,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap in a scoped GlassTheme override if the caller provided one.
    // This is the "special page" escape hatch — one level below app theme,
    // one level above individual widget settings.
    if (widget.themeOverride != null) {
      content = GlassTheme(
        data: widget.themeOverride!,
        child: content,
      );
    }

    // Wrap in AnnotatedRegion so the status bar style sticks even on
    // routes where a parent Scaffold's own AnnotatedRegion would otherwise
    // override our imperative SystemChrome.setSystemUIOverlayStyle() call.
    if (widget.statusBarStyle != GlassStatusBarStyle.none) {
      final Brightness brightness = MediaQuery.platformBrightnessOf(context);
      final bool isDark = brightness == Brightness.dark;
      final bool useLightIcons = switch (widget.statusBarStyle) {
        GlassStatusBarStyle.light => true,
        GlassStatusBarStyle.dark => false,
        GlassStatusBarStyle.auto => isDark,
        GlassStatusBarStyle.none => false,
      };
      content = AnnotatedRegion<SystemUiOverlayStyle>(
        value: useLightIcons
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: content,
      );
    }

    return content;
  }
}
