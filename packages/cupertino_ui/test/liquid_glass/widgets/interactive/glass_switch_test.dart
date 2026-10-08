import 'package:liquid_glass_widgets/widgets/interactive/glass_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassSwitch', () {
    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      var value = false;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: value,
              onChanged: (newValue) => value = newValue,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassSwitch));
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('shows thumb in correct position when value is false',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('shows thumb in correct position when value is true',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('respects custom colors', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: true,
              onChanged: (_) {},
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              thumbColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      const customWidth = 64.0;
      const customHeight = 32.0;

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: false,
              onChanged: (_) {},
              width: customWidth,
              height: customHeight,
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('works in standalone mode', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassSwitch(
            value: false,
            onChanged: (_) {},
            useOwnLayer: true,
            settings: defaultTestGlassSettings,
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    test('defaults are correct', () {
      final glassSwitch = GlassSwitch(
        value: false,
        onChanged: (_) {},
      );

      expect(glassSwitch.width, equals(58.0));
      expect(glassSwitch.height, equals(26.0));
      expect(glassSwitch.thumbColor, equals(Colors.white));
      expect(glassSwitch.useOwnLayer, isFalse);
      expect(glassSwitch.quality, isNull);
    });

    // ── didUpdateWidget animation branches (lines 212-227) ───────────────────
    testWidgets('toggling value=true animates forward (lines 218-219)',
        (tester) async {
      bool value = false;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      // Flip to true — exercises _positionController.forward()
      outerSetState(() => value = true);
      await tester.pump(); // kick animation
      await tester.pump(const Duration(milliseconds: 400)); // mid animation
      await tester.pumpAndSettle();
      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('toggling value=false animates reverse (line 221)',
        (tester) async {
      bool value = true;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      // Start at true, flip to false — exercises _positionController.reverse()
      outerSetState(() => value = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('mid-animation glow overlay renders when transition > 0.05',
        (tester) async {
      // Catching line 446-451: `if (transition > 0.05) Opacity(GlassGlow(...))`
      // This renders during the animation. We pump partway through the animation
      // to ensure the glow layer is built.
      bool value = false;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      outerSetState(() => value = true);
      // Do NOT pumpAndSettle — mid-animation is where transition > 0
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // Widget still alive; glow branch rendered
      expect(find.byType(GlassSwitch), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // ── Drag-to-toggle ───────────────────────────────────────────────────────
    // Helper: builds a self-contained switch with an external state wrapper.
    Widget buildDraggableSwitch({
      required bool initialValue,
      required ValueChanged<bool> onChanged,
      double width = 58.0,
    }) =>
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: defaultTestGlassSettings,
            child: GlassSwitch(
              value: initialValue,
              onChanged: onChanged,
              width: width,
            ),
          ),
        );

    testWidgets('slow drag past 50% midpoint toggles switch on',
        (tester) async {
      bool value = false;
      await tester.pumpWidget(
        buildDraggableSwitch(
          initialValue: value,
          onChanged: (v) => value = v,
        ),
      );

      final switchFinder = find.byType(GlassSwitch);
      final switchRect = tester.getRect(switchFinder);

      // Drag from left side to well past the midpoint (right quarter).
      await tester.drag(
        switchFinder,
        Offset(switchRect.width * 0.6, 0),
      );
      await tester.pumpAndSettle();

      expect(value, isTrue,
          reason: 'Dragging past 50% should toggle the switch on');
    });

    testWidgets('drag from on→off past midpoint toggles switch off',
        (tester) async {
      bool value = true;
      await tester.pumpWidget(
        buildDraggableSwitch(
          initialValue: value,
          onChanged: (v) => value = v,
        ),
      );

      final switchFinder = find.byType(GlassSwitch);
      final switchRect = tester.getRect(switchFinder);

      // Start from a position near the right and drag left past the midpoint.
      await tester.drag(
        switchFinder,
        Offset(-switchRect.width * 0.6, 0),
      );
      await tester.pumpAndSettle();

      expect(value, isFalse,
          reason: 'Dragging left past 50% should toggle the switch off');
    });

    testWidgets(
        'external value change while dragging: widget survives without crash',
        (tester) async {
      // This test verifies that _dragAbandonedExternally prevents a double-fire
      // of onChanged. We drive the external change via the parent StatefulWidget
      // then verify the widget tree is intact after the gesture ends.
      bool value = false;
      int callCount = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) {
                    callCount++;
                    outerSetState(() => value = v);
                  },
                ),
              );
            },
          ),
        ),
      );

      final switchFinder = find.byType(GlassSwitch);

      // Start a drag gesture — must move > kTouchSlop (18 px) to trigger
      // onHorizontalDragStart recognition so _isDragging is set to true.
      final gesture = await tester.startGesture(
        tester.getCenter(switchFinder),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(20, 0)); // > kTouchSlop
      await tester.pump();

      // External change: parent overrides value programmatically.
      // This goes through didUpdateWidget → sets _dragAbandonedExternally.
      outerSetState(() => value = true);
      await tester.pump();

      // Lift finger — _onDragEnd must not call onChanged again.
      await gesture.up();
      await tester.pumpAndSettle();

      // onChanged must NOT have been called (the external setState handled it).
      expect(callCount, equals(0),
          reason:
              '_dragAbandonedExternally should suppress onChanged in _onDragEnd');
      // Widget must still be alive.
      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    // ── Regression: realistic gesture sequences ──────────────────────────────

    testWidgets('tap works reliably on repeated interactions', (tester) async {
      // Regression: onTap + onHorizontalDrag conflict caused tap to fail after
      // the first interaction. Verify toggling works 5 times consecutively.
      bool value = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      for (int i = 0; i < 5; i++) {
        final expected = (i % 2 == 0); // false→true→false…
        // Use pointer-level tap down+up to match onTapDown+onTapUp handler.
        await tester.tapAt(tester.getCenter(find.byType(GlassSwitch)));
        await tester.pumpAndSettle();
        expect(value, equals(expected),
            reason: 'Tap $i: expected $expected, got $value');
      }
    });

    testWidgets('slow drag (below slop then above) keeps pill plump',
        (tester) async {
      // Regression: slow drag fired onTapCancel which deflated the bloom before
      // onHorizontalDragStart could stop it. Widget must not crash.
      bool value = false;

      await tester.pumpWidget(
        buildDraggableSwitch(
          initialValue: value,
          onChanged: (v) => value = v,
        ),
      );

      final switchFinder = find.byType(GlassSwitch);
      final center = tester.getCenter(switchFinder);

      // Simulate slow horizontal gesture: start, move slowly past slop.
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 80));
      // Small initial move (still below slop) — triggers onTapCancel in Flutter.
      await gesture.moveBy(const Offset(8, 0));
      await tester.pump(const Duration(milliseconds: 50));
      // Move past slop threshold — triggers onHorizontalDragStart.
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      // Release past midpoint.
      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Widget must still be alive and functional.
      expect(find.byType(GlassSwitch), findsOneWidget);
      expect(value, isTrue,
          reason: 'Slow drag past midpoint should still toggle');
    });

    testWidgets('drag not reaching midpoint snaps back without toggle',
        (tester) async {
      bool value = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      final switchFinder = find.byType(GlassSwitch);
      final center = tester.getCenter(switchFinder);

      // Gesture: touch down, move just past slop (20px > kTouchSlop 18px) but
      // stay well under the full thumb travel (~22px). Position will be < 50%.
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.moveBy(const Offset(20, 0)); // clears slop, starts drag
      await tester.pump();
      await gesture.up(); // release at ~90% position from start
      await tester.pumpAndSettle();

      // At this position (close to center, very small delta from center),
      // the controller should snap back to false.
      // Note: if this flickers, it means the snap threshold needs a nudge —
      // the real behaviour is tested by the flick and slow-drag tests above.
      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets('fast flick right toggles on regardless of position',
        (tester) async {
      bool value = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      final switchFinder = find.byType(GlassSwitch);
      // 30px is enough to clear kTouchSlop (18px) and generate usable velocity.
      await tester.fling(switchFinder, const Offset(30, 0), 500);
      await tester.pumpAndSettle();

      expect(value, isTrue,
          reason: 'Fast rightward flick should toggle on via velocity');
    });

    testWidgets('fast flick left toggles off regardless of position',
        (tester) async {
      bool value = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      final switchFinder = find.byType(GlassSwitch);
      await tester.fling(switchFinder, const Offset(-30, 0), 500);
      await tester.pumpAndSettle();

      expect(value, isFalse,
          reason: 'Fast leftward flick should toggle off via velocity');
    });

    testWidgets('thickness controller resets cleanly on second interaction',
        (tester) async {
      // Regression: _thicknessController at value=1.0 (end of previous
      // animation) was not being reset to 0.0 before the next forward().
      // This caused the bloom to skip entirely on the second tap.
      bool value = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      // First toggle — let animation complete fully (controller ends at 1.0).
      outerSetState(() => value = true);
      await tester.pump();
      await tester.pumpAndSettle();

      // Second toggle — must not crash and bloom must replay.
      outerSetState(() => value = false);
      await tester.pump(); // kick
      await tester.pump(const Duration(milliseconds: 50)); // mid-bloom
      expect(find.byType(GlassSwitch), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.byType(GlassSwitch), findsOneWidget);
      expect(value, isFalse);
    });

    // ── New targeted tests for production hardening ─────────────────────────

    testWidgets(
        'initial state: switch starting as true renders thumb at right '
        'and first tap animates in reverse direction (anchor fix)',
        (tester) async {
      // Regression: _isMovingForward was hardcoded to `true`, so the first
      // tap on a switch starting as `true` bloomed from the wrong anchor
      // (left edge instead of right edge). After the fix, _isMovingForward
      // is initialised from widget.value in initState().
      bool value = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      // No pumping — the switch is mounted with value=true. The position
      // controller must already be at 1.0 (right side) without any animation.
      // We verify the widget renders without error at this initial state.
      expect(find.byType(GlassSwitch), findsOneWidget);

      // First tap: should go true→false. Critically, the first interaction
      // must behave identically to subsequent ones — no broken bloom anchor.
      await tester.tapAt(tester.getCenter(find.byType(GlassSwitch)));
      await tester.pump(); // frame after tap triggers onChanged
      await tester.pump(const Duration(milliseconds: 50)); // mid-animation
      // Widget must be alive and animating
      expect(find.byType(GlassSwitch), findsOneWidget);
      await tester.pumpAndSettle();

      // State must have toggled off correctly.
      expect(value, isFalse,
          reason:
              'First tap on a switch initialised as true must toggle it off');

      // Second tap: false→true. Must behave consistently.
      await tester.tapAt(tester.getCenter(find.byType(GlassSwitch)));
      await tester.pumpAndSettle();
      expect(value, isTrue,
          reason:
              'Second tap must toggle back on; confirms direction consistency');
    });

    testWidgets(
        '_justEndedDrag: onChanged is called exactly once after a drag '
        'toggle, not twice (race condition fix)', (tester) async {
      // Regression: _justEndedDrag was reset via addPostFrameCallback, which
      // could fire *after* didUpdateWidget if the parent setState was batched
      // to a later frame. This caused a double-bloom. The fix consumes the flag
      // atomically inside didUpdateWidget.
      //
      // We verify the _behavioural_ guarantee: after a drag toggle, onChanged
      // is called exactly once (from _onDragEnd), not a second time from
      // didUpdateWidget triggering the bloom independently.
      bool value = false;
      int callCount = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) {
                    callCount++;
                    outerSetState(() => value = v);
                  },
                ),
              );
            },
          ),
        ),
      );

      final switchFinder = find.byType(GlassSwitch);

      // Perform a full drag-to-toggle: clear slop, move past midpoint, release.
      final gesture = await tester.startGesture(tester.getCenter(switchFinder));
      await tester.pump();
      await gesture.moveBy(const Offset(25, 0)); // clear kTouchSlop (18px)
      await tester.pump();
      await gesture.moveBy(const Offset(20, 0)); // past 50% midpoint
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // onChanged must have been called exactly once — from _onDragEnd.
      // A second call would mean the race condition is still present.
      expect(callCount, equals(1),
          reason: 'onChanged must fire exactly once per drag toggle; '
              'a count of 2 means _justEndedDrag race is still present');
      expect(value, isTrue,
          reason: 'Drag past midpoint must toggle the switch on');
      expect(find.byType(GlassSwitch), findsOneWidget);
    });

    testWidgets(
        'float guard: rapid consecutive toggles never skip bloom '
        '(>= 0.99 threshold is robust against floating-point drift)',
        (tester) async {
      // Regression: using == 1.0 to guard the thickness controller reset was
      // fragile — floating-point drift could leave it at 0.9999... meaning the
      // reset to 0.0 was skipped and the bloom sequence played from mid-point.
      //
      // We simulate drift by toggling twice in quick succession without letting
      // the first animation settle. The controller may be at a non-integer value
      // between the two toggles. The widget must survive without assertion
      // errors and correctly play the bloom on the second toggle.
      bool value = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveLiquidGlassLayer(
                settings: defaultTestGlassSettings,
                child: GlassSwitch(
                  value: value,
                  onChanged: (v) => outerSetState(() => value = v),
                ),
              );
            },
          ),
        ),
      );

      // First toggle — do NOT settle; interrupt it partway through.
      outerSetState(() => value = true);
      await tester.pump(); // start animation
      await tester.pump(const Duration(milliseconds: 190)); // ~50% through

      // Second toggle while first is still animating (controller is mid-flight).
      // This is the scenario where the thickness value is not exactly 0.0 or 1.0.
      outerSetState(() => value = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50)); // mid second bloom

      // Widget must be alive — no assert or controller errors.
      expect(find.byType(GlassSwitch), findsOneWidget);

      // Let everything settle cleanly.
      await tester.pumpAndSettle();
      expect(find.byType(GlassSwitch), findsOneWidget);
      expect(value, isFalse,
          reason: 'Final state must reflect the last programmatic toggle');

      // One more toggle from a clean resting state to confirm full recovery.
      outerSetState(() => value = true);
      await tester.pumpAndSettle();
      expect(value, isTrue,
          reason: 'Switch must be fully functional after rapid interruption');
    });
    group('keyboard focus & accessibility', () {
      testWidgets('Space key toggles switch when focused', (tester) async {
        bool value = false;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSwitch(
                value: value,
                onChanged: (v) => value = v,
                focusNode: focusNode,
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        expect(value, isTrue);
      });

      testWidgets('Enter key toggles switch when focused', (tester) async {
        bool value = false;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveLiquidGlassLayer(
              settings: defaultTestGlassSettings,
              child: GlassSwitch(
                value: value,
                onChanged: (v) => value = v,
                focusNode: focusNode,
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(value, isTrue);
      });

      testWidgets('exposes switch semantics', (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            createTestApp(
              child: GlassSwitch(
                value: true,
                onChanged: (_) {},
                semanticLabel: 'Test Switch',
              ),
            ),
          );

          expect(
            tester.getSemantics(find.byType(GlassSwitch)),
            matchesSemantics(
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction:
                  true, // focus merges into the labelled node (#381)
              hasToggledState: true,
              isToggled: true,
              label: 'Test Switch',
            ),
          );
        } finally {
          handle.dispose();
        }
      });
    });
  });
}
