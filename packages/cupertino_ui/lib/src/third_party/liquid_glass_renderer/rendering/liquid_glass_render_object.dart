// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../../renderer/fragment_shader_extensions.dart';
import '../../renderer/liquid_glass_renderer.dart'
    show debugPaintLiquidGlassGeometry;
import '../liquid_glass.dart' show RenderLiquidGlass;
import '../liquid_glass_settings.dart';
import '../render_liquid_glass_geometry.dart';
import '../snap_rect_to_pixels.dart';

/// A render object that can assemble [RenderLiquidGlassGeometry] shapes and
/// render them to the screen with the liquid glass effect.
abstract class LiquidGlassRenderObject extends RenderProxyBox {
  LiquidGlassRenderObject({
    required GeometryRenderLink link,
    this.renderShader,
    required LiquidGlassSettings settings,
    required double devicePixelRatio,
    BackdropKey? backdropKey,
    ui.Image? captureImage,
    Offset captureOriginInScreenSpace = Offset.zero,
  })  : _settings = settings,
        _devicePixelRatio = devicePixelRatio,
        _backdropKey = backdropKey,
        _captureImage = captureImage,
        _captureOriginInScreenSpace = captureOriginInScreenSpace,
        _link = link,
        _cachedLightDir = Offset(
          cos(settings.lightAngle),
          -sin(settings.lightAngle),
        );

  final FragmentShader? renderShader;

  /// With a frost, the alternate pixel rows its blur pass is clipped to, in
  /// local coordinates: every row with an odd y in the enclosing pass, over
  /// the glass's bounds. The render shader reads the frost's cloud from
  /// these rows and the sharp backdrop from the rows between (see uFrost in
  /// liquid_glass_render.frag). Null without a frost, on the capture path,
  /// or when the glass is rotated or skewed and rows in local space would
  /// not land on pixel rows.
  Path? frostRowsPath;

  /// Widest blur, as a sigma in physical pixels, that the render shader
  /// applies to the copy of the content showing through a frost; a wider
  /// [LiquidGlassSettings.blur] runs as its own pass first.
  static const double frostGhostMaxSigma = 2.4;

  // Built once per size and scale, shifted while the glass moves.
  final FrostRows _frostRowsCache = FrostRows();

  /// How many times the frost rows were built from scratch, for tests.
  @visibleForTesting
  int get debugFrostRowsBuilds => _frostRowsCache.builds;

  /// Cached light direction vector — updated only when [settings.lightAngle]
  /// changes. Avoids recomputing cos/sin on every setting change.
  Offset _cachedLightDir;

  /// The size that the geometry texture should have.
  Size get desiredMatteSize;

  Matrix4 get matteTransform;

  /// Local-space rect of the backdrop-reading compositor pass this render
  /// object opened on its last paint (the clip around its
  /// [BackdropFilterLayer]), or null when it painted via the capture path
  /// (no live backdrop pass opened). Descendant glass uses this via
  /// [enclosingBackdropPassRect] to find the pass its own fragment
  /// coordinates are relative to.
  Rect? backdropPassClipRectLocal;

  /// Whether direct children in [child] painted via [super.paint] should
  /// inherit [backdropPassClipRectLocal] even if they are not descendants of
  /// a [RenderLiquidGlass] shape.
  ///
  /// Defaults to `false` for [RenderLiquidGlassLayer] because it paints [child]
  /// outside the [BackdropFilterLayer] via [super.paint], and only paints
  /// [RenderLiquidGlass] shapes inside the backdrop pass.
  ///
  /// Test fixtures or custom subclasses that composite their [child] directly
  /// inside the backdrop pass can override this to `true`.
  bool get encloseDirectChildrenInPass => false;

  /// Builds [frostRowsPath] for the glass's current bounds and screen
  /// transform; see [FrostRows].
  Path? _frostRows(Rect passPhysical, double dpr) => _frostRowsCache.rows(
        transform: getTransformTo(null),
        bounds: _paintBounds,
        passPhysical: passPhysical,
        dpr: dpr,
      );

  /// Screen-space (logical) rect of the nearest enclosing Impeller compositor
  /// pass that a [BackdropFilterLayer] in this subtree samples from, or null
  /// when that pass is the root surface.
  ///
  /// On Impeller, every [BackdropFilterLayer] renders its subtree into an
  /// offscreen pass sized to its clip. [FlutterFragCoord()] inside any shader
  /// nested in that subtree is relative to the pass, not the screen, and the
  /// backdrop texture the nested shader samples IS that pass — not the full
  /// screen. The live-path uniforms (uSize, uGeometryOffset, uTouchPosition)
  /// must therefore be expressed against this rect rather than the screen.
  ///
  /// Recognises two pass sources:
  ///   1. Flutter's own [RenderBackdropFilter] (any BackdropFilter widget).
  ///   2. A [LiquidGlassRenderObject] whose [backdropPassClipRectLocal] is
  ///      non-null (any own-layer glass surface on the live/backdrop path)
  ///      when the querying node is inside a [RenderLiquidGlass] shape (or
  ///      when [encloseDirectChildrenInPass] is true).
  ///
  /// Returns null (→ uniforms reduce to current behaviour) when no such
  /// ancestor is found, i.e. the glass composes directly into the root pass.
  Rect? enclosingBackdropPassRect() {
    RenderObject? node = parent;
    bool passedThroughGlassShape = false;
    while (node != null) {
      Rect? local;
      if (node is RenderBackdropFilter) {
        // Flutter's BackdropFilter opens a pass scoped to its own logical size.
        local = Offset.zero & node.size;
      } else if (node is RenderLiquidGlass) {
        passedThroughGlassShape = true;
      } else if (node is LiquidGlassRenderObject) {
        if (passedThroughGlassShape || node.encloseDirectChildrenInPass) {
          local = node.backdropPassClipRectLocal;
        }
        passedThroughGlassShape = false;
      }
      if (local != null) {
        final global = MatrixUtils.transformRect(
          node.getTransformTo(null),
          local,
        );
        // Coverage never exceeds the root surface.
        return global.intersect(Offset.zero & desiredMatteSize);
      }
      node = node.parent;
    }
    return null;
  }

