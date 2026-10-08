import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_data.dart';

/// Signature for [GlassContentAwareBrightness.builder].
///
/// [brightness] is the committed content-aware verdict for the control.
/// [darkAmount] is the animated cross-fade position between the light (0.0)
/// and dark (1.0) appearance — it eases toward `brightness` over the flip
/// duration, so consumers can interpolate their own colors during the
/// transition.
typedef GlassBrightnessWidgetBuilder = Widget Function(
  BuildContext context,
  Brightness brightness,
  double darkAmount,
);

/// Drives iOS 26-style content-aware light/dark adaptation for glass
/// controls floating over scrolling content.
///
/// iOS 26 bars and controls watch the content scrolling underneath them and
/// flip between their light and dark appearance so the glyphs always keep
/// contrast — light controls over bright photos, dark controls over a dark
/// album cover. This scope productizes that behavior:
///
/// 1. Wrap the screen (typically the `Scaffold`) in a
///    [GlassContentAwareScope].
/// 2. Wrap the **scrolling content** — not the bars — in a
///    [GlassContentAwareContent]. This marks the region that is sampled.
///    The glass controls themselves must stay outside of it so the capture
///    sees the content *behind* them rather than their own rendering.
/// 3. Set `adaptiveBrightness: true` on `GlassTabBar.bottom` /
///    `GlassTabBar.searchable` (or wrap any custom control in a
///    [GlassContentAwareBrightness]).
///
/// ```dart
/// GlassContentAwareScope(
///   child: Scaffold(
///     extendBody: true, // content scrolls underneath the bar
///     body: GlassContentAwareContent(
///       child: ListView(...),
///     ),
///     bottomNavigationBar: GlassTabBar.bottom(
///       adaptiveBrightness: true,
///       ...
///     ),
///   ),
/// )
/// ```
///
/// The same wiring applies with [GlassScaffold]: wrap the scaffold in the
/// scope and the scrolling content inside `body` in a
/// [GlassContentAwareContent]. The scroll-edge fade that [GlassScaffold]
/// renders sits outside the captured region, so it never feeds back into
/// the vote.
///
/// ## How the verdict is decided
///
/// The scope captures the content boundary **once** per sample (a heavily
/// downscaled, asynchronous `toImage` readback) and serves every registered
/// control from that single capture. Each control's own rectangle is mapped
/// into the captured image, divided into a small grid of cells, and each
/// cell casts a vote: *which glyph color reads better over this content —
/// the light variant's dark glyphs, or the dark variant's light glyphs?*
/// The comparison uses WCAG contrast ratios, so the verdict is a **contrast
/// vote, not a luminance threshold**: dark glyphs hold contrast over light
/// *and* medium content, which keeps controls in their light appearance
/// through the medium range and only flips them when the content is
/// genuinely dark — matching the native behavior and resisting mode-flapping
/// on mixed content such as photo grids.
///
/// On top of the vote, two flap-prevention layers are applied per control:
///
/// - **Sticky ties** — a tied or sub-threshold vote keeps the current
///   appearance.
/// - **Dual-threshold hysteresis** — flipping light → dark requires the dark
///   vote fraction to reach [lightToDarkThreshold], while flipping back
///   requires the light fraction to reach [darkToLightThreshold]. Content
///   sitting right at the boundary therefore cannot oscillate.
///
/// ## Sampling cost
///
/// Sampling is scroll-aware: a [ScrollNotification] listener inside the
/// scope starts a periodic sampler (every [sampleInterval]) when scrolling
/// begins and stops it when scrolling ends, with one trailing sample to
/// capture the settled state. While nothing moves, the sample rate is zero.
/// The capture itself is downscaled to roughly 16 physical pixels per grid
/// cell, so the readback is a few kilobytes regardless of screen size.
///
/// Because the automatic triggers are scroll-driven, content that changes
/// **without** emitting scroll notifications — pan/zoom viewers such as
/// [InteractiveViewer], asynchronously decoded images, programmatic
/// restyles — should request a sample explicitly when it settles:
///
/// ```dart
/// GlassContentAwareScope.maybeOf(context)?.requestSample();
/// ```
///
/// ## Known limit: PlatformViews
///
/// Content rendered by an iOS PlatformView (e.g. a map) cannot be captured
/// by `toImage` — the same wall as `platformViewBackdrop`. For those
/// screens, drive the appearance explicitly with
/// `GlassTabBar.bottom.brightnessOverride` (which bypasses the sampler
/// entirely) keyed off your own signal, such as the active map style.
///
/// See also:
///
/// * [GlassContentAwareContent], which marks the sampled region.
/// * [GlassContentAwareBrightness], the per-control consumer used by the
///   bars and available to custom controls.
class GlassContentAwareScope extends StatefulWidget {
  /// Creates a content-aware brightness scope.
  const GlassContentAwareScope({
    required this.child,
    this.sampleInterval = const Duration(milliseconds: 180),
    this.flipDuration = const Duration(milliseconds: 200),
    this.flipCurve = Curves.easeInOut,
    this.lightToDarkThreshold = 0.6,
    this.darkToLightThreshold = 0.6,
    this.backgroundColor,
    super.key,
  })  : assert(
          lightToDarkThreshold >= 0.5 && lightToDarkThreshold <= 1.0,
          'lightToDarkThreshold must be within [0.5, 1.0]',
        ),
        assert(
          darkToLightThreshold >= 0.5 && darkToLightThreshold <= 1.0,
          'darkToLightThreshold must be within [0.5, 1.0]',
        );

