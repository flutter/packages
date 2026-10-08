import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/glass_theme.dart';
import '../effects/progressive_blur.dart';
import '../interactive/liquid_glass_scope.dart';

/// Edge effect style matching iOS 26's `.scrollEdgeEffectStyle`.
///
/// Controls how scroll content fades or frosts at the edges when it meets a
/// glass surface (navigation bar, bottom bar, etc.).
enum GlassScrollEdgeStyle {
  /// A progressive, graduated blur that frosts live content under the bar.
  ///
  /// Uses [ProgressiveBlur] to blur live scrolling content with a gradient
  /// sigma so high frequencies (text, sharp edges) melt into a soft frost,
  /// maintaining contrast and legibility for bar chrome while keeping content
  /// visible underneath.
  ///
  /// This is an opt-in design enhancement beyond the system default, ideal
  /// for rich media grids, video feeds, or custom dynamic gradients.
  ///
  /// **Compositing cost:** Internally uses a [BackdropFilterLayer], which
  /// requires compositing on every frame the widget is visible. On
  /// Metal/Impeller this is GPU-only and cheap; on Skia/Android it carries
  /// a slightly higher overhead than [soft] or [hard]. On pages that use no
  /// other glass surfaces, [soft] remains a lighter alternative.
  blur,

  /// A rounded, diffused fade — content dissolves into the backdrop.
  ///
  /// Matches iOS 26's `.scrollEdgeEffectStyle(.soft)`. This is the default
  /// and recommended style for standard navigation and list views. When inside
  /// a [GlassPage] (or with texture capture enabled), paints a slice of the
  /// background texture; outside, falls back to a solid gradient.
  soft,

  /// A crisp boundary — content has a sharper cutoff at the bar edge.
  ///
  /// Matches iOS 26's `.scrollEdgeEffectStyle(.hard)`. Uses a 50% tighter
  /// transition zone with a steep opacity curve, ideal for dense settings
  /// lists, tabular data, and utility screens.
  hard,
}

/// A widget that fades or blurs scroll content at the top and/or bottom edges.
///
/// Matches iOS 26's `.scrollEdgeEffectStyle(_:for:)` modifier. Places gradient
/// blur or overlay masks at the specified edges, creating the effect of content
/// smoothly dissolving into navigation bars or bottom bars rather than clipping
/// sharply.
///
/// ## How it works
///
/// **[GlassScrollEdgeStyle.soft]** (default, iOS 26 parity):
/// Inside [GlassPage], automatically captures the page background texture and
/// paints it over the scroll edges with a gradient alpha mask. Outside
/// [GlassPage], falls back to a solid-colour gradient overlay using [fadeColor].
///
/// **[GlassScrollEdgeStyle.hard]**:
/// Like [GlassScrollEdgeStyle.soft], but applies a 50% height zone and steeper alpha curve for a
/// crisper structural edge.
///
/// **[GlassScrollEdgeStyle.blur]** (opt-in GPU enhancement):
/// Uses [ProgressiveBlur] to apply a hardware-accelerated 2-pass Gaussian blur
/// directly over live scrolling content. The content remains visible underneath
/// the bar while high frequencies melt away, protecting navigation buttons and
/// titles.
///
/// ## Usage
///
/// ```dart
/// GlassScrollEdgeEffect(
///   topFadeHeight: 100,
///   bottomFadeHeight: 80,
///   child: ListView.builder(
///     itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
///   ),
/// )
/// ```
///
/// ## With GlassAppBar
///
/// ```dart
/// Scaffold(
///   extendBodyBehindAppBar: true,
///   appBar: GlassAppBar(title: Text('Messages')),
///   body: GlassScrollEdgeEffect(
///     topFadeHeight: MediaQuery.paddingOf(context).top + 44 + 50,
///     bottomFadeHeight: 60 + MediaQuery.paddingOf(context).bottom,
///     child: ListView(...),
///   ),
/// )
/// ```
///
/// The [topFadeHeight] should typically cover the safe area + app bar height
/// + a buffer zone so content fades before reaching the navigation buttons.
class GlassScrollEdgeEffect extends StatefulWidget {
  /// Creates a scroll edge effect that blurs or fades content at the edges.
  ///
  /// When [style] is [GlassScrollEdgeStyle.soft] (default), the effect uses a
  /// gradient fade overlay, matching iOS 26's `.scrollEdgeEffectStyle(.soft)`.
  ///
  /// When [style] is [GlassScrollEdgeStyle.blur], [ProgressiveBlur] is used to
  /// apply a hardware-accelerated progressive Gaussian frost to live content.
  /// This is a creative enhancement beyond the system default — opt in
  /// explicitly when you want a stronger frosted-glass look.
  ///
  /// When [style] is [GlassScrollEdgeStyle.hard], a crisp gradient cutoff is
  /// used, matching iOS 26's `.scrollEdgeEffectStyle(.hard)`.
  const GlassScrollEdgeEffect({
    super.key,
    required this.child,
    this.topFadeHeight = 100.0,
    this.bottomFadeHeight = 60.0,
    this.fadeTop = true,
    this.fadeBottom = true,
    this.style = GlassScrollEdgeStyle.soft,
    this.maxSigma = 18.0,
    this.fadeColor,
  });

