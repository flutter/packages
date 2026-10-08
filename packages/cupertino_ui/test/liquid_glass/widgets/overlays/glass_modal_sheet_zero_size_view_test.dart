// A sheet built while the window has no size — an app the system launched
// in the background for a push, before it was ever shown — must pick up the
// real size when it arrives and drag normally afterwards. It used to keep
// the zero for life and divide every drag by it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

const _content = Key('content');
const _screen = Size(1320, 2868);
const _dpr = 3.0;
const _halfSize = 500.0;
final _halfPosition = _halfSize / (_screen.height / _dpr);

Widget _sheetApp(
  GlassModalSheetController controller,
  List<GlassSheetState> log,
) =>
    createTestApp(
      child: Stack(
        children: [
          GlassModalSheet(
            controller: controller,
            initialState: GlassSheetState.hidden,
            detents: const {GlassSheetDetent.medium},
            halfSize: _halfSize,
            quality: GlassQuality.minimal,
            onStateChanged: log.add,
            child: const SizedBox(key: _content, height: 300),
          ),
        ],
      ),
    );

/// Builds the sheet on a 0×0 view, then sizes the view (the app coming to
/// the foreground) and opens the sheet to half.
Future<void> _pumpLaunchedInBackground(
  WidgetTester tester,
  GlassModalSheetController controller,
  List<GlassSheetState> log,
) async {
  tester.view.physicalSize = Size.zero;
  tester.view.devicePixelRatio = _dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_sheetApp(controller, log));
  await tester.pump(); // the sheet's post-frame size read sees 0×0
  tester.view.physicalSize = _screen;
  await tester.pump();
  controller.snapToState(GlassSheetState.half);
  await tester.pumpAndSettle();
  expect(controller.currentState, GlassSheetState.half);
  expect(controller.value, closeTo(_halfPosition, 0.001));
}

void main() {
  group('GlassModalSheet — built before the window has a size', () {
    testWidgets('a short upward drag settles back at half', (tester) async {
      final controller = GlassModalSheetController();
      final log = <GlassSheetState>[];
      await _pumpLaunchedInBackground(tester, controller, log);

      await tester.drag(find.byKey(_content), const Offset(0, -20));
      await tester.pumpAndSettle();

      expect(controller.value, closeTo(_halfPosition, 0.001));
      expect(controller.currentState, GlassSheetState.half);
      expect(log, [GlassSheetState.half]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an upward flick keeps a finite position', (tester) async {
      final controller = GlassModalSheetController();
      final log = <GlassSheetState>[];
      await _pumpLaunchedInBackground(tester, controller, log);

      await tester.fling(find.byKey(_content), const Offset(0, -40), 2000);
      await tester.pumpAndSettle();

      expect(controller.value.isFinite, isTrue);
      expect(controller.value, closeTo(_halfPosition, 0.001));
      expect(controller.currentState, GlassSheetState.half);
      expect(log, [GlassSheetState.half]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a long downward drag still dismisses', (tester) async {
      final controller = GlassModalSheetController();
      final log = <GlassSheetState>[];
      await _pumpLaunchedInBackground(tester, controller, log);

      // Frames between the moves and the release, as a finger gets.
      final gesture =
          await tester.startGesture(tester.getCenter(find.byKey(_content)));
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 360));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.value, closeTo(0.0, 0.001));
      expect(controller.currentState, GlassSheetState.hidden);
      expect(log, [GlassSheetState.half, GlassSheetState.hidden]);
      expect(tester.takeException(), isNull);
    });
  });
}
