// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: avoid_setters_without_getters, public_member_api_docs

import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../renderer/glass_backdrop_group.dart';
import '../renderer/glass_backdrop_group_boundary.dart';
import '../renderer/glass_frost_budget.dart';
import '../renderer/glass_materialize_scope.dart';
import '../renderer/liquid_glass_push_back_scope.dart';
import '../renderer/liquid_glass_self_scale_scope.dart';
import 'glass_glow.dart';
import 'internal/transform_tracking_repaint_boundary_mixin.dart';
import 'liquid_glass_render_scope.dart';
import 'liquid_glass_settings.dart';
import 'multi_shader_builder.dart';
import 'render_liquid_glass_geometry.dart';
import 'rendering/liquid_glass_render_object.dart';
import 'shaders.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Scale-safe repaint boundary
//
// Flutter's built-in [RepaintBoundary] rasterises its subtree to a GPU texture
// whose dimensions exactly match the widget's layout size.  When an ancestor
// [Transform.scale] (e.g. from [LiquidStretch] during a press animation) tries
// to expand that texture beyond its original bounds, Impeller clips at the
// layer boundary — producing the "top-cut" artefact on nav-bar buttons.
//
// [_ScaleSafeRepaintBoundary] is a drop-in replacement that overrides
// [paintBounds] to include the [clipExpansion] insets in all four directions.
// This tells Impeller to allocate a slightly larger texture so the scale
// animation has transparent headroom to paint into.
//
// When [clipExpansion] is [EdgeInsets.zero] (the default) the behaviour is
// identical to a plain [RepaintBoundary] — zero extra GPU cost.
// ─────────────────────────────────────────────────────────────────────────────

class _ScaleSafeRepaintBoundary extends SingleChildRenderObjectWidget {
  const _ScaleSafeRepaintBoundary({
    required super.child,
    this.expansion = EdgeInsets.zero,
  });

  /// Extra space (logical pixels) to inflate [paintBounds] in each direction.
  ///
  /// Set this to the same value as [LiquidGlassLayer.clipExpansion] so the
  /// repaint-boundary texture is large enough to absorb any ancestor scale or
  /// translate transform without hard-clipping the glass content.
  final EdgeInsets expansion;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderScaleSafeRepaintBoundary(expansion: expansion);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderScaleSafeRepaintBoundary renderObject,
  ) {
    renderObject.expansion = expansion;
  }
}

class _RenderScaleSafeRepaintBoundary extends RenderProxyBox {
  _RenderScaleSafeRepaintBoundary({required EdgeInsets expansion})
      : _expansion = expansion;

  EdgeInsets _expansion;
  set expansion(EdgeInsets value) {
    if (_expansion == value) return;
    _expansion = value;
    markNeedsPaint();
  }

  /// Acts as a repaint boundary — tells Flutter to rasterise the subtree into
  /// its own GPU layer rather than painting inline into the parent.
  @override
  bool get isRepaintBoundary => true;

  /// Inflate the declared paint area by [_expansion].  This causes Impeller to
  /// allocate a texture whose pixel region includes the expansion margin, so
  /// parent [Transform.scale] animations can expand into that space without
  /// triggering a hard clip at the original layout boundary.
  @override
  Rect get paintBounds => Rect.fromLTRB(
        -_expansion.left,
        -_expansion.top,
        size.width + _expansion.right,
        size.height + _expansion.bottom,
      );
}

/// Represents a layer of multiple [LiquidGlass] shapes or
/// [LiquidGlassBlendGroup]s that have shared [LiquidGlassSettings] and will be
/// rendered together.
///
/// If you create a [LiquidGlassLayer] with one or more [LiquidGlass] or
/// [LiquidGlassBlendGroup] widgets, the liquid glass effect will be rendered
/// where this layer is.
///
/// Make sure not to stack any other widgets between the [LiquidGlassLayer] and
/// the [LiquidGlass] widgets, otherwise the liquid glass effect will be behind
/// them.
///
/// ## Example
///
/// ```dart
/// Widget build(BuildContext context) {
///   return LiquidGlassLayer(
///     child: Column(
///       children: [
///         LiquidGlass(
///           shape: LiquidRoundedSuperellipse(
///             borderRadius: 10,
///           ),
///           child: const SizedBox.square(
///             dimension: 100,
///           ),
///         ),
///         const SizedBox(height: 100),
///         LiquidGlassBlendGroup(
///          blend: 20,
///          child: Row(
///             children: [
///               LiquidGlass.grouped(
///                 shape: const LiquidOval(),
///                 child: const SizedBox.square(
///                   dimension: 100,
///                 ),
///               ),
///               LiquidGlass.grouped(
///                 shape: const LiquidRoundedSuperellipse(
///                   borderRadius: 20,
///                 ),
///                 child: const SizedBox.square(
///                   dimension: 100,
///                 ),
///               ),
///             ],
///           ),
///         ),
///       ],
///     ),
///   );
/// }
class LiquidGlassLayer extends StatefulWidget {
  /// Creates a new [LiquidGlassLayer] with the given [child] and [settings].
  const LiquidGlassLayer({
    required this.child,
    this.settings = const LiquidGlassSettings(),
    this.shadows = const <BoxShadow>[],
    this.clipExpansion = EdgeInsets.zero,
    this.captureImage,
    this.captureOriginInScreenSpace = Offset.zero,
    super.key,
  });

