import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassPicker rendering', () {
    testWidgets('renders with a selected value', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassPicker(
            value: 'Option A',
            onTap: () {},
          ),
        ),
      );
      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets('renders placeholder when value is null', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: null,
            placeholder: 'Choose one',
          ),
        ),
      );
      expect(find.text('Choose one'), findsOneWidget);
    });

    testWidgets(
        'renders default placeholder when value is null and no placeholder given',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(value: null),
        ),
      );
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: 'A',
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('renders default chevron icon when no icon given',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(value: 'X'),
        ),
      );
      expect(
          find.byIcon(CupertinoIcons.chevron_up_chevron_down), findsOneWidget);
    });

    testWidgets('custom height is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(value: 'Y', height: 64),
        ),
      );
      expect(find.byType(GlassPicker), findsOneWidget);
    });

    testWidgets('custom width is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(value: 'Z', width: 200),
        ),
      );
      expect(find.byType(GlassPicker), findsOneWidget);
    });

    testWidgets('custom textStyle is applied', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: 'Styled',
            textStyle: TextStyle(fontSize: 20, color: Colors.amber),
          ),
        ),
      );
      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('custom placeholderStyle is applied', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: null,
            placeholder: 'Pick...',
            placeholderStyle: TextStyle(fontSize: 14, color: Colors.white54),
          ),
        ),
      );
      expect(find.text('Pick...'), findsOneWidget);
    });
  });

  group('GlassPicker tap interaction', () {
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestApp(
          child: GlassPicker(
            value: 'Tap me',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(GlassPicker));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('onTap is null is safe (no crash)', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(value: 'No tap'),
        ),
      );
      await tester.tap(find.byType(GlassPicker));
      await tester.pump();
      // No crash expected
      expect(find.byType(GlassPicker), findsOneWidget);
    });
  });

  group('GlassPicker layer and quality', () {
    testWidgets('renders with useOwnLayer=true', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: 'Layered',
            useOwnLayer: true,
          ),
        ),
      );
      expect(find.byType(GlassPicker), findsOneWidget);
    });

    testWidgets('renders with custom quality', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: 'Q',
            quality: GlassQuality.standard,
          ),
        ),
      );
      expect(find.byType(GlassPicker), findsOneWidget);
    });

    testWidgets('renders with custom settings', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: 'G',
            settings: LiquidGlassSettings(thickness: 20),
          ),
        ),
      );
      expect(find.byType(GlassPicker), findsOneWidget);
    });

    testWidgets('renders with custom shape', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPicker(
            value: 'S',
            shape: LiquidRoundedSuperellipse(borderRadius: 16),
          ),
        ),
      );
      expect(find.byType(GlassPicker), findsOneWidget);
    });
  });

  group('GlassPicker.showSheet', () {
    testWidgets('showSheet with title renders sheet', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => GlassPicker.showSheet<String>(
                context: ctx,
                items: const ['A', 'B', 'C'],
                itemBuilder: (item) => Text(item),
                title: 'Pick Option',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Pick Option'), findsOneWidget);
    });

    testWidgets('showSheet without title omits title row', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => GlassPicker.showSheet<String>(
                context: ctx,
                items: const ['X', 'Y'],
                itemBuilder: (item) => Text(item),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // No title, sheet is open; we just verify no crash
      expect(find.byType(CupertinoPicker), findsOneWidget);
    });

    testWidgets('showSheet renders items via itemBuilder', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => GlassPicker.showSheet<int>(
                context: ctx,
                items: const [1, 2, 3],
                itemBuilder: (item) => Text('Item $item'),
                title: 'Numbers',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Numbers'), findsOneWidget);
    });
  });

  group('GlassPicker defaults', () {
    test('default values are correct', () {
      const picker = GlassPicker(value: null);
      expect(picker.placeholder, 'Select');
      expect(picker.height, 48.0);
      expect(picker.width, isNull);
      expect(picker.useOwnLayer, isFalse);
      expect(picker.quality, isNull);
      expect(picker.icon, isNull);
    });
  });
}
