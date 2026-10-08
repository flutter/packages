import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';

class _TestLiquidGlassRenderObject extends LiquidGlassRenderObject {
  _TestLiquidGlassRenderObject({
    required super.link,
    required super.renderShader,
    required super.settings,
    required super.devicePixelRatio,
    this.testDesiredMatteSize = const Size(800, 600),
  });

  Size testDesiredMatteSize;

  @override
  Size get desiredMatteSize => testDesiredMatteSize;

  @override
  Matrix4 get matteTransform => Matrix4.identity();

  @override
  bool get encloseDirectChildrenInPass => true;

  @override
  void paintLiquidGlass(
    PaintingContext context,
    Offset offset,
    List<dynamic> shapes,
    Rect boundingBox,
  ) {}
}

class _TestLiquidGlassWidget extends SingleChildRenderObjectWidget {
  const _TestLiquidGlassWidget({
    required this.renderObject,
    required Widget super.child,
  });

  final _TestLiquidGlassRenderObject renderObject;

  @override
  RenderObject createRenderObject(BuildContext context) => renderObject;

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _TestLiquidGlassRenderObject renderObject,
  ) {}
}

class _RenderLayerWidget extends SingleChildRenderObjectWidget {
  const _RenderLayerWidget({
    required this.layer,
    required Widget super.child,
  });

  final RenderLiquidGlassLayer layer;

  @override
  RenderLiquidGlassLayer createRenderObject(BuildContext context) => layer;
}