  late GeometryRenderLink _link;
  GeometryRenderLink get link => _link;
  set link(GeometryRenderLink value) {
    if (_link == value) return;
    markNeedsPaint();
    _link = value;
  }

  LiquidGlassSettings? _settings;
  LiquidGlassSettings get settings => _settings!;
  set settings(LiquidGlassSettings value) {
    if (_settings == value) return;
    // Only recompute the trig if lightAngle actually changed.
    if (value.lightAngle != _settings?.lightAngle) {
      _cachedLightDir = Offset(
        cos(value.lightAngle),
        -sin(value.lightAngle),
      );
    }
    // alwaysNeedsCompositing == (_geometryImage != null). The geometry image is
    // set synchronously inside paint() so we cannot call
    // markNeedsCompositingBitsUpdate() from there. However, when settings
    // change such that the paint path changes (e.g. thickness/blur both drop to
    // zero → _clearGeometryImage is called → predicate flips false), we need
    // to dirty the compositing bit. Capture the pre-update state and request
    // a re-evaluation after the value changes.
    final wasCompositing = alwaysNeedsCompositing;
    _settings = value;
    if (wasCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  double _devicePixelRatio;
  double get devicePixelRatio => _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  /// The [BackdropKey] for blur-sharing via the layer's own [BackdropGroup].
  /// Set to [BackdropGroup.of(context)?.backdropKey] from the layer's local
  /// [BackdropGroup]; null when no group exists (no-op).
  BackdropKey? _backdropKey;
  BackdropKey? get backdropKey => _backdropKey;
  set backdropKey(BackdropKey? value) {
    if (_backdropKey == value) return;
    _backdropKey = value;
    markNeedsPaint();
  }

  // ── Capture-path fields ───────────────────────────────────────────────────
  //
  // When [captureImage] is non-null, [paintLiquidGlass] implementations MUST
  // use [paintLiquidGlassWithCapture] instead of the BackdropFilterLayer path.
  // The captured image is the background texture fed directly to the shader,
  // bypassing the live compositor read entirely.
  //
  // [captureOriginInScreenSpace] is the global (screen-space) logical-pixel
  // position of the RepaintBoundary that produced [captureImage]. It is used
  // to derive [uCaptureOffset]: the physical-pixel shift from the render
  // surface's canvas origin to the capture boundary's origin, which corrects
  // [FlutterFragCoord()] (canvas-local) into capture-image space.

  ui.Image? _captureImage;
  ui.Image? get captureImage => _captureImage;
  set captureImage(ui.Image? value) {
    if (identical(_captureImage, value)) return;
    _captureImage = value;
    markNeedsPaint();
  }

  Offset _captureOriginInScreenSpace = Offset.zero;
  Offset get captureOriginInScreenSpace => _captureOriginInScreenSpace;
  set captureOriginInScreenSpace(Offset value) {
    if (_captureOriginInScreenSpace == value) return;
    _captureOriginInScreenSpace = value;
    markNeedsPaint();
  }

  // ── Touch Specular fields ─────────────────────────────────────────────────
  //
  // Driven by GlassGlowLayerState via a ValueNotifier. The logical-pixel touch
  // position and spring-animated intensity are forwarded to the shader as
  // uTouchPosition (physical px) and uTouchIntensity.
  //
  // setTouchSpecular() is the only public mutation point: it guards against
  // redundant markNeedsPaint() calls (equality check on both fields) and
  // performs the DPR scale so callers work in logical pixels.

  /// Touch point in logical pixels (layer-local).
  Offset _touchPosition = Offset.zero;

  /// Spring-animated touch presence scalar [0.0 at rest, 1.0 while pressed].
  double _touchIntensity = 0.0;

  @visibleForTesting
  Offset get touchPosition => _touchPosition;

  @visibleForTesting
  double get touchIntensity => _touchIntensity;

  /// Updates the touch specular uniforms and schedules a repaint if changed.
  ///
  /// [position] must be in layer-local **logical pixels**.
  /// [intensity] must be in [0.0, 1.0].
  ///
  /// Called from [GlassGlowLayerState] on every spring animation tick via a
  /// [ValueNotifier] listener — never from a widget build or setState.
  void setTouchSpecular(Offset position, double intensity) {
    final clamped = intensity.clamp(0.0, 1.0);
    if (_touchPosition == position && _touchIntensity == clamped) return;
    _touchPosition = position;
    _touchIntensity = clamped;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => _geometryImage != null;

  /// Pre-rendered geometry texture in the render object's LOCAL coordinate space.
  /// Because the geometry is recorded without `matteTransform`, its screen-space
  /// position is always derived synchronously at paint time — zero async lag.
  ui.Image? _geometryImage;
  @protected
  ui.Image? get geometryImage => _geometryImage;

  /// Bounding box of [_geometryImage] in the render object's LOCAL logical-pixel
  /// coordinate space (snapped to physical pixels).
  /// Apply `matteTransform` at paint time to get the current screen-space bounds.
  Rect _geometryLocalBounds = Rect.zero;
  @protected
  Rect get geometryLocalBounds => _geometryLocalBounds;

  /// Physical-pixel budget for [_geometryImage] while its shape is animating.
  /// See [_matteDevicePixelRatio].
  static const double _kAnimatingMattePixelBudget = 1024 * 1024;

  /// The pixel ratio [_geometryImage] was rasterized at. Equal to
  /// [devicePixelRatio] unless the matte was capped.
  double _geometryImageDevicePixelRatio = 1;

  /// Whether the previous paint rebuilt [_geometryImage]. A rebuild on the
  /// paint right after a rebuild means the shape is animating.
  bool _rebuiltGeometryLastPaint = false;

  /// Whether [_geometryImage] was rasterized below [devicePixelRatio] and
  /// still owes a full-resolution rebuild once the shape comes to rest.
  bool _geometryImageCapped = false;

  /// Whether the paint that settles a capped matte is already requested.
  bool _settleGeometryScheduled = false;

  /// The shape transforms [_geometryImage] was rasterized with, relative to
  /// this render object. A blend group that moved on screen only needs a new
  /// matte if it moved relative to this layer, not when both moved together
  /// (glass scrolling with its content, a sheet sliding in).
  final List<Matrix4> _geometryImageTransforms = [];

  @override
  @mustCallSuper
  void attach(PipelineOwner owner) {
    super.attach(owner);
  }

  @override
  @mustCallSuper
  void detach() {
    backdropPassClipRectLocal = null;
    // Reset transient paint-state flags so a re-attached surface always starts
    // its first paint at full resolution, without inheriting stale animation
    // state (e.g. a surface that was animating when removed would otherwise
    // cap its first post-reattach matte).
    _rebuiltGeometryLastPaint = false;
    _settleGeometryScheduled = false;
    super.detach();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    needsGeometryUpdate = true;
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  ui.Rect _paintBounds = ui.Rect.zero;

  @override
  ui.Rect get paintBounds => _paintBounds;

  // Reusable list to avoid per-frame allocations during paint traversal.
  final _shapesWithGeometry =
      <(RenderLiquidGlassGeometry, GeometryCache, Matrix4)>[];

  bool _sameTransformsAsMatte() {
    if (_geometryImageTransforms.length != _shapesWithGeometry.length) {
      return false;
    }
    for (var i = 0; i < _shapesWithGeometry.length; i++) {
      if (_shapesWithGeometry[i].$3 != _geometryImageTransforms[i]) {
        return false;
      }
    }
    return true;
  }

  // MARK: Painting

  @override
  @nonVirtual
  void paint(PaintingContext context, Offset offset) {
    // Guard: if this render object has been detached mid-frame (e.g. rapid
    // widget removal during isolate shutdown), skip all GPU operations to
    // prevent use-after-free on Mali GPU Vulkan resources.
    if (!attached) return;

    _shapesWithGeometry.clear();

    Rect? boundingBox;

    for (final geometryRo in link.shapes) {
      final geometry = geometryRo.maybeRebuildGeometry();

      if (geometry == null) continue;

      final transform = geometryRo.getTransformTo(this);
      _shapesWithGeometry.add((geometryRo, geometry, transform));

      final geoBounds = MatrixUtils.transformRect(
        transform,
        geometry.bounds,
      );
      boundingBox = boundingBox == null
          ? geoBounds
          : boundingBox.expandToInclude(geoBounds);
    }

    if (boundingBox == null || boundingBox.isEmpty || !boundingBox.isFinite) {
      _clearGeometryImage();

      super.paint(context, offset);
      return;
    }

    _paintBounds = boundingBox;

    // Fast-path: if there is no geometric thickness AND no blur, there is
    // nothing to render — skip the expensive async geometry build entirely.
    // If blur > 0 but thickness == 0, we must still run paintLiquidGlass so
    // the BackdropFilterLayer blur pass fires in liquid_glass_layer.dart.
    if (settings.effectiveThickness <= 0 && settings.effectiveBlur <= 0) {
      _clearGeometryImage();
      paintShapeContents(
        context,
        offset,
        _shapesWithGeometry,
        insideGlass: true,
      );
      paintShapeContents(
        context,
        offset,
        _shapesWithGeometry,
        insideGlass: false,
      );
      super.paint(context, offset);
      return;
    }

    final rebuildGeometry = needsGeometryUpdate ||
        _geometryImage == null ||
        link._dirty ||
        (link._transformDirty && !_sameTransformsAsMatte());
    link._transformDirty = false;
    if (rebuildGeometry) {
      link.updateAllGeometries();
      link._dirty = false;
      needsGeometryUpdate = false;

      // Synchronous rasterization (toImageSync) eliminates 1-frame jitter
      // during size animations (like modal sheet expansion).
      //
      // The first rebuild after a quiet paint is at full resolution; every
      // consecutive one is capped, since a shape that rebuilds on every paint
      // is animating and the matte is only on screen for one frame.
      _updateGeometrySync(
        _shapesWithGeometry,
        boundingBox,
        capped: _rebuiltGeometryLastPaint,
      );

      // The image is now current — no latency. On the very first frame there
      // is no previous image — fall through to the early-return below via the
      // null check on _geometryImage.
    } else if (_geometryImageCapped) {
      // The shape came to rest on a capped matte: settle at full resolution.
      _updateGeometrySync(_shapesWithGeometry, boundingBox, capped: false);
    }
    _rebuiltGeometryLastPaint = rebuildGeometry;

    if (debugPaintLiquidGlassGeometry) {
      _debugPaintGeometry(context, offset);
      paintShapeContents(
        context,
        offset,
        _shapesWithGeometry,
        insideGlass: true,
      );
      paintShapeContents(
        context,
        offset,
        _shapesWithGeometry,
        insideGlass: false,
      );
    } else {
      if (_geometryImage case final geometryImage?) {
        // Map the texture to exactly the bounds it was originally built for
        // (_geometryLocalBounds) rather than the newly expanding current frame
        // bounds (_paintBounds).
        //
        // Using _paintBounds causes severe multi-button jitter during animations:
        // as one button scales, _paintBounds expands/shifts to contain it. Since
        // the asynchronous texture lags 1 frame behind, rendering the old texture
        // using the new origin visually shifted entire group of buttons on the
        // screen until the next texture arrived.
        //
        // Locking the shader mapping to the precise bounds the texture was built
        // with ensures stable pixel positioning for the life of the texture.
        final activeBounds = MatrixUtils.transformRect(
          matteTransform,
          _geometryLocalBounds,
        ).snapToPixels(devicePixelRatio);

        // Scale physical thickness to maintain identical logical rim width across DPRs.
        // The baseline visual thickness was tuned on a 3x Retina display.
        final scale = devicePixelRatio / 3.0;

        final dpr = devicePixelRatio;

        // On Impeller, any ancestor BackdropFilter (Flutter's or our own
        // own-layer glass) renders its subtree into an offscreen pass scoped to
        // that ancestor's clip. FlutterFragCoord() inside our shader is then
        // relative to that pass, not the screen, and the backdrop texture IS
        // that pass. Express uSize and uGeometryOffset against that pass rect.
        // When there is no such ancestor, passLogical is null and passPhysical
        // equals the full screen — uniforms reduce exactly to their previous
        // values (zero regression for top-level surfaces).
        final passLogical = enclosingBackdropPassRect();
        // Impeller allocates offscreen-pass textures in whole physical pixels;
        // round out so our size matches the actual texture dimensions.
        final passPhysical = passLogical == null
            ? Offset.zero & (desiredMatteSize * dpr)
            : Rect.fromLTRB(
                (passLogical.left * dpr).floorToDouble(),
                (passLogical.top * dpr).floorToDouble(),
                (passLogical.right * dpr).ceilToDouble(),
                (passLogical.bottom * dpr).ceilToDouble(),
              );

        // The capture path draws without a live backdrop, so no frost.
        frostRowsPath = settings.effectiveFrost > 0 && _captureImage == null
            ? _frostRows(passPhysical, dpr)
            : null;
        // The frost's opacity, eased in over its first 2 pt so a frost that
        // animates up from 0 doesn't start as a sharp, opaque cloud, and kept
        // above zero so uFrost.x doubles as the frost's on switch.
        final frostOpacity = max(
          settings.frostOpacity.clamp(0.0, 1.0) *
              (settings.effectiveFrost / 2).clamp(0.0, 1.0),
          1e-3,
        );
        // A blur wider than the shader's ghost runs as a pass of its own
        // (see RenderLiquidGlassLayer), leaving the shader nothing to add.
        final ghostSigma = settings.effectiveBlur * dpr;

        renderShader!
          // Slot 0-1: uSize — physical-pixel size of the enclosing compositor
          // pass (root surface when no backdrop ancestor exists).
          ..setFloatUniforms(initialIndex: 0, (value) {
            value.setSize(passPhysical.size);
          })
          // Slots 2-5: uGeometryOffset + uGeometrySize, pass-relative.
          // Subtracting passPhysical.topLeft converts screen-space activeBounds
          // into coordinates relative to the pass texture's origin (0,0).
          ..setFloatUniforms(initialIndex: 2, (value) {
            value
              ..setOffset(activeBounds.topLeft * dpr - passPhysical.topLeft)
              ..setSize(activeBounds.size * dpr);
          })
          ..setFloatUniforms(initialIndex: 6, (value) {
            value
              ..setColor(settings.effectiveGlassColor)
              ..setFloats([
                settings.effectiveRefractiveIndex,
                settings.effectiveChromaticAberration,
                settings.effectiveThickness * scale,
                1.0, // uRefractScale (slot 13) - normalization handled by physical geometry curve scaling
                settings.effectiveLightIntensity,
                settings.effectiveAmbientStrength,
                settings.effectiveSaturation,
              ])
              ..setOffset(_cachedLightDir); // slots 17-18
          })
          // Slot 19: uWhiten (whitening amount); slot 20: uWhitenGated
          // Slot 21: uPinchStrength
          ..setFloatUniforms(initialIndex: 19, (value) {
            value
              ..setFloat(settings.effectiveWhitenStrength)
              ..setFloat(settings.whitenGated ? 1.0 : 0.0)
              ..setFloat(settings.pinchStrength);
          })
          // Slots 22-25: uBackgroundFallback (straight RGBA).
          ..setFloatUniforms(initialIndex: 22, (value) {
            final b = settings.platformViewFallbackColor ??
                settings.effectiveBackerColor ??
                const Color(0x00000000);
            value.setFloats(<double>[b.r, b.g, b.b, b.a]);
          })
          // Slots 26-27: uCaptureOffset
          ..setFloatUniforms(initialIndex: 26, (value) {
            value.setOffset(Offset.zero);
          })
          // Slots 28-31: uEdgeConfig (ambientRim, fresnelStrength, dprScale, edgeAbsorption)
          ..setFloatUniforms(initialIndex: 28, (value) {
            value.setFloats([
              settings.effectiveAmbientRim * scale,
              settings.effectiveFresnelStrength,
              scale,
              settings.effectiveEdgeAbsorption,
            ]);
          })
          // Slot 32: uPlatformViewMode; Slot 33: uBodyMode.
          ..setFloatUniforms(initialIndex: 32, (value) {
            value
              ..setFloat(
                settings.platformViewMode == PlatformViewGlassMode.passthrough
                    ? 1.0
                    : 0.0,
              )
              ..setFloat(
                settings.bodyMode == GlassBodyMode.clear ? 1.0 : 0.0,
              );
          })
          // Slots 34-35: uTouchPosition (physical px); Slot 36: uTouchIntensity.
          // Multiply by DPR here so the shader receives physical-pixel coords
          // matching FlutterFragCoord() — GlassGlowLayerState delivers logical px.
          // Subtract passPhysical.topLeft for the same reason as uGeometryOffset:
          // touch position must be relative to the enclosing pass, not the screen.
          ..setFloatUniforms(initialIndex: 34, (value) {
            value
              ..setOffset(_touchPosition * dpr - passPhysical.topLeft)
              ..setFloat(_touchIntensity.clamp(0.0, 1.0));
          })
          // Slots 37-39: uRimConfig (rimShade, rimLight, rimShadeEnds);
          // slot 40: uLensModel; slot 45: uBodyShade.
          ..setFloatUniforms(initialIndex: 37, (value) {
            value.setFloats([
              settings.effectiveRimShade,
              settings.effectiveRimLight,
              settings.rimShadeEnds,
              settings.lensModel == GlassLensModel.paraxial ? 1.0 : 0.0,
              // Slots 41-44: uFrost.
              if (frostRowsPath == null) 0.0 else frostOpacity,
              settings.frostClamp.clamp(-1.0, 1.0),
              ghostSigma > frostGhostMaxSigma ? 0.0 : ghostSigma,
              max(settings.blurWeight, 0.0),
              // Slot 45: uBodyShade.
              settings.effectiveBodyShade.clamp(0.0, 1.0),
            ]);
          })
          ..setImageSampler(
            1,
            geometryImage,
            filterQuality: FilterQuality.medium,
          );
        paintLiquidGlass(
          context,
          offset,
          _shapesWithGeometry,
          _paintBounds,
        );
      }
    }

    super.paint(context, offset);
  }

  void _clearGeometryImage() {
    _geometryImage?.dispose();
    _geometryImage = null;
    _geometryImageCapped = false;
  }

  /// Subclasses implement the actual glass rendering
  /// (e.g., with backdrop filters)
  void paintLiquidGlass(
    PaintingContext context,
    Offset offset,
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> shapes,
    Rect boundingBox,
  );

  /// Direct-draw paint path used when [captureImage] is non-null.
  ///
  /// Instead of emitting a [BackdropFilterLayer] (which reads from the live
  /// compositor), this draws the shader as a plain rect onto the current canvas,
  /// binding the pre-captured background image to sampler slot 0.
  ///
  /// Coordinate math:
  ///   [FlutterFragCoord()] in a plain canvas.drawRect gives the fragment
  ///   position within the current compositing layer (the RepaintBoundary that
  ///   [LiquidGlassLayer] creates). [captureOriginInScreenSpace] is the global
  ///   logical-pixel origin of the capture boundary (from localToGlobal).
  ///   The physical-pixel offset between the two coordinate origins is:
  ///
  ///     uCaptureOffset = (captureOriginGlobal - thisRenderOriginGlobal) * dpr
  ///
  ///   Adding this to [FlutterFragCoord()] maps each fragment into capture-image
  ///   space, so [screenUV] correctly addresses the pre-captured bar texture.
  @protected
  void paintLiquidGlassWithCapture(
    PaintingContext context,
    Offset offset,
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> shapes,
    Rect boundingBox,
    ui.Image capture,
  ) {
    if (!attached) return;

    final dpr = devicePixelRatio;

    // Our render object's global logical-pixel origin.
    final thisOriginGlobal = matteTransform.getTranslation();
    final thisOriginLogical = Offset(thisOriginGlobal.x, thisOriginGlobal.y);

    // Physical-pixel offset from our canvas origin → capture-boundary origin.
    // This is the uCaptureOffset uniform: it shifts FlutterFragCoord() (which
    // is relative to the compositing layer, i.e. our RepaintBoundary surface)
    // into the capture image's coordinate space.
    final captureOffset =
        (captureOriginInScreenSpace - thisOriginLogical) * dpr;

    // uSize: physical pixel dimensions of the captured image.
    final captureSize =
        ui.Size(capture.width.toDouble(), capture.height.toDouble());

    // Geometry bounds in screen space, snapped to pixels.
    final activeBounds = MatrixUtils.transformRect(
      matteTransform,
      _geometryLocalBounds,
    ).snapToPixels(dpr);

    // uGeometryOffset/uGeometrySize are relative to the capture origin
    // (not screen origin) so that geometryUV = (fragCoord + uCaptureOffset -
    // uGeometryOffset) / uGeometrySize resolves correctly.
    final geometryOffsetInCapture =
        (activeBounds.topLeft - captureOriginInScreenSpace) * dpr;
    final geometrySizePhysical = activeBounds.size * dpr;
    final scale = dpr / 3.0;

    renderShader!
      // Slot 0-1: uSize — physical size of the capture image.
      ..setFloatUniforms(initialIndex: 0, (value) {
        value.setSize(captureSize);
      })
      // Slots 2-5: uGeometryOffset + uGeometrySize, relative to capture origin.
      ..setFloatUniforms(initialIndex: 2, (value) {
        value
          ..setOffset(geometryOffsetInCapture)
          ..setSize(geometrySizePhysical);
      })
      ..setFloatUniforms(initialIndex: 6, (value) {
        value
          ..setColor(settings.effectiveGlassColor)
          ..setFloats([
            settings.effectiveRefractiveIndex,
            settings.effectiveChromaticAberration,
            settings.effectiveThickness * scale,
            1.0, // uRefractScale (slot 13) - normalization handled by physical geometry curve scaling
            settings.effectiveLightIntensity,
            settings.effectiveAmbientStrength,
            settings.effectiveSaturation,
          ])
          ..setOffset(_cachedLightDir); // slots 17-18
      })
      ..setFloatUniforms(initialIndex: 19, (value) {
        value
          ..setFloat(settings.effectiveWhitenStrength)
          ..setFloat(settings.whitenGated ? 1.0 : 0.0)
          ..setFloat(settings.pinchStrength);
      })
      ..setFloatUniforms(initialIndex: 22, (value) {
        final b = settings.platformViewFallbackColor ??
            settings.effectiveBackerColor ??
            const Color(0x00000000);
        value.setFloats(<double>[b.r, b.g, b.b, b.a]);
      })
      // Slot 26-27: uCaptureOffset
      ..setFloatUniforms(initialIndex: 26, (value) {
        value.setOffset(captureOffset);
      })
      // Slots 28-31: uEdgeConfig (ambientRim, fresnelStrength, dprScale, edgeAbsorption)
      ..setFloatUniforms(initialIndex: 28, (value) {
        value.setFloats([
          settings.effectiveAmbientRim * scale,
          settings.effectiveFresnelStrength,
          scale,
          settings.effectiveEdgeAbsorption,
        ]);
      })
      // Slot 32: uPlatformViewMode; Slot 33: uBodyMode.
      ..setFloatUniforms(initialIndex: 32, (value) {
        value
          ..setFloat(
            settings.platformViewMode == PlatformViewGlassMode.passthrough
                ? 1.0
                : 0.0,
          )
          ..setFloat(
            settings.bodyMode == GlassBodyMode.clear ? 1.0 : 0.0,
          );
      })
      // Slots 34-35: uTouchPosition (physical px); Slot 36: uTouchIntensity.
      // Multiply by DPR here so the shader receives physical-pixel coords
      // matching FlutterFragCoord() — GlassGlowLayerState delivers logical px.
      ..setFloatUniforms(initialIndex: 34, (value) {
        value
          ..setOffset(_touchPosition * dpr)
          ..setFloat(_touchIntensity.clamp(0.0, 1.0));
      })
      // Slots 37-39: uRimConfig (rimShade, rimLight, rimShadeEnds);
      // slot 40: uLensModel; slot 45: uBodyShade.
      ..setFloatUniforms(initialIndex: 37, (value) {
        value.setFloats([
          settings.effectiveRimShade,
          settings.effectiveRimLight,
          settings.rimShadeEnds,
          settings.lensModel == GlassLensModel.paraxial ? 1.0 : 0.0,
          // Slots 41-44: uFrost. No frost on the capture path (no cloud
          // rows); every component is set so none is left stale.
          0.0, 0.0, 0.0, 1.0,
          // Slot 45: uBodyShade.
          settings.effectiveBodyShade.clamp(0.0, 1.0),
        ]);
      })
      // Slot 0: captured background image (replaces the BackdropFilter read).
      ..setImageSampler(0, capture)
      ..setImageSampler(1, geometryImage!, filterQuality: FilterQuality.medium);

    // Draw the capture path: no BackdropFilterLayer needed — draw directly
    // onto the canvas over the expanded clip rect.
    final clipRect = boundingBox.expandToInclude(
      Rect.fromLTRB(
        boundingBox.left - 20,
        boundingBox.top - 15,
        boundingBox.right + 20,
        boundingBox.bottom + 15,
      ),
    );

    // Pass 1 (blur): retained even in capture mode — the blur layer reads from
    // the BackdropGroup which is the internal bar blur, not the external capture.
    // This is correct: the inner blur pass blurs icon content inside the glass,
    // the capture provides the bar background behind the glass.
    paintShapeContents(context, offset, shapes, insideGlass: true);

    // Pass 2: glass refraction shader as a plain canvas.drawRect.
    // No BackdropFilter wrapper; the captured image is already bound to slot 0.
    context.canvas
      ..save()
      ..clipRect(clipRect.shift(offset))
      ..drawRect(
        clipRect.shift(offset),
        Paint()..shader = renderShader!,
      )
      ..restore();

    // Pass 3: shape contents painted on top (non-glass child layer).
    paintShapeContents(context, offset, shapes, insideGlass: false);
  }

  @protected
  void paintShapeContents(
    PaintingContext context,
    Offset offset,
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> shapes, {
    required bool insideGlass,
  }) {
    for (final (geometryRenderObject, _, _) in shapes) {
      geometryRenderObject.paintShapeContents(
        this,
        context,
        offset,
        insideGlass: insideGlass,
      );
    }
  }

  void _debugPaintGeometry(PaintingContext context, Offset offset) {
    if (_geometryImage case final geometryImage?) {
      // The geometry image is in local space. Draw it at the local bounds
      // position so it overlays the glass content at the correct on-screen
      // location (the rendering canvas already applies the correct transform).
      context.canvas
        ..save()
        ..translate(_geometryLocalBounds.left, _geometryLocalBounds.top)
        ..scale(1 / _geometryImageDevicePixelRatio)
        ..drawImage(
          geometryImage,
          Offset.zero,
          Paint()..blendMode = BlendMode.src,
        )
        ..restore();
    }
  }

  /// Synchronously rasterizes the geometry picture using [ui.Picture.toImageSync].
  /// This eliminates the 1-frame async lag that caused visible ghosting during
  /// modal sheet and button-group animations. For the small pill-shape geometry
  /// used here, synchronous GPU upload is sub-millisecond and safe.
  ///
  /// With [capped], the matte is rasterized at [_matteDevicePixelRatio] and one
  /// more paint is requested so it settles at full resolution once the shape
  /// stops changing.
  void _updateGeometrySync(
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> geometries,
    Rect bounds, {
    required bool capped,
  }) {
    final matteDevicePixelRatio =
        _matteDevicePixelRatio(bounds.size, capped: capped);
    _geometryImageTransforms
      ..clear()
      ..addAll([for (final (_, _, transform) in geometries) transform]);

    // Record canvas commands synchronously — pure CPU work.
    final (picture, localBounds, imageSize) =
        _recordGeometryPicture(geometries, bounds, matteDevicePixelRatio);

    try {
      // Synchronous GPU rasterization — no async lag.
      // Clamp to ≥1: jelly squash can push geometry to near-zero size and
      // toImageSync(0, n) throws "Invalid image dimensions".
      final image = picture.toImageSync(
        max(1, imageSize.width.ceil()),
        max(1, imageSize.height.ceil()),
      );

      _clearGeometryImage();
      _geometryImage = image;
      _geometryLocalBounds = localBounds;
      _geometryImageDevicePixelRatio = matteDevicePixelRatio;
      _geometryImageCapped = matteDevicePixelRatio < devicePixelRatio;
      // No markNeedsPaint() needed — we are already inside paint().
      if (_geometryImageCapped) _scheduleGeometrySettle();
    } finally {
      picture.dispose();
    }
  }

  /// The pixel ratio to rasterize the geometry matte at.
  ///
  /// A resting surface builds its matte once and holds it, so full resolution
  /// costs nothing per frame there and it is always rasterized at
  /// [devicePixelRatio]. An animating surface rebuilds it on every frame, and
  /// the raster thread frees each texture some frames after the UI thread
  /// allocated the next: a sheet-sized matte is ~8 MB at 3×, which at 120 Hz
  /// grows the working set by hundreds of megabytes for the length of the
  /// animation. While [capped], the matte is scaled down to at most
  /// [_kAnimatingMattePixelBudget] physical pixels. The render shader samples
  /// it through a normalized UV with bilinear filtering, so a moving edge at
  /// ~1.5× is not visibly different from 3×; a capsule or tab bar is under
  /// the budget at any pixel ratio and is untouched.
  double _matteDevicePixelRatio(Size logicalSize, {required bool capped}) {
    final dpr = devicePixelRatio;
    if (!capped) return dpr;
    final pixels = logicalSize.width * logicalSize.height * dpr * dpr;
    if (pixels <= _kAnimatingMattePixelBudget) return dpr;
    return dpr * sqrt(_kAnimatingMattePixelBudget / pixels);
  }

  /// Requests one more paint after a capped rebuild. Nothing repaints a
  /// surface once its animation stops, so without this it would rest on the
  /// last capped matte.
  void _scheduleGeometrySettle() {
    if (_settleGeometryScheduled) return;
    _settleGeometryScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _settleGeometryScheduled = false;
      if (attached && _geometryImageCapped) markNeedsPaint();
    });
  }

  @override
  @mustCallSuper
  void dispose() {
    _clearGeometryImage();
    // Break reference chains to prevent stale GPU resource retention during
    // isolate shutdown. The render shader holds a DlRuntimeEffectColorSource
    // that retains Vulkan textures — nulling _settings ensures no closure
    // retains a path back to the shader's GPU resources past the Vulkan
    // context lifetime (Crash 2 in Mali GPU crash analysis).
    _settings = null;
    super.dispose();
  }

  // MARK: Geometry

  @protected
  bool needsGeometryUpdate = true;

  /// Records all geometry drawing commands into a [ui.Picture] synchronously.
  /// Returns the picture, the LOCAL-SPACE bounding rect, and the physical
  /// pixel size needed for rasterization at [matteDevicePixelRatio]. The
  /// caller is responsible for disposing the picture after rasterization.
  ///
  /// ## Local-space rasterization (A3)
  ///
  /// The geometry is recorded WITHOUT applying [matteTransform] (position,
  /// jelly scale, global screen offset). This means:
  ///
  /// - The image represents the pill SDF purely in the render object's own
  ///   coordinate space, at its current LOCAL size.
  /// - [matteTransform] is applied SYNCHRONOUSLY at paint time to derive the
  ///   screen-space [uGeometryOffset] / [uGeometrySize] uniforms — no 1-2
  ///   frame async lag, no correction needed.
  /// - Geometry rebuilds are only needed when the LOCAL shape changes
  ///   (layout/style), not for every position or jelly-scale animation frame.
  (ui.Picture, Rect, Size) _recordGeometryPicture(
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> geometries,
    Rect bounds,
    double matteDevicePixelRatio,
  ) {
    // Work in local coordinate space — no matteTransform applied.
    // Inflate by 2 logical pixels (= 2×DPR physical pixels after snapToPixels
    // aligns to the pixel grid) to ensure the anti-aliased SDF edge is fully
    // captured. Without this, the picture boundaries tightly crop the fractional
    // edge pixels, abruptly cutting off the rim lighting at the pill boundary.
    final localBounds = bounds.snapToPixels(devicePixelRatio).inflate(2.0);
    final size = localBounds.size * matteDevicePixelRatio;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final (_, geometry, transform) in geometries) {
      canvas
        ..save()
        ..scale(matteDevicePixelRatio)
        // Shift so localBounds.topLeft is the texture origin.
        ..translate(-localBounds.left, -localBounds.top)
        // Apply geometry-local → glass-local transform only (no matteTransform).
        ..transform(transform.storage)
        // Each shape's matte is in physical pixels at the real pixel ratio.
        ..scale(1 / devicePixelRatio)
        ..translate(
          geometry.matteBounds.topLeft.dx,
          geometry.matteBounds.topLeft.dy,
        );

      switch (geometry) {
        case UnrenderedGeometryCache(matte: final picture):
          canvas.drawPicture(picture);
        case RenderedGeometryCache(matte: final image):
          // The geometry-local transform above can scale this matte (shapes
          // under a Transform/LiquidStretch inside a shared layer). Paint()
          // defaults to FilterQuality.none — nearest — which stair-steps
          // the edge under any non-1:1 mapping; medium restores bilinear
          // resampling.
          canvas.drawImage(
            image,
            Offset.zero,
            Paint()..filterQuality = FilterQuality.medium,
          );
      }

      canvas.restore();
    }

    return (recorder.endRecording(), localBounds, size);
  }
}

class GeometryRenderLink {
  final List<RenderLiquidGlassGeometry> _shapeGeometries = [];

