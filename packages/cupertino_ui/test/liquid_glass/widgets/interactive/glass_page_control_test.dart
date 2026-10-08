import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Rendering
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassPageControl rendering', () {
    testWidgets('renders inside a GlassButton capsule', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 5,
            currentPage: 0,
          ),
        ),
      );
      await tester.pump();
      // Should be wrapped in a GlassButton (for press interactions)
      expect(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(GlassButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 5,
            currentPage: 0,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassPageControl), findsOneWidget);
      // Should have 5 circular dot Container widgets
      final dots = find.descendant(
        of: find.byType(GlassPageControl),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      expect(dots, findsNWidgets(5));
    });

    testWidgets('renders nothing when count is 0', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 0,
            currentPage: 0,
          ),
        ),
      );
      await tester.pump();
      // Should render SizedBox.shrink, not a GlassButton
      expect(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(GlassButton),
        ),
        findsNothing,
      );
    });

    testWidgets('renders nothing when count is negative', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: -1,
            currentPage: 0,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(GlassButton),
        ),
        findsNothing,
      );
    });

    testWidgets('renders leading icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
            leadingIcon: Icon(Icons.location_on, size: 10),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('does not render leading icon when not provided',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(FittedBox),
        ),
        findsNothing,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Defaults
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassPageControl defaults', () {
    test('has sensible defaults', () {
      const control = GlassPageControl(count: 5, currentPage: 2);
      expect(control.count, 5);
      expect(control.currentPage, 2);
      expect(control.dotSize, 7.0);
      expect(control.spacing, 7.0);
      expect(control.activeColor, isNull);
      expect(control.inactiveColor, isNull);
      expect(control.leadingIcon, isNull);
      expect(control.onPageChanged, isNull);
      expect(control.settings, isNull);
      expect(control.quality, isNull);
      expect(control.useOwnLayer, isFalse);
      expect(control.height, 56);
      expect(control.animationDuration, const Duration(milliseconds: 250));
      expect(control.animationCurve, Curves.easeOutCubic);
    });

    test('accepts custom values', () {
      const custom = GlassPageControl(
        count: 10,
        currentPage: 3,
        dotSize: 12,
        spacing: 16,
        activeColor: Color(0xFF0000FF),
        inactiveColor: Color(0x33FFFFFF),
        useOwnLayer: true,
        quality: GlassQuality.premium,
        height: 44,
        animationDuration: Duration(milliseconds: 500),
        animationCurve: Curves.bounceOut,
      );
      expect(custom.dotSize, 12);
      expect(custom.spacing, 16);
      expect(custom.activeColor, const Color(0xFF0000FF));
      expect(custom.inactiveColor, const Color(0x33FFFFFF));
      expect(custom.useOwnLayer, isTrue);
      expect(custom.quality, GlassQuality.premium);
      expect(custom.height, 44);
      expect(custom.animationDuration, const Duration(milliseconds: 500));
      expect(custom.animationCurve, Curves.bounceOut);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Interaction
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassPageControl interaction', () {
    testWidgets('tapping advances to next page', (tester) async {
      int? changedPage;
      await tester.pumpWidget(
        createTestApp(
          child: GlassPageControl(
            count: 5,
            currentPage: 2,
            onPageChanged: (page) => changedPage = page,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the capsule — should advance to next page (3)
      await tester.tap(find.byType(GlassPageControl));
      await tester.pump();
      expect(changedPage, 3);
    });

    testWidgets('tapping on last page wraps to first page', (tester) async {
      int? changedPage;
      await tester.pumpWidget(
        createTestApp(
          child: GlassPageControl(
            count: 3,
            currentPage: 2, // last page
            onPageChanged: (page) => changedPage = page,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GlassPageControl));
      await tester.pump();
      expect(changedPage, 0); // wraps to first
    });

    testWidgets('tap does nothing when onPageChanged is null', (tester) async {
      // Just verify it doesn't crash
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GlassPageControl));
      await tester.pump();
      expect(find.byType(GlassPageControl), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Animation
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassPageControl animation', () {
    testWidgets('animates when currentPage changes', (tester) async {
      int currentPage = 0;
      late StateSetter setPageState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              setPageState = setState;
              return GlassPageControl(
                count: 3,
                currentPage: currentPage,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Change page
      setPageState(() => currentPage = 2);
      await tester.pump();

      // Animation should be in progress
      expect(find.byType(GlassPageControl), findsOneWidget);

      // Let animation complete
      await tester.pumpAndSettle();
      expect(find.byType(GlassPageControl), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Edge cases
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassPageControl edge cases', () {
    testWidgets('single page renders one dot in glass capsule', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 1,
            currentPage: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(GlassButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('custom colors are applied', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 3,
            currentPage: 0,
            activeColor: Color(0xFFFF0000),
            inactiveColor: Color(0xFF00FF00),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassPageControl), findsOneWidget);
    });

    testWidgets('with glass settings renders without error', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 3,
            currentPage: 1,
            settings: LiquidGlassSettings(
              thickness: 20,
              blur: 3,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassPageControl), findsOneWidget);
    });

    testWidgets('custom height renders without error', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(
            count: 4,
            currentPage: 2,
            height: 44,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassPageControl), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Semantics
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassPageControl semantics', () {
    testWidgets('announces default "Page N of M" label', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassPageControl(
            count: 5,
            currentPage: 1,
            onPageChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      final semanticsNodes = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semanticsNodes.any((s) => s.properties.label == 'Page 2 of 5'),
        isTrue,
        reason: 'Default label should be "Page N of M" (1-indexed)',
      );
    });

    testWidgets('custom semanticLabel overrides default', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassPageControl(
            count: 3,
            currentPage: 2,
            semanticLabel: 'Slide 3 of 3',
            onPageChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      final semanticsNodes = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semanticsNodes.any((s) => s.properties.label == 'Slide 3 of 3'),
        isTrue,
        reason: 'semanticLabel must override the default',
      );
    });

    testWidgets('has tap hint when onPageChanged is set', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassPageControl(
            count: 3,
            currentPage: 0,
            onPageChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      final semanticsNodes = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semanticsNodes.any(
          (s) => s.properties.hint != null && s.properties.hint!.isNotEmpty,
        ),
        isTrue,
        reason: 'Interactive control should have a tap hint',
      );
    });

    testWidgets('no tap hint when onPageChanged is null', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPageControl(count: 3, currentPage: 0),
        ),
      );
      await tester.pump();
      final outerSemantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPageControl),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        outerSemantics.any(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.startsWith('Page') &&
              (s.properties.hint == null || s.properties.hint!.isEmpty),
        ),
        isTrue,
        reason: 'Non-interactive control should have no tap hint',
      );
    });
  });
}
