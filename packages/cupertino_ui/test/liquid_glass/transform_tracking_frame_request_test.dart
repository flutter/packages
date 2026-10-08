import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// A slow finger drag over glass that lives INSIDE the scrolled content must
/// keep painting.
///
/// `GeometryTransformTrackingLayer` notices the moved glass while the frame
/// is composited and asks for a repaint. Asked from inside the frame, that
/// used to set `_needsPaint` up the tree without a frame being scheduled;
/// every later scroll step then returned early from `markNeedsPaint`, and
/// nothing was drawn until the pointer lifted. The flag is what is checked
/// here rather than the frame count: the test binding's semantics request
/// frames of their own and would mask the freeze.
void main() {
  testWidgets('no frame leaves scrolled glass dirty without the next frame',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (var i = 0; i < 6; i++)
                LightweightLiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  settings: const LiquidGlassSettings(blur: 0),
                  child: const SizedBox(width: 300, height: 300),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final glass =
        tester.renderObject(find.byType(LightweightLiquidGlass).first);
    final gesture = await tester.startGesture(const Offset(150, 400));
    // Past the touch slop: the scroll drag is accepted (the slop itself is
    // swallowed by `DragStartBehavior.start`, so the page has not moved yet).
    await gesture.moveBy(const Offset(0, -60));
    await tester.pump();
    for (var step = 1; step <= 4; step++) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump();
      expect(
        !glass.debugNeedsPaint || tester.binding.hasScheduledFrame,
        isTrue,
        reason:
            'scroll step $step left the glass dirty with no frame requested',
      );
    }
    await gesture.up();
  });
}
