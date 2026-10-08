import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The edge a [ProgressiveBlur] is *strongest* at; it eases to perfectly sharp
/// at the opposite edge. Named after the direction the blur travels — e.g.
/// [topToBottom] is heavy at the top and dissolves downward (the classic
/// app-bar / status-bar look), [bottomToTop] is heavy at the bottom (e.g. a
/// bottom bar or a fade above a docked toolbar).
enum ProgressiveBlurDirection {
  /// Strong at the top edge, sharp at the bottom.
  topToBottom,

  /// Strong at the bottom edge, sharp at the top.
  bottomToTop,

  /// Strong at the left edge, sharp at the right.
  leftToRight,

  /// Strong at the right edge, sharp at the left.
  rightToLeft;

  /// The `uDirection` uniform value the shader expects (0 top, 1 bottom, 2 left,
  /// 3 right = where the blur is strongest).
  double get _uniform => index.toDouble();
}

/// A *progressive* (graduated) backdrop blur — the Signal / iOS-26 header look:
/// a clean gaussian frost that is strongest at one edge and eases to perfectly
/// sharp at the opposite edge. Stack it behind a translucent app bar so content
/// dissolves beneath it instead of ending on a hard cut-off.
///
/// This is the graduated-blur primitive the rest of the library does not
/// provide (glass surfaces apply a *uniform* blur). It is self-contained — it
/// needs no [LiquidGlassLayer] or glass ancestor — so it can back any bar.
///
/// ## How it works — a single GPU pass that samples the backdrop
///
/// The naive "blur then fade with a ShaderMask" recipe does NOT work: a
/// [BackdropFilter]'s captured backdrop is not included in an ancestor
/// [ShaderMask]'s layer on Impeller, so the mask reveals nothing and iOS shows
/// no blur at all. Instead this uses [ui.ImageFilter.shader]: a fragment shader
/// runs as the [ui.ImageFilter] of a [BackdropFilter], so the engine binds the
/// captured backdrop to the shader's sampler — sampling it reliably on every
/// backend. `shaders/progressive_blur.frag` reads that backdrop with an
/// importance-sampled gaussian whose sigma follows the gradient (normalised over
/// the widget's own device-pixel rectangle, since the bound texture is the whole
/// screen), giving a smooth, band-free dissolve in one backdrop capture + one
/// draw.
///
/// Drive [maxSigma] from a scroll offset to fade the blur in/out (0 → sharp).
///
/// ```dart
/// Stack(
///   children: [
///     const Positioned(top: 0, left: 0, right: 0, height: 96,
///       child: ProgressiveBlur(maxSigma: 20)),
///     // ... your translucent app bar on top ...
///   ],
/// )
/// ```
///
/// Call [preload] once from `main()` (after the binding is initialised) to
/// pre-compile the shader so the first bar paint already has it.
class ProgressiveBlur extends StatefulWidget {
  /// Creates a new [ProgressiveBlur].
  const ProgressiveBlur({
    super.key,
    this.maxSigma = 18,
    this.direction = ProgressiveBlurDirection.topToBottom,
    this.falloff = 1.2,
  });

  /// Blur sigma (logical px) at the strong edge. 0 ⇒ no blur (passthrough).
  /// Optional — defaults to a moderate 18.
  final double maxSigma;

  /// Which edge the blur is strongest at (it eases to sharp at the opposite
  /// edge). Defaults to [ProgressiveBlurDirection.topToBottom].
  final ProgressiveBlurDirection direction;

  /// Gradient gamma. >1 keeps the blur strong across the strong edge then eases
  /// to sharp near the opposite edge.
  final double falloff;

  // ── Shader program: compiled once, process-wide ───────────────────────────
  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram>? _loading;

  /// Pre-compiles the blur shader so the first bar paint already has it. Safe to
  /// call repeatedly (compiled once). Call from `main()` after the binding is
  /// initialized. Never throws — on failure the widget falls back to a uniform
  /// blur.
  static Future<void> preload() async {
    if (_program != null) return;
    // Package-qualified asset path (this shader ships with the package); the
    // bare path is the fallback for unit tests where the package prefix may not
    // resolve.
    const path = 'packages/liquid_glass_widgets/shaders/progressive_blur.frag';
    const testPath = 'shaders/progressive_blur.frag';
    try {
      _program = await (_loading ??= _loadProgram(path, testPath));
    } catch (e) {
      // Graceful degradation: the widget falls back to a uniform blur. (Also the
      // path taken in unit tests, where compiled shaders aren't bundled.)
      _loading = null;
      debugPrint(
        'progressive_blur.frag load failed, using uniform-blur fallback: $e',
      );
    }
  }

