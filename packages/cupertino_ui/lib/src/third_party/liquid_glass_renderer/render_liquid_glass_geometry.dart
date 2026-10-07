// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:ui';
import 'package:flutter/foundation.dart';

import 'package:flutter/rendering.dart';
import '../../constants/glass_defaults.dart';
import '../renderer/fragment_shader_extensions.dart';
import 'liquid_glass.dart';
import 'liquid_glass_blend_group.dart';
import 'liquid_glass_settings.dart';
import 'liquid_shape.dart';
import 'rendering/liquid_glass_render_object.dart';
import 'snap_rect_to_pixels.dart';

/// The state of liquid glass geometry, used to determine if it needs to be
/// updated.
enum LiquidGlassGeometryState {
  /// The geometry is up to date and does not need to be updated.
  updated,

  /// The geometry might need to be updated, but could potentially be reused.
  ///
  /// This happens mainly when all of the geometry itself is unchanged, but all
  /// of the geometry has been uniformly transformed.
  ///
  /// In this case, we can use the existing geometry matte and transform it to
  /// save GPU cycles.
  mightNeedUpdate,

  /// The geometry definitely needs to be updated.
  needsUpdate,
}

/// A base class for any render object that represents liquid glass geometry.
///
/// This will paint to the screen normally, but use a [GlassGroupLink] to gather
/// shape information and generate a geometry matte using the provided
/// [geometryShader].
abstract class RenderLiquidGlassGeometry extends RenderProxyBox {
  /// Creates a new [RenderLiquidGlassGeometry] with the given
  /// [geometryShader].
  RenderLiquidGlassGeometry({
    required GeometryRenderLink renderLink,
    required this.geometryShader,
    required LiquidGlassSettings settings,
    required double devicePixelRatio,
  })  : _renderLink = renderLink,
        _settings = settings,
        _devicePixelRatio = devicePixelRatio {
    updateShaderWithSettings(settings, devicePixelRatio);
  }

  /// The shader that generates the geometry matte.
  final FragmentShader geometryShader;

  LiquidGlassSettings? _settings;

  /// The settings used for liquid glass rendering.
  ///
  /// If these settings change in a way that affects geometry, the geometry
  /// will be marked as needing an update.
  LiquidGlassSettings get settings => _settings!;
  set settings(LiquidGlassSettings value) {
    if (_settings == value) return;

    if (value.requiresGeometryRebuild(_settings)) {
      markGeometryNeedsUpdate(force: true);
    }

    _settings = value;
    updateShaderWithSettings(value, _devicePixelRatio);
    markNeedsPaint();
  }

  double _devicePixelRatio;

