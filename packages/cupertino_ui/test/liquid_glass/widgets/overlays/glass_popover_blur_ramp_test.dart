import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Tests for [GlassPopover]'s backdrop-blur ramp (see
/// `GlassPopover.blurRampDuration`): the blur must ease in from 0 → the
/// configured target over the opening morph, and must be applied at full
/// strength immediately when the ramp is disabled or reduced-motion is active.
///
/// The blur is observed through the overlay's [LiquidGlassLayer], whose
/// `settings.blur` is exactly the value the [BackdropFilter] rasterises each
/// frame. A fixed `popoverHeight` is used throughout so the morph starts on the
/// first frame (no intrinsic-height measurement pass) and the ramp is
/// deterministic.
void main() {
  const target = 24.0;

  Widget buildApp({
    Duration blurRampDuration = const Duration(milliseconds: 260),
    bool disableAnimations = false,
  }) {
    Widget popover = GlassPopover(
      popoverHeight: 160,
      popoverWidth: 200,
      settings: const LiquidGlassSettings(blur: target),
      blurRampDuration: blurRampDuration,
      trigger: const SizedBox(width: 50, height: 50, child: Text('Open')),
      contentBuilder: (context, close) =>
          const Padding(padding: EdgeInsets.all(16), child: Text('Body')),
    );
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(disableAnimations: disableAnimations),
              child: popover,
            ),
          ),
        ),
      ),
    );
  }

  /// The blur the overlay's glass layer is currently rasterising, or null when
  /// no layer is mounted (popover closed).
  double? layerBlur(WidgetTester tester) {
    final layers =
        tester.widgetList<LiquidGlassLayer>(find.byType(LiquidGlassLayer));
    if (layers.isEmpty) return null;
    return layers.first.settings.blur;
  }

  testWidgets('blur ramps in from ~0 to the target over the morph',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Frame 0 of the open: overlay is mounted, ramp has just started at 0 — the
    // expensive full-strength blur must NOT be paid yet.
    await tester.tap(find.text('Open'));
    await tester.pump();
    final atStart = layerBlur(tester);
    expect(atStart, isNotNull, reason: 'glass layer should be mounted on open');
    expect(atStart, lessThan(target * 0.5),
        reason: 'blur must start ramping from ~0, not full strength');

    // Part-way through the ramp it has grown but not yet reached full.
    await tester.pump(const Duration(milliseconds: 120));
    final mid = layerBlur(tester)!;
    expect(mid, greaterThan(atStart!));
    expect(mid, lessThanOrEqualTo(target));

    // Past the ramp duration it sits at exactly the configured blur.
    await tester.pump(const Duration(milliseconds: 300));
    expect(layerBlur(tester), closeTo(target, 0.001));

    await tester.pumpAndSettle();
  });

  testWidgets('blurRampDuration: Duration.zero applies full blur immediately',
      (tester) async {
    await tester.pumpWidget(buildApp(blurRampDuration: Duration.zero));

    await tester.tap(find.text('Open'));
    await tester.pump();

    // No ramp: the very first painted frame already carries the full blur.
    expect(layerBlur(tester), closeTo(target, 0.001));

    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion skips the ramp (full blur immediately)',
      (tester) async {
    await tester.pumpWidget(buildApp(disableAnimations: true));

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(
      layerBlur(tester),
      closeTo(target, 0.001),
      reason: 'reduce-motion must not add a blur ramp',
    );

    await tester.pumpAndSettle();
  });

  test('GlassPopover exposes the documented ramp defaults', () {
    final popover = GlassPopover(
      trigger: const SizedBox(width: 40, height: 40),
      contentBuilder: (context, close) => const Text('x'),
    );
    expect(popover.blurRampDuration, const Duration(milliseconds: 260));
    expect(popover.blurRampCurve, Curves.easeOut);
  });

  testWidgets(
      'blurRampDuration change mid-open applies without crash and settles',
      (tester) async {
    // Start with a long ramp so we can catch it mid-animation.
    await tester.pumpWidget(
      buildApp(blurRampDuration: const Duration(milliseconds: 600)),
    );

    await tester.tap(find.text('Open'));
    await tester.pump(); // ramp starts

    // Confirm the blur is ramping (not yet full).
    expect(layerBlur(tester)!, lessThan(target * 0.5));

    // Rebuild with a much shorter duration while the ramp is still running.
    // didUpdateWidget must not throw, and the widget must remain mounted.
    await tester.pumpWidget(
      buildApp(blurRampDuration: const Duration(milliseconds: 50)),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(GlassPopover), findsOneWidget);

    // After settling the blur must reach the full configured target.
    await tester.pumpAndSettle();
    expect(layerBlur(tester), closeTo(target, 0.01));
  });
}
