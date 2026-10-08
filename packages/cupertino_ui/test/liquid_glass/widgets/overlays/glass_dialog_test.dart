import 'package:liquid_glass_widgets/widgets/overlays/glass_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassDialog', () {
    final testActions = [
      GlassDialogAction(
        label: 'Cancel',
        onPressed: () {},
      ),
      GlassDialogAction(
        label: 'OK',
        onPressed: () {},
      ),
    ];

    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDialog(
            actions: testActions,
          ),
        ),
      );

      expect(find.byType(GlassDialog), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDialog(
            title: 'Alert',
            actions: testActions,
          ),
        ),
      );

      expect(find.text('Alert'), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDialog(
            title: 'Confirm',
            message: 'Are you sure?',
            actions: testActions,
          ),
        ),
      );

      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('displays custom content when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDialog(
            content: const Text('Custom Content'),
            actions: testActions,
          ),
        ),
      );

      expect(find.text('Custom Content'), findsOneWidget);
    });

    testWidgets('displays all action buttons', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDialog(
            actions: testActions,
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('action buttons call onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createTestApp(
          child: GlassDialog(
            actions: [
              GlassDialogAction(
                label: 'Press Me',
                onPressed: () => pressed = true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('shows dialog with static show method', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GlassDialog.show(
                    context: context,
                    title: 'Test Dialog',
                    actions: testActions,
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
    });

    test('defaults are correct', () {
      final dialog = GlassDialog(
        actions: testActions,
      );

      expect(dialog.maxWidth, equals(280));
      expect(dialog.quality, isNull);
    });

    test('asserts 1-3 actions', () {
      expect(
        () => GlassDialog(actions: []),
        throwsAssertionError,
      );

      expect(
        () => GlassDialog(
          actions: List.generate(
            4,
            (i) => GlassDialogAction(
              label: 'Action $i',
              onPressed: () {},
            ),
          ),
        ),
        throwsAssertionError,
      );
    });
  });

  group('GlassDialogAction', () {
    test('can be instantiated', () {
      final action = GlassDialogAction(
        label: 'OK',
        onPressed: () {},
      );

      expect(action.label, equals('OK'));
      expect(action.isPrimary, isFalse);
      expect(action.isDestructive, isFalse);
    });

    test('can be marked as primary', () {
      final action = GlassDialogAction(
        label: 'Save',
        onPressed: () {},
        isPrimary: true,
      );

      expect(action.isPrimary, isTrue);
    });

    test('can be marked as destructive', () {
      final action = GlassDialogAction(
        label: 'Delete',
        onPressed: () {},
        isDestructive: true,
      );

      expect(action.isDestructive, isTrue);
    });
  });
}