  /// The device pixel ratio used for rendering.
  ///
  /// If this changes, the geometry will be marked as needing an update.
  double get devicePixelRatio => _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markGeometryNeedsUpdate(force: true);
    updateShaderWithSettings(settings, value);
    markNeedsPaint();
  }

  GeometryRenderLink? _renderLink;
  GeometryRenderLink? get renderLink => _renderLink;
  set renderLink(GeometryRenderLink? value) {
    if (_renderLink == value) return;
    _renderLink?.unregisterGeometry(this);
    _renderLink = value;
    _renderLink?.registerGeometry(this);
  }

  /// The current state of the geometry.
  @visibleForTesting
  @protected
  LiquidGlassGeometryState geometryState = LiquidGlassGeometryState.needsUpdate;

  /// The current geometry matte image.
  @visibleForTesting
  @protected
  GeometryCache? geometry;

  /// Marks the geometry as needing an update.
  ///
  /// If [force] is true, the geometry will be marked as definitely needing an
  /// update. Otherwise, it will be marked as possibly needing an update,
  /// unless it is already marked as definitely needing an update.
  @protected
  void markGeometryNeedsUpdate({bool force = false}) {
    final newState = force
        ? LiquidGlassGeometryState.needsUpdate
        : LiquidGlassGeometryState.mightNeedUpdate;

    geometryState = switch ((geometryState, newState)) {
      (LiquidGlassGeometryState.needsUpdate, _) =>
        LiquidGlassGeometryState.needsUpdate,
      (_, LiquidGlassGeometryState.needsUpdate) =>
        LiquidGlassGeometryState.needsUpdate,
      _ => LiquidGlassGeometryState.mightNeedUpdate,
    };
  }

  @override
  @mustCallSuper
  void attach(PipelineOwner owner) {
    _renderLink?.registerGeometry(this);
    super.attach(owner);
  }

  @override
  @mustCallSuper
  void detach() {
    _renderLink?.unregisterGeometry(this);
    super.detach();
  }

  @override
  @mustCallSuper
  void dispose() {
    _renderLink?.unregisterGeometry(this);
    geometry?.dispose();
    geometry = null;
    super.dispose();
  }

  /// Updates the shader with the current settings and device pixel ratio.
  void updateShaderWithSettings(
    LiquidGlassSettings settings,
    double devicePixelRatio,
  );

  /// Uploads shape data to geometry shader in screen space coordinates
  void updateGeometryShaderShapes(
    List<ShapeGeometry> shapes,
  );

  /// Paints the contents of all shapes to the given [context] at the given
  /// [offset].
  void paintShapeContents(
    RenderObject from,
    PaintingContext context,
    Offset offset, {
    required bool insideGlass,
  });

  /// Gathers all shapes and computes them in both layer and screen space
  /// Returns (layerBounds, shapes, anyShapeChangedInLayer)
  (
    Rect bounds,
    List<ShapeGeometry> geometries,
    bool needsUpdate,
  ) gatherShapeData();

  Path getPath(
    List<ShapeGeometry> geometries,
  ) {
    final path = Path();
    for (final shape in geometries) {
      path.addPath(
        shape.renderObject.getPath(),
        Offset.zero,
        matrix4: shape.shapeToGeometry?.storage,
      );
    }
    return path;
  }

  /// Should be called from within [paint] to maybe rebuild the [geometry].
  GeometryCache? maybeRebuildGeometry() {
    if (geometryState == LiquidGlassGeometryState.updated && geometry != null) {
      return geometry;
    }

    final (layerBounds, shapes, anyShapeChangedInLayer) = gatherShapeData();

    if (geometryState == LiquidGlassGeometryState.mightNeedUpdate &&
        !anyShapeChangedInLayer &&
        geometry != null) {
      renderLink?.notifyGeometryChanged(this);

      // Only render once we are done building
      geometry = geometry!.render();
      geometryState = LiquidGlassGeometryState.updated;
      return geometry;
    }

    geometry?.dispose();
    geometry = null;
    geometryState = LiquidGlassGeometryState.updated;

    if (shapes.isEmpty) {
      return null;
    }

    final snappedBounds = layerBounds.snapToPixels(devicePixelRatio);
    final matteBounds = Rect.fromLTWH(
      snappedBounds.left * devicePixelRatio,
      snappedBounds.top * devicePixelRatio,
      snappedBounds.width * devicePixelRatio,
      snappedBounds.height * devicePixelRatio,
    ).snapToPixels(1);

    // Set the new geometry
    final newGeo = geometry = UnrenderedGeometryCache(
      matte: _buildGeometryPicture(snappedBounds, shapes),
      bounds: snappedBounds,
      matteBounds: matteBounds,
      shapes: shapes,
      path: getPath(shapes),
    );

    // We have updated the geometry.
    _renderLink?.notifyGeometryChanged(this);
    return newGeo;
  }

  Picture _buildGeometryPicture(
    Rect geometryBounds,
    List<ShapeGeometry> shapes,
  ) {
    final bounds = geometryBounds.snapToPixels(devicePixelRatio);

    if (bounds.isEmpty || !bounds.isFinite) {
      final recorder = PictureRecorder();
      Canvas(recorder); // Recorder must be started by a Canvas
      return recorder.endRecording();
    }

    final width = (bounds.width * devicePixelRatio).ceil();
    final height = (bounds.height * devicePixelRatio).ceil();

    geometryShader.setFloatUniforms((value) {
      value
        ..setFloat(width.toDouble())
        ..setFloat(height.toDouble());
    });

    updateGeometryShaderShapes(shapes);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..shader = geometryShader;

    final leftPixel = (geometryBounds.left * devicePixelRatio).roundToDouble();
    final topPixel = (geometryBounds.top * devicePixelRatio).roundToDouble();

    canvas
      // This translation might seem redundant, but we do it to ensure pixel
      // snapping
      ..translate(-leftPixel, -topPixel)
      ..drawRect(
        Rect.fromLTWH(
          leftPixel,
          topPixel,
          width.toDouble(),
          height.toDouble(),
        ),
        paint,
      );

    return recorder.endRecording();
  }
}

@immutable
sealed class GeometryCache {
  const GeometryCache({
    required this.matteBounds,
    required this.bounds,
    required this.shapes,
    required this.path,
  });

