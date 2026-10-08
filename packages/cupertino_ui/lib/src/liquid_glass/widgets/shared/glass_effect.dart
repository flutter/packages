// ignore_for_file: require_trailing_commas

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import '../../src/renderer/glass_backdrop_group.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/scheduler.dart';
import '../../theme/glass_theme.dart';
import '../../widgets/interactive/liquid_glass_scope.dart';
import 'inherited_liquid_glass.dart';

import '../../types/glass_quality.dart';
import 'adaptive_glass.dart';

/// Enhanced glass renderer specifically for interactive indicators.
///
/// Uses a specialized shader on Skia/Web to match Impeller's visual quality
/// with magnification effects, enhanced rim lighting, and radial brightness.
///
/// On Impeller with premium quality, it uses the native LiquidGlass renderer.
/// On Skia/Web or standard quality, it uses the enhanced GlassEffect
/// shader with magnification and structural rim effects.
class GlassEffect extends StatefulWidget {
  /// Creates a new [GlassEffect].
  const GlassEffect({
    required this.shape,
    required this.settings,
    required this.interactionIntensity,
    required this.child,
    this.quality = GlassQuality.standard,
    this.densityFactor = 0.0,
    this.backgroundKey,
    this.ambientRim = 0.1,
    this.baseAlphaMultiplier = 0.2,
    this.edgeAlphaMultiplier = 0.4,
    this.rimThickness = 0.5,
    this.rimSmoothing = 1.5,
    this.clipExpansion = EdgeInsets.zero,
    super.key,
  });

  /// The child widget to display.
  final Widget child;

  /// The shape of the glass effect.
  final LiquidShape shape;

  /// The settings for the liquid glass effect.
  final LiquidGlassSettings settings;

  /// The render quality of the glass.
  final GlassQuality quality;

  /// Defaults to 0.0.
  final double densityFactor;

  /// GlobalKey of a RepaintBoundary wrapping the background content.
  /// Used for Skia/Web background sampling.
  final GlobalKey? backgroundKey;

  /// Interaction intensity (0.0 = resting, 1.0 = fully active)
  /// Drives magnification and enhancement effects
  final double interactionIntensity;

  /// Minimum rim brightness regardless of light direction (default: 0.1)
  final double ambientRim;

  /// Center transparency multiplier (default: 0.2)
  final double baseAlphaMultiplier;

  /// Edge opacity multiplier (default: 0.4)
  final double edgeAlphaMultiplier;

  /// Rim offset/thickness in logical pixels (default: 0.5)
  final double rimThickness;

  /// Rim edge smoothing multiplier (default: 1.5)
  final double rimSmoothing;

  /// Extra clip budget forwarded to [LiquidGlass.withOwnLayer] on the Impeller
  /// premium path.  Use this to prevent the glass BackdropFilterLayer from
  /// hard-clipping pixels that an ancestor Transform (e.g. jelly physics) has
  /// pushed outside the tight geometry bounds.
  ///
  /// Defaults to [EdgeInsets.zero] — no extra cost for static glass.
  final EdgeInsets clipExpansion;

  static ui.FragmentProgram? _cachedProgram;
  static bool _isPreparing = false;

  /// Detects if Impeller rendering engine is active
  static bool get _canUseImpeller => ui.ImageFilter.isShaderFilterSupported;

  // Dummy 1x1 transparent image for when no background is captured.
  // Lazily allocated on first paint to guarantee zero GPU raster work
  // during preWarm() or initialize() before runApp().
  static ui.Image? _dummyImage;

  /// Returns the cached 1×1 transparent dummy image, creating it lazily on demand.
  static ui.Image get dummyImage => _dummyImage ??= _createDummyImage();

  static ui.Image _createDummyImage() {
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(1, 1);
    picture.dispose();
    return image;
  }

  /// Resets static shader state for testing.
  @visibleForTesting
  static void resetForTesting() {
    _cachedProgram = null;
    _isPreparing = false;
    _dummyImage?.dispose();
    _dummyImage = null;
  }

  /// Pre-warms the shaders for this effect.
  static Future<void> preWarm() async {
    if (_cachedProgram != null || _isPreparing) return;
    _isPreparing = true;
    const path =
        'packages/liquid_glass_widgets/shaders/interactive_indicator.frag';
    const testPath = 'shaders/interactive_indicator.frag';

    try {
      ui.FragmentProgram program;
      try {
        program = await ui.FragmentProgram.fromAsset(path);
      } catch (_) {
        // Fallback for unit tests where package prefix may not be resolved
        program = await ui.FragmentProgram.fromAsset(testPath);
      }
      _cachedProgram = program;
    } catch (e) {
      debugPrint('[GlassEffect] Pre-warm failed: $e');
    } finally {
      _isPreparing = false;
    }
  }

  @override
  State<GlassEffect> createState() => _GlassEffectState();
}