  /// The subtree containing both the sampled content and the adaptive
  /// controls.
  final Widget child;

  /// Minimum interval between samples while scrolling is active.
  ///
  /// Scrolling starts a periodic sampler at this rate; when scrolling ends
  /// the sampler stops (after one trailing sample), so idle screens cost
  /// nothing. Defaults to 180 ms — roughly 5 samples per second during an
  /// active scroll, which tracks content changes without competing with
  /// frame production.
  final Duration sampleInterval;

  /// Duration of the light ⇄ dark cross-fade when a control flips.
  ///
  /// Applied by every [GlassContentAwareBrightness] registered in this
  /// scope. Defaults to 200 ms, matching the iOS 26 appearance transition.
  final Duration flipDuration;

  /// Curve of the light ⇄ dark cross-fade when a control flips.
  final Curve flipCurve;

  /// Vote fraction required to flip a control from light to dark.
  ///
  /// A control in its light appearance flips dark only when at least this
  /// fraction of its grid cells vote for light glyphs (dark appearance).
  /// Together with [darkToLightThreshold] this forms a hysteresis band:
  /// content sitting right at the contrast boundary cannot flap the control
  /// back and forth. Must be within `[0.5, 1.0]`; defaults to 0.6.
  final double lightToDarkThreshold;

  /// Vote fraction required to flip a control from dark back to light.
  ///
  /// The counterpart to [lightToDarkThreshold]. Must be within
  /// `[0.5, 1.0]`; defaults to 0.6.
  final double darkToLightThreshold;

  /// Color substituted for fully transparent pixels in the capture.
  ///
  /// The content boundary may not paint every pixel (e.g. a transparent
  /// scaffold background). Transparent pixels are evaluated as this color so
  /// the vote reflects what the user actually sees behind the control. When
  /// null, defaults to white in light mode and black in dark mode.
  final Color? backgroundColor;

  /// The [GlassContentAwareScopeState] from the closest enclosing scope, or
  /// null if there is none.
  ///
  /// Used by [GlassContentAwareBrightness] (and available to custom
  /// controls) to register for verdicts.
  static GlassContentAwareScopeState? maybeOf(BuildContext context) {
    final marker =
        context.dependOnInheritedWidgetOfExactType<_ContentAwareScopeMarker>();
    return marker?.state;
  }