class _TestGlassShapeWidget extends SingleChildRenderObjectWidget {
  const _TestGlassShapeWidget({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLiquidGlass(
      shape: const LiquidRoundedRectangle(borderRadius: 10),
      glassContainsChild: false,
      blendGroupLink: null,
    );
  }
}

RenderLiquidGlassLayer _createLayer({
  EdgeInsets clipExpansion = EdgeInsets.zero,
  ui.Image? captureImage,
}) {
  return RenderLiquidGlassLayer(
    renderShader: null,
    devicePixelRatio: 1.0,
    settings: const LiquidGlassSettings(),
    shadows: const [],
    link: GeometryRenderLink(),
    clipExpansion: clipExpansion,
    captureImage: captureImage,
  );
}

void main() {
  group('LiquidGlassRenderObject.enclosingBackdropPassRect', () {
    testWidgets('returns null when there is no backdrop-reading ancestor',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: _TestLiquidGlassWidget(
              renderObject: ro,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(ro.enclosingBackdropPassRect(), isNull);
    });

    testWidgets(
        'returns screen-space rect when enclosed by a Flutter RenderBackdropFilter',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 98,
                  top: 45,
                  width: 300,
                  height: 500,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _TestLiquidGlassWidget(
                          renderObject: ro,
                          child: const SizedBox(width: 80, height: 40),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final passRect = ro.enclosingBackdropPassRect();
      expect(passRect, isNotNull);
      // The BackdropFilter is positioned at (98, 45) with size 300x500.
      expect(passRect, const Rect.fromLTWH(98, 45, 300, 500));
    });

    testWidgets(
        'returns transformed rect when enclosed by an own-layer LiquidGlassRenderObject',
        (tester) async {
      final outerRo = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );
      final innerRo = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      // Simulate outer glass layer having painted a backdrop pass with local clip.
      outerRo.backdropPassClipRectLocal = const Rect.fromLTWH(0, 0, 250, 350);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 60,
                  top: 70,
                  width: 250,
                  height: 350,
                  child: _TestLiquidGlassWidget(
                    renderObject: outerRo,
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: _TestLiquidGlassWidget(
                        renderObject: innerRo,
                        child: const SizedBox(width: 100, height: 50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final passRect = innerRo.enclosingBackdropPassRect();
      expect(passRect, isNotNull);
      // Outer render object is at (60, 70), clip is (0, 0, 250, 350) → global (60, 70, 250, 350)
      expect(passRect, const Rect.fromLTWH(60, 70, 250, 350));
    });

    testWidgets(
        'returns null when ancestor LiquidGlassRenderObject has backdropPassClipRectLocal == null (capture path)',
        (tester) async {
      final outerRo = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );
      final innerRo = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      // Capture path clears backdropPassClipRectLocal to null.
      outerRo.backdropPassClipRectLocal = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestLiquidGlassWidget(
              renderObject: outerRo,
              child: _TestLiquidGlassWidget(
                renderObject: innerRo,
                child: const SizedBox(width: 50, height: 50),
              ),
            ),
          ),
        ),
      );

      expect(innerRo.enclosingBackdropPassRect(), isNull);
    });

    testWidgets(
        'stops at the nearest enclosing backdrop pass when nested multiple levels',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                // Outer BackdropFilter (e.g. full-screen modal background)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Stack(
                      children: [
                        // Inner BackdropFilter (e.g. nested drawer or card)
                        Positioned(
                          left: 120,
                          top: 80,
                          width: 200,
                          height: 300,
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: _TestLiquidGlassWidget(
                              renderObject: ro,
                              child: const SizedBox(width: 100, height: 100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final passRect = ro.enclosingBackdropPassRect();
      expect(passRect, isNotNull);
      // Must resolve to the inner BackdropFilter (120, 80, 200, 300), not the outer full-screen one
      expect(passRect, const Rect.fromLTWH(120, 80, 200, 300));
    });

    testWidgets('clamps pass rect to root surface bounds (desiredMatteSize)',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
        testDesiredMatteSize: const Size(400, 400),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                // BackdropFilter extends beyond the 400x400 desiredMatteSize
                Positioned(
                  left: 250,
                  top: 200,
                  width: 300,
                  height: 350,
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: _TestLiquidGlassWidget(
                      renderObject: ro,
                      child: const SizedBox(width: 100, height: 100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final passRect = ro.enclosingBackdropPassRect();
      expect(passRect, isNotNull);
      // Expected intersection: Rect(250, 200, 550, 550) ∩ Rect(0, 0, 400, 400) = Rect(250, 200, 400, 400)
      expect(passRect, const Rect.fromLTRB(250, 200, 400, 400));
    });
  });

  group('RenderLiquidGlassLayer backdrop pass propagation', () {
    testWidgets(
        'real RenderLiquidGlassLayer enclosed by BackdropFilter resolves pass rect with RenderView bounds',
        (tester) async {
      final layer = _createLayer();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 50,
                  width: 300,
                  height: 400,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: _RenderLayerWidget(
                        layer: layer,
                        child: const SizedBox(width: 120, height: 80),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify that desiredMatteSize resolves from the RenderView (default 800x600)
      expect(layer.desiredMatteSize, const Size(800, 600));

      final passRect = layer.enclosingBackdropPassRect();
      expect(passRect, isNotNull);
      // Should find the ancestor BackdropFilter at (100, 50, 300, 400)
      expect(passRect, const Rect.fromLTWH(100, 50, 300, 400));
    });

    testWidgets(
        'glass-in-glass: inner RenderLiquidGlassLayer finds outer RenderLiquidGlassLayer pass rect when inside glass shape',
        (tester) async {
      final outerLayer = _createLayer();
      final innerLayer = _createLayer();

      // Simulate outer layer having painted with a 320x400 clip rect
      outerLayer.backdropPassClipRectLocal =
          const Rect.fromLTWH(0, 0, 320, 400);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 80,
                  top: 60,
                  width: 320,
                  height: 400,
                  child: _RenderLayerWidget(
                    layer: outerLayer,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: _TestGlassShapeWidget(
                        child: _RenderLayerWidget(
                          layer: innerLayer,
                          child: const SizedBox(width: 100, height: 60),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
          outerLayer.enclosingBackdropPassRect(), isNull); // outer is at root

      final innerPassRect = innerLayer.enclosingBackdropPassRect();
      expect(innerPassRect, isNotNull);
      // Inner layer finds outer layer at (80, 60) with size (320, 400)
      expect(innerPassRect, const Rect.fromLTWH(80, 60, 320, 400));
    });

    testWidgets(
        'glass-in-glass: outer capture path sets backdropPassClipRectLocal to null so inner does not inherit it',
        (tester) async {
      final outerLayer = _createLayer();
      final innerLayer = _createLayer();

      // Outer painted via capture path → backdropPassClipRectLocal is null
      outerLayer.backdropPassClipRectLocal = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 80,
                  top: 60,
                  width: 320,
                  height: 400,
                  child: _RenderLayerWidget(
                    layer: outerLayer,
                    child: _TestGlassShapeWidget(
                      child: _RenderLayerWidget(
                        layer: innerLayer,
                        child: const SizedBox(width: 100, height: 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(innerLayer.enclosingBackdropPassRect(), isNull);
    });

    testWidgets(
        'backdropPassClipRectLocal is not inherited by super.paint children outside paintShapeContents',
        (tester) async {
      final outerLayer = _createLayer();
      final innerLayer = _createLayer();

      outerLayer.backdropPassClipRectLocal =
          const Rect.fromLTWH(0, 0, 320, 400);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 80,
                  top: 60,
                  width: 320,
                  height: 400,
                  child: _RenderLayerWidget(
                    layer: outerLayer,
                    child: _RenderLayerWidget(
                      layer: innerLayer,
                      child: const SizedBox(width: 100, height: 60),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // outerLayer retains its backdropPassClipRectLocal for its shapes
      expect(outerLayer.backdropPassClipRectLocal, isNotNull);
      // but innerLayer was rendered as a super.paint child (no RenderLiquidGlass shape),
      // so it does NOT inherit the pass rect!
      expect(innerLayer.enclosingBackdropPassRect(), isNull);
    });

    testWidgets(
        'isolated descendant repaint retains enclosing pass rect when outer layer does not repaint',
        (tester) async {
      final outerLayer = _createLayer();
      final innerLayer = _createLayer();

      outerLayer.backdropPassClipRectLocal =
          const Rect.fromLTWH(0, 0, 320, 400);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 80,
                  top: 60,
                  width: 320,
                  height: 400,
                  child: _RenderLayerWidget(
                    layer: outerLayer,
                    child: _TestGlassShapeWidget(
                      child: _RenderLayerWidget(
                        layer: innerLayer,
                        child: const SizedBox(width: 100, height: 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Inner layer initially resolves the outer pass rect.
      expect(innerLayer.enclosingBackdropPassRect(),
          const Rect.fromLTWH(80, 60, 320, 400));

      // Simulate isolated repaint on innerLayer (e.g. button click/glow animation)
      innerLayer.markNeedsPaint();
      await tester.pump();

      // Outer layer did not repaint, but inner layer still resolves the outer pass rect!
      expect(outerLayer.backdropPassClipRectLocal, isNotNull);
      expect(innerLayer.enclosingBackdropPassRect(),
          const Rect.fromLTWH(80, 60, 320, 400));
    });
  });

  group('Physical pass rect calculation math', () {
    test('floor and ceil pixel alignment matches Impeller texture allocation',
        () {
      const dpr = 3.0; // iPhone retina scale
      const passLogical = Rect.fromLTRB(98.3, 45.7, 398.2, 545.8);

      final passPhysical = Rect.fromLTRB(
        (passLogical.left * dpr).floorToDouble(),
        (passLogical.top * dpr).floorToDouble(),
        (passLogical.right * dpr).ceilToDouble(),
        (passLogical.bottom * dpr).ceilToDouble(),
      );

      expect(passPhysical.left, 294.0); // floor(294.9)
      expect(passPhysical.top, 137.0); // floor(137.1)
      expect(passPhysical.right, 1195.0); // ceil(1194.6)
      expect(passPhysical.bottom, 1638.0); // ceil(1637.4)

      // Active bounds offset translation
      const activeBounds = Rect.fromLTWH(118.3, 65.7, 100.0, 50.0);
      final uGeometryOffset = activeBounds.topLeft * dpr - passPhysical.topLeft;
      // activeBounds.topLeft * 3 = (354.9, 197.1)
      // uGeometryOffset = (354.9 - 294.0, 197.1 - 137.0) = (60.9, 60.1)
      expect(uGeometryOffset.dx, closeTo(60.9, 1e-6));
      expect(uGeometryOffset.dy, closeTo(60.1, 1e-6));
    });
  });
}