  /// The subtree in which you should include at least one [LiquidGlass] widget.
  ///
  /// The [LiquidGlassLayer] will automatically register all [LiquidGlass]
  /// widgets in the subtree as shapes and render them.
  final Widget child;

  /// The settings for the liquid glass effect for all shapes in this layer.
  final LiquidGlassSettings settings;

  /// The shadows to render using the merged SDF geometry.
  final List<BoxShadow> shadows;

  /// Extra space to add around the geometry bounding box before clipping the
  /// [BackdropFilterLayer] that runs the glass shader.
  ///
  /// The clip rect is normally tight to the glass shape's geometry.  Any
  /// ancestor [Transform] (e.g. jelly squash-and-stretch on an indicator)
  /// can push painted pixels outside that tight rect, producing a hard edge
  /// cutoff.  Set [clipExpansion] to a safe margin that covers the maximum
  /// expected deformation so the shader is applied over the full animated area.
  ///
  /// Defaults to [EdgeInsets.zero] — zero extra GPU cost for static glass.
  final EdgeInsets clipExpansion;

  /// Pre-captured background image to use instead of a live [BackdropFilterLayer].
  ///
  /// When non-null, the glass shader reads from this image directly (sampler
  /// slot 0) instead of letting the compositor extract the backdrop. This
  /// eliminates the Impeller compositor ordering dependency that caused the
  /// opaque-white indicator bug (#99). The image must come from a
  /// [RenderRepaintBoundary.toImageSync] call on a boundary that covers the
  /// full background region behind the glass.
  ///
  /// Defaults to null — falls through to the BackdropFilterLayer path.
  final ui.Image? captureImage;

  /// The global (screen-space) logical-pixel origin of the [RepaintBoundary]
  /// that produced [captureImage]. Used to compute `uCaptureOffset` inside
  /// the shader so `FlutterFragCoord()` fragments are correctly mapped into
  /// the capture image's coordinate space.
  ///
  /// Ignored when [captureImage] is null.
  final Offset captureOriginInScreenSpace;

  @override
  State<LiquidGlassLayer> createState() => _LiquidGlassLayerState();
}