  static Future<ui.FragmentProgram> _loadProgram(
    String path,
    String testPath,
  ) async {
    try {
      return await ui.FragmentProgram.fromAsset(path);
    } catch (_) {
      return ui.FragmentProgram.fromAsset(testPath);
    }
  }

  @override
  State<ProgressiveBlur> createState() => _ProgressiveBlurState();
}

class _ProgressiveBlurState extends State<ProgressiveBlur> {
  // Two instances of the same program: one blurs along X, the other along Y.
  ui.FragmentShader? _hShader;
  ui.FragmentShader? _vShader;

  @override
  void initState() {
    super.initState();
    _makeShaders();
    if (_hShader == null) {
      // Not pre-compiled yet — load, then rebuild with the shaders.
      ProgressiveBlur.preload().then((_) {
        if (mounted) setState(_makeShaders);
      });
    }
  }

  void _makeShaders() {
    final p = ProgressiveBlur._program;
    if (p != null && _hShader == null) {
      _hShader = p.fragmentShader(); // coverage:ignore-line
      _vShader = p.fragmentShader(); // coverage:ignore-line
    }
  }

  @override
  void dispose() {
    _hShader?.dispose(); // coverage:ignore-line
    _vShader?.dispose(); // coverage:ignore-line
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.maxSigma <= 0) return const SizedBox.expand();

    final h = _hShader;
    final v = _vShader;
    // Fallback — the shaders aren't ready yet, or the backend can't run shader
    // filters (Skia / web: isShaderFilterSupported == false). A single uniform
    // backdrop blur is a cheap stand-in; the translucent scrim above the bar
    // hides the harder bottom edge. Web/desktop have the headroom for it.
    if (h == null || v == null || !ui.ImageFilter.isShaderFilterSupported) {
      return ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: widget.maxSigma * 0.6,
            sigmaY: widget.maxSigma * 0.6,
          ),
          child: const SizedBox.expand(),
        ),
      );
    }

    // The bound texture (and thus uSize, float indices 0,1) is the WHOLE
    // backdrop, not this widget — so the shader needs this widget's own
    // device-pixel rectangle to normalise the gradient over. Both halves of
    // that rectangle are resolved at PAINT time; see [_RenderProgressiveBlur].
    //
    // The ClipRect bounds what the filter WRITES — a backdrop filter otherwise
    // reaches up to the nearest ancestor clip, and the shader clamps its
    // gradient at the region's edges rather than stopping there, so an
    // unclipped band frosted the whole backdrop width. Under a Cupertino pop
    // that is the route being revealed, which is translated, not clipped
    // (#278).
    // coverage:ignore-start
    // Requires a compiled FragmentProgram; the headless test VM never provides
    // one. The fallback path above is tested.
    return ClipRect(
      child: _ProgressiveBlurLayer(
        hShader: h,
        vShader: v,
        maxSigma: widget.maxSigma,
        falloff: widget.falloff,
        direction: widget.direction,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        child: const SizedBox.expand(),
      ),
    );
    // coverage:ignore-end
  }
}

/// The eight uniforms describing the blur region, in the order the program
/// declares them (float indices 2-9).
///
/// Pure, and public to tests, because the defect this replaced was a hard-coded
/// zero in the middle of a widget build — which no test could see: the shader
/// path needs a compiled [ui.FragmentProgram], and a headless VM never provides
/// one. The arithmetic can at least be pinned.
@visibleForTesting
List<double> progressiveBlurUniforms({
  required Offset origin,
  required Size size,
  required double devicePixelRatio,
  required double maxSigma,
  required double falloff,
  required ProgressiveBlurDirection direction,
  required double axis,
}) =>
    <double>[
      maxSigma * devicePixelRatio,
      falloff,
      direction._uniform,
      axis, // 0 = horizontal, 1 = vertical
      origin.dx * devicePixelRatio,
      origin.dy * devicePixelRatio,
      size.width * devicePixelRatio,
      size.height * devicePixelRatio,
    ];

// Everything below is reachable only with a compiled FragmentProgram, which a
// headless VM never provides — so it cannot be exercised by `flutter test`, and
// the region maths is factored into [progressiveBlurUniforms] above so that the
// part which CAN be tested, is.
// coverage:ignore-start

