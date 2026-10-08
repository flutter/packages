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

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../renderer/glass_materialize_scope.dart';
import 'internal/transform_tracking_repaint_boundary_mixin.dart';
import 'liquid_glass_blend_group.dart';
import 'liquid_glass_layer.dart';
import 'liquid_glass_settings.dart';
import 'liquid_shape.dart';

/// A liquid glass shape.
///
/// To render liquid glass, you probably want to wrap this in a
/// [LiquidGlassLayer], where the glass effect will be rendered.
///
/// This can either create a single shape, or be blended together with other
/// shapes in a parent [LiquidGlassBlendGroup] by using the
/// [LiquidGlass.grouped] constructor.
///
/// If you only need a single shape with its own settings, you can also use the
/// [LiquidGlass.withOwnLayer] constructor, which will create its own
/// [LiquidGlassLayer] internally.
/// Be mindful that creating many individual layers can be expensive.
///
/// See the [LiquidGlassLayer] documentation for more information.
class LiquidGlass extends StatelessWidget {
  /// Creates a new [LiquidGlass] with the given [child] and [shape].
  ///
  /// This will expect a parent [LiquidGlassLayer] to be present in the widget
  /// tree, where the liquid glass effect will be rendered.
  const LiquidGlass({
    required this.child,
    required this.shape,
    this.glassContainsChild = false,
    this.clipBehavior = Clip.hardEdge,
    super.key,
  })  : grouped = false,
        blendGroupLink = null,
        clipExpansion = EdgeInsets.zero,
        shadows = const <BoxShadow>[],
        ownLayerConfig = null,
        _captureImage = null,
        _captureOriginInScreenSpace = Offset.zero;

  /// Creates a new [LiquidGlass] that is part of a [LiquidGlassBlendGroup].
  ///
  /// This will expect a parent [LiquidGlassBlendGroup] to be present in the
  /// widget tree, as well as a parent [LiquidGlassLayer] above that, where the
  /// result will be rendered.
  const LiquidGlass.grouped({
    required this.child,
    required this.shape,
    super.key,
    this.glassContainsChild = false,
    this.clipBehavior = Clip.hardEdge,
    this.blendGroupLink,
  })  : ownLayerConfig = null,
        clipExpansion = EdgeInsets.zero,
        shadows = const <BoxShadow>[],
        _captureImage = null,
        _captureOriginInScreenSpace = Offset.zero,
        grouped = true;

  /// Creates a new [LiquidGlass] that creates its own [LiquidGlassLayer].
  ///
  /// While this might seem convenient, creating many individual layers can be
  /// expensive.
  ///
  /// You should prefer rendering multiple [LiquidGlass] shapes that share the
  /// same settings inside a single [LiquidGlassLayer] for better performance.
  const LiquidGlass.withOwnLayer({
    required this.child,
    required this.shape,
    LiquidGlassSettings settings = const LiquidGlassSettings(),
    this.shadows = const <BoxShadow>[],
    super.key,
    this.glassContainsChild = false,
    this.clipBehavior = Clip.hardEdge,
    this.blendGroupLink,
    this.clipExpansion = EdgeInsets.zero,
    ui.Image? captureImage,
    Offset captureOriginInScreenSpace = Offset.zero,
  })  : ownLayerConfig = settings,
        _captureImage = captureImage,
        _captureOriginInScreenSpace = captureOriginInScreenSpace,
        grouped = false;

  /// The child of this widget.
  ///
  /// You can choose whether this should be rendered "inside" of the glass, or
  /// on top using [glassContainsChild].
  final Widget child;

  /// {@template liquid_glass_renderer.LiquidGlass.shape}
  /// The shape of this glass.
  ///
  /// This is the shape of the glass that will be rendered.
  /// {@endtemplate}
  final LiquidShape shape;

  /// Whether this glass should be rendered "inside" of the glass, or on top.
  ///
  /// If it is rendered inside, the color tint
  /// of the glass will affect the child, and it will also be refracted.
  ///
  /// Defaults to `false`.
  final bool glassContainsChild;

  /// The clip behavior of this glass.
  ///
  /// Defaults to [Clip.none], so [child] will not be clipped.
  final Clip clipBehavior;

  /// Whether this glass is part of a blend group.
  final bool grouped;

  /// The link to this glass's blend group if it is part of one.
  final GlassGroupLink? blendGroupLink;

  /// The settings for this glass if it is supposed to create its own layer.
  final LiquidGlassSettings? ownLayerConfig;

  /// The shadow to pass to the created layer (only applies for withOwnLayer).
  final List<BoxShadow> shadows;

  /// Extra clip expansion forwarded to [LiquidGlassLayer.clipExpansion].
  ///
  /// Only meaningful when using [LiquidGlass.withOwnLayer]. Has no effect on
  /// the grouped or default constructors.
  final EdgeInsets clipExpansion;

  // Capture-path fields — only set by LiquidGlass.withOwnLayer.
  // When non-null, LiquidGlassLayer bypasses its BackdropFilterLayer and
  // feeds this image directly to the shader as uBackgroundTexture.
  final ui.Image? _captureImage;
  final Offset _captureOriginInScreenSpace;