  /// Decides a control's [Brightness] from a raw RGBA capture.
  ///
  /// Exposed for tests; production code goes through the sampling pipeline.
  /// [cellRects] are the control's grid cells in pixel coordinates of the
  /// [width]×[height] image. Each cell votes via WCAG contrast (light
  /// variant's dark glyphs vs dark variant's light glyphs over the cell's
  /// average color, with [background] substituted for transparent pixels);
  /// the verdict applies sticky ties and the dual-threshold hysteresis
  /// described on [GlassContentAwareScope].
  @visibleForTesting
  static Brightness computeVerdict({
    required Uint8List rgba,
    required int width,
    required int height,
    required List<Rect> cellRects,
    required Brightness current,
    required double lightToDarkThreshold,
    required double darkToLightThreshold,
    required Color background,
  }) {
    if (width <= 0 || height <= 0) return current;
    var votesLight = 0;
    var votesDark = 0;
    for (final r in cellRects) {
      final x0 = r.left.floor().clamp(0, width - 1);
      final x1 = r.right.ceil().clamp(x0 + 1, width);
      final y0 = r.top.floor().clamp(0, height - 1);
      final y1 = r.bottom.ceil().clamp(y0 + 1, height);
      var sumR = 0.0, sumG = 0.0, sumB = 0.0;
      var n = 0;
      for (var y = y0; y < y1; y++) {
        for (var x = x0; x < x1; x++) {
          final i = (y * width + x) * 4;
          final a = rgba[i + 3] / 255.0;
          if (a < 0.02) {
            // Unpainted pixel — evaluate as the page background.
            sumR += background.r;
            sumG += background.g;
            sumB += background.b;
          } else {
            sumR += rgba[i] / 255.0;
            sumG += rgba[i + 1] / 255.0;
            sumB += rgba[i + 2] / 255.0;
          }
          n++;
        }
      }
      if (n == 0) continue;
      final cellLuma = _wcagLuma(sumR / n, sumG / n, sumB / n);
      // Which glyph reads better over this cell? The light variant uses dark
      // glyphs, the dark variant uses light glyphs. Dark glyphs hold
      // contrast over light AND medium content; light glyphs only win once
      // the content is genuinely dark — so the vote keeps controls light
      // through the medium range and flips late, like the native bars.
      final lightVariantContrast = _contrast(_lightVariantGlyphLuma, cellLuma);
      final darkVariantContrast = _contrast(_darkVariantGlyphLuma, cellLuma);
      if (lightVariantContrast >= darkVariantContrast) {
        votesLight++;
      } else {
        votesDark++;
      }
    }
    final total = votesLight + votesDark;
    if (total == 0) return current;
    // Dual-threshold hysteresis on top of sticky ties: each direction needs
    // a supermajority, so boundary content keeps the current appearance.
    if (current == Brightness.light) {
      return votesDark / total >= lightToDarkThreshold
          ? Brightness.dark
          : Brightness.light;
    }
    return votesLight / total >= darkToLightThreshold
        ? Brightness.light
        : Brightness.dark;
  }

  /// WCAG relative luminance of the light variant's glyphs (near-black).
  static const double _lightVariantGlyphLuma = 0.0;

  /// WCAG relative luminance of the dark variant's glyphs (white).
  static const double _darkVariantGlyphLuma = 1.0;

  /// WCAG contrast ratio between two relative luminances.
  static double _contrast(double l1, double l2) {
    final hi = math.max(l1, l2);
    final lo = math.min(l1, l2);
    return (hi + 0.05) / (lo + 0.05);
  }

  /// WCAG relative luminance from non-linear sRGB channels in `[0, 1]`.
  static double _wcagLuma(double r, double g, double b) {
    double lin(double c) => c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
  }

  @override
  State<GlassContentAwareScope> createState() => GlassContentAwareScopeState();
}