  UnmodifiableListView<RenderLiquidGlassGeometry> get shapes =>
      UnmodifiableListView(_shapeGeometries);

  bool _dirty = false;

  /// Set when a geometry's transform changed; the layer rebuilds its matte
  /// only if the transform relative to it changed too.
  bool _transformDirty = false;

  void updateAllGeometries() {
    for (final renderObject in _shapeGeometries) {
      renderObject.maybeRebuildGeometry();
    }
  }

  void registerGeometry(
    RenderLiquidGlassGeometry renderObject,
  ) {
    _dirty = true;
    // Idempotent: the layer paints one matte per entry, and [unregisterGeometry]
    // removes a single entry, so a duplicate would be painted twice and
    // outlive its detach.
    if (_shapeGeometries.contains(renderObject)) return;
    _shapeGeometries.add(renderObject);
  }

  /// Signals that a geometry object has completed a rebuild and the render
  /// layer should integrate the updated result on the next paint.
  void notifyGeometryChanged(RenderLiquidGlassGeometry renderObject) {
    _dirty = true;
  }

  /// Signals that a geometry object moved on screen. The render layer
  /// rebuilds its matte on the next paint only if the geometry moved
  /// relative to the layer.
  void notifyTransformChanged(RenderLiquidGlassGeometry renderObject) {
    _transformDirty = true;
  }