  /// The scrollable content to apply edge fading to.
  final Widget child;

  /// The height of the top fade zone in logical pixels.
  ///
  /// Content within this zone fades from fully transparent (at the top edge)
  /// to fully visible. Should cover the safe area + navigation bar height +
  /// a buffer zone.
  ///
  /// Defaults to 100.0.
  final double topFadeHeight;

  /// The height of the bottom fade zone in logical pixels.
  ///
  /// Content within this zone fades from fully visible to fully transparent
  /// (at the bottom edge). Should cover the bottom bar height + safe area.
  ///
  /// Defaults to 60.0.
  final double bottomFadeHeight;

  /// Whether to fade content at the top edge.
  ///
  /// Defaults to true.
  final bool fadeTop;

  /// Whether to fade content at the bottom edge.
  ///
  /// Defaults to true.
  final bool fadeBottom;

  /// The edge effect style.
  ///
  /// Defaults to [GlassScrollEdgeStyle.blur], matching iOS 26's
  /// `.scrollEdgeEffectStyle`.
  final GlassScrollEdgeStyle style;

  /// Maximum blur sigma for [GlassScrollEdgeStyle.blur] at the strongest edge.
  ///
  /// Defaults to 18.0.
  final double maxSigma;

  /// Fallback colour used when no background texture is available.
  ///
  /// This is only used for [GlassScrollEdgeStyle.soft] / [GlassScrollEdgeStyle.hard]
  /// outside [GlassPage].
  final Color? fadeColor;

  @override
  State<GlassScrollEdgeEffect> createState() => _GlassScrollEdgeEffectState();
}

class _GlassScrollEdgeEffectState extends State<GlassScrollEdgeEffect> {
  GlobalKey? _backgroundKey;
  ui.Image? _backgroundImage;
  bool _hasAttemptedCapture = false;
  bool _capturePending = false;

  /// Set to true when a capture is requested while one is already in-flight.
  /// [_finishCapture] checks this and issues the deferred capture.
  bool _recaptureRequested = false;

  /// Generation counter for background captures. Incremented whenever an
  /// in-flight capture is invalidated (e.g. on theme switch or color change),
  /// ensuring stale async results are discarded rather than overwriting
  /// newly updated state.
  int _captureGeneration = 0;

  /// Tracks the last resolved brightness to detect theme changes in [didChangeDependencies].
  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _backgroundKey = LiquidGlassScope.of(context);

    // Track brightness via the package's single brightness authority so that
    // theme mode switches (e.g. dark -> light in MaterialApp / CupertinoTheme)
    // invalidate the stale background texture and schedule a fresh capture.
    final currentBrightness = GlassTheme.brightnessOf(context);
    final brightnessChanged =
        _lastBrightness != null && _lastBrightness != currentBrightness;
    _lastBrightness = currentBrightness;

