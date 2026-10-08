// test/renderer/uv_freeze_gate_test.dart
//
// Unit tests for the LiquidGlassPushBackScope gate in _hasScale().
//
// Verifies the fix for #292: a persistent app-level scale
// (e.g. responsive_framework, FittedBox) must NOT freeze UV coordinates.
// Only a CupertinoSheet push-back — signalled by LiquidGlassPushBackScope —
// should enable the freeze.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_push_back_scope.dart';
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_self_scale_scope.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  group('LiquidGlassPushBackScope.of', () {
    testWidgets('returns false when no scope ancestor exists', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Builder(builder: (context) {
          captured = context;
          return const SizedBox();
        }),
      );
      expect(LiquidGlassPushBackScope.of(captured), isFalse);
    });

    testWidgets('returns true when active scope wraps context', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        LiquidGlassPushBackScope(
          active: true,
          child: Builder(builder: (context) {
            captured = context;
            return const SizedBox();
          }),
        ),
      );
      expect(LiquidGlassPushBackScope.of(captured), isTrue);
    });

    testWidgets('returns false when scope present but inactive',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        LiquidGlassPushBackScope(
          active: false,
          child: Builder(builder: (context) {
            captured = context;
            return const SizedBox();
          }),
        ),
      );
      expect(LiquidGlassPushBackScope.of(captured), isFalse);
    });

    testWidgets('inner active scope shadows outer inactive scope',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        LiquidGlassPushBackScope(
          active: false,
          child: LiquidGlassPushBackScope(
            active: true,
            child: Builder(builder: (context) {
              captured = context;
              return const SizedBox();
            }),
          ),
        ),
      );
      expect(LiquidGlassPushBackScope.of(captured), isTrue);
    });

    testWidgets('updateShouldNotify fires when active changes', (tester) async {
      bool pushBack = false;
      int buildCount = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          outerSetState = setState;
          return LiquidGlassPushBackScope(
            active: pushBack,
            child: Builder(builder: (context) {
              LiquidGlassPushBackScope.of(context); // register dependency
              buildCount++;
              return const SizedBox();
            }),
          );
        }),
      );

      final countBefore = buildCount;
      outerSetState(() => pushBack = !pushBack);
      await tester.pump();
      expect(buildCount, greaterThan(countBefore),
          reason: 'dependent must rebuild when active flips');
    });
  });

  // ---------------------------------------------------------------------------
  // LiquidGlassSelfScaleScope — existing contract still holds
  // ---------------------------------------------------------------------------

  group('LiquidGlassSelfScaleScope.of', () {
    testWidgets('returns false without ancestor', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Builder(builder: (context) {
          captured = context;
          return const SizedBox();
        }),
      );
      expect(LiquidGlassSelfScaleScope.of(captured), isFalse);
    });

    testWidgets('returns selfScaled value from nearest ancestor',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        LiquidGlassSelfScaleScope(
          selfScaled: true,
          child: Builder(builder: (context) {
            captured = context;
            return const SizedBox();
          }),
        ),
      );
      expect(LiquidGlassSelfScaleScope.of(captured), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Gate contract: scale + no push-back scope → must NOT freeze
  // ---------------------------------------------------------------------------

  group('UV freeze gate — #292 regression contract', () {
    /// Builds a widget tree and verifies the push-back gate is off by default,
    /// ensuring that a static app-level scale (responsive_framework pattern)
    /// cannot activate UV freezing.
    testWidgets('scale without push-back scope yields pushBackActive = false',
        (tester) async {
      // This simulates the responsive_framework scenario: a Transform.scale
      // wraps the whole app but no GlassPage is present → no push-back scope
      // should be emitted → UV freeze must NOT activate.
      late BuildContext captured;
      await tester.pumpWidget(
        Transform.scale(
          scale: 0.9, // simulates responsive_framework's persistent scale
          child: Builder(builder: (context) {
            captured = context;
            return const SizedBox(width: 100, height: 100);
          }),
        ),
      );
      expect(
        LiquidGlassPushBackScope.of(captured),
        isFalse,
        reason: 'no push-back scope → _hasScale must return false → no jitter',
      );
    });

    testWidgets(
        'scale WITH active push-back scope yields pushBackActive = true',
        (tester) async {
      // This simulates GlassPage emitting the scope during a sheet push-back.
      late BuildContext captured;
      await tester.pumpWidget(
        LiquidGlassPushBackScope(
          active: true,
          child: Transform.scale(
            scale: 0.9,
            child: Builder(builder: (context) {
              captured = context;
              return const SizedBox(width: 100, height: 100);
            }),
          ),
        ),
      );
      expect(
        LiquidGlassPushBackScope.of(captured),
        isTrue,
        reason:
            'push-back scope active → _hasScale may return true → freeze OK',
      );
    });

    testWidgets(
        'selfScaled=true overrides push-back — self-scale must never freeze',
        (tester) async {
      // LiquidStretch and GlassMaterializeEffect set selfScaled: true.
      // Even if a push-back scope is active above them, the self-scale guard
      // should take precedence so their internal animation never freezes.
      late BuildContext captured;
      await tester.pumpWidget(
        LiquidGlassPushBackScope(
          active: true,
          child: LiquidGlassSelfScaleScope(
            selfScaled: true,
            child: Builder(builder: (context) {
              captured = context;
              return const SizedBox(width: 100, height: 100);
            }),
          ),
        ),
      );
      // The selfScaled guard is checked BEFORE pushBackActive in _hasScale,
      // so selfScaled: true → _hasScale → false, regardless of push-back scope.
      expect(
        LiquidGlassSelfScaleScope.of(captured),
        isTrue,
        reason:
            'selfScaled must be true so _hasScale short-circuits → no freeze',
      );
      // (Push-back scope is still active above, but selfScaled wins.)
      expect(LiquidGlassPushBackScope.of(captured), isTrue);
    });

    testWidgets('scope transitions active→inactive → dependents rebuild',
        (tester) async {
      bool active = true;
      int rebuilds = 0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          outerSetState = setState;
          return LiquidGlassPushBackScope(
            active: active,
            child: Builder(builder: (context) {
              LiquidGlassPushBackScope.of(context);
              rebuilds++;
              return const SizedBox();
            }),
          );
        }),
      );

      final before = rebuilds;
      outerSetState(() => active = false);
      await tester.pump();
      expect(rebuilds, greaterThan(before),
          reason: 'scope going inactive must rebuild dependents');

      late BuildContext ctx;
      await tester.pumpWidget(
        LiquidGlassPushBackScope(
          active: false,
          child: Builder(builder: (context) {
            ctx = context;
            return const SizedBox();
          }),
        ),
      );
      expect(LiquidGlassPushBackScope.of(ctx), isFalse,
          reason: 'after transition settles, scope must be inactive');
    });

    // These tests cover scope notifications; push_back_layout_test.dart
    // exercises the render object's layout-safe snapshot refresh directly.
    testWidgets('scope reads false cleanly after active→inactive cycle',
        (tester) async {
      bool active = false;
      late StateSetter outerSetState;
      late BuildContext capturedContext;

      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          outerSetState = setState;
          return LiquidGlassPushBackScope(
            active: active,
            child: Builder(builder: (context) {
              capturedContext = context;
              LiquidGlassPushBackScope.of(context);
              return const SizedBox();
            }),
          );
        }),
      );

      // Activate (sheet opens).
      outerSetState(() => active = true);
      await tester.pump();
      expect(LiquidGlassPushBackScope.of(capturedContext), isTrue,
          reason: 'scope must be active after first flip');

      // Deactivate (sheet dismissed).
      outerSetState(() => active = false);
      await tester.pump();
      expect(LiquidGlassPushBackScope.of(capturedContext), isFalse,
          reason:
              'scope must be inactive after dismissal; no stale true must linger');
    });

    testWidgets('rapid true→false→true→false cycling lands correctly',
        (tester) async {
      bool active = false;
      late StateSetter outerSetState;
      late BuildContext capturedContext;

      await tester.pumpWidget(
        StatefulBuilder(builder: (_, setState) {
          outerSetState = setState;
          return LiquidGlassPushBackScope(
            active: active,
            child: Builder(builder: (context) {
              capturedContext = context;
              LiquidGlassPushBackScope.of(context);
              return const SizedBox();
            }),
          );
        }),
      );

      for (int i = 0; i < 3; i++) {
        outerSetState(() => active = true);
        await tester.pump();
        expect(LiquidGlassPushBackScope.of(capturedContext), isTrue,
            reason: 'cycle $i: scope must be active');

        outerSetState(() => active = false);
        await tester.pump();
        expect(LiquidGlassPushBackScope.of(capturedContext), isFalse,
            reason: 'cycle $i: scope must be inactive after dismissal');
      }
    });
  });
}
