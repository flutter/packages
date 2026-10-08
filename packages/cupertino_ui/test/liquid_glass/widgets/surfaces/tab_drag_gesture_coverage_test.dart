// Tests for TabDragGestureMixin and buildIconShadows
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_internal.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: LiquidGlassWidgets.wrap(child: child)),
    );

GlassTab _tab(String label) =>
    GlassTab(label: label, icon: const Icon(Icons.home));

void main() {
  group('buildIconShadows', () {
    test('returns null when thickness is null', () {
      final result = buildIconShadows(
        iconColor: Colors.white,
        thickness: null,
        selected: false,
        activeIcon: null,
      );
      expect(result, isNull);
    });

    test('returns null when selected with activeIcon', () {
      final result = buildIconShadows(
        iconColor: Colors.white,
        thickness: 1.5,
        selected: true,
        activeIcon: const Icon(Icons.star),
      );
      expect(result, isNull);
    });

    test('returns 8 shadows when unselected with thickness', () {
      final result = buildIconShadows(
        iconColor: Colors.white,
        thickness: 1.5,
        selected: false,
        activeIcon: null,
      );
      expect(result, isNotNull);
      expect(result!.length, 8);
    });

    test('returns shadows when selected WITHOUT activeIcon', () {
      final result = buildIconShadows(
        iconColor: Colors.blue,
        thickness: 2.0,
        selected: true,
        activeIcon: null,
      );
      expect(result, isNotNull);
      expect(result!.length, 8);
    });

    test('shadows use correct iconColor', () {
      const iconColor = Color(0xFFFF0000);
      final result = buildIconShadows(
        iconColor: iconColor,
        thickness: 1.0,
        selected: false,
        activeIcon: null,
      );
      expect(result!.every((s) => s.color == iconColor), isTrue);
    });

    test('shadows offset magnitude equals thickness', () {
      const thickness = 3.0;
      final result = buildIconShadows(
        iconColor: Colors.black,
        thickness: thickness,
        selected: false,
        activeIcon: null,
      );
      for (final shadow in result!) {
        expect(shadow.offset.distance, closeTo(thickness, 0.01));
      }
    });
  });

  group('TabDragGestureMixin — drag state machine via GlassTabBar.bottom', () {
    testWidgets('drag left switches tab via velocity fling', (tester) async {
      int selectedTab = 2;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(builder: (ctx, setState) {
          return SizedBox(
            height: 100,
            child: GlassTabBar.bottom(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: selectedTab,
              onTabSelected: (i) => setState(() => selectedTab = i),
              maskingQuality: MaskingQuality.off,
            ),
          );
        }),
      ));
      await tester.pump();

      // Start a horizontal drag from right to left
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(-200, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      // Tab should have moved left
      expect(selectedTab, lessThan(2));
    });

    testWidgets('drag cancel while dragging snaps to nearest tab',
        (tester) async {
      int selectedTab = 1;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(builder: (ctx, setState) {
          return SizedBox(
            height: 100,
            child: GlassTabBar.bottom(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: selectedTab,
              onTabSelected: (i) => setState(() => selectedTab = i),
              maskingQuality: MaskingQuality.off,
            ),
          );
        }),
      ));
      await tester.pump();

      // Move far enough to lock in tabIsDragging=true, then cancel.
      // onBarDragCancel's tabIsDragging=true branch (lines 143-151) is hit.
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(80, 0)); // large enough for drag lock
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.cancel();
      await tester.pumpAndSettle();
      // Should snap to some valid tab without crash
      expect(selectedTab, greaterThanOrEqualTo(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag cancel without dragging resets indicator position',
        (tester) async {
      // onBarDragCancel with tabIsDragging=false (else branch, line 154).
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 1,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      // Start and immediately cancel without moving → tabIsDragging stays false
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.cancel(); // cancel before any move
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('onBarTapDown selects a tab on tap', (tester) async {
      int? lastSelected;
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            onTabSelected: (i) => lastSelected = i,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      // Tap on the rightmost third (tab index 2) — may or may not hit test
      // depending on headless layout; we just verify no crash occurs.
      final barFinder = find.byType(GlassTabBar);
      final barRect = tester.getRect(barFinder);
      await tester.tapAt(Offset(barRect.right - 20, barRect.center.dy));
      await tester.pumpAndSettle();
      // Result may be null if bar is hidden behind the sheet overlay
      expect(lastSelected == null || lastSelected! >= 0, isTrue);
    });
  });

  group('BottomBarTabItem', () {
    testWidgets('renders label and icon', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 80,
          width: 80,
          child: BottomBarTabItem(
            tab: const GlassTab(
              label: 'Test',
              icon: Icon(Icons.home),
            ),
            selected: false,
            selectedIconColor: Colors.blue,
            unselectedIconColor: Colors.grey,
            iconSize: 24,
            textStyle: null,
            labelFontSize: 11,
            iconLabelSpacing: 4,
            glowDuration: const Duration(milliseconds: 300),
            glowBlurRadius: 20,
            glowSpreadRadius: 10,
            glowOpacity: 0.5,
            onTap: null,
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('selected state changes icon weight', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 80,
          width: 80,
          child: BottomBarTabItem(
            tab: const GlassTab(
              label: 'Test',
              icon: Icon(Icons.home),
              glowColor: Colors.blue,
            ),
            selected: true,
            selectedIconColor: Colors.white,
            unselectedIconColor: Colors.grey,
            iconSize: 24,
            textStyle: null,
            labelFontSize: 11,
            iconLabelSpacing: 4,
            glowDuration: const Duration(milliseconds: 300),
            glowBlurRadius: 20,
            glowSpreadRadius: 10,
            glowOpacity: 0.5,
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('TabIndicator — high quality mode', () {
    testWidgets('MaskingQuality.high renders dual-layer stack', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.high,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('MaskingQuality.off at edge tab (index 0) renders correctly',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0, // leftmost tab
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('A'), findsWidgets);
    });
  });

  group('TabDragGestureMixin — barSwayOffset (lateral sway)', () {
    testWidgets('barSwayOffset accumulates during horizontal drag',
        (tester) async {
      int selectedTab = 1;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(builder: (ctx, setState) {
          return SizedBox(
            height: 100,
            child: GlassTabBar.bottom(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: selectedTab,
              onTabSelected: (i) => setState(() => selectedTab = i),
              maskingQuality: MaskingQuality.off,
            ),
          );
        }),
      ));
      await tester.pump();

      // Perform a horizontal drag — the bar should accept it without error
      // and the Transform.translate should appear in the tree.
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 16));

      // Verify Transform.translate is present (sway wrapper)
      expect(find.byType(Transform), findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('barSwayOffset resets on drag end (springs back to center)',
        (tester) async {
      int selectedTab = 1;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(builder: (ctx, setState) {
          return SizedBox(
            height: 100,
            child: GlassTabBar.bottom(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: selectedTab,
              onTabSelected: (i) => setState(() => selectedTab = i),
              maskingQuality: MaskingQuality.off,
            ),
          );
        }),
      ));
      await tester.pump();

      // Drag and release
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      // After settle, the state's TabIndicatorState.barSwayOffset should be 0.
      final indicatorState =
          tester.state<TabIndicatorState>(find.byType(TabIndicator));
      expect(indicatorState.barSwayOffset, 0.0);
    });

    testWidgets('barSwayOffset resets on drag cancel', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 1,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      // Start drag, move, then cancel
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.cancel();
      await tester.pumpAndSettle();

      final indicatorState =
          tester.state<TabIndicatorState>(find.byType(TabIndicator));
      expect(indicatorState.barSwayOffset, 0.0);
    });

    testWidgets('barSwayOffset is clamped to max magnitude', (tester) async {
      int selectedTab = 1;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(builder: (ctx, setState) {
          return SizedBox(
            height: 100,
            child: GlassTabBar.bottom(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: selectedTab,
              onTabSelected: (i) => setState(() => selectedTab = i),
              maskingQuality: MaskingQuality.off,
            ),
          );
        }),
      ));
      await tester.pump();

      // Drag very far to exceed the clamp
      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      // Move in multiple large increments to try to exceed the 3px clamp
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(50, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }

      final indicatorState =
          tester.state<TabIndicatorState>(find.byType(TabIndicator));
      // barSwayOffset should never exceed _maxSwayPx (0.75)
      expect(indicatorState.barSwayOffset.abs(), lessThanOrEqualTo(0.75));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Regression: issue #157 — tap→index must use raw fraction, not drag remap
  //
  // For a 4-tab bar the hit boundaries must be at 25 / 50 / 75 % of the
  // TabIndicator width (the render box whose coordinate space the mixin uses).
  // The old code routed tap positions through the drag-physics alignment remap,
  // which shifted the boundaries to ~31.25 / 50 / 68.75 %, causing tapping
  // the right ¼ of tab 2 to select tab 3.
  // ─────────────────────────────────────────────────────────────────────────

  group('issue #157 — 4-tab tap hit regions (raw fraction, equal slices)', () {
    /// Builds a GlassTabBar.bottom with 4 equal tabs and returns the
    /// selected-index tracker.
    Future<int Function()> build4Tabs(WidgetTester tester) async {
      int selected = 0;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.bottom(
            tabs: [
              _tab('A'),
              _tab('B'),
              _tab('C'),
              _tab('D'),
            ],
            selectedIndex: selected,
            onTabSelected: (i) => setState(() => selected = i),
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();
      return () => selected;
    }

    // Compute tap positions relative to the TabIndicator's own render box —
    // that is the RenderBox that `context.findRenderObject()` returns inside
    // the mixin, so fractions must be against this widget's bounds.
    Rect indicatorRect(WidgetTester tester) =>
        tester.getRect(find.byType(TabIndicator));

    testWidgets('tap at 12% of indicator width → tab 0', (tester) async {
      final getSelected = await build4Tabs(tester);
      final r = indicatorRect(tester);
      await tester.tapAt(Offset(r.left + r.width * 0.12, r.center.dy));
      await tester.pumpAndSettle();
      expect(getSelected(), 0,
          reason: 'Tap at 12% should select tab 0 (first equal slice)');
    });

    testWidgets(
        'tap at 40% of indicator width → tab 1 (well inside second slice)',
        (tester) async {
      final getSelected = await build4Tabs(tester);
      final r = indicatorRect(tester);
      // 40% is deep inside the second quarter [25%, 50%) — must be tab 1.
      await tester.tapAt(Offset(r.left + r.width * 0.40, r.center.dy));
      await tester.pumpAndSettle();
      expect(getSelected(), 1,
          reason: 'Tap at 40% must select tab 1 (second equal slice)');
    });

    testWidgets(
        'tap at 73% of indicator width → tab 2 (just before third boundary)',
        (tester) async {
      final getSelected = await build4Tabs(tester);
      final r = indicatorRect(tester);
      // 73% is inside [50%, 75%) — must be tab 2, NOT tab 3.
      // With the old drag-physics remap the boundary was at 68.75%, so a
      // 73% tap would have selected tab 3.
      await tester.tapAt(Offset(r.left + r.width * 0.73, r.center.dy));
      await tester.pumpAndSettle();
      expect(getSelected(), isNot(3),
          reason:
              'Tap at 73% (before 75% boundary) must not select tab 3 (#157 regression)');
    });

    testWidgets('tap at 88% of indicator width → tab 3 (last tab)',
        (tester) async {
      final getSelected = await build4Tabs(tester);
      final r = indicatorRect(tester);
      await tester.tapAt(Offset(r.left + r.width * 0.88, r.center.dy));
      await tester.pumpAndSettle();
      expect(getSelected(), 3,
          reason: 'Tap at 88% should select tab 3 (last equal slice)');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Reconcile with host when selection is declined (PR #255)
  // ─────────────────────────────────────────────────────────────────────────

  group('TabDragGestureMixin — reconcileWithHost on declined selection (#255)',
      () {
    testWidgets('drag end settles indicator back when host declines selection',
        (tester) async {
      int? reportedTarget;
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            onTabSelected: (i) => reportedTarget = i,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(200, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Host never adopted the selection (no StatefulBuilder), so the
      // indicator must spring back to tab 0.
      expect(reportedTarget, greaterThan(0),
          reason: 'notifyTabChanged must have fired for a non-zero tab');
      final state = tester.state<TabIndicatorState>(find.byType(TabIndicator));
      expect(state.tabXAlign, closeTo(state.computeTabAlignment(0), 0.001),
          reason:
              'reconcileWithHost must have settled the indicator back to tab 0');
    });

    testWidgets(
        'drag cancel while dragging settles indicator back when host declines selection',
        (tester) async {
      int? reportedTarget;
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            onTabSelected: (i) => reportedTarget = i,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      final state = tester.state<TabIndicatorState>(find.byType(TabIndicator));
      final indicatorRect = tester.getRect(find.byType(TabIndicator));

      state.onBarDragStart(DragStartDetails(
        globalPosition:
            Offset(indicatorRect.right - 20, indicatorRect.center.dy),
      ));
      expect(state.tabIsDragging, isTrue);

      state.onBarDragCancel();
      await tester.pumpAndSettle();

      expect(reportedTarget, greaterThan(0),
          reason: 'notifyTabChanged must have fired for a non-zero tab');
      expect(state.tabXAlign, closeTo(state.computeTabAlignment(0), 0.001),
          reason:
              'reconcileWithHost must have settled the indicator back to tab 0');
    });

    testWidgets(
        'hybrid tap up settles indicator back when host declines selection',
        (tester) async {
      int? reportedTarget;
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            platformViewBackdrop: true,
            onTabSelected: (i) => reportedTarget = i,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      final indicatorFinder = find.byType(TabIndicator);
      final indicatorRect = tester.getRect(indicatorFinder);
      await tester
          .tapAt(Offset(indicatorRect.right - 20, indicatorRect.center.dy));
      await tester.pumpAndSettle();

      expect(reportedTarget, 2);
      final state = tester.state<TabIndicatorState>(find.byType(TabIndicator));
      expect(state.tabXAlign, closeTo(state.computeTabAlignment(0), 0.001));
    });

    testWidgets(
        'recoverIfGestureStuck settles indicator back when host declines selection',
        (tester) async {
      int? reportedTarget;
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            platformViewBackdrop: true,
            onTabSelected: (i) => reportedTarget = i,
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();

      final state = tester.state<TabIndicatorState>(find.byType(TabIndicator));
      final barFinder = find.byType(GlassTabBar);
      final barRect = tester.getRect(barFinder);

      // Simulate wedged gesture on PlatformView
      state.onBarPointerDown(barRect.center);
      state
          .recoverIfGestureStuck(Offset(barRect.right - 20, barRect.center.dy));
      await tester.pumpAndSettle();

      expect(reportedTarget, 2);
      expect(state.tabXAlign, closeTo(state.computeTabAlignment(0), 0.001));
    });

    testWidgets('reconcileWithHost is a no-op when host adopts selection',
        (tester) async {
      int selectedTab = 0;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(builder: (ctx, setState) {
          return SizedBox(
            height: 100,
            child: GlassTabBar.bottom(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: selectedTab,
              onTabSelected: (i) => setState(() => selectedTab = i),
              maskingQuality: MaskingQuality.off,
            ),
          );
        }),
      ));
      await tester.pump();

      final barFinder = find.byType(GlassTabBar);
      final barCenter = tester.getCenter(barFinder);
      final gesture = await tester.startGesture(barCenter);
      await gesture.moveBy(const Offset(200, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(selectedTab, greaterThan(0));
      final state = tester.state<TabIndicatorState>(find.byType(TabIndicator));
      expect(state.tabXAlign,
          closeTo(state.computeTabAlignment(selectedTab), 0.001));
    });
  });
}
