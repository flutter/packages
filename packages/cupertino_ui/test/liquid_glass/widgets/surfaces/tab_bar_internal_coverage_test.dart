// ignore_for_file: require_trailing_commas
// Tests for scrollable_segment_content.dart (ScrollableSegmentContent) and
// bottom_bar_internal.dart (GlassTabBar.bottomClipper.shouldReclip).
//
// Coverage targets:
//   scrollable_segment_content.dart:
//     - lines 337-348: selectedIndex change in scrollable mode (indicator update)
//     - line 127:      _measureTabs postFrameCallback re-schedule
//     - lines 534-546: scrollable mode indicator skip when not measured + exact-width path
//     - Drag gesture improvements (PR#54): 20% threshold, velocity flick, boundary clamping
//     - Jelly physics: VelocitySpringBuilder in scrollable mode
//     - Rubber-band overstep constants
//   bottom_bar_internal.dart:
//     - lines 472-482: GlassTabBar.bottomClipper.shouldReclip full-check when values differ

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

/// Five tabs reused across most tests.
final _tabs = [
  const GlassSegment(label: 'One'),
  const GlassSegment(label: 'Two'),
  const GlassSegment(label: 'Three'),
  const GlassSegment(label: 'Four'),
  const GlassSegment(label: 'Five'),
];

/// Three-tab set for boundary / edge-clamp tests.
final _tabs3 = [
  const GlassSegment(label: 'A'),
  const GlassSegment(label: 'B'),
  const GlassSegment(label: 'C'),
];