  void unregisterGeometry(RenderLiquidGlassGeometry renderObject) {
    if (_shapeGeometries.remove(renderObject)) {
      _dirty = true;
    }
  }

  void dispose() {
    _shapeGeometries.clear();
  }
}

class InheritedGeometryRenderLink extends InheritedWidget {
  const InheritedGeometryRenderLink({
    required this.link,
    required super.child,
    super.key,
  });

  final GeometryRenderLink link;

  static GeometryRenderLink? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedGeometryRenderLink>()
        ?.link;
  }

  @override
  bool updateShouldNotify(covariant InheritedGeometryRenderLink oldWidget) {
    return oldWidget.link != link;
  }
}

/// The frost's pixel rows: one rect per odd pass-relative physical row across
/// a glass's bounds, in its local coordinates.
///
/// The rows only depend on the glass's size and scale and on where its top
/// edge falls between two pass rows (its phase, 0 to 2 physical px). So they
/// are built once for phase 0, with a row beyond each edge, and a glass that
/// moves (a scroll, a sheet sliding in) gets them shifted by its phase
/// instead of rebuilt. Rows past the edges don't matter: the frost is clipped
/// to the shape first.
class FrostRows {
  Path? _base;
  Path? _shifted;
  Rect? _bounds;
  double _scaleX = 0;
  double _scaleY = 0;
  double _dpr = 0;
  double _phase = -1;