/// State (and registration surface) of a [GlassContentAwareScope].
///
/// Custom controls obtain this via [GlassContentAwareScope.maybeOf] and call
/// [register]; the bars do this internally through
/// [GlassContentAwareBrightness].
class GlassContentAwareScopeState extends State<GlassContentAwareScope> {
  final List<GlassContentAwareSubscription> _subscriptions =
      <GlassContentAwareSubscription>[];
  GlobalKey? _contentKey;
  Timer? _scrollTimer;
  bool _samplePending = false;
  bool _sampling = false;

  /// Fraction of a control's height trimmed from the top and bottom before
  /// gridding. Glyphs sit in the vertical middle of a control; edge rows
  /// would bias the vote with content that never sits behind a glyph.
  static const double _kVerticalInsetFraction = 0.18;

  /// Capture downscale target: physical pixels per grid cell edge.
  static const double _kTargetCellPixels = 16.0;

  /// Registers a glass control to receive content-aware verdicts.
  ///
  /// [controlBox] returns the control's render box at sample time (or null
  /// while it is unmounted — the control is skipped for that sample). The
  /// control's rectangle is divided into [gridColumns] × [gridRows] voting
  /// cells — 6×1 suits wide bars; a compact button would use a square grid.
  /// [onBrightnessChanged] fires only when the verdict actually flips;
  /// [initialBrightness] seeds the hysteresis state.
  ///
  /// Call [GlassContentAwareSubscription.cancel] when the control goes away.
  GlassContentAwareSubscription register({
    required RenderBox? Function() controlBox,
    required ValueChanged<Brightness> onBrightnessChanged,
    required Brightness initialBrightness,
    int gridColumns = 6,
    int gridRows = 1,
  }) {
    assert(gridColumns > 0 && gridRows > 0, 'Grid must have at least 1 cell');
    final sub = GlassContentAwareSubscription._(
      this,
      controlBox,
      onBrightnessChanged,
      gridColumns,
      gridRows,
      initialBrightness,
    );
    _subscriptions.add(sub);
    requestSample();
    return sub;
  }

