// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import '../../../widgets/shared/inherited_liquid_glass.dart';
import '../../../utils/glass_spring.dart';
import 'rendering/liquid_glass_render_object.dart';

/// {@template glass_glow}
/// If placed as a descendant of a [GlassGlowLayer], this widget will
/// send touch updates to that layer to create a glow effect.
/// {@endtemplate}
class GlassGlow extends StatefulWidget {
  /// {@macro glass_glow}
  const GlassGlow({
    required this.child,
    // Whitelisted: Renderer constant, out of scope for widget criteria.
    this.glowColor = const Color(0x33FFFFFF), // white24 equivalent
    this.glowRadius = 1,
    this.glowBlurRadius = 0,
    this.glowSpreadRadius = 0,
    this.glowOpacity = 1,
    this.pulse = 0,
    this.clipper,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.enabled = true,
    this.glowOnTapOnly = false,
    super.key,
  });

  /// The radius of the glow effect relative to the layer's shortest side.
  ///
  /// A value of 0.8 means the glow radius will be 80% of the shortest
  /// dimension (width or height) of the [GlassGlowLayer].
  ///
  /// Defaults to 1.
  final double glowRadius;

  /// The color of the glow effect.
  ///
  /// The glow will have this colors opacity at the center, and will fade out
  /// to fully transparent at the edge of the glow.
  final Color glowColor;

  /// Additional blur sigma applied to the glow circle via a [MaskFilter].
  ///
  /// A value of 0 (the default) produces a sharp-edged radial gradient with no
  /// additional blur. Higher values soften the glow, creating a wider diffuse
  /// halo. The blur is applied *on top of* the radial gradient fade-out, so
  /// even moderate values (4–12) are clearly visible.
  ///
  /// Corresponds to [GlassGlowColors.glowBlurRadius].
  final double glowBlurRadius;

  /// Extra radius added to the drawn circle beyond the physics radius.
  ///
  /// A value of 0 (the default) draws the circle at the physics radius. A
  /// positive value (e.g. 0.2) expands it by that fraction of the layer's
  /// shortest side — useful for making the glow bleed slightly further from
  /// the touch point without inflating the radius spring.
  ///
  /// Corresponds to [GlassGlowColors.glowSpreadRadius].
  final double glowSpreadRadius;

  /// Master opacity multiplier applied on top of [glowColor]'s own alpha.
  ///
  /// Range 0–1. Defaults to 1 (no change). A value of 0.5 halves the effective
  /// glow opacity without changing the color itself, making it easy to dial
  /// the intensity down from the theme without adjusting the raw color.
  ///
  /// Corresponds to [GlassGlowColors.glowOpacity].
  final double glowOpacity;

  /// Global pulse intensity (0.0 to 1.0) for a full-window saturation/brightness
  /// highlight. Used by [GlassModalSheet] to synchronise a whole-surface pulse
  /// during high-velocity drag interactions.
  ///
  /// Defaults to 0 (no pulse).
  final double pulse;

  /// The hit test behavior of this gesture listener.
  ///
  /// Defaults to [HitTestBehavior.opaque].
  final HitTestBehavior hitTestBehavior;

  /// The child that will be painted above the glow effect.
  final Widget child;

  /// The shape to clip the glow to.
  /// Only clips the additive glow effect, not the child widget.
  final CustomClipper<Path>? clipper;

  /// Whether the glow is active at all.
  ///
  /// When false, the widget renders as a plain passthrough to [child] with
  /// zero overhead. Useful for disabling glow in specific states without
  /// restructuring the widget tree.
  ///
  /// Defaults to true.
  final bool enabled;

  /// When true, the glow fires on touch-down but is suppressed after the
  /// finger travels more than 10 logical pixels (i.e. a drag or scroll).
  ///
  /// This prevents the "stuck glow" artefact during scrollable menus or
  /// lists where a drag gesture should not leave a persistent glare behind.
  /// The glow is re-enabled automatically on the next touch-down.
  ///
  /// Defaults to false (glow always follows the pointer).
  final bool glowOnTapOnly;

  @override
  State<GlassGlow> createState() => _GlassGlowState();
}

class _GlassGlowState extends State<GlassGlow> {
  Offset? _initialPointerDown;
  bool _glowSuppressed = false;

