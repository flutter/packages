import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Regression tests for `GlassPopover` positioning and sizing:
///
/// 1. **Nearest-overlay & nested layouts (#274)** — the morphing overlay attaches
///    to `OverlayChildLocation.nearestOverlay` so that it stays confined to the
///    route where it was opened and incoming routes render on top of it. The
///    trigger position is mapped relative to the nearest overlay to ensure zero
///    offset drift in nested layouts (e.g. sidebars or nested Navigators).
/// 2. **Frozen intrinsic height** — in intrinsic-height mode the popover used to
///    freeze the content height measured at open time; content that grew while
///    open overflowed. It must now re-measure and follow the live size.
void main() {
  group(
      'GlassPopover renders into the nearest overlay without nested offset drift',
      () {
    testWidgets('OverlayPortal targets OverlayChildLocation.nearestOverlay',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassPopover(
                trigger:
                    const SizedBox(width: 50, height: 50, child: Text('Open')),
                contentBuilder: (context, close) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Body'),
                ),
              ),
            ),
          ),
        ),
      );

      final portal = tester.widget<OverlayPortal>(
        find.descendant(
          of: find.byType(GlassPopover),
          matching: find.byType(OverlayPortal),
        ),
      );

      expect(
        portal.overlayLocation,
        OverlayChildLocation.nearestOverlay,
        reason: 'the morph must attach to the nearest overlay so it remains '
            'confined to the route and does not linger over destination pages (#274)',
      );
    });

    testWidgets(
        'renders accurately over trigger inside nested layout with offset',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                // 100px sidebar offsetting the nested navigator/overlay
                const SizedBox(width: 100),
                Expanded(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (context) => Scaffold(
                        body: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40, top: 40),
                            child: GlassPopover(
                              popoverWidth: 150,
                              popoverHeight: 100,
                              trigger: const SizedBox(
                                width: 50,
                                height: 50,
                                child: Text('NestedTrigger'),
                              ),
                              contentBuilder: (context, close) =>
                                  const Text('NestedBody'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('NestedTrigger'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('NestedBody'), findsOneWidget);

      // Trigger is at global X = 100 (sidebar) + 40 (padding) = 140
      final triggerRect = tester.getRect(find.text('NestedTrigger'));
      expect(triggerRect.left, 140.0);
      expect(triggerRect.top, 40.0);

      // The popover body must open relative to the trigger at 140, NOT double-offset to 240!
      final bodyRect = tester.getRect(find.text('NestedBody'));
      expect(bodyRect.left, greaterThanOrEqualTo(100.0));
      expect(bodyRect.left, lessThan(200.0));
    });
  });

  group('GlassPopover live re-measure (intrinsic height)', () {
    testWidgets('follows content that grows while open instead of overflowing',
        (tester) async {
      final height = ValueNotifier<double>(80);
      addTearDown(height.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassPopover(
                // Intrinsic height (no popoverHeight) — the mode the fix targets.
                popoverWidth: 220,
                trigger:
                    const SizedBox(width: 50, height: 50, child: Text('Open')),
                contentBuilder: (context, close) =>
                    ValueListenableBuilder<double>(
                  valueListenable: height,
                  builder: (context, h, _) => SizedBox(
                    key: const Key('popover-body'),
                    height: h,
                    child: const Text('Body'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pumpAndSettle();

      final body = find.byKey(const Key('popover-body'));
      expect(body, findsOneWidget);
      expect(tester.getSize(body).height, 80);

      // Grow the content while the popover is open.
      height.value = 260;
      await tester.pump(); // content rebuilds → SizeChangedLayoutNotifier fires
      await tester.pumpAndSettle(); // flush the post-frame re-measure

      // No overflow, and the popover followed the taller content.
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(body).height,
        260,
        reason: 'the popover must re-measure and grow to the live content '
            'height instead of clamping to the height frozen at open time',
      );
    });
  });
}