  /// Schedules a single sample after the next frame.
  ///
  /// Coalesces multiple requests; used for the initial verdict, trailing
  /// scroll-end samples, and external invalidation (e.g. the app theme
  /// changed). Sampling only happens when content is registered, so this is
  /// free on screens without a [GlassContentAwareContent].
  void requestSample() {
    if (_samplePending || !mounted) return;
    _samplePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _samplePending = false;
      unawaited(_sample());
    });
    // Make sure a frame actually comes — the screen may be fully idle.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Runs one sample immediately and returns when verdicts are delivered.
  @visibleForTesting
  Future<void> sampleNow() => _sample();

  /// Whether the periodic scroll sampler is currently running.
  @visibleForTesting
  bool get isScrollSamplingActive => _scrollTimer != null;

  void _attachContent(GlobalKey boundaryKey) {
    assert(
      _contentKey == null || _contentKey == boundaryKey,
      'A GlassContentAwareScope supports a single GlassContentAwareContent. '
      'Found a second content region under the same scope.',
    );
    _contentKey = boundaryKey;
    requestSample();
  }

  void _detachContent(GlobalKey boundaryKey) {
    if (_contentKey == boundaryKey) _contentKey = null;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _startScrollSampling();
    } else if (notification is ScrollEndNotification) {
      _stopScrollSampling();
    } else if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      // A Start may have been swallowed (e.g. programmatic jumps) — make
      // sure the sampler runs whenever positions are actually moving.
      _startScrollSampling();
    }
    return false;
  }

  bool _onScrollMetrics(ScrollMetricsNotification notification) {
    // Content geometry changed without a scroll (new items, viewport
    // resize). One sample keeps idle verdicts honest; the periodic sampler
    // already covers the scrolling case.
    if (_scrollTimer == null) requestSample();
    return false;
  }

  void _startScrollSampling() {
    if (_scrollTimer != null) return;
    requestSample();
    _scrollTimer = Timer.periodic(
      widget.sampleInterval,
      (_) => unawaited(_sample()),
    );
  }

  void _stopScrollSampling() {
    if (_scrollTimer == null) return;
    _scrollTimer!.cancel();
    _scrollTimer = null;
    // Trailing sample so the settled content decides the resting verdict.
    requestSample();
  }

  @override
  void didUpdateWidget(GlassContentAwareScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sampleInterval != widget.sampleInterval &&
        _scrollTimer != null) {
      _scrollTimer!.cancel();
      _scrollTimer = Timer.periodic(
        widget.sampleInterval,
        (_) => unawaited(_sample()),
      );
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    for (final sub in _subscriptions) {
      sub._cancelled = true;
    }
    _subscriptions.clear();
    super.dispose();
  }

  Future<void> _sample() async {
    if (!mounted || _sampling || _subscriptions.isEmpty) return;
    final boundary = _contentKey?.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary ||
        !boundary.hasSize ||
        boundary.size.isEmpty) {
      return;
    }
    // Skip frames that are mid-paint. debugNeedsPaint is DEBUG-ONLY — its
    // backing value is assigned inside an assert, so reading it in profile
    // or release builds throws. Only consult it behind an assert closure;
    // release builds sample post-frame where the boundary is always clean.
    var midPaint = false;
    assert(() {
      midPaint = boundary.debugNeedsPaint;
      return true;
    }());
    if (midPaint) return;
    _sampling = true;
    try {
      // Resolve each registered control's grid cells in boundary-local
      // coordinates, and the smallest cell height for the downscale factor.
      final work = <(GlassContentAwareSubscription, List<Rect>)>[];
      var minCellExtent = double.infinity;
      for (final sub in List.of(_subscriptions)) {
        final box = sub._controlBox();
        if (box == null || !box.attached || !box.hasSize) continue;
        final origin = boundary.globalToLocal(box.localToGlobal(Offset.zero));
        var rect = origin & box.size;
        final inset = rect.height * _kVerticalInsetFraction;
        rect = Rect.fromLTRB(
          rect.left,
          rect.top + inset,
          rect.right,
          rect.bottom - inset,
        ).intersect(Offset.zero & boundary.size);
        if (rect.isEmpty) continue;
        final cellW = rect.width / sub.gridColumns;
        final cellH = rect.height / sub.gridRows;
        final cells = <Rect>[
          for (var gy = 0; gy < sub.gridRows; gy++)
            for (var gx = 0; gx < sub.gridColumns; gx++)
              Rect.fromLTWH(
                rect.left + gx * cellW,
                rect.top + gy * cellH,
                cellW,
                cellH,
              ),
        ];
        minCellExtent = math.min(minCellExtent, cellH);
        work.add((sub, cells));
      }
      if (work.isEmpty) return;

      // Downscale so a cell maps to ~16 physical pixels — enough for a
      // stable average, cheap enough to read back at scroll rates.
      final pixelRatio =
          (_kTargetCellPixels / math.max(minCellExtent, 1.0)).clamp(0.05, 0.5);
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final width = image.width;
      final height = image.height;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (!mounted || byteData == null) return;
      final rgba = byteData.buffer.asUint8List();
      final background = widget.backgroundColor ??
          (MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark
              // Whitelisted: Raw black/white used for contrast detection math, not theming.
              ? const Color(0xFF000000)
              : const Color(0xFFFFFFFF));

      for (final (sub, cells) in work) {
        if (sub._cancelled) continue;
        final pixelCells = <Rect>[
          for (final c in cells)
            Rect.fromLTRB(
              c.left * pixelRatio,
              c.top * pixelRatio,
              c.right * pixelRatio,
              c.bottom * pixelRatio,
            ),
        ];
        final verdict = GlassContentAwareScope.computeVerdict(
          rgba: rgba,
          width: width,
          height: height,
          cellRects: pixelCells,
          current: sub._brightness,
          lightToDarkThreshold: widget.lightToDarkThreshold,
          darkToLightThreshold: widget.darkToLightThreshold,
          background: background,
        );
        if (verdict != sub._brightness) {
          sub._brightness = verdict;
          sub._onBrightnessChanged(verdict);
        }
      }
    } catch (e, stack) {
      // Transient capture failure (boundary mid-mutation, detached layer).
      // The next scroll tick retries; never let sampling take a screen down.
      // Surface errors in debug/profile so programming mistakes are visible.
      assert(() {
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: stack,
          library: 'liquid_glass_widgets',
          context: ErrorDescription(
            'during content-aware brightness sample',
          ),
          silent: true,
        ));
        return true;
      }());
    } finally {
      _sampling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ContentAwareScopeMarker(
      state: this,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: _onScrollMetrics,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A live registration of a glass control with a [GlassContentAwareScope].
///
/// Returned by [GlassContentAwareScopeState.register]. Holds the control's
/// hysteresis state; [cancel] detaches the control from the scope.
class GlassContentAwareSubscription {
  GlassContentAwareSubscription._(
    this._scope,
    this._controlBox,
    this._onBrightnessChanged,
    this.gridColumns,
    this.gridRows,
    this._brightness,
  );

  final GlassContentAwareScopeState _scope;
  final RenderBox? Function() _controlBox;
  final ValueChanged<Brightness> _onBrightnessChanged;

  /// Number of horizontal voting cells for this control.
  final int gridColumns;

  /// Number of vertical voting cells for this control.
  final int gridRows;

  Brightness _brightness;
  bool _cancelled = false;

  /// The control's current content-aware verdict.
  Brightness get brightness => _brightness;

  /// Detaches the control from the scope. Safe to call more than once.
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _scope._subscriptions.remove(this);
  }
}

class _ContentAwareScopeMarker extends InheritedWidget {
  const _ContentAwareScopeMarker({
    required this.state,
    required super.child,
  });

  final GlassContentAwareScopeState state;

  @override
  bool updateShouldNotify(_ContentAwareScopeMarker oldWidget) =>
      state != oldWidget.state;
}

/// Marks the sampled content region of a [GlassContentAwareScope].
///
/// Wrap the scrolling content — and only the content — in this widget. It
/// installs the [RepaintBoundary] that the scope captures, so the adaptive
/// glass controls themselves must stay **outside** of it (e.g. in
/// `Scaffold.bottomNavigationBar` with `extendBody: true`); otherwise the
/// capture would see the controls' own rendering instead of the content
/// behind them.
///
/// A scope supports a single content region. Without one, the scope never
/// samples and adaptive controls keep their ambient appearance.
class GlassContentAwareContent extends StatefulWidget {
  /// Creates a sampled content region.
  const GlassContentAwareContent({required this.child, super.key});

  /// The scrolling content to sample.
  final Widget child;

  @override
  State<GlassContentAwareContent> createState() =>
      _GlassContentAwareContentState();
}

class _GlassContentAwareContentState extends State<GlassContentAwareContent> {
  final GlobalKey _boundaryKey = GlobalKey();
  GlassContentAwareScopeState? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = GlassContentAwareScope.maybeOf(context);
    if (scope != _scope) {
      _scope?._detachContent(_boundaryKey);
      _scope = scope;
      _scope?._attachContent(_boundaryKey);
    }
  }

  @override
  void dispose() {
    _scope?._detachContent(_boundaryKey);
    _scope = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: _boundaryKey, child: widget.child);
  }
}