class _LiquidGlassLayerState extends State<LiquidGlassLayer>
    with SingleTickerProviderStateMixin {
  late final GeometryRenderLink _link = GeometryRenderLink();
  late final BackdropKey _backdropKey = BackdropKey();

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [LOCAL PATCH]: a running materialize transition above this layer
    // dissolves its glass through the settings' visibility channel — the one
    // fade the backdrop pass honours. Identity (the same instance) at rest.
    final settings =
        GlassMaterializeScope.resolveSettings(context, widget.settings);

    if (!ImageFilter.isShaderFilterSupported) {
      return LiquidGlassRenderScope(
        settings: settings,
        child: InheritedGeometryRenderLink(
          link: _link,
          child: widget.child,
        ),
      );
    }

    return BackdropGroup(
      // Inside a GlassBackdropGroup the blur and frost passes share the
      // group's backdrop read instead of this layer's own.
      backdropKey: GlassBackdropGroup.keyOf(context) ?? _backdropKey,
      child: _ScaleSafeRepaintBoundary(
        // Inflate the RepaintBoundary texture by clipExpansion so that any
        // ancestor Transform.scale (e.g. LiquidStretch press animation) can
        // expand into the margin without hard-clipping at the original bounds.
        expansion: widget.clipExpansion,
        child: LiquidGlassRenderScope(
          settings: settings,
          child: InheritedGeometryRenderLink(
            link: _link,
            child: ShaderBuilder(
              assetKey: ShaderKeys.liquidGlassRender,
              (context, shader, child) => _TouchSpecularBridge(
                renderShader: shader,
                backdropKey: BackdropGroup.of(context)?.backdropKey,
                settings: settings,
                shadows: widget.shadows,
                link: _link,
                clipExpansion: widget.clipExpansion,
                captureImage: widget.captureImage,
                captureOriginInScreenSpace: widget.captureOriginInScreenSpace,
                selfScaled: LiquidGlassSelfScaleScope.of(context),
                pushBackActive: LiquidGlassPushBackScope.of(context),
                child: child!,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TouchSpecularBridge — zero-rebuild touch-specular wiring
//
// Subscribes to GlassGlowLayer.touchSpecularNotifierOf() and pushes position
// + intensity directly to RenderLiquidGlassLayer.setTouchSpecular().
//
// No setState. No widget rebuild. The listener fires on every spring animation
// tick (driven by GlassGlowLayerState's ListenableBuilder) and calls
// markNeedsPaint() on the render object only when values have changed.
//
// If no GlassGlowLayer ancestor exists (e.g. GlassAppBar with no GlassButton
// children), touchSpecularNotifierOf returns null and this bridge is a
// transparent passthrough with zero overhead.
// ---------------------------------------------------------------------------
class _TouchSpecularBridge extends StatefulWidget {
  const _TouchSpecularBridge({
    required this.renderShader,
    required this.backdropKey,
    required this.settings,
    required this.shadows,
    required this.link,
    required this.child,
    this.clipExpansion = EdgeInsets.zero,
    this.captureImage,
    this.captureOriginInScreenSpace = Offset.zero,
    this.selfScaled = false,
    this.pushBackActive = false,
  });

  final FragmentShader renderShader;
  final BackdropKey? backdropKey;
  final LiquidGlassSettings settings;
  final List<BoxShadow> shadows;
  final GeometryRenderLink link;
  final Widget child;
  final EdgeInsets clipExpansion;
  final ui.Image? captureImage;
  final Offset captureOriginInScreenSpace;
  final bool selfScaled;
  final bool pushBackActive;

  @override
  State<_TouchSpecularBridge> createState() => _TouchSpecularBridgeState();
}

class _TouchSpecularBridgeState extends State<_TouchSpecularBridge> {
  final _rawShapesKey = GlobalKey();
  ValueNotifier<({Offset position, double intensity})>? _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebindNotifier();
  }

  void _rebindNotifier() {
    final next = GlassGlowLayer.touchSpecularNotifierOf(context);
    if (next == _notifier) return;
    _notifier?.removeListener(_onTouchSpecular);
    _notifier = next;
    _notifier?.addListener(_onTouchSpecular);
  }

  void _onTouchSpecular() {
    final v = _notifier?.value;
    if (v == null) return;
    final ro = _rawShapesKey.currentContext?.findRenderObject()
        as RenderLiquidGlassLayer?;
    if (ro == null) return;

    final layerBox = GlassGlowLayer.maybeOf(context)?.context.findRenderObject()
        as RenderBox?;
    final Offset pos;
    if (layerBox != null && layerBox.attached && layerBox.hasSize) {
      pos = layerBox.localToGlobal(v.position);
    } else {
      pos = v.position;
    }
    ro.setTouchSpecular(pos, v.intensity);
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onTouchSpecular);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RawShapes(
      key: _rawShapesKey,
      renderShader: widget.renderShader,
      backdropKey: widget.backdropKey,
      settings: widget.settings,
      shadows: widget.shadows,
      link: widget.link,
      clipExpansion: widget.clipExpansion,
      captureImage: widget.captureImage,
      captureOriginInScreenSpace: widget.captureOriginInScreenSpace,
      selfScaled: widget.selfScaled,
      pushBackActive: widget.pushBackActive,
      child: widget.child,
    );
  }
}

class _RawShapes extends SingleChildRenderObjectWidget {
  const _RawShapes({
    required this.renderShader,
    required this.backdropKey,
    required this.settings,
    required this.shadows,
    required Widget super.child,
    required this.link,
    super.key,
    this.clipExpansion = EdgeInsets.zero,
    this.captureImage,
    this.captureOriginInScreenSpace = Offset.zero,
    this.selfScaled = false,
    this.pushBackActive = false,
  });

  final FragmentShader renderShader;
  final BackdropKey? backdropKey;
  final LiquidGlassSettings settings;
  final List<BoxShadow> shadows;
  final GeometryRenderLink link;
  final EdgeInsets clipExpansion;
  final ui.Image? captureImage;
  final Offset captureOriginInScreenSpace;

  /// See [LiquidGlassSelfScaleScope].
  final bool selfScaled;

  /// See [LiquidGlassPushBackScope]. When `false` (the default),
  /// [RenderLiquidGlassLayer._hasScale] always returns `false` regardless of
  /// the ancestor transform — a static app-level scale (e.g.
  /// `responsive_framework`) never freezes UV coordinates.
  final bool pushBackActive;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLiquidGlassLayer(
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      renderShader: renderShader,
      backdropKey: backdropKey,
      settings: GlassFrostBudget.apply(context, settings),
      shadows: shadows,
      link: link,
      clipExpansion: clipExpansion,
      captureImage: captureImage,
      captureOriginInScreenSpace: captureOriginInScreenSpace,
      selfScaled: selfScaled,
      pushBackActive: pushBackActive,
    )..sharedBackdrop = GlassBackdropGroup.keyOf(context) != null;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLiquidGlassLayer renderObject,
  ) {
    renderObject
      ..link = link
      ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context)
      ..settings = GlassFrostBudget.apply(context, settings)
      ..shadows = shadows
      ..backdropKey = backdropKey
      ..clipExpansion = clipExpansion
      ..captureImage = captureImage
      ..captureOriginInScreenSpace = captureOriginInScreenSpace
      ..selfScaled = selfScaled
      ..pushBackActive = pushBackActive
      ..sharedBackdrop = GlassBackdropGroup.keyOf(context) != null;
  }
}

class RenderLiquidGlassLayer extends LiquidGlassRenderObject
    with TransformTrackingRenderObjectMixin {
  RenderLiquidGlassLayer({
    required super.renderShader,
    required super.devicePixelRatio,
    required super.settings,
    required this.shadows,
    required super.link,
    super.backdropKey,
    super.captureImage,
    super.captureOriginInScreenSpace,
    EdgeInsets clipExpansion = EdgeInsets.zero,
    bool selfScaled = false,
    bool pushBackActive = false,
  })  : _clipExpansion = clipExpansion,
        _selfScaled = selfScaled,
        _pushBackActive = pushBackActive;

  // ── Cached filters ──────────────────────────────────────────────────────
  // The BackdropFilterLayers' filters are rebuilt only when their settings
  // change — not on every paint frame during jelly/morph animations.
  ImageFilter? _cachedBlur;
  double _cachedBlurSigma = -1;
  ImageFilter? _cachedFrost;
  double _cachedFrostSigma = -1;
  ColorFilter? _cachedWeight;
  double _cachedWeightValue = 1;
  ImageFilter? _cachedSharedFrost;

  /// Whether this layer's blur and frost share the backdrop read of an
  /// enclosing [GlassBackdropGroup]; see there.
  bool get sharedBackdrop => _sharedBackdrop;
  bool _sharedBackdrop = false;
  set sharedBackdrop(bool value) {
    if (_sharedBackdrop == value) return;
    _sharedBackdrop = value;
    markNeedsPaint();
  }

  /// The group this layer shares the backdrop read with, while it does.
  RenderGlassBackdropGroupBoundary? _group;

  /// Whether the last paint shared the group's backdrop read.
  @visibleForTesting
  bool get debugSharesBackdrop => _sharesBackdrop;
  bool _sharesBackdrop = false;

  /// Runs the group check [paintLiquidGlass] runs; see there.
  @visibleForTesting
  bool debugResolveSharing() => _resolveSharing();

  /// Joins or leaves the enclosing group for this paint, and says whether
  /// the blur and frost share its backdrop read: only with another member
  /// in it, and only while no render pass of its own opens between this
  /// layer and the group (see [opensRenderPassBelow]).
  bool _resolveSharing() {
    final group = sharedBackdrop && backdropKey != null
        ? enclosingBackdropGroup(this)
        : null;
    if (!identical(group, _group)) {
      _group?.leave(this);
      _group = group;
    }
    group?.join(this);
    return _sharesBackdrop = group != null && group.memberCount >= 2;
  }

  @override
  void detach() {
    _group?.leave(this);
    _group = null;
    super.detach();
  }

  // ── Baked shadow ────────────────────────────────────────────────────────
  // The shadows drawn once into an image while the geometry holds still, so
  // a resting surface doesn't pay a saveLayer and a blur for them on every
  // frame the backdrop moves. See _paintShadows.
  ui.Image? _lastShadowGeometry;
  ui.Image? _bakedShadow;
  Rect _bakedShadowRect = Rect.zero;
  ui.Image? _bakedShadowGeometry;
  List<BoxShadow>? _bakedShadowList;
  Rect _bakedShadowBounds = Rect.zero;
  double _bakedShadowDpr = 0;

  final _shaderHandle = LayerHandle<BackdropFilterLayer>();
  final _blurLayerHandle = LayerHandle<BackdropFilterLayer>();
  final _frostLayerHandle = LayerHandle<BackdropFilterLayer>();
  final _weightLayerHandle = LayerHandle<BackdropFilterLayer>();
  final _clipRectLayerHandle = LayerHandle<ClipRectLayer>();
  final _clipPathLayerHandle = LayerHandle<ClipPathLayer>();
  final _frostClipLayerHandle = LayerHandle<ClipPathLayer>();
  final _frostRowsLayerHandle = LayerHandle<ClipPathLayer>();

  /// The union of [shapes]' paths in local coordinates.
  Path _shapePath(
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> shapes,
  ) {
    final path = Path();
    for (final geometry in shapes) {
      if (!geometry.$1.attached) continue;
      path.addPath(
        geometry.$2.path,
        Offset.zero,
        matrix4: geometry.$3.storage,
      );
    }
    return path;
  }

  EdgeInsets _clipExpansion;
  set clipExpansion(EdgeInsets value) {
    if (_clipExpansion == value) return;
    _clipExpansion = value;
    markNeedsPaint();
  }

  /// See [LiquidGlassSelfScaleScope]. Repaints on change: the shader's shape
  /// bounds are derived from [matteTransform], which this switches.
  bool _selfScaled;
  set selfScaled(bool value) {
    if (_selfScaled == value) return;
    _selfScaled = value;
    markNeedsPaint();
  }

  /// See [LiquidGlassPushBackScope]. When `false`, [_hasScale] returns
  /// `false` unconditionally — a static app-level scale (e.g.
  /// `responsive_framework`) is never mistaken for a CupertinoSheet push-back.
  bool _pushBackActive;
  set pushBackActive(bool value) {
    if (_pushBackActive == value) return;
    // Called by updateRenderObject during build. An attached ancestor may
    // still need layout (e.g. a newly inserted route SlideTransition), so
    // reading getTransformTo here can throw. Refresh the resting snapshot
    // on the next paint, after the entire ancestor chain has been laid out.
    _pushBackActive = value;
    markNeedsPaint();
  }

  List<BoxShadow> shadows;

  @override
  Size get desiredMatteSize => switch (owner?.rootNode) {
        final RenderView rv => rv.size,
        final RenderBox rb => rb.size,
        _ => Size.zero,
      };

  Matrix4? _unscaledTransform;
  Offset? _unscaledCaptureOrigin;

  bool _hasScale(Matrix4 m) {
    // A surface scaling itself leaves its backdrop where it was, so the live
    // transform is the right one and freezing would strand the shape.
    if (_selfScaled) return false;
    // A push-back scope must be active — a persistent app-level scale
    // (e.g. responsive_framework, FittedBox, InteractiveViewer) must never
    // freeze UV coordinates. Only a CupertinoSheet push-back emits the scope.
    if (!_pushBackActive) return false;
    // Detects the CupertinoSheet push-back, which scales the page down
    // uniformly on both X and Y axes simultaneously (< 1.0 on both).
    //
    // Requiring BOTH axes to shrink correctly rejects:
    //   - 1D jelly physics (one axis squashes, the other stretches; always one >= 1.0)
    //   - Pure translations (both axes remain 1.0)
    //   - Z-axis perspective flattening (m[10] == 0 but m[0] == m[5] == 1)
    final scaleX = m[0].abs();
    final scaleY = m[5].abs();
    // Use a very tight tolerance (0.9999) to catch the very first frame of the CupertinoSheet
    // scale animation. A looser tolerance (0.99) allowed early frames of the animation
    // (e.g., 0.995) to overwrite the snapshot before freezing, causing a slight jump.
    const threshold = LiquidGlassSelfScaleScope.freezeScaleThreshold;
    return (scaleX < threshold && scaleX > 0.0) &&
        (scaleY < threshold && scaleY > 0.0);
  }

  /// Snapshots the layer's current screen-space transform and capture origin
  /// whenever no ancestor scale is active. When a scale IS active (e.g.
  /// CupertinoSheet push-back), the snapshot is frozen at the last unscaled
  /// values so [matteTransform] and [captureOriginInScreenSpace] can return
  /// coordinates that match the unscaled [captureImage] texture.
  ///
  /// Called from [paint] on every frame — not from
  /// [onTransformChanged] — because [GeometryTransformTrackingLayer] skips
  /// the callback on the very first frame (when [_lastTransform] is null), and
  /// only fires again when the accumulated transform actually changes between
  /// scene builds.  A CupertinoSheet that opens before any movement would leave
  /// [_unscaledTransform] null if we relied on [onTransformChanged] alone,
  /// causing the frozen-coordinate fallback to silently miss.
  ///
  /// Updating a cached field inside [paint] is safe: it calls no
  /// [markNeedsPaint], no [setState], and no layout-invalidation, so it does
  /// not violate Flutter's read-only paint contract.
  void _updateScaleState(
      Matrix4 currentTransform, Offset currentCaptureOrigin) {
    if (!_hasScale(currentTransform)) {
      _unscaledTransform = currentTransform;
      _unscaledCaptureOrigin = currentCaptureOrigin;
    }
  }

  @override
  Matrix4 get matteTransform {
    if (_unscaledTransform case final frozen?
        when _hasScale(getTransformTo(null))) {
      return frozen;
    }
    return getTransformTo(null);
  }

  @override
  Offset get captureOriginInScreenSpace {
    if (_unscaledCaptureOrigin case final frozen?
        when _hasScale(getTransformTo(null))) {
      return frozen;
    }
    return super.captureOriginInScreenSpace;
  }

  @override
  void onTransformChanged() {
    // Geometry is in LOCAL space; matteTransform is applied at paint time,
    // so only a repaint — not a layout/geometry rebuild — is required here.
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!attached) return;
    // Refresh before the base paint reads matteTransform to build geometry.
    // This also records the resting baseline when geometry is not ready yet.
    _updateScaleState(getTransformTo(null), super.captureOriginInScreenSpace);
    super.paint(context, offset);
  }

  @override
  void paintLiquidGlass(
    PaintingContext context,
    Offset offset,
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> shapes,
    Rect boundingBox,
  ) {
    if (!attached) return;
    final shared = _resolveSharing();

    // ── Pass 0: SDF Shadows ──────────────────────────────────────────────────
    if (shadows.isNotEmpty && geometryImage != null) {
      _paintShadows(
        context.canvas,
        offset,
        geometryImage!,
        geometryLocalBounds,
      );
    }

    // ── Pass 1a: Blur ────────────────────────────────────────────────────────
    // Use Flutter's native ImageFilter.blur for smooth, multi-pass Gaussian
    // quality (the inline 9-tap shader approximation was pixelated with text).
    // Clip tightly to the actual pill shape path — no expansion needed here.
    //
    // Under a frost the render shader blurs the ghost itself, from the sharp
    // rows the frost pass leaves (see Pass 1b), so there is no blur pass
    // unless the blur is wider than the shader takes.
    final frostRows = frostRowsPath;
    if (settings.effectiveBlur > 0 &&
        (frostRows == null ||
            settings.effectiveBlur * devicePixelRatio >
                LiquidGlassRenderObject.frostGhostMaxSigma)) {
      final blurSigma = settings.effectiveBlur;
      // Reuse cached blur filter when sigma hasn't changed.
      if (_cachedBlur == null || _cachedBlurSigma != blurSigma) {
        _cachedBlur = ImageFilter.blur(
          tileMode: TileMode.mirror,
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        );
        _cachedBlurSigma = blurSigma;
      }

      final blurLayer = (_blurLayerHandle.layer ??= BackdropFilterLayer())
        // Outside a group the key is this layer's own BackdropGroup. A group
        // member that does not share this frame (alone, or in a render pass
        // of its own) must not use the group's key.
        ..backdropKey = shared || !sharedBackdrop ? backdropKey : null
        ..filter = _cachedBlur!;

      _clipPathLayerHandle.layer = context.pushClipPath(
        needsCompositing,
        offset,
        boundingBox,
        _shapePath(shapes),
        (context, offset) {
          context.pushLayer(
            blurLayer,
            (context, offset) {
              paintShapeContents(context, offset, shapes, insideGlass: true);
            },
            offset,
          );
        },
        oldLayer: _clipPathLayerHandle.layer,
      );
    } else if (frostRows != null) {
      _blurLayerHandle.layer = null;
      // Straight onto the backdrop, where the frost will read it.
      _clipPathLayerHandle.layer = context.pushClipPath(
        needsCompositing,
        offset,
        boundingBox,
        _shapePath(shapes),
        (context, offset) {
          paintShapeContents(context, offset, shapes, insideGlass: true);
        },
        oldLayer: _clipPathLayerHandle.layer,
      );
    } else {
      _blurLayerHandle.layer = null;
      _clipPathLayerHandle.layer = null;
    }

    // ── Pass 1b: Frost ───────────────────────────────────────────────────────
    // The cloud of iOS 27 glass: a wide blur of the backdrop, written only to
    // alternate pixel rows of the shape (frostRowsPath), so the sharp
    // backdrop survives on the rows between. The render shader reads both
    // and makes the ghost, the clamp and the mix itself (uFrost), which keeps
    // the frost to one plain blur pass: on Impeller any other filter stage
    // composed with a backdrop blur measured as costly as a pass over the
    // whole screen. Not part of the layer's BackdropGroup, so that content
    // painted inside the glass above is in what it reads, unless the layer
    // sits in a GlassBackdropGroup.
    if (frostRows != null) {
      final frostSigma = settings.effectiveFrost;
      if (_cachedFrost == null || _cachedFrostSigma != frostSigma) {
        _cachedSharedFrost = null;
        _cachedFrost = ImageFilter.blur(
          tileMode: TileMode.mirror,
          sigmaX: frostSigma,
          sigmaY: frostSigma,
        );
        _cachedFrostSigma = frostSigma;
      }
      final weight = settings.frostWeight;
      final weighted = weight != 1.0 && weight > 0;
      if (weighted && (_cachedWeight == null || _cachedWeightValue != weight)) {
        // alpha = base + slope * luma, with white weighing `weight` times
        // black and the heavier end at 1.
        final base = weight > 1 ? 1 / weight : 1.0;
        final slope = weight > 1 ? 1 - 1 / weight : weight - 1;
        _cachedWeight = ColorFilter.matrix(<double>[
          1, 0, 0, 0, 0, //
          0, 1, 0, 0, 0, //
          0, 0, 1, 0, 0, //
          slope * 0.2126, slope * 0.7152, slope * 0.0722, base, 0, //
        ]);
        _cachedWeightValue = weight;
        _cachedSharedFrost = null;
      }
      // In a GlassBackdropGroup the frost reads the group's shared backdrop,
      // so the weight can't be written into the backdrop by a pass of its
      // own first: it goes ahead of the blur in the same filter. Alone that
      // costs more than the two passes; shared, the engine runs the filter
      // once for every surface with the same settings.
      ImageFilter frostFilter = _cachedFrost!;
      if (shared && weighted) {
        frostFilter = _cachedSharedFrost ??= ImageFilter.compose(
          outer: _cachedFrost!,
          inner: _cachedWeight!,
        );
      }
      final frostLayer = (_frostLayerHandle.layer ??= BackdropFilterLayer())
        ..backdropKey = shared ? backdropKey : null
        // Replaces rather than covers the weighted pixels below, so the
        // cloud rows keep the blurred weight in their alpha.
        ..blendMode = weighted ? BlendMode.src : BlendMode.srcOver
        ..filter = frostFilter;

      // frostWeight: the shape is first given an alpha that weights each
      // pixel by its luminance, colour premultiplied by it, so the blur's
      // unpremultiplied result is a weighted mean in which light (or dark)
      // pixels count for more; the sharp rows unpremultiply back to what
      // they were. A lone colour filter stays within the clip; ahead of the
      // blur in one filter it would not.
      if (weighted && !shared) {
        (_weightLayerHandle.layer ??= BackdropFilterLayer())
          ..backdropKey = null
          // Only the alpha is taken: the pixels beneath keep their colour,
          // premultiplied by it.
          ..blendMode = BlendMode.dstIn
          ..filter = _cachedWeight!;
      } else {
        _weightLayerHandle.layer = null;
      }

      _frostClipLayerHandle.layer = context.pushClipPath(
        needsCompositing,
        offset,
        boundingBox,
        _shapePath(shapes),
        (context, offset) {
          if (_weightLayerHandle.layer case final weightLayer?) {
            context.pushLayer(weightLayer, (context, offset) {}, offset);
          }
          _frostRowsLayerHandle.layer = context.pushClipPath(
            needsCompositing,
            offset,
            boundingBox,
            frostRows,
            (context, offset) {
              context.pushLayer(frostLayer, (context, offset) {}, offset);
            },
            clipBehavior: Clip.hardEdge,
            oldLayer: _frostRowsLayerHandle.layer,
          );
        },
        oldLayer: _frostClipLayerHandle.layer,
      );
    } else {
      _frostLayerHandle.layer = null;
      _weightLayerHandle.layer = null;
      _frostClipLayerHandle.layer = null;
      _frostRowsLayerHandle.layer = null;
    }

    // ── Pass 2: Glass refraction + lighting shader ────────────────────────────
    // Inflate the clip rect by _clipExpansion so jelly squash-and-stretch can
    // push deformed pixels beyond the tight bounding box without a hard clip
    // edge. For static glass _clipExpansion == EdgeInsets.zero (no-op).
    final clipRect = _clipExpansion == EdgeInsets.zero
        ? boundingBox
        : Rect.fromLTRB(
            boundingBox.left - _clipExpansion.left,
            boundingBox.top - _clipExpansion.top,
            boundingBox.right + _clipExpansion.right,
            boundingBox.bottom + _clipExpansion.bottom,
          );

    // Capture path: when a pre-captured background image is available, bypass
    // the BackdropFilterLayer entirely and draw the shader directly onto the
    // canvas, binding the captured image as uBackgroundTexture (slot 0).
    // This eliminates the live compositor read, making the indicator rendering
    // deterministic and immune to Impeller compositor ordering bugs (#99).
    //
    // IMPORTANT: skip the capture path when the ancestor transform applies a scale
    // (e.g. during a CupertinoSheet drag). The capture image's UV coordinates are
    // computed relative to the layer's original bounds. When scaled, FlutterFragCoord()
    // shifts relative to the baked UV constants, sending samples out of range →
    // The captureImage path correctly maps coordinates on Impeller, but suffers from
    // double-scaling if the ancestor transform applies a scale (like CupertinoSheet drag),
    // because the captureImage itself is captured unscaled.
    // To fix this, we snapshot the layer's unscaled transform on every paint
    // via _updateScaleState. The moment a 3D perspective scale is applied,
    // the snapshot stops updating. The matteTransform and
    // captureOriginInScreenSpace getters then return the last known unscaled
    // coordinates, perfectly neutralising the double-scale artifact.

    if (captureImage case final capture?) {
      paintLiquidGlassWithCapture(
        context,
        offset,
        shapes,
        clipRect,
        capture,
      );
      // paintLiquidGlassWithCapture handles all three passes (blur, shader, contents).
      // Release the stale BackdropFilter layer handles so the engine can collect
      // the offscreen surface when we're no longer using the backdrop path.
      _shaderHandle.layer = null;
      _clipRectLayerHandle.layer = null;
      // Capture path does not open a live backdrop pass — clear so that
      // descendant glass does not inherit a stale pass rect.
      backdropPassClipRectLocal = null;
      return;
    }
    // BackdropFilter path (default): live compositor read via BackdropFilterLayer.
    // Publish the clip rect so descendant premium glass can find the pass their
    // FlutterFragCoord() is relative to (see enclosingBackdropPassRect).
    backdropPassClipRectLocal = clipRect;
    final shaderLayer = (_shaderHandle.layer ??= BackdropFilterLayer())
      ..filter = ImageFilter.shader(renderShader!);

    _clipRectLayerHandle.layer = context.pushClipRect(
      needsCompositing,
      offset,
      clipRect,
      (context, offset) {
        context.pushLayer(
          shaderLayer,
          (context, offset) {
            paintShapeContents(context, offset, shapes, insideGlass: false);
          },
          offset,
        );
      },
      oldLayer: _clipRectLayerHandle.layer,
    );
  }

  /// Draws [shadows] under the glass.
  ///
  /// While the geometry changes from frame to frame (a jelly squash, a morph)
  /// they are drawn live. Once the same geometry image is painted a second
  /// time they are drawn once into an image and that image is drawn from
  /// then on: same pixels, but no saveLayer and no blur per frame.
  void _paintShadows(
    Canvas canvas,
    Offset offset,
    ui.Image geometry,
    Rect bounds,
  ) {
    final stable = identical(geometry, _lastShadowGeometry);
    _lastShadowGeometry = geometry;
    if (stable) {
      if (!identical(_bakedShadowGeometry, geometry) ||
          !listEquals(_bakedShadowList, shadows) ||
          _bakedShadowBounds != bounds ||
          _bakedShadowDpr != devicePixelRatio) {
        _bakeShadows(geometry, bounds);
      }
      if (_bakedShadow case final baked?) {
        canvas.drawImageRect(
          baked,
          Rect.fromLTWH(0, 0, baked.width.toDouble(), baked.height.toDouble()),
          _bakedShadowRect.shift(offset),
          Paint()..filterQuality = FilterQuality.low,
        );
        return;
      }
    }
    _drawShadows(canvas, bounds.shift(offset), geometry);
  }

  void _bakeShadows(ui.Image geometry, Rect bounds) {
    _bakedShadow?.dispose();
    _bakedShadow = null;
    _bakedShadowGeometry = geometry;
    _bakedShadowList = List.of(shadows);
    _bakedShadowBounds = bounds;
    _bakedShadowDpr = devicePixelRatio;

    Rect? area;
    for (final shadow in shadows) {
      if (shadow.color.a == 0) continue;
      final clip = _shadowClip(bounds, shadow);
      area = area == null ? clip : area.expandToInclude(clip);
    }
    if (area == null) return;
    final dpr = devicePixelRatio;
    final width = (area.width * dpr).ceil();
    final height = (area.height * dpr).ceil();
    if (width <= 0 || height <= 0) return;
    // Whole physical pixels, so the image is drawn back unscaled.
    final rect = Rect.fromLTWH(area.left, area.top, width / dpr, height / dpr);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(dpr)
      ..translate(-rect.left, -rect.top);
    _drawShadows(canvas, bounds, geometry);
    final picture = recorder.endRecording();
    _bakedShadow = picture.toImageSync(width, height);
    picture.dispose();
    _bakedShadowRect = rect;
  }

  /// Paints the shadows as a paint pass would, for tests: [geometry] stands
  /// in for the geometry matte and [bounds] for where it lies.
  @visibleForTesting
  void debugPaintShadows(
    Canvas canvas,
    Offset offset,
    ui.Image geometry,
    Rect bounds,
  ) =>
      _paintShadows(canvas, offset, geometry, bounds);

  /// The image the shadows are baked into, once the geometry held still.
  @visibleForTesting
  ui.Image? get debugBakedShadow => _bakedShadow;

  static Rect _shadowClip(Rect bounds, BoxShadow shadow) =>
      // Inflated so large blurs aren't cut off.
      bounds
          .shift(shadow.offset)
          .inflate(shadow.spreadRadius + shadow.blurRadius * 3);

  void _drawShadows(Canvas canvas, Rect bounds, ui.Image geometry) {
    final src = Rect.fromLTWH(
      0,
      0,
      geometry.width.toDouble(),
      geometry.height.toDouble(),
    );
    for (final shadow in shadows) {
      if (shadow.color.a == 0) continue;

      canvas.saveLayer(_shadowClip(bounds, shadow), Paint());

      // 1. Draw the geometry matte as a blurred, tinted shadow
      final shadowPaint = Paint()
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcIn)
        ..imageFilter = ImageFilter.blur(
          sigmaX: shadow.blurSigma,
          sigmaY: shadow.blurSigma,
          tileMode: TileMode.decal,
        );
      canvas.drawImageRect(
        geometry,
        src,
        bounds.shift(shadow.offset),
        shadowPaint,
      );

      // 2. GPU Cutout (dstOut): punch out the interior using the same geometry
      // matte to prevent the glass from blurring its own shadow (dirty rim).
      canvas.drawImageRect(
        geometry,
        src,
        bounds,
        Paint()..blendMode = BlendMode.dstOut,
      );

      canvas.restore();
    }
  }

  @override
  void dispose() {
    _bakedShadow?.dispose();
    _bakedShadow = null;
    _bakedShadowGeometry = null;
    _lastShadowGeometry = null;
    // Eagerly clear filter references on the backdrop layers before nulling
    // the handles. During isolate shutdown on Mali GPUs, GC finalization of
    // BackdropFilterLayer retains DlRuntimeEffectColorSource → TextureVK →
    // Vulkan mutex chains that outlive the GPU context (Crash 2). Clearing
    // the filter property breaks this retention chain immediately.
    _shaderHandle.layer?.filter = ImageFilter.blur(sigmaX: 0, sigmaY: 0);
    _blurLayerHandle.layer?.filter = ImageFilter.blur(sigmaX: 0, sigmaY: 0);
    _frostLayerHandle.layer?.filter = ImageFilter.blur(sigmaX: 0, sigmaY: 0);
    _weightLayerHandle.layer?.filter = ImageFilter.blur(sigmaX: 0, sigmaY: 0);
    _shaderHandle.layer = null;
    _blurLayerHandle.layer = null;
    _frostLayerHandle.layer = null;
    _weightLayerHandle.layer = null;
    _clipRectLayerHandle.layer = null;
    _clipPathLayerHandle.layer = null;
    _frostClipLayerHandle.layer = null;
    _frostRowsLayerHandle.layer = null;
    backdropPassClipRectLocal = null;
    super.dispose();
  }
}
