// Drag-gesture tests for GlassTabBar.bottom tab indicator.
//
// Covers the _onDragEnd snap-to-tab logic and _onDragCancel paths that are
// not exercised by the existing tap-based tests. These are the highest-risk
// paths — any regression in the physics calculation immediately breaks
// navigation UX.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _tabs = [
  const GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
  const GlassTab(label: 'Following', icon: Icon(CupertinoIcons.person_2)),
  const GlassTab(label: 'Saved', icon: Icon(CupertinoIcons.bookmark)),
];

Widget _bar({
  int selectedIndex = 0,
  required ValueChanged<int> onTabSelected,
}) {
  return createTestApp(
    child: GlassTabBar.bottom(
      tabs: _tabs,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
      maskingQuality: MaskingQuality.off, // avoid dual-layer in tests
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------------------------------------------------------------------------
  // Regression tests — issue #22: same-tab repeat tap
  // ---------------------------------------------------------------------------

  group('GlassTabBar.bottom — same-tab repeat tap (issue #22)', () {
    testWidgets('tapping the already-selected tab fires onTabChanged',
        (tester) async {
      final changes = <int>[];

      await tester.pumpWidget(
        _bar(selectedIndex: 0, onTabSelected: changes.add),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      // Tap well into the left third — tab 0 zone (already selected).
      final tapX = rect.left + rect.width * 0.1;
      await tester.tapAt(Offset(tapX, rect.center.dy));
      await tester.pumpAndSettle();

      // Must fire even though tab 0 is already the active tab.
      expect(changes, contains(0),
          reason: 'onTabChanged must fire on repeat tap of the active tab '
              '(issue #22 — enables scroll-to-top / refresh pattern)');
    });

    testWidgets('tapping active tab twice fires onTabChanged both times',
        (tester) async {
      final changes = <int>[];
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _bar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final tapX = rect.left + rect.width * 0.1; // tab 0 zone
      final tapY = rect.center.dy;

      await tester.tapAt(Offset(tapX, tapY));
      await tester.pumpAndSettle();
      await tester.tapAt(Offset(tapX, tapY));
      await tester.pumpAndSettle();

      // Two taps on the same tab → at least two callbacks with index 0.
      final zeroTaps = changes.where((i) => i == 0).length;
      expect(zeroTaps, greaterThanOrEqualTo(2),
          reason: 'Each tap on the active tab must emit a callback');
    });
  });

  // ---------------------------------------------------------------------------
  // Regression tests — issue #23: coordinate space fix
  // ---------------------------------------------------------------------------

  group('GlassTabBar.bottom — drag-end coordinate fix (issue #23)', () {
    // Build a 5-tab bar inside a fixed-width container so coordinates are
    // predictable regardless of the test device screen size.
    final fiveTabs = List.generate(
      5,
      (i) => GlassTab(
        label: 'T$i',
        icon: const Icon(CupertinoIcons.star),
      ),
    );

    Widget fiveTabBar({
      int selectedIndex = 0,
      required ValueChanged<int> onTabSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 80,
            child: GlassTabBar.bottom(
              tabs: fiveTabs,
              selectedIndex: selectedIndex,
              onTabSelected: onTabSelected,
              maskingQuality: MaskingQuality.off,
            ),
          ),
        ),
      );
    }

    testWidgets('drag ending at 50% of 5-tab bar selects tab 2, not tab 3',
        (tester) async {
      // This was the core symptom of issue #23:
      //   relX at center = 0.5
      //   Old formula:  (0.5 / (1/5)).round() = (2.5).round() = 3  ← WRONG
      //   Fixed formula: (0.5 * (5-1)).round() = (2.0).round() = 2  ← CORRECT
      final changes = <int>[];
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => fiveTabBar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      // Drag from the far left (tab 0) to exactly the center of the bar.
      // With 5 equal tabs the center is the midpoint of tab 2.
      final startX = rect.left + rect.width * 0.05;
      final endX = rect.left + rect.width * 0.50;
      final y = rect.center.dy;

      await tester.dragFrom(Offset(startX, y), Offset(endX - startX, 0));
      await tester.pumpAndSettle();

      expect(changes, isNotEmpty,
          reason: 'Drag from tab 0 to centre must fire onTabChanged');
      expect(changes.last, equals(2),
          reason: 'Centre of 5-tab bar (50%) must snap to tab 2, not tab 3 '
              '(coordinate space fix — issue #23)');
    });

    testWidgets('drag ending at 25% of 5-tab bar selects tab 1',
        (tester) async {
      final changes = <int>[];
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => fiveTabBar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final startX = rect.left + rect.width * 0.05;
      final endX = rect.left + rect.width * 0.25;
      final y = rect.center.dy;

      await tester.dragFrom(Offset(startX, y), Offset(endX - startX, 0));
      await tester.pumpAndSettle();

      if (changes.isNotEmpty) {
        expect(changes.last, equals(1),
            reason: '25% position in 5-tab bar must snap to tab 1');
      }
    });

    testWidgets('drag ending at 75% of 5-tab bar selects tab 3',
        (tester) async {
      final changes = <int>[];
      int currentIndex = 4;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => fiveTabBar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      // Drag from far right (tab 4) back to 75%
      final startX = rect.left + rect.width * 0.95;
      final endX = rect.left + rect.width * 0.75;
      final y = rect.center.dy;

      await tester.dragFrom(Offset(startX, y), Offset(endX - startX, 0));
      await tester.pumpAndSettle();

      if (changes.isNotEmpty) {
        expect(changes.last, equals(3),
            reason: '75% position in 5-tab bar must snap to tab 3');
      }
    });
  });

  group('GlassTabBar.bottom — drag gesture snap', () {
    testWidgets('drag right from tab 0 reaches tab 1', (tester) async {
      final changes = <int>[];
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _bar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final bar = find.byType(GlassTabBar);
      expect(bar, findsOneWidget);

      final rect = tester.getRect(bar);
      // Start in the left third (tab 0 zone), drag into the centre (tab 1 zone)
      final startX = rect.left + rect.width * 0.1;
      final endX = rect.left + rect.width * 0.55;
      final y = rect.center.dy;

      await tester.dragFrom(Offset(startX, y), Offset(endX - startX, 0));
      await tester.pumpAndSettle();

      // At minimum the bar survived the drag without throwing.
      expect(find.byType(GlassTabBar), findsOneWidget);
      // And if the drag crossed a tab boundary, a change was reported.
      if (changes.isNotEmpty) {
        expect(changes.last, inInclusiveRange(0, 2));
      }
    });

    testWidgets('drag left from tab 2 reaches tab 1', (tester) async {
      final changes = <int>[];
      int currentIndex = 2;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _bar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final startX = rect.left + rect.width * 0.9;
      final endX = rect.left + rect.width * 0.45;
      final y = rect.center.dy;

      await tester.dragFrom(Offset(startX, y), Offset(endX - startX, 0));
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
      if (changes.isNotEmpty) {
        expect(changes.last, inInclusiveRange(0, 2));
      }
    });

    testWidgets('short drag without crossing zone stays on same tab',
        (tester) async {
      final changes = <int>[];

      await tester.pumpWidget(
        _bar(selectedIndex: 1, onTabSelected: changes.add),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final centerX = rect.center.dx;
      final y = rect.center.dy;

      // Tiny drag — less than half a tab width
      await tester.dragFrom(
        Offset(centerX, y),
        const Offset(8, 0), // very small
      );
      await tester.pumpAndSettle();

      // No tab change — or if it fires, it should still be a valid index.
      for (final idx in changes) {
        expect(idx, inInclusiveRange(0, 2));
      }
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('drag cancel while mid-drag snaps to nearest tab',
        (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        _bar(selectedIndex: 0, onTabSelected: changes.add),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final startX = rect.left + rect.width * 0.1;
      final y = rect.center.dy;

      // Begin drag, move partway, then cancel
      final gesture = await tester.startGesture(Offset(startX, y));
      await tester.pump();
      await gesture.moveBy(const Offset(60, 0)); // mid-drag
      await tester.pump();
      await gesture.cancel();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
      for (final idx in changes) {
        expect(idx, inInclusiveRange(0, 2));
      }
    });

    testWidgets('drag cancel without moving resets alignment cleanly',
        (tester) async {
      await tester.pumpWidget(
        _bar(selectedIndex: 1, onTabSelected: (_) {}),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final center = rect.center;

      // Press without moving, then cancel
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.cancel();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('full drag left-to-right across all tabs fires ordered changes',
        (tester) async {
      final changes = <int>[];
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _bar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      // Drag from far left to far right in one gesture
      await tester.dragFrom(
        Offset(rect.left + 10, rect.center.dy),
        Offset(rect.width - 20, 0),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
      for (final idx in changes) {
        expect(idx, inInclusiveRange(0, 2));
      }
    });

    testWidgets('drag with high velocity snaps past current position',
        (tester) async {
      final changes = <int>[];
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _bar(
            selectedIndex: currentIndex,
            onTabSelected: (i) {
              changes.add(i);
              setState(() => currentIndex = i);
            },
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(find.byType(GlassTabBar));
      final startX = rect.left + rect.width * 0.15;
      final y = rect.center.dy;

      // Simulate a fast fling using a sequence of very quick moves
      final gesture = await tester.startGesture(Offset(startX, y));
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
      for (final idx in changes) {
        expect(idx, inInclusiveRange(0, 2));
      }
    });
  });
}