class _GlassEffectState extends State<GlassEffect>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ui.FragmentShader? _localShader;
  bool _isDisposed = false;
  ui.Image? _backgroundImage;
  late Ticker _ticker;
  Size? _lastCaptureSize;
  Offset? _lastCapturePosition;
  // Web only: guards against overlapping async captures.
  bool _isCapturingAsync = false;
  // Device pixel ratio — updated in didChangeDependencies so it is always
  // current when _captureBackgroundSync / _captureBackgroundAsync runs.
  double _devicePixelRatio = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Skip shader init entirely in minimal quality — build() returns early via
    // the _FrostedFallback path and the shader is never used.
    if (widget.quality != GlassQuality.minimal) {
      _initShader();
    }

    _ticker = createTicker(_handleTick);

    // Defer ticker update until after first frame to ensure shader is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateTicker();
      }
    });
  }

  @override
  void didUpdateWidget(covariant GlassEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quality != widget.quality) {
      if (_activeShader == null) {
        _initShader();
      }
    }
    _updateTicker();
  }

  GlobalKey? _cachedScopeKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedScopeKey = LiquidGlassScope.of(context);
    // Keep DPR in sync — changes on orientation, accessibility zoom, or
    // moving between displays with different densities.
    _devicePixelRatio = View.of(context).devicePixelRatio;
    _updateTicker();
  }

  /// Halts background-capture Tickers during app lifecycle transitions.
  ///
  /// Stopping captures on [AppLifecycleState.inactive] / [paused] prevents
  /// GPU texture creation/destruction from racing with [surfaceChanged] on
  /// the raster thread — the root cause of the ANR observed on Vulkan devices.
  /// Captures restart one frame after [resumed] to let the new surface
  /// stabilise before any [toImageSync] calls.
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

  GlobalKey? get _effectiveKey => widget.backgroundKey ?? _cachedScopeKey;

  void _updateTicker() {
    // Background capture requirements:
    //  1. Widget is actively interacting (cost only paid during gesture)
    //  2. A valid capture key is available
    //  3. blur > 0 — when blur is 0 the component intentionally uses synthetic
    //     glass (e.g. GlassSwitch thumb). Capturing the background would let the
    //     green track bleed through as a dark/tinted frosted overlay, which
    //     contradicts the intended white glass bloom effect.
    final bool shouldCapture = widget.interactionIntensity > 0.01 &&
        _effectiveKey != null &&
        widget.settings.blur > 0.0;
    if (shouldCapture) {
      if (!_ticker.isActive) {
        _ticker.start();
        // debugPrint(
        //     '[GlassEffect] 📸 Starting capture loop. Intensity: ${widget.interactionIntensity.toStringAsFixed(2)}');
      }
    } else {
      if (_ticker.isActive) {
        _ticker.stop();
        _backgroundImage?.dispose();
        _backgroundImage = null;
        // debugPrint(
        //     '[GlassEffect] 📸 Interaction finished, cleared snapshot.');
      }
    }
  }

  void _handleTick(Duration elapsed) {
    if (_isDisposed) return; // belt-and-suspenders: post-frame callbacks can
    // outlive dispose() on rapid navigation; bail out before any GPU access.
    final key = _effectiveKey;
    if (key == null) return;

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    // Guard: boundary may not be laid out yet (e.g. when the glass widget
    // is mounted early for Standard quality before the first frame completes).
    if (!boundary.hasSize) return;

    final currentSize = boundary.size;
    final currentPos = (key.currentContext?.findRenderObject() as RenderBox?)
        ?.localToGlobal(Offset.zero);

    // Capture on geometry change always; during interaction capture every frame
    // since toImageSync() is synchronous (no GPU readback, no CPU copy).
    final bool isInteracting = widget.interactionIntensity > 0.05;
    bool needsCapture = _backgroundImage == null;
    needsCapture |= _lastCaptureSize != currentSize;
    needsCapture |= _lastCapturePosition != currentPos;
    needsCapture |= isInteracting; // every frame during drag — free cost

    if (needsCapture) {
      _captureBackground(boundary, currentSize, currentPos);
    }
  }

  /// Background capture — platform-adaptive.
  ///
  /// **Native (Impeller / Skia):** [RenderRepaintBoundary.toImageSync] —
  /// fully synchronous, stays in GPU memory, zero CPU←GPU readback.
  /// Runs every frame during active interaction at negligible cost.
  ///
  /// **Web (CanvasKit):** async [RenderRepaintBoundary.toImage] at
  /// `pixelRatio: 1.0`. [toImageSync] is unreliable across CanvasKit versions
  /// and unavailable in the legacy HTML renderer. The async path is still a
  /// significant improvement over the previous `pixelRatio: dpr` approach —
  /// same 1/DPR² memory reduction, with a 1-frame delivery lag during a drag.
  /// An `_isCapturingAsync` guard prevents overlapping futures.
  void _captureBackground(
      RenderRepaintBoundary boundary, Size size, Offset? pos) {
    assert(() {
      if (boundary.size.isEmpty) {
        debugPrint(
          '⚠️ [GlassEffect] Background boundary has zero size.\n'
          '   Ensure GlassBackgroundSource (or GlassPage) wraps\n'
          '   a widget with non-zero dimensions.',
        );
      }
      return true;
    }());

    if (kIsWeb) {
      _captureBackgroundAsync(boundary, size, pos);
    } else {
      _captureBackgroundSync(boundary, size, pos);
    }
  }

  /// Synchronous capture path for native (non-web) platforms.
  void _captureBackgroundSync(
      RenderRepaintBoundary boundary, Size size, Offset? pos) {
    try {
      // Capture at the device's physical pixel ratio so the background texture
      // has full-DPR resolution. This gives the bilinear filter in
      // interactive_indicator.frag genuine sub-pixel texels to interpolate
      // across, eliminating the blocky 3×3 pixel "staircase" aliasing on
      // Retina/3× displays when pixelRatio: 1.0 was used.
      final dpr = _devicePixelRatio;
      final image = boundary.toImageSync(pixelRatio: dpr);
      // Guard: if the widget was disposed between the toImageSync call and
      // this point (possible during rapid navigation), dispose the image
      // immediately rather than leaking it into a dead State.
      if (!mounted) {
        image.dispose();
        return;
      }
      _backgroundImage?.dispose();
      _backgroundImage = image;
      _lastCaptureSize = size;
      _lastCapturePosition = pos;
      setState(() {});
    } catch (e) {
      assert(() {
        debugPrint('[GlassEffect] toImageSync failed: $e');
        return true;
      }());
    }
  }

  /// Async capture path for web (CanvasKit / HTML renderer).
  ///
  /// [toImageSync] is not reliably available across all CanvasKit builds and
  /// is absent in the legacy HTML renderer. Using async at `pixelRatio: 1.0`
  /// still achieves the same memory reduction with an acceptable 1-frame lag.
  Future<void> _captureBackgroundAsync(
      RenderRepaintBoundary boundary, Size size, Offset? pos) async {
    if (_isCapturingAsync) return; // prevent overlapping futures
    _isCapturingAsync = true;
    try {
      // Web: async at full DPR. Still a 1-frame lag during drag but now
      // provides full-resolution texels for the bilinear filter.
      final image = await boundary.toImage(
          pixelRatio: _devicePixelRatio); // coverage:ignore-line
      if (mounted) {
        setState(() {
          _backgroundImage?.dispose();
          _backgroundImage = image;
          _lastCaptureSize = size;
          _lastCapturePosition = pos;
        });
      }
    } catch (e) {
      assert(() {
        debugPrint('[GlassEffect] toImage (web) failed: $e');
        return true;
      }());
    } finally {
      _isCapturingAsync = false;
    }
  }

  Future<void> _initShader() async {
    // Check if shader is already available
    if (GlassEffect._cachedProgram == null) {
      // Shader not ready, load it asynchronously
      await GlassEffect.preWarm();

      // Force rebuild now that shader is ready
      if (mounted) {
        setState(() {});
      }
    }

    if (GlassEffect._cachedProgram != null && _localShader == null) {
      if (mounted) {
        setState(() {
          // Always create a local shader instance for state isolation
          _localShader = GlassEffect._cachedProgram!.fragmentShader();
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    // Null backgroundImage BEFORE disposing the shader to break the reference
    // chain: _backgroundImage → render object → engine layer tree → GPU texture.
    // On Mali GPUs, if the shader’s DlRuntimeEffectColorSource retains a
    // texture reference during isolate shutdown, the Vulkan mutex is accessed
    // after destruction (Crash 2).
    _backgroundImage?.dispose();
    _backgroundImage = null;
    _localShader?.dispose();
    _localShader = null;
    super.dispose();
  }

  ui.FragmentShader? get _activeShader => _localShader;

  @override
  Widget build(BuildContext context) {
    // 1. Detect Environment & Constraints
    final bool isImpeller = !kIsWeb && GlassEffect._canUseImpeller;

    final bool avoidsRefraction = context
            .dependOnInheritedWidgetOfExactType<InheritedLiquidGlass>()
            ?.avoidsRefraction ??
        false;

    // 2. Resolve the background refraction source
    final effectiveKey = widget.backgroundKey ?? LiquidGlassScope.of(context);
    final shader = _activeShader;

    // VQ4: Content-adaptive glass strength proxy.
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final backdropLuma = isDark ? 0.15 : 0.85;

    // 3. Selection Logic:

    // Path A: Minimal (shader-free — BackdropFilter + ClipPath via _FrostedFallback)
    // Routes through AdaptiveGlass which uses ClipPath(ShapeBorderClipper) for
    // correct clipping on all shape types. No fragment shaders on any platform.
    //
    // IMPORTANT: always pass Clip.antiAlias here — never Clip.none.
    // clipExpansion is only relevant for the LiquidStretch jelly displacement
    // used in the full-shader path. _FrostedFallback has no displacement, so
    // Clip.none would skip clipping entirely and let BackdropFilter blur the
    // full rectangular bounds (the grey-square artifact).
    if (widget.quality == GlassQuality.minimal) {
      return AdaptiveGlass(
        shape: widget.shape,
        settings: widget.settings,
        quality: GlassQuality.minimal,
        useOwnLayer: true,
        clipBehavior: Clip.antiAlias,
        isInteractive: true,
        child: widget.child,
      );
    }

    // Path A2: Nested glass vibrancy fill (avoidsRefraction: true)
    //
    // Triggered when an ancestor GlassContainer (or any widget that sets
    // InheritedLiquidGlass.avoidsRefraction = true) is in the tree. A second
    // BackdropFilter inside the parent glass surface causes Impeller GPU tile-
    // memory thrash, missing surfaces, and visible compositor artifacts.
    //
    // The correct iOS 26 behaviour for nested glass is a UIVibrancyEffect-style
    // translucent tinted fill: no refraction, no blur, but rim and specular
    // highlights are preserved. _VibrancyFill delivers exactly this — zero GPU
    // compositor overhead, correct on all renderers including Skia and Web.
    if (avoidsRefraction) {
      return AdaptiveGlass.vibrancy(
        shape: widget.shape,
        settings: widget.settings,
        child: widget.child,
      );
    }

    // Path B: Native Impeller (Premium only)
    if (isImpeller && widget.quality == GlassQuality.premium) {
      // No outer ClipPath here: a ClipPath clips in the widget's LOCAL (pre-jelly)
      // coordinate space. When the parent Transform stretches the indicator taller
      // during jelly physics, the already-clipped content has a hard edge at the
      // original pill height, which becomes visible as a cutoff after scaling.
      // LiquidGlass.withOwnLayer performs its own internal ClipPath for the child,
      // and the shader uses SDF alpha masking for the pill boundary — both of which
      // DO stretch correctly with the parent Transform.
      //
      // Capture path: when _backgroundImage is available (the ticker has already
      // captured the background boundary at least once), pass it directly to
      // LiquidGlass.withOwnLayer so the shader reads from the deterministic
      // captured texture instead of emitting a live BackdropFilterLayer.
      // This eliminates the Impeller compositor ordering dependency that caused
      // the opaque-white indicator bug (#99) while preserving the full 3D
      // geometry rendering pipeline. Performance is strictly better: one
      // toImageSync capture per frame (already happening) replaces a heavyweight
      // BackdropFilterLayer compositor pass.
      //
      // Falls back to the live BackdropFilter path if no capture is available
      // yet (first frame before the ticker has fired) — zero visual difference
      // since the indicator is invisible until thickness > 0.01 anyway.
      //
      // coverage:ignore-start
      // Unreachable in unit tests: isImpeller=false (no real GPU renderer).
      // Tested on physical device / Impeller integration tests only.
      // An indicator lies over the glass it moves on, so it stays out of a
      // GlassBackdropGroup the bar may be in: glass in a group can't see
      // the glass of the same group below it.
      return GlassBackdropGroup(
        enabled: false,
        child: LiquidGlass.withOwnLayer(
          shape: widget.shape,
          settings: widget.settings,
          clipExpansion: widget.clipExpansion,
          captureImage: _backgroundImage,
          captureOriginInScreenSpace: _lastCapturePosition ?? Offset.zero,
          child: widget.child,
        ),
      );
      // coverage:ignore-end
    }

    // 4. Resolve if we can use the high-fidelity refraction shader
    final bool canUseRefraction = effectiveKey != null && !avoidsRefraction;

    // Standard-path structural normalization for interactive_indicator.frag.
    // The Premium Impeller path renders a real 3D bevel with natural gradient
    // falloff. The 2D indicator shader draws a flat rim that reads as heavier
    // at the same parameter values. Scaling these structural params down brings
    // the pill's visual weight in line with the Premium bevel.
    //
    // NOTE: This mirrors the AdaptiveGlass normalization for lightweight_glass.frag
    // (cards/buttons). Both are intentional Standard-path normalization sites —
    // each scoped to its own shader's parameter space.
    // Premium exits above via LiquidGlass.withOwnLayer; this block never runs there.
    final double effectiveRimThickness = widget.quality == GlassQuality.standard
        ? widget.rimThickness * 0.35
        : widget.rimThickness;
    final double effectiveAmbientRim = widget.quality == GlassQuality.standard
        ? widget.ambientRim * 0.7
        : widget.ambientRim;
    final double effectiveEdgeAlpha = widget.quality == GlassQuality.standard
        ? widget.edgeAlphaMultiplier * 0.7
        : widget.edgeAlphaMultiplier;

    // Normalise LiquidGlassSettings for the Standard path.
    // The 2D interactive_indicator.frag renders thickness and specular highlights
    // heavier than the Impeller 3D path at equal parameter values.
    // Ratios are identical to AdaptiveGlass (thickness × 0.4, lightIntensity × 0.6)
    // so the visual language stays consistent between static and interactive surfaces.
    //
    // NOTE: glassColor.alpha is intentionally NOT normalised here (unlike AdaptiveGlass).
    // Interactive thumb body opacity is already governed by
    //   standardBaseAlpha = baseAlphaMultiplier × interactionIntensity
    // inside the shader — normalising alpha here would double-count it.
    final LiquidGlassSettings effectiveSettings;
    if (widget.quality == GlassQuality.standard) {
      final base = widget.settings;
      effectiveSettings = base.copyWith(
        thickness: (base.effectiveThickness * 0.4).clamp(0.0, double.infinity),
        lightIntensity: (base.effectiveLightIntensity * 0.6).clamp(0.0, 10.0),
        ambientStrength: (base.effectiveAmbientStrength * 0.25).clamp(0.0, 1.0),
        glowIntensity: (base.glowIntensity * 0.50).clamp(0.0, 5.0),
      );
    } else {
      effectiveSettings = widget.settings;
    }

    // Path B: High-Fidelity Refraction Shader (Custom GLSL)
    // This is the "New Shader" featuring magnification and liquid distortion.
    // No outer ClipPath: the shader computes SDF alpha internally for the pill
    // boundary. An outer ClipPath would clip in local (pre-jelly) space,
    // producing a hard cutoff at the original pill height when the parent
    // jelly Transform stretches the indicator vertically. Blur is constrained
    // to the pill path via an inner ClipPathLayer in the render object's paint.
    if (canUseRefraction && shader != null) {
      return _InteractiveIndicatorEffect(
        shader: shader,
        settings: effectiveSettings,
        shape: widget.shape,
        interactionIntensity: widget.interactionIntensity,
        densityFactor: widget.densityFactor,
        backdropLuma: backdropLuma,
        backgroundImage: _backgroundImage,
        backgroundKey: effectiveKey,
        devicePixelRatio: View.of(context).devicePixelRatio,
        ambientRim: effectiveAmbientRim,
        baseAlphaMultiplier: widget.baseAlphaMultiplier,
        edgeAlphaMultiplier: effectiveEdgeAlpha,
        rimThickness: effectiveRimThickness,
        rimSmoothing: widget.rimSmoothing,
        edgeAbsorption: effectiveSettings.edgeAbsorption,
        clipExpansion: widget.clipExpansion,
        child: widget.child,
      );
    }

    // Path C: Unified Indicator Fallback
    // Even if no background image is available, we use the custom indicator shader
    // to preserve the signature lighting, rim highlights, and structural "vibe".
    // The shader will automatically switch to "Synthetic Frost" mode.
    // No outer ClipPath — same reason as Path B (jelly clipping).
    if (shader != null) {
      return _InteractiveIndicatorEffect(
        shader: shader,
        settings: effectiveSettings.copyWith(blur: 0),
        shape: widget.shape,
        interactionIntensity: widget.interactionIntensity,
        densityFactor: widget.densityFactor,
        backdropLuma: backdropLuma,
        backgroundImage: null, // Fallback mode
        backgroundKey: null,
        devicePixelRatio: View.of(context).devicePixelRatio,
        ambientRim: effectiveAmbientRim,
        baseAlphaMultiplier: widget.baseAlphaMultiplier,
        edgeAlphaMultiplier: effectiveEdgeAlpha,
        rimThickness: effectiveRimThickness,
        rimSmoothing: widget.rimSmoothing,
        edgeAbsorption: effectiveSettings.edgeAbsorption,
        clipExpansion: widget.clipExpansion,
        child: widget.child,
      );
    }

    // Ultra-clean fallback if shader hasn't loaded yet — transparent, no clip.
    return widget.child;
  }
}

class _InteractiveIndicatorEffect extends SingleChildRenderObjectWidget {
  const _InteractiveIndicatorEffect({
    required this.shader,
    required this.settings,
    required this.shape,
    required this.interactionIntensity,
    required this.densityFactor,
    required this.backdropLuma,
    this.backgroundImage,
    this.backgroundKey,
    required this.devicePixelRatio,
    required this.ambientRim,
    required this.baseAlphaMultiplier,
    required this.edgeAlphaMultiplier,
    required this.rimThickness,
    required this.rimSmoothing,
    required this.edgeAbsorption,
    this.clipExpansion = EdgeInsets.zero,
    required super.child,
  });

  final ui.FragmentShader shader;
  final LiquidGlassSettings settings;
  final LiquidShape shape;
  final double interactionIntensity;
  final double densityFactor;
  final double backdropLuma;
  final ui.Image? backgroundImage;
  final GlobalKey? backgroundKey;
  final double devicePixelRatio;
  final double ambientRim;
  final double baseAlphaMultiplier;
  final double edgeAlphaMultiplier;
  final double rimThickness;
  final double rimSmoothing;
  final double edgeAbsorption;

  /// Inflation budget matching the parent [AnimatedGlassIndicator._jellyClipExpansion].
  /// The shader drawRect is inflated by this amount so that pixels pushed
  /// outside the pill's layout bounds by horizontal/vertical jelly physics
  /// are still painted by the shader (which self-masks via SDF alpha).
  final EdgeInsets clipExpansion;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInteractiveIndicator(
      shader: shader,
      settings: settings,
      shape: shape,
      interactionIntensity: interactionIntensity,
      densityFactor: densityFactor,
      backdropLuma: backdropLuma,
      backgroundImage: backgroundImage,
      backgroundKey: backgroundKey,
      devicePixelRatio: devicePixelRatio,
      ambientRim: ambientRim,
      baseAlphaMultiplier: baseAlphaMultiplier,
      edgeAlphaMultiplier: edgeAlphaMultiplier,
      rimThickness: rimThickness,
      rimSmoothing: rimSmoothing,
      edgeAbsorption: edgeAbsorption,
      clipExpansion: clipExpansion,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderInteractiveIndicator renderObject,
  ) {
    renderObject
      ..shader = shader
      ..settings = settings
      ..shape = shape
      ..interactionIntensity = interactionIntensity
      ..densityFactor = densityFactor
      ..backdropLuma = backdropLuma
      ..backgroundImage = backgroundImage
      ..backgroundKey = backgroundKey
      ..devicePixelRatio = devicePixelRatio
      ..ambientRim = ambientRim
      ..baseAlphaMultiplier = baseAlphaMultiplier
      ..edgeAlphaMultiplier = edgeAlphaMultiplier
      ..rimThickness = rimThickness
      ..rimSmoothing = rimSmoothing
      ..edgeAbsorption = edgeAbsorption
      ..clipExpansion = clipExpansion;
  }
}

class _RenderInteractiveIndicator extends RenderProxyBox {
  _RenderInteractiveIndicator({
    required ui.FragmentShader shader,
    required LiquidGlassSettings settings,
    required LiquidShape shape,
    required double interactionIntensity,
    required double densityFactor,
    required double backdropLuma,
    ui.Image? backgroundImage,
    GlobalKey? backgroundKey,
    required double devicePixelRatio,
    required double ambientRim,
    required double baseAlphaMultiplier,
    required double edgeAlphaMultiplier,
    required double rimThickness,
    required double rimSmoothing,
    required double edgeAbsorption,
    EdgeInsets clipExpansion = EdgeInsets.zero,
  })  : _shader = shader,
        _settings = settings,
        _shape = shape,
        _interactionIntensity = interactionIntensity,
        _densityFactor = densityFactor,
        _backdropLuma = backdropLuma,
        _backgroundImage = backgroundImage,
        _backgroundKey = backgroundKey,
        _devicePixelRatio = devicePixelRatio,
        _ambientRim = ambientRim,
        _baseAlphaMultiplier = baseAlphaMultiplier,
        _edgeAlphaMultiplier = edgeAlphaMultiplier,
        _rimThickness = rimThickness,
        _rimSmoothing = rimSmoothing,
        _edgeAbsorption = edgeAbsorption,
        _clipExpansion = clipExpansion,
        _cachedLightCos = math.cos(settings.lightAngle),
        _cachedLightSin = -math.sin(settings.lightAngle);

  ui.FragmentShader _shader;
  set shader(ui.FragmentShader value) {
    if (_shader == value) return;
    _shader = value;
    markNeedsPaint();
  }

  LiquidGlassSettings _settings;
  set settings(LiquidGlassSettings value) {
    if (_settings == value) return;
    // Invalidate cached filter when blur changes.
    if (value.effectiveBlur != _settings.effectiveBlur) {
      _cachedInteractiveFilter = null;
    }
    // Recompute trig only when lightAngle actually changes.
    if (value.lightAngle != _settings.lightAngle) {
      _cachedLightCos = math.cos(value.lightAngle);
      _cachedLightSin = -math.sin(value.lightAngle);
    }
    final wasCompositing = alwaysNeedsCompositing;
    _settings = value;
    // alwaysNeedsCompositing depends on effectiveBlur. Dirty the compositing
    // bit whenever blur crosses zero so the framework re-evaluates instead of
    // keeping a stale needsCompositing value.
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  LiquidShape _shape;
  set shape(LiquidShape value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
  }

  double _interactionIntensity;
  set interactionIntensity(double value) {
    if (_interactionIntensity == value) return;
    _interactionIntensity = value;
    markNeedsPaint();
  }

  double _densityFactor;
  set densityFactor(double value) {
    if (_densityFactor == value) return;
    _densityFactor = value;
    markNeedsPaint();
  }

  double _backdropLuma;
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

  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  double _ambientRim;
  set ambientRim(double value) {
    if (_ambientRim == value) return;
    _ambientRim = value;
    markNeedsPaint();
  }

  double _baseAlphaMultiplier;
  set baseAlphaMultiplier(double value) {
    if (_baseAlphaMultiplier == value) return;
    _baseAlphaMultiplier = value;
    markNeedsPaint();
  }

  double _edgeAlphaMultiplier;
  set edgeAlphaMultiplier(double value) {
    if (_edgeAlphaMultiplier == value) return;
    _edgeAlphaMultiplier = value;
    markNeedsPaint();
  }

  double _rimThickness;
  set rimThickness(double value) {
    if (_rimThickness == value) return;
    _rimThickness = value;
    markNeedsPaint();
  }

  double _rimSmoothing;
  set rimSmoothing(double value) {
    if (_rimSmoothing == value) return;
    _rimSmoothing = value;
    markNeedsPaint();
  }

  double _edgeAbsorption;
  set edgeAbsorption(double value) {
    if (_edgeAbsorption == value) return;
    _edgeAbsorption = value;
    markNeedsPaint();
  }

  EdgeInsets _clipExpansion;
  set clipExpansion(EdgeInsets value) {
    if (_clipExpansion == value) return;
    _clipExpansion = value;
    markNeedsPaint();
  }

  // ── Cached light direction ────────────────────────────────────────────────
  // Avoids recomputing cos/sin on every _updateShaderUniforms call.
  // Matches the caching pattern in _RenderLightweightGlass.
  double _cachedLightCos;
  double _cachedLightSin;

  // Only force compositing when blur > 0 (the BackdropFilterLayer path).
  // When blur is 0, _paintGlassContent draws directly — no compositing layer.
  @override
  bool get alwaysNeedsCompositing => _settings.effectiveBlur > 0;

  // ── Cached brightness+blur filter ─────────────────────────────────────────
  // The brightness ColorFilter matrix is constant (mult=1.15, add=0.05), so
  // the composed filter only changes when blurSigma changes. Caching avoids
  // a 20-element List<double> allocation per frame per interactive indicator.
  ui.ImageFilter? _cachedInteractiveFilter;
  double _cachedInteractiveBlur = -1;

  ui.ImageFilter _getInteractiveFilter(double blurSigma) {
    if (_cachedInteractiveFilter != null &&
        _cachedInteractiveBlur == blurSigma) {
      return _cachedInteractiveFilter!;
    }

    const double mult = 1.15;
    const double add = 0.05;
    final ui.ColorFilter brightnessFilter = ui.ColorFilter.matrix(<double>[
      mult,
      0.0,
      0.0,
      0.0,
      add * 255.0,
      0.0,
      mult,
      0.0,
      0.0,
      add * 255.0,
      0.0,
      0.0,
      mult,
      0.0,
      add * 255.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
    ]);

    _cachedInteractiveFilter = ui.ImageFilter.compose(
      outer: brightnessFilter,
      inner: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
    );
    _cachedInteractiveBlur = blurSigma;
    return _cachedInteractiveFilter!;
  }

  // Reusable ClipPathLayer handle — avoids allocation on every paint frame.
  final _clipPathLayerHandle = LayerHandle<ClipPathLayer>();

  @override
  void dispose() {
    _clipPathLayerHandle.layer = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final blurSigma = _settings.effectiveBlur;
    if (blurSigma > 0) {
      final filter = _getInteractiveFilter(blurSigma);

      // Clip blur to the pill shape so the BackdropFilterLayer does not bleed
      // into the expansion zone around the jelly-physics draw rect.
      //
      // Clip.antiAlias is used (not Clip.antiAliasWithSaveLayer) because
      // antiAliasWithSaveLayer would isolate the BackdropFilter from the real
      // compositor backdrop via a saveLayer, destroying the frosted-glass effect.
      // antiAlias creates a ClipPathLayer with no saveLayer, giving sub-pixel AA
      // on the pill edge without compositor isolation.
      //
      // IMPORTANT: build the path in **local** coordinates (Offset.zero & size).
      // PaintingContext.pushClipPath calls clipPath.shift(offset) internally, so
      // passing `offset & size` here would shift the clip twice — placing it
      // entirely outside the widget's screen bounds whenever offset != zero.
      final pillPath = _shape.getOuterPath(Offset.zero & size);
      _clipPathLayerHandle.layer = context.pushClipPath(
        needsCompositing,
        offset,
        Offset.zero & size,
        pillPath,
        (context, offset) {
          context.pushLayer(
            BackdropFilterLayer(filter: filter),
            (context, offset) {
              _paintGlassContent(context, offset);
            },
            offset,
          );
        },
        clipBehavior: Clip.antiAlias,
        oldLayer: _clipPathLayerHandle.layer,
      );
    } else {
      _clipPathLayerHandle.layer = null;
      _paintGlassContent(context, offset);
    }
  }

  void _paintGlassContent(PaintingContext context, Offset offset) {
    // 1. Paint Child content (glow etc)
    super.paint(context, offset);

    // 2. Prepare shader uniforms
    final canvas = context.canvas;
    final matrix = canvas.getTransform();

    final canvasPhysicalX = matrix[12];
    final canvasPhysicalY = matrix[13];
    final scaleX = matrix[0];
    final scaleY = matrix[5];

    final physicalOrigin = Offset(
      canvasPhysicalX + (offset.dx * scaleX),
      canvasPhysicalY + (offset.dy * scaleY),
    );

    // Keep uScale from canvas for shape calculations
    final uScale = Offset(scaleX, scaleY);

    // Relative Offset Mapping - ALL IN LOGICAL PIXELS
    Offset bgRelativeOffset = Offset.zero;
    Size bgSize = const Size(1, 1);

    if (_backgroundKey != null && _backgroundImage != null) {
      final boundary = _backgroundKey!.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        // Get screen positions (localToGlobal gives logical coords)
        final bgGlobalPos = boundary.localToGlobal(Offset.zero);
        final indGlobalPos = localToGlobal(Offset.zero);

        // Keep in LOGICAL pixels (don't multiply by DPR)
        bgRelativeOffset = indGlobalPos - bgGlobalPos;

        // Image is now captured at pixelRatio: _devicePixelRatio.
        // Divide by DPR to convert physical pixel dimensions back to logical
        // pixels, keeping uBackgroundSize in the same coordinate space as
        // localLogical/posInBg in the shader. The bilinear function in GLSL
        // uses the physical size (uBgPhysicalSize = logical × DPR) internally.
        bgSize = Size(
          _backgroundImage!.width / _devicePixelRatio,
          _backgroundImage!.height / _devicePixelRatio,
        );
      }
    }

    _updateShaderUniforms(
        size, physicalOrigin, uScale, bgRelativeOffset, bgSize);

    // 3. Set Sampler
    final imageToBind = _backgroundImage ?? GlassEffect.dummyImage;
    _shader.setImageSampler(
      0,
      imageToBind,
      filterQuality: FilterQuality.medium,
    );

    // 4. Paint shader overlay — inflate the draw rect by the clip expansion budget.
    //
    // WHY: canvas.drawRect(offset & size) normally covers only the pill's layout
    // bounds (e.g. 90×64px). The parent jelly Transform can stretch the indicator
    // wider/taller than those bounds. Without inflation, pixels pushed outside the
    // layout rect by the jelly physics are never painted by the shader, producing
    // a hard cutoff at the layout edge.
    //
    // The shader self-masks via SDF alpha (vec4(0.0) outside pill), so inflating
    // the rect into the expansion zone causes zero visual bleed — only the SDF
    // region of the pill is rendered. The expansion values match
    // AnimatedGlassIndicator._jellyClipExpansion (20px H, 15px V).
    final paint = Paint()..shader = _shader;
    final expandedRect = Rect.fromLTRB(
      offset.dx - _clipExpansion.left,
      offset.dy - _clipExpansion.top,
      offset.dx + size.width + _clipExpansion.right,
      offset.dy + size.height + _clipExpansion.bottom,
    );
    canvas.drawRect(expandedRect, paint);
  }

  void _updateShaderUniforms(Size size, Offset physicalOrigin,
      Offset physicalScale, Offset bgOrigin, Size bgSize) {
    int index = 0;
    _shader.setFloat(index++, size.width);
    _shader.setFloat(index++, size.height);
    _shader.setFloat(index++, physicalOrigin.dx);
    _shader.setFloat(index++, physicalOrigin.dy);

    final color = _settings.effectiveGlassColor;
    _shader.setFloat(index++, (color.r * 255.0).round().clamp(0, 255) / 255.0);
    _shader.setFloat(index++, (color.g * 255.0).round().clamp(0, 255) / 255.0);
    _shader.setFloat(index++, (color.b * 255.0).round().clamp(0, 255) / 255.0);
    _shader.setFloat(index++, (color.a * 255.0).round().clamp(0, 255) / 255.0);

    _shader.setFloat(index++, _settings.effectiveThickness);

    // Pass light direction as [cos(angle), -sin(angle)]
    // lightAngle is in radians (per LiquidGlassSettings API docs).
    // Uses cached values — trig only recomputed when lightAngle changes.
    _shader.setFloat(index++, _cachedLightCos);
    _shader.setFloat(index++, _cachedLightSin);

    _shader.setFloat(index++, _settings.effectiveLightIntensity);
    _shader.setFloat(index++, _settings.effectiveAmbientStrength);
    _shader.setFloat(index++, _settings.effectiveSaturation);
    _shader.setFloat(index++, _settings.effectiveRefractiveIndex);
    _shader.setFloat(index++, (_settings.chromaticAberration).clamp(0.0, 1.0));

    // 16: uCornerRadius (float) - Logical
    // effectiveRadius is obfuscation-safe: it is a typed virtual dispatch on
    // the sealed LiquidShape hierarchy, not a dynamic property lookup or a
    // runtimeType.toString() heuristic (both of which break under --obfuscate).
    final maxRadius = math.min(size.width, size.height) / 2.0;
    final cornerRadius = _shape.effectiveRadius.clamp(0.0, maxRadius);
    _shader.setFloat(index++, cornerRadius);

    _shader.setFloat(index++, physicalScale.dx);
    _shader.setFloat(index++, physicalScale.dy);
    _shader.setFloat(
        index++, _settings.glowIntensity); // uGlowIntensity (fresnel boost)
    _shader.setFloat(
        index++,
        _densityFactor.clamp(0.0,
            1.0)); // 20: uDensityFactor (float) - Elevation physics (0.0-1.0)
    _shader.setFloat(index++, _interactionIntensity.clamp(0.0, 1.0));

    // Background Mapping Uniforms
    _shader.setFloat(index++, bgOrigin.dx);
    _shader.setFloat(index++, bgOrigin.dy);
    _shader.setFloat(index++, bgSize.width);
    _shader.setFloat(index++, bgSize.height);
    _shader.setFloat(index++, _backgroundImage != null ? 1.0 : 0.0);

    // Configurable appearance parameters
    _shader.setFloat(index++, _ambientRim);
    _shader.setFloat(index++, _baseAlphaMultiplier);
    _shader.setFloat(index++, _edgeAlphaMultiplier);
    _shader.setFloat(index++, _rimThickness);
    _shader.setFloat(index++, _rimSmoothing);

    // Device pixel ratio — used by textureBilinear() in the shader to
    // convert logical uBackgroundSize to physical texel dimensions.
    // index 32 (after the 32 floats mapped to uData0..uData7).
    _shader.setFloat(index++, _devicePixelRatio);

    // Slot 33: edgeAbsorption — Beer-Lambert meniscus rim darkening [0..1].
    // Passed directly — what the caller sets is what the shader gets.
    _shader.setFloat(index++, _edgeAbsorption.clamp(0.0, 1.0));
  }
}