  // BUG 3 FIX: Reset suppression flag when glowOnTapOnly is toggled off at
  // runtime (e.g. animation-driven state changes). Without this, the glow
  // remains permanently muted until the next pointer-down.
  @override
  void didUpdateWidget(GlassGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.glowOnTapOnly && !widget.glowOnTapOnly) {
      _glowSuppressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fast-path: no overhead if glow is disabled entirely.
    if (!widget.enabled) return widget.child;

    return GlassGlowLayer(
      clipper: widget.clipper,
      pulse: widget.pulse,
      child: Builder(
        builder: (innerContext) => Listener(
          behavior: widget.hitTestBehavior,
          onPointerDown: (event) {
            _initialPointerDown = event.localPosition;
            _glowSuppressed = false;
            _handlePointer(innerContext, event);
          },
          onPointerMove: (event) {
            if (widget.glowOnTapOnly && !_glowSuppressed) {
              final delta =
                  event.localPosition - (_initialPointerDown ?? Offset.zero);
              if (delta.distance > 10.0) {
                _glowSuppressed = true;
                _removeTouch(innerContext);
                return;
              }
            }
            if (!_glowSuppressed) _handlePointer(innerContext, event);
          },
          onPointerUp: (event) => _removeTouch(innerContext),
          onPointerCancel: (event) => _removeTouch(innerContext),
          child: widget.child,
        ),
      ),
    );
  }

  void _handlePointer(BuildContext context, PointerEvent event) {
    final layerState = GlassGlowLayer.maybeOf(context);
    if (layerState == null) return;

    // GlassGlowLayer may be at a different level than GlassGlow — e.g. a
    // toolbar GlassGlowLayer wrapping three buttons, each with their own
    // GlassGlow. event.localPosition is relative to this GlassGlow widget,
    // not relative to the GlassGlowLayer. We must convert via global space.
    final myBox = context.findRenderObject() as RenderBox?;
    final layerBox = layerState.context.findRenderObject() as RenderBox?;

    Offset pos;
    if (myBox != null &&
        layerBox != null &&
        myBox.attached &&
        layerBox.attached) {
      // local-in-GlassGlow → global screen → local-in-GlassGlowLayer
      pos = layerBox.globalToLocal(myBox.localToGlobal(event.localPosition));
      // Keep the glow inside the layer it belongs to. A pointer that has been
      // captured keeps reporting moves after it leaves the widget, and the
      // layer clips the glow to [GlassGlowLayer.clipper], so an unclamped
      // centre slides the highlight out of the clip and the light fades to
      // nothing while the finger is still down. On a wide bar that is very
      // visible: drag off a GlassTabBar.bottom and the touch light vanishes
      // while the selection indicator, which does clamp, keeps tracking the
      // same finger. Clamping keeps the two agreeing, and matches the
      // platform, where the highlight belongs to the element and stays on it.
      pos = Offset(
        pos.dx.clamp(0.0, layerBox.size.width),
        pos.dy.clamp(0.0, layerBox.size.height),
      );
    } else {
      // Fallback for tests or during layout (same-level case is also correct).
      pos = event.localPosition;
    }

    layerState.updateTouch(
      pos,
      radius: widget.glowRadius,
      color: widget.glowColor,
      blurRadius: widget.glowBlurRadius,
      spreadRadius: widget.glowSpreadRadius,
      opacity: widget.glowOpacity,
    );
  }

  void _removeTouch(BuildContext context) {
    GlassGlowLayer.maybeOf(context)?.removeTouch();
  }
}

/// {@template glass_glow}
/// Represents a layer that can paint a glowing effect below its child.
///
/// Any child [GlassGlow] will send touch updates to this layer to
/// update the glow effect.
///
/// This is similar to how an `InkWell` works with a `Material` widget.
/// {@endtemplate}
class GlassGlowLayer extends StatefulWidget {
  /// {@macro glass_glow}
  const GlassGlowLayer({
    required this.child,
    this.clipper,
    this.pulse = 0,
    super.key,
  });

  /// The child that will be painted above the glow effect.
  final Widget child;

  /// The shape to clip the glow to.
  final CustomClipper<Path>? clipper;

  /// Global pulse intensity (0.0 to 1.0) for a full-window glow effect.
  final double pulse;

  @override
  State<GlassGlowLayer> createState() => GlassGlowLayerState();

  static GlassGlowLayerState? maybeOf(BuildContext context) {
    if (!context.mounted) return null;
    return context.findAncestorStateOfType<GlassGlowLayerState>();
  }