  /// The bounds of the geometry in the coordinate space of its
  /// [RenderLiquidGlassGeometry] parent.
  final Rect bounds;

  /// The bounds of the matte image in physical pixels.
  final Rect matteBounds;

  final List<ShapeGeometry> shapes;

  final Path path;

  /// Ensure that this geometry is rendered and potentially dispose this
  /// instance.
  ///
  /// Using this object isn't safe after calling this method.
  /// Make sure to only use the returned object after calling this.
  ///
  /// If this is a [UnrenderedGeometryCache], this will produce a
  /// [RenderedGeometryCache].
  ///
  /// If this is already rendered, it will return itself.
  RenderedGeometryCache render();

  Future<RenderedGeometryCache> renderAsync();

  void dispose();
}

/// Represents a current snapshot of the geometry used for liquid glass
/// rendering.
@immutable
class UnrenderedGeometryCache extends GeometryCache {
  const UnrenderedGeometryCache({
    required this.matte,
    required super.matteBounds,
    required super.bounds,
    required super.shapes,
    required super.path,
  });

  /// The matte image representing the geometry.
  final Picture matte;

  @override
  Future<RenderedGeometryCache> renderAsync() async {
    final width = matteBounds.width.ceil();
    final height = matteBounds.height.ceil();
    // Guard: zero/negative dimensions can corrupt Mali GPU driver state during
    // rapid layout changes (jelly animations, modal expansion). Return a
    // minimal 1×1 cache rather than handing the GPU an invalid texture request.
    if (width < 1 || height < 1) {
      final recorder = PictureRecorder();
      Canvas(recorder);
      final fallback = recorder.endRecording();
      final image = fallback.toImageSync(1, 1);
      fallback.dispose();
      return RenderedGeometryCache(
        matte: image,
        matteBounds: const Rect.fromLTWH(0, 0, 1, 1),
        bounds: bounds,
        shapes: shapes,
        path: path,
      );
    }
    final image = await matte.toImage(width, height);
    return RenderedGeometryCache(
      matte: image,
      matteBounds: matteBounds,
      bounds: bounds,
      shapes: shapes,
      path: path,
    );
  }

  @override
  RenderedGeometryCache render() {
    final width = matteBounds.width.ceil();
    final height = matteBounds.height.ceil();
    // Guard: zero/negative dimensions during jelly squash or rapid layout
    // transitions can produce invalid GPU texture requests on Mali GPUs.
    if (width < 1 || height < 1) {
      dispose();
      final recorder = PictureRecorder();
      Canvas(recorder);
      final fallback = recorder.endRecording();
      final image = fallback.toImageSync(1, 1);
      fallback.dispose();
      return RenderedGeometryCache(
        matte: image,
        matteBounds: const Rect.fromLTWH(0, 0, 1, 1),
        bounds: bounds,
        shapes: shapes,
        path: path,
      );
    }
    try {
      final image = matte.toImageSync(width, height);
      dispose();
      return RenderedGeometryCache(
        matte: image,
        matteBounds: matteBounds,
        bounds: bounds,
        shapes: shapes,
        path: path,
      );
    } catch (_) {
      // Mali GPU driver failure during toImageSync — return a safe 1×1 fallback
      // rather than crashing the entire app. The next paint frame will rebuild
      // the geometry with valid dimensions.
      dispose();
      final recorder = PictureRecorder();
      Canvas(recorder);
      final fallback = recorder.endRecording();
      final image = fallback.toImageSync(1, 1);
      fallback.dispose();
      return RenderedGeometryCache(
        matte: image,
        matteBounds: const Rect.fromLTWH(0, 0, 1, 1),
        bounds: bounds,
        shapes: shapes,
        path: path,
      );
    }
  }

  /// Disposes of the resources used by the geometry.
  @override
  void dispose() {
    matte.dispose();
  }
}

/// Represents a current snapshot of the geometry used for liquid glass
/// rendering.
@immutable
class RenderedGeometryCache extends GeometryCache {
  const RenderedGeometryCache({
    required this.matte,
    required super.matteBounds,
    required super.bounds,
    required super.shapes,
    required super.path,
  });

  /// The matte image representing the geometry.
  final Image matte;

  @override
  RenderedGeometryCache render() => this;

  @override
  Future<RenderedGeometryCache> renderAsync() => Future.value(this);

  /// Disposes of the resources used by the geometry.
  @override
  void dispose() {
    matte.dispose();
  }
}

