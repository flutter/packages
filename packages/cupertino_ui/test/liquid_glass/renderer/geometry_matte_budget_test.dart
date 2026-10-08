import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';
import 'package:liquid_glass_widgets/src/engine/render_liquid_glass_geometry.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';
import 'package:liquid_glass_widgets/src/engine/shaders.dart';

// Physical pixels the matte may hold while its shape is animating.
const _budget = 1024.0 * 1024.0;

void main() {
  late ui.FragmentShader geometryShader;
  late ui.FragmentShader renderShader;
  setUpAll(() async {
    geometryShader =
        (await ui.FragmentProgram.fromAsset(ShaderKeys.blendedGeometry))
            .fragmentShader();
    renderShader =
        (await ui.FragmentProgram.fromAsset(ShaderKeys.liquidGlassRender))
            .fragmentShader();
  });

  late GeometryRenderLink link;
  setUp(() => link = GeometryRenderLink());

  Future<_Layer> pump(WidgetTester tester, Size size) async {
    await tester.pumpWidget(Align(
      alignment: Alignment.topLeft,
      child: _LayerWidget(
        link: link,
        renderShader: renderShader,
        child: _ShapeWidget(
          link: link,
          geometryShader: geometryShader,
          child: SizedBox.fromSize(size: size),
        ),
      ),
    ));
    return tester.allRenderObjects.whereType<_Layer>().single;
  }

  // Physical width of a matte for a shape of [size] rasterised at [dpr]; the
  // recorded bounds are inflated by 2 logical px on each side.
  int matteWidth(Size size, double dpr) => ((size.width + 4) * dpr).ceil();

  testWidgets('a resizing shape over the budget is capped, then settles',
      (tester) async {
    final dpr = tester.view.devicePixelRatio;
    const large = Size(600, 500);
    expect(large.width * large.height * dpr * dpr, greaterThan(_budget));

    // The first paint, and the first rebuild after a quiet paint, are at
    // full resolution.
    var layer = await pump(tester, large);
    expect(layer.matte.width, matteWidth(large, dpr));
    layer.markNeedsPaint();
    await tester.pump();
    layer = await pump(tester, const Size(620, 520));
    expect(layer.matte.width, matteWidth(const Size(620, 520), dpr));

    // Consecutive rebuilds mean the shape is animating: the matte is scaled
    // so the whole texture fits the budget.
    const animating = Size(640, 540);
    final pixels = animating.width * animating.height * dpr * dpr;
    final capped = dpr * sqrt(_budget / pixels);
    layer = await pump(tester, animating);
    expect(layer.matte.width, matteWidth(animating, capped));

    // Nothing else repaints a resting shape; the layer asks for one more
    // frame and settles at full resolution.
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump();
    expect(layer.matte.width, matteWidth(animating, dpr));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  group('a moved blend group', () {
    Future<(_Layer, _Shape)> pumpMoved(
      WidgetTester tester, {
      required Offset outer,
      required Offset inner,
    }) async {
      await tester.pumpWidget(Align(
        alignment: Alignment.topLeft,
        // Moves layer and shape together, like glass scrolling with its
        // content.
        child: Transform.translate(
          offset: outer,
          child: _LayerWidget(
            link: link,
            renderShader: renderShader,
            // Moves the shape within the layer.
            child: Transform.translate(
              offset: inner,
              child: _ShapeWidget(
                link: link,
                geometryShader: geometryShader,
                child: const SizedBox(width: 120, height: 48),
              ),
            ),
          ),
        ),
      ));
      return (
        tester.allRenderObjects.whereType<_Layer>().single,
        tester.allRenderObjects.whereType<_Shape>().single,
      );
    }

    testWidgets('keeps its matte when it moved together with its layer',
        (tester) async {
      var (layer, shape) =
          await pumpMoved(tester, outer: Offset.zero, inner: Offset.zero);
      final matte = layer.matte;

      (layer, shape) = await pumpMoved(
        tester,
        outer: const Offset(0, -37.5),
        inner: Offset.zero,
      );
      link.notifyTransformChanged(shape);
      layer.markNeedsPaint();
      await tester.pump();
      expect(identical(layer.matte, matte), isTrue);
    });

    testWidgets('rebuilds its matte when it moved within its layer',
        (tester) async {
      var (layer, shape) =
          await pumpMoved(tester, outer: Offset.zero, inner: Offset.zero);
      final matte = layer.matte;

      (layer, shape) = await pumpMoved(
        tester,
        outer: Offset.zero,
        inner: const Offset(12, 0),
      );
      link.notifyTransformChanged(shape);
      layer.markNeedsPaint();
      await tester.pump();
      expect(identical(layer.matte, matte), isFalse);
    });
  });

  testWidgets('a shape under the budget is never capped', (tester) async {
    final dpr = tester.view.devicePixelRatio;
    // Three consecutive rebuilds, as an animation would produce.
    for (final width in [100.0, 120.0, 140.0]) {
      final size = Size(width, 40);
      final layer = await pump(tester, size);
      expect(layer.matte.width, matteWidth(size, dpr));
    }
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}

// The matte pipeline without the Impeller-only glass pass, which the Skia
// test runner cannot draw.
class _Layer extends LiquidGlassRenderObject {
  _Layer({
    required super.link,
    required super.renderShader,
    required super.settings,
    required super.devicePixelRatio,
  });

  ui.Image get matte => geometryImage!;

  @override
  Size get desiredMatteSize => size;

  @override
  Matrix4 get matteTransform => Matrix4.identity();

  @override
  void paintLiquidGlass(
    PaintingContext context,
    Offset offset,
    List<(RenderLiquidGlassGeometry, GeometryCache, Matrix4)> shapes,
    Rect boundingBox,
  ) {}
}

class _LayerWidget extends SingleChildRenderObjectWidget {
  const _LayerWidget({
    required this.link,
    required this.renderShader,
    required super.child,
  });

  final GeometryRenderLink link;
  final ui.FragmentShader renderShader;

  @override
  _Layer createRenderObject(BuildContext context) => _Layer(
        link: link,
        renderShader: renderShader,
        settings: const LiquidGlassSettings(thickness: 20, blur: 0),
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
}

// A shape whose geometry is its own size, rebuilt on every layout.
class _Shape extends RenderLiquidGlassGeometry {
  _Shape({
    required super.renderLink,
    required super.geometryShader,
    required super.settings,
    required super.devicePixelRatio,
  });

  @override
  void performLayout() {
    super.performLayout();
    markGeometryNeedsUpdate(force: true);
  }

  @override
  GeometryCache? maybeRebuildGeometry() {
    if (geometryState == LiquidGlassGeometryState.updated) return geometry;
    geometry?.dispose();
    final bounds = Offset.zero & size;
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    geometry = UnrenderedGeometryCache(
      matte: recorder.endRecording(),
      bounds: bounds,
      matteBounds: Rect.fromLTWH(
        0,
        0,
        bounds.width * devicePixelRatio,
        bounds.height * devicePixelRatio,
      ),
      shapes: const [],
      path: Path(),
    );
    geometryState = LiquidGlassGeometryState.updated;
    renderLink?.notifyGeometryChanged(this);
    return geometry;
  }

  @override
  (Rect, List<ShapeGeometry>, bool) gatherShapeData() =>
      (Offset.zero & size, const [], false);

  @override
  void updateShaderWithSettings(
    LiquidGlassSettings settings,
    double devicePixelRatio,
  ) {}

  @override
  void updateGeometryShaderShapes(List<ShapeGeometry> shapes) {}

  @override
  void paintShapeContents(
    RenderObject from,
    PaintingContext context,
    Offset offset, {
    required bool insideGlass,
  }) {}
}

class _ShapeWidget extends SingleChildRenderObjectWidget {
  const _ShapeWidget({
    required this.link,
    required this.geometryShader,
    required super.child,
  });

  final GeometryRenderLink link;
  final ui.FragmentShader geometryShader;

  @override
  _Shape createRenderObject(BuildContext context) => _Shape(
        renderLink: link,
        geometryShader: geometryShader,
        settings: const LiquidGlassSettings(thickness: 20, blur: 0),
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
}
