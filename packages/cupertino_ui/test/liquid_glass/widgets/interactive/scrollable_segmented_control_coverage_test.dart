import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('ScrollableSegmentContent coverage', () {
    testWidgets('drags, taps, and scrolls in scrollable mode', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GlassSegmentedControl.scrollable(
                  segments:
                      List.generate(20, (i) => GlassSegment(label: 'Item $i')),
                  selectedIndex: selectedIndex,
                  onSegmentSelected: (i) {
                    setState(() => selectedIndex = i);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.byType(GlassSegmentedControl), findsOneWidget);

      // Scroll to the right
      await tester.drag(
          find.byType(GlassSegmentedControl), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap an item that is now visible
      await tester.tap(find.text('Item 10'));
      await tester.pumpAndSettle();
      expect(selectedIndex, 10);

      // Fast flick back
      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(1000, 0), 2000);
      await tester.pumpAndSettle();

      // Tap first item
      await tester.tap(find.text('Item 0'));
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);

      // Test programmatic scroll to right edge
      expect(tester.state(find.byType(GlassSegmentedControl)), isNotNull);
      // Try to exercise any hidden state properties if we needed
    });
  });
}
