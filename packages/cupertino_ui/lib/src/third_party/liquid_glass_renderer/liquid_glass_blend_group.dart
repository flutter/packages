// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/widgets.dart';
import '../renderer/fragment_shader_extensions.dart';
import 'internal/transform_tracking_repaint_boundary_mixin.dart';
import 'liquid_glass.dart';
import 'liquid_glass_render_scope.dart';
import 'liquid_glass_settings.dart';
import 'liquid_shape.dart';
import 'multi_shader_builder.dart';
import 'render_liquid_glass_geometry.dart';
import 'rendering/liquid_glass_render_object.dart';
import 'shaders.dart';

/// A widget that groups multiple liquid glass shapes for blending.
///
/// Any [LiquidGlass.grouped] widgets inside this group will blend together.
///
/// This widget will expect a parent [LiquidGlassLayer] to render the liquid
/// glass effect on.
class LiquidGlassBlendGroup extends StatefulWidget {
  /// Creates a new [LiquidGlassBlendGroup].
  const LiquidGlassBlendGroup({
    required this.child,
    this.blend = 20.0,
    super.key,
  });

  /// The amount of blending between shapes in this group.
  ///
  /// Roughly corresponds to distance of logical pixels at which shapes start to
  /// blend.
  final double blend;

  /// The child widget containing liquid glass shapes.
  final Widget child;

  /// Maximum number of shapes supported per layer.
  static const int maxShapesPerLayer = 16;

  /// Retrieves the [GlassGroupLink] from the nearest ancestor
  /// [LiquidGlassBlendGroup].
  ///
  /// Can be used by child shapes to register themselves for blending.
  static GlassGroupLink of(BuildContext context) {
    final inherited = _InheritedLiquidGlassBlendGroup.of(context);
    assert(inherited != null, 'No LiquidGlassBlendGroup found in context');
    return inherited!.link;
  }

  /// Retrieves the [GlassGroupLink] from the nearest ancestor
  /// [LiquidGlassBlendGroup], or null if none is found.
  static GlassGroupLink? maybeOf(BuildContext context) {
    final inherited = _InheritedLiquidGlassBlendGroup.of(context);
    return inherited?.link;
  }

  @override
  State<LiquidGlassBlendGroup> createState() => _LiquidGlassBlendGroupState();
}

class _LiquidGlassBlendGroupState extends State<LiquidGlassBlendGroup> {
  late final GlassGroupLink _geometryLink = GlassGroupLink();

  @override
  void dispose() {
    _geometryLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On non-Impeller backends (Skia, web) the geometry shader cannot be
    // compiled.  Pass through to children so the widget tree still builds.
    if (!ImageFilter.isShaderFilterSupported) {
      return _InheritedLiquidGlassBlendGroup(
        link: _geometryLink,
        child: widget.child,
      );
    }

    return _InheritedLiquidGlassBlendGroup(
      link: _geometryLink,
      child: ShaderBuilder(
        (context, shader, child) {
          final renderLink = InheritedGeometryRenderLink.of(context);

          assert(
            renderLink != null,
            '\n'
            '[liquid_glass_widgets] LiquidGlassBlendGroup could not find an '
            'InheritedGeometryRenderLink in the widget tree.\n\n'
            'This happens when GlassQuality.premium is used outside of a '
            'LiquidGlassLayer (or AdaptiveLiquidGlassLayer).\n\n'
            'To fix this, either:\n'
            '  • Wrap the widget in a LiquidGlassLayer / AdaptiveLiquidGlassLayer, OR\n'
            '  • Set useOwnLayer: true on your GlassButton / AdaptiveGlass, which '
            'provisions its own layer automatically.\n\n'
            'Example:\n'
            '  GlassButton(\n'
            '    quality: GlassQuality.premium,\n'
            '    useOwnLayer: true, // ← add this\n'
            '    ...\n'
            '  )\n',
          );

          // In release builds, if no render link is available, fall back
          // gracefully by rendering the child without the glass blend effect
          // rather than crashing the app.
          if (renderLink == null) return child!;

          return _RawLiquidGlassBlendGroup(
            blend: widget.blend,
            shader: shader,
            link: _geometryLink,
            renderLink: renderLink,
            settings: LiquidGlassRenderScope.of(context).settings,
            child: child,
          );
        },
        assetKey: ShaderKeys.blendedGeometry,
        child: widget.child,
      ),
    );
  }
}

class _InheritedLiquidGlassBlendGroup extends InheritedWidget {
  const _InheritedLiquidGlassBlendGroup({
    required this.link,
    required super.child,
  });

  final GlassGroupLink link;

  static _InheritedLiquidGlassBlendGroup? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedLiquidGlassBlendGroup>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget is! _InheritedLiquidGlassBlendGroup ||
        oldWidget.link != link;
  }
}

class _RawLiquidGlassBlendGroup extends SingleChildRenderObjectWidget {
  const _RawLiquidGlassBlendGroup({
    required this.blend,
    required this.shader,
    required this.renderLink,
    required this.link,
    required this.settings,
    super.child,
  });