/// Gives a single glass control a content-aware light/dark appearance.
///
/// This is the per-control consumer of [GlassContentAwareScope] — the bars
/// use it internally when `adaptiveBrightness: true`, and custom glass
/// controls can wrap themselves in it directly.
///
/// The widget resolves the control's [Brightness] from one of three
/// sources, in priority order:
///
/// 1. [brightnessOverride] — an external [ValueListenable] that bypasses
///    the sampler entirely. Use this over PlatformViews, where the content
///    cannot be captured, and drive it from your own signal.
/// 2. The enclosing [GlassContentAwareScope], by registering the control's
///    rectangle for the per-control contrast vote.
/// 3. The ambient platform brightness, when neither is available.
///
/// Every verdict change cross-fades rather than snapping: an internal
/// animation eases `darkAmount` between 0 (light) and 1 (dark) over
/// [flipDuration] with [flipCurve] (falling back to the scope's values,
/// then to 200 ms / [Curves.easeInOut]). During the fade the subtree built
/// by [builder] is wrapped so the swap "just works" end to end:
///
/// - [GlassTheme] is replaced with the lerp of its light and dark variants
///   (see [GlassThemeVariant.lerp]) — themed glass settings, glow palettes
///   and radii cross-fade smoothly.
/// - `MediaQuery.platformBrightness` and the [CupertinoTheme] brightness
///   flip at the fade midpoint, where the blend makes the discrete residue
///   (shadows, resolved dynamic colors in user content) least visible.
///
/// [onBrightnessChanged] fires once per verdict flip — use it to swap
/// colors the package cannot see, such as custom-painted icons.
class GlassContentAwareBrightness extends StatefulWidget {
  /// Creates a content-aware brightness consumer around [builder].
  const GlassContentAwareBrightness({
    required this.builder,
    this.brightnessOverride,
    this.onBrightnessChanged,
    this.flipDuration,
    this.flipCurve,
    this.gridColumns = 6,
    this.gridRows = 1,
    super.key,
  }) : assert(
          gridColumns > 0 && gridRows > 0,
          'Grid must have at least 1 cell',
        );

