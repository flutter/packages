import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassAppBar.buttonSettings', () {
    testWidgets('wraps content in DefaultButtonSettings when provided',
        (tester) async {
      const testSettings = LiquidGlassSettings(
        blur: 42,
        thickness: 99,
      );

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: Scaffold(
              appBar: GlassAppBar(
                title: const Text('Title'),
                buttonSettings: testSettings,
              ),
            ),
          ),
        ),
      );

      // DefaultButtonSettings should be in the tree.
      expect(find.byType(DefaultButtonSettings), findsOneWidget);

      // The settings should match what we passed.
      final scope = tester.widget<DefaultButtonSettings>(
        find.byType(DefaultButtonSettings),
      );
      expect(scope.settings.blur, equals(42.0));
      expect(scope.settings.thickness, equals(99.0));
    });

    testWidgets('does not insert DefaultButtonSettings when null',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const Scaffold(
              appBar: GlassAppBar(
                title: Text('Title'),
                // No buttonSettings — default is null.
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DefaultButtonSettings), findsNothing);
    });
  });

  group('DefaultButtonSettings', () {
    testWidgets('.of returns settings from ancestor', (tester) async {
      LiquidGlassSettings? inherited;
      const testSettings = LiquidGlassSettings(blur: 77);

      await tester.pumpWidget(
        createTestApp(
          child: DefaultButtonSettings(
            settings: testSettings,
            child: Builder(
              builder: (context) {
                inherited = DefaultButtonSettings.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(inherited, isNotNull);
      expect(inherited!.blur, equals(77.0));
    });

    testWidgets('.of returns null when no ancestor exists', (tester) async {
      LiquidGlassSettings? inherited;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              inherited = DefaultButtonSettings.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(inherited, isNull);
    });

    testWidgets('updateShouldNotify returns true when settings change',
        (tester) async {
      const settingsA = LiquidGlassSettings(blur: 1);
      const settingsB = LiquidGlassSettings(blur: 2);

      final widgetA = DefaultButtonSettings(
        settings: settingsA,
        child: const SizedBox.shrink(),
      );
      final widgetB = DefaultButtonSettings(
        settings: settingsB,
        child: const SizedBox.shrink(),
      );

      expect(widgetB.updateShouldNotify(widgetA), isTrue);
    });

    testWidgets('updateShouldNotify returns false when settings are the same',
        (tester) async {
      const settingsA = LiquidGlassSettings(blur: 1);
      const settingsB = LiquidGlassSettings(blur: 1);

      final widgetA = DefaultButtonSettings(
        settings: settingsA,
        child: const SizedBox.shrink(),
      );
      final widgetB = DefaultButtonSettings(
        settings: settingsB,
        child: const SizedBox.shrink(),
      );

      expect(widgetB.updateShouldNotify(widgetA), isFalse);
    });
  });
}
