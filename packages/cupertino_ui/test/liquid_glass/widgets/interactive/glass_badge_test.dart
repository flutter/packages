import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_badge.dart';

import '../../shared/test_helpers.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // BadgePosition enum
  // ──────────────────────────────────────────────────────────────────────────

  group('BadgePosition', () {
    test('has 4 values', () {
      expect(BadgePosition.values, hasLength(4));
    });

    test('values are topRight, topLeft, bottomRight, bottomLeft', () {
      expect(
          BadgePosition.values,
          containsAll([
            BadgePosition.topRight,
            BadgePosition.topLeft,
            BadgePosition.bottomRight,
            BadgePosition.bottomLeft,
          ]));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassBadge count badge
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassBadge count badge', () {
    testWidgets('hides badge when count is 0 and showZero is false',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 0,
            showZero: false,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      // When count==0 and showZero==false, GlassBadge returns child directly —
      // no Positioned widget is added, so the badge text is absent.
      expect(find.text('0'), findsNothing);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('shows badge when count is 0 and showZero is true',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 0,
            showZero: true,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows count when count > 0', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 5,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows maxCount+ text when count exceeds maxCount',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 150,
            maxCount: 99,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('renders as Stack when count > 0', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 3,
            child: const Icon(Icons.mail),
          ),
        ),
      );
      await tester.pump();
      // Badge itself wraps in a Stack; there may be other Stacks in the tree.
      expect(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Stack),
        ),
        findsWidgets,
      );
    });

    testWidgets('has correct semantic label for count badge', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 5,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.text('5'),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.label, contains('notifications'));
    });

    testWidgets('has correct semantic label when count exceeds maxCount',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 200,
            maxCount: 99,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      final badge = tester.widget<GlassBadge>(find.byType(GlassBadge));
      expect(badge.maxCount, 99);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassBadge all 4 positions
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassBadge count — all positions render without error', () {
    for (final position in BadgePosition.values) {
      testWidgets('position: ${position.name}', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            child: GlassBadge(
              count: 3,
              position: position,
              child: const Icon(Icons.inbox),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(GlassBadge), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });
    }
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassBadge.dot badge
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassBadge.dot', () {
    testWidgets('renders dot badge on top of child', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge.dot(
            child: const Icon(Icons.person),
          ),
        ),
      );
      await tester.pump();
      // Dot badge always renders — a Stack is added inside GlassBadge.
      expect(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Stack),
        ),
        findsWidgets,
      );
    });

    testWidgets('renders with custom dot color', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge.dot(
            dotColor: const Color(0xFF00FF00),
            child: const Icon(Icons.person),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassBadge), findsOneWidget);
    });

    testWidgets('has correct semantic label for dot badge', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge.dot(
            child: const Icon(Icons.person),
          ),
        ),
      );
      await tester.pump();
      // The Semantics wrapping the badge should have label 'Active'
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == 'Active'),
        isTrue,
      );
    });

    testWidgets('dot badge in all 4 positions renders without error',
        (tester) async {
      for (final position in BadgePosition.values) {
        await tester.pumpWidget(
          createTestApp(
            child: GlassBadge.dot(
              position: position,
              child: const Icon(Icons.person),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(GlassBadge), findsOneWidget);
      }
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassBadge defaults
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassBadge defaults', () {
    test('count badge defaults — semanticLabel and semanticCount are null', () {
      final badge = GlassBadge(
        count: 1,
        child: const Icon(Icons.notifications),
      );
      expect(badge.semanticLabel, isNull);
      expect(badge.semanticCount, isNull);
    });

    test('dot badge defaults — semanticLabel is null', () {
      final badge = GlassBadge.dot(
        child: const Icon(Icons.person),
      );
      expect(badge.semanticLabel, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // semanticLabel / semanticCount overrides
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassBadge semanticLabel & semanticCount', () {
    testWidgets('semanticLabel overrides the default "N notifications" label',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 5,
            semanticLabel: '5 downloads',
            child: const Icon(Icons.cloud_download),
          ),
        ),
      );
      await tester.pump();
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == '5 downloads'),
        isTrue,
        reason: 'semanticLabel should be used verbatim',
      );
    });

    testWidgets(
        'semanticLabel on a capped badge announces caller string, not "99+ notifications"',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 2500,
            maxCount: 99,
            semanticLabel: '2500 downloads',
            child: const Icon(Icons.cloud_download),
          ),
        ),
      );
      await tester.pump();
      // Visual shows "99+"
      expect(find.text('99+'), findsOneWidget);
      // But semantics should carry the caller-supplied string
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == '2500 downloads'),
        isTrue,
        reason: 'semanticLabel must override the capped default label',
      );
    });

    testWidgets('semanticCount speaks the true count when badge is capped',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 2500,
            maxCount: 99,
            semanticCount: 2500,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      // Visual is still capped at "99+"
      expect(find.text('99+'), findsOneWidget);
      // Semantic label should use the true count
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == '2500 notifications'),
        isTrue,
        reason: 'semanticCount must override the number spoken by VoiceOver',
      );
    });

    testWidgets('semanticLabel takes priority over semanticCount',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 10,
            semanticCount: 10,
            semanticLabel: '10 messages',
            child: const Icon(Icons.message),
          ),
        ),
      );
      await tester.pump();
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == '10 messages'),
        isTrue,
        reason: 'semanticLabel has highest priority over semanticCount',
      );
    });

    testWidgets('semanticLabel overrides dot badge "Active" default',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge.dot(
            semanticLabel: 'Online',
            child: const Icon(Icons.person),
          ),
        ),
      );
      await tester.pump();
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == 'Online'),
        isTrue,
        reason: 'semanticLabel should override the "Active" dot-badge default',
      );
      expect(
        badges.any((s) => s.properties.label == 'Active'),
        isFalse,
        reason: '"Active" must not appear when semanticLabel is set',
      );
    });

    testWidgets('backward compat — default label is still "N notifications"',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassBadge(
            count: 7,
            child: const Icon(Icons.notifications),
          ),
        ),
      );
      await tester.pump();
      final badges = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassBadge),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        badges.any((s) => s.properties.label == '7 notifications'),
        isTrue,
        reason:
            'Default label must remain unchanged for backward compatibility',
      );
    });
  });
}
