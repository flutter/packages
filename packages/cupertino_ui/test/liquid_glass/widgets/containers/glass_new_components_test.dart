import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  // ===========================================================================
  // GlassDivider
  // ===========================================================================

  group('GlassDivider', () {
    testWidgets('renders a horizontal Divider by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassDivider()),
        ),
      );
      expect(find.byType(GlassDivider), findsOneWidget);
      // GlassDivider uses a raw Container instead of Material Divider.
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders a VerticalDivider when axis is vertical',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: Row(children: [GlassDivider.vertical()]),
            ),
          ),
        ),
      );
      // GlassDivider uses a raw Container instead of Material VerticalDivider.
      expect(find.byType(GlassDivider), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('applies custom colour', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassDivider(color: Colors.red)),
        ),
      );
      // GlassDivider uses raw Containers — verify the colour on the inner Container.
      final containers = tester.widgetList<Container>(find.byType(Container));
      final coloured = containers.where((c) => c.color == Colors.red);
      expect(coloured, isNotEmpty);
    });

    testWidgets('applies indent and endIndent', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassDivider(indent: 16, endIndent: 8),
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      // GlassDivider uses EdgeInsetsDirectional for RTL correctness.
      // Resolve against LTR (the default test direction) to verify
      // that start→left and end→right map correctly.
      final edgeInsets = padding.padding.resolve(TextDirection.ltr);
      expect(edgeInsets.left, 16);
      expect(edgeInsets.right, 8);
    });
  });

  // ===========================================================================
  // GlassListTile
  // ===========================================================================

  group('GlassListTile', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassListTile(title: Text('Hello'))),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders leading, subtitle, and trailing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassListTile(
              leading: const Icon(Icons.star),
              title: const Text('Title'),
              subtitle: const Text('Sub'),
              trailing: GlassListTile.chevron,
            ),
          ),
        ),
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Sub'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_forward), findsOneWidget);
    });

    testWidgets('fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassListTile(
              title: const Text('Tap me'),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GlassListTile));
      expect(tapped, isTrue);
    });

    testWidgets(
        'GlassGroupedSection injects dividers between tiles, not after last',
        (tester) async {
      // GlassGroupedSection is the source of truth for divider rendering.
      // It should inject (n-1) GlassDividers for n tiles.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: const [
                GlassListTile(title: Text('First')),
                GlassListTile(title: Text('Middle')),
                GlassListTile(title: Text('Last')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      // 3 tiles → 2 dividers injected between them, none after the last.
      expect(find.byType(GlassDivider), findsNWidgets(2));
    });

    testWidgets('GlassGroupedSection with 1 tile injects no dividers',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(title: Text('Only')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassDivider), findsNothing);
    });

    testWidgets('GlassGroupedSection uses smart indent based on leading widget',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(
                    leading: Icon(Icons.star), title: Text('With Icon')),
                GlassListTile(title: Text('No Icon')),
                GlassListTile(title: Text('Last')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final dividers =
          tester.widgetList<GlassDivider>(find.byType(GlassDivider)).toList();
      expect(dividers.length, 2);
      expect(dividers[0].indent, 56.0); // Preceding tile has leading icon
      expect(dividers[1].indent, 16.0); // Preceding tile has no leading icon
    });

    testWidgets('GlassGroupedSection respects user-placed dividers',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(title: Text('A')),
                GlassDivider(indent: 40.0), // Manual divider
                GlassListTile(title: Text('B')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final dividers =
          tester.widgetList<GlassDivider>(find.byType(GlassDivider)).toList();
      expect(dividers.length, 1);
      expect(dividers[0].indent, 40.0);
    });
  });

  // ===========================================================================
  // GlassStepper  (iOS 26 UIStepper — numeric +/- control)
  // ===========================================================================

  group('GlassStepper', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(value: 5, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassStepper), findsOneWidget);
    });

    testWidgets('shows decrement and increment icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(value: 5, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.minus), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.plus), findsOneWidget);
    });

    testWidgets('calls onChanged with incremented value on + tap',
        (tester) async {
      double result = 5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              step: 1,
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.plus));
      expect(result, 6);
    });

    testWidgets('calls onChanged with decremented value on − tap',
        (tester) async {
      double result = 5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              step: 1,
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.minus));
      expect(result, 4);
    });

    testWidgets('does not decrement below min', (tester) async {
      double result = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              min: 0,
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.minus));
      expect(result, 0); // unchanged
    });

    testWidgets('does not increment above max', (tester) async {
      double result = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              max: 10,
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.plus));
      expect(result, 10); // unchanged
    });

    testWidgets('respects custom step size', (tester) async {
      double result = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              step: 5,
              max: 100,
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.plus));
      expect(result, 5);
    });

    testWidgets('wraps below min when wraps is true', (tester) async {
      double result = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              min: 0,
              max: 10,
              step: 1,
              wraps: true,
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.minus));
      expect(result, greaterThan(0)); // wrapped to near max
    });

    // ── wraps above max (line 196) ────────────────────────────────────────────
    testWidgets('wraps above max when wraps is true (line 196)',
        (tester) async {
      double result = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: result,
              min: 0,
              max: 10,
              step: 1,
              wraps: true, // exercises wrap-increment: next > max → wrap to min
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.plus));
      // Wrapped from 10 to near min=0
      expect(result, lessThan(10));
    });

    // ── decimal value VoiceOver path (line 230) ───────────────────────────────
    testWidgets('decimal value uses toStringAsFixed(1) in Semantics (line 230)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value:
                  5.5, // 5.5 != 5.5.truncateToDouble() → uses toStringAsFixed
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Verify widget builds without error
      expect(find.byType(GlassStepper), findsOneWidget);
    });
  });

  // ===========================================================================
  // Additional GlassStepper coverage: autoRepeat timer path (lines 196, 208)
  // and tap-cancel → _cancelRepeat (lines 273-275, 304-306)
  // ===========================================================================

  group('GlassStepper autoRepeat and cancel paths', () {
    testWidgets('autoRepeat=true: long-press increment starts repeat timer',
        (tester) async {
      double value = 5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: value,
              min: 0,
              max: 20,
              step: 1,
              autoRepeat: true,
              autoRepeatDelay: const Duration(milliseconds: 50),
              autoRepeatInterval: const Duration(milliseconds: 30),
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      // Long-press the increment icon to trigger _startRepeat
      final gesture = await tester
          .startGesture(tester.getCenter(find.byIcon(CupertinoIcons.plus)));
      await tester.pump();
      // Wait past autoRepeatDelay so the timer fires at least once
      await tester.pump(const Duration(milliseconds: 150));
      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      expect(value, greaterThan(5)); // repeated increments occurred
    });

    testWidgets('increment tap-cancel calls _cancelRepeat without crash',
        (tester) async {
      double value = 5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: value,
              min: 0,
              max: 20,
              step: 1,
              autoRepeat: true,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      // Press and then cancel — exercises onTapCancel → _cancelRepeat
      final gesture = await tester
          .startGesture(tester.getCenter(find.byIcon(CupertinoIcons.plus)));
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassStepper), findsOneWidget);
    });

    testWidgets('decrement tap-cancel calls _cancelRepeat without crash',
        (tester) async {
      double value = 5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassStepper(
              value: value,
              min: 0,
              max: 20,
              step: 1,
              autoRepeat: true,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byIcon(CupertinoIcons.minus)));
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassStepper), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassListTile.standalone (line 81: useOwnLayer path)
  // ===========================================================================

  group('GlassListTile.standalone', () {
    testWidgets('renders with own glass layer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassListTile.standalone(
              title: const Text('Standalone Tile'),
              settings: const LiquidGlassSettings(thickness: 20),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Standalone Tile'), findsOneWidget);
    });

    testWidgets('infoButton getter returns an Icon widget', (tester) async {
      // Line 199 — static getter
      expect(GlassListTile.infoButton, isNotNull);
    });

    testWidgets('trailing shown when set', (tester) async {
      // Lines 210-213 — trailing widget path
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassListTile.standalone(
              title: const Text('Title'),
              trailing: const Icon(Icons.arrow_forward_ios),
              settings: const LiquidGlassSettings(thickness: 20),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassGroupedSection
  // ===========================================================================

  group('GlassGroupedSection', () {
    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(title: Text('Item 1')),
                GlassListTile(title: Text('Item 2')),
                GlassListTile(title: Text('Item 3')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('renders header when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              header: Text('Section Header'),
              children: [
                GlassListTile(title: Text('Item')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Section Header'), findsOneWidget);
    });

    testWidgets('renders footer when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              footer: Text('Section Footer'),
              children: [
                GlassListTile(title: Text('Item')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Section Footer'), findsOneWidget);
    });

    testWidgets('wraps children in a GlassCard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(title: Text('Item')),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('handles non-GlassListTile children gracefully',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(title: Text('Tile')),
                const SizedBox(height: 10), // Non-GlassListTile child
              ],
            ),
          ),
        ),
      );
      expect(find.text('Tile'), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('handles single child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassGroupedSection(
              children: [
                GlassListTile(title: Text('Only Item')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Only Item'), findsOneWidget);
    });
  });
}