  /// Builds the control under the brightness overrides.
  ///
  /// See [GlassBrightnessWidgetBuilder] for the parameters.
  final GlassBrightnessWidgetBuilder builder;

  /// External brightness source that bypasses the sampler entirely.
  ///
  /// When non-null, the control never registers with the scope and follows
  /// this listenable instead — the escape hatch for content that cannot be
  /// captured (iOS PlatformViews such as maps).
  final ValueListenable<Brightness>? brightnessOverride;

  /// Called when the committed verdict flips (not for the initial value).
  final ValueChanged<Brightness>? onBrightnessChanged;

  /// Cross-fade duration override; falls back to the scope's
  /// [GlassContentAwareScope.flipDuration], then 200 ms.
  final Duration? flipDuration;

  /// Cross-fade curve override; falls back to the scope's
  /// [GlassContentAwareScope.flipCurve], then [Curves.easeInOut].
  final Curve? flipCurve;

  /// Horizontal voting cells for this control's rect. Defaults to 6 — the
  /// bar-shaped grid. Compact controls should use a square grid (e.g. 2×2).
  final int gridColumns;

  /// Vertical voting cells for this control's rect. Defaults to 1.
  final int gridRows;

  @override
  State<GlassContentAwareBrightness> createState() =>
      _GlassContentAwareBrightnessState();
}

