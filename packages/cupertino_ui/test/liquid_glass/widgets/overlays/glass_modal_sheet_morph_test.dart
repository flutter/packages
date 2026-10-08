// Coverage for the Liquid Morph presentation of GlassModalSheet:
// SheetMorphGeometry (pure) and GlassSheetMorphPresenter (widget), plus the
// capability fallback GlassModalSheet.show() applies before pushing the route.
//
// Both types live in the glass_modal_sheet library rather than the package's
// public surface, so — like the mechanics tests — this imports the library file
// directly.

import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show GlassQuality, GlassTheme, GlassThemeData, MorphSpeed;
import 'package:liquid_glass_widgets/widgets/shared/adaptive_glass.dart'
    show AdaptiveGlass;
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_renderer.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_glass.dart';
import 'package:liquid_glass_widgets/widgets/shared/adaptive_liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/widgets/overlays/glass_modal_sheet.dart';

/// A 400 × 800 screen keeps every expected number below exact and readable.
const _screen = Size(400, 800);

/// Two detents, no peek floor — the default sheet configuration.
const _defaultGeometry = SheetGeometry(
  mode: GlassSheetMode.dismissible,
  halfSize: 0.5,
  peekSize: 100.0,
  enablePeek: false,
);

const _peekGeometry = SheetGeometry(
  mode: GlassSheetMode.persistent,
  halfSize: 0.5,
  peekSize: 100.0,
  enablePeek: true,
);

/// Glass (blurred) and solid (blur-free) surfaces, for the fill branches.
const _glassSettings = LiquidGlassSettings(blur: 10.0);
const _solidSettings = LiquidGlassSettings(blur: 0.0);

Widget _app(Widget child, {bool disableAnimations = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: _screen,
          disableAnimations: disableAnimations,
        ),
        child: Scaffold(backgroundColor: Colors.transparent, body: child),
      ),
    );

