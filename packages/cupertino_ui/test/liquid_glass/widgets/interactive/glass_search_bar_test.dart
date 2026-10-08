import 'package:liquid_glass_widgets/widgets/input/glass_search_bar.dart';
import 'package:liquid_glass_widgets/widgets/input/glass_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassSearchBar', () {
    testWidgets('can be instantiated with default parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassSearchBar(),
          ),
        ),
      );

      expect(find.byType(GlassSearchBar), findsOneWidget);
    });

    testWidgets('displays placeholder text', (tester) async {
      const placeholder = 'Search messages';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassSearchBar(
              placeholder: placeholder,
            ),
          ),
        ),
      );

      expect(find.text(placeholder), findsOneWidget);
    });

    testWidgets('displays search icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassSearchBar(),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      var searchText = '';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSearchBar(
              onChanged: (value) => searchText = value,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(CupertinoTextField).first,
        'flutter',
      );

      expect(searchText, equals('flutter'));
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassSearchBar(),
          ),
        ),
      );

      // Initially, clear button should not be visible (opacity 0)
      await tester.enterText(find.byType(CupertinoTextField).first, 'test');
      await tester.pumpAndSettle();

      // Clear button should now be visible
      expect(find.byIcon(CupertinoIcons.clear_circled_solid), findsOneWidget);
    });

    testWidgets('clears text when clear button is tapped', (tester) async {
      final controller = TextEditingController(text: 'initial text');

      await tester.pumpWidget(
        createTestApp(
          child: Center(
            child: SizedBox(
              width: 300,
              child: AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSearchBar(
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the clear button by looking for the GestureDetector with the clear icon
      final clearIcon = find.descendant(
        of: find.byType(GlassTextField),
        matching: find.byIcon(CupertinoIcons.clear_circled_solid),
      );

      // The GestureDetector is the parent of the Opacity which contains the icon
      await tester.tap(clearIcon.hitTestable());
      await tester.pumpAndSettle();

      expect(controller.text, isEmpty);
    });

    testWidgets('shows cancel button when focused and showsCancelButton true',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Center(
            child: SizedBox(
              width: 400,
              child: AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: const GlassSearchBar(
                  showsCancelButton: true,
                  autofocus: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for autofocus and animations
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Cancel button appears as a glass icon (×), not text
      expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
    });

    testWidgets('calls onCancel when cancel button is tapped', (tester) async {
      var cancelled = false;

      await tester.pumpWidget(
        createTestApp(
          child: Center(
            child: SizedBox(
              width: 400,
              child: AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSearchBar(
                  showsCancelButton: true,
                  autofocus: true,
                  onCancel: () => cancelled = true,
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for autofocus and animations
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap cancel icon
      await tester.tap(find.byIcon(CupertinoIcons.xmark));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassSearchBar(
            useOwnLayer: true,
          ),
        ),
      );

      expect(find.byType(GlassSearchBar), findsOneWidget);
    });

    test('defaults are correct', () {
      const searchBar = GlassSearchBar();

      expect(searchBar.placeholder, equals('Search'));
      expect(searchBar.showsCancelButton, isFalse);
      expect(searchBar.autofocus, isFalse);
      expect(searchBar.enabled, isTrue);
      expect(searchBar.height, equals(44.0));
      expect(searchBar.useOwnLayer, isFalse);
      expect(searchBar.quality, isNull);
      expect(searchBar.cancelIconSize, equals(24.0));
      expect(searchBar.cancelIcon, isNull);
    });

    testWidgets('respects cancelIconSize for the cancel button icon',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Center(
            child: SizedBox(
              width: 400,
              child: AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: const GlassSearchBar(
                  showsCancelButton: true,
                  autofocus: true,
                  cancelIconSize: 28,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The × icon should be present with size 28
      final icon = tester.widget<Icon>(
        find.byWidgetPredicate(
          (w) => w is Icon && w.icon == CupertinoIcons.xmark,
        ),
      );
      expect(icon.size, equals(28.0));
    });

    testWidgets('uses cancelIcon widget when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Center(
            child: SizedBox(
              width: 400,
              child: AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: const GlassSearchBar(
                  showsCancelButton: true,
                  autofocus: true,
                  cancelIcon: Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Custom icon is used — xmark_circle_fill should appear, not plain xmark
      expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.xmark), findsNothing);
    });
  });
}
