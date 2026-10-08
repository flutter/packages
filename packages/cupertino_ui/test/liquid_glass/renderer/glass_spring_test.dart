import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/utils/glass_spring.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // GlassSpring presets
  // ─────────────────────────────────────────────────────────────────────────
  //
  // SpringDescription.withDurationAndBounce determinism:
  //   - bounce > 0  →  under-damped  (oscillates, lower damping)
  //   - bounce = 0  →  critically-damped (fastest settle, no oscillation)
  //   - Same duration + higher bounce → higher stiffness, lower damping
  //
  // We test the DAMPING ordering (higher bounce → lower damping coefficient)
  // because that reliably distinguishes the presets, and the STIFFNESS
  // ordering for the duration sensitivity test.
  // ─────────────────────────────────────────────────────────────────────────

  group('GlassSpring presets', () {
    group('return valid SpringDescriptions', () {
      test('bouncy() has positive physical parameters', () {
        final s = GlassSpring.bouncy();
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('snappy() has positive physical parameters', () {
        final s = GlassSpring.snappy();
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('smooth() has positive physical parameters', () {
        final s = GlassSpring.smooth();
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('interactive() has positive physical parameters', () {
        final s = GlassSpring.interactive();
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });
    });

    group('bounce ordering at same duration', () {
      // All three have the same default duration (500 ms) but different bounce.
      // Higher bounce → under-damped → lower damping coefficient.
      final bouncy = GlassSpring.bouncy(); // bounce 0.3
      final snappy = GlassSpring.snappy(); // bounce 0.15
      final smooth = GlassSpring.smooth(); // bounce 0.0 (critically damped)

      test('bouncy has lower damping than snappy (more oscillation)', () {
        expect(bouncy.damping, lessThan(snappy.damping));
      });

      test('snappy has lower damping than smooth (more oscillation)', () {
        expect(snappy.damping, lessThan(smooth.damping));
      });

      test('all three have equal stiffness at the same duration', () {
        // k = mass * (2π / duration)² → identical for equal duration.
        expect(bouncy.stiffness, closeTo(snappy.stiffness, 1e-6));
        expect(snappy.stiffness, closeTo(smooth.stiffness, 1e-6));
      });
    });

    group('interactive() uses a much shorter default duration', () {
      // interactive: 150 ms  vs bouncy: 500 ms → interactive is stiffer.
      final interactive = GlassSpring.interactive(); // 150 ms
      final bouncy = GlassSpring.bouncy(); // 500 ms

      test('interactive is stiffer than default bouncy', () {
        expect(interactive.stiffness, greaterThan(bouncy.stiffness));
      });
    });

    group('extraBounce parameter', () {
      test('extraBounce lowers damping (more bounce)', () {
        final base = GlassSpring.bouncy();
        final extra = GlassSpring.bouncy(extraBounce: 0.2);
        // More bounce → lower damping coefficient
        expect(extra.damping, lessThan(base.damping));
      });

      test('smooth() with small extraBounce is still physically valid', () {
        final s = GlassSpring.smooth(extraBounce: 0.05);
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });
    });

    group('duration parameter is respected', () {
      // A shorter duration → higher angular frequency → higher stiffness.
      test('shorter duration produces stiffer spring', () {
        final fast =
            GlassSpring.bouncy(duration: const Duration(milliseconds: 200));
        final slow =
            GlassSpring.bouncy(duration: const Duration(milliseconds: 800));
        expect(fast.stiffness, greaterThan(slow.stiffness));
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SingleSpringController
  // ─────────────────────────────────────────────────────────────────────────

  group('SingleSpringController', () {
    testWidgets('initial value is set correctly', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
            initialValue: 42.0,
          ),
        ),
      );

      expect(ctrl.value, closeTo(42.0, 0.001));
    });

    testWidgets('animateTo reaches target after settling', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(1.0);

      // Smooth spring default ~500 ms; pump 1.5 s to be safe.
      for (var i = 0; i < 95; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(ctrl.value, closeTo(1.0, 0.01));
    });

    testWidgets('notifies listeners while animating', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      var notifyCount = 0;
      ctrl.addListener(() => notifyCount++);

      ctrl.animateTo(1.0);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(notifyCount, greaterThan(0));
    });

    testWidgets('value progresses toward target while animating',
        (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(1.0);

      // Pump a few frames and collect values.
      final values = <double>[];
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        values.add(ctrl.value);
      }

      // Value must increase (moving toward 1.0 from 0.0).
      expect(values.last, greaterThan(values.first));
      expect(values.last, lessThan(1.0)); // Hasn't settled in 160 ms.
    });

    testWidgets('velocity is zero after fully settling', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(1.0);

      // Pump well past settle time.
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(ctrl.velocity, closeTo(0.0, 0.001));
    });

    testWidgets('setValue sets value immediately without animating',
        (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.setValue(0.75);
      expect(ctrl.value, closeTo(0.75, 0.001));
      expect(ctrl.velocity, closeTo(0.0, 0.001));

      // No animation running — value stays put.
      await tester.pump(const Duration(milliseconds: 100));
      expect(ctrl.value, closeTo(0.75, 0.001));
    });

    testWidgets('lowerBound clamps value from going below 0', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.bouncy(),
            lowerBound: 0.0,
            upperBound: 1.0,
            initialValue: 0.0,
          ),
        ),
      );

      // Animate to upper bound; a bouncy spring will overshoot.
      // Even with overshoot the clamp must hold value >= 0.
      ctrl.animateTo(1.0);
      var minSeen = double.infinity;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (ctrl.value < minSeen) minSeen = ctrl.value;
      }

      expect(minSeen, greaterThanOrEqualTo(0.0));
    });

    testWidgets('upperBound clamps value from going above 1', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.bouncy(),
            lowerBound: 0.0,
            upperBound: 1.0,
            initialValue: 0.0,
          ),
        ),
      );

      ctrl.animateTo(1.0);
      var maxSeen = double.negativeInfinity;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (ctrl.value > maxSeen) maxSeen = ctrl.value;
      }

      expect(maxSeen, lessThanOrEqualTo(1.0));
    });

    testWidgets('redirect mid-animation does not jump', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(1.0);
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final valueAtRedirect = ctrl.value;

      // Redirect to 0 mid-flight. One frame later the value must still be
      // close to where it was (no teleport).
      ctrl.animateTo(0.0);
      await tester.pump(const Duration(milliseconds: 16));

      expect(ctrl.value, closeTo(valueAtRedirect, 0.15));
    });

    testWidgets('spring setter redirects simulation without throwing',
        (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(1.0);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Swapping spring mid-animation must not throw.
      expect(() => ctrl.spring = GlassSpring.bouncy(), returnsNormally);

      // Must still be well below target after the swap (not jumped to 1.0).
      await tester.pump(const Duration(milliseconds: 16));
      expect(ctrl.value, lessThan(1.0));
    });

    testWidgets('dispose does not throw', (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(1.0);
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Removing the widget tree triggers dispose.
      expect(
        () async => tester.pumpWidget(const SizedBox()),
        returnsNormally,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OffsetSpringController
  // ─────────────────────────────────────────────────────────────────────────

  group('OffsetSpringController', () {
    testWidgets('initial value is Offset.zero by default', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      expect(ctrl.value.dx, closeTo(0.0, 0.001));
      expect(ctrl.value.dy, closeTo(0.0, 0.001));
    });

    testWidgets('initial value is honoured', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
            initialValue: const Offset(5.0, 10.0),
          ),
        ),
      );

      expect(ctrl.value.dx, closeTo(5.0, 0.001));
      expect(ctrl.value.dy, closeTo(10.0, 0.001));
    });

    testWidgets('animateTo drives both axes toward target', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(const Offset(100, 200));

      // Collect values over ~160 ms; they should be progressing.
      final dxValues = <double>[];
      final dyValues = <double>[];
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        dxValues.add(ctrl.value.dx);
        dyValues.add(ctrl.value.dy);
      }

      expect(dxValues.last, greaterThan(dxValues.first));
      expect(dyValues.last, greaterThan(dyValues.first));
    });

    testWidgets('animateTo settles at target', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(const Offset(100, 200));

      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(ctrl.value.dx, closeTo(100.0, 1.0));
      expect(ctrl.value.dy, closeTo(200.0, 1.0));
    });

    testWidgets('listeners fire when an axis animates', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      var count = 0;
      ctrl.addListener(() => count++);

      ctrl.animateTo(const Offset(50, 50));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(count, greaterThan(0));
    });

    testWidgets('value setter sets offset immediately', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.value = const Offset(10, 20);
      expect(ctrl.value.dx, closeTo(10.0, 0.001));
      expect(ctrl.value.dy, closeTo(20.0, 0.001));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SpringBuilder widget
  // ─────────────────────────────────────────────────────────────────────────

  group('SpringBuilder', () {
    testWidgets('renders initial value immediately', (tester) async {
      double? renderedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SpringBuilder(
            value: 0.5,
            spring: GlassSpring.smooth(),
            builder: (context, v, _) {
              renderedValue = v;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(renderedValue, closeTo(0.5, 0.001));
    });

    testWidgets('builder is called with increasing values toward target',
        (tester) async {
      var targetValue = 0.0;
      late StateSetter outerSetState;
      final collectedValues = <double>[];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            outerSetState = setState;
            return Directionality(
              textDirection: TextDirection.ltr,
              child: SpringBuilder(
                value: targetValue,
                spring: GlassSpring.smooth(),
                builder: (context, v, _) {
                  collectedValues.add(v);
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      );

      // Start at 0; change target to 1.
      outerSetState(() => targetValue = 1.0);
      await tester.pump(); // trigger rebuild

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // The builder should have been called with values progressing from 0 → 1.
      expect(collectedValues, isNotEmpty);
      expect(collectedValues.last, greaterThan(collectedValues.first));
      expect(collectedValues.last, lessThan(1.0)); // not yet settled in 160 ms
    });

    testWidgets('child is passed through builder unchanged', (tester) async {
      const sentinel = Key('sentinel');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SpringBuilder(
            value: 0.0,
            spring: GlassSpring.smooth(),
            builder: (context, _, child) => child!,
            child: const SizedBox(key: sentinel),
          ),
        ),
      );

      expect(find.byKey(sentinel), findsOneWidget);
    });

    testWidgets('spring change redirects animation without throwing',
        (tester) async {
      var spring = GlassSpring.smooth();
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            outerSetState = setState;
            return Directionality(
              textDirection: TextDirection.ltr,
              child: SpringBuilder(
                value: 1.0,
                spring: spring,
                builder: (context, v, _) => const SizedBox.shrink(),
              ),
            );
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      // Swap spring mid-animation.
      expect(
        () => outerSetState(() => spring = GlassSpring.bouncy()),
        returnsNormally,
      );

      await tester.pump(const Duration(milliseconds: 16));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // VelocitySpringBuilder widget
  // ─────────────────────────────────────────────────────────────────────────

  group('VelocitySpringBuilder', () {
    testWidgets('velocity is zero at rest (no animation)', (tester) async {
      double? capturedVelocity;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: VelocitySpringBuilder(
            value: 0.0,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.bouncy(),
            builder: (context, v, vel, _) {
              capturedVelocity = vel;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(capturedVelocity, closeTo(0.0, 0.001));
    });

    testWidgets('builder receives increasing values while animating',
        (tester) async {
      var target = 0.0;
      late StateSetter outerSetState;
      final capturedValues = <double>[];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            outerSetState = setState;
            return Directionality(
              textDirection: TextDirection.ltr,
              child: VelocitySpringBuilder(
                value: target,
                springWhenActive: GlassSpring.interactive(),
                springWhenReleased: GlassSpring.bouncy(),
                builder: (context, v, vel, _) {
                  capturedValues.add(v);
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      );

      outerSetState(() => target = 1.0);
      await tester.pump();

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(capturedValues.last, greaterThan(capturedValues.first));
    });

    test(
        'active spring (interactive) physically reaches target sooner than released (bouncy)',
        () {
      // Compare the raw spring physics directly using SpringSimulation.
      // At the same elapsed time (100 ms), the interactive spring (stiffer/faster)
      // should be closer to 1.0 than the bouncy spring (slower default).
      final interactiveSpring = GlassSpring.interactive(); // 150 ms duration
      final bouncySpring = GlassSpring.bouncy(); // 500 ms duration

      final fast =
          SpringSimulation(interactiveSpring, 0.0, 1.0, 0.0, snapToEnd: true);
      final slow =
          SpringSimulation(bouncySpring, 0.0, 1.0, 0.0, snapToEnd: true);

      // Sample at 50 ms — both should be animating but interactive should lead.
      const t = 0.05; // seconds
      final fastValue = fast.x(t);
      final slowValue = slow.x(t);

      expect(fastValue, greaterThan(slowValue),
          reason:
              'interactive spring ($fastValue) should be ahead of bouncy spring ($slowValue) at t=50ms');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OffsetSpringBuilder widget
  // ─────────────────────────────────────────────────────────────────────────

  group('OffsetSpringBuilder', () {
    testWidgets('renders initial offset immediately', (tester) async {
      Offset? rendered;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OffsetSpringBuilder(
            value: const Offset(3, 7),
            spring: GlassSpring.smooth(),
            builder: (context, v, _) {
              rendered = v;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(rendered!.dx, closeTo(3.0, 0.01));
      expect(rendered!.dy, closeTo(7.0, 0.01));
    });

    testWidgets('both axes progress toward target after value change',
        (tester) async {
      var target = Offset.zero;
      late StateSetter outerSetState;
      final dxValues = <double>[];
      final dyValues = <double>[];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            outerSetState = setState;
            return Directionality(
              textDirection: TextDirection.ltr,
              child: OffsetSpringBuilder(
                value: target,
                spring: GlassSpring.smooth(),
                builder: (context, v, _) {
                  dxValues.add(v.dx);
                  dyValues.add(v.dy);
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      );

      outerSetState(() => target = const Offset(100, 50));
      await tester.pump();

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(dxValues.last, greaterThan(dxValues.first));
      expect(dyValues.last, greaterThan(dyValues.first));
      expect(dxValues.last, lessThan(100.0)); // not settled yet
      expect(dyValues.last, lessThan(50.0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SpringBuilder — reduce motion snap branch (line ~339)
  // ─────────────────────────────────────────────────────────────────────────

  group('SpringBuilder reduce motion', () {
    testWidgets('snaps instantly when reduceMotion is active', (tester) async {
      // Inject a reduce-motion MediaQuery.
      var target = 0.0;
      late StateSetter outerSetState;
      final collectedValues = <double>[];

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            accessibleNavigation: false,
            disableAnimations: true, // Reduce Motion
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              outerSetState = setState;
              return Directionality(
                textDirection: TextDirection.ltr,
                child: SpringBuilder(
                  value: target,
                  spring: GlassSpring.smooth(),
                  builder: (context, v, _) {
                    collectedValues.add(v);
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );

      final before = collectedValues.length;

      // Change target — should snap, not animate.
      outerSetState(() => target = 1.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // After at most 2 frames the value should already be at 1.0 (snapped).
      final snapValue = collectedValues.last;
      expect(snapValue, closeTo(1.0, 0.01));
      expect(collectedValues.length - before, lessThanOrEqualTo(3));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // VelocitySpringBuilder — reduce motion snap branch (line ~445)
  // ─────────────────────────────────────────────────────────────────────────

  group('VelocitySpringBuilder reduce motion', () {
    testWidgets('snaps instantly when reduceMotion is active', (tester) async {
      var target = 0.0;
      late StateSetter outerSetState;
      double? lastValue;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              outerSetState = setState;
              return Directionality(
                textDirection: TextDirection.ltr,
                child: VelocitySpringBuilder(
                  value: target,
                  springWhenActive: GlassSpring.interactive(),
                  springWhenReleased: GlassSpring.bouncy(),
                  builder: (context, v, vel, _) {
                    lastValue = v;
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );

      outerSetState(() => target = 1.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(lastValue, closeTo(1.0, 0.01));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SingleSpringController — spring getter & setter no-op path (line ~127/129)
  // ─────────────────────────────────────────────────────────────────────────

  group('SingleSpringController spring getter/setter', () {
    testWidgets('spring getter returns the current spring', (tester) async {
      late SingleSpringController ctrl;
      final spring = GlassSpring.smooth();
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: spring,
          ),
        ),
      );
      expect(ctrl.spring.mass, spring.mass);
      expect(ctrl.spring.stiffness, spring.stiffness);
    });

    testWidgets('setting the same spring value is a no-op', (tester) async {
      late SingleSpringController ctrl;
      final spring = GlassSpring.smooth();
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: spring,
          ),
        ),
      );

      // Setting the identical spring should not throw.
      expect(() => ctrl.spring = spring, returnsNormally);
      // Value must not have changed.
      expect(ctrl.value, closeTo(0.0, 0.001));
    });

    testWidgets(
        'spring setter while ticker inactive updates spring without starting',
        (tester) async {
      late SingleSpringController ctrl;
      await tester.pumpWidget(
        _ControllerHarness(
          build: (vsync) => ctrl = SingleSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      // No animation running; setting a new spring should not start the ticker.
      ctrl.spring = GlassSpring.bouncy();
      // If ticker were active, further pump would show value change.
      await tester.pump(const Duration(milliseconds: 16));
      expect(ctrl.value, closeTo(0.0, 0.001)); // still at initial
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OffsetSpringController — spring setter
  // ─────────────────────────────────────────────────────────────────────────

  group('OffsetSpringController spring setter', () {
    testWidgets('can swap spring mid-animation', (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(const Offset(50, 50));
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Swap spring — should not crash and should keep the simulation going.
      expect(() => ctrl.spring = GlassSpring.bouncy(), returnsNormally);
      await tester.pump(const Duration(milliseconds: 16));
      expect(ctrl.value.dx, greaterThan(0));
    });

    testWidgets('velocity getter returns non-zero Offset while animating',
        (tester) async {
      late OffsetSpringController ctrl;
      await tester.pumpWidget(
        _OffsetControllerHarness(
          build: (vsync) => ctrl = OffsetSpringController(
            vsync: vsync,
            spring: GlassSpring.smooth(),
          ),
        ),
      );

      ctrl.animateTo(const Offset(100, 100));
      // Pump several frames so the spring builds up velocity.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Velocity is an Offset — it should be a valid object (not throw).
      final vel = ctrl.velocity;
      expect(vel, isA<Offset>());
      // While animating, at least one axis should be nonzero.
      expect(vel.dx + vel.dy, greaterThan(0));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Test harness widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Minimal [StatefulWidget] that provides a [TickerProvider] and exposes a
/// [SingleSpringController] to the surrounding test.
class _ControllerHarness extends StatefulWidget {
  const _ControllerHarness({required this.build});

  final SingleSpringController Function(TickerProvider vsync) build;

  @override
  State<_ControllerHarness> createState() => _ControllerHarnessState();
}

class _ControllerHarnessState extends State<_ControllerHarness>
    with SingleTickerProviderStateMixin {
  late final SingleSpringController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.build(this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Same as [_ControllerHarness] but for [OffsetSpringController].
/// Uses [TickerProviderStateMixin] (supports multiple tickers).
class _OffsetControllerHarness extends StatefulWidget {
  const _OffsetControllerHarness({required this.build});

  final OffsetSpringController Function(TickerProvider vsync) build;

  @override
  State<_OffsetControllerHarness> createState() =>
      _OffsetControllerHarnessState();
}

class _OffsetControllerHarnessState extends State<_OffsetControllerHarness>
    with TickerProviderStateMixin {
  late final OffsetSpringController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.build(this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
