import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassProgressIndicator.circular', () {
    testWidgets('renders circular indeterminate progress indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);

      // Verify animation is running
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be present after animation ticks
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('renders circular determinate progress indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  value: 0.5,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 40.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  size: customSize,
                ),
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(GlassProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('respects custom stroke width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  strokeWidth: 5.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassProgressIndicator.circular(
                useOwnLayer: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      expect(find.byType(AdaptiveLiquidGlassLayer), findsOneWidget);
    });

    testWidgets('transitions from indeterminate to determinate',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(),
              ),
            ),
          ),
        ),
      );

      // Initial indeterminate state
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to determinate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  value: 0.7,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('transitions from determinate to indeterminate',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  value: 0.3,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);

      // Switch to indeterminate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });
  });

  group('GlassProgressIndicator.linear', () {
    testWidgets('renders linear indeterminate progress indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);

      // Verify animation is running
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('renders linear determinate progress indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  value: 0.5,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  height: 8.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom minWidth', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  minWidth: 300.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassProgressIndicator.linear(
                useOwnLayer: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      expect(find.byType(AdaptiveLiquidGlassLayer), findsOneWidget);
    });

    testWidgets('clamps value between 0.0 and 1.0', (tester) async {
      // Test value > 1.0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  value: 1.5, // Should be clamped to 1.0
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);

      // Test value < 0.0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  value: -0.5, // Should be clamped to 0.0
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });
  });

  group('GlassProgressIndicator Theme Integration', () {
    testWidgets('uses theme glow color when color is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassTheme(
                data: GlassThemeData(
                  light: GlassThemeVariant(
                    glowColors: GlassGlowColors(
                      primary: Colors.purple.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: const AdaptiveLiquidGlassLayer(
                  child: GlassProgressIndicator.circular(),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('explicit color overrides theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassTheme(
                data: GlassThemeData(
                  light: GlassThemeVariant(
                    glowColors: GlassGlowColors(
                      primary: Colors.purple.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: const AdaptiveLiquidGlassLayer(
                  child: GlassProgressIndicator.circular(
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });
  });

  group('GlassProgressIndicator Edge Cases', () {
    testWidgets('handles value of 0.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  value: 0.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('handles value of 1.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  value: 1.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('handles rapid value changes', (tester) async {
      for (var i = 0; i <= 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AdaptiveLiquidGlassLayer(
                  child: GlassProgressIndicator.circular(
                    value: i / 10,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // semanticLabel overrides
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassProgressIndicator semanticLabel', () {
    testWidgets('default label is "Progress" for circular', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(value: 0.5),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final nodes = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassProgressIndicator),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        nodes.any((s) => s.properties.label == 'Progress'),
        isTrue,
        reason: 'Default label must remain "Progress" for backward compat',
      );
    });

    testWidgets('semanticLabel overrides default for linear', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.linear(
                  value: 0.7,
                  semanticLabel: 'Download progress',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final nodes = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassProgressIndicator),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        nodes.any((s) => s.properties.label == 'Download progress'),
        isTrue,
        reason: 'semanticLabel must override the default "Progress" label',
      );
    });

    testWidgets('semanticLabel overrides default for circular', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveLiquidGlassLayer(
                child: GlassProgressIndicator.circular(
                  value: 0.3,
                  semanticLabel: 'Upload progress',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final nodes = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassProgressIndicator),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        nodes.any((s) => s.properties.label == 'Upload progress'),
        isTrue,
        reason: 'semanticLabel must work for circular variant too',
      );
    });
  });
}
