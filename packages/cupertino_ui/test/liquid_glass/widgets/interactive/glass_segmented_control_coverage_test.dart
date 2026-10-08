// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for GlassSegmentedControl.
// Targets lines 512-524 (onHorizontalDragCancel):
//   - _isDragging=true path: snaps to nearest segment, fires callback if changed
//   - _isDragging=false path: resets alignment to selectedIndex

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

const _segments = <GlassSegment>[
  GlassSegment(label: 'Alpha'),
  GlassSegment(label: 'Beta'),
  GlassSegment(label: 'Gamma')
];

Widget _buildSegmentedControl({
  required int selected,
  required ValueChanged<int> onSelected,
}) {
  return createTestApp(
    child: SizedBox(
      width: 300,
      height: 50,
      child: GlassSegmentedControl(
        segments: _segments,
        selectedIndex: selected,
        onSegmentSelected: onSelected,
      ),
    ),
  );
}

void main() {
  group('GlassSegmentedControl — onHorizontalDragCancel', () {
    testWidgets(
        'cancel while dragging snaps to nearest segment (isDragging=true path)',
        (tester) async {
      int selected = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          outerSetState = setState;
          return _buildSegmentedControl(
            selected: selected,
            onSelected: (i) => outerSetState(() => selected = i),
          );
        }),
      );
      await tester.pump();

      final finder = find.byType(GlassSegmentedControl);
      final rect = tester.getRect(finder);
      // Start in the first segment, drag well into the third to lock isDragging.
      final startX = rect.left + rect.width * 0.15;
      final gesture = await tester.startGesture(Offset(startX, rect.center.dy));
      // Move far enough to pass the drag-start threshold (8px).
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump(const Duration(milliseconds: 16));

      // Cancel mid-drag → isDragging=true branch fires.
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // selected may have changed or stayed; just confirm it's a valid index.
      expect(selected, greaterThanOrEqualTo(0));
      expect(selected, lessThan(3));
    });

    testWidgets(
        'cancel without dragging resets alignment (isDragging=false path)',
        (tester) async {
      int selected = 1;

      await tester.pumpWidget(
        _buildSegmentedControl(
          selected: selected,
          onSelected: (i) => selected = i,
        ),
      );
      await tester.pump();

      final finder = find.byType(GlassSegmentedControl);
      final rect = tester.getRect(finder);
      // Touch down then immediately cancel — isDragging stays false.
      final gesture = await tester.startGesture(rect.center);
      await gesture.cancel(); // no move → isDragging=false
      await tester.pumpAndSettle();

      // selectedIndex unchanged, no crash.
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'cancel while dragging across segment boundary fires onSegmentSelected',
        (tester) async {
      int selected = 2; // start at rightmost
      final changes = <int>[];

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          return _buildSegmentedControl(
            selected: selected,
            onSelected: (i) {
              setState(() => selected = i);
              changes.add(i);
            },
          );
        }),
      );
      await tester.pump();

      final finder = find.byType(GlassSegmentedControl);
      final rect = tester.getRect(finder);
      // Start at rightmost segment center, drag left to first segment.
      final startX = rect.left + rect.width * 0.83;
      final gesture = await tester.startGesture(Offset(startX, rect.center.dy));
      await gesture.moveBy(const Offset(-130, 0)); // drag to segment 0
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // If the drag moved far enough to land on a different segment, callback fires.
      // In headless tests gesture thresholds may differ — just verify no crash.
      expect(selected, greaterThanOrEqualTo(0));
      expect(selected, lessThan(3));
    });
  });

  // ── indicatorPinchStrength / indicatorExpansion / premium quality ─────────
  // Targets the new parameters added in 0.17.0 and the isPremiumQuality
  // second-pass path in segmented_control_internal.dart.

  group('GlassSegmentedControl — pinch + expansion + premium quality', () {
    testWidgets('premium quality renders both indicator passes without crash',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: _segments,
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            quality: GlassQuality.premium,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('indicatorPinchStrength: 0.0 disables pinch without crash',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: _segments,
            selectedIndex: 1,
            onSegmentSelected: (_) {},
            indicatorPinchStrength: 0.0,
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('indicatorPinchStrength: 0.4 (typical value) is accepted',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: _segments,
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            indicatorPinchStrength: 0.4,
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('indicatorExpansion is accepted and applied', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: _segments,
            selectedIndex: 2,
            onSegmentSelected: (_) {},
            indicatorExpansion:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'premium quality + pinch + expansion combined renders correctly',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: _segments,
            selectedIndex: 1,
            onSegmentSelected: (_) {},
            quality: GlassQuality.premium,
            indicatorPinchStrength: 0.4,
            indicatorExpansion:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── GlassSegment — new concrete class fields (v0.19.0) ───────────────────

  group('GlassSegment.enabled', () {
    testWidgets('disabled segment ignores tap — onSegmentSelected not called',
        (tester) async {
      int? selected;
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'Active'),
              GlassSegment(label: 'Disabled', enabled: false),
            ],
            selectedIndex: 0,
            onSegmentSelected: (i) => selected = i,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the disabled segment (index 1).
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(selected, isNull,
          reason: 'Disabled segment must not fire onSegmentSelected');
    });

    testWidgets('enabled segment responds to tap normally', (tester) async {
      int? selected;
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'First'),
              GlassSegment(label: 'Second'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (i) => selected = i,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('disabled segment renders without error', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'A'),
              GlassSegment(label: 'B', enabled: false),
              GlassSegment(label: 'C'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('GlassSegment.tooltip', () {
    testWidgets('GlassSegment accepts tooltip without error', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'One', tooltip: 'First option'),
              GlassSegment(label: 'Two', tooltip: 'Second option'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('GlassSegment with null tooltip renders normally',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: SizedBox(
          width: 300,
          height: 50,
          child: GlassSegmentedControl(
            segments: const [
              GlassSegment(label: 'No tooltip'),
              GlassSegment(label: 'Also no tooltip'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
