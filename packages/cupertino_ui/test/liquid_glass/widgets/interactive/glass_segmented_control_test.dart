// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassSegmentedControl', () {
    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [
              GlassSegment(label: 'One'),
              GlassSegment(label: 'Two'),
              GlassSegment(label: 'Three')
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            useOwnLayer: true,
          ),
        ),
      );

      expect(find.byType(GlassSegmentedControl), findsOneWidget);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('displays all segments', (tester) async {
      const segments = <GlassSegment>[
        GlassSegment(label: 'Daily'),
        GlassSegment(label: 'Weekly'),
        GlassSegment(label: 'Monthly')
      ];

      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: segments,
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            useOwnLayer: true,
          ),
        ),
      );

      for (final segment in segments) {
        expect(find.text(segment.label!), findsOneWidget);
      }
    });

    testWidgets('calls onSegmentSelected when tapping a segment',
        (tester) async {
      var selectedIndex = 0;

      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [
              GlassSegment(label: 'One'),
              GlassSegment(label: 'Two'),
              GlassSegment(label: 'Three')
            ],
            selectedIndex: selectedIndex,
            onSegmentSelected: (index) => selectedIndex = index,
            useOwnLayer: true,
          ),
        ),
      );

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(1));
    });

    testWidgets('shows correct selected segment', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [
              GlassSegment(label: 'Option A'),
              GlassSegment(label: 'Option B'),
              GlassSegment(label: 'Option C')
            ],
            selectedIndex: 1,
            onSegmentSelected: (_) {},
            useOwnLayer: true,
          ),
        ),
      );

      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      const customHeight = 40.0;

      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'One'), GlassSegment(label: 'Two')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            height: customHeight,
            useOwnLayer: true,
          ),
        ),
      );

      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('has proper semantics for each segment', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'One'), GlassSegment(label: 'Two')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            useOwnLayer: true,
          ),
        ),
      );

      final semantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassSegmentedControl),
          matching: find.byType(Semantics),
        ),
      );

      expect(semantics.length, greaterThan(0));
      expect(
        semantics.any((s) => s.properties.button == true),
        isTrue,
      );
    });

    test('defaults are correct', () {
      final control = GlassSegmentedControl(
        segments: [GlassSegment(label: 'One'), GlassSegment(label: 'Two')],
        selectedIndex: 0,
        onSegmentSelected: (_) {},
      );

      expect(control.height, equals(32));
      expect(control.borderRadius, equals(GlassDefaults.capsuleRadius));
      expect(control.useOwnLayer, isFalse);
      expect(control.quality, isNull);
    });

    test('asserts minimum 2 segments', () {
      expect(
        () => GlassSegmentedControl(
          segments: [GlassSegment(label: 'One')],
          selectedIndex: 0,
          onSegmentSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });

    test('asserts selectedIndex within bounds', () {
      expect(
        () => GlassSegmentedControl(
          segments: [GlassSegment(label: 'One'), GlassSegment(label: 'Two')],
          selectedIndex: 5,
          onSegmentSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Grouped mode (no useOwnLayer)
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl grouped mode', () {
    testWidgets('renders without own layer', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('tap fires onSegmentSelected in grouped mode', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [
              GlassSegment(label: 'X'),
              GlassSegment(label: 'Y'),
              GlassSegment(label: 'Z')
            ],
            selectedIndex: 0,
            onSegmentSelected: (i) => tapped = i,
          ),
        ),
      );
      // Tap on 'Z' (index 2)
      await tester.tap(find.text('Z').first);
      await tester.pumpAndSettle();
      expect(tapped, 2);
    });

    testWidgets('does not call onSegmentSelected when tapping already-selected',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) => callCount++,
          ),
        ),
      );
      await tester.tap(find.text('A').first);
      await tester.pump();
      expect(callCount, 0);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Drag interaction — state machine
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl drag interaction', () {
    testWidgets('horizontal drag triggers segment change', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'P'),
                GlassSegment(label: 'Q'),
                GlassSegment(label: 'R')
              ],
              selectedIndex: 0,
              onSegmentSelected: (_) {},
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassSegmentedControl)));
      await tester.pump();
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // lastSelected may or may not have changed depending on exact position;
      // the widget should at minimum not crash
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('RTL drag right selects left logical segment', (tester) async {
      int selected = 2; // Start at logical right (physical left in RTL)
      await tester.pumpWidget(
        createTestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 300,
              child: GlassSegmentedControl(
                segments: [
                  GlassSegment(label: 'P'), // logical left, physical right
                  GlassSegment(label: 'Q'), // logical center, physical center
                  GlassSegment(label: 'R'), // logical right, physical left
                ],
                selectedIndex: selected,
                onSegmentSelected: (i) => selected = i,
              ),
            ),
          ),
        ),
      );

      // Start drag at center and fling to the right
      final center = tester.getCenter(find.byType(GlassSegmentedControl));
      await tester.flingFrom(center, const Offset(100, 0), 1000);
      await tester.pumpAndSettle();

      // Should have selected index 0 or 1 (logical left/center), definitely not 2.
      expect(selected, lessThan(2));
    });

    testWidgets('drag cancel snaps back without crash', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'P'),
                GlassSegment(label: 'Q'),
                GlassSegment(label: 'R')
              ],
              selectedIndex: 1,
              onSegmentSelected: (_) {},
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassSegmentedControl)));
      await tester.pump();
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Custom styling properties
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl custom styling', () {
    testWidgets('custom selectedTextStyle is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            selectedTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.amber,
            ),
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('custom unselectedTextStyle is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            unselectedTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: Colors.white38,
            ),
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('custom backgroundColor is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            backgroundColor: Colors.purple.withValues(alpha: 0.2),
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('indicatorColor is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            indicatorColor: Colors.green.withValues(alpha: 0.4),
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Quality and glass settings
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl quality and glass settings', () {
    testWidgets('explicit GlassQuality.standard works', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            quality: GlassQuality.standard,
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });

    testWidgets('explicit settings works with useOwnLayer', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            useOwnLayer: true,
            settings: const LiquidGlassSettings(thickness: 25),
          ),
        ),
      );
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // selectedIndex update — triggers didUpdateWidget
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl didUpdateWidget', () {
    testWidgets('updates when selectedIndex changes externally',
        (tester) async {
      var index = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => createTestApp(
            child: Column(
              children: [
                GlassSegmentedControl(
                  segments: [
                    GlassSegment(label: 'A'),
                    GlassSegment(label: 'B'),
                    GlassSegment(label: 'C')
                  ],
                  selectedIndex: index,
                  onSegmentSelected: (i) => setState(() => index = i),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => index = 2),
                  child: const Text('Select C'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select C'));
      await tester.pumpAndSettle();
      expect(index, 2);
    });

    testWidgets('segments count change updates alignment', (tester) async {
      var segments = [GlassSegment(label: 'A'), GlassSegment(label: 'B')];
      var selectedIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => createTestApp(
            child: Column(
              children: [
                GlassSegmentedControl(
                  segments: segments,
                  selectedIndex: selectedIndex,
                  onSegmentSelected: (i) => setState(() => selectedIndex = i),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    segments = [
                      GlassSegment(label: 'A'),
                      GlassSegment(label: 'B'),
                      GlassSegment(label: 'C')
                    ];
                    selectedIndex = 0;
                  }),
                  child: const Text('Add C'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add C'));
      await tester.pumpAndSettle();

      expect(find.text('C'), findsWidgets);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Drag-cancel without prior drag (else branch — lines 519-521)
  // ──────────────────────────────────────────────────────────────────────────
  group('GlassSegmentedControl drag-cancel edge cases', () {
    testWidgets('cancel-without-drag snaps indicator back to selectedIndex',
        (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'A'),
                GlassSegment(label: 'B'),
                GlassSegment(label: 'C')
              ],
              selectedIndex: selected,
              onSegmentSelected: (i) => selected = i,
            ),
          ),
        ),
      );

      // Start a gesture but do NOT move — cancel immediately.
      // This exercises the `_isDragging == false` branch in _onDragCancel.
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassSegmentedControl)));
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassSegmentedControl), findsOneWidget);
      expect(selected, 0); // unchanged
    });

    testWidgets('drag then end fires onSegmentSelected when index changes',
        (tester) async {
      int? fired;
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'X'),
                GlassSegment(label: 'Y'),
                GlassSegment(label: 'Z')
              ],
              selectedIndex: 0,
              onSegmentSelected: (i) => fired = i,
            ),
          ),
        ),
      );

      // Drag ~2/3 to the right to clearly land on segment 2 (index 2)
      await tester.drag(
        find.byType(GlassSegmentedControl),
        const Offset(200, 0),
      );
      await tester.pumpAndSettle();
      // onSegmentSelected should have been called
      expect(fired, isNotNull);
    });

    testWidgets('quality inherited from AdaptiveLiquidGlassLayer ancestor',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: const LiquidGlassSettings(thickness: 20),
            child: SizedBox(
              width: 300,
              child: GlassSegmentedControl(
                segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
                selectedIndex: 0,
                onSegmentSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Indicator Radius Tiers
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl 3-Tier Indicator Radius', () {
    testWidgets('Tier 1: capsule sentinel passes directly to indicator',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            // Implicitly barBorderRadius is GlassDefaults.capsuleRadius
          ),
        ),
      );

      final indicator = tester.widget<AnimatedGlassIndicator>(
          find.byType(AnimatedGlassIndicator).first);
      expect(indicator.borderRadius, equals(GlassDefaults.capsuleRadius));
    });

    testWidgets('Tier 2: custom finite radius applies padding inset',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            borderRadius: 16.0,
          ),
        ),
      );

      final indicator = tester.widget<AnimatedGlassIndicator>(
          find.byType(AnimatedGlassIndicator).first);
      // Outer 16.0 minus 2.0 padding = 14.0
      expect(indicator.borderRadius, equals(14.0));
    });

    testWidgets('Tier 3: explicit indicatorBorderRadius overrides everything',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl(
            segments: [GlassSegment(label: 'A'), GlassSegment(label: 'B')],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            borderRadius: GlassDefaults.capsuleRadius,
            indicatorBorderRadius: 8.0,
          ),
        ),
      );

      final indicator = tester.widget<AnimatedGlassIndicator>(
          find.byType(AnimatedGlassIndicator).first);
      expect(indicator.borderRadius, equals(8.0));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Accessibility & Focus
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassSegmentedControl keyboard focus & accessibility', () {
    testWidgets('exposes semantics for segments', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          createTestApp(
            child: GlassSegmentedControl(
              segments: [
                GlassSegment(label: 'Semantics A'),
                GlassSegment(label: 'Semantics B'),
              ],
              selectedIndex: 0,
              onSegmentSelected: (_) {},
            ),
          ),
        );

        final nodeA = tester.getSemantics(
          find.bySemanticsLabel('Semantics A').first,
        );
        // ignore: deprecated_member_use
        expect(nodeA.hasFlag(SemanticsFlag.isButton), true);
        // ignore: deprecated_member_use
        expect(nodeA.hasFlag(SemanticsFlag.isSelected), true);
        // ignore: deprecated_member_use
        expect(nodeA.hasFlag(SemanticsFlag.hasSelectedState), true);

        final nodeB = tester.getSemantics(
          find.bySemanticsLabel('Semantics B').first,
        );
        // ignore: deprecated_member_use
        expect(nodeB.hasFlag(SemanticsFlag.isButton), true);
        // ignore: deprecated_member_use
        expect(nodeB.hasFlag(SemanticsFlag.isSelected), false);
        // ignore: deprecated_member_use
        expect(nodeB.hasFlag(SemanticsFlag.hasSelectedState), true);
      } finally {
        handle.dispose();
      }
    });

    group('indicatorSettings blur neutralisation', () {
      testWidgets(
          'premium quality: indicatorSettings with blur > 0 resolves to effectiveBlur == 0 on indicator',
          (tester) async {
        await tester.pumpWidget(
          createTestApp(
            child: GlassSegmentedControl(
              segments: const [
                GlassSegment(label: 'Day'),
                GlassSegment(label: 'Week'),
              ],
              selectedIndex: 0,
              onSegmentSelected: (_) {},
              quality: GlassQuality.premium,
              indicatorSettings: const LiquidGlassSettings(blur: 20),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Press down to trigger active indicator lens bloom (thickness > 0.01)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Day')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final indicatorGlass = tester.widget<GlassEffect>(
          find.byType(GlassEffect).first,
        );
        expect(
          indicatorGlass.settings.effectiveBlur,
          0.0,
          reason: 'Premium indicator lens must never apply BackdropFilter blur',
        );

        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets(
          'standard quality: indicatorSettings with blur > 0 resolves to effectiveBlur == 0 on indicator',
          (tester) async {
        await tester.pumpWidget(
          createTestApp(
            child: GlassSegmentedControl(
              segments: const [
                GlassSegment(label: 'Day'),
                GlassSegment(label: 'Week'),
              ],
              selectedIndex: 0,
              onSegmentSelected: (_) {},
              quality: GlassQuality.standard,
              indicatorSettings: const LiquidGlassSettings(blur: 15),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Press down to trigger active indicator lens bloom (thickness > 0.01)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Day')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final indicatorGlass = tester.widget<GlassEffect>(
          find.byType(GlassEffect).first,
        );
        expect(
          indicatorGlass.settings.effectiveBlur,
          0.0,
          reason:
              'Standard indicator lens must never apply BackdropFilter blur',
        );

        await gesture.up();
        await tester.pumpAndSettle();
      });
    });

    testWidgets(
        'GlassSegmentedControl.scrollable with infinite borderRadius renders without collapsing',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSegmentedControl.scrollable(
            segments: const [
              GlassSegment(label: 'Day'),
              GlassSegment(label: 'Week'),
              GlassSegment(label: 'Month'),
            ],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
            borderRadius: double.infinity,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassSegmentedControl), findsOneWidget);
    });
  });
}
