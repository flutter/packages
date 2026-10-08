import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Selection stability for [GlassSegmentedControl.scrollable]:
///  1. the initial selection mounts scrolled into view, with no residual
///     indicator animation (no slide-in from the track edge),
///  2. a list-length change keeps the indicator mounted through the
///     remeasure and lands it with no travel,
///  3. segments with a surviving identity keep their elements across list
///     changes instead of remounting,
///  4. [VelocitySpringBuilder.teleportEpoch] snaps discontinuous values.
void main() {
  Widget harness(Widget child) => MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 300, child: child)),
        ),
      );

  List<GlassSegment> segments(int n, {String prefix = 'S'}) =>
      [for (var i = 0; i < n; i++) GlassSegment(label: '$prefix$i')];

  testWidgets('initial selection is in view with no residual animation',
      (tester) async {
    final ctl = ScrollController();
    addTearDown(ctl.dispose);
    await tester.pumpWidget(harness(GlassSegmentedControl.scrollable(
      segments: segments(30),
      selectedIndex: 20,
      onSegmentSelected: (_) {},
      scrollController: ctl,
    )));
    // Frame 2: post-frame measurement has run and snapped everything.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    expect(ctl.offset, greaterThan(0),
        reason: 'selection 20 of 30 cannot be visible at offset 0');
    expect(find.text('S20').hitTestable(), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0,
        reason: 'nothing may still be animating after the mount snap');
  });

  testWidgets('length change keeps the indicator and lands without travel',
      (tester) async {
    final ctl = ScrollController();
    addTearDown(ctl.dispose);
    // regridDuration zero: this test covers the SNAP path; the morph path
    // has its own tests below.
    Widget build(int n) => harness(GlassSegmentedControl.scrollable(
          segments: segments(n),
          selectedIndex: 5,
          onSegmentSelected: (_) {},
          scrollController: ctl,
          regridDuration: Duration.zero,
        ));
    await tester.pumpWidget(build(10));
    await tester.pumpAndSettle();

    bool indicatorShown() => find
        .byWidgetPredicate(
            (w) => w.runtimeType.toString() == 'AnimatedGlassIndicator')
        .evaluate()
        .isNotEmpty;
    expect(indicatorShown(), isTrue);

    await tester.pumpWidget(build(20));
    // The remeasure gap: indicator must survive it.
    expect(indicatorShown(), isTrue,
        reason: 'indicator blinked out during the remeasure gap');
    await tester.pump();
    expect(indicatorShown(), isTrue);
    await tester.pump(const Duration(milliseconds: 32));
    expect(tester.binding.transientCallbackCount, 0,
        reason: 'the indicator must snap to the new geometry, not travel');
  });

  testWidgets('surviving identities keep their elements across list changes',
      (tester) async {
    Widget build(List<String> labels) => harness(
          GlassSegmentedControl.scrollable(
            segments: [for (final l in labels) GlassSegment(label: l)],
            selectedIndex: 0,
            onSegmentSelected: (_) {},
          ),
        );
    await tester.pumpWidget(build(['A', 'B', 'C']));
    await tester.pumpAndSettle();
    final before = tester.element(find.text('B'));
    await tester.pumpWidget(build(['A0', 'A', 'B', 'C', 'D']));
    await tester.pumpAndSettle();
    expect(identical(before, tester.element(find.text('B'))), isTrue,
        reason: "segment 'B' survived the change and must keep its element");
  });

  testWidgets('center alignment seats the selection mid-viewport',
      (tester) async {
    await tester.pumpWidget(harness(GlassSegmentedControl.scrollable(
      segments: segments(30),
      selectedIndex: 15,
      onSegmentSelected: (_) {},
      selectionAlignment: SegmentSelectionAlignment.center,
    )));
    await tester.pumpAndSettle();
    final viewport = tester.getRect(find.byType(GlassSegmentedControl));
    final cell = tester.getRect(find.text('S15'));
    expect((cell.center.dx - viewport.center.dx).abs(), lessThan(2.0),
        reason: 'selection must sit at the viewport center');
  });

  testWidgets(
      're-grid morph: anchored selection, entrants grow, leavers '
      'shrink out', (tester) async {
    var selected = 4;
    List<GlassSegment> coarse() =>
        [for (var i = 0; i < 8; i++) GlassSegment(label: 'T$i')];
    List<GlassSegment> fine() => [
          for (var i = 0; i < 8; i++) ...[
            GlassSegment(label: 'T$i'),
            if (i < 7) GlassSegment(label: 'N$i'),
          ],
        ];
    Widget build(List<GlassSegment> segs) =>
        harness(GlassSegmentedControl.scrollable(
          segments: segs,
          selectedIndex: segs.indexWhere((t) => t.label == 'T$selected'),
          onSegmentSelected: (_) {},
          selectionAlignment: SegmentSelectionAlignment.center,
          // The morph is opt-in (the default snaps), and this test is
          // about the morph — so it has to ask for it.
          regridDuration: const Duration(milliseconds: 180),
        ));
    await tester.pumpWidget(build(coarse()));
    await tester.pumpAndSettle();
    final anchor = tester.getTopLeft(find.text('T$selected')).dx;

    await tester.pumpWidget(build(fine()));
    await tester.pump(const Duration(milliseconds: 90)); // mid-morph
    expect(find.text('N3'), findsOneWidget,
        reason: 'entrants must exist mid-morph');
    expect((tester.getTopLeft(find.text('T$selected')).dx - anchor).abs(),
        lessThan(3.0),
        reason: 'the selection is anchored through the morph');
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);

    // Coarsen again: leavers must remain visible mid-morph, gone after.
    await tester.pumpWidget(build(coarse()));
    await tester.pump(const Duration(milliseconds: 90));
    expect(find.text('N3'), findsOneWidget,
        reason: 'leavers shrink out — still present mid-morph');
    await tester.pumpAndSettle();
    expect(find.text('N3'), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('pill position hands off seamlessly at morph end',
      (tester) async {
    var n = 8;
    List<GlassSegment> segs() => [
          for (var i = 0; i < n; i++) ...[
            GlassSegment(label: 'T$i'),
            if (n > 8 && i < 7) GlassSegment(label: 'N$i'),
          ],
        ];
    Widget build() => harness(GlassSegmentedControl.scrollable(
          segments: segs(),
          selectedIndex: segs().indexWhere((t) => t.label == 'T4'),
          onSegmentSelected: (_) {},
          selectionAlignment: SegmentSelectionAlignment.center,
          // Opt in: without a morph there is no handoff to test, and this
          // would pass vacuously.
          regridDuration: const Duration(milliseconds: 180),
        ));
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    double? pillLeft() {
      final els = find
          .byWidgetPredicate(
              (w) => w.runtimeType.toString() == 'AnimatedGlassIndicator')
          .evaluate();
      if (els.isEmpty) return null;
      return (els.first.widget as dynamic).exactOffset as double?;
    }

    n = 15;
    await tester.pumpWidget(build());
    // Pump beyond the 180ms morph in small steps, across the finish
    // handoff: the rendered pill offset must never move visibly.
    double? prev = pillLeft();
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final now = pillLeft();
      if (prev != null && now != null) {
        expect((now - prev).abs(), lessThan(1.5),
            reason: 'pill jumped between frames (frame $i)');
      }
      prev = now;
    }
    await tester.pumpAndSettle();
  });

  testWidgets(
      'dragBehavior.scroll: pill drags scroll the list, tap-only '
      'selection', (tester) async {
    int? tapped;
    final ctl = ScrollController();
    addTearDown(ctl.dispose);
    await tester.pumpWidget(harness(GlassSegmentedControl.scrollable(
      segments: segments(30),
      selectedIndex: 15,
      onSegmentSelected: (i) => tapped = i,
      selectionAlignment: SegmentSelectionAlignment.center,
      dragBehavior: SegmentDragBehavior.scroll,
      scrollController: ctl,
    )));
    await tester.pumpAndSettle();
    final before = ctl.offset;
    await tester.drag(find.text('S15'), const Offset(-120, 0));
    await tester.pumpAndSettle();
    expect(tapped, isNull, reason: 'a drag must not change the selection');
    expect((ctl.offset - before).abs(), greaterThan(60),
        reason: 'a drag starting on the pill must scroll the list');
  });

  testWidgets('default dragBehavior keeps the indicator drag', (tester) async {
    int? dragged;
    final ctl = ScrollController();
    addTearDown(ctl.dispose);
    await tester.pumpWidget(harness(GlassSegmentedControl.scrollable(
      segments: segments(30),
      selectedIndex: 15,
      onSegmentSelected: (i) => dragged = i,
      selectionAlignment: SegmentSelectionAlignment.center,
      scrollController: ctl,
    )));
    await tester.pumpAndSettle();
    final before = ctl.offset;
    await tester.timedDrag(find.text('S15'), const Offset(-120, 0),
        const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(dragged, isNotNull,
        reason: 'dragging the pill selects a neighboring segment');
    expect((ctl.offset - before).abs(), lessThan(1),
        reason: 'an indicator drag must not scroll the list');
  });

  testWidgets('center tap: pill beat first, centering glide second',
      (tester) async {
    var selected = 15;
    final ctl = ScrollController();
    addTearDown(ctl.dispose);
    late StateSetter setSel;
    await tester.pumpWidget(harness(StatefulBuilder(
      builder: (context, setState) {
        setSel = setState;
        return GlassSegmentedControl.scrollable(
          segments: segments(30),
          selectedIndex: selected,
          onSegmentSelected: (i) => setState(() => selected = i),
          selectionAlignment: SegmentSelectionAlignment.center,
          dragBehavior: SegmentDragBehavior.scroll,
          scrollController: ctl,
        );
      },
    )));
    await tester.pumpAndSettle();
    final before = ctl.offset;

    await tester.tap(find.text('S16'), warnIfMissed: true);
    // Beat one: the pill travels, the scroll HOLDS.
    await tester.pump(const Duration(milliseconds: 120));
    expect(selected, 16);
    expect((ctl.offset - before).abs(), lessThan(1),
        reason: 'the scroll must hold while the pill travels');
    // Beat two: the centering glide, after the delay.
    await tester.pumpAndSettle();
    final viewport = tester.getRect(find.byType(GlassSegmentedControl));
    final cell = tester.getRect(find.text('S16'));
    expect((cell.center.dx - viewport.center.dx).abs(), lessThan(2.0),
        reason: 'the choice ends centered');
    setSel(() {}); // silence unused warning paths
  });

  testWidgets('teleportEpoch snaps; unchanged epoch animates', (tester) async {
    double seen = -1;
    Widget build(double value, int epoch) => MaterialApp(
          home: VelocitySpringBuilder(
            value: value,
            teleportEpoch: epoch,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased:
                GlassSpring.snappy(duration: const Duration(milliseconds: 350)),
            active: false,
            builder: (context, v, _, __) {
              seen = v;
              return const SizedBox();
            },
          ),
        );
    await tester.pumpWidget(build(0, 0));
    expect(seen, 0);
    // Epoch bump: lands instantly, nothing left animating.
    await tester.pumpWidget(build(100, 1));
    await tester.pump();
    expect(seen, 100);
    expect(tester.binding.transientCallbackCount, 0);
    // Same epoch: animates through intermediate values.
    await tester.pumpWidget(build(200, 1));
    await tester.pump(const Duration(milliseconds: 40));
    expect(seen, greaterThan(100));
    expect(seen, lessThan(200), reason: 'must travel, not snap');
    await tester.pumpAndSettle();
    expect(seen, moreOrLessEquals(200, epsilon: 0.5));
  });
}