/// Applies the two-pass shader as a backdrop filter.
///
/// A render object rather than a [BackdropFilter] under a [LayoutBuilder]
/// because the region rectangle is only knowable — and only stays current — at
/// paint time. Two consequences fall out of that:
///
///  * The widget's offset within the backdrop layer changes whenever an
///    ancestor MOVES it: a sheet being dragged, a scroll, an animated inset.
///    Those move it by repainting, not by rebuilding, so an offset read during
///    build (or in a post-frame callback) is stale for as long as the motion
///    lasts, and the gradient is normalised over the wrong rectangle the whole
///    time.
///  * Dropping the [LayoutBuilder] also lets a [ProgressiveBlur] sit under a
///    parent that asks for intrinsic dimensions, which LayoutBuilder refuses to
///    answer.
class _ProgressiveBlurLayer extends SingleChildRenderObjectWidget {
  const _ProgressiveBlurLayer({
    required this.hShader,
    required this.vShader,
    required this.maxSigma,
    required this.falloff,
    required this.direction,
    required this.devicePixelRatio,
    required Widget super.child,
  });

  final ui.FragmentShader hShader;
  final ui.FragmentShader vShader;
  final double maxSigma;
  final double falloff;
  final ProgressiveBlurDirection direction;
  final double devicePixelRatio;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderProgressiveBlur(
        hShader: hShader,
        vShader: vShader,
        maxSigma: maxSigma,
        falloff: falloff,
        direction: direction,
        devicePixelRatio: devicePixelRatio,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderProgressiveBlur renderObject,
  ) =>
      renderObject.update(
        hShader: hShader,
        vShader: vShader,
        maxSigma: maxSigma,
        falloff: falloff,
        direction: direction,
        devicePixelRatio: devicePixelRatio,
      );
}

class _RenderProgressiveBlur extends RenderProxyBox {
  _RenderProgressiveBlur({
    required ui.FragmentShader hShader,
    required ui.FragmentShader vShader,
    required double maxSigma,
    required double falloff,
    required ProgressiveBlurDirection direction,
    required double devicePixelRatio,
  })  : _hShader = hShader,
        _vShader = vShader,
        _maxSigma = maxSigma,
        _falloff = falloff,
        _direction = direction,
        _devicePixelRatio = devicePixelRatio;

  ui.FragmentShader _hShader;
  ui.FragmentShader _vShader;
  double _maxSigma;
  double _falloff;
  ProgressiveBlurDirection _direction;
  double _devicePixelRatio;

  /// One setter for the lot: every field arrives from the same widget on the
  /// same rebuild, so a single comparison is all the change detection this
  /// needs. The shaders are compared by identity — they are long-lived
  /// [ui.FragmentShader] instances owned by the [State], not values.
  void update({
    required ui.FragmentShader hShader,
    required ui.FragmentShader vShader,
    required double maxSigma,
    required double falloff,
    required ProgressiveBlurDirection direction,
    required double devicePixelRatio,
  }) {
    if (identical(_hShader, hShader) &&
        identical(_vShader, vShader) &&
        _maxSigma == maxSigma &&
        _falloff == falloff &&
        _direction == direction &&
        _devicePixelRatio == devicePixelRatio) {
      return;
    }
    _hShader = hShader;
    _vShader = vShader;
    _maxSigma = maxSigma;
    _falloff = falloff;
    _direction = direction;
    _devicePixelRatio = devicePixelRatio;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  BackdropFilterLayer? get layer => super.layer as BackdropFilterLayer?;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      layer = null;
      return;
    }
    // The offset in the backdrop layer's own coordinate space — which is what
    // the shader's FlutterFragCoord() is expressed in.
    final origin = localToGlobal(Offset.zero);
    _configure(_hShader, 0, origin);
    _configure(_vShader, 1, origin);

    // Separable 2-pass: horizontal (inner) then vertical (outer) = a clean
    // 2-D gaussian.
    (layer ??= BackdropFilterLayer()).filter = ui.ImageFilter.compose(
      outer: ui.ImageFilter.shader(_vShader),
      inner: ui.ImageFilter.shader(_hShader),
    );
    context.pushLayer(layer!, super.paint, offset);
  }

  void _configure(ui.FragmentShader shader, double axis, Offset origin) {
    final uniforms = progressiveBlurUniforms(
      origin: origin,
      size: size,
      devicePixelRatio: _devicePixelRatio,
      maxSigma: _maxSigma,
      falloff: _falloff,
      direction: _direction,
      axis: axis,
    );
    for (var i = 0; i < uniforms.length; i++) {
      shader.setFloat(2 + i, uniforms[i]);
    }
  }
}
// coverage:ignore-end
