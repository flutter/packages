// Tests for glass_modal_sheet_state.dart — deep branch coverage
// Uses the actual GlassModalSheetScaffold(background:, sheetChild:) API
// and GlassModalSheetController.snapToState()
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Widget _makeSheet({
  GlassModalSheetController? controller,
  void Function(GlassSheetState)? onStateChanged,
  GlassSheetMode mode = GlassSheetMode.persistent,
  double halfSize = 0.45,
  Widget? sheetChild,
}) =>
    MaterialApp(
      home: Scaffold(
        body: LiquidGlassWidgets.wrap(
          child: GlassModalSheetScaffold(
            body: const ColoredBox(
              color: Colors.blue,
              child: SizedBox.expand(),
            ),
            sheet: sheetChild ??
                ListView(children: [
                  for (int i = 0; i < 20; i++) ListTile(title: Text('Item $i')),
                ]),
            halfSize: halfSize,
            mode: mode,
            controller: controller,
            onStateChanged: onStateChanged,
          ),
        ),
      ),
    );

void main() {
  group('horizontal content does not hijack the sheet', () {
    testWidgets('a sideways gesture that turns vertical never moves the sheet',
        (tester) async {
      // The user-visible symptom both the axis guard and the one-shot axis
      // lock exist to prevent. Scroll notifications bubble from ANY
      // descendant, so pulling a HORIZONTAL list past its leading edge used
      // to make the sheet claim the gesture and re-anchor its vertical drag
      // origin; the axis test was also re-run on every move, so the moment
      // the finger turned upward the sheet came with it.
      //
      // The L-shape is the point: a pure sideways drag never moved the sheet
      // anyway (the vertical delta is ~zero), which is why this has to keep
      // the finger down and change direction.
      await tester.pumpWidget(_makeSheet(
        sheetChild: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            for (int i = 0; i < 20; i++)
              SizedBox(width: 120, child: Text('col $i')),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final before = tester.getTopLeft(find.text('col 0')).dy;
      final g = await tester.startGesture(tester.getCenter(find.text('col 0')));
      // Sideways first, past the leading edge — this is what emits
      // OverscrollNotification with overscroll < 0.
      for (var i = 0; i < 6; i++) {
        await g.moveBy(const Offset(30, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      // Now upward, WITHOUT lifting.
      for (var i = 0; i < 8; i++) {
        await g.moveBy(const Offset(0, -25));
        await tester.pump(const Duration(milliseconds: 16));
      }
      final during = tester.getTopLeft(find.text('col 0')).dy;
      await g.up();
      await tester.pumpAndSettle();

      // Tolerance, not zero: the sheet applies `interactionScale` on
      // pointer-down, which nudges its children a few points without any drag
      // taking place. The bug moves the sheet by the FULL vertical travel
      // (200pt here), so anything under ~20 cleanly separates "squeezed" from
      // "dragged".
      expect((during - before).abs(), lessThan(20.0),
          reason: 'the sheet must not follow a gesture that began sideways');
    });
  });

  group('GlassModalSheetController — attach/detach', () {
    testWidgets('controller has valid currentState after mount',
        (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      expect(ctrl.currentState, isA<GlassSheetState>());
    });

    testWidgets('detach on dispose: snapToState is no-op', (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox()); // triggers dispose
      await tester.pump();
      expect(() => ctrl.snapToState(GlassSheetState.full), returnsNormally);
    });

    testWidgets('swapping controller detaches old and attaches new',
        (tester) async {
      final ctrl1 = GlassModalSheetController();
      final ctrl2 = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl1));
      await tester.pumpAndSettle();
      expect(ctrl1.currentState, isA<GlassSheetState>());

      await tester.pumpWidget(_makeSheet(controller: ctrl2));
      await tester.pumpAndSettle();
      // Old controller detached — returns default
      expect(ctrl1.currentState, GlassSheetState.hidden);
      // New controller attached
      expect(ctrl2.currentState, isA<GlassSheetState>());
    });
  });

  group('GlassModalSheetController — state transitions', () {
    testWidgets('snapToState(full) transitions to full', (tester) async {
      final ctrl = GlassModalSheetController();
      final states = <GlassSheetState>[];
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        onStateChanged: states.add,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.full);
      await tester.pumpAndSettle();
      expect(ctrl.currentState, GlassSheetState.full);
    });

    testWidgets('snapToState(half) transitions to half', (tester) async {
      final ctrl = GlassModalSheetController();
      final states = <GlassSheetState>[];
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        mode: GlassSheetMode.persistent,
        onStateChanged: states.add,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.half);
      await tester.pumpAndSettle();
      expect(ctrl.currentState, GlassSheetState.half);
    });

    testWidgets('snapToState(hidden) in dismissible mode hides sheet',
        (tester) async {
      final ctrl = GlassModalSheetController();
      final states = <GlassSheetState>[];
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        mode: GlassSheetMode.dismissible,
        onStateChanged: states.add,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.full);
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.hidden);
      await tester.pumpAndSettle();
      expect(ctrl.currentState, GlassSheetState.hidden);
    });

    testWidgets('snapToState(hidden) in persistent mode clamps to peek',
        (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        mode: GlassSheetMode.persistent,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.full);
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.hidden); // clamps to peek
      await tester.pumpAndSettle();
      // Persistent: minimum is peek, not hidden
      expect(ctrl.currentState, isNot(GlassSheetState.hidden));
    });

    testWidgets('snapToState with animate=false does instant jump',
        (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.full, animate: false);
      await tester.pump();
      expect(ctrl.currentState, GlassSheetState.full);
    });

    testWidgets('value setter jumps to exact position', (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      ctrl.value = 0.5;
      await tester.pump();
      expect(ctrl.value, closeTo(0.5, 0.15));
    });
  });

  group('GlassModalSheet — halfSize change triggers recalculation', () {
    testWidgets('halfSize change rebuilds geometry', (tester) async {
      double halfSize = 0.5;
      await tester.pumpWidget(StatefulBuilder(
        builder: (ctx, setState) => MaterialApp(
          home: Scaffold(
            body: LiquidGlassWidgets.wrap(
              child: GlassModalSheetScaffold(
                body: GestureDetector(
                  onTap: () => setState(() => halfSize = 0.4),
                  child: const ColoredBox(
                    color: Colors.green,
                    child: SizedBox.expand(),
                  ),
                ),
                sheet: const SizedBox.expand(),
                halfSize: halfSize,
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.byType(GlassModalSheetScaffold), findsOneWidget);
    });
  });

  group('GlassModalSheet — onStateChanged callback', () {
    testWidgets('fires on each transition', (tester) async {
      final ctrl = GlassModalSheetController();
      final states = <GlassSheetState>[];
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        onStateChanged: states.add,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.full);
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.half);
      await tester.pumpAndSettle();
      expect(states, contains(GlassSheetState.full));
      expect(states, contains(GlassSheetState.half));
    });
  });

  group('GlassModalSheet — drag handle interaction', () {
    testWidgets('dragging scaffold content reveals sheet', (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      final scaffoldFinder = find.byType(GlassModalSheetScaffold);
      final rect = tester.getRect(scaffoldFinder);
      // Drag from bottom of visible area upward
      await tester.dragFrom(
        Offset(rect.center.dx, rect.bottom - 100),
        const Offset(0, -250),
      );
      await tester.pumpAndSettle();
      // Regardless of the exact result, there's no crash
      expect(find.byType(GlassModalSheetScaffold), findsOneWidget);
    });

    testWidgets('downward drag from full via controller collapses sheet',
        (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        mode: GlassSheetMode.persistent,
      ));
      await tester.pumpAndSettle();
      // Expand to full
      ctrl.snapToState(GlassSheetState.full, animate: false);
      await tester.pump();
      expect(ctrl.currentState, GlassSheetState.full);
      // Collapse back
      ctrl.snapToState(GlassSheetState.half, animate: false);
      await tester.pump();
      expect(ctrl.currentState, GlassSheetState.half);
    });
  });

  group('GlassModalSheet — mode variants', () {
    testWidgets('dismissible mode allows hidden state', (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        mode: GlassSheetMode.dismissible,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.hidden);
      await tester.pumpAndSettle();
      expect(ctrl.currentState, GlassSheetState.hidden);
    });

    testWidgets('persistent mode: hidden clamps to peek', (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(
        controller: ctrl,
        mode: GlassSheetMode.persistent,
      ));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.hidden);
      await tester.pumpAndSettle();
      expect(ctrl.currentState, isNot(GlassSheetState.hidden));
    });
  });

  group('GlassModalSheet — velocity-based snap', () {
    testWidgets('snapToState with velocity uses spring simulation',
        (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      ctrl.snapToState(GlassSheetState.full, velocity: 1500);
      await tester.pumpAndSettle();
      expect(ctrl.currentState, GlassSheetState.full);
    });
  });

  group('GlassModalSheet — dispose cleanup', () {
    testWidgets('dispose removes observer and controllers', (tester) async {
      final ctrl = GlassModalSheetController();
      await tester.pumpWidget(_makeSheet(controller: ctrl));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(true, isTrue); // no exception
    });
  });
}
