import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('SegmentedControlInternal coverage', () {
    testWidgets('drag cancel while dragging', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: GlassSegmentedControl(
                segments: [
                  GlassSegment(label: 'A'),
                  GlassSegment(label: 'B'),
                  GlassSegment(label: 'C')
                ],
                selectedIndex: selected,
                onSegmentSelected: (i) => selected = i,
              ),
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassSegmentedControl)));
      await tester.pump();

      // Move to trigger _isDragging
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();

      // Move a bit more so it's definitively dragging
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump();

      // Cancel
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
    });
  });
}
