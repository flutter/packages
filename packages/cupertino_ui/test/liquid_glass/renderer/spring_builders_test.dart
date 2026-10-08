import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/utils/glass_spring.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // VelocitySpringBuilder
  // ──────────────────────────────────────────────────────────────────────────

  group('VelocitySpringBuilder', () {
    testWidgets('renders initial value', (tester) async {
      double? lastValue;
      double? lastVelocity;

      await tester.pumpWidget(
        MaterialApp(
          home: VelocitySpringBuilder(
            value: 0.5,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.bouncy(),
            builder: (context, value, velocity, child) {
              lastValue = value;
              lastVelocity = velocity;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(lastValue, closeTo(0.5, 0.001));
      expect(lastVelocity, isNotNull);
    });

    testWidgets('animates toward new value when value changes', (tester) async {
      double renderedValue = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: VelocitySpringBuilder(
            value: 0.0,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.smooth(),
            builder: (context, value, velocity, child) {
              renderedValue = value;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: VelocitySpringBuilder(
            value: 1.0,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.smooth(),
            builder: (context, value, velocity, child) {
              renderedValue = value;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 250));
      expect(renderedValue, greaterThan(0.0));
    });

    testWidgets('spring switches when active changes', (tester) async {
      Widget buildWidget({required bool active}) => MaterialApp(
            home: VelocitySpringBuilder(
              value: 0.5,
              springWhenActive: GlassSpring.interactive(),
              springWhenReleased: GlassSpring.smooth(),
              active: active,
              builder: (context, value, velocity, child) =>
                  const SizedBox.shrink(),
            ),
          );

      await tester.pumpWidget(buildWidget(active: true));
      await tester.pump();
      await tester.pumpWidget(buildWidget(active: false));
      await tester.pump();
    });

    testWidgets('spring param changes redirect simulation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VelocitySpringBuilder(
            value: 1.0,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.bouncy(),
            builder: (context, value, velocity, child) =>
                const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: VelocitySpringBuilder(
            value: 1.0,
            springWhenActive: GlassSpring.snappy(),
            springWhenReleased: GlassSpring.smooth(),
            builder: (context, value, velocity, child) =>
                const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();
    });

    testWidgets('disposes cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VelocitySpringBuilder(
            value: 0.0,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.smooth(),
            builder: (context, value, velocity, child) =>
                const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // OffsetSpringBuilder
  // ──────────────────────────────────────────────────────────────────────────

  group('OffsetSpringBuilder', () {
    testWidgets('renders initial offset value', (tester) async {
      Offset? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: OffsetSpringBuilder(
            value: const Offset(10, 20),
            spring: GlassSpring.smooth(),
            builder: (context, value, child) {
              lastValue = value;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(lastValue, isNotNull);
      expect(lastValue!.dx, closeTo(10, 0.1));
      expect(lastValue!.dy, closeTo(20, 0.1));
    });

    testWidgets('animates toward new offset value', (tester) async {
      Offset latestValue = Offset.zero;

      Widget build(Offset val) => MaterialApp(
            home: OffsetSpringBuilder(
              value: val,
              spring: GlassSpring.bouncy(),
              builder: (context, value, child) {
                latestValue = value;
                return const SizedBox.shrink();
              },
            ),
          );

      await tester.pumpWidget(build(Offset.zero));
      await tester.pumpWidget(build(const Offset(50, 50)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(latestValue.dx, greaterThan(0));
    });

    testWidgets('spring change redirects simulation', (tester) async {
      Widget build(SpringDescription spring) => MaterialApp(
            home: OffsetSpringBuilder(
              value: const Offset(100, 0),
              spring: spring,
              builder: (context, value, child) => const SizedBox.shrink(),
            ),
          );

      await tester.pumpWidget(build(GlassSpring.smooth()));
      await tester.pump();
      await tester.pumpWidget(build(GlassSpring.bouncy()));
      await tester.pump();
    });

    testWidgets('disposes cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OffsetSpringBuilder(
            value: const Offset(5, 5),
            spring: GlassSpring.smooth(),
            builder: (context, value, child) => const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // SpringBuilder — additional branch coverage
  // ──────────────────────────────────────────────────────────────────────────

  group('SpringBuilder additional branches', () {
    testWidgets('spring change while ticking redirects smoothly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpringBuilder(
            value: 1.0,
            spring: GlassSpring.bouncy(),
            builder: (context, value, child) => const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(
        MaterialApp(
          home: SpringBuilder(
            value: 1.0,
            spring: GlassSpring.smooth(),
            builder: (context, value, child) => const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('child widget is passed through correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpringBuilder(
            value: 0.0,
            spring: GlassSpring.smooth(),
            builder: (context, value, child) =>
                child ?? const SizedBox.shrink(),
            child: const Text('spring child'),
          ),
        ),
      );

      expect(find.text('spring child'), findsOneWidget);
    });
  });
}