  /// Returns the [ValueNotifier] that carries live touch-specular data from
  /// the nearest ancestor [GlassGlowLayerState] to [LiquidGlassRenderObject].
  ///
  /// The notifier fires on every spring animation tick when a touch is active
  /// (or on release, as intensity decays to 0). Listeners call
  /// [LiquidGlassRenderObject.setTouchSpecular] directly — zero [setState],
  /// zero widget rebuild, only [RenderObject.markNeedsPaint].
  static ValueNotifier<({Offset position, double intensity})>?
      touchSpecularNotifierOf(BuildContext context) {
    if (!context.mounted) return null;
    return context
        .findAncestorStateOfType<GlassGlowLayerState>()
        ?._touchSpecularNotifier;
  }
}

class GlassGlowLayerState extends State<GlassGlowLayer>
    with TickerProviderStateMixin {
  late final _offsetController = OffsetSpringController(
    vsync: this,
    spring: GlassSpring.smooth(duration: const Duration(seconds: 1)),
    initialValue: Offset.zero,
  );

  late final _alphaController = SingleSpringController(
    vsync: this,
    spring: GlassSpring.smooth(),
    initialValue: 0,
    lowerBound: 0,
    upperBound: 1,
  );

  late final _radiusController = SingleSpringController(
    vsync: this,
    spring: GlassSpring.smooth(),
    initialValue: 1.2,
  );

  /// Carries the current touch position (layer-local logical px) and
  /// spring-animated intensity to [LiquidGlassRenderObject.setTouchSpecular].
  ///
  /// Updated on every spring animation tick, so listeners need not poll.
  /// At rest: intensity == 0.0. While pressed: intensity rises to 1.0.
  final _touchSpecularNotifier =
      ValueNotifier<({Offset position, double intensity})>(
    (position: Offset.zero, intensity: 0.0),
  );

  bool _dragging = false;

  /// Whether a touch is currently active.
  ///
  /// Exposed for testing to verify the spring-switching behaviour introduced
  /// in the glow-follow-speed fix.
  @visibleForTesting
  bool get dragging => _dragging;

  double _baseRadius = 0;
  Color _baseColor = const Color.fromARGB(0, 0, 0, 0);
  double _baseBlurRadius = 0;
  double _baseSpreadRadius = 0;
  double _baseOpacity = 1;

  @override
  void initState() {
    super.initState();
    _offsetController.addListener(_syncTouchSpecular);
    _alphaController.addListener(_syncTouchSpecular);
  }

  void _syncTouchSpecular() {
    final currentIntensity = _alphaController.value;
    final currentPosition = _offsetController.value;
    final prev = _touchSpecularNotifier.value;
    if (prev.intensity != currentIntensity ||
        prev.position != currentPosition) {
      _touchSpecularNotifier.value = (
        position: currentPosition,
        intensity: currentIntensity,
      );
    }
  }

  @override
  void dispose() {
    _offsetController.removeListener(_syncTouchSpecular);
    _alphaController.removeListener(_syncTouchSpecular);
    _offsetController.dispose();
    _alphaController.dispose();
    _radiusController.dispose();
    _touchSpecularNotifier.dispose();
    super.dispose();
  }

  void updateTouch(
    Offset offset, {
    required double radius,
    required Color color,
    double blurRadius = 0,
    double spreadRadius = 0,
    double opacity = 1,
  }) {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    if (_baseRadius != radius ||
        _baseColor != color ||
        _baseBlurRadius != blurRadius ||
        _baseSpreadRadius != spreadRadius ||
        _baseOpacity != clampedOpacity) {
      setState(() {
        _baseRadius = radius;
        _baseColor = color;
        _baseBlurRadius = blurRadius;
        _baseSpreadRadius = spreadRadius;
        _baseOpacity = clampedOpacity;
      });
    }

    if (!_dragging) {
      _dragging = true;
      // Snap to the exact touch point immediately so the glow appears right
      // where the finger lands — not at Offset.zero drifting over. Alpha then
      // fades in at the correct position instead of mid-spring.
      _offsetController.value = offset;
      _alphaController.spring = GlassSpring.interactive();
      _radiusController.spring = GlassSpring.interactive();
      // Switch position tracking to a critically damped smooth spring so the
      // glow follows the finger smoothly without any micro-bounce or resonance jitter.
      _offsetController.spring = GlassSpring.smooth(
        duration: const Duration(milliseconds: 100),
      );
      _alphaController.animateTo(1, fromVelocity: 0);
      _radiusController.animateTo(1, fromVelocity: 0);
      _touchSpecularNotifier.value = (
        position: offset,
        intensity: _alphaController.value,
      );
    } else {
      // Deadband threshold (3.0 px, matching GlassDragBuilder._kTouchSlopPx):
      // ignore capacitive sensor centroid fluctuations on a stationary finger to
      // completely eliminate micro-shaking and spring oscillation during a stationary hold.
      //
      // Position uses an IMMEDIATE set (not animateTo) for the drag phase.
      //
      // Rationale: for buttons with a full glass shader (non-nested), the shader
      // touch-specular is driven by _touchSpecularNotifier at the ACTUAL pointer
      // position (no spring lag) and dominates visually. The local glow-circle
      // spring lag is masked by the shader output.
      //
      // For nested glass (_VibrancyFill, avoidsRefraction = true), the local
      // glow circle IS the only visual feedback — propagateToAncestor is false,
      // so the shader path never fires. A 100 ms spring lag is fully visible on
      // the clean vibrancy surface and reads as jitter/chase to the user.
      //
      // Using _offsetController.value (immediate) eliminates the lag while the
      // 3 px deadband above continues to suppress capacitive noise at a stationary
      // hold. The spring is preserved for the alpha fade-in/out and for the
      // release drift configured in removeTouch().
      final delta = offset - _offsetController.value;
      if (delta.distanceSquared >= 9.0) {
        _offsetController.value = offset;
        _touchSpecularNotifier.value = (
          position: offset,
          intensity: _alphaController.value,
        );
      }
    }
  }

  void removeTouch() {
    if (!_dragging) return;
    _alphaController.spring = GlassSpring.smooth();
    _radiusController.spring = GlassSpring.smooth();
    // Restore smooth spring for the position fade-out drift.
    _offsetController.spring = GlassSpring.smooth(
      duration: const Duration(seconds: 1),
    );
    _dragging = false;
    _radiusController.animateTo(1.2);
    _alphaController.animateTo(0);
    // Notify touch-specular listeners that the touch is gone.
    // Position is kept (last touch point) so the specular fades from the
    // correct spot rather than jumping to Offset.zero.
    _touchSpecularNotifier.value = (
      position: _offsetController.value,
      intensity: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedLiquidGlass>();
    final avoidsRefraction = inherited?.avoidsRefraction ?? false;

    return ListenableBuilder(
      listenable: Listenable.merge([
        _offsetController,
        _alphaController,
        _radiusController,
      ]),
      builder: (context, child) {
        final animatedAlpha = _baseColor.a * _alphaController.value;

        return _RenderGlassGlowLayerWidget(
          clipper: widget.clipper,
          pulse: widget.pulse,
          glowRadius: _baseRadius * _radiusController.value,
          glowColor: _baseColor.withValues(
            alpha: animatedAlpha * _baseOpacity,
          ),
          glowOffset: _offsetController.value,
          glowBlurRadius: _baseBlurRadius,
          glowSpreadRadius: _baseSpreadRadius,
          propagateToAncestor: !avoidsRefraction,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _RenderGlassGlowLayerWidget extends SingleChildRenderObjectWidget {
  const _RenderGlassGlowLayerWidget({
    required this.clipper,
    required this.pulse,
    required this.glowRadius,
    required this.glowColor,
    required this.glowOffset,
    required this.glowBlurRadius,
    required this.glowSpreadRadius,
    this.propagateToAncestor = true,
    required super.child,
  });

  final CustomClipper<Path>? clipper;
  final double pulse;
  final double glowRadius;
  final Color glowColor;
  final Offset glowOffset;
  final double glowBlurRadius;
  final double glowSpreadRadius;
  final bool propagateToAncestor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGlassGlowLayer(
      clipper: clipper,
      pulse: pulse,
      glowRadius: glowRadius,
      glowColor: glowColor,
      glowOffset: glowOffset,
      glowBlurRadius: glowBlurRadius,
      glowSpreadRadius: glowSpreadRadius,
      propagateToAncestor: propagateToAncestor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGlassGlowLayer renderObject,
  ) {
    renderObject
      ..clipper = clipper
      ..pulse = pulse
      ..glowRadius = glowRadius
      ..glowColor = glowColor
      ..glowOffset = glowOffset
      ..glowBlurRadius = glowBlurRadius
      ..glowSpreadRadius = glowSpreadRadius
      ..propagateToAncestor = propagateToAncestor;
  }
}

class _RenderGlassGlowLayer extends RenderProxyBox {
  _RenderGlassGlowLayer({
    required double glowRadius,
    required Color glowColor,
    required Offset glowOffset,
    required double glowBlurRadius,
    required double glowSpreadRadius,
    required double pulse,
    bool propagateToAncestor = true,
    CustomClipper<Path>? clipper,
  })  : _glowRadius = glowRadius,
        _glowColor = glowColor,
        _glowOffset = glowOffset,
        _glowBlurRadius = glowBlurRadius,
        _glowSpreadRadius = glowSpreadRadius,
        _pulse = pulse,
        _propagateToAncestor = propagateToAncestor,
        _clipper = clipper;

  // ---------------------------------------------------------------------------
  // Clipper — path caching + proper shouldReclip / ChangeNotifier wiring.
  //
  // Follows the Flutter engine's RenderCustomClip pattern:
  //   • The computed Path is cached keyed on size, so the
  //     superellipse/oval getOuterPath() construction runs at most once per
  //     layout change, not once per paint frame (120 x/s on ProMotion).
  //   • shouldReclip is respected so value-equal clippers don't invalidate.
  //   • addListener/removeListener wires dynamic clippers that notify on
  //     parameter change (e.g. a morph-animated clipper in GlassButtonGroup).
  // ---------------------------------------------------------------------------
  CustomClipper<Path>? _clipper;
  CustomClipper<Path>? get clipper => _clipper;
  set clipper(CustomClipper<Path>? value) {
    if (_clipper == value) return;
    final oldClipper = _clipper;
    _clipper = value;
    if (value == null) {
      _markNeedsClip();
    } else if (oldClipper == null ||
        oldClipper.runtimeType != value.runtimeType ||
        value.shouldReclip(oldClipper)) {
      _markNeedsClip();
    }
    if (attached) {
      oldClipper?.removeListener(_markNeedsClip);
      value?.addListener(_markNeedsClip);
    }
  }

  Path? _cachedClipPath;
  Size? _cachedClipSize;

  void _markNeedsClip() {
    _cachedClipPath = null;
    _cachedClipSize = null;
    markNeedsPaint();
  }

  /// Returns the clip [Path] for [size], reusing the cached instance when
  /// [size] is unchanged. Eliminates redundant [getOuterPath] calls (and the
  /// associated native [Path] construction) on every animation frame.
  Path _getClipPath(Size size) {
    if (_cachedClipPath == null || _cachedClipSize != size) {
      _cachedClipPath = _clipper!.getClip(size);
      _cachedClipSize = size;
    }
    return _cachedClipPath!;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _clipper?.addListener(_markNeedsClip);
  }

  @override
  void detach() {
    _needsAncestorPropagation = false;
    _clipper?.removeListener(_markNeedsClip);
    super.detach();
  }

  double _pulse;
  double get pulse => _pulse;
  set pulse(double value) {
    if (_pulse == value) return;
    _pulse = value;
    markNeedsPaint();
  }

  double _glowRadius;
  double get glowRadius => _glowRadius;
  set glowRadius(double value) {
    if (_glowRadius == value) return;
    _glowRadius = value;
    markNeedsPaint();
  }

  Color _glowColor;
  Color get glowColor => _glowColor;
  set glowColor(Color value) {
    if (_glowColor == value) return;
    _glowColor = value;
    _propagateToAncestorLiquidGlass();
    markNeedsPaint();
  }

  Offset _glowOffset;
  Offset get glowOffset => _glowOffset;
  set glowOffset(Offset value) {
    if (_glowOffset == value) return;
    _glowOffset = value;
    _propagateToAncestorLiquidGlass();
    markNeedsPaint();
  }

  bool _propagateToAncestor;
  bool get propagateToAncestor => _propagateToAncestor;
  set propagateToAncestor(bool value) {
    if (_propagateToAncestor == value) return;
    _propagateToAncestor = value;
    // If toggled off while a touch is active, flush a zero-intensity
    // notification so the ancestor LiquidGlassRenderObject doesn't retain
    // stale specular data. Consistent with all other property setters.
    _propagateToAncestorLiquidGlass();
  }

  bool _needsAncestorPropagation = false;

  /// Returns true only if every [RenderBox] in the ancestor chain from `this`
  /// up to [ancestor] (inclusive) is attached and has been laid out.
  bool _canTransformToAncestor(RenderObject ancestor) {
    if (!attached || !ancestor.attached) return false;
    RenderObject? node = this;
    while (node != null) {
      if (node is RenderBox && !node.hasSize) {
        return false;
      }
      if (node == ancestor) {
        return true;
      }
      node = node.parent;
    }
    return false;
  }

  /// Propagates touch specular data to an ancestor [LiquidGlassRenderObject]
  /// when [GlassGlow] is placed inside a glass surface (e.g. inside [GlassButton]).
  void _propagateToAncestorLiquidGlass() {
    if (!_propagateToAncestor) {
      _needsAncestorPropagation = false;
      RenderObject? p = parent;
      while (p != null) {
        if (p is LiquidGlassRenderObject) {
          p.setTouchSpecular(Offset.zero, 0.0);
          break;
        }
        p = p.parent;
      }
      return;
    }

    RenderObject? p = parent;
    while (p != null) {
      if (p is LiquidGlassRenderObject) {
        if (_canTransformToAncestor(p)) {
          _needsAncestorPropagation = false;
          final layerPos = localToGlobal(_glowOffset, ancestor: p);
          p.setTouchSpecular(layerPos, _glowColor.a);
        } else {
          p.setTouchSpecular(_glowOffset, _glowColor.a);
          if (!_needsAncestorPropagation && attached) {
            _needsAncestorPropagation = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!attached || !_needsAncestorPropagation) return;
              _needsAncestorPropagation = false;
              _propagateToAncestorLiquidGlass();
            });
          }
        }
        break;
      }
      p = p.parent;
    }
  }

  double _glowBlurRadius;
  double get glowBlurRadius => _glowBlurRadius;
  set glowBlurRadius(double value) {
    if (_glowBlurRadius == value) return;
    _glowBlurRadius = value;
    markNeedsPaint();
  }

  double _glowSpreadRadius;
  double get glowSpreadRadius => _glowSpreadRadius;
  set glowSpreadRadius(double value) {
    if (_glowSpreadRadius == value) return;
    _glowSpreadRadius = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 1. Paint the children (which includes AdaptiveGlass taking its backdrop snapshot)
    super.paint(context, offset);

    final canvas = context.canvas;
    final bool hasClipper = _clipper != null;

    // For both drawing operations we translate the canvas to the render
    // object's local origin before clipping and drawing. This means:
    //   • _getClipPath returns a path in [0,0,width,height] — no .shift() needed.
    //   • drawRect / drawCircle arguments live in local space.
    // The net effect: 0 Path allocations per frame during the spring animation
    // (previously 2 per frame: getClip() construction + .shift() clone).

    // 2. Global Specular Pulse (full-window additive highlight, driven by GlassModalSheet
    //    saturation controller during high-velocity drag interactions).
    if (_pulse > 0) {
      final pulsePaint = Paint()
        // Renderer optical constant — pure white is the correct math anchor for saturation bloom.
        ..color = CupertinoColors.white.withValues(alpha: 0.08 * _pulse)
        ..blendMode = BlendMode.plus;

      if (hasClipper) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.clipPath(_getClipPath(size));
        canvas.drawRect(Offset.zero & size, pulsePaint);
        canvas.restore();
      } else {
        canvas.drawRect(offset & size, pulsePaint);
      }
    }

    // 3. Local Interactive Glow (finger glare — radial gradient following the touch point)
    if (_glowColor.a > 0 && _glowRadius > 0) {
      // _glowOffset is in local layer coordinates: _handlePointer converts the
      // raw pointer position from GlassGlow-local → global → GlassGlowLayer-local
      // before calling updateTouch(), so no further adjustment is needed here.
      final shortSide = math.min(size.width, size.height);
      final radius = _glowRadius * shortSide + _glowSpreadRadius * shortSide;

      // RadialGradient.createShader() bakes the center position into the shader
      // via the Rect passed to it — caching across position changes is incorrect.
      // Per-frame creation is cheap for a simple radial gradient (uniform-only).
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [_glowColor, _glowColor.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: _glowOffset, radius: radius))
        ..blendMode = BlendMode.plus;

      // Optional Gaussian blur to soften the glow halo. Only create the
      // MaskFilter when non-zero to avoid a no-op allocation every frame.
      if (_glowBlurRadius > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, _glowBlurRadius);
      }

      // Additive specular light, clipped to the glass geometry boundary.
      if (hasClipper) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.clipPath(_getClipPath(size));
        canvas.drawCircle(_glowOffset, radius, paint);
        canvas.restore();
      } else {
        canvas.drawCircle(offset + _glowOffset, radius, paint);
      }
    }
  }
}