void main() {
  group('SheetMorphGeometry.restingRect', () {
    test('half detent rests inset by the sheet margins', () {
      final rect = SheetMorphGeometry.restingRect(
        state: GlassSheetState.half,
        geometry: _defaultGeometry,
        screenSize: _screen,
        horizontalMargin: 8.0,
        bottomMargin: 6.0,
        bottomInset: 34.0,
        bottomRadius: 56.0,
      );

      // pos = 0.5 → the top edge sits halfway down the screen.
      expect(rect.top, 400.0);
      expect(rect.left, 8.0);
      expect(rect.right, 392.0);
      expect(rect.bottom, 794.0); // 800 - bottomMargin
      expect(rect.height, 394.0);
    });

    test('full detent runs edge to edge and sinks past the bottom', () {
      final rect = SheetMorphGeometry.restingRect(
        state: GlassSheetState.full,
        geometry: _defaultGeometry,
        screenSize: _screen,
        horizontalMargin: 8.0,
        bottomMargin: 6.0,
        bottomInset: 34.0,
        bottomRadius: 46.0,
      );

      // Default full size is screenHeight - 90.
      expect(rect.top, closeTo(90.0, 1e-9));
      expect(rect.left, 0.0);
      expect(rect.right, 400.0);
      // Sunk by bottomInset + bottomRadius so the lower corners leave screen.
      expect(rect.bottom, 880.0);
    });

    test('peek detent honours the peek-specific margins', () {
      final rect = SheetMorphGeometry.restingRect(
        state: GlassSheetState.peek,
        geometry: _peekGeometry,
        screenSize: _screen,
        horizontalMargin: 8.0,
        bottomMargin: 6.0,
        bottomInset: 0.0,
        bottomRadius: 56.0,
        peekHorizontalMargin: 20.0,
        peekBottomMargin: 12.0,
      );

      // peekSize 100 of an 800pt screen → pos 0.125 → top 700.
      expect(rect.top, 700.0);
      expect(rect.left, 20.0);
      expect(rect.right, 380.0);
      expect(rect.bottom, 788.0);
    });

    test('peekWidth centres a fixed-width floor instead of insetting it', () {
      final rect = SheetMorphGeometry.restingRect(
        state: GlassSheetState.peek,
        geometry: _peekGeometry,
        screenSize: _screen,
        horizontalMargin: 8.0,
        bottomMargin: 6.0,
        bottomInset: 0.0,
        bottomRadius: 56.0,
        peekWidth: 200.0,
      );

      expect(rect.left, 100.0);
      expect(rect.width, 200.0);
    });

    test('hidden collapses to the bottom edge without inverting', () {
      final rect = SheetMorphGeometry.restingRect(
        state: GlassSheetState.hidden,
        geometry: _defaultGeometry,
        screenSize: _screen,
        horizontalMargin: 8.0,
        bottomMargin: 6.0,
        bottomInset: 0.0,
        bottomRadius: 56.0,
      );

      expect(rect.top, 800.0);
      expect(rect.height, 0.0);
      expect(rect.isEmpty, isTrue);
    });

    test('margins wider than the screen clamp instead of inverting', () {
      final rect = SheetMorphGeometry.restingRect(
        state: GlassSheetState.half,
        geometry: _defaultGeometry,
        screenSize: _screen,
        horizontalMargin: 900.0,
        bottomMargin: 6.0,
        bottomInset: 0.0,
        bottomRadius: 56.0,
      );

      expect(rect.left, 200.0);
      expect(rect.width, 0.0);
    });
  });

  group('SheetMorphGeometry dismiss geometry', () {
    test('a sheet at or above its lowest detent has not been dragged', () {
      expect(
        SheetMorphGeometry.dismissTravel(position: 0.45, minPosition: 0.35),
        0.0,
      );
      expect(
        SheetMorphGeometry.dismissTravel(position: 0.35, minPosition: 0.35),
        0.0,
      );
    });

    test('travel is the gap below the lowest detent', () {
      expect(
        SheetMorphGeometry.dismissTravel(position: 0.20, minPosition: 0.35),
        closeTo(0.15, 1e-9),
      );
    });

    test('scale falls linearly at the measured iOS gain', () {
      // The fitted native gain: 0.64 of scale lost per *card height* dragged.
      // See [SheetMorphGeometry.dismissScaleGain].
      expect(SheetMorphGeometry.dismissScale(0.0, cardFraction: 0.5), 1.0);
      expect(
        SheetMorphGeometry.dismissScale(0.1, cardFraction: 0.5),
        closeTo(1.0 - 0.64 * 0.2, 1e-9),
      );
      // Linear, not eased: half the travel is half the scale loss.
      final half =
          1.0 - SheetMorphGeometry.dismissScale(0.1, cardFraction: 0.5);
      final full =
          1.0 - SheetMorphGeometry.dismissScale(0.2, cardFraction: 0.5);
      expect(half * 2.0, closeTo(full, 1e-9));
    });

    test('the shrink is normalised by the card, not the screen', () {
      // iOS shrinks a small panel faster than a tall sheet for the same drag:
      // Maps' "Map Modes" panel measures ~2.5x per screen height and a medium
      // sheet ~1.4x, and both collapse onto one gain per card height.
      final small = SheetMorphGeometry.dismissScale(0.1, cardFraction: 0.25);
      final tall = SheetMorphGeometry.dismissScale(0.1, cardFraction: 0.5);
      expect(small, lessThan(tall));
      expect(1.0 - small, closeTo((1.0 - tall) * 2.0, 1e-9));
    });

    test('scale eases toward the floor without reaching it', () {
      // A long drag stops making the card meaningfully smaller, but never
      // freezes outright — there is always a little give left.
      final far = SheetMorphGeometry.dismissScale(1.0, cardFraction: 0.5);
      expect(far, greaterThan(SheetMorphGeometry.minDismissScale));
      expect(far, lessThan(0.5));
      expect(
        SheetMorphGeometry.dismissScale(0.5, cardFraction: 0.5),
        greaterThan(far),
        reason: 'still shrinking, just barely',
      );
    });

    test('the measured linear region is untouched by the easing', () {
      // The knee sits at 0.48 of the card's height; up to it the response is
      // exactly the fitted line, so every ordinary swipe stays inside the fit.
      expect(
        SheetMorphGeometry.dismissScale(0.2, cardFraction: 0.5),
        closeTo(1.0 - 0.64 * 0.4, 1e-9),
      );
      expect(
        SheetMorphGeometry.dismissScale(0.24, cardFraction: 0.5),
        closeTo(1.0 - 0.64 * 0.48, 1e-9),
        reason: 'the knee itself is the last untouched point',
      );
    });

    test('degenerate card fraction or screen height returns safe fallbacks',
        () {
      expect(
        SheetMorphGeometry.dampedDismissTravel(0.1, cardFraction: 0.0),
        0.0,
      );
      expect(SheetMorphGeometry.dismissScale(0.1, cardFraction: 0.0), 1.0);
      const resting = Rect.fromLTRB(8, 400, 392, 794);
      final rect = SheetMorphGeometry.dismissedRect(
        restingRect: resting,
        travel: 0.1,
        screenHeight: 0.0,
      );
      expect(rect.width, resting.width);
      expect(rect.height, resting.height);
    });

    test('an untouched sheet dismisses from exactly its resting frame', () {
      const resting = Rect.fromLTRB(8, 400, 392, 794);
      expect(
        SheetMorphGeometry.dismissedRect(
          restingRect: resting,
          travel: 0.0,
          screenHeight: 800,
        ),
        resting,
      );
    });

    test('a sideways drag translates without touching the shrink', () {
      const resting = Rect.fromLTRB(8, 400, 392, 794);
      final straight = SheetMorphGeometry.dismissedRect(
        restingRect: resting,
        travel: 0.15,
        screenHeight: 800,
      );
      final swept = SheetMorphGeometry.dismissedRect(
        restingRect: resting,
        travel: 0.15,
        screenHeight: 800,
        horizontalOffset: 120.0,
      );

      // Measured off iOS 26: a sideways sweep moves the card and leaves its
      // scale alone. Were the shrink keyed to total drag distance instead,
      // this would be markedly smaller than the straight-down frame.
      expect(swept.width, closeTo(straight.width, 1e-9));
      expect(swept.height, closeTo(straight.height, 1e-9));
      expect(swept.center.dx, closeTo(straight.center.dx + 120.0, 1e-9));
      expect(swept.center.dy, closeTo(straight.center.dy, 1e-9));
    });

    test('a swiped sheet shrinks about its centre as it follows the finger',
        () {
      const resting = Rect.fromLTRB(8, 400, 392, 794);
      final swiped = SheetMorphGeometry.dismissedRect(
        restingRect: resting,
        travel: 0.15,
        screenHeight: 800,
      );

      final scale = SheetMorphGeometry.dismissScale(
        0.15,
        cardFraction: resting.height / 800.0,
      );
      // Tracks the finger 1:1 — 0.15 of 800 is 120 logical pixels down.
      expect(swiped.center.dy, closeTo(resting.center.dy + 120.0, 1e-9));
      expect(swiped.center.dx, closeTo(resting.center.dx, 1e-9));
      // Uniform: both axes take the same scale.
      expect(swiped.width, closeTo(resting.width * scale, 1e-9));
      expect(swiped.height, closeTo(resting.height * scale, 1e-9));
    });
  });

  group('SheetMorphGeometry.rubberBand', () {
    test('starts at 1:1 and never reaches the limit', () {
      // The slope at the origin is `tension`, so the first pixels of a sideways
      // push are true direct manipulation rather than immediately gummy.
      expect(SheetMorphGeometry.rubberBand(0, limit: 200), 0.0);
      expect(SheetMorphGeometry.rubberBand(2, limit: 200), closeTo(2.0, 0.05));
      // ...and no finger travel can push past the limit.
      expect(SheetMorphGeometry.rubberBand(1e6, limit: 200), lessThan(200.0));
      expect(
        SheetMorphGeometry.rubberBand(1e6, limit: 200),
        greaterThan(199.0),
      );
    });

    test('resists more the further it goes', () {
      final first = SheetMorphGeometry.rubberBand(50, limit: 200);
      final second = SheetMorphGeometry.rubberBand(100, limit: 200) - first;
      expect(second, lessThan(first), reason: 'the second 50 buys less travel');
    });

    test('is symmetric about zero', () {
      expect(
        SheetMorphGeometry.rubberBand(-60, limit: 200),
        -SheetMorphGeometry.rubberBand(60, limit: 200),
      );
    });

    test('a degenerate limit damps everything away', () {
      expect(SheetMorphGeometry.rubberBand(80, limit: 0), 0.0);
    });
  });

  group('SheetMorphGeometry.horizontalOffsetFor', () {
    // A card sitting well left of centre on a 400-wide screen: lots of room to
    // its right, none to its left.
    const card = Rect.fromLTRB(0, 500, 200, 800);

    test('free travel until the card reaches the edge it is heading for', () {
      // Pushing right, into 200pt of open screen: pure direct manipulation.
      expect(
        SheetMorphGeometry.horizontalOffsetFor(
          rawOffset: 150,
          cardRect: card,
          screenWidth: 400,
        ),
        150.0,
      );
    });

    test('resists immediately when there is nowhere to go', () {
      // Pushing left, with the card already against the left edge.
      final damped = SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: -150,
        cardRect: card,
        screenWidth: 400,
      );
      expect(damped, greaterThan(-150.0), reason: 'held back');
      expect(damped, lessThan(0.0), reason: 'but still follows the finger');
    });

    test('the same finger travel differs by direction, given the room', () {
      final right = SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: 150,
        cardRect: card,
        screenWidth: 400,
      );
      final left = SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: -150,
        cardRect: card,
        screenWidth: 400,
      );
      // The asymmetry is the whole point: resistance tracks where the card is,
      // not how far the finger has moved.
      expect(right, greaterThan(left.abs()));
    });

    test('past the edge it rubber-bands rather than stopping', () {
      final justPast = SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: 260,
        cardRect: card,
        screenWidth: 400,
      );
      final wellPast = SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: 600,
        cardRect: card,
        screenWidth: 400,
      );
      expect(justPast, greaterThan(200.0), reason: 'it does keep moving');
      expect(wellPast, greaterThan(justPast));
      expect(wellPast - justPast, lessThan(340.0),
          reason: 'but far less than '
              'the finger did');
    });
  });

  group('SheetMorphGeometry.dismissedRect scale anchor', () {
    const resting = Rect.fromLTRB(8, 400, 392, 794);
    const screenHeight = 800.0;
    const cardFraction = (794.0 - 400.0) / screenHeight;

    test('the grabbed point stays exactly under the finger', () {
      // The pivot is the grab point carried down with the fall, so below the
      // damping knee the content the finger is holding sits precisely under
      // the finger — the whole feel of the native gesture, and the requirement
      // the bottom-pinned pivot this replaced could not meet.
      const grab = Offset(100, 430);
      const travel = 0.15; // below the knee for this card

      final swiped = SheetMorphGeometry.dismissedRect(
        restingRect: resting,
        travel: travel,
        screenHeight: screenHeight,
        scaleAnchor: grab,
      );

      // The grabbed content, located by its fractional position in the card.
      final fx = (grab.dx - resting.left) / resting.width;
      final fy = (grab.dy - resting.top) / resting.height;
      expect(
        swiped.left + fx * swiped.width,
        closeTo(grab.dx, 1e-9),
        reason: 'the grabbed column does not slide sideways',
      );
      expect(
        swiped.top + fy * swiped.height,
        closeTo(grab.dy + travel * screenHeight, 1e-9),
        reason: 'and the grabbed content is exactly under the finger',
      );
      final scale = SheetMorphGeometry.dismissScale(
        travel,
        cardFraction: cardFraction,
      );
      expect(swiped.width, closeTo(resting.width * scale, 1e-9));
    });

    test('the bottom edge never rises above its resting line', () {
      // With [dismissScaleGain] below 1.0 per card height, anchoring at the
      // grab point can never lift the bottom into view — the fall outruns the
      // shrink. The clamp guards the invariant even for a pivot no real
      // gesture can produce (or a future gain retune that breaks the bound).
      for (final grab in [
        const Offset(100, 430), // near the top of the card
        const Offset(200, 780), // near the bottom
        const Offset(200, 100), // far above the card: clamp territory
      ]) {
        var previousBottom = -double.infinity;
        for (final travel in [0.0, 0.05, 0.1, 0.2, 0.4]) {
          final swiped = SheetMorphGeometry.dismissedRect(
            restingRect: resting,
            travel: travel,
            screenHeight: screenHeight,
            scaleAnchor: grab,
          );
          expect(
            swiped.bottom,
            greaterThanOrEqualTo(resting.bottom - 1e-9),
            reason: 'the underside of the sheet must never come into view',
          );
          expect(swiped.bottom, greaterThanOrEqualTo(previousBottom));
          previousBottom = swiped.bottom;
        }
      }
    });

    test('the fall eases instead of sliding off under the finger', () {
      // Past the knee the card keeps giving a little but stops meaningfully
      // descending — a long drag parks it near the bottom rather than posting
      // it off the screen while the finger is still moving.
      const knee = 0.48 * cardFraction; // the knee, in screen-height units
      expect(
        SheetMorphGeometry.dampedDismissTravel(0.1, cardFraction: cardFraction),
        closeTo(0.1, 1e-9),
      );
      expect(
        SheetMorphGeometry.dampedDismissTravel(knee,
            cardFraction: cardFraction),
        closeTo(knee, 1e-9),
        reason: 'direct manipulation up to the knee',
      );

      final long = SheetMorphGeometry.dampedDismissTravel(
        2.0 * cardFraction,
        cardFraction: cardFraction,
      );
      expect(long, greaterThan(knee), reason: 'never fully frozen');
      final limit = (1.0 - SheetMorphGeometry.minDismissScale) /
          SheetMorphGeometry.dismissScaleGain *
          cardFraction;
      expect(
        long,
        lessThan(limit),
        reason: 'and eased toward the limit the scale floor implies',
      );

      // Four times the knee's travel buys well under twice the fall.
      expect(long, lessThan(knee * 2.0));
    });

    test('shrink and fall ease together off one curve', () {
      // Both read `dampedDismissTravel`, so the card cannot shrink while its
      // position keeps sliding — it settles as one object.
      for (final travel in [0.05, 0.2, 0.3, 0.6]) {
        final damped = SheetMorphGeometry.dampedDismissTravel(
          travel,
          cardFraction: cardFraction,
        );
        expect(
          SheetMorphGeometry.dismissScale(travel, cardFraction: cardFraction),
          closeTo(
            1.0 - SheetMorphGeometry.dismissScaleGain * damped / cardFraction,
            1e-9,
          ),
        );
      }
    });

    test('without an anchor it still shrinks about its own centre', () {
      const travel = 0.15;
      final defaulted = SheetMorphGeometry.dismissedRect(
        restingRect: resting,
        travel: travel,
        screenHeight: 800,
      );
      final fallen = resting.shift(const Offset(0, travel * 800));
      expect(defaulted.center.dx, closeTo(fallen.center.dx, 1e-9));
      expect(defaulted.center.dy, closeTo(fallen.center.dy, 1e-9));
    });
  });

  group('SheetMorphGeometry.blobRect', () {
    const trigger = Rect.fromLTWH(100, 700, 56, 56);
    const destination = Rect.fromLTWH(8, 400, 384, 394);

    test('starts exactly on the trigger', () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 0.0,
        sizeT: 0.0,
      );
      expect(rect.center, trigger.center);
      expect(rect.size, trigger.size);
    });

    test('lands exactly on the destination', () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 1.0,
        sizeT: 1.0,
      );
      // The handoff to the real sheet depends on this being exact.
      expect(rect.center.dx, closeTo(destination.center.dx, 1e-9));
      expect(rect.center.dy, closeTo(destination.center.dy, 1e-9));
      expect(rect.width, closeTo(destination.width, 1e-9));
      expect(rect.height, closeTo(destination.height, 1e-9));
    });

    test('position and size advance independently', () {
      // The J-curve runs ahead of the size curve — that separation is what the
      // metaball neck stretches across, so the blob must not couple them.
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 0.9,
        sizeT: 0.3,
      );
      expect(rect.center.dy, lessThan(trigger.center.dy));
      expect(rect.width, lessThan(destination.width));
      expect(rect.width, greaterThan(trigger.width));
    });

    test('closing undershoot cannot produce a negative size', () {
      // The underdamped close drives sizeT below zero; a negative width would
      // trip a BoxConstraints assert.
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: -0.2,
        sizeT: -0.2,
      );
      expect(rect.width, greaterThanOrEqualTo(0.0));
      expect(rect.height, greaterThanOrEqualTo(0.0));
    });
  });

  group(
      'SheetMorphGeometry.blobRect — continuous fluid expansion (large scaleDelta)',
      () {
    // Typical compose-button → full sheet geometry.
    const trigger = Rect.fromLTWH(172.5, 790.0, 48.0, 48.0);
    const destination = Rect.fromLTWH(0.0, 0.0, 393.0, 852.0);
    const scaleDelta = 12.0; // √(393*852 / 48*48) ≈ 12.05

    test('starts exactly on the trigger at sizeT = 0.0', () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 0.0,
        sizeT: 0.0,
        scaleDelta: scaleDelta,
      );
      expect(rect.size, trigger.size);
      expect(rect.center, trigger.center);
    });

    test('lands exactly on the destination at sizeT = 1.0 / pathT = 1.0', () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 1.0,
        sizeT: 1.0,
        scaleDelta: scaleDelta,
      );
      expect(rect.center.dx, closeTo(destination.center.dx, 1e-9));
      expect(rect.center.dy, closeTo(destination.center.dy, 1e-9));
      expect(rect.width, closeTo(destination.width, 1e-9));
      expect(rect.height, closeTo(destination.height, 1e-9));
    });

    test('continuous fluid expansion in flight (sizeT = 0.50)', () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 0.50,
        sizeT: 0.50,
        scaleDelta: scaleDelta,
      );
      final expectedWidth = lerpDouble(trigger.width, destination.width, 0.50)!;
      final expectedHeight =
          lerpDouble(trigger.height, destination.height, 0.50)!;
      expect(rect.width, closeTo(expectedWidth, 1e-6));
      expect(rect.height, closeTo(expectedHeight, 1e-6));
    });

    test(
        'anchor drift is clamped to at most 8px, keeping the blob rooted at trigger',
        () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: 0.9,
        sizeT: 0.1,
        scaleDelta: scaleDelta,
      );
      // Even under extreme pathT - sizeT separation (0.8), the anchor drift
      // is clamped to 8px so the blob never detaches from the trigger button.
      final driftX = rect.center.dx -
          (trigger.center.dx +
              (destination.center.dx - trigger.center.dx) * 0.1);
      final driftY = rect.center.dy -
          (trigger.center.dy +
              (destination.center.dy - trigger.center.dy) * 0.1);
      expect(driftX.abs(), lessThanOrEqualTo(8.0 + 1e-6));
      expect(driftY.abs(), lessThanOrEqualTo(8.0 + 1e-6));
    });

    test('close undershoot (sizeT = -0.2) does not go negative', () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: -0.2,
        sizeT: -0.2,
        scaleDelta: scaleDelta,
      );
      expect(rect.width, greaterThanOrEqualTo(0.0));
      expect(rect.height, greaterThanOrEqualTo(0.0));
    });

    test(
        'close undershoot (sizeT = -0.2) does not collapse to 0 px on large destinations',
        () {
      final rect = SheetMorphGeometry.blobRect(
        trigger: trigger,
        destination: destination,
        pathT: -0.2,
        sizeT: -0.2,
        scaleDelta: scaleDelta,
      );
      // Squeezed relative to trigger (not collapsed to 0):
      expect(rect.width, closeTo(trigger.width * 0.95, 0.1));
      expect(rect.height, closeTo(trigger.height * 0.95, 0.1));
    });

    group('symmetric monotonic dismissal (isClosing = true)', () {
      const closeTrigger = Rect.fromLTWH(172.5, 780.0, 48.0, 48.0);
      const closeDest = Rect.fromLTWH(0.0, 0.0, 393.0, 852.0);
      const closeScaleDelta = 13.3;

      test('at sizeT=1.0 (start of close) matches destination size', () {
        final rect = SheetMorphGeometry.blobRect(
          trigger: closeTrigger,
          destination: closeDest,
          pathT: 1.0,
          sizeT: 1.0,
          scaleDelta: closeScaleDelta,
          isClosing: true,
        );
        expect(rect.width, closeTo(closeDest.width, 1e-9));
        expect(rect.height, closeTo(closeDest.height, 1e-9));
      });

      test('at mid-dismiss (sizeT=0.5) dimensions are linearly lerped', () {
        final rect = SheetMorphGeometry.blobRect(
          trigger: closeTrigger,
          destination: closeDest,
          pathT: 0.5,
          sizeT: 0.5,
          scaleDelta: closeScaleDelta,
          isClosing: true,
        );
        final expectedW = lerpDouble(closeTrigger.width, closeDest.width, 0.5)!;
        final expectedH =
            lerpDouble(closeTrigger.height, closeDest.height, 0.5)!;
        expect(rect.width, closeTo(expectedW, 1e-6));
        expect(rect.height, closeTo(expectedH, 1e-6));
      });

      test('at sizeT=0.0 (close complete) lands on trigger size', () {
        final rect = SheetMorphGeometry.blobRect(
          trigger: closeTrigger,
          destination: closeDest,
          pathT: 0.0,
          sizeT: 0.0,
          scaleDelta: closeScaleDelta,
          isClosing: true,
        );
        expect(rect.width, closeTo(closeTrigger.width, 1e-9));
        expect(rect.height, closeTo(closeTrigger.height, 1e-9));
      });
    });
  });

  group('SheetMorphGeometry.blobRadius', () {
    test('starts fully rounded at the trigger', () {
      final radius = SheetMorphGeometry.blobRadius(
        blobSize: const Size(56, 56),
        target: 56.0,
        sizeT: 0.0,
      );
      expect(radius, 28.0);
    });

    test('resolves to the sheet radius on arrival', () {
      final radius = SheetMorphGeometry.blobRadius(
        blobSize: const Size(384, 394),
        target: 56.0,
        sizeT: 1.0,
      );
      expect(radius, 56.0);
    });

    test('never exceeds the half-extent of the blob', () {
      // A 56pt target on a 40pt-tall droplet would render as a lozenge with
      // overlapping corners.
      final radius = SheetMorphGeometry.blobRadius(
        blobSize: const Size(384, 40),
        target: 56.0,
        sizeT: 1.0,
      );
      expect(radius, 20.0);
    });

    test('stays round through the travel', () {
      // easeInExpo holds the droplet round until it is nearly landed.
      final radius = SheetMorphGeometry.blobRadius(
        blobSize: const Size(200, 200),
        target: 20.0,
        sizeT: 0.5,
      );
      expect(radius, greaterThan(90.0));
    });
  });

  group('SheetMorphGeometry.fillReveal', () {
    test('holds at zero through the travel', () {
      expect(SheetMorphGeometry.fillReveal(0.0), 0.0);
      expect(SheetMorphGeometry.fillReveal(0.7), 0.0);
    });

    test('ramps to full over the last 30%', () {
      expect(SheetMorphGeometry.fillReveal(0.85), closeTo(0.5, 1e-9));
      expect(SheetMorphGeometry.fillReveal(1.0), 1.0);
    });

    test('clamps past the ends', () {
      expect(SheetMorphGeometry.fillReveal(-0.2), 0.0);
      expect(SheetMorphGeometry.fillReveal(1.4), 1.0);
    });
  });

  group('SheetMorphGeometry.restingFillOpacity', () {
    test('default sheet: glass at half, opaque at full', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.half,
          baseSettings: _glassSettings,
          enablePeek: false,
        ),
        0.0,
      );
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.full,
          baseSettings: _glassSettings,
          enablePeek: false,
        ),
        1.0,
      );
    });

    test('a blur-free base surface is solid at every detent', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.half,
          baseSettings: _solidSettings,
          enablePeek: false,
        ),
        1.0,
      );
    });

    test('explicit full settings keep the full detent glassy', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.full,
          baseSettings: _glassSettings,
          halfSettings: _glassSettings,
          fullSettings: _glassSettings,
          enablePeek: false,
        ),
        0.0,
      );
    });

    test('explicit solid full settings fill on arrival', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.full,
          baseSettings: _glassSettings,
          halfSettings: _glassSettings,
          fullSettings: _solidSettings,
          enablePeek: false,
        ),
        1.0,
      );
      // ...and the half detent it crossfades from stays glass.
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.half,
          baseSettings: _glassSettings,
          halfSettings: _glassSettings,
          fullSettings: _solidSettings,
          enablePeek: false,
        ),
        0.0,
      );
    });

    test('a solid half crossfading to glass is solid at half', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.half,
          baseSettings: _glassSettings,
          halfSettings: _solidSettings,
          fullSettings: _glassSettings,
          enablePeek: false,
        ),
        1.0,
      );
    });

    test('two solid surfaces stay solid throughout', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.full,
          baseSettings: _glassSettings,
          halfSettings: _solidSettings,
          fullSettings: _solidSettings,
          enablePeek: false,
        ),
        1.0,
      );
    });

    test('peek follows the peek surface when the floor is enabled', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.peek,
          baseSettings: _glassSettings,
          enablePeek: true,
        ),
        0.0,
      );
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.peek,
          baseSettings: _glassSettings,
          peekSettings: _solidSettings,
          enablePeek: true,
        ),
        1.0,
      );
    });

    test('peek without a floor falls back to the half surface', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.peek,
          baseSettings: _glassSettings,
          halfSettings: _solidSettings,
          enablePeek: false,
        ),
        1.0,
      );
    });

    test('hidden never fills', () {
      expect(
        SheetMorphGeometry.restingFillOpacity(
          state: GlassSheetState.hidden,
          baseSettings: _glassSettings,
          enablePeek: false,
        ),
        0.0,
      );
    });
  });

  group('SheetMorphGeometry.restingSettings', () {
    test('picks the surface the detent rests on', () {
      expect(
        SheetMorphGeometry.restingSettings(
          state: GlassSheetState.full,
          baseSettings: _glassSettings,
          fullSettings: _solidSettings,
          enablePeek: false,
        ),
        _solidSettings,
      );
      expect(
        SheetMorphGeometry.restingSettings(
          state: GlassSheetState.half,
          baseSettings: _glassSettings,
          halfSettings: _solidSettings,
          enablePeek: false,
        ),
        _solidSettings,
      );
      expect(
        SheetMorphGeometry.restingSettings(
          state: GlassSheetState.peek,
          baseSettings: _glassSettings,
          peekSettings: _solidSettings,
          enablePeek: true,
        ),
        _solidSettings,
      );
      expect(
        SheetMorphGeometry.restingSettings(
          state: GlassSheetState.hidden,
          baseSettings: _glassSettings,
          enablePeek: false,
        ),
        _glassSettings,
      );
    });

    test('peek without a floor uses the half surface', () {
      expect(
        SheetMorphGeometry.restingSettings(
          state: GlassSheetState.peek,
          baseSettings: _glassSettings,
          halfSettings: _solidSettings,
          enablePeek: false,
        ),
        _solidSettings,
      );
    });

    test('falls back to the base surface when nothing is overridden', () {
      expect(
        SheetMorphGeometry.restingSettings(
          state: GlassSheetState.full,
          baseSettings: _glassSettings,
          enablePeek: false,
        ),
        _glassSettings,
      );
    });
  });

  group('GlassSheetMorphPresenter', () {
    /// Builds a presenter with a caller-owned route animation, so the test can
    /// drive the reverse that a real pop would.
    Widget buildPresenter({
      required AnimationController routeAnimation,
      MorphSpeed speed = MorphSpeed.normal,
      GlassSheetState restingState = GlassSheetState.half,
      bool disableAnimations = false,
      GlassMorphAnchor? anchor,
      Color? expandedColor,
      Color? expandedDarkColor,
      Brightness? brightness,
    }) {
      final presenter = GlassSheetMorphPresenter(
        routeAnimation: routeAnimation,
        triggerRect: const Rect.fromLTWH(172, 700, 56, 56),
        anchor: anchor,
        speed: speed,
        restingState: restingState,
        controller: GlassModalSheetController(),
        geometry: _defaultGeometry,
        horizontalMargin: 8.0,
        bottomMargin: 6.0,
        topBorderRadius: 56.0,
        fullTopBorderRadius: 46.0,
        bottomBorderRadius: null,
        fullBottomBorderRadius: null,
        settings: null,
        peekSettings: null,
        halfSettings: null,
        fullSettings: null,
        expandedColor: expandedColor,
        quality: null,
        peekHorizontalMargin: null,
        peekBottomMargin: null,
        peekWidth: null,
        peekTopBorderRadius: null,
        platformViewBackdrop: false,
        expandedDarkColor: expandedDarkColor,
        child: GlassModalSheetScaffold(
          body: SizedBox.shrink(),
          sheet: Text('Sheet body'),
        ),
      );
      return _app(
        disableAnimations: disableAnimations,
        brightness == null
            ? presenter
            : GlassTheme(
                data: GlassThemeData(brightness: brightness),
                child: presenter,
              ),
      );
    }

    testWidgets('fills the droplet with expandedDarkColor in dark mode',
        (tester) async {
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(buildPresenter(
        routeAnimation: route,
        // The full detent is opaque, so the droplet fills on its way there.
        restingState: GlassSheetState.full,
        expandedColor: Colors.white,
        expandedDarkColor: Colors.black,
        brightness: Brightness.dark,
      ));

      // The fill fades in while the droplet grows, so look across the morph.
      final fills = <Color>{};
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        fills.addAll(tester
            .widgetList<ColoredBox>(find.descendant(
              of: find.byType(AdaptiveGlass),
              matching: find.byType(ColoredBox),
            ))
            .map((box) => box.color.withValues(alpha: 1.0)));
      }

      expect(fills, contains(Colors.black.withValues(alpha: 1.0)));
      expect(fills, isNot(contains(Colors.white.withValues(alpha: 1.0))));

      await tester.pumpAndSettle();
    });

    testWidgets('renders the droplet before it lands, then the real sheet',
        (tester) async {
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(buildPresenter(routeAnimation: route));
      await tester.pump(const Duration(milliseconds: 16));

      // Mid-morph: the droplet's glass layer is in the tree and the real sheet
      // is mounted but not yet handed off (content reveals inside the blob).
      expect(find.byType(AdaptiveLiquidGlassLayer), findsWidgets);
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isFalse,
      );

      await tester.pumpAndSettle();

      // Settled: the sheet has taken over and the droplet is gone.
      expect(find.text('Sheet body'), findsOneWidget);
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isTrue,
      );
    });

    testWidgets('the sheet is mounted for the whole morph, never remounted',
        (tester) async {
      // Remounting a glass widget mid-animation re-seeds its layers and springs
      // and shows as a glitch frame, so the sheet element must survive the
      // handoff rather than being inserted at the end.
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(buildPresenter(routeAnimation: route));
      await tester.pump(const Duration(milliseconds: 16));

      final elementDuringMorph =
          tester.element(find.byType(GlassModalSheetScaffold));

      await tester.pumpAndSettle();

      expect(
        tester.element(find.byType(GlassModalSheetScaffold)),
        same(elementDuringMorph),
      );
    });

    testWidgets('a route reverse starts the closing morph', (tester) async {
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(buildPresenter(routeAnimation: route));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isTrue,
      );

      route.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // The sheet hands back to the droplet for the return trip.
      // Real sheet is not yet visible; content is only in the blob.
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isFalse,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('a dragged dismissal morphs too, not just a resting one',
        (tester) async {
      // iOS 26 morphs a swiped-away sheet back into its trigger from wherever
      // the finger let go. This used to skip the morph entirely on the grounds
      // that starting from the resting frame would jump — the jump was real,
      // but the answer is to start from the released frame instead.
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(buildPresenter(routeAnimation: route));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(200, 500));
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();

      route.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // The sheet hands back to the droplet, exactly as a resting close does.
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isFalse,
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a tap that wobbles within slop still morphs', (tester) async {
      // Barrier taps routinely move a pixel or two; treating that as a drag
      // would cost the morph on the most common way of closing the sheet.
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(buildPresenter(routeAnimation: route));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(200, 500));
      await gesture.moveBy(const Offset(1, 2));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      route.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Wobble-within-slop still triggers the morph close.
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isFalse,
      );

      await tester.pumpAndSettle();
    });

    /// Runs an opening morph frame by frame and reports whether it had landed
    /// within 200 ms — long enough for the engine's instant spring, well short
    /// of the ~375 ms native-parity profile.
    Future<bool> landedWithin200ms(
      WidgetTester tester, {
      required bool disableAnimations,
    }) async {
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(
        buildPresenter(
          routeAnimation: route,
          disableAnimations: disableAnimations,
        ),
      );

      var landed = false;
      for (var elapsed = 0; elapsed < 200 && !landed; elapsed += 16) {
        await tester.pump(const Duration(milliseconds: 16));
        // _handedOffToSheet flips to true only when the spring has fully settled
        // at value >= 0.999 — not when the opacity fade starts. That is exactly
        // the moment the droplet hands control to the real sheet.
        landed =
            tester.widget<Visibility>(find.byType(Visibility).first).visible;
      }
      await tester.pumpAndSettle();
      return landed;
    }

    testWidgets('reduce motion resolves the morph immediately', (tester) async {
      // The engine's own accessibility path — the same one GlassMenu takes.
      // The flag has to reach the controller before the spring starts, which is
      // why the presenter opens from didChangeDependencies and not initState;
      // opening in initState left the very first presentation animating at full
      // length with Reduce Motion on.
      expect(await landedWithin200ms(tester, disableAnimations: true), isTrue);
    });

    testWidgets('a normal morph is still travelling at 200 ms', (tester) async {
      // Guards the test above from passing for the wrong reason.
      expect(
          await landedWithin200ms(tester, disableAnimations: false), isFalse);
    });

    testWidgets('morphs into the full detent as well as the half detent',
        (tester) async {
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(
        buildPresenter(
          routeAnimation: route,
          restingState: GlassSheetState.full,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sheet body'), findsOneWidget);
    });

    testWidgets('skips the blend group under platformViewBackdrop (#214)',
        (tester) async {
      // LiquidGlassBlendGroup needs a full LiquidGlassLayer, which
      // AdaptiveLiquidGlassLayer does not create in this mode.
      final route = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 500),
      )..forward();
      addTearDown(route.dispose);

      await tester.pumpWidget(
        _app(
          GlassSheetMorphPresenter(
            routeAnimation: route,
            triggerRect: const Rect.fromLTWH(172, 700, 56, 56),
            anchor: null,
            speed: MorphSpeed.fast,
            restingState: GlassSheetState.half,
            controller: GlassModalSheetController(),
            geometry: _defaultGeometry,
            horizontalMargin: 8.0,
            bottomMargin: 6.0,
            topBorderRadius: 56.0,
            fullTopBorderRadius: 46.0,
            bottomBorderRadius: null,
            fullBottomBorderRadius: null,
            settings: null,
            peekSettings: null,
            halfSettings: null,
            fullSettings: null,
            expandedColor: null,
            quality: null,
            peekHorizontalMargin: null,
            peekBottomMargin: null,
            peekWidth: null,
            peekTopBorderRadius: null,
            platformViewBackdrop: true,
            child: GlassModalSheetScaffold(
              body: SizedBox.shrink(),
              sheet: Text('Sheet body'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(LiquidGlassBlendGroup), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
    });
  });

  group('GlassMorphTrigger', () {
    // GlassMorphAnchor is an opaque token — no public members to drive — so
    // these exercise the trigger the way a consumer does: present a sheet and
    // watch what the trigger renders.
    setUp(() => GlassModalSheet.debugMorphSupportsBlending = true);
    tearDown(() => GlassModalSheet.debugMorphSupportsBlending = null);

    const triggerKey = Key('trigger-content');

    Future<GlassMorphAnchor> pumpTrigger(WidgetTester tester) async {
      late GlassMorphAnchor anchor;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassMorphTrigger(builder: (context, a) {
              anchor = a;
              return const SizedBox(key: triggerKey, width: 56, height: 56);
            }),
          ),
        ),
      );
      await tester.pump();
      return anchor;
    }

    double triggerOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byKey(triggerKey),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    Future<void> present(WidgetTester tester, GlassMorphAnchor anchor) async {
      GlassModalSheet.show<void>(
        context: tester.element(find.byType(Align)),
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
    }

    testWidgets('hands the same anchor to its builder across rebuilds',
        (tester) async {
      final seen = <GlassMorphAnchor>[];
      await tester.pumpWidget(
        _app(GlassMorphTrigger(builder: (context, anchor) {
          seen.add(anchor);
          return const SizedBox(width: 56, height: 56);
        })),
      );
      await tester.pump();

      expect(seen, isNotEmpty);
      expect(seen.every((a) => identical(a, seen.first)), isTrue);
    });

    testWidgets('paints nothing while presented, and is restored after',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      expect(triggerOpacity(tester), 1.0);

      await present(tester, anchor);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      // Toggled outright, never animated — a partial fade would pop the glass.
      expect(triggerOpacity(tester), 0.0);

      await tester.pumpAndSettle();
      expect(triggerOpacity(tester), 0.0, reason: 'still presented');

      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();
      expect(triggerOpacity(tester), 1.0);
    });

    testWidgets('keeps bouncing after the presented route is gone',
        (tester) async {
      // The whole point of the trigger owning a ticker: the route is torn down
      // as soon as the droplet lands, so a bounce driven from there would be
      // truncated mid-swing and the button would snap home.
      final anchor = await pumpTrigger(tester);
      final resting = tester.getTopLeft(find.byKey(triggerKey));

      await present(tester, anchor);
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(200, 60));
      await tester.pump();

      var routeGone = false;
      var maxOffsetAfterRouteGone = 0.0;
      for (var elapsed = 0; elapsed < 1200; elapsed += 16) {
        await tester.pump(const Duration(milliseconds: 16));
        if (find.byType(GlassSheetMorphPresenter).evaluate().isEmpty) {
          routeGone = true;
          final dy =
              (tester.getTopLeft(find.byKey(triggerKey)).dy - resting.dy).abs();
          if (dy > maxOffsetAfterRouteGone) maxOffsetAfterRouteGone = dy;
        }
      }

      expect(routeGone, isTrue, reason: 'route never popped');
      expect(maxOffsetAfterRouteGone, greaterThan(0.5),
          reason: 'trigger was not still bouncing once the route had gone');

      // ...and it eases back to exactly where it started.
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(triggerKey)).dy,
        moreOrLessEquals(resting.dy, epsilon: 0.5),
      );
    });

    testWidgets('does not rebuild the consumer subtree during the bounce',
        (tester) async {
      // The bounce repaints the trigger every frame; building the consumer's
      // widget inside the AnimatedBuilder callback would rebuild their whole
      // subtree at 60fps along with it.
      var builds = 0;
      late GlassMorphAnchor anchor;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassMorphTrigger(builder: (context, a) {
              anchor = a;
              builds++;
              return const SizedBox(key: triggerKey, width: 56, height: 56);
            }),
          ),
        ),
      );
      await tester.pump();

      await present(tester, anchor);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 60));
      await tester.pump();

      final before = builds;
      var frames = 0;
      for (var elapsed = 0; elapsed < 1200; elapsed += 16) {
        await tester.pump(const Duration(milliseconds: 16));
        frames++;
      }
      await tester.pumpAndSettle();

      // One rebuild when the bounce is handed over is expected; per-frame is
      // the regression.
      expect(builds - before, lessThanOrEqualTo(3),
          reason: 'consumer rebuilt ${builds - before} times over $frames '
              'frames — the trigger should be repainted, not rebuilt');
    });

    testWidgets('a fresh open cancels a bounce still in flight',
        (tester) async {
      // Tapping the button mid-bounce must not leave it stranded off-centre.
      final anchor = await pumpTrigger(tester);
      final resting = tester.getTopLeft(find.byKey(triggerKey));

      await present(tester, anchor);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 60));
      await tester.pump();
      // Far enough in that the route is gone and the bounce is running.
      for (var elapsed = 0; elapsed < 450; elapsed += 16) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await present(tester, anchor);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.getTopLeft(find.byKey(triggerKey)), resting);

      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();
    });

    testWidgets('a sheet presented WITHOUT a morph never shrinks on a swipe',
        (tester) async {
      // The boundary of this feature, and the reason the swipe-away transform
      // lives in the presenter rather than in the sheet's own metrics. iOS
      // hangs its interactive shrink off the zoom transition, not off the
      // detents — a plain sheet has no trigger to shrink toward, so it keeps
      // the slide-away it always had. Putting the scale in `_calculateMetrics`
      // silently changed the dismissal for every sheet in the package.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => GlassModalSheet.show<void>(
                context: context,
                builder: (_) => const Text('Sheet body'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final body = find.text('Sheet body');
      final restingWidth = tester.getRect(body).width;

      final drag = await tester.startGesture(
        tester.getCenter(find.bySemanticsLabel('Drag handle')),
      );
      await drag.moveBy(const Offset(0, 150));
      await tester.pump();

      expect(
        tester.getRect(body).width,
        closeTo(restingWidth, 0.01),
        reason: 'a sheet with no trigger to morph into slides away at full '
            'size, exactly as it did before the morph existed',
      );

      await drag.up();
      await tester.pumpAndSettle();
    });

    testWidgets('sideways does nothing until the dismiss drag is under way',
        (tester) async {
      // Above the threshold the sheet keeps its own jelly-follow stretch and
      // nothing else — a sideways wobble must not start sliding the card
      // around before the swipe has actually committed to going down.
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();

      final body = find.text('Sheet body');
      final resting = tester.getRect(body);

      // A few pixels below the detent: past zero travel, but short of the slop
      // that says the drag has begun.
      final nudge = await tester.startGesture(const Offset(200, 420));
      await nudge.moveBy(const Offset(0, 6));
      await tester.pump();
      await nudge.moveBy(const Offset(40, 0));
      await tester.pump();

      expect(
        tester.getRect(body).center.dx,
        closeTo(resting.center.dx, 0.01),
        reason: 'the card has not been pushed sideways yet',
      );

      await nudge.up();
      await tester.pumpAndSettle();

      // Committed to the downward drag: now the axis opens.
      final swipe = await tester.startGesture(const Offset(200, 420));
      await swipe.moveBy(const Offset(0, 60));
      await tester.pump();
      final opened = tester.getRect(body);
      expect(opened.width, lessThan(resting.width * 0.95));

      await swipe.moveBy(const Offset(70, 0));
      // The card chases the finger through the tracking spring rather than
      // copying it, so give the chase a few frames to move.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tester.getRect(body).center.dx,
        greaterThan(opened.center.dx),
        reason: 'and now it follows the finger',
      );

      await swipe.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'dragging back up above the threshold closes the sideways axis and springs home',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();

      final body = find.text('Sheet body');
      final resting = tester.getRect(body);

      // Committed to the downward drag: axis opens.
      final swipe = await tester.startGesture(const Offset(200, 420));
      await swipe.moveBy(const Offset(0, 60));
      await tester.pump();
      final opened = tester.getRect(body);
      expect(opened.width, lessThan(resting.width * 0.95));

      await swipe.moveBy(const Offset(70, 0));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tester.getRect(body).center.dx,
        greaterThan(opened.center.dx),
        reason: 'sheet follows finger sideways while falling',
      );

      // Drag back up above the lowest detent threshold without releasing finger.
      await swipe.moveBy(const Offset(0, -60));
      await tester.pump();

      // Pumping frames should animate return spring back to centre.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 25));
      }

      expect(
        tester.getRect(body).center.dx,
        closeTo(resting.center.dx, 1.0),
        reason: 'axis closed and card sprang back to centre',
      );

      await swipe.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a swipe can be pushed sideways, and springs back if released',
        (tester) async {
      // iOS lets a falling sheet be pushed around the screen, not just down.
      // The sideways axis is pure translation — it never feeds the shrink.
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();

      final body = find.text('Sheet body');
      final resting = tester.getRect(body);

      // Below the detent, but short of the dismiss threshold so the release
      // cancels rather than closing.
      final drag = await tester.startGesture(const Offset(200, 420));
      await drag.moveBy(const Offset(0, 60));
      await tester.pump();

      final falling = tester.getRect(body);
      expect(
        falling.width,
        lessThan(resting.width),
        reason: 'the downward travel shrinks it',
      );

      // Far enough that the card's edge passes its free slack and leans on
      // the screen-edge pin.
      await drag.moveBy(const Offset(200, 0));
      // One frame in, the chase spring has only just set off — the card
      // already moves, but visibly behind the finger. That trail is the
      // sideways weight.
      await tester.pump(const Duration(milliseconds: 16));
      final chasing = tester.getRect(body).center.dx - falling.center.dx;
      expect(chasing, greaterThan(0.0), reason: 'the chase starts at once');
      expect(
        chasing,
        lessThan(80.0),
        reason: 'but trails the finger — a card that tracked it exactly '
            'reads as weightless',
      );

      // Settled, the chase lands on the damped offset: the free slack plus
      // the few points of give the edge pin allows, well short of the finger.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      final swept = tester.getRect(body);
      final movedBy = swept.center.dx - falling.center.dx;
      expect(
        movedBy,
        greaterThan(chasing),
        reason: 'the card catches up once the finger stops',
      );
      expect(
        movedBy,
        lessThan(140.0),
        reason: 'but pinned at the screen edge, far short of the finger',
      );
      // Loose tolerance: the held sheet's own position creeps a little over
      // the settle window; a sweep that fed the shrink would move this ~10%+.
      expect(
        swept.width,
        closeTo(falling.width, falling.width * 0.02),
        reason: 'and the sweep leaves the shrink alone — scale is keyed to the '
            'vertical travel only',
      );

      await drag.up();
      await tester.pumpAndSettle();

      expect(
        find.byType(GlassSheetMorphPresenter),
        findsOneWidget,
        reason: 'released short of the threshold, so it did not dismiss',
      );
      expect(tester.getRect(body).center.dx, closeTo(resting.center.dx, 0.5));
      expect(tester.getRect(body).width, closeTo(resting.width, 0.5));
    });

    testWidgets('the swipe declares its scale to the premium renderer',
        (tester) async {
      // The renderer freezes its shader UVs under a uniform scale-down, for
      // the CupertinoSheet push-back — where the page being sampled shrinks
      // with the glass. A swipe is the opposite: the page behind holds still,
      // and a frozen transform strands the surface's rim and rounded corners
      // at the size the sheet had when the drag began.
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();

      // The sheet's LiquidStretch declares a scope of its own for the press
      // scale, and the glass resolves only the innermost — so the presenter's
      // declaration has to reach it through the stretch.
      bool selfScaled() => tester
          .widget<LiquidGlassSelfScaleScope>(
            find
                .descendant(
                  of: find.byType(GlassSheetMorphPresenter),
                  matching: find.byType(LiquidGlassSelfScaleScope),
                )
                .last,
          )
          .selfScaled;

      expect(selfScaled(), isFalse,
          reason: 'at rest the sheet is not scaling itself, so a push-back '
              'over it must still freeze');

      final drag = await tester.startGesture(const Offset(200, 420));
      await drag.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(selfScaled(), isTrue, reason: 'the shrink is under way');

      await drag.up();
      await tester.pumpAndSettle();
      expect(selfScaled(), isFalse, reason: 'and released, it is over');
    });

    testWidgets('the rendered mid-swipe frame is exactly the geometry\'s',
        (tester) async {
      // The release hands [SheetMorphGeometry.dismissedRect] to the morph as
      // the frame to catch, while what is on screen comes from the presenter's
      // own pair of Transforms. The two paths are written to agree; this pins
      // them to each other, because the moment they drift the droplet starts
      // life on a frame the sheet was never actually wearing.
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();

      // The sheet's one unified glass surface spans the card frame — the same
      // rect the geometry reasons about.
      final surface = find.descendant(
        of: find.byType(GlassSheetMorphPresenter),
        matching: find.byType(AdaptiveGlass),
      );
      expect(surface, findsOneWidget);
      final resting = tester.getRect(surface);
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final cardFraction = resting.height / screen.height;

      // The travel the presenter rendered with, recovered from the scale it
      // drew. The sheet's own drag mapping applies its resistance on the way
      // into the position, so no public value is bit-exact with the live
      // position the presenter reads — but scale → travel is invertible, and
      // every OTHER part of the frame (the fall, the pivot, the sideways
      // offset) is then predicted from that travel and must land exactly.
      double renderedTravel() {
        final s = tester.getRect(surface).width / resting.width;
        final damped = (1.0 - s) / SheetMorphGeometry.dismissScaleGain;
        const knee = 0.48;
        final tail = (1.0 - SheetMorphGeometry.minDismissScale) /
                SheetMorphGeometry.dismissScaleGain -
            knee;
        final raw = damped <= knee
            ? damped
            : knee + (damped - knee) * tail / (tail - (damped - knee));
        return raw * cardFraction;
      }

      const grab = Offset(200, 420);
      const fall = 90.0;
      final drag = await tester.startGesture(grab);
      await drag.moveBy(const Offset(0, fall));
      await tester.pump();

      Rect predicted(double horizontalOffset) {
        final travel = renderedTravel();
        return SheetMorphGeometry.dismissedRect(
          restingRect: resting,
          travel: travel,
          screenHeight: screen.height,
          horizontalOffset: horizontalOffset,
          // The presenter derives the anchor from the finger's live position
          // minus the raw fall; the finger is parked at grab + the drag.
          scaleAnchor: Offset(grab.dx, grab.dy + fall - travel * screen.height),
        );
      }

      void expectSameRect(Rect actual, Rect wanted, String why) {
        expect(actual.left, closeTo(wanted.left, 0.1), reason: why);
        expect(actual.top, closeTo(wanted.top, 0.1), reason: why);
        expect(actual.right, closeTo(wanted.right, 0.1), reason: why);
        expect(actual.bottom, closeTo(wanted.bottom, 0.1), reason: why);
      }

      expectSameRect(
        tester.getRect(surface),
        predicted(0.0),
        'straight down, the rendered frame and the geometry are one',
      );

      // And with the sideways axis in play: the raw finger offset is damped
      // through the same horizontalOffsetFor the chase spring is targeted
      // with. The spring's steady state IS that target, so once the chase
      // settles the rendered frame and the geometry agree exactly. The sweep
      // is kept under kTouchSlop so the sheet's own vertical recognizer is
      // not derailed by the sideways movement (a pre-existing arena quirk —
      // a derailed sheet quietly springs back up during the settle window,
      // and its position reads stale through the controller), and it stays
      // inside the card's free slack so the damped offset is the raw offset.
      const sweep = 12.0;
      await drag.moveBy(const Offset(sweep, 0));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      final damped = SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: sweep,
        cardRect: predicted(0.0),
        screenWidth: screen.width,
      );
      expect(damped, sweep, reason: 'sanity: the sweep is in the free region');
      // Looser tolerance than the fresh-frame assertion above: over the
      // settle window the held sheet's live position creeps while its layout
      // holds the last drag-set value, and the presenter's transform reads
      // the live one — a transient sub-3px divergence that the next pointer
      // move re-syncs. Structural drift would miss by far more.
      void expectNearRect(Rect actual, Rect wanted, String why) {
        expect(actual.left, closeTo(wanted.left, 5.0), reason: why);
        expect(actual.top, closeTo(wanted.top, 5.0), reason: why);
        expect(actual.right, closeTo(wanted.right, 5.0), reason: why);
        expect(actual.bottom, closeTo(wanted.bottom, 5.0), reason: why);
      }

      expectNearRect(
        tester.getRect(surface),
        predicted(damped),
        'pushed sideways, still the frame the release would freeze',
      );

      await drag.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a swipe-down dismissal still hands the trigger back',
        (tester) async {
      // Whether or not the closing morph gets to hand the trigger back
      // mid-flight, the presenter restores it as it is disposed. Without that
      // safety net the button would stay invisible for good.
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();
      expect(triggerOpacity(tester), 0.0);

      // Throw the sheet down from its handle zone.
      final drag = await tester.startGesture(const Offset(200, 420));
      await drag.moveBy(const Offset(0, 260));
      await tester.pump();
      await drag.moveBy(const Offset(0, 160));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(find.byType(GlassSheetMorphPresenter), findsNothing);
      expect(triggerOpacity(tester), 1.0);
    });

    testWidgets('survives its trigger being unmounted while presented',
        (tester) async {
      // The presenter restores the anchor from dispose as a safety net; that
      // must not touch a trigger that has already gone away.
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pumpAndSettle();

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('an anchor whose trigger has gone falls back to the slide',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      // Trigger unmounted — its rect can no longer be resolved.
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      await tester.pump();

      expect(
        () => GlassModalSheet.show<void>(
          context: tester.element(find.byType(SizedBox)),
          builder: (_) => const Text('Sheet body'),
          morphFrom: anchor,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('abrupt route removal triggers anchor restore for safety',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      await present(tester, anchor);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(triggerOpacity(tester), 0.0);

      final route = ModalRoute.of(
        tester.element(find.byType(GlassSheetMorphPresenter)),
      )!;
      Navigator.of(
        tester.element(find.byType(GlassSheetMorphPresenter)),
      ).removeRoute(route);
      await tester.pumpAndSettle();

      expect(triggerOpacity(tester), 1.0);
    });
  });

  group('GlassModalSheet.show morph arguments', () {
    testWidgets('rejects both an anchor and a rect', (tester) async {
      late GlassMorphAnchor anchor;
      await tester.pumpWidget(
        _app(GlassMorphTrigger(builder: (context, a) {
          anchor = a;
          return const SizedBox(width: 56, height: 56);
        })),
      );
      await tester.pump();
      final context = tester.element(find.byType(GlassMorphTrigger));

      expect(
        () => GlassModalSheet.show<void>(
          context: context,
          builder: (_) => const Text('Sheet'),
          morphFrom: anchor,
          morphFromRect: const Rect.fromLTWH(0, 0, 10, 10),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('without a trigger the slide transition is unchanged',
        (tester) async {
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      final context = tester.element(find.byType(SizedBox));

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SlideTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
    });

    testWidgets('falls back to the slide when blending is unavailable',
        (tester) async {
      // Headless test runs report ImageFilter.isShaderFilterSupported == false,
      // which is exactly the Skia/web path: the metaball neck cannot be drawn,
      // so the sheet must present with its ordinary slide rather than a
      // degraded morph.
      late GlassMorphAnchor anchor;
      await tester.pumpWidget(
        _app(GlassMorphTrigger(builder: (context, a) {
          anchor = a;
          return const SizedBox(width: 56, height: 56);
        })),
      );
      final context = tester.element(find.byType(Scaffold));

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SlideTransition), findsWidgets);
      expect(find.byType(GlassSheetMorphPresenter), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
    });

    testWidgets('an explicit rect takes the same fallback path',
        (tester) async {
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      final context = tester.element(find.byType(SizedBox));

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFromRect: const Rect.fromLTWH(172, 700, 56, 56),
        morphSpeed: MorphSpeed.fast,
      );
      await tester.pumpAndSettle();

      expect(find.text('Sheet body'), findsOneWidget);
    });
    testWidgets('minimal quality falls back even with blending forced',
        (tester) async {
      GlassModalSheet.debugMorphSupportsBlending = true;
      addTearDown(() => GlassModalSheet.debugMorphSupportsBlending = null);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      final context = tester.element(find.byType(SizedBox));

      GlassModalSheet.show<void>(
        context: context,
        quality: GlassQuality.minimal,
        builder: (_) => const Text('Sheet body'),
        morphFromRect: const Rect.fromLTWH(172, 700, 56, 56),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSheetMorphPresenter), findsNothing);
      expect(find.byType(SlideTransition), findsWidgets);
    });

    testWidgets('platformViewBackdrop falls back even with blending forced',
        (tester) async {
      GlassModalSheet.debugMorphSupportsBlending = true;
      addTearDown(() => GlassModalSheet.debugMorphSupportsBlending = null);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      final context = tester.element(find.byType(SizedBox));

      GlassModalSheet.show<void>(
        context: context,
        platformViewBackdrop: true,
        builder: (_) => const Text('Sheet body'),
        morphFromRect: const Rect.fromLTWH(172, 700, 56, 56),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSheetMorphPresenter), findsNothing);
    });
  });

  group('GlassModalSheet.show with the morph route', () {
    setUp(() => GlassModalSheet.debugMorphSupportsBlending = true);
    tearDown(() => GlassModalSheet.debugMorphSupportsBlending = null);

    /// Pumps an app whose body is a 56pt trigger wrapped in a
    /// [GlassMorphTrigger], and hands back its anchor.
    Future<GlassMorphAnchor> pumpTrigger(WidgetTester tester) async {
      late GlassMorphAnchor anchor;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassMorphTrigger(builder: (context, a) {
              anchor = a;
              return const SizedBox(
                key: Key('trigger-content'),
                width: 56,
                height: 56,
              );
            }),
          ),
        ),
      );
      return anchor;
    }

    /// The context to present from — the trigger's own subtree is fine.
    BuildContext contextOf(WidgetTester tester) =>
        tester.element(find.byType(Align));

    /// Whether the trigger is currently painting. The anchor is opaque, so the
    /// rendered opacity is what a consumer would see.
    bool triggerPainted(WidgetTester tester) =>
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.byKey(const Key('trigger-content')),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity >
        0.0;

    testWidgets('presents through the morph instead of the slide',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      final context = contextOf(tester);

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(GlassSheetMorphPresenter), findsOneWidget);
      // The slide is the thing being replaced, so the route must not have
      // wrapped the page in one.
      expect(
        find.ancestor(
          of: find.byType(GlassSheetMorphPresenter),
          matching: find.byType(SlideTransition),
        ),
        findsNothing,
      );

      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
    });

    testWidgets('empties the trigger for the whole morph, then hands it back',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      final context = contextOf(tester);

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Emptied before the first morph frame paints, so the real button and
      // the anchor blob standing in for it are never both on screen.
      expect(triggerPainted(tester), isFalse);

      await tester.pumpAndSettle();
      expect(triggerPainted(tester), isFalse, reason: 'still presented');

      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();

      // Handed back once the droplet has been caught.
      expect(triggerPainted(tester), isTrue);
    });

    testWidgets('an explicit rect blooms instead of duplicating the trigger',
        (tester) async {
      // With no anchor the trigger stays painted, so drawing the anchor blob
      // over it would read as two buttons. It is suppressed and the droplet
      // blooms from the rect's centre instead.
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      final context = tester.element(find.byType(SizedBox));

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFromRect: const Rect.fromLTWH(172, 700, 56, 56),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final presenter = tester.widget<GlassSheetMorphPresenter>(
        find.byType(GlassSheetMorphPresenter),
      );
      expect(presenter.anchor, isNull);
      // One blob, not two: the anchor blob is the one that would duplicate.
      // Scoped to the droplet's blend group so the sheet's own glass — mounted
      // underneath for the whole morph — isn't counted.
      expect(
        find.descendant(
          of: find.byType(LiquidGlassBlendGroup),
          matching: find.byType(AdaptiveGlass),
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
    });

    testWidgets('an anchored morph draws both blobs so the neck can form',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      final context = contextOf(tester);

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Anchor blob + travelling droplet — the metaball bridges exactly these.
      expect(
        find.descendant(
          of: find.byType(LiquidGlassBlendGroup),
          matching: find.byType(AdaptiveGlass),
        ),
        findsNWidgets(2),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('hides the droplet once the trigger has caught it',
        (tester) async {
      // The droplet and the restored trigger must never be on screen together
      // — that is the duplicated-button artifact the anchor exists to avoid,
      // and it reappears at the tail of the close if the overlay isn't hidden
      // at the handoff latch. GlassMenu gates its overlay at the same point.
      final anchor = await pumpTrigger(tester);
      final context = contextOf(tester);

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(200, 60));
      await tester.pump();

      // Step through the close and assert the invariant on every frame.
      var sawBothHidden = false;
      for (var elapsed = 0; elapsed < 380; elapsed += 16) {
        await tester.pump(const Duration(milliseconds: 16));
        if (find.byType(GlassSheetMorphPresenter).evaluate().isEmpty) break;

        final dropletOpacity = tester
            .widgetList<Opacity>(
              find.ancestor(
                of: find.byType(AdaptiveLiquidGlassLayer),
                matching: find.byType(Opacity),
              ),
            )
            .first
            .opacity;

        if (triggerPainted(tester)) {
          // Trigger is back — the droplet must be gone.
          expect(dropletOpacity, 0.0,
              reason: 'droplet still painted after the trigger returned');
          sawBothHidden = true;
        }
      }

      expect(sawBothHidden, isTrue, reason: 'never observed the handoff');
      await tester.pumpAndSettle();
    });

    testWidgets('a barrier tap morphs back and then pops the route',
        (tester) async {
      final anchor = await pumpTrigger(tester);
      final context = contextOf(tester);

      GlassModalSheet.show<void>(
        context: context,
        builder: (_) => const Text('Sheet body'),
        morphFrom: anchor,
      );
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);

      // Tap well above the half detent — that is the dismiss barrier.
      await tester.tapAt(const Offset(200, 60));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Still mounted: the route stays up for the whole closing morph.
      expect(find.byType(GlassSheetMorphPresenter), findsOneWidget);
      // The real sheet is handed back to the blob; Visibility.visible is false
      // while the droplet returns to the trigger.
      expect(
        tester.widget<Visibility>(find.byType(Visibility).first).visible,
        isFalse,
      );

      await tester.pumpAndSettle();
      expect(find.byType(GlassSheetMorphPresenter), findsNothing);
      expect(find.text('Sheet body'), findsNothing);
    });

    testWidgets('every speed profile keeps the page up for its morph',
        (tester) async {
      // Each must outlast its spring's full settle (968 / 696 / 544 / 352 ms),
      // not just the moment the droplet is caught — the trigger's closing
      // bounce is driven by this route and snaps if it unmounts mid-swing.
      // Sized to the droplet's trip home (408 / 304 / 240 / 160 ms), not the
      // spring's full settle — the barrier must not outlive the morph and
      // leave the restored trigger dead to the touch. The bounce's tail runs
      // on GlassMorphTrigger's own ticker afterwards.
      const expected = <MorphSpeed, int>{
        MorphSpeed.slow: 480,
        MorphSpeed.normal: 380,
        MorphSpeed.fast: 300,
        MorphSpeed.instant: 210,
      };

      for (final entry in expected.entries) {
        final anchor = await pumpTrigger(tester);
        final context = contextOf(tester);

        GlassModalSheet.show<void>(
          context: context,
          builder: (_) => const Text('Sheet body'),
          morphFrom: anchor,
          morphSpeed: entry.key,
        );
        await tester.pump();

        final route = ModalRoute.of(
          tester.element(find.byType(GlassSheetMorphPresenter)),
        )!;
        expect(
          route.transitionDuration,
          Duration(milliseconds: entry.value),
          reason: 'for ${entry.key}',
        );

        await tester.pumpAndSettle();
        Navigator.of(
          tester.element(find.byType(GlassSheetMorphPresenter)),
        ).pop();
        await tester.pumpAndSettle();
      }
    });
  });
}
