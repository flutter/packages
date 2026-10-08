import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  // ────────────────────────────────────────────────────────────────────────────
  // Rendering
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassPasswordField rendering', () {
    testWidgets('renders without error with default params', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      expect(find.byType(GlassPasswordField), findsOneWidget);
      expect(find.byType(GlassTextField), findsOneWidget);
    });

    testWidgets('shows placeholder text by default', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('uses custom placeholder', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassPasswordField(placeholder: 'Enter PIN'),
        ),
      );
      await tester.pump();
      expect(find.text('Enter PIN'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Toggle button semantics
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassPasswordField toggle button semantics', () {
    testWidgets(
        'toggle icon has "Show password" label when password is obscured',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPasswordField),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semanticsWidgets.any((s) => s.properties.label == 'Show password'),
        isTrue,
        reason: '"Show password" label must be present when password is hidden',
      );
    });

    testWidgets('toggle icon has "Hide password" label after tapping to reveal',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      final eyeIcon = find.byIcon(CupertinoIcons.eye_slash_fill);
      expect(eyeIcon, findsOneWidget);
      await tester.tap(eyeIcon);
      await tester.pump();
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPasswordField),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semanticsWidgets.any((s) => s.properties.label == 'Hide password'),
        isTrue,
        reason: '"Hide password" label must appear when password is revealed',
      );
    });

    testWidgets('toggle button Semantics has button: true', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(GlassPasswordField),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semanticsWidgets.any(
          (s) =>
              s.properties.label == 'Show password' &&
              s.properties.button == true,
        ),
        isTrue,
        reason: 'Toggle Semantics must have button: true',
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Toggle behaviour
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassPasswordField toggle behaviour', () {
    testWidgets('shows eye_slash icon when obscured', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.eye_slash_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.eye_fill), findsNothing);
    });

    testWidgets('shows eye icon after tapping to reveal', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.eye_slash_fill));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.eye_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.eye_slash_fill), findsNothing);
    });

    testWidgets('tapping twice returns to obscured state', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassPasswordField()),
      );
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.eye_slash_fill));
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.eye_fill));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.eye_slash_fill), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Defaults
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassPasswordField defaults', () {
    test('has correct default values', () {
      const field = GlassPasswordField();
      expect(field.placeholder, 'Password');
      expect(field.enabled, isTrue);
      expect(field.readOnly, isFalse);
      expect(field.autofocus, isFalse);
    });
  });
}