  final double blend;
  final FragmentShader shader;
  final GeometryRenderLink renderLink;
  final GlassGroupLink link;
  final LiquidGlassSettings settings;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLiquidGlassBlendGroup(
      renderLink: renderLink,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      geometryShader: shader,
      settings: settings,
      link: link,
      blend: blend,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLiquidGlassBlendGroup renderObject,
  ) {
    renderObject
      ..blend = blend
      ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context)
      ..settings = settings
      ..link = link;
  }
}

@visibleForTesting
class RenderLiquidGlassBlendGroup extends RenderLiquidGlassGeometry
    with TransformTrackingRenderObjectMixin {
  RenderLiquidGlassBlendGroup({
    required super.renderLink,
    required super.devicePixelRatio,
    required super.geometryShader,
    required super.settings,
    required GlassGroupLink link,
    required double blend,
  })  : _link = link,
        _blend = blend {
    link.addListener(_onLinkUpdate);
    link.onShapeTransformChanged = _onShapeTransformChanged;
  }

  GlassGroupLink _link;

  /// The link that provides shape information to this geometry.
  GlassGroupLink get link => _link;

  set link(GlassGroupLink value) {
    if (_link == value) return;
    _link.removeListener(_onLinkUpdate);
    _link.onShapeTransformChanged = null;
    _link = value;
    value.addListener(_onLinkUpdate);
    value.onShapeTransformChanged = _onShapeTransformChanged;
    markNeedsPaint();
  }

  double _blend = 0;
  double get blend => _blend;
  set blend(double value) {
    if (_blend == value) return;
    _blend = value;
    updateShaderWithSettings(settings, devicePixelRatio);
    markGeometryNeedsUpdate(force: true);
    markNeedsPaint();
  }

  void _onLinkUpdate() {
    markGeometryNeedsUpdate();
    markNeedsPaint();
  }

  void _onShapeTransformChanged(RenderObject renderObject) {
    markGeometryNeedsUpdate();
    markNeedsPaint();
  }

  @override
  void onTransformChanged() {
    markNeedsPaint();
    renderLink?.notifyTransformChanged(this);
  }

  @override
  void updateShaderWithSettings(
    LiquidGlassSettings settings,
    double devicePixelRatio,
  ) {
    // The baseline visual thickness was tuned on a 3x Retina display.
    // To maintain this exact logical thickness on all screens, we multiply by (DPR / 3.0).
    // This scales the physical rim width so it always occupies the same logical space.
    final scale = devicePixelRatio / 3.0;

    geometryShader.setFloatUniforms(initialIndex: 2, (value) {
      value.setFloats([
        settings.effectiveRefractiveIndex,
        settings.effectiveChromaticAberration,
        settings.effectiveThickness * scale,
        blend * devicePixelRatio,
      ]);
    });
    // uNativeEdge, after the shape array.
    geometryShader.setFloatUniforms(
      initialIndex: 8 + LiquidGlassBlendGroup.maxShapesPerLayer * 7,
      (value) => value.setFloat(
        settings.rimShade > 0 || settings.frost > 0 ? 1.0 : 0.0,
      ),
    );
  }

  @override
  void updateGeometryShaderShapes(
    List<ShapeGeometry> shapes,
  ) {
    if (shapes.length > LiquidGlassBlendGroup.maxShapesPerLayer) {
      throw UnsupportedError(
        'Only ${LiquidGlassBlendGroup.maxShapesPerLayer} shapes are supported '
        'at the moment!',
      );
    }

    geometryShader.setFloatUniforms(initialIndex: 6, (value) {
      value.setFloat(shapes.length.toDouble());
      value.setFloat(devicePixelRatio);
      for (final shape in shapes) {
        final center = shape.shapeBounds.center;
        final size = shape.shapeBounds.size;
        // 7-float per-shape stride: type, center.xy, size.xy, top corner
        // radius, bottom corner radius. For symmetric shapes top == bottom
        // so the shader's `sdfRRectAsym` collapses to plain `sdfRRect`
        // (mathematical identity, no behavior change). See sdf.glsl's
        // shape-slot layout comment.
        value
          ..setFloat(shape.rawShapeType.shaderIndex)
          ..setFloat(center.dx * devicePixelRatio)
          ..setFloat(center.dy * devicePixelRatio)
          ..setFloat(size.width * devicePixelRatio)
          ..setFloat(size.height * devicePixelRatio)
          ..setFloat(shape.rawCornerRadius * devicePixelRatio)
          ..setFloat(shape.rawBottomCornerRadius * devicePixelRatio);
      }
    });
  }

  @override
  (Rect, List<ShapeGeometry>, bool) gatherShapeData() {
    final shapes = <ShapeGeometry>[];
    final cachedShapes = geometry?.shapes ?? [];

    var anyShapeChangedInLayer =
        cachedShapes.length != link.shapeEntries.length;

    Rect? layerBounds;

    for (final (
          index,
          MapEntry(
            key: renderObject,
            value: (shape, glassContainsChild),
          )
        ) in link.shapeEntries.indexed) {
      if (!renderObject.attached || !renderObject.hasSize) continue;

      try {
        final shapeData = _computeShapeInfo(
          renderObject,
          shape,
          glassContainsChild,
        );
        shapes.add(shapeData);

        layerBounds = layerBounds?.expandToInclude(shapeData.shapeBounds) ??
            shapeData.shapeBounds;

        final existingShape =
            cachedShapes.length > index ? cachedShapes[index] : null;

        if (existingShape == null) {
          anyShapeChangedInLayer = true;
        } else if (existingShape.shapeBounds != shapeData.shapeBounds ||
            existingShape.shape != shapeData.shape) {
          anyShapeChangedInLayer = true;
        }
      } catch (e) {
        debugPrint('Failed to compute shape info: $e');
      }
    }

    return (
      // With a rim outline or a frost the geometry pass draws the glass a
      // physical pixel larger than the shape (uNativeEdge in
      // liquid_glass_geometry_blended.frag): room for that plus a
      // transparent border, since the matte's edge texels are what the
      // shadow blurs and what the render pass clamps to outside the matte.
      (layerBounds ?? Rect.zero).inflate(
        blend * .25 +
            (settings.rimShade > 0 || settings.frost > 0
                ? 3 / devicePixelRatio
                : 0),
      ),
      shapes,
      anyShapeChangedInLayer,
    );
  }

  @override
  void paintShapeContents(
    RenderObject from,
    PaintingContext context,
    Offset offset, {
    required bool insideGlass,
  }) {
    for (final shapeEntry in link.shapeEntries) {
      final renderObject = shapeEntry.key;
      if (!renderObject.attached ||
          renderObject.glassContainsChild != insideGlass) {
        continue;
      }

      // Fetch the true live paint transform. Since paint-only animations
      // (LiquidStretch, scale) bypass SDF geometry rebuilds, we must NOT use
      // transforming caches derived from the old layout geometry.
      final transform = renderObject.getTransformTo(from);

      renderObject.paintFromLayer(context, transform, offset);
    }
  }

  ShapeGeometry _computeShapeInfo(
    RenderLiquidGlass renderObject,
    LiquidShape shape,
    bool glassContainsChild,
  ) {
    if (!hasSize) {
      throw StateError(
        'Cannot compute shape info for $renderObject because '
        '$this LiquidGlassGeometry has no size yet.',
      );
    }

    if (!renderObject.hasSize) {
      throw StateError(
        'Cannot compute shape info for LiquidGlass $renderObject because it '
        'has no size yet.',
      );
    }

    // We remember the shapes transform to this blend group.
    final transformToGeometry = renderObject.getTransformTo(this);

    final blendGroupRect = MatrixUtils.transformRect(
      transformToGeometry,
      Offset.zero & renderObject.size,
    );

    return ShapeGeometry(
      renderObject: renderObject,
      shape: shape,
      glassContainsChild: glassContainsChild,
      shapeBounds: blendGroupRect,
      shapeToGeometry: transformToGeometry,
    );
  }
}

