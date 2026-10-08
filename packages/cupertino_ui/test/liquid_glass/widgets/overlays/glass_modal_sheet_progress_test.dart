// GlassModalSheetController.progress / progressListenable: live half↔full
// position reporting.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

Widget _sheetApp(GlassModalSheetController controller) => createTestApp(
      child: Stack(
        children: [
          GlassModalSheet(
            controller: controller,
            initialState: GlassSheetState.half,
            child: const Text('Sheet Content'),
          ),
        ],
      ),
    );

void main() {
  group('GlassModalSheetController — progress', () {
    test('unmounted controller reports progress 0.0', () {
      expect(GlassModalSheetController().progress, 0.0);
    });

    test('unmounted controller has a null progressListenable', () {
      expect(GlassModalSheetController().progressListenable, isNull);
    });

    testWidgets('mounted at half → progress 0.0, listenable non-null',
        (tester) async {
      final controller = GlassModalSheetController();
      await tester.pumpWidget(_sheetApp(controller));
      await tester.pumpAndSettle();

      expect(controller.currentState, GlassSheetState.half);
      expect(controller.progress, 0.0);
      expect(controller.progressListenable, isNotNull);
    });

    testWidgets('snap to full → progress 1.0', (tester) async {
      final controller = GlassModalSheetController();
      await tester.pumpWidget(_sheetApp(controller));
      await tester.pumpAndSettle();

      controller.snapToState(GlassSheetState.full, animate: false);
      await tester.pumpAndSettle();

      expect(controller.progress, 1.0);
    });

    testWidgets('progress is current inside its own listener', (tester) async {
      // A listener runs before the sheet rebuilds. It must still read the
      // position the sheet is moving to, not the one it last built at —
      // otherwise the final tick of any drag reports a frame too early.
      final controller = GlassModalSheetController();
      await tester.pumpWidget(_sheetApp(controller));
      await tester.pumpAndSettle();

      double? seen;
      void listener() => seen = controller.progress;
      controller.progressListenable!.addListener(listener);
      addTearDown(
          () => controller.progressListenable?.removeListener(listener));

      controller.snapToState(GlassSheetState.full, animate: false);
      expect(seen, 1.0, reason: 'the jump to full should read as 1.0 at once');
      await tester.pumpAndSettle();
      expect(controller.progress, 1.0);
    });

    testWidgets('snap back to half → progress returns to 0.0', (tester) async {
      final controller = GlassModalSheetController();
      await tester.pumpWidget(_sheetApp(controller));
      await tester.pumpAndSettle();

      controller.snapToState(GlassSheetState.full, animate: false);
      await tester.pumpAndSettle();
      controller.snapToState(GlassSheetState.half, animate: false);
      await tester.pumpAndSettle();

      expect(controller.progress, 0.0);
    });

    testWidgets(
        'progressListenable notifies during an animated snap and progress '
        'passes through intermediate values', (tester) async {
      final controller = GlassModalSheetController();
      await tester.pumpWidget(_sheetApp(controller));
      await tester.pumpAndSettle();

      var notifications = 0;
      var sawIntermediate = false;
      void listener() {
        notifications++;
        final p = controller.progress;
        if (p > 0.05 && p < 0.95) sawIntermediate = true;
      }

      controller.progressListenable!.addListener(listener);
      controller.snapToState(GlassSheetState.full, animate: true);
      await tester.pumpAndSettle();
      controller.progressListenable!.removeListener(listener);

      expect(notifications, greaterThan(0));
      expect(sawIntermediate, isTrue,
          reason: 'progress should report positions between the snaps '
              'while the sheet animates');
      expect(controller.progress, 1.0);
    });
  });
}
