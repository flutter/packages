import 'package:liquid_glass_widgets/src/renderer/liquid_glass_renderer.dart';
import 'package:liquid_glass_widgets/theme/glass_interaction_settings.dart';
import 'package:liquid_glass_widgets/theme/glass_theme.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_data.dart';
import 'package:liquid_glass_widgets/types/glass_quality.dart';
import 'package:liquid_glass_widgets/widgets/interactive/glass_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassButton', () {
    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(CupertinoIcons.heart),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassButton), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
    });

    testWidgets('displays icon correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(Icons.star),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(Icons.add),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(Icons.add),
              onTap: () => tapped = true,
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renders with reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(Icons.add),
              onTap: () {},
              enabled: false,
            ),
          ),
        ),
      );

      final opacities = tester.widgetList<Opacity>(
        find.descendant(
          of: find.byType(GlassButton),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacities.any((o) => o.opacity == 0.5), isTrue);
    });

    testWidgets('GlassButton.custom displays custom child', (tester) async {
      const testText = 'Custom Button';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton.custom(
              onTap: () {},
              child: const Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('respects custom width and height', (tester) async {
      const customWidth = 100.0;
      const customHeight = 80.0;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(Icons.star),
              onTap: () {},
              width: customWidth,
              height: customHeight,
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(GlassButton));

      expect(size.width, equals(customWidth));
      expect(size.height, equals(customHeight));
    });

    testWidgets('GlassButton.custom shrink-wraps to child when sizes are null',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: Center(
              child: GlassButton.custom(
                onTap: () {},
                // No explicit width or height
                child: const SizedBox(width: 40, height: 20),
              ),
            ),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(GlassButton));

      // Should perfectly wrap the 40x20 child, not expand to fill the screen
      expect(buttonSize.width, equals(40));
      expect(buttonSize.height, equals(20));
    });

    testWidgets('has proper semantics', (tester) async {
      const semanticLabel = 'Add Item';

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: Icon(Icons.add),
              onTap: () {},
              label: semanticLabel,
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(GlassButton),
              matching: find.byType(Semantics),
            )
            .first,
      );

      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.label, equals(semanticLabel));
      expect(semantics.properties.enabled, isTrue);
    });

    testWidgets('works in standalone mode with useOwnLayer', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassButton(
            icon: Icon(Icons.star),
            onTap: () {},
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
          ),
        ),
      );

      expect(find.byType(GlassButton), findsOneWidget);
    });

    testWidgets('uses correct glass quality', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassButton(
            icon: Icon(Icons.star),
            onTap: () {},
            useOwnLayer: true,
            quality: GlassQuality.premium,
          ),
        ),
      );

      expect(find.byType(GlassButton), findsOneWidget);
    });

    test('defaults are correct', () {
      final button = GlassButton(
        icon: Icon(Icons.star),
        onTap: () {},
      );

      expect(button.width, equals(56));
      expect(button.height, equals(56));
      expect(button.iconSize, equals(24.0));
      expect(button.enabled, isTrue);
      expect(button.useOwnLayer, isFalse);
      expect(button.quality, isNull);
      expect(button.interactionScale, isNull);
      expect(button.anchorStretchSettings, isNull);
      expect(button.stretch, equals(0.5));
      expect(button.resistance, equals(0.01));
    });
  });

  group('GlassButton interaction resolution', () {
    /// The LiquidStretch the button builds from its params and the theme.
    LiquidStretch stretchOf(WidgetTester tester) =>
        tester.widget<LiquidStretch>(
          find.descendant(
            of: find.byType(GlassButton),
            matching: find.byType(LiquidStretch),
          ),
        );

    Widget themed({
      required GlassInteractionSettings interaction,
      required Widget child,
    }) =>
        createTestApp(
          child: GlassTheme(
            data: GlassThemeData(interaction: interaction),
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: child,
            ),
          ),
        );

    testWidgets('defaults to the native sizing', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () {},
            ),
          ),
        ),
      );

      final stretch = stretchOf(tester);
      expect(stretch.pressGrowth, equals(17));
      expect(stretch.interactionScale, equals(1.0));
      expect(stretch.anchorStretchSettings.intensity, equals(0.1));
      expect(stretch.anchorStretchSettings.squashFactor, equals(0.1));
      expect(stretch.anchorStretchSettings.translationDamping, equals(0.1));
      expect(stretch.anchorStretchSettings.bounciness, equals(0.0));
    });

    testWidgets('an explicit interactionScale is a fixed factor',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () {},
              interactionScale: 1.15,
            ),
          ),
        ),
      );

      final stretch = stretchOf(tester);
      expect(stretch.interactionScale, equals(1.15));
      expect(stretch.pressGrowth, isNull);
    });

    testWidgets('the theme supplies a fixed factor and stretch settings',
        (tester) async {
      await tester.pumpWidget(
        themed(
          interaction: const GlassInteractionSettings(
            interactionScale: 1.2,
            anchorStretchSettings: AnchorStretchSettings(intensity: 0.7),
          ),
          child: GlassButton(
            icon: const Icon(Icons.star),
            onTap: () {},
          ),
        ),
      );

      final stretch = stretchOf(tester);
      expect(stretch.interactionScale, equals(1.2));
      expect(stretch.pressGrowth, isNull);
      expect(stretch.anchorStretchSettings.intensity, equals(0.7));
    });

    testWidgets('explicit anchorStretchSettings win over the theme',
        (tester) async {
      await tester.pumpWidget(
        themed(
          interaction: const GlassInteractionSettings(
            anchorStretchSettings: AnchorStretchSettings(intensity: 0.7),
          ),
          child: GlassButton(
            icon: const Icon(Icons.star),
            onTap: () {},
            anchorStretchSettings: const AnchorStretchSettings(intensity: 0.4),
          ),
        ),
      );

      expect(stretchOf(tester).anchorStretchSettings.intensity, equals(0.4));
    });
  });

  // ── _handleTapCancel (lines 436-438) ────────────────────────────────────────
  group('GlassButton tap-cancel', () {
    testWidgets('tap-cancel on enabled button reverses animation',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () {},
            ),
          ),
        ),
      );

      // Start tap then cancel — exercises _handleTapCancel (line 436-438)
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassButton)),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassButton), findsOneWidget);
    });

    testWidgets('tap-cancel on disabled button is a no-op (line 437 guard)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () {},
              enabled: false, // exercises `if (!widget.enabled) return;`
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassButton)),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassButton), findsOneWidget);
    });
  });

  // ── persistPressOnDrag (lines 596-620) ──────────────────────────────────────
  group('GlassButton persistPressOnDrag', () {
    test('default value is true', () {
      final button = GlassButton(
        icon: const Icon(Icons.star),
        onTap: () {},
      );
      expect(button.persistPressOnDrag, isTrue);
    });

    test('GlassButton.custom default value is true', () {
      final button = GlassButton.custom(
        onTap: () {},
        child: const Text('test'),
      );
      expect(button.persistPressOnDrag, isTrue);
    });

    testWidgets('persistPressOnDrag: true — uses Listener (pointer events)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () {},
              persistPressOnDrag: true,
            ),
          ),
        ),
      );

      // The tree should contain a Listener wrapping a GestureDetector
      final listenerFinder = find.descendant(
        of: find.byType(GlassButton),
        matching: find.byType(Listener),
      );
      expect(listenerFinder, findsWidgets); // At least our Listener

      // Test that tap still fires onTap
      var tapped = false;
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () => tapped = true,
              persistPressOnDrag: true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GlassButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets(
        'persistPressOnDrag: false — uses GestureDetector tap callbacks',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () => tapped = true,
              persistPressOnDrag: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('persistPressOnDrag: false — cancel reverses animation',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(Icons.star),
              onTap: () {},
              persistPressOnDrag: false,
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlassButton)),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      expect(find.byType(GlassButton), findsOneWidget);
    });
  });

  // ===========================================================================
  // Keyboard focus & accessibility template tests
  //
  // These tests validate the behaviour added in the a11y-keyboard-focus branch
  // and serve as the specification that all other interactive widgets must
  // satisfy when the template is applied to them.
  // ===========================================================================
  group('GlassButton keyboard focus & accessibility', () {
    // -------------------------------------------------------------------------
    // ActivateIntent (Space / Enter)
    // -------------------------------------------------------------------------
    testWidgets('Space key fires onTap when button is focused', (tester) async {
      var tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () => tapped = true,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Enter key fires onTap when button is focused', (tester) async {
      var tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () => tapped = true,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Space key does NOT fire onTap when disabled', (tester) async {
      var tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () => tapped = true,
              focusNode: focusNode,
              enabled: false,
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    // -------------------------------------------------------------------------
    // focusNode parameter
    // -------------------------------------------------------------------------
    testWidgets('focusNode parameter allows programmatic focus',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () {},
              focusNode: focusNode,
            ),
          ),
        ),
      );

      expect(focusNode.hasFocus, isFalse);
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
    });

    // -------------------------------------------------------------------------
    // autofocus parameter
    // -------------------------------------------------------------------------
    testWidgets('autofocus: true focuses button on mount', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () {},
              focusNode: focusNode,
              autofocus: true,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
    });

    // -------------------------------------------------------------------------
    // Focus ring visual presence
    // -------------------------------------------------------------------------
    testWidgets('focus ring CustomPaint NOT in tree when button is not focused',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      // CustomPaint for the focus ring is only inserted when focused.
      // When not focused, ValueListenableBuilder returns child directly —
      // no Stack, no CustomPaint for the ring.
      // We look for a CustomPaint that is a descendant of the GlassButton's
      // Stack — if none exist, the ring is correctly absent.
      expect(
        find.descendant(
          of: find.byType(Stack),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
        reason: 'Focus ring CustomPaint must not be present when button is '
            'unfocused (zero GPU cost for touch users)',
      );
    });

    testWidgets('focus ring CustomPaint IS in tree when button is focused',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassButton(
              icon: const Icon(CupertinoIcons.heart),
              onTap: () {},
              focusNode: focusNode,
            ),
          ),
        ),
      );

      // Switch FocusManager to keyboard highlight mode, then request focus.
      // This replicates Tab-key navigation which triggers onShowFocusHighlight.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      focusNode.requestFocus();
      await tester.pump();
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);

      // After keyboard focus, ValueListenableBuilder inserts Stack + CustomPaint.
      expect(
        find.descendant(
          of: find.byType(GlassButton),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
        reason: 'Focus ring CustomPaint must be present when keyboard-focused',
      );
    });

    // -------------------------------------------------------------------------
    // Reduce Motion
    // -------------------------------------------------------------------------
    testWidgets('keyboard activation works with reduceMotion enabled',
        (tester) async {
      var tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      // Override MediaQuery to signal reduceMotion / disableAnimations.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () => tapped = true,
                focusNode: focusNode,
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      // Should fire onTap without running the animation (no exception thrown).
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(tapped, isTrue,
          reason: 'onTap must fire even when reduceMotion is enabled');
    });

    // -------------------------------------------------------------------------
    // Semantics
    // -------------------------------------------------------------------------
    testWidgets('exposes button semantics', (tester) async {
      final handle = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
                label: 'Like',
              ),
            ),
          ),
        );

        await tester.pump();

        // Find the Semantics widget with the button role directly.
        expect(
          tester.getSemantics(
            find.bySemanticsLabel('Like'),
          ),
          matchesSemantics(
            isButton: true,
            label: 'Like',
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true, // focus merges into the labelled node (#381)
            isFocusable: true,
          ),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('semantics shows disabled state', (tester) async {
      final handle = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
                label: 'Like',
                enabled: false,
              ),
            ),
          ),
        );

        await tester.pump();

        expect(
          tester.getSemantics(
            find.bySemanticsLabel('Like'),
          ),
          matchesSemantics(
            isButton: true,
            label: 'Like',
            hasEnabledState: true,
            isEnabled: false,
            // isFocusable is absent when enabled:false — FocusableActionDetector
            // correctly removes the focusable flag for disabled controls.
          ),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('excludeFromSemantics hides button from semantics tree',
        (tester) async {
      final handle = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassButton(
                icon: const Icon(CupertinoIcons.heart),
                onTap: () {},
                label: 'Like',
                excludeFromSemantics: true,
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.bySemanticsLabel('Like'), findsNothing);
      } finally {
        handle.dispose();
      }
    });
  });
}
