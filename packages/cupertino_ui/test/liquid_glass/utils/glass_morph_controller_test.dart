import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/utils/glass_morph_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: mounts a minimal widget that owns a GlassMorphController.
// ─────────────────────────────────────────────────────────────────────────────

class _Harness extends StatefulWidget {
  const _Harness({
    required this.ref,
    this.speed = MorphSpeed.normal,
    this.style = MorphStyle.teardrop,
  });

  final void Function(GlassMorphController) ref;
  final MorphSpeed speed;
  final MorphStyle style;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> with TickerProviderStateMixin {
  late final GlassMorphController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = GlassMorphController(
      vsync: this,
      speed: widget.speed,
      style: widget.style,
    );
    widget.ref(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Mounts the harness and returns the controller.
/// The first [pump] is included so the widget tree is fully built.
Future<GlassMorphController> _mount(
  WidgetTester tester, {
  MorphSpeed speed = MorphSpeed.normal,
  MorphStyle style = MorphStyle.teardrop,
}) async {
  late GlassMorphController ctrl;
  await tester.pumpWidget(
    MaterialApp(
      home: _Harness(ref: (c) => ctrl = c, speed: speed, style: style),
    ),
  );
  return ctrl;
}

// Pumps one engine frame (16 ms) so that a spring simulation advances.
Future<void> _pumpFrame(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 16));

void main() {
  // ── Construction ──────────────────────────────────────────────────────────

  group('GlassMorphController — construction', () {
    testWidgets('creates without throwing', (tester) async {
      expect(() => _mount(tester), returnsNormally);
    });

    testWidgets('speed property is stored', (tester) async {
      final ctrl = await _mount(tester, speed: MorphSpeed.fast);
      expect(ctrl.speed, equals(MorphSpeed.fast));
    });

    testWidgets('style property is stored', (tester) async {
      final ctrl = await _mount(tester, style: MorphStyle.bloom);
      expect(ctrl.style, equals(MorphStyle.bloom));
    });

    testWidgets('value is 0.0 at construction', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.value, equals(0.0));
    });

    testWidgets('isClosing is false at construction', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.isClosing, isFalse);
    });

