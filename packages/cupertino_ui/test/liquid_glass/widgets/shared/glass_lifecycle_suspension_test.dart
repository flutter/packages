// ignore_for_file: require_trailing_commas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _shape = LiquidRoundedSuperellipse(borderRadius: 16);
const _settings = LiquidGlassSettings(thickness: 20, blur: 0);

/// Minimal GlassEffect wrapper. Uses minimal quality so no shader assets are
/// required (FragmentProgram.fromAsset is unavailable in the headless test VM).
Widget _glassEffect({GlobalKey? backgroundKey}) => createTestApp(
      child: GlassEffect(
        shape: _shape,
        settings: _settings,
        interactionIntensity: 0.0,
        quality: GlassQuality.minimal,
        backgroundKey: backgroundKey,
        child: const SizedBox(width: 80, height: 40),
      ),
    );

/// Minimal LightweightLiquidGlass wrapper.
Widget _lightweightGlass({GlobalKey? backgroundKey}) => createTestApp(
      child: LightweightLiquidGlass(
        shape: _shape,
        settings: const LiquidGlassSettings(thickness: 20, blur: 0),
        backgroundKey: backgroundKey,
        child: const SizedBox(width: 80, height: 40),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(LightweightLiquidGlass.resetForTesting);

  // ── GlassEffect ────────────────────────────────────────────────────────────

  group('GlassEffect — lifecycle-aware Ticker suspension (v0.19.1)', () {
    testWidgets('inactive → paused → resumed lifecycle completes without crash',
        (tester) async {
      await tester.pumpWidget(_glassEffect());
      await tester.pump();

      final binding = tester.binding;

      // Simulate screen rotation / split-screen: inactive fires first
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      // App fully backgrounded
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // App returns to foreground — pumpAndSettle lets the addPostFrameCallback
      // from resumed fire before we assert.
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('hidden lifecycle state does not crash', (tester) async {
      await tester.pumpWidget(_glassEffect());
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('detached lifecycle state does not crash', (tester) async {
      await tester.pumpWidget(_glassEffect());
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('dispose during inactive does not crash (_isDisposed guard)',
        (tester) async {
      await tester.pumpWidget(_glassEffect());
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      // Tear down while inactive — _isDisposed must prevent pending callbacks
      // from accessing GPU resources after the State is gone.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid mount-dispose cycle with lifecycle changes',
        (tester) async {
      // Exercises the _isDisposed guard: resumed schedules a postFrameCallback
      // that must not fire against a State disposed before the frame ran.
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(_glassEffect());
        await tester.pump();

        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });
  });

  // ── LightweightLiquidGlass ─────────────────────────────────────────────────

  group('LightweightLiquidGlass — lifecycle-aware Ticker suspension (v0.19.1)',
      () {
    testWidgets('inactive → paused → resumed lifecycle completes without crash',
        (tester) async {
      await tester.pumpWidget(_lightweightGlass());
      await tester.pump();

      final binding = tester.binding;

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('hidden lifecycle state does not crash', (tester) async {
      await tester.pumpWidget(_lightweightGlass());
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('detached lifecycle state does not crash', (tester) async {
      await tester.pumpWidget(_lightweightGlass());
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('dispose during inactive does not crash (_isDisposed guard)',
        (tester) async {
      await tester.pumpWidget(_lightweightGlass());
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid mount-dispose cycle with lifecycle changes',
        (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(_lightweightGlass());
        await tester.pump();

        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('all lifecycle states in sequence do not accumulate callbacks',
        (tester) async {
      await tester.pumpWidget(_lightweightGlass());
      await tester.pump();

      final binding = tester.binding;

      // Rapid-fire every state — exercises switch exhaustiveness and
      // ensures no state is left dirty between transitions.
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