  /// How many times the rows were built from scratch.
  int builds = 0;

  /// The rows for a glass of [bounds] under [transform] (local to screen),
  /// drawn into a pass at [passPhysical], or null when [transform] rotates,
  /// skews or flips, and rows in local space would not land on pixel rows.
  Path? rows({
    required Matrix4 transform,
    required Rect bounds,
    required Rect passPhysical,
    required double dpr,
  }) {
    final storage = transform.storage;
    const tolerance = 1e-6;
    final sx = storage[0];
    final sy = storage[5];
    if (storage[1].abs() > tolerance ||
        storage[4].abs() > tolerance ||
        storage[3].abs() > tolerance ||
        storage[7].abs() > tolerance ||
        sx <= 0 ||
        sy <= 0) {
      return null;
    }
    if (_base == null ||
        bounds != _bounds ||
        sx != _scaleX ||
        sy != _scaleY ||
        dpr != _dpr) {
      _base = _build(bounds, sx, sy, dpr);
      _bounds = bounds;
      _scaleX = sx;
      _scaleY = sy;
      _dpr = dpr;
      _shifted = null;
    }
    // Pass-relative physical y of the glass's top edge, modulo two rows.
    // Dart's % is Euclidean, so the phase is in [0, 2).
    final top = bounds.top * sy + storage[13];
    final phase = (top * dpr - passPhysical.top) % 2;
    if (_shifted == null || phase != _phase) {
      _phase = phase;
      _shifted = _base!.shift(Offset(0, -phase / (dpr * sy)));
    }
    return _shifted;
  }

  /// The odd rows of a glass whose top edge sits on an even pass row:
  /// physical offsets -1, 1, 3, ... from the top edge, through one row past
  /// the bottom.
  Path _build(Rect bounds, double sx, double sy, double dpr) {
    builds++;
    final rowHeight = 1 / (dpr * sy);
    final left = bounds.left - 1 / (dpr * sx);
    final right = bounds.right + 1 / (dpr * sx);
    final physicalHeight = bounds.height * sy * dpr;
    final path = Path();
    for (var offset = -1.0; offset <= physicalHeight + 1; offset += 2) {
      final rowTop = bounds.top + offset * rowHeight;
      path.addRect(Rect.fromLTRB(left, rowTop, right, rowTop + rowHeight));
    }
    return path;
  }
}