  @override
  Widget build(BuildContext context) {
    // If we have our own layer config, we create our own layer.
    if (ownLayerConfig case final settings?) {
      return LiquidGlassLayer(
        settings: settings,
        shadows: shadows,
        clipExpansion: clipExpansion,
        captureImage: _captureImage,
        captureOriginInScreenSpace: _captureOriginInScreenSpace,
        child: LiquidGlassBlendGroup(
          blend: 0,
          child: Builder(
            builder: _buildContent,
          ),
        ),
      );
    }

    final blendGroupLink = grouped
        ? this.blendGroupLink ?? LiquidGlassBlendGroup.maybeOf(context)
        : null;

    if (blendGroupLink == null) {
      // For now we create our own blend group until we support non-blended
      // geometry generation
      return LiquidGlassBlendGroup(
        blend: 0,
        child: Builder(
          builder: (context) => _buildContent(
            context,
            LiquidGlassBlendGroup.of(context),
          ),
        ),
      );
    }

    return _buildContent(
      context,
      blendGroupLink,
    );
  }

  Widget _buildContent(BuildContext context, [GlassGroupLink? blendGroupLink]) {
    final settings = LiquidGlassSettings.of(context);

    if (!ImageFilter.isShaderFilterSupported) {
      // No Impeller — render child without glass effect.
      // Use AdaptiveLiquidGlassLayer / LightweightLiquidGlass for non-Impeller.
      return child;
    }

    return _RawLiquidGlass(
      blendGroupLink: blendGroupLink ?? LiquidGlassBlendGroup.of(context),
      shape: shape,
      glassContainsChild: glassContainsChild,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        clipBehavior: clipBehavior,
        // [LOCAL PATCH]: the materialize content channel — a lagged fade and
        // gaussian blur so the icon sharpens after the glass has resolved.
        // The visibility Opacity below it already tracks the glass channel,
        // because `settings` comes from the (possibly transformed) scope.
        child: GlassMaterializeScope.wrapContent(
          context,
          Opacity(
            opacity: settings.visibility.clamp(0, 1),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RawLiquidGlass extends SingleChildRenderObjectWidget {
  const _RawLiquidGlass({
    required super.child,
    required this.shape,
    required this.glassContainsChild,
    required this.blendGroupLink,
  });

  final LiquidShape shape;

  final bool glassContainsChild;

  final GlassGroupLink? blendGroupLink;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLiquidGlass(
      shape: shape,
      glassContainsChild: glassContainsChild,
      blendGroupLink: blendGroupLink,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLiquidGlass renderObject,
  ) {
    renderObject
      ..shape = shape
      ..glassContainsChild = glassContainsChild
      ..blendGroupLink = blendGroupLink;
  }
}

class RenderLiquidGlass extends RenderProxyBox
    with TransformTrackingRenderObjectMixin {
  RenderLiquidGlass({
    required LiquidShape shape,
    required bool glassContainsChild,
    required GlassGroupLink? blendGroupLink,
  })  : _shape = shape,
        _glassContainsChild = glassContainsChild,
        _blendGroupLink = blendGroupLink;

  late LiquidShape _shape;
  LiquidShape get shape => _shape;
  set shape(LiquidShape value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
    _updateBlendGroupLink();
  }

  bool _glassContainsChild = true;
  bool get glassContainsChild => _glassContainsChild;
  set glassContainsChild(bool value) {
    if (_glassContainsChild == value) return;
    _glassContainsChild = value;
    _updateBlendGroupLink();
  }

  GlassGroupLink? _blendGroupLink;
  set blendGroupLink(GlassGroupLink? value) {
    if (_blendGroupLink == value) return;
    _unregisterFromParentLayer();
    _blendGroupLink = value;
    _registerWithLink();
  }

  final transformLayerHandle = LayerHandle<TransformLayer>();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _registerWithLink();
  }

  @override
  void detach() {
    _unregisterFromParentLayer();
    transformLayerHandle.layer = null;
    super.detach();
  }

  void _registerWithLink() {
    if (_blendGroupLink != null) {
      _blendGroupLink!.registerShape(
        this,
        _shape,
        glassContainsChild: _glassContainsChild,
      );
    }
  }

  void _unregisterFromParentLayer() {
    _blendGroupLink?.unregisterShape(this);
  }

  void _updateBlendGroupLink() {
    _blendGroupLink?.updateShape(
      this,
      _shape,
      glassContainsChild: _glassContainsChild,
    );
  }

  late Path _lastPath;

  @override
  void performLayout() {
    super.performLayout();
    // Notify parent layer when our layout changes
    _lastPath = shape.getOuterPath(Offset.zero & size);
    _blendGroupLink?.notifyShapeLayoutChanged(this);
  }

  @override
  void onTransformChanged() {
    _blendGroupLink?.notifyShapeTransformChanged(this);
  }

  @override
  // ignore: must_call_super
  void paint(PaintingContext context, Offset offset) {
    setUpLayer(offset);
    // Push the tracking layer during the normal paint traversal.
    // We pass an empty painter because the child is NOT drawn here;
    // it is drawn by the blend group via paintFromLayer.
    // Pushing the layer ensures it is added to the scene, which
    // allows onTransformChanged to fire when the user scrolls.
    context.pushLayer(layer!, (context, offset) {}, offset);
  }

  void paintFromLayer(
    PaintingContext context,
    Matrix4 transform,
    Offset offset,
  ) {
    if (attached) {
      transformLayerHandle.layer = context.pushTransform(
        needsCompositing,
        offset,
        transform,
        super.paint,
        oldLayer: transformLayerHandle.layer,
      );
    }
  }

  Path getPath() {
    return _lastPath;
  }
}