    // For blur style, ProgressiveBlur captures the live backdrop dynamically
    // via BackdropFilterLayer at paint time, so no static background image
    // capture is needed.
    if (widget.style == GlassScrollEdgeStyle.blur) return;

    // Calling isCurrentOf registers a dependency on the ModalRoute, so Flutter
    // will call didChangeDependencies again whenever isCurrent changes — i.e.
    // when a route is pushed on top of us, or when we resume after a pop.
    // All three cases (first mount / route resume / dep changed while visible)
    // are handled identically: schedule a capture on the next frame.
    if (!(ModalRoute.isCurrentOf(context) ?? true)) return;

    if (brightnessChanged) {
      _captureGeneration++;
      _backgroundImage?.dispose();
      _backgroundImage = null;
    }
    _scheduleCapture();
  }

  @override
  void didUpdateWidget(GlassScrollEdgeEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool styleBecameRaster = widget.style != GlassScrollEdgeStyle.blur &&
        oldWidget.style == GlassScrollEdgeStyle.blur;
    final bool fadeColorChanged = widget.fadeColor != oldWidget.fadeColor;

    if (widget.style != GlassScrollEdgeStyle.blur &&
        (styleBecameRaster || fadeColorChanged)) {
      if (fadeColorChanged) {
        _captureGeneration++;
        _backgroundImage?.dispose();
        _backgroundImage = null;
      }
      _scheduleCapture();
    }
  }

  void _scheduleCapture() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _captureBackground();
    });
  }

  void _captureBackground() {
    if (_backgroundKey == null) {
      _hasAttemptedCapture = true;
      return;
    }

    final boundary = _backgroundKey!.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null || !boundary.hasSize || boundary.size.isEmpty) {
      // Boundary not ready yet — retry after the first frame.
      if (!_hasAttemptedCapture) {
        _hasAttemptedCapture = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _captureBackground();
        });
      }
      return;
    }

    _hasAttemptedCapture = true;

    // In debug mode, toImageSync asserts if the boundary is marked as needing paint.
    // If it needs paint, wait for the next frame.
    bool needsPaint = false;
    assert(() {
      needsPaint = boundary.debugNeedsPaint;
      return true;
    }());

    if (needsPaint) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _captureBackground();
      });
      return;
    }

    // Already in-flight: record the request and let _finishCapture re-issue
    // it once the current capture completes. Previously this was a hard
    // early-return, which could leave a stale image indefinitely if a theme
    // change arrived while a capture was already running (issue #212).
    if (_capturePending) {
      _recaptureRequested = true;
      return;
    }
    _capturePending = true;
    final currentGen = _captureGeneration;
    try {
      boundary
          .toImage(pixelRatio: 1.0)
          .then<void>((image) {
            if (!mounted || currentGen != _captureGeneration) {
              image.dispose();
              return;
            }
            _backgroundImage?.dispose();
            _backgroundImage = image;
            setState(() {});
          })
          .catchError((Object _) {})
          .whenComplete(_finishCapture);
    } on Object {
      // toImage() can throw synchronously if `layer` is still null
      // (paint has not completed). Reset the flag and fall back to
      // the solid-colour gradient overlay.
      _capturePending = false;
    }
  }

  /// Called via [Future.whenComplete] after every capture attempt (success or
  /// error). If a recapture was requested while the previous one was in-flight,
  /// issues a new capture on the next frame.
  void _finishCapture() {
    _capturePending = false;
    if (!_recaptureRequested) return;
    _recaptureRequested = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _captureBackground();
    });
  }

  @override
  void dispose() {
    _captureGeneration++;
    _backgroundImage?.dispose();
    _backgroundImage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No fading needed — return child directly.
    if (!widget.fadeTop && !widget.fadeBottom) return widget.child;

    final screenSize = MediaQuery.sizeOf(context);
    final hasTexture = _backgroundImage != null;

    return Stack(
      children: [
        // 1. Scroll content — no compositing layer wrapping it.
        widget.child,

        // 2. Top fade overlay.
        if (widget.fadeTop)
          _buildOverlay(
            isTop: true,
            height: _effectiveHeight(widget.topFadeHeight, screenSize.height),
            screenSize: screenSize,
            hasTexture: hasTexture,
          ),

        // 3. Bottom fade overlay.
        if (widget.fadeBottom)
          _buildOverlay(
            isTop: false,
            height:
                _effectiveHeight(widget.bottomFadeHeight, screenSize.height),
            screenSize: screenSize,
            hasTexture: hasTexture,
          ),
      ],
    );
  }

  Widget _buildOverlay({
    required bool isTop,
    required double height,
    required Size screenSize,
    required bool hasTexture,
  }) {
    if (widget.style == GlassScrollEdgeStyle.blur) {
      return Positioned(
        top: isTop ? 0 : null,
        bottom: isTop ? null : 0,
        left: 0,
        right: 0,
        height: height,
        child: IgnorePointer(
          child: ProgressiveBlur(
            maxSigma: widget.maxSigma,
            // ease-in quadratic falloff: keeps sigma near-zero for the first
            // ~40% of the zone so content stays perceptually sharp until it
            // is well inside the bar area. Default ProgressiveBlur falloff
            // (1.2) is near-linear and makes the blur visible too early.
            // No shader changes — uFalloff is already a uniform.
            falloff: 2.0,
            direction: isTop
                ? ProgressiveBlurDirection.topToBottom
                : ProgressiveBlurDirection.bottomToTop,
          ),
        ),
      );
    }

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: hasTexture
            ? CustomPaint(
                size: Size(screenSize.width, height),
                painter: _TextureFadePainter(
                  image: _backgroundImage!,
                  isTop: isTop,
                  screenHeight: screenSize.height,
                  style: widget.style,
                ),
              )
            : _buildColorOverlay(isTop: isTop),
      ),
    );
  }

  /// Fallback: solid-colour gradient overlay for use outside [GlassPage].
  ///
  /// Only valid for [GlassScrollEdgeStyle.soft] and [GlassScrollEdgeStyle.hard].
  /// The [GlassScrollEdgeStyle.blur] branch in [_buildOverlay] returns a
  /// [ProgressiveBlur] directly and never reaches this method.
  Widget _buildColorOverlay({required bool isTop}) {
    assert(
      widget.style != GlassScrollEdgeStyle.blur,
      '_buildColorOverlay must not be called for GlassScrollEdgeStyle.blur. '
      'The blur branch in _buildOverlay should return early with ProgressiveBlur.',
    );
    final color =
        widget.fadeColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor;
    final curve = _kFadeCurves[widget.style]!;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
          colors: curve.alphas
              .map((a) => color.withValues(alpha: color.a * a))
              .toList(),
          stops: curve.stops,
        ),
      ),
    );
  }

  double _effectiveHeight(double height, double boundsHeight) {
    // Hard style uses a tighter transition zone (half of soft) combined with
    // a steeper gradient curve — so it's a different *shape*, not just a
    // compressed version of soft.
    final adjusted =
        widget.style == GlassScrollEdgeStyle.hard ? height * 0.5 : height;
    // Clamp to 40% of available height to avoid overlapping zones.
    return adjusted.clamp(0.0, boundsHeight * 0.4);
  }
}

