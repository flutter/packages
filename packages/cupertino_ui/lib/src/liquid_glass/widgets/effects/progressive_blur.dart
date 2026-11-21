// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
/// Unlike [BackdropFilter] with [ui.ImageFilter.blur], which applies the same
/// blur everywhere, the blur here fades out across the widget. It needs no
/// special ancestor, so it can back any bar.
///
/// ## How it works: a separable two-pass blur that samples the backdrop
///
/// The naive "blur then fade with a ShaderMask" recipe does NOT work: a
/// [BackdropFilter]'s captured backdrop is not included in an ancestor
/// [ShaderMask]'s layer on Impeller, so the mask reveals nothing and iOS shows
/// no blur at all. Instead this uses [ui.ImageFilter.shader]: a fragment shader
/// runs as the [ui.ImageFilter] of a [BackdropFilter], so the engine binds the
/// captured backdrop to the shader's sampler — sampling it reliably on every
/// backend that supports shader image filters. The `progressive_blur.frag`
/// shader blurs that backdrop with a gaussian whose sigma follows the gradient,
/// normalized over the widget's own device-pixel rectangle because the bound
/// texture is the whole backdrop. It runs twice, horizontally then vertically,
/// composed into one image filter.
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
/// Call [preload] once from `main()` (after the binding is initialized) to
/// pre-compile the shader so the first bar paint already has it.
///
/// On backends that can't run shader image filters (Skia, the web), and until
/// the shader has loaded, the widget falls back to a uniform backdrop blur.
///
/// Known limitation: the blur region is measured when this widget paints. If an
/// ancestor moves it without repainting it (for example a route transition
/// that translates a repaint boundary), the gradient stays aligned to the old
/// position until the widget next repaints.
class ProgressiveBlur extends StatefulWidget {
  /// Creates a new [ProgressiveBlur].
  const ProgressiveBlur({
    super.key,
    this.maxSigma = 18,
    this.direction = ProgressiveBlurDirection.topToBottom,
    this.falloff = 1.2,
  }) : // Also false for NaN (`isFinite` isn't allowed in a const constructor).
       assert(maxSigma < double.infinity, 'maxSigma must not be NaN or positive infinity.'),
       assert(
         falloff > 0 && falloff < double.infinity,
         'falloff must be a positive, finite number.',
       );

  /// Blur sigma (logical px) at the strong edge. 0 or less (including negative
  /// infinity) ⇒ no blur (passthrough). Must not be NaN or positive infinity.
  /// Defaults to a moderate 18.
  final double maxSigma;

  /// Which edge the blur is strongest at (it eases to sharp at the opposite
  /// edge). Defaults to [ProgressiveBlurDirection.topToBottom].
  final ProgressiveBlurDirection direction;

  /// Shape of the blur gradient.
  ///
  /// At a fraction `t` of the way from the strong edge to the opposite edge,
  /// the blur sigma is `maxSigma * pow(1 - t, falloff)`. A value of 1 fades
  /// linearly, values above 1 fade faster near the strong edge, and values
  /// below 1 keep the blur strong further in.
  ///
  /// Must be positive and finite. Defaults to 1.2.
  final double falloff;

  // ── Shader program: compiled once, process-wide ───────────────────────────
  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram>? _loading;

  /// Pre-compiles the blur shader so the first bar paint already has it. Safe to
  /// call repeatedly (compiled once). Call from `main()` after the binding is
  /// initialized. Never throws — on failure the widget falls back to a uniform
  /// blur.
  static Future<void> preload() async {
    if (_program != null || !ui.ImageFilter.isShaderFilterSupported) {
      return;
    }
    // Package-qualified asset key (the shader is declared in cupertino_ui's
    // pubspec). The bare key is how the package's own tests see the asset.
    const path = 'packages/cupertino_ui/lib/src/third_party/progressive_blur/progressive_blur.frag';
    const testPath = 'lib/src/third_party/progressive_blur/progressive_blur.frag';
    final Future<ui.FragmentProgram> loading = _loading ??= _loadProgram(path, testPath);
    try {
      _program = await loading;
    } catch (e) {
      // Graceful degradation: the widget falls back to a uniform blur. Clear
      // the failed load so a later call can retry, unless a retry has already
      // started.
      if (identical(_loading, loading)) {
        _loading = null;
      }
      debugPrint('progressive_blur.frag load failed, using uniform-blur fallback: $e');
    }
  }

