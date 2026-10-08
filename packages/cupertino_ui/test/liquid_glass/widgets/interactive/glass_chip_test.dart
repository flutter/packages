// ignore: unnecessary_import
import 'dart:ui';
import 'package:liquid_glass_widgets/widgets/interactive/glass_chip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassChip', () {
    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassChip(
              label: 'Test Chip',
            ),
          ),
        ),
      );

      expect(find.byType(GlassChip), findsOneWidget);
      expect(find.text('Test Chip'), findsOneWidget);
    });

    testWidgets('displays label correctly', (tester) async {
      const testLabel = 'Flutter';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassChip(
              label: testLabel,
            ),
          ),
        ),
      );

      expect(find.text(testLabel), findsOneWidget);
    });

    testWidgets('displays leading icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassChip(
              label: 'Favorite',
              icon: Icon(CupertinoIcons.heart_fill),
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
    });

    testWidgets('displays delete button when onDeleted provided',
        (tester) async {
      var deleted = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassChip(
              label: 'Tag',
              onDeleted: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassChip(
              label: 'Filter',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassChip));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows selection state when selected', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassChip(
              label: 'Selected',
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassChip), findsOneWidget);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassChip(
            label: 'Standalone',
            useOwnLayer: true,
          ),
        ),
      );

      expect(find.byType(GlassChip), findsOneWidget);
    });

    test('defaults are correct', () {
      final chip = GlassChip(
        label: 'Test',
      );

      expect(chip.selected, isFalse);
      expect(chip.useOwnLayer, isFalse);
      expect(chip.quality, isNull);
      expect(chip.interactionScale, equals(1.03));
      expect(chip.stretch, equals(0.3));
      expect(chip.glowRadius, equals(0.8));
    });

    group('keyboard focus & accessibility', () {
      testWidgets('Space key triggers onTap when focused', (tester) async {
        bool tapped = false;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassChip(
                label: 'Chip',
                onTap: () => tapped = true,
                focusNode: focusNode,
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('Enter key triggers onTap when focused', (tester) async {
        bool tapped = false;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassChip(
                label: 'Chip',
                onTap: () => tapped = true,
                focusNode: focusNode,
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('exposes chip semantics', (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            createTestApp(
              child: GlassChip(
                label: 'Test Chip',
                semanticLabel: 'Semantics Chip',
                onTap: () {},
              ),
            ),
          );

          final node =
              tester.getSemantics(find.bySemanticsLabel('Semantics Chip'));
          // ignore: deprecated_member_use
          expect(node.hasFlag(SemanticsFlag.isButton), true);
          // ignore: deprecated_member_use
          expect(node.hasFlag(SemanticsFlag.isEnabled), true);
          // ignore: deprecated_member_use
          expect(node.hasFlag(SemanticsFlag.isFocusable), true);
        } finally {
          handle.dispose();
        }
      });
    });
  });
}
