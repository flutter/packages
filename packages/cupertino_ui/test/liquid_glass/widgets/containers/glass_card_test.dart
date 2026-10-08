import 'package:liquid_glass_widgets/widgets/containers/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassCard', () {
    testWidgets('can be instantiated with default parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassCard(),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('displays child widget', (tester) async {
      const testText = 'Card Content';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassCard(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('has default padding of 16', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassCard(
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('respects custom padding', (tester) async {
      const customPadding = EdgeInsets.all(32);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassCard(
              padding: customPadding,
              child: Text('Custom Padding'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassCard(
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            child: Text('Standalone Card'),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });

    test('defaults are correct', () {
      const card = GlassCard();

      expect(card.padding, equals(const EdgeInsets.all(16)));
      expect(card.useOwnLayer, isFalse);
      expect(card.quality, isNull);
    });
  });
}