/// Pre-computed gradient curves for each raster [GlassScrollEdgeStyle].
///
/// Each curve defines the alpha values and corresponding stops for a
/// multi-stop gradient that produces a perceptually smooth fade. A simple
/// 2-stop linear ramp (the previous implementation) appears non-uniform to
/// the human eye — denser in the middle — and terminates with a visible seam.
///
/// [GlassScrollEdgeStyle.blur] is NOT included here — that style renders via
/// [ProgressiveBlur] and never reaches the [_TextureFadePainter] or
/// [_buildColorOverlay] paths. Only [soft] and [hard] are valid map keys.
///
/// These curves are modelled after iOS 26's scroll edge effect:
/// - **Soft**: gentle ease-in dissolve with a long transparent tail, producing
///   a diffused fade that dissolves content smoothly into the bar area.
/// - **Hard**: holds opacity longer then drops sharply, but still includes a
///   feathered tail to avoid the hard cutoff seam.
class _FadeCurve {
  const _FadeCurve(this.alphas, this.stops);

  /// Alpha multipliers from edge (1.0 = fully opaque) to content (0.0).
  final List<double> alphas;

  /// Corresponding gradient stop positions in [0, 1].
  final List<double> stops;
}

/// Gradient curves for the two raster styles ([soft] and [hard] only).
///
/// [GlassScrollEdgeStyle.blur] is intentionally absent — it uses
/// [ProgressiveBlur] rather than a raster gradient, so it never reads this map.
const Map<GlassScrollEdgeStyle, _FadeCurve> _kFadeCurves = {
  // Soft: gentle ease-in dissolve. Holds opacity briefly at the edge, then
  // accelerates through the mid-range, and includes a long low-alpha tail
  // that reaches fully transparent well before the overlay boundary —
  // eliminating the visible seam.
  GlassScrollEdgeStyle.soft: _FadeCurve(
    [1.0, 0.70, 0.30, 0.04, 0.0],
    [0.0, 0.15, 0.45, 0.75, 0.92],
  ),
  // Hard: crisp but feathered. Stays opaque for longer (the "hard" feel),
  // then drops more steeply, but still includes a tail to prevent seaming.
  // Combined with the 0.5× height multiplier in _effectiveHeight, this
  // produces a noticeably crisper boundary than soft without a sharp line.
  GlassScrollEdgeStyle.hard: _FadeCurve(
    [1.0, 0.90, 0.50, 0.04, 0.0],
    [0.0, 0.30, 0.60, 0.85, 0.95],
  ),
};

