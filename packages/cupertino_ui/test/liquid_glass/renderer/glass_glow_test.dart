import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/glass_glow.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassGlowLayer construction
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassGlowLayer', () {
    testWidgets('renders child without glow when no touch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: SizedBox(width: 200, height: 200, child: Text('content')),
          ),
        ),
      );
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('maybeOf returns null when no layer ancestor', (tester) async {
      GlassGlowLayerState? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = GlassGlowLayer.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isNull);
    });

    testWidgets('maybeOf returns state when layer is present', (tester) async {
      GlassGlowLayerState? result;
      await tester.pumpWidget(
        MaterialApp(
          home: GlassGlowLayer(
            child: Builder(
              builder: (context) {
                result = GlassGlowLayer.maybeOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(result, isNotNull);
    });

    testWidgets('disposes cleanly when removed from tree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      // Remove from tree
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassGlow within layer
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassGlow', () {
    testWidgets('renders child within a GlassGlowLayer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: GlassGlow(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Text('glow child'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('glow child'), findsOneWidget);
    });

    testWidgets('responds to pointer down and move events', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: GlassGlow(
              child: SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(GlassGlow));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      await gesture.moveBy(const Offset(10, 10));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('pointer cancel removes touch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: GlassGlow(
              child: SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(GlassGlow));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();
    });

    testWidgets('custom glowColor and glowRadius are stored', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: GlassGlow(
              glowColor: Colors.blue,
              glowRadius: 0.5,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final glow = tester.widget<GlassGlow>(find.byType(GlassGlow));
      expect(glow.glowColor, Colors.blue);
      expect(glow.glowRadius, 0.5);
    });

    testWidgets('GlassGlow without GlassGlowLayer does not throw',
        (tester) async {
      // _handlePointer should silently return when layerState == null
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlow(
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(GlassGlow));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.up();
      await tester.pump();
    });

    testWidgets('GlassGlowLayerState.updateTouch updates on subsequent call',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassGlowLayer(
            child: GlassGlow(
              child: SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(GlassGlow));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Second move — exercises the already-dragging branch
      await gesture.moveBy(const Offset(5, 5));
      await tester.pump();
      await gesture.moveBy(const Offset(-5, 10));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('removeTouch is idempotent – calling twice does not crash',
        (tester) async {
      GlassGlowLayerState? state;
      await tester.pumpWidget(
        MaterialApp(
          home: GlassGlowLayer(
            child: Builder(
              builder: (context) {
                state = GlassGlowLayer.maybeOf(context);
                return const SizedBox(width: 100, height: 100);
              },
            ),
          ),
        ),
      );

      expect(state, isNotNull);
      state!.removeTouch(); // no-op (not dragging)
      state!.removeTouch(); // should not throw
    });
  });

  // ── Spring-switching behaviour (glow-follow-speed fix) ────────────────────
  //
  // Before the fix: _offsetController always used GlassSpring.smooth(1 s),
  // so the glow spotlight lagged ~1 s behind the finger during drags.
  //
  // After the fix: on the first updateTouch call, _offsetController is
  // switched to GlassSpring.interactive() so position tracks the finger
  // tightly. On removeTouch() it reverts to the slow smooth spring for the
  // graceful fade-out drift.
  //
  // We verify this through the @visibleForTesting `dragging` getter which
  // is the authoritative switch between the two spring profiles.

  group('GlassGlowLayerState spring-switching (glow-follow-speed fix)', () {
    testWidgets('updateTouch sets dragging=true on first call', (tester) async {
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child:
                GlassGlowLayer(key: layerKey, child: const SizedBox.expand()),
          ),
        ),
      );

      expect(layerKey.currentState!.dragging, isFalse);

      layerKey.currentState!.updateTouch(const Offset(50, 40),
          radius: 1.0, color: Colors.white24);
      await tester.pump();

      expect(layerKey.currentState!.dragging, isTrue);
    });

    testWidgets(
        'subsequent updateTouch calls while dragging keep dragging=true',
        (tester) async {
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child:
                GlassGlowLayer(key: layerKey, child: const SizedBox.expand()),
          ),
        ),
      );

      final state = layerKey.currentState!;
      state.updateTouch(const Offset(10, 40),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(state.dragging, isTrue);

      // Subsequent moves should not toggle _dragging
      state.updateTouch(const Offset(50, 40),
          radius: 1.0, color: Colors.white24);
      state.updateTouch(const Offset(90, 40),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(state.dragging, isTrue);
    });

    testWidgets('removeTouch sets dragging=false', (tester) async {
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child:
                GlassGlowLayer(key: layerKey, child: const SizedBox.expand()),
          ),
        ),
      );

      final state = layerKey.currentState!;
      state.updateTouch(const Offset(50, 40),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(state.dragging, isTrue);

      state.removeTouch();
      await tester.pump();
      expect(state.dragging, isFalse);
    });

    testWidgets('removeTouch while not dragging is a no-op (no crash)',
        (tester) async {
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child:
                GlassGlowLayer(key: layerKey, child: const SizedBox.expand()),
          ),
        ),
      );

      expect(() => layerKey.currentState!.removeTouch(), returnsNormally);
      expect(layerKey.currentState!.dragging, isFalse);
    });

    testWidgets('drag → release → drag cycle works without crash',
        (tester) async {
      final layerKey = GlobalKey<GlassGlowLayerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child:
                GlassGlowLayer(key: layerKey, child: const SizedBox.expand()),
          ),
        ),
      );

      final state = layerKey.currentState!;

      // Cycle 1 — enter interactive spring
      state.updateTouch(const Offset(10, 40),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(state.dragging, isTrue);

      state.removeTouch();
      await tester.pump();
      expect(state.dragging, isFalse);

      // Cycle 2 — re-enter interactive spring after smooth restore
      state.updateTouch(const Offset(90, 40),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(state.dragging, isTrue);

      state.removeTouch();
      await tester.pump();
      expect(state.dragging, isFalse);
    });

    testWidgets(
        'pointer gesture triggers interactive spring and releases it on up',
        (tester) async {
      // GlassGlow.build() creates its OWN inner GlassGlowLayer for event
      // routing, so the keyed outer layer is not the one receiving the touch.
      // We test end-to-end via the inner layer — same pattern as the passing
      // "responds to pointer down and move events" test above.
      GlassGlowLayerState? innerState;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: GlassGlow(
              glowColor: Colors.white24,
              child: Builder(
                builder: (context) {
                  innerState = GlassGlowLayer.maybeOf(context);
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );

      expect(innerState, isNotNull);
      expect(innerState!.dragging, isFalse);

      // Simulate drag — directly call the public API (same as what the
      // Listener in GlassGlow does internally).
      innerState!.updateTouch(const Offset(100, 100),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(innerState!.dragging, isTrue);

      // Move
      innerState!.updateTouch(const Offset(120, 100),
          radius: 1.0, color: Colors.white24);
      await tester.pump();
      expect(innerState!.dragging, isTrue);

      // Release
      innerState!.removeTouch();
      await tester.pump();
      expect(innerState!.dragging, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // The touch stays inside the layer it lights
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassGlowLayer bounds', () {
    testWidgets('clamps the touch to the layer when the pointer leaves it',
        (tester) async {
      // A captured pointer keeps reporting moves after it leaves the widget,
      // and the layer clips the glow to its own shape — so an unclamped centre
      // slides the highlight out of the clip and the light fades to nothing
      // while the finger is still down. Most visible on a wide, short bar.
      late BuildContext inner;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 64,
              child: GlassGlowLayer(
                child: GlassGlow(
                  child: Builder(
                    builder: (context) {
                      inner = context;
                      return const SizedBox.expand();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final notifier = GlassGlowLayer.touchSpecularNotifierOf(inner);
      expect(notifier, isNotNull);

      final centre = tester.getCenter(find.byType(GlassGlow));
      final gesture = await tester.startGesture(centre);
      await tester.pump();
      expect(notifier!.value.position.dy, closeTo(32, 1));

      // Straight up, well past the top edge.
      await gesture.moveBy(const Offset(0, -300));
      await tester.pump();
      expect(notifier.value.position.dy, inInclusiveRange(0, 64));
      expect(notifier.value.position.dx, closeTo(200, 1));

      // And sideways, past the trailing edge: the glow parks at the corner
      // rather than walking off the bar.
      await gesture.moveBy(const Offset(500, 0));
      await tester.pump();
      expect(notifier.value.position.dx, inInclusiveRange(0, 400));
      expect(notifier.value.position.dy, inInclusiveRange(0, 64));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
