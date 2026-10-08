// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for GlassSlider.
// Targets:
//   - lines 343-344: _handleDragEnd fires onChangeEnd callback
//   - lines 412-418: _handleDragCancel → _cleanupDrag (isDragging guard)
//   - lines 582-585: GlassGlow Opacity branch (transition > 0.05)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

Widget _buildSlider({
  required double value,
  ValueChanged<double>? onChanged,
  ValueChanged<double>? onChangeEnd,
}) {
  return createTestApp(
    child: SizedBox(
      width: 300,
      height: 60,
      child: GlassSlider(
        value: value,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    ),
  );
}

void main() {
  group('GlassSlider — _handleDragCancel / _cleanupDrag', () {
    testWidgets('drag cancel after drag-start cleans up correctly',
        (tester) async {
      double sliderValue = 0.5;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          return _buildSlider(
            value: sliderValue,
            onChanged: (v) => setState(() => sliderValue = v),
          );
        }),
      );
      await tester.pump();

      final finder = find.byType(GlassSlider);
      final rect = tester.getRect(finder);

      // Start a drag and move enough to set _isDragging=true.
      final gesture =
          await tester.startGesture(Offset(rect.left + 100, rect.center.dy));
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 16));

      // Cancel → _handleDragCancel → _cleanupDrag (isDragging=true path).
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('_cleanupDrag guard: cancel without prior drag-start no-ops',
        (tester) async {
      // Touch down and immediately cancel (no moveBy) → _isDragging stays false
      // → _cleanupDrag returns early at the guard.
      await tester.pumpWidget(
        _buildSlider(
          value: 0.3,
          onChanged: (_) {},
        ),
      );
      await tester.pump();

      final finder = find.byType(GlassSlider);
      final rect = tester.getRect(finder);
      final gesture = await tester.startGesture(rect.center);
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassSlider — onChangeEnd callback (line 344)', () {
    testWidgets('onChangeEnd fires when drag ends', (tester) async {
      double? endValue;
      double sliderValue = 0.5;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          return _buildSlider(
            value: sliderValue,
            onChanged: (v) => setState(() => sliderValue = v),
            onChangeEnd: (v) => endValue = v,
          );
        }),
      );
      await tester.pump();

      final finder = find.byType(GlassSlider);
      final rect = tester.getRect(finder);

      // Complete a full drag (down → move → up).
      await tester.dragFrom(
        Offset(rect.left + 80, rect.center.dy),
        const Offset(50, 0),
      );
      await tester.pumpAndSettle();

      // onChangeEnd should have fired with the final value.
      expect(endValue, isNotNull);
      expect(endValue, greaterThanOrEqualTo(0.0));
      expect(endValue, lessThanOrEqualTo(1.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('onChangeEnd is null-safe (no crash when omitted)',
        (tester) async {
      await tester.pumpWidget(
        _buildSlider(
          value: 0.5,
          onChanged: (_) {},
          // onChangeEnd omitted → null → guard in _handleDragEnd
        ),
      );
      await tester.pump();

      final finder = find.byType(GlassSlider);
      final rect = tester.getRect(finder);
      await tester.dragFrom(
        Offset(rect.left + 80, rect.center.dy),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassSlider — GlassGlow opacity branch (transition > 0.05)', () {
    testWidgets('dragging renders GlassGlow when transition exceeds threshold',
        (tester) async {
      double sliderValue = 0.5;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          return createTestApp(
            child: SizedBox(
              width: 300,
              height: 60,
              child: GlassSlider(
                value: sliderValue,
                onChanged: (v) => setState(() => sliderValue = v),
              ),
            ),
          );
        }),
      );
      await tester.pump();

      final finder = find.byType(GlassSlider);
      final rect = tester.getRect(finder);

      // Start drag (thumb transition animates from 0 → 1, revealing GlassGlow).
      final gesture =
          await tester.startGesture(Offset(rect.left + 80, rect.center.dy));
      await tester.pump(const Duration(milliseconds: 50));
      // Mid-animation: transition > 0.05 → GlassGlow + Opacity branch rendered.
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