/// Paints a slice of the background texture with a gradient alpha mask.
///
/// This is the core of the texture overlay approach: it takes the background
/// image captured by [GlassBackgroundSource], extracts the top or bottom
/// strip, and paints it with a gradient from fully opaque (at the edge) to
/// fully transparent (towards the content). Visually, this is identical to
/// fading the content to transparent and revealing the background.
///
/// Uses [BlendMode.dstIn] inside a [Canvas.saveLayer] to apply the gradient
/// mask. Since this painter only draws a static image (no [BackdropFilterLayer]),
/// the `saveLayer` is safe and does not interfere with glass rendering.
class _TextureFadePainter extends CustomPainter {
  _TextureFadePainter({
    required this.image,
    required this.isTop,
    required this.screenHeight,
    required this.style,
  });

  final ui.Image image;
  final bool isTop;
  final double screenHeight;
  final GlassScrollEdgeStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // The image is captured at pixelRatio: 1.0, so its pixel dimensions
    // match logical dimensions. Calculate the source strip from the
    // corresponding edge of the background.
    final double scaleY = image.height / screenHeight;

    final Rect srcRect = isTop
        ? Rect.fromLTWH(0, 0, image.width.toDouble(), size.height * scaleY)
        : Rect.fromLTWH(
            0,
            image.height - size.height * scaleY,
            image.width.toDouble(),
            size.height * scaleY,
          );

    final Rect dstRect = Offset.zero & size;

    // Paint the background strip with gradient alpha.
    // saveLayer is safe here — no BackdropFilterLayer inside.
    canvas.saveLayer(dstRect, Paint());

    // Draw the background texture slice.
    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    // Apply gradient alpha mask: opaque at the edge, transparent towards
    // the content. Uses a multi-stop eased gradient to produce a
    // perceptually smooth fade without a visible seam at the boundary.
    final curve = _kFadeCurves[style]!;
    final gradientPaint = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = LinearGradient(
        begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
        colors: curve.alphas
            .map((a) => Color.fromARGB((a * 255).round(), 0, 0, 0))
            .toList(),
        stops: curve.stops,
      ).createShader(dstRect);

    canvas.drawRect(dstRect, gradientPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TextureFadePainter oldDelegate) =>
      image != oldDelegate.image ||
      isTop != oldDelegate.isTop ||
      screenHeight != oldDelegate.screenHeight ||
      style != oldDelegate.style;
}
