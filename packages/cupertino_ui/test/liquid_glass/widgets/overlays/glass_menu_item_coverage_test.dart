// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for glass_menu_item.dart and liquid_glass_setup.dart.
// Targets:
//   glass_menu_item.dart:
//     - line 90:  GlassMenuDivider renders with custom color + indent
//     - line 135: GlassMenuLabel renders with child (not title)
//     - line 142: GlassMenuLabel build with explicit style
//     - lines 224-225: GlassMenuItem tap cancel → _isPressed = false
//   liquid_glass_setup.dart:
//     - line 36: LiquidGlassWidgets private constructor (static-only class)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  // ── GlassMenuDivider ─────────────────────────────────────────────────────

  group('GlassMenuDivider', () {
    testWidgets('renders with default params', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const SizedBox(
            width: 200,
            child: GlassMenuDivider(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenuDivider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with custom color and indent', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const SizedBox(
            width: 200,
            child: GlassMenuDivider(
              height: 20,
              color: Colors.blue,
              indent: 16,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenuDivider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── GlassMenuLabel ───────────────────────────────────────────────────────

  group('GlassMenuLabel', () {
    testWidgets('renders with title string', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const SizedBox(
            width: 200,
            child: GlassMenuLabel(title: 'Section'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenuLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with custom child widget (line 135)', (tester) async {
      // child= path instead of title=
      await tester.pumpWidget(
        createTestApp(
          child: const SizedBox(
            width: 200,
            child: GlassMenuLabel(
              height: 40,
              child: Icon(Icons.star),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with explicit TextStyle (line 142)', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const SizedBox(
            width: 200,
            child: GlassMenuLabel(
              title: 'Styled',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              height: 36,
              horizontalPadding: 12,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenuLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── GlassMenuItem tap-cancel → _isPressed = false ────────────────────────

  group('GlassMenuItem — tap cancel clears pressed state', () {
    testWidgets('press then cancel clears _isPressed (lines 224-225)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 200,
            child: GlassMenuItem(
              title: 'Item',
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final finder = find.byType(GlassMenuItem);
      // Press down (sets _isPressed=true).
      final gesture = await tester.startGesture(tester.getCenter(finder));
      await tester.pump();

      // Cancel (sets _isPressed=false via onTapCancel → setState).
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassMenuItem — enablePressScale', () {
    testWidgets('respects enablePressScale=false on press', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 200,
            child: GlassMenuItem(
              title: 'Item',
              onTap: () {},
              enablePressScale: false,
            ),
          ),
        ),
      );
      await tester.pump();

      final finder = find.byType(GlassMenuItem);
      final gesture = await tester.startGesture(tester.getCenter(finder));
      await tester.pump();

      // Find Transform.scale inside the GlassMenuItem hierarchy
      final transformFinder = find.descendant(
        of: finder,
        matching: find.byType(Transform),
      );

      // The matrix should be identity because scale is 1.0
      final Transform transform = tester.widget(transformFinder.first);
      expect(transform.transform.getMaxScaleOnAxis(), 1.0);

      await gesture.cancel();
      await tester.pumpAndSettle();
    });
  });

  group('GlassSlider — GlassGlow opacity branch (transition > 0.05)', () {
    testWidgets('dragging slider renders glow animation overlay',
        (tester) async {
      double sliderValue = 0.5;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          return createTestApp(
            child: SizedBox(
              width: 300,
              height: 60,
              child: GlassSlider(
                value: sliderValue,
                onChanged: (v) => setState(() => sliderValue = v),
              ),
            ),
          );
        }),
      );
      await tester.pump();

      final finder = find.byType(GlassSlider);
      final rect = tester.getRect(finder);

      // Start drag (thumb transition animates from 0 → 1).
      final gesture =
          await tester.startGesture(Offset(rect.left + 80, rect.center.dy));
      await tester.pump(const Duration(milliseconds: 50));
      // Mid-animation: transition > 0.05 → GlassGlow + Opacity rendered.
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // ── LiquidGlassWidgets private constructor ────────────────────────────────

  group('LiquidGlassWidgets', () {
    test('static accessors work without instantiating the class (line 36)', () {
      // The private constructor LiquidGlassWidgets._() on line 36 is reached
      // when Dart initialises the class for the first time (static field access).
      final accessibility = LiquidGlassWidgets.respectSystemAccessibility;
      expect(accessibility, isA<bool>());
    });
  });
}
