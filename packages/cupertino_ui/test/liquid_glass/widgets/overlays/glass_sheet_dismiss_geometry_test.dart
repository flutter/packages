import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  for (final medium in [false, true]) {
    testWidgets('dismiss geometry stays continuous (medium: $medium)',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = GlassModalSheetController();
      const contentKey = ValueKey('sheet-frame');
      await tester.pumpWidget(MaterialApp(
        home: GlassModalSheetScaffold(
          controller: controller,
          initialState: GlassSheetState.full,
          mode: GlassSheetMode.dismissible,
          detents: {
            if (medium) GlassSheetDetent.medium,
            GlassSheetDetent.large
          },
          fullSize: .9,
          halfSize: .5,
          horizontalMargin: 8,
          bottomMargin: 6,
          peekWidth: 240,
          peekBottomMargin: 24,
          enableInteractionGlow: false,
          enableSaturationGlow: false,
          interactionScale: 1,
          padding: EdgeInsets.zero,
          body: const SizedBox.expand(),
          sheet: const SizedBox.expand(key: contentKey),
        ),
      ));
      await tester.pumpAndSettle();
      final frame = find.byKey(contentKey);
      var previous = tester.getRect(frame);
      final gesture = await tester.startGesture(Offset(200, previous.top + 12));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      previous = tester.getRect(frame);
      for (var i = 0; i < 125; i++) {
        await gesture.moveBy(const Offset(0, 4));
        await tester.pump();
        final current = tester.getRect(frame);
        expect((current.width - previous.width).abs(), lessThan(2),
            reason: 'width jumped at drag step $i: $previous → $current');
        expect(current.top - previous.top, closeTo(4, .02),
            reason: 'the sheet must track the finger without a vertical jump');
        if (!medium) {
          expect(current.width, closeTo(400, .01),
              reason: 'large-only dismissal should preserve the full frame');
          expect(current.height, closeTo(previous.height, .01));
        } else if (current.top > 400) {
          expect(current.width, closeTo(384, .01),
              reason: 'dismissal must preserve the medium frame, not peek');
          expect(current.height, closeTo(394, .01));
        }
        previous = current;
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.currentState, GlassSheetState.hidden);
      expect(tester.takeException(), isNull);
    });
  }
}
