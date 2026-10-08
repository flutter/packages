import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassActionSheetAction — data class
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassActionSheetAction', () {
    test('can be instantiated with required fields', () {
      final action = GlassActionSheetAction(
        label: 'Delete',
        onPressed: () {},
      );
      expect(action.label, 'Delete');
      expect(action.style, GlassActionSheetStyle.defaultStyle);
      expect(action.icon, isNull);
    });

    test('stores destructive style', () {
      final action = GlassActionSheetAction(
        label: 'Remove',
        onPressed: () {},
        style: GlassActionSheetStyle.destructive,
      );
      expect(action.style, GlassActionSheetStyle.destructive);
    });

    test('stores cancel style', () {
      final action = GlassActionSheetAction(
        label: 'Cancel',
        onPressed: () {},
        style: GlassActionSheetStyle.cancel,
      );
      expect(action.style, GlassActionSheetStyle.cancel);
    });

    test('stores optional icon', () {
      final action = GlassActionSheetAction(
        label: 'Share',
        onPressed: () {},
        icon: const Icon(Icons.share),
      );
      expect(action.icon, isNotNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassActionSheetStyle enum
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassActionSheetStyle', () {
    test('has 3 values', () {
      expect(GlassActionSheetStyle.values, hasLength(3));
    });

    test('values are defaultStyle, destructive, cancel', () {
      expect(
          GlassActionSheetStyle.values,
          containsAll([
            GlassActionSheetStyle.defaultStyle,
            GlassActionSheetStyle.destructive,
            GlassActionSheetStyle.cancel,
          ]));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // showGlassActionSheet — widget integration
  // ──────────────────────────────────────────────────────────────────────────

  group('showGlassActionSheet', () {
    testWidgets('renders action labels in sheet', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                title: 'Sheet Title',
                message: 'Sheet message',
                actions: [
                  GlassActionSheetAction(
                    label: 'Save',
                    onPressed: () {},
                  ),
                  GlassActionSheetAction(
                    label: 'Delete',
                    style: GlassActionSheetStyle.destructive,
                    onPressed: () {},
                  ),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Title'), findsOneWidget);
      expect(find.text('Sheet message'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('shows cancel button by default', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Action',
                    onPressed: () {},
                  ),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('hides cancel button when showCancelButton is false',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Action',
                    onPressed: () {},
                  ),
                ],
                showCancelButton: false,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('custom cancel label renders correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Action',
                    onPressed: () {},
                  ),
                ],
                cancelLabel: 'Dismiss',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('fires action callback on tap', (tester) async {
      var actionFired = false;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Do It',
                    onPressed: () => actionFired = true,
                  ),
                ],
                showCancelButton: false,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Do It'));
      await tester.pumpAndSettle();

      expect(actionFired, isTrue);
    });

    testWidgets('cancel button closes sheet', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Action',
                    onPressed: () {},
                  ),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed; 'Cancel' button should no longer appear.
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('action with icon renders icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Share',
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
                showCancelButton: false,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('sheet without title or message still renders', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlassActionSheet(
                context: context,
                actions: [
                  GlassActionSheetAction(
                    label: 'Only Action',
                    onPressed: () {},
                  ),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Only Action'), findsOneWidget);
    });
  });
}