/// A link that connects liquid glass shapes to their parent
/// [LiquidGlassBlendGroup] for efficient communication of position, size, and
/// transform changes.
class GlassGroupLink with ChangeNotifier {
  /// Creates a new [GlassGroupLink].
  GlassGroupLink();

  /// Information about a shape registered with this link.
  final Map<RenderLiquidGlass, (LiquidShape shape, bool glassContainsChild)>
      _shapes = {};

  /// Shape entries as an iterable — returned directly from the underlying Map
  /// without allocating a new List. All call sites only need to iterate, never
  /// index, so Iterable is sufficient and avoids 2–3 heap allocations per frame.
  Iterable<
      MapEntry<RenderLiquidGlass,
          (LiquidShape shape, bool glassContainsChild)>> get shapeEntries =>
      _shapes.entries;

  /// Check if any shapes are registered.
  bool get hasShapes => _shapes.isNotEmpty;

  /// Register a shape with this link.
  void registerShape(
    RenderLiquidGlass renderObject,
    LiquidShape shape, {
    required bool glassContainsChild,
  }) {
    _shapes[renderObject] = (shape, glassContainsChild);
    notifyListeners();
  }

  /// Unregister a shape from this link.
  void unregisterShape(RenderLiquidGlass renderObject) {
    _shapes.remove(renderObject);
    notifyListeners();
  }

  /// Update the shape properties for a registered render object.
  void updateShape(
    RenderLiquidGlass renderObject,
    LiquidShape shape, {
    required bool glassContainsChild,
  }) {
    _shapes[renderObject] = (shape, glassContainsChild);
    notifyListeners();
  }

  /// Notify that a shape's layout has changed.
  void notifyShapeLayoutChanged(RenderObject renderObject) {
    if (_shapes.containsKey(renderObject)) {
      notifyListeners();
    }
  }

  /// Called when a shape's transform changes, requesting a repaint without a geometry rebuild.
  void Function(RenderObject)? onShapeTransformChanged;

  /// Notify that a shape's transform has changed.
  void notifyShapeTransformChanged(RenderObject renderObject) {
    if (_shapes.containsKey(renderObject)) {
      onShapeTransformChanged?.call(renderObject);
    }
  }

  @override
  void dispose() {
    _shapes.clear();
    super.dispose();
  }
}