  static Future<ui.FragmentProgram> _loadProgram(String path, String testPath) async {
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
    if (_hShader == null && ui.ImageFilter.isShaderFilterSupported) {
      // Not pre-compiled yet — load, then rebuild with the shaders.
      ProgressiveBlur.preload().then((_) {
        if (mounted) {
          setState(_makeShaders);
        }
      });
    }
  }

  void _makeShaders() {
    final ui.FragmentProgram? p = ProgressiveBlur._program;
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
    if (widget.maxSigma <= 0) {
      return const SizedBox.expand();
    }

    final ui.FragmentShader? h = _hShader;
    final ui.FragmentShader? v = _vShader;
    // Fallback — the shaders aren't ready yet, or the backend can't run shader
    // filters (Skia / web: isShaderFilterSupported == false). A single uniform
    // backdrop blur is a cheap stand-in; the translucent scrim above the bar
    // hides the harder bottom edge. Web/desktop have the headroom for it.
    if (h == null || v == null || !ui.ImageFilter.isShaderFilterSupported) {
      return ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: widget.maxSigma * 0.6, sigmaY: widget.maxSigma * 0.6),
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
    // that is the route being revealed, which is translated, not clipped.
    // coverage:ignore-start
    // Runs only where shader image filters are supported; the default
    // `flutter test` backend has none, so tests reach it with `--enable-impeller`.
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
/// zero in the middle of a widget build. The shader path only runs where shader
/// image filters are supported, so this pins the arithmetic on every backend.
@visibleForTesting
List<double> progressiveBlurUniforms({
  required Offset origin,
  required Size size,
  required double devicePixelRatio,
  required double maxSigma,
  required double falloff,
  required ProgressiveBlurDirection direction,
  required double axis,
}) => <double>[
  maxSigma * devicePixelRatio,
  falloff,
  direction._uniform,
  axis, // 0 = horizontal, 1 = vertical
  origin.dx * devicePixelRatio,
  origin.dy * devicePixelRatio,
  size.width * devicePixelRatio,
  size.height * devicePixelRatio,
];

// Everything below runs only on the shader path, which `flutter test` reaches
// only with `--enable-impeller` (the default test backend has no shader image
// filters). The region maths is factored into [progressiveBlurUniforms] above so
// that it can be tested on any backend.
// coverage:ignore-start

/// Applies the two-pass shader as a backdrop filter.
///
/// A render object rather than a [BackdropFilter] under a [LayoutBuilder]
/// because the region rectangle is only knowable — and only stays current — at
/// paint time. Two consequences fall out of that:
///
///  * The widget's offset within the backdrop layer changes whenever an
///    ancestor moves it: a sheet being dragged, a scroll, an animated inset.
///    When the move repaints this widget, an offset read at paint time is
///    current, while one read during build would be stale. When an ancestor
///    moves it by re-compositing a repaint boundary instead (route transitions
///    do this), paint doesn't run and the region stays at its old position;
///    see the known limitation on [ProgressiveBlur].
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
  RenderObject createRenderObject(BuildContext context) => _RenderProgressiveBlur(
    hShader: hShader,
    vShader: vShader,
    maxSigma: maxSigma,
    falloff: falloff,
    direction: direction,
    devicePixelRatio: devicePixelRatio,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderProgressiveBlur renderObject) =>
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
    required this._hShader,
    required this._vShader,
    required this._maxSigma,
    required this._falloff,
    required this._direction,
    required this._devicePixelRatio,
  });

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
    final ui.Offset origin = localToGlobal(Offset.zero);
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
    final List<double> uniforms = progressiveBlurUniforms(
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
