import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';
import 'package:liquid_glass_widgets/src/engine/render_liquid_glass_geometry.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';
import 'package:liquid_glass_widgets/src/engine/shaders.dart';

// The frost's blur pass is clipped to every odd physical pixel row of the
// glass, and the render shader reads the cloud from those rows and the sharp
// backdrop from the rows between, so the rows must land on whole pixel rows
// wherever the glass is placed and however it is scaled.
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

  Future<_Layer> pump(
    WidgetTester tester,
    LiquidGlassSettings settings, {
    Matrix4? transform,
    bool inBackdropPass = false,
  }) async {
    Widget glass = Padding(
      // A fractional offset, so rows do not fall on logical pixels.
      padding: const EdgeInsets.fromLTRB(10.3, 7.7, 0, 0),
      child: Transform(
        transform: transform ?? Matrix4.identity(),
        child: _LayerWidget(
          link: link,
          renderShader: renderShader,
          settings: settings,
          child: _ShapeWidget(
            link: link,
            geometryShader: geometryShader,
            settings: settings,
            child: const SizedBox(width: 56, height: 56),
          ),
        ),
      ),
    );
    if (inBackdropPass) {
      // An enclosing pass at a fractional offset of its own: the shader's
      // rows count from its top, not the screen's.
      glass = Padding(
        padding: const EdgeInsets.fromLTRB(3.1, 5.7, 0, 0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: glass,
        ),
      );
    }
    await tester.pumpWidget(Align(alignment: Alignment.topLeft, child: glass));
    return tester.allRenderObjects.whereType<_Layer>().single;
  }

  const frosted = LiquidGlassSettings(frost: 14, blur: 0.6);

  void expectOddRows(WidgetTester tester, _Layer layer) {
    final dpr = tester.view.devicePixelRatio;
    final pass = layer.enclosingBackdropPassRect();
    final passTop = pass == null ? 0 : (pass.top * dpr).floor();
    final rows = layer.frostRowsPath!;
    final toScreen = layer.getTransformTo(null);
    final toLocal = Matrix4.inverted(toScreen);
    final screen =
        MatrixUtils.transformRect(toScreen, Offset.zero & layer.size);
    final top = (screen.top * dpr).ceil() + 1;
    final bottom = (screen.bottom * dpr).floor() - 1;
    final x = (screen.center.dx * dpr).floorToDouble() + 0.5;
    for (var y = top; y < bottom; y++) {
      final local = MatrixUtils.transformPoint(
        toLocal,
        Offset(x / dpr, (y + 0.5) / dpr),
      );
      expect(
        rows.contains(local),
        (y - passTop).isOdd,
        reason: 'physical row $y, pass top $passTop',
      );
    }
  }

  testWidgets('a frost clips its blur to the odd physical rows',
      (tester) async {
    expectOddRows(tester, await pump(tester, frosted));
  });

  testWidgets('the rows stay on physical rows under a scale', (tester) async {
    expectOddRows(
      tester,
      await pump(
        tester,
        frosted,
        transform: Matrix4.diagonal3Values(1.3, 1.3, 1),
      ),
    );
  });

  testWidgets('rows count from an enclosing backdrop pass', (tester) async {
    final layer = await pump(tester, frosted, inBackdropPass: true);
    // 5.7 pt at 3x puts the pass's top on an odd physical row, so rows
    // counted from the screen would be the wrong ones.
    expect(
      (layer.enclosingBackdropPassRect()!.top * tester.view.devicePixelRatio)
          .floor()
          .isOdd,
      isTrue,
    );
    expectOddRows(tester, layer);
  });

  testWidgets('no frost, no rows', (tester) async {
    final layer = await pump(tester, const LiquidGlassSettings(blur: 0.6));
    expect(layer.frostRowsPath, isNull);
  });

  testWidgets('a rotated frost has no rows to land on', (tester) async {
    final layer =
        await pump(tester, frosted, transform: Matrix4.rotationZ(0.1));
    expect(layer.frostRowsPath, isNull);
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

  @override
  Size get desiredMatteSize => const Size(800, 600);

  @override
  Matrix4 get matteTransform => getTransformTo(null);

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
    required this.settings,
    required super.child,
  });

  final GeometryRenderLink link;
  final ui.FragmentShader renderShader;
  final LiquidGlassSettings settings;

  @override
  _Layer createRenderObject(BuildContext context) => _Layer(
        link: link,
        renderShader: renderShader,
        settings: settings,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
}

// A shape whose geometry is its own size.
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
    required this.settings,
    required super.child,
  });

  final GeometryRenderLink link;
  final ui.FragmentShader geometryShader;
  final LiquidGlassSettings settings;

  @override
  _Shape createRenderObject(BuildContext context) => _Shape(
        renderLink: link,
        geometryShader: geometryShader,
        settings: settings,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
}
