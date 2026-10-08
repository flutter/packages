import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

/// Regression suite for the sheet ↔ content scroll handover.
///
/// Below its topmost detent an upward drag grows the sheet and the content
/// holds still; the moment the sheet tops out, the same unbroken gesture
/// continues as a content scroll, and reverses back the same way.
void main() {
  /// The sheet's vertical scrollable, re-resolved on every call.
  ///
  /// The [ScrollPosition] is replaced when the physics swap at the top detent,
  /// so a reference captured before the drag reports `0` for the rest of it.
  ScrollableState verticalScrollable(WidgetTester tester) {
    return tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((state) =>
            axisDirectionToAxis(state.axisDirection) == Axis.vertical);
  }

  double contentPixels(WidgetTester tester) =>
      verticalScrollable(tester).position.pixels;

  /// Moves [gesture] by [dy] in small steps, pumping between them, so the sheet
  /// and the content both see a continuous drag rather than one jump.
  Future<void> dragBy(
    WidgetTester tester,
    TestGesture gesture,
    double dy, {
    int steps = 12,
  }) async {
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(0, dy / steps));
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Widget buildSheet({
    required GlassModalSheetController controller,
    Set<GlassSheetDetent> detents = const {
      GlassSheetDetent.medium,
      GlassSheetDetent.large,
    },
    GlassSheetState initialState = GlassSheetState.half,
    bool ownController = false,
    bool withCarousel = false,
    ScrollController? contentController,
    ValueChanged<GlassSheetState>? onStateChanged,
  }) {
    return createTestApp(
      child: Stack(
        children: [
          GlassModalSheet(
            controller: controller,
            detents: detents,
            initialState: initialState,
            onStateChanged: onStateChanged,
            child: Builder(
              builder: (context) {
                final scroll = ScrollControllerProvider.of(context);
                return ListView.builder(
                  controller:
                      ownController ? contentController : scroll?.controller,
                  physics: ownController ? null : scroll?.physics,
                  itemCount: 120,
                  itemBuilder: (context, index) {
                    if (withCarousel && index == 0) {
                      return SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 30,
                          itemBuilder: (context, i) =>
                              SizedBox(width: 100, child: Text('Card $i')),
                        ),
                      );
                    }
                    return SizedBox(height: 56, child: Text('Item $index'));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  testWidgets('grows the sheet first, then scrolls content on the same drag',
      (tester) async {
    final controller = GlassModalSheetController();
    await tester.pumpWidget(buildSheet(controller: controller));
    await tester.pumpAndSettle();

    final startValue = controller.value;
    final gesture = await tester.startGesture(const Offset(400, 450));
    await tester.pump(const Duration(milliseconds: 16));

    // 1. Below the top detent the sheet grows and the content holds still.
    await dragBy(tester, gesture, -120);
    expect(controller.value, greaterThan(startValue),
        reason: 'the sheet should grow while the content holds still');
    expect(contentPixels(tester), 0.0,
        reason: 'content must not scroll below the top detent');

    // 2. Without lifting, the same finger carries on into a content scroll.
    await dragBy(tester, gesture, -420);
    expect(contentPixels(tester), greaterThan(100.0),
        reason: 'reaching the top detent should hand the drag to the content');

    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.currentState, GlassSheetState.full);
  });

  testWidgets(
      'the handover finishes the sheet\'s travel before the finger lifts',
      (tester) async {
    final states = <GlassSheetState>[];
    final controller = GlassModalSheetController();
    await tester.pumpWidget(
      buildSheet(controller: controller, onStateChanged: states.add),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(400, 450));
    await tester.pump(const Duration(milliseconds: 16));
    await dragBy(tester, gesture, -540);
    expect(contentPixels(tester), greaterThan(0.0),
        reason: 'the drag should have been handed to the content');

    // The handover happens at the top-detent THRESHOLD, short of the detent
    // itself, and this pointer's up will see a scroll rather than a drag —
    // so the sheet must finish the trip on its own, while the finger is
    // still down: it arrives at full, and says so, as the content starts to
    // scroll rather than when the finger eventually lifts.
    await tester.pump(const Duration(milliseconds: 600));
    expect(controller.progress, 1.0,
        reason: 'the sheet should complete its travel to the top detent');
    expect(states, contains(GlassSheetState.full),
        reason: 'arriving at full via the handover must be reported');

    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.currentState, GlassSheetState.full);
    expect(controller.progress, 1.0);
  });

  testWidgets('scrolls content back to its top before collapsing',
      (tester) async {
    final controller = GlassModalSheetController();
    await tester.pumpWidget(
      buildSheet(controller: controller, initialState: GlassSheetState.full),
    );
    await tester.pumpAndSettle();

    // Scroll the content away from its top first.
    final scrollGesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 16));
    await dragBy(tester, scrollGesture, -300);
    await scrollGesture.up();
    await tester.pumpAndSettle();
    expect(contentPixels(tester), greaterThan(0.0));
    expect(controller.currentState, GlassSheetState.full);

    // 3. One downward drag returns the content to its top, and only then does
    //    the sheet begin to collapse. Measured against how far the content
    //    actually travelled, so the assertion is about ordering rather than
    //    about any particular distance.
    final scrolled = contentPixels(tester);
    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 16));
    final valueBefore = controller.value;

    // Stop short of the content's top: the sheet must not have moved at all.
    await dragBy(tester, gesture, scrolled - 40);
    expect(contentPixels(tester), greaterThan(0.0));
    expect(controller.value, closeTo(valueBefore, 0.001),
        reason: 'the sheet must not collapse while the content can scroll');

    // Carry on through the top on the same pointer: the sheet takes over for
    // the remaining travel only. The drag anchors still describe the whole
    // gesture, so a sheet that resumed from them would jump by everything the
    // content had scrolled — here about `scrolled / 600` of the screen.
    await dragBy(tester, gesture, 100);
    expect(contentPixels(tester), 0.0,
        reason: 'the content should reach its top first');
    expect(controller.value, lessThan(valueBefore),
        reason: 'with the content at its top the sheet takes the remainder');

    final travelled = valueBefore - controller.value;
    expect(travelled, lessThan(0.25),
        reason: 'the sheet should follow the finger from where it took over, '
            'not jump by the distance the content scrolled');

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a single-detent sheet scrolls its content on the first drag',
      (tester) async {
    final controller = GlassModalSheetController();
    await tester.pumpWidget(
      buildSheet(
        controller: controller,
        detents: const {GlassSheetDetent.large},
        initialState: GlassSheetState.full,
      ),
    );
    await tester.pumpAndSettle();

    // 4. Its resting stop is also its top one, so there is nothing to grow
    //    into and the very first drag scrolls.
    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 16));
    await dragBy(tester, gesture, -200);
    expect(contentPixels(tester), greaterThan(100.0));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a horizontal scrollable is unaffected below the top detent',
      (tester) async {
    final controller = GlassModalSheetController();
    await tester.pumpWidget(
      buildSheet(controller: controller, withCarousel: true),
    );
    await tester.pumpAndSettle();

    final horizontal = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere(
            (s) => axisDirectionToAxis(s.axisDirection) == Axis.horizontal);
    expect(horizontal.position.pixels, 0.0);

    // 5. The sheet is at `medium`, where a vertical drag is frozen. The
    //    carousel shares none of that ambiguity and must still scroll.
    await tester.drag(find.text('Card 0'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    final after = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere(
            (s) => axisDirectionToAxis(s.axisDirection) == Axis.horizontal);
    expect(after.position.pixels, greaterThan(0.0));
    expect(controller.currentState, GlassSheetState.half,
        reason: 'a horizontal swipe must not move the sheet');
  });

  testWidgets('content on its own controller hands over the same way',
      (tester) async {
    final controller = GlassModalSheetController();
    final contentController = ScrollController();
    addTearDown(contentController.dispose);

    await tester.pumpWidget(buildSheet(
      controller: controller,
      ownController: true,
      contentController: contentController,
    ));
    await tester.pumpAndSettle();

    final startValue = controller.value;
    final gesture = await tester.startGesture(const Offset(400, 450));
    await tester.pump(const Duration(milliseconds: 16));

    // 6. A controller the sheet does not own is still observed, so the sheet
    //    grows first rather than the two moving together.
    await dragBy(tester, gesture, -120);
    expect(controller.value, greaterThan(startValue));
    expect(contentPixels(tester), 0.0,
        reason: 'foreign controllers must obey the same expand-first gate');

    await dragBy(tester, gesture, -420);
    expect(contentPixels(tester), greaterThan(100.0));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
      'a fast fling below the top detent does not fling the content list',
      (tester) async {
    // Covers _ExpandFirstScrollPhysics.createBallisticSimulation: when the
    // finger lifts with positive velocity while the content is still at pixel 0
    // (sheet not yet past the top-detent threshold), the guard returns null so
    // the list does not scroll. The sheet's own ballistic continues independently.
    final controller = GlassModalSheetController();
    await tester.pumpWidget(buildSheet(controller: controller));
    await tester.pumpAndSettle();

    // Short fling: the finger travels only 60 px upward at high velocity.
    // The sheet starts at `medium` and cannot cross _kTopDetentThreshold in
    // 60 px, so _ExpandFirstScrollPhysics is still installed when the finger
    // lifts and createBallisticSimulation is called with velocity > 0,
    // pixels == 0 → it returns null and the list stays still.
    await tester.fling(
      find.byType(GlassModalSheet),
      const Offset(0, -60),
      800,
    );
    // Pump just a few frames — enough for the ballistic to fire but not enough
    // for the sheet to finish settling, so we can assert the content mid-flight.
    await tester.pump(const Duration(milliseconds: 32));

    expect(contentPixels(tester), 0.0,
        reason: 'the fling must not scroll the content while the sheet is '
            'still expanding below the top detent');

    await tester.pumpAndSettle();
  });
}
