// ignore_for_file: require_trailing_commas

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../../src/engine/internal/transform_tracking_repaint_boundary_mixin.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme.dart';

import 'inherited_liquid_glass.dart';

/// Returns the [RenderRepaintBoundary] for [key] only when it is fully safe
/// to use — the element must be *active* and the render object *attached*.
///
/// [BuildContext.mounted] is insufficient: it returns `true` for *inactive*
/// elements (lifecycle state = `inactive`). The assert inside
/// [Element.findRenderObject] fires on `inactive`, not just `defunct`.
/// A try-catch is the only public-API-safe guard against this.
///
/// Used by both [_LightweightGlassEffectState] (Ticker) and
/// [_RenderLightweightGlass] (paint) to avoid crashing when
/// [GlassBackgroundSource.enabled] is toggled mid-frame.
RenderRepaintBoundary? _safeGetBoundary(GlobalKey? key) {
  if (key == null) return null;
  final ctx = key.currentContext;
  if (ctx == null) return null;
  try {
    final obj = ctx.findRenderObject();
    if (obj is RenderRepaintBoundary && obj.attached) return obj;
  } catch (_) {
    // Element is transitioning through an inactive lifecycle state.
    // Skip this frame — the Ticker will retry on the next frame.
  }
  return null;
}

/// A lightweight, high-performance glass effect widget optimized for
/// scrollable lists and universal platform compatibility.
///
/// This widget uses a custom fragment shader to achieve iOS 26 liquid glass
/// aesthetics while being 5-10x faster than BackdropFilter-based approaches.
///
/// **Lightweight-Specific Parameters:**
/// - [glowIntensity]: Interactive glow strength (0.0-1.0, button press feedback)
/// - [densityFactor]: Elevation physics (0.0-1.0, simulates nested blur darkening)
///
/// These parameters are only used by the lightweight shader (Skia/Web).
/// On Impeller, glow is handled by [GlassGlow] widget and density is not needed.
class LightweightLiquidGlass extends StatefulWidget {
  /// Creates a lightweight liquid glass effect widget.
  const LightweightLiquidGlass({
    required this.child,
    required this.shape,
    this.settings = const LiquidGlassSettings(),
    this.glowIntensity = 0.0,
    this.densityFactor = 0.0,
    this.indicatorWeight = 0.0,
    this.backgroundKey,
    super.key,
  });

  /// Creates a lightweight glass widget that inherits settings from the
  /// nearest ancestor [LiquidGlassLayer].
  const LightweightLiquidGlass.inLayer({
    required this.child,
    required this.shape,
    this.glowIntensity = 0.0,
    this.densityFactor = 0.0,
    this.indicatorWeight = 0.0,
    this.backgroundKey,
    super.key,
  }) : settings = null;

  /// The widget to display inside the glass effect.
  final Widget child;

  /// The shape of the glass surface.
  final LiquidShape shape;

  /// The glass effect settings.
  final LiquidGlassSettings? settings;

  /// Interactive glow intensity for button press feedback (Skia/Web only).
  ///
  /// Range: 0.0 (no glow) to 1.0 (full glow)
  ///
  /// On Impeller, use [GlassGlow] widget instead. This parameter is ignored.
  /// On Skia/Web, this controls shader-based glow effect.
  ///
  /// Defaults to 0.0.
  final double glowIntensity;

  /// Density factor for elevation physics (Skia/Web only).
  ///
  /// Range: 0.0 (normal) to 1.0 (fully elevated)
  ///
  /// When a parent container provides blur (batch-blur optimization), elevated
  /// buttons use this to simulate the "double-darkening" effect of nested
  /// BackdropFilters without the O(n) performance cost.
  ///
  /// On Impeller, this is not needed as each widget can have its own blur.
  ///
  /// Defaults to 0.0.
  final double densityFactor;

  /// Thicker, brighter aesthetic for indicators (Skia/Web only).
  ///
  /// Range: 0.0 (default) to 1.0 (thick/bright)
  ///
  /// This allows active indicators (like the pill in GlassSegmentedControl) to
  /// have more visual weight without affecting other glass widgets.
  final double indicatorWeight;

  /// Optional background capture key.
  final GlobalKey? backgroundKey;

  // Cache the FragmentProgram (compiled shader code) globally
  static ui.FragmentProgram? _cachedProgram;
  static bool _isPreparing = false;

  // On native: Share one shader instance (efficient)
  // On web: Each widget needs its own instance (CanvasKit requirement)
  static ui.FragmentShader? _sharedShader; // Native only

  // Dummy 1x1 transparent image for when no background is captured.
  // Lazily allocated on first paint to guarantee zero GPU raster work
  // during preWarm() or initialize() before runApp().
  static ui.Image? _dummyImage;

  /// Returns the cached 1×1 transparent dummy image, creating it lazily on demand.
  static ui.Image get dummyImage => _dummyImage ??= _createDummyImage();

