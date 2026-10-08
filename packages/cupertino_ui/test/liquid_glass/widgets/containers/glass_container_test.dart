import 'package:liquid_glass_widgets/widgets/containers/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassContainer', () {
    testWidgets('can be instantiated with default parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassContainer(),
          ),
        ),
      );

      expect(find.byType(GlassContainer), findsOneWidget);
    });

    testWidgets('displays child widget', (tester) async {
      const testText = 'Container Content';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassContainer(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('respects padding', (tester) async {
      const padding = EdgeInsets.all(20);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassContainer(
              padding: padding,
              child: Text('Padded'),
            ),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassContainer),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(paddingWidget.padding, equals(padding));
    });

    testWidgets('respects width and height', (tester) async {
      const width = 200.0;
      const height = 150.0;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassContainer(
              width: width,
              height: height,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(GlassContainer),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, equals(width));
      expect(sizedBox.height, equals(height));
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassContainer(
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            child: Text('Standalone'),
          ),
        ),
      );

      expect(find.byType(GlassContainer), findsOneWidget);
    });

    test('defaults are correct', () {
      const container = GlassContainer();

      expect(container.useOwnLayer, isFalse);
      expect(container.quality, isNull);
      expect(container.clipBehavior, equals(Clip.none));
    });

    testWidgets('applies alignment to child content (line 226-229)',
        (tester) async {
      // GlassContainer wraps content in Align when alignment != null
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassContainer(
              width: 300,
              height: 200,
              alignment: Alignment.topRight,
              child: Text('Aligned'),
            ),
          ),
        ),
      );

      expect(find.text('Aligned'), findsOneWidget);
      // Align widget should be in the tree
      expect(
        find.descendant(
          of: find.byType(GlassContainer),
          matching: find.byType(Align),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('applies margin outside glass shell (line 262-265)',
        (tester) async {
      // GlassContainer wraps in Padding when margin != null
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassContainer(
              margin: EdgeInsets.all(16),
              child: Text('Margined'),
            ),
          ),
        ),
      );

      expect(find.text('Margined'), findsOneWidget);
    });
  });
}