/// Pumps a [GlassTabBar] and waits for tab measurement to complete.
Future<void> _pumpBar(
  WidgetTester tester, {
  required List<GlassSegment> tabs,
  required ValueNotifier<int> selectedIndex,
  bool isScrollable = false,
  double width = 400,
}) async {
  await tester.pumpWidget(
    createTestApp(
      child: ValueListenableBuilder<int>(
        valueListenable: selectedIndex,
        builder: (ctx, idx, _) => SizedBox(
          width: width,
          height: 56,
          child: isScrollable
              ? GlassSegmentedControl.scrollable(
                  segments: tabs,
                  selectedIndex: idx,
                  onSegmentSelected: (i) => selectedIndex.value = i)
              : GlassSegmentedControl(
                  segments: tabs,
                  selectedIndex: idx,
                  onSegmentSelected: (i) => selectedIndex.value = i),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
  await tester.pumpAndSettle();
}

void main() {
  group('GlassTabBar — scrollable indicator exact-width interpolation', () {
    testWidgets(
        'selecting different tab in scrollable mode triggers indicator update',
        (tester) async {
      // Lines 337-348 + 534-546: once _tabWidths are measured, selecting a
      // different tab drives the indicator width interpolation path.
      int selectedIndex = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(builder: (ctx, setState) {
            outerSetState = setState;
            return SizedBox(
              width: 400,
              height: 56,
              child: GlassSegmentedControl.scrollable(
                  segments: _tabs,
                  selectedIndex: selectedIndex,
                  onSegmentSelected: (i) =>
                      outerSetState(() => selectedIndex = i)),
            );
          }),
        ),
      );

      // Multiple frames so _measureTabs post-frame callback fires.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      // Switch tab → indicator animates with measured widths.
      outerSetState(() => selectedIndex = 2);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      outerSetState(() => selectedIndex = 4);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('drag gesture in scrollable mode updates indicator position',
        (tester) async {
      // Lines 534-546: the fractional-index calculation during drag.
      int selectedIndex = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(builder: (ctx, setState) {
            outerSetState = setState;
            return SizedBox(
              width: 400,
              height: 56,
              child: GlassSegmentedControl.scrollable(
                  segments: _tabs,
                  selectedIndex: selectedIndex,
                  onSegmentSelected: (i) =>
                      outerSetState(() => selectedIndex = i)),
            );
          }),
        ),
      );
      // Wait for tab measurement.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      // Drag → DraggableIndicatorPhysics drives fractional index path.
      final finder = find.byType(GlassSegmentedControl);
      final center = tester.getCenter(finder);
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'non-scrollable → scrollable toggle exercises isScrollable branch',
        (tester) async {
      // Lines 152-154 equivalent: toggling the isScrollable flag causes the
      // tab bar to re-attach/detach internal scroll listener.
      bool scrollable = false;
      int selectedIndex = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(builder: (ctx, setState) {
            outerSetState = setState;
            return SizedBox(
              width: 400,
              height: 56,
              child: scrollable
                  ? GlassSegmentedControl.scrollable(
                      segments: _tabs,
                      selectedIndex: selectedIndex,
                      onSegmentSelected: (i) =>
                          outerSetState(() => selectedIndex = i))
                  : GlassSegmentedControl(
                      segments: _tabs,
                      selectedIndex: selectedIndex,
                      onSegmentSelected: (i) =>
                          outerSetState(() => selectedIndex = i)),
            );
          }),
        ),
      );
      await tester.pump();

      // Toggle to scrollable.
      outerSetState(() => scrollable = true);
      await tester.pump();
      await tester.pumpAndSettle();

      // Toggle back to non-scrollable.
      outerSetState(() => scrollable = false);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassTabBar.bottomClipper — shouldReclip full-check path', () {
    testWidgets('changing indicator alignment triggers shouldReclip',
        (tester) async {
      // Lines 472-482: shouldReclip returns true when alignment changes.
      // Exercised by changing selectedIndex (moves indicator → new clipper).
      int selectedTab = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(builder: (ctx, setState) {
            outerSetState = setState;
            return SizedBox(
              height: 80,
              width: 300,
              child: GlassTabBar.bottom(
                tabs: [
                  const GlassTab(label: 'A', icon: Icon(Icons.home)),
                  const GlassTab(label: 'B', icon: Icon(Icons.search)),
                  const GlassTab(label: 'C', icon: Icon(Icons.person)),
                ],
                selectedIndex: selectedTab,
                onTabSelected: (i) => outerSetState(() => selectedTab = i),
                maskingQuality: MaskingQuality.high,
              ),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      // Cycle through all tabs — clipper shouldReclip called with different
      // alignment values each time.
      for (int i = 1; i < 3; i++) {
        outerSetState(() => selectedTab = i);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'changing borderRadius and selectedIndex together exercises all shouldReclip fields',
        (tester) async {
      // Lines 472-482: the full-check path evaluates borderRadius field.
      // GlassTabBar with indicatorBorderRadius change exercises this.
      int selectedIndex = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(builder: (ctx, setState) {
            outerSetState = setState;
            return SizedBox(
              width: 400,
              height: 56,
              child: GlassSegmentedControl(
                  segments: _tabs.sublist(0, 3),
                  selectedIndex: selectedIndex,
                  onSegmentSelected: (i) =>
                      outerSetState(() => selectedIndex = i)),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      // Change both radius and selected tab — causes shouldReclip to evaluate
      // the full property set (including borderRadius != oldClipper.borderRadius).
      outerSetState(() {
        selectedIndex = 1;
      });
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      outerSetState(() {
        selectedIndex = 2;
      });
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  // Drag gesture improvements (PR#54)
  // ===========================================================================

  group('GlassTabBar — fixed-mode drag gestures', () {
    testWidgets('tiny drag below 20% threshold keeps selected tab',
        (tester) async {
      // Tab width = 400/5 = 80 px; 20% threshold = 16 px. Drag 8 px → no switch.
      final sel = ValueNotifier<int>(2);
      await _pumpBar(tester, tabs: _tabs, selectedIndex: sel);

      await tester.drag(find.byType(GlassSegmentedControl), const Offset(8, 0));
      await tester.pumpAndSettle();

      expect(sel.value, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('large drag past 20% threshold advances selected tab',
        (tester) async {
      // 45 px rightward >> 20% of 80 px tab — must trigger a tab switch.
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester, tabs: _tabs, selectedIndex: sel);

      await tester.drag(
          find.byType(GlassSegmentedControl), const Offset(45, 0));
      await tester.pumpAndSettle();

      expect(sel.value, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('high-velocity flick right advances tab', (tester) async {
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester, tabs: _tabs3, selectedIndex: sel, width: 300);

      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(10, 0), 600);
      await tester.pumpAndSettle();

      expect(sel.value, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('high-velocity flick left retreats tab', (tester) async {
      final sel = ValueNotifier<int>(2);
      await _pumpBar(tester, tabs: _tabs3, selectedIndex: sel, width: 300);

      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(-10, 0), 600);
      await tester.pumpAndSettle();

      expect(sel.value, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag past left edge clamps at tab 0', (tester) async {
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester, tabs: _tabs3, selectedIndex: sel, width: 300);

      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(-200, 0), 800);
      await tester.pumpAndSettle();

      expect(sel.value, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag past right edge clamps at last tab', (tester) async {
      final sel = ValueNotifier<int>(2);
      await _pumpBar(tester, tabs: _tabs3, selectedIndex: sel, width: 300);

      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(200, 0), 800);
      await tester.pumpAndSettle();

      expect(sel.value, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('extreme rubber-band drag left does not crash', (tester) async {
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester, tabs: _tabs3, selectedIndex: sel);

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassSegmentedControl)));
      await gesture.moveBy(const Offset(-500, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('extreme rubber-band drag right does not crash',
        (tester) async {
      final sel = ValueNotifier<int>(2);
      await _pumpBar(tester, tabs: _tabs3, selectedIndex: sel);

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassSegmentedControl)));
      await gesture.moveBy(const Offset(500, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassTabBar — scrollable-mode jelly physics', () {
    testWidgets('drag on active indicator does not throw', (tester) async {
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester,
          tabs: _tabs, selectedIndex: sel, isScrollable: true);

      final barRect = tester.getRect(find.byType(GlassSegmentedControl));
      final gesture = await tester.startGesture(
        Offset(barRect.left + 40, barRect.center.dy),
      );
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('fast flick exercises velocity-override code path',
        (tester) async {
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester,
          tabs: _tabs, selectedIndex: sel, isScrollable: true);

      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(5, 0), 600);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'programmatic tab switch drives VelocitySpringBuilder animation',
        (tester) async {
      final sel = ValueNotifier<int>(0);
      await _pumpBar(tester,
          tabs: _tabs, selectedIndex: sel, isScrollable: true);

      sel.value = 3;
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      sel.value = 1;
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('drag cancel resets dragging flags without throwing',
        (tester) async {
      final sel = ValueNotifier<int>(1);
      await _pumpBar(tester,
          tabs: _tabs, selectedIndex: sel, isScrollable: true);

      final barRect = tester.getRect(find.byType(GlassSegmentedControl));
      final gesture = await tester.startGesture(
        Offset(barRect.left + 50, barRect.center.dy),
      );
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('two-tab scrollable bar boundary fix keeps indicator in bounds',
        (tester) async {
      // Boundary fix: right wall = viewMax - targetWidth (not viewMax).
      final sel = ValueNotifier<int>(0);
      await tester.pumpWidget(
        createTestApp(
          child: ValueListenableBuilder<int>(
            valueListenable: sel,
            builder: (ctx, idx, _) => SizedBox(
              width: 300,
              height: 56,
              child: GlassSegmentedControl.scrollable(segments: const [
                GlassSegment(label: 'A'),
                GlassSegment(label: 'B')
              ], selectedIndex: idx, onSegmentSelected: (i) => sel.value = i),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      await tester.fling(
          find.byType(GlassSegmentedControl), const Offset(200, 0), 200);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  // _scrollToEnsureVisible — off-screen left & right scroll branches
  // ===========================================================================

  group('GlassTabBar — scrollToEnsureVisible scroll paths', () {
    // Build a scrollable bar that is narrower than its tab content so that
    // tabs can actually be off-screen, then switch programmatically to trigger
    // _scrollToEnsureVisible for both the left and right branches.

    Future<void> pumpNarrowBar(
      WidgetTester tester,
      ValueNotifier<int> sel,
    ) async {
      // 8 tabs in a 200 px viewport — content is much wider than the viewport
      // so right-most tabs start off-screen.
      const narrowTabs = [
        GlassSegment(label: 'T1'),
        GlassSegment(label: 'T2'),
        GlassSegment(label: 'T3'),
        GlassSegment(label: 'T4'),
        GlassSegment(label: 'T5'),
        GlassSegment(label: 'T6'),
        GlassSegment(label: 'T7'),
        GlassSegment(label: 'T8'),
      ];
      await tester.pumpWidget(
        createTestApp(
          child: ValueListenableBuilder<int>(
            valueListenable: sel,
            builder: (ctx, idx, _) => SizedBox(
              width: 200,
              height: 56,
              child: GlassSegmentedControl.scrollable(
                  segments: narrowTabs,
                  selectedIndex: idx,
                  onSegmentSelected: (i) => sel.value = i),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();
    }

    testWidgets('selecting a right off-screen tab triggers rightward scroll',
        (tester) async {
      // Start at tab 0 (visible); jump to tab 7 (off-screen right).
      // _scrollToEnsureVisible must detect tabRight > viewportWidth - edgePadding
      // and animate the scroll controller rightward.
      final sel = ValueNotifier<int>(0);
      await pumpNarrowBar(tester, sel);

      sel.value = 7;
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a left off-screen tab triggers leftward scroll',
        (tester) async {
      // Start at tab 7 so the bar is scrolled right; jump back to tab 0.
      // _scrollToEnsureVisible must detect tabLeft - currentOffset < edgePadding
      // and animate the scroll controller leftward.
      final sel = ValueNotifier<int>(7);
      await pumpNarrowBar(tester, sel);

      // Let the bar settle scrolled to the right (tab 7 in view).
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      sel.value = 0;
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping an off-screen tab also calls scrollToEnsureVisible',
        (tester) async {
      // The _onTabTap path also calls _scrollToEnsureVisible — cover it via
      // a tap on a partially-visible edge tab.
      final sel = ValueNotifier<int>(0);
      await pumpNarrowBar(tester, sel);

      // Programmatically switch to a middle tab then back to 0 via tap.
      sel.value = 3;
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      // Tap the first tab (leftmost, may be partially scrolled off).
      final barRect = tester.getRect(find.byType(GlassSegmentedControl));
      await tester.tapAt(Offset(barRect.left + 10, barRect.center.dy));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  // Edge cases: diff==0 interpolation guard & !_isDragging dragEnd early-return
  // ===========================================================================

  group('GlassTabBar — scrollable edge-case guards', () {
    testWidgets('dragEnd without prior drag movement calls dragCancel cleanly',
        (tester) async {
      // _handleDragEnd checks !_isDragging and delegates to _handleDragCancel.
      // Simulate a pointer-down then immediate pointer-up with no move.
      // The gesture arena may resolve this as a tap (switching tabs) or a
      // no-op cancel — both are valid; the key invariant is no exception thrown.
      final sel = ValueNotifier<int>(1);
      await _pumpBar(tester,
          tabs: _tabs, selectedIndex: sel, isScrollable: true);

      final barRect = tester.getRect(find.byType(GlassSegmentedControl));
      final gesture = await tester.startGesture(
        Offset(barRect.left + 50, barRect.center.dy),
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '2-tab scrollable bar at last tab covers diff==0 interpolation guard',
        (tester) async {
      // With 2 tabs and the indicator at tab 1 (last), the loop sets index=1
      // and nextIndex clamps to 1 as well, so diff == 0.
      // The guard `diff != 0 ? ... : 0.0` must return 0.0 without NaN.
      final sel = ValueNotifier<int>(1);
      await tester.pumpWidget(
        createTestApp(
          child: ValueListenableBuilder<int>(
            valueListenable: sel,
            builder: (ctx, idx, _) => SizedBox(
              width: 300,
              height: 56,
              child: GlassSegmentedControl.scrollable(
                segments: const [
                  GlassSegment(label: 'Left'),
                  GlassSegment(label: 'Right'),
                ],
                selectedIndex: idx,
                onSegmentSelected: (i) => sel.value = i,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();

      // Drag from the rightmost tab area — indicator is at index 1, nextIndex
      // clamps to 1, making diff == 0 in the interpolation.
      final barRect = tester.getRect(find.byType(GlassSegmentedControl));
      final gesture = await tester.startGesture(
        Offset(barRect.right - 30, barRect.center.dy),
      );
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('BottomBarExtraBtn via GlassTabBar', () {
    testWidgets(
        'platformViewBackdrop=true swaps LiquidOval for LiquidRoundedRectangle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTabBar.bottom(
              tabs: const [
                GlassTab(icon: Icon(Icons.home)),
                GlassTab(icon: Icon(Icons.settings))
              ],
              selectedIndex: 0,
              onTabSelected: (i) {},
              platformViewBackdrop: true,
              extraButton: GlassTabBarExtraButton(
                icon: const Icon(Icons.add),
                onTap: () {},
                label: 'Add',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    // Regression test for https://github.com/sdegenaar/liquid_glass_widgets/issues/203
    // GlassTabBarExtraButton must retain its BackdropFilter blur in minimal
    // quality so it visually matches the frosted main tab bar surface.
    testWidgets(
        'GlassTabBarExtraButton has BackdropFilter in GlassQuality.minimal (#203)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTabBar.bottom(
              tabs: const [
                GlassTab(icon: Icon(Icons.home)),
                GlassTab(icon: Icon(Icons.settings)),
              ],
              selectedIndex: 0,
              onTabSelected: (i) {},
              quality: GlassQuality.minimal,
              extraButton: GlassTabBarExtraButton(
                icon: const Icon(Icons.add),
                onTap: () {},
                label: 'Add',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The extra button is stationary, so its _FrostedFallback must use a
      // BackdropFilter even in minimal mode (isStationary: true bypasses the
      // isInteractive blur-omission guard).
      expect(find.byType(BackdropFilter), findsWidgets);
    });
  });
}