  static ui.Image _createDummyImage() {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(1, 1);
    picture.dispose();
    return image;
  }

  /// Resets static shader state for testing. Call between tests to ensure
  /// each test gets the fallback rendering (no cached shader).
  @visibleForTesting
  static void resetForTesting() {
    _cachedProgram = null;
    _sharedShader = null;
    _isPreparing = false;
    _dummyImage?.dispose();
    _dummyImage = null;
  }

  /// Global pre-warm method - loads and compiles the shader program.
  static Future<void> preWarm() async {
    if (_cachedProgram != null || _isPreparing) return;
    _isPreparing = true;
    const path = 'packages/liquid_glass_widgets/shaders/lightweight_glass.frag';
    const testPath = 'shaders/lightweight_glass.frag';

    try {
      ui.FragmentProgram program;
      try {
        program = await ui.FragmentProgram.fromAsset(path);
      } catch (_) {
        // Fallback for unit tests where package prefix may not be resolved
        program = await ui.FragmentProgram.fromAsset(testPath);
      }
      _cachedProgram = program;

      // On native platforms, create the shared shader instance
      if (!kIsWeb) {
        _sharedShader = program.fragmentShader();
      }
    } catch (e) {
      debugPrint('[LightweightGlass] Pre-warm failed: $e');
    } finally {
      _isPreparing = false;
    }
  }

  @override
  State<LightweightLiquidGlass> createState() => _LightweightLiquidGlassState();
}

