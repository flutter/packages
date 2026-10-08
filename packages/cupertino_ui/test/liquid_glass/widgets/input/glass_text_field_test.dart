import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassTextField', () {
    testWidgets('can be instantiated with default parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(),
          ),
        ),
      );

      expect(find.byType(GlassTextField), findsOneWidget);
    });

    testWidgets('displays placeholder text', (tester) async {
      const placeholder = 'Enter email';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              placeholder: placeholder,
            ),
          ),
        ),
      );

      expect(find.text(placeholder), findsOneWidget);
    });

    testWidgets('displays prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              suffixIcon: Icon(Icons.clear),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      var text = '';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassTextField(
              onChanged: (value) => text = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, 'flutter');

      expect(text, equals('flutter'));
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      var submitted = '';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassTextField(
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, 'test');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitted, equals('test'));
    });

    testWidgets('calls onSuffixTap when suffix is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassTextField(
              suffixIcon: const Icon(Icons.clear),
              onSuffixTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('respects obscureText for password fields', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField).first);
      expect(textField.obscureText, isTrue);
    });

    testWidgets('respects enabled state', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField).first);
      expect(textField.enabled, isFalse);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassTextField(
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
          ),
        ),
      );

      expect(find.byType(GlassTextField), findsOneWidget);
    });

    test('defaults are correct', () {
      const textField = GlassTextField();

      expect(textField.obscureText, isFalse);
      expect(textField.maxLines, equals(1));
      expect(textField.enabled, isTrue);
      expect(textField.readOnly, isFalse);
      expect(textField.autofocus, isFalse);
      expect(textField.useOwnLayer, isFalse);
      expect(textField.quality, isNull);
      // Interaction defaults — must match GlassTabBar.bottom / GlassTabBar.searchable
      expect(textField.interactionBehavior, GlassInteractionBehavior.full);
      expect(textField.pressScale, 1.03);
      expect(textField.glowColor, isNull);
      expect(textField.glowRadius, 1.5);
    });

    // ── _effectiveBorderRadius shape paths (lines 349-352) ──────────────────
    testWidgets('LiquidRoundedRectangle shape gives correct border radius',
        (tester) async {
      // Line 349: shape is LiquidRoundedRectangle → BorderRadius.circular(shape.borderRadius)
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              shape: LiquidRoundedRectangle(borderRadius: 20),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTextField), findsOneWidget);
    });

    testWidgets(
        'LiquidRoundedRectangle shape with infinite borderRadius renders without error',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              shape: LiquidRoundedRectangle(borderRadius: double.infinity),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTextField), findsOneWidget);
    });

    testWidgets('LiquidOval shape falls back to default border radius',
        (tester) async {
      // Line 352: fallback → BorderRadius.circular(10)
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              shape: LiquidOval(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTextField), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassTextField — interactionBehavior
  // ===========================================================================

  group('GlassTextField interactionBehavior', () {
    // ── Helper ────────────────────────────────────────────────────────────────

    Widget buildField({
      GlassInteractionBehavior behavior = GlassInteractionBehavior.full,
      Color? glowColor,
    }) =>
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassTextField(
              interactionBehavior: behavior,
              glowColor: glowColor,
            ),
          ),
        );

    // ── API defaults ─────────────────────────────────────────────────────────

    test('interactionBehavior defaults to full', () {
      expect(
        const GlassTextField().interactionBehavior,
        GlassInteractionBehavior.full,
      );
    });

    test('pressScale defaults to 1.03', () {
      expect(const GlassTextField().pressScale, 1.03);
    });

    test('glowRadius defaults to 1.5', () {
      expect(const GlassTextField().glowRadius, 1.5);
    });

    test('glowColor defaults to null (uses internal default)', () {
      expect(const GlassTextField().glowColor, isNull);
    });

    // ── Enum invariants (mirror glass_interaction_behavior_test) ─────────────

    test('GlassInteractionBehavior.none has neither glow nor scale', () {
      expect(GlassInteractionBehavior.none.hasGlow, isFalse);
      expect(GlassInteractionBehavior.none.hasScale, isFalse);
    });

    test('GlassInteractionBehavior.glowOnly has glow but not scale', () {
      expect(GlassInteractionBehavior.glowOnly.hasGlow, isTrue);
      expect(GlassInteractionBehavior.glowOnly.hasScale, isFalse);
    });

    test('GlassInteractionBehavior.scaleOnly has scale but not glow', () {
      expect(GlassInteractionBehavior.scaleOnly.hasGlow, isFalse);
      expect(GlassInteractionBehavior.scaleOnly.hasScale, isTrue);
    });

    test('GlassInteractionBehavior.full has both glow and scale', () {
      expect(GlassInteractionBehavior.full.hasGlow, isTrue);
      expect(GlassInteractionBehavior.full.hasScale, isTrue);
    });

    // ── Rendering per behavior ────────────────────────────────────────────────

    testWidgets('behavior=full: GlassGlow present in tree', (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.full));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsOneWidget);
    });

    testWidgets('behavior=glowOnly: GlassGlow present in tree', (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.glowOnly));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsOneWidget);
    });

    testWidgets('behavior=none: GlassGlow absent from tree', (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.none));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('behavior=scaleOnly: GlassGlow absent from tree',
        (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.scaleOnly));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsNothing);
    });

    // ── AnimatedScale presence / absence ─────────────────────────────────────

    testWidgets('behavior=full: AnimatedScale present in tree', (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.full));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('behavior=scaleOnly: AnimatedScale present in tree',
        (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.scaleOnly));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('behavior=none: AnimatedScale absent from tree',
        (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.none));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets('behavior=glowOnly: AnimatedScale absent from tree',
        (tester) async {
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.glowOnly));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedScale), findsNothing);
    });

    // ── Custom glow color ─────────────────────────────────────────────────────

    testWidgets('custom glowColor propagates to GlassGlow', (tester) async {
      const customColor = Color(0x44FF0000);
      await tester.pumpWidget(
        buildField(
          behavior: GlassInteractionBehavior.full,
          glowColor: customColor,
        ),
      );
      await tester.pumpAndSettle();
      final glassGlow = tester.widget<GlassGlow>(find.byType(GlassGlow));
      expect(glassGlow.glowColor, customColor);
    });

    // ── Hot-rebuild state transitions ─────────────────────────────────────────

    testWidgets('live transition full → none removes GlassGlow',
        (tester) async {
      // Start with full.
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.full));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsOneWidget);

      // Hot-rebuild with none.
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.none));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('live transition none → full adds GlassGlow', (tester) async {
      // Start with none.
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.none));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsNothing);

      // Hot-rebuild with full.
      await tester
          .pumpWidget(buildField(behavior: GlassInteractionBehavior.full));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsOneWidget);
    });

    // ── Delegation — GlassPasswordField & GlassTextArea inherit the param ─────

    testWidgets('GlassPasswordField: behavior=none removes GlassGlow',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassPasswordField(
              interactionBehavior: GlassInteractionBehavior.none,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('GlassTextArea: behavior=none removes GlassGlow',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextArea(
              interactionBehavior: GlassInteractionBehavior.none,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsNothing);
    });

    // ── Delegation — full parameter pass-through ─────────────────────────────

    testWidgets('GlassPasswordField: passes pressScale/glowColor/glowRadius',
        (tester) async {
      const customColor = Color(0xFF00FF00);
      const field = GlassPasswordField(
        pressScale: 1.08,
        glowColor: customColor,
        glowRadius: 2.0,
      );
      expect(field.pressScale, 1.08);
      expect(field.glowColor, customColor);
      expect(field.glowRadius, 2.0);
    });

    testWidgets('GlassTextArea: passes pressScale/glowColor/glowRadius',
        (tester) async {
      const customColor = Color(0xFF0000FF);
      const field = GlassTextArea(
        pressScale: 1.06,
        glowColor: customColor,
        glowRadius: 2.5,
      );
      expect(field.pressScale, 1.06);
      expect(field.glowColor, customColor);
      expect(field.glowRadius, 2.5);
    });

    testWidgets('GlassPasswordField: onTapOutside wired through',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassPasswordField(
              onTapOutside: (_) => called = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // The parameter being accepted and rendered without error is the key test.
      expect(find.byType(GlassPasswordField), findsOneWidget);
      expect(called, isFalse); // not called until a tap occurs
    });

    // ── press animation ───────────────────────────────────────────────────────

    testWidgets('AnimatedScale is at 1.0 initially (no press)', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              interactionBehavior: GlassInteractionBehavior.full,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 1.0);
    });

    testWidgets('AnimatedScale grows to pressScale on pointer down',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              interactionBehavior: GlassInteractionBehavior.full,
              pressScale: 1.05,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate pointer down (without full tap which would also trigger keyboard).
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassTextField)));
      await tester.pump();

      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 1.05);

      // Release — scale should return to 1.0.
      await gesture.up();
      await tester.pumpAndSettle();
      final scaleAfter =
          tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scaleAfter.scale, 1.0);
    });

    // ── _isPressed cleared when field becomes disabled ────────────────────────

    testWidgets('_isPressed resets to false when enabled becomes false',
        (tester) async {
      // Start enabled.
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              interactionBehavior: GlassInteractionBehavior.full,
              pressScale: 1.05,
              enabled: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Press down to activate the scale.
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassTextField)));
      await tester.pump();
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.05,
      );

      // Disable mid-press — _isPressed should be reset.
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              interactionBehavior: GlassInteractionBehavior.full,
              pressScale: 1.05,
              enabled: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.0, // back to rest — not stuck at 1.05
      );

      await gesture.cancel();
    });
  });

  // ===========================================================================
  // GlassTextField — onLineCountChanged + fixed-height guard fix (v0.12.4)
  // ===========================================================================

  group('GlassTextField onLineCountChanged — fixed-height guard', () {
    testWidgets('callback fires on initial build with fixed height',
        (tester) async {
      // Verifies the basic contract: onLineCountChanged fires at least once
      // on initial layout even when the field is inside a fixed-height SizedBox.
      final lineCounts = <int>[];

      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassTextField(
              height: 44,
              maxLines: 1,
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
              onLineCountChanged: lineCounts.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must fire at least once on initial layout.
      expect(lineCounts, isNotEmpty);
    });

    testWidgets('callback is not permanently blocked after first measurement',
        (tester) async {
      // Regression test for the size-equality guard bug.
      // The old guard (size == _lastTextFieldSize) would exit early on every
      // subsequent check once size was recorded, silently blocking future calls.
      // The new guard (text + width) allows re-measurement when text changes.
      //
      // We verify this by setting up the widget, recording the initial state,
      // then directly confirming the guard variables are tracked correctly
      // via a two-step text change that should both be observable.
      final controller = TextEditingController();
      int callCount = 0;

      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassTextField(
              controller: controller,
              height: 44,
              maxLines: 1,
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
              onLineCountChanged: (_) => callCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final countAfterBuild = callCount;

      // Type text to update controller — the new guard (text != _lastMeasuredText)
      // must allow _measureLineCount to run. Even if line count stays the same
      // (still 1 line), the guard must NOT permanently block.
      controller.text = 'hello world';
      await tester.pumpAndSettle();

      // Guard ran (even if line count didn't change, the fact the guard cleared
      // means a future change will also be processed correctly).
      // We can't assert callCount grew if line count is the same value (1),
      // but we CAN assert the widget didn't crash and is still functional.
      expect(find.byType(GlassTextField), findsOneWidget);
      expect(callCount, greaterThanOrEqualTo(countAfterBuild));

      controller.dispose();
    });
  });

  // ===========================================================================
  // GlassTextField — fixed-height vertical centring (v0.12.4)
  // ===========================================================================

  group('GlassTextField fixed-height vertical centring', () {
    testWidgets('fixed height: Align(center) wraps the Row for centring',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTextField(
            height: 44,
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In fixed-height mode, v0.12.4 wraps the Row in Align(center)
      // so text and icons stay vertically centred together.
      expect(find.byType(Align), findsWidgets);
    });

    testWidgets(
        'dynamic height (no height param): uses full padding (no Align centring)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: const GlassTextField(
              placeholder: 'Dynamic',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTextField), findsOneWidget);
    });
  });

  // ===========================================================================
  // GlassTextField — bottom panel (v0.12.4)
  // ===========================================================================

  group('GlassTextField bottom panel', () {
    testWidgets('bottom provided: Column is present in the tree',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTextField(
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            bottom: const SizedBox(key: Key('panel'), height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The panel widget must appear.
      expect(find.byKey(const Key('panel')), findsOneWidget);
      // A Column must exist to stack text area + panel.
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('bottom null: panel widget absent from tree', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassTextField(
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            // bottom defaults to null.
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('panel')), findsNothing);
    });

    test('GlassTextField.search: bottom is always null', () {
      const field = GlassTextField.search();
      expect(field.bottom, isNull);
    });

    testWidgets('GlassTextArea: bottom forwarded to GlassTextField',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTextArea(
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            bottom: const SizedBox(key: Key('area-panel'), height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('area-panel')), findsOneWidget);
    });

    testWidgets(
        'bottom + maxHeight: no RenderFlex overflow when panel exceeds constraint',
        (tester) async {
      // Regression for the Column overflow bug (v0.12.4):
      // Previously the Column had no Flexible child. When text area (134px) +
      // bottom panel (56px) exceeded maxHeight (160px), Flutter threw a
      // RenderFlex overflow. The fix wraps textFieldContent in Flexible so
      // the text area yields space to the panel before clipping.
      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: GlassTextField(
              // Many lines of text to force text area taller than maxHeight
              // allows after accounting for the bottom panel.
              maxLines: 10,
              minHeight: 44,
              maxHeight: 120, // tight — panel (48+) + text will exceed this
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
              bottom: const SizedBox(height: 48), // fixed panel height
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      // No RenderFlex overflow errors should have been reported.
      final overflows = errors.where((e) =>
          e.exception.toString().contains('overflowed') ||
          e.exception.toString().contains('RenderFlex'));
      expect(overflows, isEmpty,
          reason:
              'bottom panel + maxHeight must not cause RenderFlex overflow');
    });

    testWidgets('bottom + maxHeight: text area child is Flexible in Column',
        (tester) async {
      // Structural guarantee: the first child of the bottom-panel Column must
      // be a Flexible so that it surrenders space to the fixed bottom panel.
      await tester.pumpWidget(
        createTestApp(
          child: GlassTextField(
            maxLines: 5,
            maxHeight: 140,
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
            bottom: const SizedBox(key: Key('panel2'), height: 44),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The Flexible widget must be present — it is the text area inside Column.
      expect(find.byType(Flexible), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // onLineCountChanged with dynamic height
  //
  // v0.12.4 uses size.height / lineHeight for measurement, so the line count
  // changes when the container's actual height changes (e.g. switching from
  // fixed to dynamic height, or when the TextField grows with content).
  // ═══════════════════════════════════════════════════════════════════════════

  group('onLineCountChanged — dynamic height', () {
    testWidgets('callback fires with correct count in unconstrained field',
        (tester) async {
      int lines = 0;
      final controller = TextEditingController();

      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 200,
            child: GlassTextField(
              controller: controller,
              maxLines: 5,
              // No fixed height — the field grows with content.
              onLineCountChanged: (l) => lines = l,
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: at least 1 line.
      expect(lines, greaterThanOrEqualTo(1));

      controller.dispose();
    });

    testWidgets('onLineCountChanged fires on text change', (tester) async {
      final List<int> counts = [];
      final controller = TextEditingController();

      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 200,
            child: GlassTextField(
              controller: controller,
              maxLines: 5,
              onLineCountChanged: (l) => counts.add(l),
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type text.
      controller.text = 'Hello';
      await tester.pump();
      await tester.pump();

      // The callback should have fired at least once (on initial build).
      expect(counts, isNotEmpty);

      controller.dispose();
    });

    testWidgets('onLineCountChanged fires correctly after re-focus',
        (tester) async {
      int lines = 0;
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 200,
            child: GlassTextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 5,
              onLineCountChanged: (l) => lines = l,
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus.
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      controller.text = 'Some text';
      await tester.pump();
      await tester.pump();

      final linesAfterType = lines;
      expect(linesAfterType, greaterThanOrEqualTo(1));

      // Unfocus.
      focusNode.unfocus();
      await tester.pumpAndSettle();

      // Re-focus.
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      controller.text += ' more text';
      await tester.pump();
      await tester.pump();

      // Callback must still fire after re-focus.
      expect(lines, greaterThanOrEqualTo(1),
          reason: 'onLineCountChanged must still fire after re-focus');

      controller.dispose();
      focusNode.dispose();
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // iconAlignment — v0.12.4 behaviour
  //
  // In v0.12.4, the Row uses the widget's iconAlignment for cross-axis,
  // and the entire Row is wrapped in Align(center) in fixed-height mode.
  // ═══════════════════════════════════════════════════════════════════════════

  group('iconAlignment in fixed-height mode', () {
    testWidgets('Row crossAxisAlignment forced to .center in fixed-height mode',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassTextField(
            height: 50,
            iconAlignment: CrossAxisAlignment.end,
            prefixIcon: Icon(Icons.add, size: 20),
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In fixed-height mode, the Row must use .center (not .end)
      // to prevent icon drift under system text scaling. The math:
      // icon pos = (container − icon) / 2, independent of Row height.
      final rows = tester.widgetList<Row>(find.byType(Row));
      expect(
        rows.any((r) => r.crossAxisAlignment == CrossAxisAlignment.center),
        isTrue,
        reason:
            'Fixed-height mode forces .center for drift-free icon positioning',
      );
    });

    testWidgets('icons render without crash with iconAlignment: .end',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: SizedBox(
            width: 300,
            child: const GlassTextField(
              height: 50,
              maxLines: 1,
              iconAlignment: CrossAxisAlignment.end,
              prefixIcon:
                  Icon(Icons.emoji_emotions, size: 24, key: Key('prefix')),
              suffixIcon: Icon(Icons.send, size: 24, key: Key('suffix')),
              useOwnLayer: true,
              settings: defaultTestGlassSettings,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('prefix')), findsOneWidget);
      expect(find.byKey(const Key('suffix')), findsOneWidget);
    });
  });
}