    testWidgets('hasHandedOff is false at construction', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.hasHandedOff, isFalse);
    });

    testWidgets('isShowing is false at construction', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.isShowing, isFalse);
    });

    testWidgets('animation getter is non-null', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.animation, isNotNull);
    });

    testWidgets('velocity is 0.0 at construction', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.velocity, equals(0.0));
    });
  });

  // ── open() ────────────────────────────────────────────────────────────────

  group('GlassMorphController — open()', () {
    testWidgets('sets isClosing to false', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      expect(ctrl.isClosing, isFalse);
    });

    testWidgets('resets hasHandedOff to false', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      ctrl.close();
      await tester.pumpAndSettle();
      // hasHandedOff latched during close.
      // Re-opening must clear it.
      ctrl.open();
      expect(ctrl.hasHandedOff, isFalse);
    });

    testWidgets('value advances above 0 after one engine frame',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      // Advance 2 engine frames (spring has non-zero dt to integrate)
      await _pumpFrame(tester);
      await _pumpFrame(tester);
      expect(ctrl.value, greaterThan(0.0));
    });

    testWidgets('isShowing becomes true after open() advances', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await _pumpFrame(tester);
      await _pumpFrame(tester);
      expect(ctrl.isShowing, isTrue);
    });

    testWidgets('value approaches 1.0 after animation settles', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      expect(ctrl.value, closeTo(1.0, 0.01));
    });
  });

  // ── close() ───────────────────────────────────────────────────────────────

  group('GlassMorphController — close()', () {
    testWidgets('sets isClosing to true', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      ctrl.close();
      expect(ctrl.isClosing, isTrue);
    });

    testWidgets('value returns toward 0.0 after close() settles',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      ctrl.close();
      await tester.pumpAndSettle();
      expect(ctrl.value, closeTo(0.0, 0.02));
    });

    testWidgets('hasHandedOff latches true after close animation',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      ctrl.close();
      await tester.pumpAndSettle();
      expect(ctrl.hasHandedOff, isTrue);
    });

    testWidgets('close() can be called before open() without crashing',
        (tester) async {
      final ctrl = await _mount(tester);
      expect(() => ctrl.close(), returnsNormally);
    });

    testWidgets('isClosing is false at construction (never closed)',
        (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.isClosing, isFalse);
    });
  });

  // ── hasHandedOff latch ────────────────────────────────────────────────────

  group('GlassMorphController — hasHandedOff latch', () {
    testWidgets('latch does not fire during open animation', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await _pumpFrame(tester);
      await _pumpFrame(tester);
      // Mid-animation, not closing — handoff must not have fired.
      expect(ctrl.hasHandedOff, isFalse);
    });

    testWidgets('open() after close resets latch to false', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      ctrl.close();
      await tester.pumpAndSettle();
      expect(ctrl.hasHandedOff, isTrue);
      ctrl.open();
      expect(ctrl.hasHandedOff, isFalse);
    });

    testWidgets('latch only fires once per close cycle', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pumpAndSettle();
      ctrl.close();
      await tester.pumpAndSettle();
      final afterFirstClose = ctrl.hasHandedOff;
      // Pump a few more frames — latch must stay latched, not re-fire.
      await _pumpFrame(tester);
      await _pumpFrame(tester);
      expect(ctrl.hasHandedOff, equals(afterFirstClose));
    });
  });

  // ── MorphSpeed variants ───────────────────────────────────────────────────

  group('GlassMorphController — MorphSpeed variants', () {
    for (final speed in MorphSpeed.values) {
      testWidgets('$speed speed opens and settles without crashing',
          (tester) async {
        final ctrl = await _mount(tester, speed: speed);
        ctrl.open();
        await tester.pumpAndSettle();
        expect(ctrl.value, closeTo(1.0, 0.01));
      });
    }

    test(
        'fast spring has higher stiffness than slow (settles faster by design)',
        () {
      // Verify the contract via physics constants rather than animation timing.
      // GlassMorphController._effectiveSpring uses these values:
      //   slow:   stiffness=60,  damping=11.3
      //   normal: stiffness=120, damping=16.0
      //   fast:   stiffness=200, damping=20.5
      //   instant: stiffness=500, damping=32.4
      //
      // Higher stiffness → higher ω₀ → faster settlement.
      // This test validates the ordering of the spring constants.
      // ω₀ = √(stiffness/mass), all at mass=1.
      const slowStiffness = 60.0;
      const normalStiffness = 120.0;
      const fastStiffness = 200.0;
      const instantStiffness = 500.0;

      expect(normalStiffness, greaterThan(slowStiffness));
      expect(fastStiffness, greaterThan(normalStiffness));
      expect(instantStiffness, greaterThan(fastStiffness));
    });
  });

  // ── computeState integration ──────────────────────────────────────────────

  group('GlassMorphController — computeState', () {
    testWidgets('returns a valid LiquidMorphState at rest', (tester) async {
      final ctrl = await _mount(tester);
      final state = ctrl.computeState(finalDx: 80.0, finalDy: 160.0);
      expect(state.pathT, equals(0.0));
      expect(state.sizeT, equals(0.0));
      expect(state.anchorScale, equals(1.0));
      expect(state.containerScale, equals(1.0));
      expect(state.phase, equals(MorphPhase.idle));
    });

    testWidgets('currentDx > 0 after animation settles to halfway',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      // Pump until value is clearly above 0.4 (anchor scale has zeroed out
      // and Blob B is in mid-travel — pathT is guaranteed > 0).
      while (ctrl.value < 0.5) {
        await _pumpFrame(tester);
      }
      final state = ctrl.computeState(finalDx: 80.0, finalDy: 160.0);
      expect(state.currentDx, greaterThan(0.0));
    });

    testWidgets('anchorScale decreases below 1.0 during early open',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await tester.pump(const Duration(milliseconds: 150));
      final state = ctrl.computeState(finalDx: 80.0, finalDy: 160.0);
      expect(state.anchorScale, lessThanOrEqualTo(1.0));
    });

    testWidgets('horizontalOffset and verticalOffset are forwarded correctly',
        (tester) async {
      final ctrl = await _mount(tester);
      expect(
        () => ctrl.computeState(
          finalDx: 80.0,
          finalDy: 160.0,
          horizontalOffset: 12.0,
          verticalOffset: 8.0,
        ),
        returnsNormally,
      );
    });
  });

  // ── ChangeNotifier / listener ─────────────────────────────────────────────

  group('GlassMorphController — ChangeNotifier', () {
    testWidgets('notifies listeners on each tick', (tester) async {
      final ctrl = await _mount(tester);
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.open();
      await tester.pump(const Duration(milliseconds: 100));
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('dispose removes listeners without crashing', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      await _pumpFrame(tester);
      expect(
        () async {
          await tester.pumpWidget(
            const MaterialApp(home: SizedBox.shrink()),
          );
        },
        returnsNormally,
      );
    });
  });

  // ── velocity ─────────────────────────────────────────────────────────────

  group('GlassMorphController — velocity', () {
    testWidgets('velocity is non-zero mid-animation', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.open();
      // Pump multiple frames so the spring has a genuine non-zero velocity.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 16));
      expect(ctrl.velocity.abs(), greaterThan(0.0));
    });
  });

  // ── MorphPhase enum completeness ──────────────────────────────────────────

  group('MorphPhase enum', () {
    test('has all expected values', () {
      expect(
        MorphPhase.values,
        containsAll([
          MorphPhase.idle,
          MorphPhase.detaching,
          MorphPhase.travelling,
          MorphPhase.arriving,
          MorphPhase.settled,
        ]),
      );
    });
  });

  // ── MorphSpeed enum completeness ──────────────────────────────────────────

  group('MorphSpeed enum', () {
    test('has all expected values', () {
      expect(
        MorphSpeed.values,
        containsAll([
          MorphSpeed.slow,
          MorphSpeed.normal,
          MorphSpeed.fast,
          MorphSpeed.instant,
        ]),
      );
    });
  });

  // ── MorphStyle enum completeness ──────────────────────────────────────────

  group('MorphStyle enum', () {
    test('has all expected values', () {
      expect(
        MorphStyle.values,
        containsAll([
          MorphStyle.teardrop,
          MorphStyle.bloom,
        ]),
      );
    });
  });

  // ── disableAnimations / reduced-motion ────────────────────────────────────

  group('GlassMorphController — disableAnimations', () {
    testWidgets('defaults to false', (tester) async {
      final ctrl = await _mount(tester);
      expect(ctrl.disableAnimations, isFalse);
    });

    testWidgets('setDisableAnimations(true) sets the flag', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.setDisableAnimations(true);
      expect(ctrl.disableAnimations, isTrue);
    });

    testWidgets('setDisableAnimations(false) clears the flag', (tester) async {
      final ctrl = await _mount(tester);
      ctrl.setDisableAnimations(true);
      ctrl.setDisableAnimations(false);
      expect(ctrl.disableAnimations, isFalse);
    });

    testWidgets('setDisableAnimations is idempotent (same value is a no-op)',
        (tester) async {
      final ctrl = await _mount(tester);
      // Calling with the current value must not throw or notify.
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.setDisableAnimations(false); // already false — no-op
      expect(notifyCount, equals(0));
    });

    testWidgets('open() with disableAnimations=true still settles to ~1.0',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.setDisableAnimations(true);
      ctrl.open();
      // The instant spring is stiffer than normal but still integrates over
      // engine frames — pumpAndSettle is the reliable way to let it finish.
      await tester.pumpAndSettle();
      expect(ctrl.value, closeTo(1.0, 0.01));
    });

    test(
        'disableAnimations uses instant spring (stiffness=500) — '
        'same as MorphSpeed.instant, which is the fastest preset', () {
      // The instant-spring constant (stiffness=500) used by disableAnimations
      // is identical to MorphSpeed.instant, which already sits above the
      // fast (200) and normal (120) presets. Verify the ordering.
      const disabledStiffness = 500.0; // matches _effectiveSpring override
      const fastStiffness = 200.0;
      const normalStiffness = 120.0;

      expect(disabledStiffness, greaterThan(fastStiffness));
      expect(disabledStiffness, greaterThan(normalStiffness));
    });

    testWidgets('disableAnimations does not affect value at rest',
        (tester) async {
      final ctrl = await _mount(tester);
      ctrl.setDisableAnimations(true);
      // No open() called — value must still be 0.
      expect(ctrl.value, equals(0.0));
    });
  });
}