class _LightweightLiquidGlassState extends State<LightweightLiquidGlass>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ui.FragmentShader? _webShader; // Web only: per-widget instance
  bool _isDisposed = false;
  bool _loggedCreation = false;
  ui.Image? _backgroundImage;

  // Ticker-driven background refresh (same proven pattern as GlassEffect).
  // Fires every frame while a backgroundKey is active; stops automatically
  // when no key is present — zero overhead for glass widgets without a background.
  late final Ticker _ticker;
  Size? _lastCaptureSize;
  Offset? _lastCapturePosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShader();
    _ticker = createTicker(_handleTick);
    // Defer ticker start until after first frame so the RepaintBoundary is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateTicker();
    });
  }

  /// Start the ticker if a live RepaintBoundary is available for sampling.
  ///
  /// Checks the key's context directly so that a non-null key with no
  /// attached [RepaintBoundary] does NOT start the ticker.
  void _updateTicker() {
    // A key that exists but has no attached RepaintBoundary (enabled:false)
    // must not start the ticker — treat it the same as a null key.
    final bool hasBoundary = _safeGetBoundary(widget.backgroundKey) != null;

    if (hasBoundary && !_ticker.isActive) {
      _stableFrameCount = 0; // Reset so auto-suspend counts from scratch.
      _ticker.start();
    } else if (!hasBoundary && _ticker.isActive) {
      _ticker.stop();
      _stableFrameCount = 0;
      _backgroundImage?.dispose();
      _backgroundImage = null;
      // Propagate null to the render object immediately so it doesn't paint
      // with a disposed image if a repaint is triggered before the next tick.
      if (mounted) setState(() {});
    }
  }

  /// Called every frame by the ticker. Captures the background only when
  /// something has actually changed — size, position, or first capture.
  ///
  /// Self-corrects if the boundary disappears at runtime (e.g. adaptive
  /// quality drops to minimal mid-session): stops the ticker immediately
  /// rather than spinning empty for the rest of the widget's lifetime.
  ///
  /// **Battery optimization (Task 2.2):** After [_kStableFrameThreshold]
  /// consecutive ticks detect no geometry change, the ticker self-suspends.
  /// This eliminates the permanent 60 fps cost for static surfaces (bottom
  /// bars, app bars) where the background never changes after initial capture.
  /// The ticker restarts automatically via [didUpdateWidget] or
  /// [_updateTicker] when the background key changes or is re-enabled.
  static const int _kStableFrameThreshold = 3;
  int _stableFrameCount = 0;

  void _handleTick(Duration _) {
    if (_isDisposed) return; // belt-and-suspenders: post-frame callbacks can
    // outlive dispose() on rapid navigation; bail out before any GPU access.
    final key = widget.backgroundKey;
    if (key == null) return;

    final renderObject = _safeGetBoundary(key);
    if (renderObject == null) {
      // The boundary was removed (e.g. background sampling was disabled at
      // runtime). Stop the ticker immediately — zero cost from this point on.
      if (_ticker.isActive) {
        _ticker.stop();
        _backgroundImage?.dispose();
        _backgroundImage = null;
        _stableFrameCount = 0;
        // Propagate null to the render object immediately — prevents the
        // "Image has been disposed" crash if a repaint fires before the next
        // frame (e.g. button press animation triggering a paint pass).
        if (mounted) setState(() {});
      }
      return;
    }
    final boundary = renderObject;

    // debugNeedsPaint is a debug-only late getter — crashes in profile/release.
    // Guard it behind assert() and use the captured local outside.
    bool needsPaint = false;
    assert(() {
      needsPaint = boundary.debugNeedsPaint;
      return true;
    }());
    if (needsPaint) return;

    final currentSize = boundary.size;
    final currentPos = (boundary as RenderBox).localToGlobal(Offset.zero);

    // Only re-capture when geometry changes or on first capture.
    // toImageSync is synchronous and stays in GPU memory — cheap but not free.
    final bool needsCapture = _backgroundImage == null ||
        _lastCaptureSize != currentSize ||
        _lastCapturePosition != currentPos;

    if (needsCapture) {
      _stableFrameCount = 0;
      _captureBackground(boundary, currentSize, currentPos);
    } else {
      // Background hasn't changed — count consecutive stable frames.
      // After _kStableFrameThreshold (~50 ms at 60 fps), self-suspend the
      // ticker. This saves battery on static surfaces (bottom bars, app bars)
      // where the background never changes after initial capture.
      _stableFrameCount++;
      if (_stableFrameCount >= _kStableFrameThreshold && _ticker.isActive) {
        _ticker.stop();
      }
    }
  }

  // Guard: prevents concurrent async captures from stacking up.
  // Only one toImage() call can be in-flight at a time.
  bool _capturePending = false;

  /// Initiates an async background capture via [RenderRepaintBoundary.toImage].
  ///
  /// Using [toImage] (Future-based) instead of [toImageSync] is critical:
  /// [toImage] resolves AFTER the GPU compositor has flushed the current frame,
  /// guaranteeing valid pixel content. [toImageSync] races the GPU and returns
  /// an all-black image on the first frame, causing the "black on first load" bug.
  ///
  /// The [_capturePending] flag prevents concurrent captures from stacking up
  /// when the ticker fires multiple times before the first capture completes.
  void _captureBackground(
      RenderRepaintBoundary boundary, Size size, Offset pos) {
    if (_capturePending) return; // Already capturing — wait for it to finish.
    _capturePending = true;
    boundary.toImage(pixelRatio: 1.0).then((image) {
      if (!mounted || _isDisposed) {
        image.dispose();
        _capturePending = false;
        return;
      }
      _backgroundImage?.dispose();
      _backgroundImage = image;
      _lastCaptureSize = size;
      _lastCapturePosition = pos;
      _capturePending = false;
      setState(() {});
    }).catchError((_) {
      // toImage can fail transiently (e.g. widget detached mid-capture).
      // Clear the flag so the ticker will retry on the next frame.
      _capturePending = false;
    });
  }

  @override
  void didUpdateWidget(LightweightLiquidGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.backgroundKey != oldWidget.backgroundKey) {
      // Key object changed — update immediately.
      _updateTicker();
    } else if (widget.backgroundKey != null && !_ticker.isActive) {
      // Same key object but ticker is stopped. The RepaintBoundary may have
      // been re-added to the tree (e.g. GlassBackgroundSource re-enabled via
      // the BG Sample toggle). Schedule a post-frame check so the boundary
      // is guaranteed to be mounted and the GlobalKey registered before we
      // attempt to restart the Ticker.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateTicker();
      });
    }
  }

  /// Halts background-capture Tickers during app lifecycle transitions.
  ///
  /// Stopping captures on [AppLifecycleState.inactive] / [paused] prevents
  /// GPU texture creation/destruction from racing with [surfaceChanged] on
  /// the raster thread — the root cause of the ANR observed on Vulkan devices.
  /// Captures restart one frame after [resumed] to let the new surface
  /// stabilise before any [toImage] calls.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (_ticker.isActive) _ticker.stop();
        break;
      case AppLifecycleState.resumed:
        // Restart one frame after resume so surfaceChanged has completed
        // and the raster thread is not holding any surface locks.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) _updateTicker();
        });
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _initShader() async {
    // Ensure program is loaded
    if (LightweightLiquidGlass._cachedProgram == null) {
      await LightweightLiquidGlass.preWarm();
    }

    // On web, create a per-widget shader instance
    if (kIsWeb && LightweightLiquidGlass._cachedProgram != null) {
      if (mounted) {
        setState(() {
          _webShader = LightweightLiquidGlass._cachedProgram!.fragmentShader();
          if (!_loggedCreation) {
            debugPrint(
                '[LightweightGlass] ✓ Created web shader for ${widget.shape.runtimeType}');
            _loggedCreation = true;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    // Null backgroundImage BEFORE disposing the shader to break the GPU
    // texture retention chain during isolate shutdown on Mali GPUs.
    _backgroundImage?.dispose();
    _backgroundImage = null;
    // On web, dispose this widget's shader instance
    if (kIsWeb && _webShader != null) {
      _webShader!.dispose();
      _webShader = null;
    }
    // Never dispose the shared shader on native
    super.dispose();
  }

  ui.FragmentShader? get _activeShader {
    return kIsWeb ? _webShader : LightweightLiquidGlass._sharedShader;
  }

  @override
  Widget build(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedLiquidGlass>();
    final settings =
        widget.settings ?? inherited?.settings ?? const LiquidGlassSettings();
    final shader = _activeShader;

    // Optimization: Skip local blur if provided by ancestor and settings match
    final bool skipBlur = (inherited?.isBlurProvidedByAncestor ?? false) &&
        (widget.settings == null ||
            widget.settings?.blur == inherited?.settings.blur);

    // VQ4: Content-adaptive glass strength proxy.
    // The lightweight shader has no backdrop texture, so platform brightness
    // is used as the luma estimate — dark mode → richer glass (0.15),
    // light mode → subtler glass (0.85). Maps to adaptiveStrength [1.2, 0.8]
    // in the shader, matching iOS 26's adaptive material behaviour.
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final backdropLuma = isDark ? 0.15 : 0.85;

    // IMPORTANT — always return the same widget tree structure regardless of
    // whether the shader is loaded yet.
    //
    // Previously, a null shader caused an early return of
    // `ClipPath → Container → child`. Once the shader loaded and `setState`
    // fired, the build switched to `ClipPath → _LightweightGlassEffect → child`.
    // Flutter saw a type change at the same slot (Container ≠
    // _LightweightGlassEffect) and tore down the entire subtree, calling
    // `initState` on every descendant StatefulWidget. This broke scroll
    // positions, controllers, and any user State inside the glass surface.
    //
    // Fix: pass the (nullable) shader directly to _LightweightGlassEffect.
    // The render object detects a null shader and paints a tinted passthrough
    // instead of the full glass effect — visually identical to the old fallback
    // but with a stable Element identity.

    final Widget effect = _LightweightGlassEffect(
      shader: shader,
      settings: settings,
      shape: widget.shape,
      skipBlur: skipBlur,
      glowIntensity: widget.glowIntensity,
      densityFactor: widget.densityFactor,
      indicatorWeight: widget.indicatorWeight,
      backdropLuma: backdropLuma,
      backgroundImage: _backgroundImage,
      backgroundKey: widget.backgroundKey,
      child: widget.child,
    );

    // ClipRRect/ClipRSuperellipse are preferred over ClipPath because Flutter
    // PR #177551 (3.41+) forwards these clip types to the iOS PlatformView
    // mutator stack, letting BackdropFilter clip correctly over PlatformViews.
    final shapeRadius = widget.shape.toBorderRadius();
    if (shapeRadius != null) {
      if (widget.shape.isSuperellipse) {
        return ClipRSuperellipse(borderRadius: shapeRadius, child: effect);
      }
      return ClipRRect(borderRadius: shapeRadius, child: effect);
    }
    return ClipPath(
      clipper: ShapeBorderClipper(shape: widget.shape.toOutlinedBorder()),
      child: effect,
    );
  }
}

class _LightweightGlassEffect extends SingleChildRenderObjectWidget {
  const _LightweightGlassEffect({
    required this.shader,
    required this.settings,
    required this.shape,
    required this.skipBlur,
    required this.glowIntensity,
    required this.densityFactor,
    required this.indicatorWeight,
    required this.backdropLuma,
    this.backgroundImage,
    this.backgroundKey,
    required super.child,
  });

  final ui.FragmentShader? shader;
  final LiquidGlassSettings settings;
  final LiquidShape shape;
  final bool skipBlur;
  final double glowIntensity;
  final double densityFactor;
  final double indicatorWeight;
  final double backdropLuma;
  final ui.Image? backgroundImage;
  final GlobalKey? backgroundKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLightweightGlass(
      shader: shader,
      settings: settings,
      shape: shape,
      skipBlur: skipBlur,
      glowIntensity: glowIntensity,
      densityFactor: densityFactor,
      indicatorWeight: indicatorWeight,
      backdropLuma: backdropLuma,
      backgroundImage: backgroundImage,
      backgroundKey: backgroundKey,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderLightweightGlass renderObject,
  ) {
    renderObject
      ..shader = shader
      ..settings = settings
      ..shape = shape
      ..skipBlur = skipBlur
      ..glowIntensity = glowIntensity
      ..densityFactor = densityFactor
      ..indicatorWeight = indicatorWeight
      ..backdropLuma = backdropLuma
      ..backgroundImage = backgroundImage
      ..backgroundKey = backgroundKey;
  }
}

class _RenderLightweightGlass extends RenderProxyBox
    with TransformTrackingRenderObjectMixin {
  _RenderLightweightGlass({
    required ui.FragmentShader? shader,
    required LiquidGlassSettings settings,
    required LiquidShape shape,
    required bool skipBlur,
    required double glowIntensity,
    required double densityFactor,
    required double indicatorWeight,
    required double backdropLuma,
    ui.Image? backgroundImage,
    GlobalKey? backgroundKey,
  })  : _shader = shader,
        _settings = settings,
        _shape = shape,
        _skipBlur = skipBlur,
        _glowIntensity = glowIntensity,
        _densityFactor = densityFactor,
        _indicatorWeight = indicatorWeight,
        _backdropLuma = backdropLuma,
        _backgroundImage = backgroundImage,
        _backgroundKey = backgroundKey,
        _cachedLightCos = math.cos(settings.lightAngle),
        _cachedLightSin = -math.sin(settings.lightAngle);

  @override
  void onTransformChanged() {
    markNeedsPaint();
  }

  ui.FragmentShader? _shader;
  ui.FragmentShader? get shader => _shader;
  set shader(ui.FragmentShader? value) {
    if (_shader == value) return;
    final wasCompositing = alwaysNeedsCompositing;
    _shader = value;
    // alwaysNeedsCompositing depends on _shader (null → non-null on first async
    // load). Notify the framework so _updateCompositingBits() re-evaluates;
    // without this the stale needsCompositing=false bit persists.
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  LiquidGlassSettings _settings;
  LiquidGlassSettings get settings => _settings;
  set settings(LiquidGlassSettings value) {
    if (_settings == value) return;
    // Invalidate cached filter when blur or saturation changes.
    if (value.effectiveBlur != _settings.effectiveBlur ||
        value.effectiveSaturation != _settings.effectiveSaturation) {
      _cachedBlurFilter = null;
    }
    // Recompute trig only when lightAngle actually changes.
    if (value.lightAngle != _settings.lightAngle) {
      _cachedLightCos = math.cos(value.lightAngle);
      _cachedLightSin = -math.sin(value.lightAngle);
    }
    final wasCompositing = alwaysNeedsCompositing;
    _settings = value;
    // alwaysNeedsCompositing depends on effectiveBlur. If blur crosses zero
    // the compositing bit must be re-evaluated by the framework.
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  LiquidShape _shape;
  LiquidShape get shape => _shape;
  set shape(LiquidShape value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
  }

  bool _skipBlur;
  bool get skipBlur => _skipBlur;
  set skipBlur(bool value) {
    if (_skipBlur == value) return;
    final wasCompositing = alwaysNeedsCompositing;
    _skipBlur = value;
    // alwaysNeedsCompositing depends on _skipBlur. Dirty the compositing bit
    // so the framework re-evaluates when blur-skipping toggles.
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  double _glowIntensity;
  double get glowIntensity => _glowIntensity;
  set glowIntensity(double value) {
    if (_glowIntensity == value) return;
    _glowIntensity = value;
    markNeedsPaint();
  }

  double _densityFactor;
  double get densityFactor => _densityFactor;
  set densityFactor(double value) {
    if (_densityFactor == value) return;
    _densityFactor = value;
    markNeedsPaint();
  }

  double _indicatorWeight;
  double get indicatorWeight => _indicatorWeight;
  set indicatorWeight(double value) {
    if (_indicatorWeight == value) return;
    _indicatorWeight = value;
    markNeedsPaint();
  }

  double _backdropLuma;
  double get backdropLuma => _backdropLuma;
  set backdropLuma(double value) {
    if (_backdropLuma == value) return;
    _backdropLuma = value;
    markNeedsPaint();
  }

  ui.Image? _backgroundImage;
  set backgroundImage(ui.Image? value) {
    if (_backgroundImage == value) return;
    _backgroundImage = value;
    markNeedsPaint();
  }

  GlobalKey? _backgroundKey;
  set backgroundKey(GlobalKey? value) {
    if (_backgroundKey == value) return;
    _backgroundKey = value;
    markNeedsPaint();
  }

  // ── Cached light direction (Task 1.3) ─────────────────────────────────────
  // Matches the caching pattern in LiquidGlassRenderObject._cachedLightDir.
  // Avoids recomputing cos/sin on every _updateShaderUniforms call.
  double _cachedLightCos;
  double _cachedLightSin;

  // ── Cached backdrop filter (Task 1.2) ─────────────────────────────────────
  // The composed blur+saturation ImageFilter is rebuilt only when blur sigma
  // or saturation changes — not on every frame. Eliminates a 20-element
  // List<double> allocation + 2 object allocations per frame per glass widget.
  ui.ImageFilter? _cachedBlurFilter;
  double _cachedFilterBlur = -1;
  double _cachedFilterSat = -1;

  /// Returns the cached blur+saturation filter, rebuilding only when the
  /// blur sigma or saturation has changed since the last call.
  ui.ImageFilter _getBlurFilter(double blurSigma, double sat) {
    if (_cachedBlurFilter != null &&
        _cachedFilterBlur == blurSigma &&
        _cachedFilterSat == sat) {
      return _cachedBlurFilter!;
    }

    // Standard saturation ColorFilter matrix (ITU-R BT.709 luminance weights).
    const double rw = 0.2126, gw = 0.7152, bw = 0.0722;
    final ui.ColorFilter satFilter = ui.ColorFilter.matrix(<double>[
      rw + (1 - rw) * sat,
      gw - gw * sat,
      bw - bw * sat,
      0,
      0,
      rw - rw * sat,
      gw + (1 - gw) * sat,
      bw - bw * sat,
      0,
      0,
      rw - rw * sat,
      gw - gw * sat,
      bw + (1 - bw) * sat,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);

    _cachedBlurFilter = ui.ImageFilter.compose(
      outer: satFilter,
      inner: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
    );
    _cachedFilterBlur = blurSigma;
    _cachedFilterSat = sat;
    return _cachedBlurFilter!;
  }

  // Only force compositing when we actually push a BackdropFilterLayer
  // (shader available AND blur > 0 AND not skipped by ancestor blur).
  // In the fallback path (null shader or zero blur), we just draw a tinted
  // rect — no compositing layer needed. Reduces layer tree depth on
  // low-end devices where the framework overhead is the bottleneck.
  @override
  bool get alwaysNeedsCompositing =>
      _shader != null && !_skipBlur && _settings.effectiveBlur > 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    if (_shader == null) {
      final paint = Paint()
        ..color = _settings.effectiveGlassColor.withValues(alpha: 0.15);
      context.canvas.drawRect(offset & size, paint);
      super.paint(context, offset);
      return;
    }

    final blurSigma = _settings.effectiveBlur;
    if (blurSigma > 0 && !_skipBlur) {
      // Compose blur + saturation to match Premium's background treatment.
      // Premium applies Gaussian blur then boosts saturation on the blurred result,
      // giving it richer, deeper colours (the "blue sky through glass" effect).
      // We replicate this by composing: outer=saturationFilter, inner=blurFilter.
      // Result: the blurred background seen through Standard glass is saturated
      // identically to Premium — no background texture capture required.
      //
      // The filter is cached on the render object and only rebuilt when blur
      // sigma or saturation changes — see _getBlurFilter().
      final filter = _getBlurFilter(
        blurSigma,
        _settings.effectiveSaturation,
      );

      context.pushLayer(
        BackdropFilterLayer(filter: filter),
        (context, offset) {
          _paintGlassContent(context, offset);
        },
        offset,
      );
    } else {
      _paintGlassContent(context, offset);
    }
  }

  void _paintGlassContent(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final matrix = canvas.getTransform();

    final canvasPhysicalX = matrix[12];
    final canvasPhysicalY = matrix[13];
    final scaleX = matrix[0];
    final scaleY = matrix[5];

    final uOrigin = Offset(
      canvasPhysicalX + (offset.dx * scaleX),
      canvasPhysicalY + (offset.dy * scaleY),
    );

    final uScale = Offset(scaleX, scaleY);

    Offset bgRelativeOffset = Offset.zero;
    Size bgSize = const Size(1, 1);

    if (_backgroundKey != null && _backgroundImage != null) {
      final boundary = _safeGetBoundary(_backgroundKey);
      if (boundary != null) {
        final bgGlobalPos = boundary.localToGlobal(Offset.zero);
        final indGlobalPos = localToGlobal(Offset.zero);
        bgRelativeOffset = indGlobalPos - bgGlobalPos;
        bgSize = Size(
          _backgroundImage!.width.toDouble(),
          _backgroundImage!.height.toDouble(),
        );
      }
    }

    _updateShaderUniforms(size, uOrigin, uScale, bgRelativeOffset, bgSize);

    if (_backgroundImage != null) {
      _shader!.setImageSampler(
        0,
        _backgroundImage!,
        filterQuality: FilterQuality.medium, // coverage:ignore-line
      );
    } else {
      _shader!.setImageSampler(
        0,
        LightweightLiquidGlass.dummyImage,
        filterQuality: FilterQuality.medium, // coverage:ignore-line
      );
    }

    final paint = Paint()..shader = _shader!;
    canvas.drawRect(offset & size, paint);

    super.paint(context, offset);
  }

  void _updateShaderUniforms(Size size, Offset physicalOrigin,
      Offset physicalScale, Offset bgOrigin, Size bgSize) {
    // _updateShaderUniforms is only ever called from _paintGlassContent,
    // which is only reached when _shader != null (guarded in paint()).
    // The assertion makes the non-nullability explicit for the analyser.
    final shader = _shader!;
    int index = 0;

    // 0, 1: uSize (vec2) - Layout Pixels (Logical)
    shader.setFloat(index++, size.width);
    shader.setFloat(index++, size.height);

    // 2, 3: uOrigin (vec2) - Physical Pixels (Window Absolute)
    shader.setFloat(index++, physicalOrigin.dx);
    shader.setFloat(index++, physicalOrigin.dy);

    // 4, 5, 6, 7: uGlassColor (vec4)
    //
    // Pass glassColor.alpha unchanged — the shader applies a Fresnel-based
    // modulation in Stage 2.5 (lightweight_glass.frag) so the alpha creates
    // a depth gradient (full at rim, 12% at center) instead of a flat fill.
    // This correctly approximates the 3D SDF Fresnel of the Premium path.
    //
    // Whiten veil: lift glassColor toward white by a ramp of
    // [LiquidGlassSettings.whitenStrength]. This is the Standard-path
    // approximation of the Premium shader's whiten — the Fresnel modulation
    // keeps the center lighter (content reads through) and the rim brighter.
    // Because it is a tint overlay rather than a backdrop color operation, it
    // also works over platform views, where BackdropFilter color ops don't
    // apply. The gain calibrates the veil so a single whitenStrength value
    // reads close to the Premium path's gated whiten at the same value.
    final double whitenStrength =
        _settings.effectiveWhitenStrength.clamp(0.0, 1.0).toDouble();
    const double kWhitenVeilGain = 1.5;
    final double whitenVeil =
        (whitenStrength * kWhitenVeilGain).clamp(0.0, 1.0).toDouble();
    final color = whitenVeil <= 0.0
        ? _settings.effectiveGlassColor
        // Whitelisted: Used in Color.lerp for glass veil tint math anchor, not a theme color.
        : Color.lerp(_settings.effectiveGlassColor, const Color(0xFFFFFFFF),
            whitenVeil)!;
    shader.setFloat(index++, (color.r * 255.0).round().clamp(0, 255) / 255.0);
    shader.setFloat(index++, (color.g * 255.0).round().clamp(0, 255) / 255.0);
    shader.setFloat(index++, (color.b * 255.0).round().clamp(0, 255) / 255.0);
    shader.setFloat(index++, color.a.clamp(0.0, 1.0));

    // 8: uThickness (float)
    shader.setFloat(index++, _settings.effectiveThickness);

    // 9, 10: uLightDirection (vec2) - [cos(angle), -sin(angle)]
    // lightAngle is in radians (per LiquidGlassSettings API).
    // Uses cached values — trig only recomputed when lightAngle changes.
    shader.setFloat(index++, _cachedLightCos);
    shader.setFloat(index++, _cachedLightSin);

    // 11: uLightIntensity (float)
    shader.setFloat(index++, _settings.effectiveLightIntensity);

    // 12: uAmbientStrength (float)
    //
    // Problem: LiquidGlassSettings.figma() hardcodes ambientStrength to 0.1.
    // In the lightweight shader, bodyColor = glassColor.rgb * (ambient + boost),
    // so white * 0.21 ≈ dark grey — far darker than the user intends.
    //
    // Fix: Derive a floor from the glass color's "brightness intent":
    //   brightnessIntent = alpha × luminance × 0.6
    //
    // The alpha encodes HOW OPAQUE the user wants the glass (opacity intent).
    // The luminance encodes HOW BRIGHT the glass color is.
    // Together they express: "how bright do you want the glass body to appear?"
    //
    // Examples:
    //   white @ alpha 0.6  (figma case): 0.6×1.0×0.6=0.36 → max(0.1,0.36)=0.36 ✓ Fixed
    //   white @ alpha 0.12 (standard):   0.12×1.0×0.6=0.07 → max(0.4,0.07)=0.4  ✓ Unchanged
    //   white @ alpha 0.2  (interactive):0.2×1.0×0.6=0.12  → max(0.3,0.12)=0.3  ✓ Unchanged
    //   white @ alpha 0.08 (bottomBar):  0.08×1.0×0.6=0.05 → max(0.5,0.05)=0.5  ✓ Unchanged
    //   dark glass @ alpha 0.8:          0.8×0.12×0.6=0.06 → max(0.1,0.06)=0.1  ✓ Unchanged
    //
    // This only affects the Skia/Web lightweight shader path.
    // Impeller uses a different physical model and is completely unaffected.
    final gc = _settings.effectiveGlassColor;
    final glassLuminance =
        0.2126 * gc.r + 0.7152 * gc.g + 0.0722 * gc.b; // ITU-R Rec.709
    final brightnessIntent = gc.a * glassLuminance * 0.6;
    final effectiveAmbient = math.max(
      _settings.effectiveAmbientStrength,
      brightnessIntent,
    );
    shader.setFloat(index++, effectiveAmbient);

    // 13: uSaturation (float)
    shader.setFloat(index++, _settings.effectiveSaturation);

    // 14: uRefractiveIndex (float)
    shader.setFloat(index++, _settings.effectiveRefractiveIndex);

    // 15: uChromaticAberration (float)
    shader.setFloat(index++, (_settings.chromaticAberration).clamp(0.0, 1.0));

    // 16: uCornerRadius (float) - Logical
    // For LiquidVerticalRoundedSuperellipse: write -1.0 to signal asymmetric mode.
    // Slots 24-27 (uData6) will carry the four per-corner radii in that case.
    double? cornerRadius;
    double topLeftR = 0.0;
    double topRightR = 0.0;
    double bottomRightR = 0.0;
    double bottomLeftR = 0.0;
    bool isAsymmetric = false;

    if (_shape is LiquidVerticalRoundedSuperellipse) {
      // Asymmetric mode: each pair of corners has a different radius.
      // topLeft == topRight == topRadius; bottomLeft == bottomRight == bottomRadius.
      final s = _shape as LiquidVerticalRoundedSuperellipse;
      final maxTop = math.min(size.width, size.height) / 2.0;
      final maxBot = math.min(size.width, size.height) / 2.0;
      topLeftR = s.topRadius.clamp(0.0, maxTop);
      topRightR = s.topRadius.clamp(0.0, maxTop);
      bottomRightR = s.bottomRadius.clamp(0.0, maxBot);
      bottomLeftR = s.bottomRadius.clamp(0.0, maxBot);
      isAsymmetric = true;
    } else {
      // effectiveRadius is obfuscation-safe: typed virtual dispatch on the
      // sealed LiquidShape hierarchy — not a dynamic property lookup or a
      // runtimeType.toString() heuristic (both break under --obfuscate).
      final maxRadius = math.min(size.width, size.height) / 2.0;
      cornerRadius = _shape.effectiveRadius.clamp(0.0, maxRadius);
    }

    shader.setFloat(index++, isAsymmetric ? -1.0 : cornerRadius!);

    // 17, 18: uScale (vec2) - Physical Scale (Includes DPR + Transforms)
    shader.setFloat(index++, physicalScale.dx);
    shader.setFloat(index++, physicalScale.dy);

    // 19: uGlowIntensity (float) - Interactive glow strength (0.0-1.0)
    shader.setFloat(index++, _glowIntensity.clamp(0.0, 1.0));

    // 20: uDensityFactor (float) - Elevation physics (0.0-1.0)
    shader.setFloat(index++, _densityFactor.clamp(0.0, 1.0));

    // 21: uIndicatorWeight (float) - Indicator style (0.0-1.0)
    shader.setFloat(index++, _indicatorWeight.clamp(0.0, 1.0));

    // 22 (uData5.z): uSpecularSharpnessF (float-encoded int)
    // 0.0=soft(n=8), 1.0=medium(n=16), 2.0=sharp(n=32)
    // PP2: Flutter's FragmentShader API only exposes setFloat (no setInt). We pass
    // 0.0/1.0/2.0 exactly and the shader does int(round()) to recover the integer.
    // The GPU compiler still sees literal-constant exponents per if/else branch.
    // NOTE: Previously declared as a separate `uniform float uSpecularSharpnessF`
    // at slot 24, but Dart only wrote 23 floats — so slot 24 was always 0 (soft).
    // Fixed: packed into uData5.z so the slot index matches exactly.
    shader.setFloat(index++, _settings.specularSharpness.glslIndex.toDouble());

    // 23 (uData5.w): backdropLuma — VQ4 content-adaptive strength
    // 0.15 = dark platform (richer glass), 0.85 = light platform (subtler glass)
    shader.setFloat(index++, _backdropLuma.clamp(0.0, 1.0));

    // 24..27 (uData6): per-corner radii for asymmetric shapes (GlassModalSheet).
    shader.setFloat(index++, topLeftR);
    shader.setFloat(index++, topRightR);
    shader.setFloat(index++, bottomRightR);
    shader.setFloat(index++, bottomLeftR);

    // 28..31 (uData7): Background texture tracking
    shader.setFloat(index++, bgOrigin.dx);
    shader.setFloat(index++, bgOrigin.dy);
    shader.setFloat(index++, bgSize.width);
    shader.setFloat(index++, bgSize.height);

    // 32: uEdgeAbsorption — Beer-Lambert meniscus rim darkening [0..1].
    // Passed directly — what the caller sets is what the shader gets.
    shader.setFloat(index++, _settings.edgeAbsorption.clamp(0.0, 1.0));

    // 33: uFresnelStrength — grazing-angle Fresnel rim scale [0..∞].
    // Matches the uniform wired in liquid_glass_render.frag via uEdgeConfig.y.
    // Default 1.0 = calibrated iOS 26 baseline (0.10 * adaptiveStrength in shader).
    shader.setFloat(index++, _settings.fresnelStrength.clamp(0.0, 4.0));

    // 34: uBodyMode — 0.0 = adaptive, 1.0 = clear.
    shader.setFloat(
        index++, _settings.bodyMode == GlassBodyMode.clear ? 1.0 : 0.0);
  }
}