class _GlassContentAwareBrightnessState
    extends State<GlassContentAwareBrightness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  late Brightness _brightness;
  Brightness? _lastAmbient;
  bool _initialized = false;
  GlassContentAwareScopeState? _scope;
  GlassContentAwareSubscription? _subscription;

  static const Duration _kDefaultFlipDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(vsync: this, duration: _kDefaultFlipDuration);
    widget.brightnessOverride?.addListener(_onOverrideChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ambient =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    if (!_initialized) {
      _initialized = true;
      _brightness = widget.brightnessOverride?.value ?? ambient;
      _flip.value = _brightness == Brightness.dark ? 1.0 : 0.0;
    } else if (_lastAmbient != ambient && widget.brightnessOverride == null) {
      // The app theme flipped underneath us — the old verdict was computed
      // against content that just restyled. Re-anchor to the ambient
      // brightness and let the next sample re-vote.
      _setBrightness(ambient);
      _scope?.requestSample();
    }
    _lastAmbient = ambient;
  }

  @override
  void didUpdateWidget(GlassContentAwareBrightness oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightnessOverride != widget.brightnessOverride) {
      oldWidget.brightnessOverride?.removeListener(_onOverrideChanged);
      widget.brightnessOverride?.addListener(_onOverrideChanged);
      final override = widget.brightnessOverride;
      if (override != null) _setBrightness(override.value);
      // Scope registration is re-resolved in build via _syncSources.
    }
    if (oldWidget.gridColumns != widget.gridColumns ||
        oldWidget.gridRows != widget.gridRows) {
      // Grid changed — drop the registration; build re-registers with the
      // new dimensions.
      _subscription?.cancel();
      _subscription = null;
      _scope = null;
    }
  }

  @override
  void dispose() {
    widget.brightnessOverride?.removeListener(_onOverrideChanged);
    _subscription?.cancel();
    _flip.dispose();
    super.dispose();
  }

  void _onOverrideChanged() {
    _setBrightness(widget.brightnessOverride!.value);
  }

  void _setBrightness(Brightness brightness) {
    if (brightness == _brightness) return;
    _brightness = brightness;
    widget.onBrightnessChanged?.call(brightness);
    final duration = widget.flipDuration ??
        _scope?.widget.flipDuration ??
        _kDefaultFlipDuration;
    final curve =
        widget.flipCurve ?? _scope?.widget.flipCurve ?? Curves.easeInOut;
    _flip.animateTo(
      brightness == Brightness.dark ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
    );
    // AnimatedBuilder listens to _flip and rebuilds on every tick;
    // no explicit setState needed.
  }

  /// Keeps the scope registration in sync with the widget configuration.
  ///
  /// Runs at the top of build (inherited lookups are legal there and this
  /// is where dependencies must be registered anyway) and is idempotent.
  void _syncSources() {
    final wantScope = widget.brightnessOverride == null
        ? GlassContentAwareScope.maybeOf(context)
        : null;
    if (wantScope == _scope && (_subscription != null) == (wantScope != null)) {
      return;
    }
    _subscription?.cancel();
    _subscription = null;
    _scope = wantScope;
    if (wantScope != null) {
      _subscription = wantScope.register(
        controlBox: () {
          if (!mounted) return null;
          final ro = context.findRenderObject();
          return ro is RenderBox ? ro : null;
        },
        onBrightnessChanged: _setBrightness,
        initialBrightness: _brightness,
        gridColumns: widget.gridColumns,
        gridRows: widget.gridRows,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncSources();
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, _) {
        final t = _flip.value;
        // The discrete residue (shadow gating, dynamic-color resolution in
        // user content) flips at the fade midpoint, where the lerped colors
        // cross and the swap is least visible.
        final displayBrightness = t >= 0.5 ? Brightness.dark : Brightness.light;
        final baseTheme = GlassThemeData.of(context);
        final variant = GlassThemeVariant.lerp(
          baseTheme.light,
          baseTheme.dark,
          t,
        );
        Widget result = Builder(
          builder: (inner) => widget.builder(inner, _brightness, t),
        );
        result = GlassTheme(
          data: baseTheme.copyWith(light: variant, dark: variant),
          child: result,
        );
        result = CupertinoTheme(
          data: CupertinoTheme.of(context)
              .copyWith(brightness: displayBrightness),
          child: result,
        );
        final mq = MediaQuery.maybeOf(context);
        if (mq != null) {
          result = MediaQuery(
            data: mq.copyWith(platformBrightness: displayBrightness),
            child: result,
          );
        }
        return result;
      },
    );
  }
}
