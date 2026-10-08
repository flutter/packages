import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/interactive/liquid_glass_scope.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('LiquidGlassScope', () {
    testWidgets('can be instantiated with a child', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(LiquidGlassScope), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: const Text('Test Content'),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('provides background key to descendants via static of() method',
        (tester) async {
      GlobalKey? foundKey;

      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: Builder(
              builder: (context) {
                foundKey = LiquidGlassScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(foundKey, isNotNull);
    });

    testWidgets('returns null when no scope is present', (tester) async {
      GlobalKey? foundKey;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              foundKey = LiquidGlassScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foundKey, isNull);
    });

    testWidgets('nested scope overrides parent scope', (tester) async {
      GlobalKey? innerKey;
      GlobalKey? outerKey;

      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: Builder(
              builder: (outerContext) {
                outerKey = LiquidGlassScope.of(outerContext);

                return LiquidGlassScope(
                  child: Builder(
                    builder: (innerContext) {
                      innerKey = LiquidGlassScope.of(innerContext);
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Both scopes should provide keys
      expect(outerKey, isNotNull);
      expect(innerKey, isNotNull);
      // Inner key should be different from outer key
      expect(innerKey, isNot(equals(outerKey)));
    });

    testWidgets('maintains stable key across rebuilds', (tester) async {
      GlobalKey? firstKey;
      GlobalKey? secondKey;

      final controller = ValueNotifier(0);

      await tester.pumpWidget(
        createTestApp(
          child: ValueListenableBuilder<int>(
            valueListenable: controller,
            builder: (context, value, _) {
              return LiquidGlassScope(
                child: Builder(
                  builder: (context) {
                    final key = LiquidGlassScope.of(context);
                    if (value == 0) {
                      firstKey = key;
                    } else {
                      secondKey = key;
                    }
                    return Text('Value: $value');
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(firstKey, isNotNull);

      // Trigger rebuild
      controller.value = 1;
      await tester.pump();

      expect(secondKey, isNotNull);
      // Key should be the same after rebuild (stable)
      expect(firstKey, equals(secondKey));
    });

    testWidgets('different instances have different keys', (tester) async {
      GlobalKey? key1;
      GlobalKey? key2;

      await tester.pumpWidget(
        createTestApp(
          child: Row(
            children: [
              LiquidGlassScope(
                child: Builder(
                  builder: (context) {
                    key1 = LiquidGlassScope.of(context);
                    return const SizedBox(width: 50);
                  },
                ),
              ),
              LiquidGlassScope(
                child: Builder(
                  builder: (context) {
                    key2 = LiquidGlassScope.of(context);
                    return const SizedBox(width: 50);
                  },
                ),
              ),
            ],
          ),
        ),
      );

      expect(key1, isNotNull);
      expect(key2, isNotNull);
      expect(key1, isNot(equals(key2)));
    });
  });

  group('GlassBackgroundSource', () {
    testWidgets('can be instantiated with a child', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: GlassBackgroundSource(
              child: Container(
                width: 200,
                height: 200,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GlassBackgroundSource), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('wraps child in RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: GlassBackgroundSource(
              child: const Text('Background Content'),
            ),
          ),
        ),
      );

      // Should find RepaintBoundary as part of GlassBackgroundSource
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(find.text('Background Content'), findsOneWidget);
    });

    testWidgets('works without LiquidGlassScope (standalone)', (tester) async {
      // GlassBackgroundSource should work standalone, just without the shared key
      await tester.pumpWidget(
        createTestApp(
          child: GlassBackgroundSource(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.byType(GlassBackgroundSource), findsOneWidget);
    });

    testWidgets('renders child content correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: GlassBackgroundSource(
              child: Column(
                children: const [
                  Text('Line 1'),
                  Text('Line 2'),
                  Text('Line 3'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
      expect(find.text('Line 3'), findsOneWidget);
    });

    testWidgets('uses key from LiquidGlassScope when available',
        (tester) async {
      GlobalKey? scopeKey;

      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: Builder(
              builder: (context) {
                scopeKey = LiquidGlassScope.of(context);
                return GlassBackgroundSource(
                  child: const SizedBox(width: 100, height: 100),
                );
              },
            ),
          ),
        ),
      );

      expect(scopeKey, isNotNull);
      expect(find.byType(GlassBackgroundSource), findsOneWidget);
    });
  });

  group('Integration: Scope + Background', () {
    testWidgets('scope and background work together', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: Stack(
              children: [
                GlassBackgroundSource(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.blue,
                  ),
                ),
                const Center(
                  child: Text('Overlay Content'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LiquidGlassScope), findsOneWidget);
      expect(find.byType(GlassBackgroundSource), findsOneWidget);
      expect(find.text('Overlay Content'), findsOneWidget);
    });

    testWidgets('multiple backgrounds require separate scopes', (tester) async {
      // Each GlassBackgroundSource should have its own LiquidGlassScope
      await tester.pumpWidget(
        createTestApp(
          child: Column(
            children: [
              LiquidGlassScope(
                child: GlassBackgroundSource(
                  child: Container(height: 100, color: Colors.red),
                ),
              ),
              LiquidGlassScope(
                child: GlassBackgroundSource(
                  child: Container(height: 100, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(GlassBackgroundSource), findsNWidgets(2));
      expect(find.byType(LiquidGlassScope), findsNWidgets(2));
    });
  });
}
