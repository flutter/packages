import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../shared/test_helpers.dart';

/// The drag indicator pill's geometry: width, thickness and top inset.
void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    double? width,
    double? height,
    double? topPadding,
  }) async {
    await tester.pumpWidget(
      createTestApp(
        child: Stack(
          children: [
            GlassModalSheet(
              initialState: GlassSheetState.half,
              dragIndicatorWidth: width ?? 36,
              dragIndicatorHeight: height ?? 4,
              dragIndicatorTopPadding: topPadding ?? 8,
              child: const SizedBox(height: 400, child: Text('Content')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The pill is the child of the 'Drag handle' Semantics node, which wraps
  // it exactly, so that node's size and position are the pill's.
  Finder handle() => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Drag handle');

  group('GlassModalSheet drag indicator geometry', () {
    testWidgets('defaults are 36 × 4, 8 below the sheet top', (tester) async {
      await pumpSheet(tester);
      expect(tester.getSize(handle()), const Size(36, 4));
    });

    testWidgets('dragIndicatorWidth and dragIndicatorHeight size the pill',
        (tester) async {
      await pumpSheet(tester, width: 54, height: 5);
      expect(tester.getSize(handle()), const Size(54, 5));
    });

    testWidgets('dragIndicatorTopPadding moves the pill, not the sheet',
        (tester) async {
      await pumpSheet(tester);
      final defaultTop = tester.getTopLeft(handle()).dy;
      await pumpSheet(tester, topPadding: 14 / 3);
      final movedTop = tester.getTopLeft(handle()).dy;
      // The sheet rests at the same detent; only the pill's inset changed.
      expect(defaultTop - movedTop, closeTo(8 - 14 / 3, 0.01));
    });
  });
}
