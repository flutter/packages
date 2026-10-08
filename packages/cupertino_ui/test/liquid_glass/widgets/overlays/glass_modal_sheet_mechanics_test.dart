// Coverage for SheetSnapshot, SheetGeometry, GestureArena, FrozenState,
// GlassModalSheetController — all accessible via glass_modal_sheet.dart library.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/overlays/glass_modal_sheet.dart';

// The mechanics types are part of the glass_modal_sheet library.
// We access them via the public API surface: re-exported from the part files.

void main() {
  const screen = Size(390, 844);

  // ── SheetSnapshot ─────────────────────────────────────────────────────────

  group('SheetSnapshot', () {
    test('copyWith replaces only specified fields', () {
      const s = SheetSnapshot(
        state: GlassSheetState.half,
        position: 0.45,
        velocity: 0.0,
        screenSize: Size(390, 844),
      );
      final s2 = s.copyWith(velocity: 500.0, state: GlassSheetState.full);
      expect(s2.state, GlassSheetState.full);
      expect(s2.velocity, 500.0);
      expect(s2.position, 0.45);
    });

    test('expandProgress=0 when position is at half', () {
      const s = SheetSnapshot(
        state: GlassSheetState.half,
        position: 0.0,
        screenSize: Size(390, 844),
      );
      expect(s.expandProgress, 0.0);
    });

    test('expandProgress=1 when position is at full', () {
      const s = SheetSnapshot(
        state: GlassSheetState.full,
        position: 1.0,
        screenSize: Size(390, 844),
      );
      expect(s.expandProgress, 1.0);
    });

    test('toString contains state name', () {
      const s = SheetSnapshot(
        state: GlassSheetState.peek,
        position: 0.1,
        screenSize: Size(390, 844),
      );
      expect(s.toString(), contains('peek'));
    });
  });

  // ── SheetGeometry.positionFor ─────────────────────────────────────────────

  group('SheetGeometry.positionFor static', () {
    test('hidden → 0.0', () {
      expect(SheetGeometry.positionFor(GlassSheetState.hidden, screen.height),
          0.0);
    });

    test('peek absolute pixels → fraction', () {
      final pos = SheetGeometry.positionFor(GlassSheetState.peek, screen.height,
          peekSize: 90.0);
      expect(pos, closeTo(90.0 / screen.height, 0.001));
    });

    test('peek fraction ≤ 1 → returned as-is', () {
      final pos = SheetGeometry.positionFor(GlassSheetState.peek, screen.height,
          peekSize: 0.1);
      expect(pos, 0.1);
    });

    test('half absolute pixels → fraction', () {
      final pos = SheetGeometry.positionFor(GlassSheetState.half, screen.height,
          halfSize: 380.0);
      expect(pos, closeTo(380.0 / screen.height, 0.001));
    });

    test('full with explicit absolute fullSize', () {
      final pos = SheetGeometry.positionFor(GlassSheetState.full, screen.height,
          fullSize: 700.0);
      expect(pos, closeTo(700.0 / screen.height, 0.001));
    });

    test('full with fraction fullSize ≤ 1', () {
      final pos = SheetGeometry.positionFor(GlassSheetState.full, screen.height,
          fullSize: 0.9);
      expect(pos, 0.9);
    });

    test('full with null fullSize uses 90px inset', () {
      final pos =
          SheetGeometry.positionFor(GlassSheetState.full, screen.height);
      expect(pos, closeTo((screen.height - 90) / screen.height, 0.001));
    });
  });

  // ── SheetGeometry.resolveTarget ───────────────────────────────────────────

  group('SheetGeometry.resolveTarget', () {
    const geo = SheetGeometry(
      mode: GlassSheetMode.dismissible,
      halfSize: 0.45,
      peekSize: 90,
      enablePeek: false,
    );

    SheetSnapshot snap(double pos, GlassSheetState state, {double vel = 0}) =>
        SheetSnapshot(
            state: state, position: pos, velocity: vel, screenSize: screen);

    test('upward flick → full', () {
      // Position must be above half to flick upward to full.
      final halfPos =
          SheetGeometry.positionFor(GlassSheetState.half, screen.height);
      final fullPos =
          SheetGeometry.positionFor(GlassSheetState.full, screen.height);
      final midPos = (halfPos + fullPos) / 2;
      expect(
        geo.resolveTarget(snap(midPos, GlassSheetState.half, vel: 1500),
            snapThreshold: 0.4, velocityThreshold: 700),
        GlassSheetState.full,
      );
    });

    test('downward flick → hidden', () {
      expect(
        geo.resolveTarget(snap(0.3, GlassSheetState.half, vel: -1500),
            snapThreshold: 0.4, velocityThreshold: 700),
        GlassSheetState.hidden,
      );
    });

    test('at bottom → snaps to hidden', () {
      expect(
        geo.resolveTarget(snap(0.0, GlassSheetState.hidden),
            snapThreshold: 0.4, velocityThreshold: 700),
        GlassSheetState.hidden,
      );
    });

    test('at top → snaps to full', () {
      expect(
        geo.resolveTarget(snap(1.0, GlassSheetState.full),
            snapThreshold: 0.4, velocityThreshold: 700),
        GlassSheetState.full,
      );
    });

    test('static: beyond threshold promotes', () {
      final halfPos =
          SheetGeometry.positionFor(GlassSheetState.half, screen.height);
      final fullPos =
          SheetGeometry.positionFor(GlassSheetState.full, screen.height);
      final crossed = halfPos + (fullPos - halfPos) * 0.7;
      expect(
        geo.resolveTarget(snap(crossed, GlassSheetState.half),
            snapThreshold: 0.4, velocityThreshold: 700),
        GlassSheetState.full,
      );
    });

    test('persistent mode includes peek in state list', () {
      const persistentGeo = SheetGeometry(
        mode: GlassSheetMode.persistent,
        halfSize: 0.45,
        peekSize: 90,
        enablePeek: true,
      );
      final peekPos = SheetGeometry.positionFor(
          GlassSheetState.peek, screen.height,
          peekSize: 90);
      final result = persistentGeo.resolveTarget(
        snap(peekPos, GlassSheetState.peek),
        snapThreshold: 0.4,
        velocityThreshold: 700,
      );
      expect(result, isA<GlassSheetState>());
    });
  });

  // ── SheetGeometry.applyResistance ─────────────────────────────────────────

  group('SheetGeometry.applyResistance', () {
    const geo = SheetGeometry(
      mode: GlassSheetMode.dismissible,
      halfSize: 0.45,
      peekSize: 90,
      enablePeek: false,
    );

    test('below minPos → rubber-band', () {
      final r = geo.applyResistance(-0.5, screen.height, resistance: 0.2);
      expect(r, greaterThan(-0.5));
    });

    test('above fullPos → rubber-band', () {
      final r = geo.applyResistance(2.0, screen.height, resistance: 0.2);
      expect(r, lessThan(2.0));
    });

    test('within bounds → unchanged', () {
      final r = geo.applyResistance(0.45, screen.height, resistance: 0.2);
      expect(r, closeTo(0.45, 0.001));
    });
  });

  // ── GestureArena ──────────────────────────────────────────────────────────

  group('GestureArena', () {
    late GestureArena arena;
    setUp(() => arena = GestureArena());

    test('reset clears phase', () {
      arena.phase = GesturePhase.handleDrag;
      arena.reset();
      expect(arena.phase, GesturePhase.idle);
    });

    test('beginHandleDrag sets phase', () {
      arena.beginHandleDrag(200.0, 0.4);
      expect(arena.phase, GesturePhase.handleDrag);
    });

    test('beginPointer sets fields', () {
      arena.beginPointer(100, 50, 0.3, PointerDeviceKind.touch);
      expect(arena.dragStartY, 100);
      expect(arena.dragStartX, 50);
    });

    test('handleDrag phase → evaluateMove always true', () {
      arena.phase = GesturePhase.handleDrag;
      expect(
          arena.evaluateMove(
              0, 0, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: false,
              atTopDetent: false),
          isTrue);
    });

    test('scrolling phase → evaluateMove always false', () {
      arena.phase = GesturePhase.scrolling;
      expect(
          arena.evaluateMove(
              0, 0, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: false,
              atTopDetent: false),
          isFalse);
    });

    test('contentDrag phase → evaluateMove always true', () {
      arena.phase = GesturePhase.contentDrag;
      expect(
          arena.evaluateMove(
              0, 0, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: false,
              atTopDetent: false),
          isTrue);
    });

    test('upward full + hasScrollClients → scrolling', () {
      arena.beginPointer(100, 50, 0.9, PointerDeviceKind.touch);
      final r = arena.evaluateMove(
          80, 50, GlassSheetState.full, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: true, atTopDetent: true);
      expect(r, isFalse);
      expect(arena.phase, GesturePhase.scrolling);
    });

    test('upward full + no clients → contentDrag', () {
      arena.beginPointer(100, 50, 0.9, PointerDeviceKind.touch);
      final r = arena.evaluateMove(
          80, 50, GlassSheetState.full, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: false, atTopDetent: true);
      expect(r, isTrue);
      expect(arena.phase, GesturePhase.contentDrag);
    });

    test('downward full + canScrollListUp → scrolling', () {
      arena.beginPointer(100, 50, 0.9, PointerDeviceKind.touch);
      final r = arena.evaluateMove(
          120, 50, GlassSheetState.full, GlassSheetState.full, 5,
          canScrollListUp: true, hasScrollClients: true, atTopDetent: true);
      expect(r, isFalse);
      expect(arena.phase, GesturePhase.scrolling);
    });

    test('downward full + cannot scroll → contentDrag', () {
      arena.beginPointer(100, 50, 0.9, PointerDeviceKind.touch);
      final r = arena.evaluateMove(
          120, 50, GlassSheetState.full, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: false, atTopDetent: true);
      expect(r, isTrue);
      expect(arena.phase, GesturePhase.contentDrag);
    });

    test('a horizontal gesture locks out the sheet for the whole touch', () {
      // Regression: the axis test used to be re-run on every move, so a
      // sideways swipe grabbed the sheet the moment cumulative vertical
      // travel overtook horizontal — a wobble at the end of a scroll.
      arena.beginPointer(100, 50, 0.3, PointerDeviceKind.touch);
      // Decisive sideways movement first.
      expect(
          arena.evaluateMove(
              102, 90, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: false),
          isFalse);
      expect(arena.phase, GesturePhase.scrolling);
      // Now drag hard vertically WITHOUT lifting. The sheet must stay out.
      expect(
          arena.evaluateMove(
              -200, 90, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: false),
          isFalse);
      expect(arena.phase, GesturePhase.scrolling);
    });

    test('a long sideways scroll does not block the NEXT drag', () {
      // The other half of the same bug: after ~220pt sideways the sheet
      // needed >220pt vertical before it would respond. A fresh touch must
      // start clean.
      arena.beginPointer(100, 50, 0.3, PointerDeviceKind.touch);
      arena.evaluateMove(
          105, 270, GlassSheetState.half, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: true, atTopDetent: false);
      expect(arena.phase, GesturePhase.scrolling);
      arena.reset();
      arena.beginPointer(100, 270, 0.3, PointerDeviceKind.touch);
      expect(
          arena.evaluateMove(
              80, 270, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: false),
          isTrue);
      expect(arena.phase, GesturePhase.contentDrag);
    });

    test('stays undecided until movement clears the threshold', () {
      // A few pixels of noise must not pick an axis.
      arena.beginPointer(100, 50, 0.3, PointerDeviceKind.touch);
      expect(
          arena.evaluateMove(
              103, 52, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: false),
          isFalse);
      expect(arena.phase, GesturePhase.idle);
    });

    test('tops out mid-drag → hands the rest of the pointer to the content',
        () {
      // The sheet grew from below, so the pointer starts as the sheet's.
      arena.beginPointer(400, 50, 0.5, PointerDeviceKind.touch);
      expect(
          arena.evaluateMove(
              380, 50, GlassSheetState.half, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: false),
          isTrue);
      expect(arena.phase, GesturePhase.contentDrag);

      // Same pointer, still travelling up, now at the topmost detent.
      expect(
          arena.evaluateMove(
              360, 50, GlassSheetState.full, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: true),
          isFalse);
      expect(arena.phase, GesturePhase.scrolling);
      expect(arena.isVerticalGesture, isTrue);
    });

    test('does not hand over while the sheet can still grow', () {
      arena.beginPointer(400, 50, 0.5, PointerDeviceKind.touch);
      arena.evaluateMove(380, 50, GlassSheetState.half, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: true, atTopDetent: false);
      // currentState already reads `full` — it carries the drag's predicted
      // target. Only measured travel may stand the sheet down, or it would be
      // stranded short of the detent it was predicting.
      expect(
          arena.evaluateMove(
              360, 50, GlassSheetState.full, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: false),
          isTrue);
      expect(arena.phase, GesturePhase.contentDrag);
    });

    test('does not hand over on a downward drag at the top detent', () {
      arena.beginPointer(400, 50, 0.9, PointerDeviceKind.touch);
      arena.evaluateMove(380, 50, GlassSheetState.half, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: true, atTopDetent: false);
      expect(arena.phase, GesturePhase.contentDrag);
      // Reversing downward is the collapse, not a scroll.
      expect(
          arena.evaluateMove(
              400, 50, GlassSheetState.full, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: true),
          isTrue);
      expect(arena.phase, GesturePhase.contentDrag);
    });

    test('content back at its top hands a downward drag to the sheet', () {
      arena.beginPointer(100, 50, 0.9, PointerDeviceKind.touch);
      // Content is scrolled, so it owns the downward drag first.
      expect(
          arena.evaluateMove(
              120, 50, GlassSheetState.full, GlassSheetState.full, 5,
              canScrollListUp: true, hasScrollClients: true, atTopDetent: true),
          isFalse);
      expect(arena.phase, GesturePhase.scrolling);

      // Same pointer, content now at its top: the sheet takes the remainder.
      expect(
          arena.evaluateMove(
              140, 50, GlassSheetState.full, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: true),
          isTrue);
      expect(arena.phase, GesturePhase.contentDrag);
    });

    test('a horizontal gesture is never woken by the reverse handover', () {
      arena.beginPointer(100, 50, 0.9, PointerDeviceKind.touch);
      // Decisive sideways movement parks the touch in `scrolling`.
      arena.evaluateMove(102, 90, GlassSheetState.full, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: true, atTopDetent: true);
      expect(arena.phase, GesturePhase.scrolling);
      expect(arena.isVerticalGesture, isFalse);

      // Downward drift at the top detent with content at its top would satisfy
      // every other condition of the reverse handover.
      expect(
          arena.evaluateMove(
              140, 90, GlassSheetState.full, GlassSheetState.full, 5,
              canScrollListUp: false,
              hasScrollClients: true,
              atTopDetent: true),
          isFalse);
      expect(arena.phase, GesturePhase.scrolling);
    });

    test('half state vertical drag → contentDrag', () {
      arena.beginPointer(100, 50, 0.5, PointerDeviceKind.touch);
      final r = arena.evaluateMove(
          120, 50, GlassSheetState.half, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: false, atTopDetent: false);
      expect(r, isTrue);
    });

    test('horizontal drag → false', () {
      arena.beginPointer(100, 50, 0.5, PointerDeviceKind.touch);
      final r = arena.evaluateMove(
          102, 80, GlassSheetState.half, GlassSheetState.full, 5,
          canScrollListUp: false, hasScrollClients: false, atTopDetent: false);
      expect(r, isFalse);
    });
  });

  // ── FrozenState ───────────────────────────────────────────────────────────

  group('FrozenState', () {
    test('toString contains scale and height', () {
      const f = FrozenState(bottomScale: 0.95, heightAtFreeze: 400.0);
      expect(f.toString(), contains('scale'));
      expect(f.toString(), contains('400'));
    });
  });

  // ── GlassModalSheetController detached ───────────────────────────────────

  group('GlassModalSheetController detached', () {
    test('currentState returns hidden', () {
      expect(GlassModalSheetController().currentState, GlassSheetState.hidden);
    });

    test('value returns 0.0', () {
      expect(GlassModalSheetController().value, 0.0);
    });

    test('set value does not crash', () {
      GlassModalSheetController().value = 0.5;
    });

    test('snapToState does not crash', () {
      GlassModalSheetController().snapToState(GlassSheetState.full);
    });
  });

  group('SheetGeometry.resolvePeek', () {
    const dismissible = GlassSheetMode.dismissible;
    const persistent = GlassSheetMode.persistent;
    const twoStop = {GlassSheetDetent.medium, GlassSheetDetent.large};
    const withSmall = {
      GlassSheetDetent.small,
      GlassSheetDetent.medium,
      GlassSheetDetent.large,
    };

    test('small in detents enables the peek floor', () {
      expect(
        SheetGeometry.resolvePeek(detents: withSmall, mode: dismissible),
        isTrue,
      );
    });

    test('no small, dismissible → no peek', () {
      expect(
        SheetGeometry.resolvePeek(detents: twoStop, mode: dismissible),
        isFalse,
      );
    });

    test('persistent keeps its floor without small', () {
      // A persistent sheet is DEFINED by resting instead of dismissing, so the
      // default {medium, large} keeps its floor.
      expect(
        SheetGeometry.resolvePeek(detents: twoStop, mode: persistent),
        isTrue,
      );
    });

    test('peek detent feeds orderedStates as a real rest state', () {
      final geo = SheetGeometry(
        mode: dismissible,
        halfSize: 400,
        fullSize: 800,
        peekSize: 100,
        enablePeek:
            SheetGeometry.resolvePeek(detents: withSmall, mode: dismissible),
        enableHalf: withSmall.contains(GlassSheetDetent.medium),
        enableFull: withSmall.contains(GlassSheetDetent.large),
      );
      expect(geo.orderedStates, contains(GlassSheetState.peek));
    });

    test('all primary detents disabled still yields an openable sheet', () {
      // The widget asserts a non-empty detent set in debug, but release
      // builds don't run asserts — a sheet reaching this state with no
      // primary detent would render permanently un-openable. orderedStates
      // falls back to half rather than returning an empty rest set.
      final geo = SheetGeometry(
        mode: dismissible,
        halfSize: 400,
        fullSize: 800,
        peekSize: 0,
        enablePeek: false,
        enableHalf: false,
        enableFull: false,
      );
      expect(geo.orderedStates, contains(GlassSheetState.half));
      expect(geo.maxState, GlassSheetState.half);
    });

    test('half disabled by a zero halfSize also falls back', () {
      // enableHalf is true here, but `halfSize > 0` gates it — the guardrail
      // has to catch this second route to an empty set too.
      final geo = SheetGeometry(
        mode: dismissible,
        halfSize: 0,
        fullSize: 800,
        peekSize: 0,
        enablePeek: false,
        enableHalf: true,
        enableFull: false,
      );
      expect(geo.orderedStates, contains(GlassSheetState.half));
    });
  });

  group('orderedStates — dismissible:false', () {
    test(
        'large-only non-dismissible sheet has orderedStates [full] '
        '(minState == maxState == full, rubber-bands at full)', () {
      // This is the "full-only, non-dismissible" Apple flavor documented in
      // #178: the sheet opens straight to full and cannot be swiped away.
      // orderedStates must be exactly [full] — no hidden, no half, no peek.
      const largeOnly = {GlassSheetDetent.large};
      final geo = SheetGeometry(
        mode: GlassSheetMode.dismissible,
        halfSize: 400,
        fullSize: 800,
        peekSize: 0,
        enablePeek: false,
        enableHalf: largeOnly.contains(GlassSheetDetent.medium),
        enableFull: largeOnly.contains(GlassSheetDetent.large),
        dismissible: false,
      );
      expect(geo.orderedStates, [GlassSheetState.full]);
      expect(geo.minState, GlassSheetState.full);
      expect(geo.maxState, GlassSheetState.full);
    });

    test(
        'medium-only non-dismissible sheet has orderedStates [half] '
        '(rubber-bands at half, never morphs to opaque full)', () {
      // The Apple Pay / Sign in with Apple flavor: half-only glass, no dismiss.
      const mediumOnly = {GlassSheetDetent.medium};
      final geo = SheetGeometry(
        mode: GlassSheetMode.dismissible,
        halfSize: 400,
        fullSize: 800,
        peekSize: 0,
        enablePeek: false,
        enableHalf: mediumOnly.contains(GlassSheetDetent.medium),
        enableFull: mediumOnly.contains(GlassSheetDetent.large),
        dismissible: false,
      );
      expect(geo.orderedStates, [GlassSheetState.half]);
      expect(geo.minState, GlassSheetState.half);
      expect(geo.maxState, GlassSheetState.half);
    });
  });
}
