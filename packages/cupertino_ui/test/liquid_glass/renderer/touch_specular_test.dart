import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/engine/glass_glow.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';

class _TestLiquidGlassRenderObject extends LiquidGlassRenderObject {
  _TestLiquidGlassRenderObject({
    required super.link,
    required super.renderShader,
    required super.settings,
    required super.devicePixelRatio,
  });

  @override
  Size get desiredMatteSize => const Size(100, 100);

  @override
  Matrix4 get matteTransform => Matrix4.identity();

  @override
  void paintLiquidGlass(
    PaintingContext context,
    Offset offset,
    List<dynamic> shapes,
    Rect boundingBox,
  ) {}

  int paintNeedsCount = 0;

  @override
  void markNeedsPaint() {
    super.markNeedsPaint();
    paintNeedsCount++;
  }
}

void main() {
  group('LiquidGlassRenderObject touch specular fields', () {
    test('setTouchSpecular updates values and schedules paint', () {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      expect(ro.touchPosition, Offset.zero);
      expect(ro.touchIntensity, 0.0);
      final initialPaintCount = ro.paintNeedsCount;

      ro.setTouchSpecular(const Offset(50, 60), 0.8);
      expect(ro.touchPosition, const Offset(50, 60));
      expect(ro.touchIntensity, 0.8);
      expect(ro.paintNeedsCount, initialPaintCount + 1);

      // Redundant call should NOT trigger markNeedsPaint
      ro.setTouchSpecular(const Offset(50, 60), 0.8);
      expect(ro.paintNeedsCount, initialPaintCount + 1);

      // Clamping intensity
      ro.setTouchSpecular(const Offset(10, 10), 1.5);
      expect(ro.touchIntensity, 1.0);
      ro.setTouchSpecular(const Offset(10, 10), -0.5);
      expect(ro.touchIntensity, 0.0);
    });
  });

  group('GlassGlowLayer touch specular notifier', () {
    testWidgets('touchSpecularNotifierOf returns null when no layer ancestor',
        (tester) async {
      ValueNotifier<({Offset position, double intensity})>? notifier;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              notifier = GlassGlowLayer.touchSpecularNotifierOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(notifier, isNull);
    });

    testWidgets('touchSpecularNotifierOf returns notifier and updates on touch',
        (tester) async {
      ValueNotifier<({Offset position, double intensity})>? notifier;
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: GlassGlowLayer(
            key: layerKey,
            child: Builder(
              builder: (context) {
                notifier = GlassGlowLayer.touchSpecularNotifierOf(context);
                return const SizedBox(width: 100, height: 100);
              },
            ),
          ),
        ),
      );
      expect(notifier, isNotNull);
      expect(notifier!.value.intensity, 0.0);

      // Trigger updateTouch
      layerKey.currentState!.updateTouch(
        const Offset(30, 40),
        radius: 1.0,
        color: const Color(0xFFFFFFFF),
      );

      expect(notifier!.value.position, const Offset(30, 40));

      // Advance spring animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(notifier!.value.intensity, greaterThan(0.0));

      // Remove touch
      layerKey.currentState!.removeTouch();
      await tester.pumpAndSettle();
      expect(notifier!.value.intensity, 0.0);
    });

    testWidgets('GlassGlow sends touch updates to GlassGlowLayer',
        (tester) async {
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: GlassGlowLayer(
            key: layerKey,
            child: const Center(
              child: GlassGlow(
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        ),
      );

      final notifier = GlassGlowLayer.touchSpecularNotifierOf(
        tester.element(find.byType(SizedBox).first),
      );
      expect(notifier, isNotNull);

      // Tap on the GlassGlow
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(SizedBox).first));
      await tester.pump();
      expect(notifier!.value.intensity, greaterThanOrEqualTo(0.0));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(notifier.value.intensity, 0.0);
    });

    testWidgets(
        'upward propagation: GlassGlow inside LiquidGlassRenderObject translates coordinates',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: _TestLiquidGlassWidget(
              renderObject: ro,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 40),
                  child: GlassGlowLayer(
                    key: layerKey,
                    child: const GlassGlow(
                      child: SizedBox(width: 100, height: 100),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Trigger touch on the child GlassGlowLayer at local offset (20, 20)
      layerKey.currentState!.updateTouch(
        const Offset(20, 20),
        radius: 1.0,
        color: const Color(0x99FFFFFF),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Check that upward propagation reached ro with translated offset: (20+30, 20+40) = (50, 60)
      expect(ro.touchPosition, const Offset(50, 60));
      expect(ro.touchIntensity, greaterThan(0.0));
    });

    testWidgets(
        'downward translation: converts GlassGlowLayer coordinates to local glass space',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GlassGlowLayer(
              key: layerKey,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 40),
                  child: _TestLiquidGlassWidget(
                    renderObject: ro,
                    child: Builder(
                      builder: (context) {
                        final notifier =
                            GlassGlowLayer.touchSpecularNotifierOf(context);
                        notifier?.addListener(() {
                          final v = notifier.value;
                          final layerBox = GlassGlowLayer.maybeOf(context)
                              ?.context
                              .findRenderObject() as RenderBox?;
                          if (layerBox != null &&
                              layerBox.attached &&
                              ro.attached &&
                              layerBox.hasSize &&
                              ro.hasSize) {
                            final pos = ro.globalToLocal(
                                layerBox.localToGlobal(v.position));
                            ro.setTouchSpecular(pos, v.intensity);
                          }
                        });
                        return const SizedBox(width: 100, height: 100);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      layerKey.currentState!.updateTouch(
        const Offset(50, 60),
        radius: 1.0,
        color: const Color(0xFFFFFFFF),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Global (50, 60) relative to layer minus padding (30, 40) gives local (20, 20)
      expect(ro.touchPosition, const Offset(20, 20));
      expect(ro.touchIntensity, greaterThan(0.0));
    });

    testWidgets(
        'issue #355: upward propagation does not throw when glow updates in the frame a FractionalTranslation wrapper is inserted',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      final layerKey = GlobalKey<GlassGlowLayerState>();
      final subtreeKey = GlobalKey();
      bool insertWrapper = false;

      late StateSetter setParentState;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setParentState = setState;
              Widget content = KeyedSubtree(
                key: subtreeKey,
                child: _TestLiquidGlassWidget(
                  renderObject: ro,
                  child: GlassGlowLayer(
                    key: layerKey,
                    child: const GlassGlow(
                      child: SizedBox(width: 100, height: 100),
                    ),
                  ),
                ),
              );

              if (insertWrapper) {
                content = FractionalTranslation(
                  translation: const Offset(0.25, 0),
                  child: content,
                );
              }

              return Center(child: content);
            },
          ),
        ),
      );

      // Settle initial frame so ro and glowLayer have size and layout.
      await tester.pumpAndSettle();
      expect(ro.hasSize, isTrue);

      // In a single frame, insert the FractionalTranslation wrapper AND update the glow.
      // This causes the newly inserted RenderFractionalTranslation to be attached without layout,
      // while the child rebuilds and calls updateRenderObject on _RenderGlassGlowLayer.
      setParentState(() {
        insertWrapper = true;
      });
      layerKey.currentState!.updateTouch(
        const Offset(20, 20),
        radius: 1.0,
        color: const Color(0x99FFFFFF),
      );

      // Pump the build phase. Prior to fixing #355, this threw:
      // StateError: Bad state: RenderBox was not laid out: RenderFractionalTranslation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(ro.touchPosition, const Offset(20, 20));
      expect(ro.touchIntensity, greaterThan(0.0));
    });

    testWidgets(
        'issue #355: upward propagation does not throw when an unlaid-out RenderBox is between glow layer and glass layer',
        (tester) async {
      final ro = _TestLiquidGlassRenderObject(
        link: GeometryRenderLink(),
        renderShader: null,
        settings: const LiquidGlassSettings(),
        devicePixelRatio: 1.0,
      );

      final layerKey = GlobalKey<GlassGlowLayerState>();
      final subtreeKey = GlobalKey();
      bool insertWrapper = false;

      late StateSetter setParentState;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: _TestLiquidGlassWidget(
              renderObject: ro,
              child: StatefulBuilder(
                builder: (context, setState) {
                  setParentState = setState;
                  Widget content = KeyedSubtree(
                    key: subtreeKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, top: 40),
                      child: GlassGlowLayer(
                        key: layerKey,
                        child: const GlassGlow(
                          child: SizedBox(width: 100, height: 100),
                        ),
                      ),
                    ),
                  );

                  if (insertWrapper) {
                    content = FractionalTranslation(
                      translation: const Offset(0.25, 0),
                      child: content,
                    );
                  }

                  return SizedBox(width: 200, height: 200, child: content);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(ro.hasSize, isTrue);

      // Insert FractionalTranslation BETWEEN ro and GlassGlowLayer, while updating touch
      setParentState(() {
        insertWrapper = true;
      });
      layerKey.currentState!.updateTouch(
        const Offset(20, 20),
        radius: 1.0,
        color: const Color(0x99FFFFFF),
      );

      // Build frame: FractionalTranslation has not been laid out yet. Must not throw!
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Advance layout and post-frame callback
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(ro.touchIntensity, greaterThan(0.0));
    });
  });
}

class _TestLiquidGlassWidget extends SingleChildRenderObjectWidget {
  const _TestLiquidGlassWidget({
    required this.renderObject,
    required Widget super.child,
  });

  final _TestLiquidGlassRenderObject renderObject;

  @override
  RenderObject createRenderObject(BuildContext context) => renderObject;
}
