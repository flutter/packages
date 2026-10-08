// Tests for the touch-noise guards and continuous drag in GlassDragBuilder.
//
// Regression tests for:
//   1. Hold-shake: sub-pixel digitizer noise during stationary press must not
//      trigger rebuilds or matrix updates.
//   2. Movement jitter: pointer tracking must be continuous (C0 continuity
//      without 3px impulse jumps) and unquantized (no stairstep oscillation).

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/glass_drag_builder.dart';

void main() {
  group('GlassDragBuilder — latched continuous deadband', () {
    testWidgets(
        'builder receives Offset.zero (not null) during press with no movement',
        (tester) async {
      Offset? latestOffset = const Offset(99, 99); // sentinel

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GlassDragBuilder(
            builder: (context, offset, child) {
              latestOffset = offset;
              return const SizedBox(width: 200, height: 200);
            },
          ),
        ),
      );

      final center = tester.getCenter(find.byType(SizedBox));
      await tester.pump();
      expect(latestOffset, isNull);

      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(latestOffset, equals(Offset.zero));

      await gesture.up();
      await tester.pump();
      expect(latestOffset, isNull);
    });

    testWidgets(
        'sub-pixel jitter below 3 px triggers ZERO rebuilds while pressed',
        (tester) async {
      var buildCount = 0;
      final captured = <Offset?>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GlassDragBuilder(
            builder: (context, offset, child) {
              buildCount++;
              captured.add(offset);
              return const SizedBox(width: 200, height: 200);
            },
          ),
        ),
      );

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      final initialBuildCount = buildCount;

      // Realistic digitizer noise: cumulative magnitude stays well under 3 px.
      for (final delta in [
        const Offset(0.4, -0.3),
        const Offset(-0.5, 0.6),
        const Offset(0.3, -0.2),
        const Offset(0.2, 0.4),
      ]) {
        await gesture.moveBy(delta);
        await tester.pump();
      }

      // Assert zero rebuilds occurred during all jitter events:
      expect(buildCount, equals(initialBuildCount),
          reason:
              'Movements within deadband must bypass setState to completely '
              'eliminate raster crawl on hairline borders.');

      await gesture.up();
      await tester.pump();
    });

    testWidgets(
        'intentional drag breaks deadband with continuous slop subtraction',
        (tester) async {
      Offset? latestOffset;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GlassDragBuilder(
            builder: (context, offset, child) {
              latestOffset = offset;
              return const SizedBox(width: 200, height: 200);
            },
          ),
        ),
      );

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Move by exactly 20 px along X.
      // Expected exposed offset is slop-subtracted: (20 - 3) = 17 px.
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();

      expect(latestOffset, isNotNull);
      expect(latestOffset!.dx, closeTo(17.0, 0.001),
          reason:
              'Exposed offset should continuously subtract touch slop (20 - 3 = 17).');
      expect(latestOffset!.dy, closeTo(0.0, 0.001));

      await gesture.up();
    });

    testWidgets(
        'drag crossing deadband starts smoothly from zero with no impulse jump',
        (tester) async {
      Offset? latestOffset;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GlassDragBuilder(
            builder: (context, offset, child) {
              latestOffset = offset;
              return const SizedBox(width: 200, height: 200);
            },
          ),
        ),
      );

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Move just past the 3.0 px threshold (e.g. 3.1 px).
      // With continuous slop subtraction: 3.1 * (1 - 3.0 / 3.1) = 0.1 px.
      // Without slop subtraction it would jump by 3.1 px!
      await gesture.moveBy(const Offset(3.1, 0));
      await tester.pump();

      expect(latestOffset, isNotNull);
      expect(latestOffset!.dx, closeTo(0.1, 0.01),
          reason:
              'At threshold crossing, motion must begin smoothly near 0 without a 3 px impulse jump.');

      await gesture.up();
    });

    testWidgets('latched drag remains engaged when moving back towards center',
        (tester) async {
      Offset? latestOffset;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GlassDragBuilder(
            builder: (context, offset, child) {
              latestOffset = offset;
              return const SizedBox(width: 200, height: 200);
            },
          ),
        ),
      );

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Engage drag by moving 10 px.
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump();
      expect(latestOffset!.dx, closeTo(7.0, 0.001));

      // Move back towards center to 2 px from origin (which is < 3 px).
      await gesture.moveBy(const Offset(-8, 0));
      await tester.pump();

      // Latched state means it smoothly clamps to Offset.zero near center,
      // without flapping or jumping.
      expect(latestOffset, equals(Offset.zero));

      // Drag through center to the other side (-10 px from origin).
      await gesture.moveBy(const Offset(-12, 0));
      await tester.pump();
      expect(latestOffset!.dx, closeTo(-7.0, 0.001));

      await gesture.up();
    });

    testWidgets('offset resets to null after pointer up', (tester) async {
      Offset? latestOffset;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GlassDragBuilder(
            builder: (context, offset, child) {
              latestOffset = offset;
              return const SizedBox(width: 200, height: 200);
            },
          ),
        ),
      );

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();

      expect(latestOffset, isNotNull);

      await gesture.up();
      await tester.pump();
      expect(latestOffset, isNull);
    });
  });
}
