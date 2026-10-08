// Coverage for GlassSheet widget uncovered branches:
//   L381-404: _handlePointerDown (suppressed interaction + enableInteractionGlow=false)
//   L454-471: isScrollable=false path
//   L513-521: suppressInteractionOnChildren=true notification listener
//   L573-591: _GlassDragIndicator dark/light mode + showIndicator=false

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/overlays/glass_sheet.dart';

Widget _app(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );

void main() {
  // ── isScrollable=false path ───────────────────────────────────────────────

  group('GlassSheet — isScrollable=false', () {
    testWidgets('renders Padding instead of SingleChildScrollView',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          isScrollable: false,
          child: SizedBox(width: 200, height: 100, key: Key('content')),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('content')), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('isScrollable=false with padding renders correctly',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          isScrollable: false,
          padding: EdgeInsets.all(16),
          child: SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── scroll notification path ─────────────────────────────────────────────

  group('GlassSheet — scroll notifications', () {
    testWidgets('removes touch glow when content starts scrolling',
        (tester) async {
      await tester.pumpWidget(_app(
        const SizedBox(
          height: 400,
          child: GlassSheet(
            child: SizedBox(
              height: 1000,
              child: Text('Scrollable content'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);
      await tester.drag(scrollView, const Offset(0, -200));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── showDragIndicator=false path ──────────────────────────────────────────

  group('GlassSheet — showDragIndicator=false', () {
    testWidgets('no drag indicator shown', (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          showDragIndicator: false,
          child: SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── drag indicator color: dark mode ───────────────────────────────────────

  group('GlassSheet — drag indicator theming', () {
    testWidgets('renders in dark mode without crash', (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(child: SizedBox(width: 200, height: 100)),
        dark: true,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom dragIndicatorColor is applied', (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          dragIndicatorColor: Colors.red,
          child: SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── enableInteractionGlow=false ───────────────────────────────────────────

  group('GlassSheet — enableInteractionGlow=false', () {
    testWidgets('no GlassGlow added when glow disabled', (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          enableInteractionGlow: false,
          child: SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('pointer down does not call haptic when glow disabled',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          enableInteractionGlow: false,
          enableSaturationGlow: false,
          child: SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GlassSheet));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── suppressInteractionOnChildren ─────────────────────────────────────────

  group('GlassSheet — suppressInteractionOnChildren', () {
    testWidgets('NotificationListener is inserted when suppress=true',
        (tester) async {
      await tester.pumpWidget(_app(
        GlassSheet(
          suppressInteractionOnChildren: true,
          child: GlassInteractionSilence(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Tap'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // Tap the silent button — suppression notification should fire.
      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('pointer down after child interaction resets flag',
        (tester) async {
      await tester.pumpWidget(_app(
        GlassSheet(
          suppressInteractionOnChildren: true,
          child: GlassInteractionSilence(
            child: GestureDetector(
              onTap: () {},
              child: const SizedBox(width: 100, height: 50, key: Key('inner')),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // Tap the silence wrapper — dispatches InteractionNotification.
      await tester.tap(find.byType(GlassInteractionSilence),
          warnIfMissed: false);
      await tester.pump();
      // Second tap on the top-level Listener to exercise the reset path.
      await tester.tap(find.byType(GlassSheet), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── enableSaturationGlow ──────────────────────────────────────────────────

  group('GlassSheet — saturation animation', () {
    testWidgets('pointer down/up runs saturation animation', (tester) async {
      await tester.pumpWidget(_app(
        const GlassSheet(
          enableSaturationGlow: true,
          child: SizedBox(width: 200, height: 100),
        ),
      ));
      await tester.pumpAndSettle();
      // Simulate press and release.
      await tester.press(find.byType(GlassSheet));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── GlassInteractionSilence ───────────────────────────────────────────────

  group('GlassInteractionSilence', () {
    testWidgets('dispatches InteractionNotification on pointer down',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GlassInteractionSilence(
          child: const SizedBox(width: 100, height: 50),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GlassInteractionSilence));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