extension on LiquidGlassSettings {
  bool requiresGeometryRebuild(LiquidGlassSettings? other) {
    if (other == null) return false;

    // blend is intentionally excluded here — it is set directly on
    // RenderLiquidGlassBlendGroup and triggers a forced geometry rebuild via
    // its own setter. If blend is ever pulled into LiquidGlassSettings, add it
    // to this check at that point.
    return effectiveThickness != other.effectiveThickness ||
        refractiveIndex != other.refractiveIndex ||
        // A rim outline or a frost switches the matte's edge (uNativeEdge).
        (rimShade > 0 || frost > 0) != (other.rimShade > 0 || other.frost > 0);
  }
}

enum RawShapeType {
  // none(0), unused in CPU code
  squircle(1),
  ellipse(2),
  roundedRectangle(3);

  const RawShapeType(this.shaderIndex);

  final double shaderIndex;

  static RawShapeType fromLiquidGlassShape(LiquidShape shape) {
    switch (shape) {
      case LiquidRoundedSuperellipse():
        return RawShapeType.squircle;
      case LiquidOval():
        return RawShapeType.ellipse;
      case LiquidRoundedRectangle():
        return RawShapeType.roundedRectangle;
      case LiquidVerticalRoundedRectangle():
        return RawShapeType.roundedRectangle;
      case LiquidVerticalRoundedSuperellipse():
        return RawShapeType.squircle;
    }
  }
}

/// The geometry of a single shape.
///
/// Can be part of multiple blended shapes in [RenderLiquidGlassGeometry], or on
/// its own.
class ShapeGeometry {
  ShapeGeometry({
    required this.renderObject,
    required this.shape,
    required this.glassContainsChild,
    required this.shapeBounds,
    this.shapeToGeometry,
  })  : rawCornerRadius = _getRadiusFromGlassShape(shape),
        rawBottomCornerRadius = _getBottomRadiusFromGlassShape(shape),
        rawShapeType = RawShapeType.fromLiquidGlassShape(shape);

  static double _getRadiusFromGlassShape(LiquidShape shape) {
    switch (shape) {
      case LiquidRoundedSuperellipse():
        return GlassDefaults.safeRadius(shape.borderRadius);
      case LiquidRoundedRectangle():
        return GlassDefaults.safeRadius(shape.borderRadius);
      case LiquidVerticalRoundedRectangle():
        return GlassDefaults.safeRadius(shape.topRadius);
      case LiquidOval():
        return 0;
      case LiquidVerticalRoundedSuperellipse():
        return GlassDefaults.safeRadius(shape.topRadius);
    }
  }

  /// Bottom corner radius. For symmetric shapes this returns the same value
  /// as [_getRadiusFromGlassShape]; for vertically-asymmetric shapes
  /// ([LiquidVerticalRoundedSuperellipse], [LiquidVerticalRoundedRectangle])
  /// it returns the distinct bottom radius. Consumed by the geometry shader
  /// via the per-shape `[base+6]` slot so the SDF can paint different top vs.
  /// bottom corners (e.g. iOS modal sheets whose bottom curves track the
  /// device chassis radius).
  static double _getBottomRadiusFromGlassShape(LiquidShape shape) {
    switch (shape) {
      case LiquidRoundedSuperellipse():
        return GlassDefaults.safeRadius(shape.borderRadius);
      case LiquidRoundedRectangle():
        return GlassDefaults.safeRadius(shape.borderRadius);
      case LiquidVerticalRoundedRectangle():
        return GlassDefaults.safeRadius(shape.bottomRadius);
      case LiquidOval():
        return 0;
      case LiquidVerticalRoundedSuperellipse():
        return GlassDefaults.safeRadius(shape.bottomRadius);
    }
  }

  final RenderLiquidGlass renderObject;

  final LiquidShape shape;

  final RawShapeType rawShapeType;

  final double rawCornerRadius;

  /// Bottom corner radius — equal to [rawCornerRadius] for symmetric shapes,
  /// distinct for vertically-asymmetric shapes. See
  /// [_getBottomRadiusFromGlassShape].
  final double rawBottomCornerRadius;

  final bool glassContainsChild;

  /// Bounds in geometry-local coordinates (for painting)
  final Rect shapeBounds;

  final Matrix4? shapeToGeometry;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ShapeGeometry &&
        other.renderObject == renderObject &&
        other.shape == shape &&
        other.glassContainsChild == glassContainsChild &&
        other.shapeBounds == shapeBounds;
  }

  @override
  int get hashCode => Object.hash(
        renderObject,
        shape,
        glassContainsChild,
        shapeBounds,
      );
}
