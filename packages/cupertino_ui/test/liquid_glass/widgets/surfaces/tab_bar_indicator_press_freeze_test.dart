// Regression tests for the "bottom bar freezes over an iOS PlatformView" fix.
//
// The freeze is iOS clip-chain reconstruction: a clip layer added/removed over a
// PlatformView mid-gesture makes the engine cancel the touch. Three parts of the
// fix are covered here (the full end-to-end freeze needs an on-device
// PlatformView, but each mechanism is checked deterministically):
//
//  1. clip-mount — the indicator's `innerBlur` frost (a ClipRRect+BackdropFilter)
//     stays MOUNTED across the morph instead of unmounting, which is the clip
//     add/remove that cancels the gesture. (Primary fix.)
//  2. recovery — if a terminal callback is dropped, the mixin self-heals:
//     disposes the wedged recognizer (gestureEpoch key bump) and selects a tab.
//  3. disposal-safety — a terminal callback firing while the gesture subtree is
//     torn down during a rebuild must not setState() during the locked phase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_drag_gesture_mixin.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: LiquidGlassWidgets.wrap(child: child)),
    );

Widget _box(Widget child) => SizedBox(height: 140, child: child);

GlassTab _tab(String label) =>
    GlassTab(label: label, icon: const Icon(Icons.circle));

Widget _bar(GlassQuality quality) => GlassTabBar.searchable(
      tabs: [_tab('Home'), _tab('Browse'), _tab('Me')],
      selectedIndex: 0,
      onTabSelected: (_) {},
      quality: quality,
      innerBlur: 2.25,
      platformViewBackdrop: true,
      magnification: 1.0,
      searchConfig:
          GlassSearchBarConfig(hintText: 'Search', onSearchToggle: (_) {}),
    );

// Minimal host for [TabDragGestureMixin] so the recovery path can be driven
// directly, without needing a real PlatformView to drop a callback.
class _RecoverHarness extends StatefulWidget {
  const _RecoverHarness({required this.onChange, required this.onState});
  final ValueChanged<int> onChange;
  final void Function(_RecoverHarnessState) onState;
  @override
  State<_RecoverHarness> createState() => _RecoverHarnessState();
}

class _RecoverHarnessState extends State<_RecoverHarness>
    with TabDragGestureMixin<_RecoverHarness> {
  @override
  int get tabCount => 3;
  @override
  int get tabIndex => 0;
  @override
  bool get isPlatformViewBackdrop => true;
  @override
  void notifyTabChanged(int index) => widget.onChange(index);

  @override
  void initState() {
    super.initState();
    widget.onState(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 300, height: 60);
}

void main() {
  testWidgets(
      'innerBlur frost stays mounted while the pill morphs (clip-mount fix)',
      (tester) async {
    // `backgroundOpacity` derives from `thickness`: 1.0 at rest (thickness 0),
    // 0 once thickness >= 0.15 (mid-morph). The fix keeps the frost's
    // ClipRRect+BackdropFilter MOUNTED across the morph (fading the sigma)
    // rather than unmounting it — the unmount is a clip add/remove over a
    // PlatformView that cancels the gesture (the freeze). Isolate the frost by
    // diffing innerBlur on vs off at the SAME (fully morphing) state.
    Future<int> backdropsAtMorph(double innerBlur) async {
      await tester.pumpWidget(_wrap(_box(Stack(children: [
        AnimatedGlassIndicator(
          velocity: 0,
          itemCount: 3,
          alignment: Alignment.centerLeft,
          thickness: 1.0, // -> backgroundOpacity == 0 (fully morphing)
          quality: GlassQuality.standard,
          indicatorColor: const Color(0xFFFFFFFF),
          isBackgroundIndicator: false,
          borderRadius: 20,
          innerBlur: innerBlur,
        ),
      ]))));
      await tester.pump();
      return find.byType(BackdropFilter).evaluate().length;
    }

    final withFrost = await backdropsAtMorph(4);
    final withoutFrost = await backdropsAtMorph(0);
    expect(
      withFrost,
      greaterThan(withoutFrost),
      reason:
          'the innerBlur frost BackdropFilter must remain mounted while the '
          'pill morphs; re-gating it on backgroundOpacity would drop the clip '
          'and re-introduce the PlatformView gesture-cancel freeze',
    );
  });

  testWidgets(
      'recoverIfGestureStuck disposes the wedged recognizer and selects a tab '
      'when a terminal callback is dropped', (tester) async {
    int? changedTo;
    late _RecoverHarnessState st;
    await tester.pumpWidget(_wrap(_box(
      _RecoverHarness(
        onChange: (i) => changedTo = i,
        onState: (s) => st = s,
      ),
    )));
    await tester.pump();

    final box = find.byType(_RecoverHarness);
    // A gesture began (recognizer live) but its terminal callback is dropped —
    // onBarPointerDown with no matching end/cancel.
    st.onBarPointerDown(tester.getCenter(box));
    final epochBefore = st.gestureEpoch;

    // The raw Listener calls this on the real pointer-up; with the terminal
    // callback gone, it must self-heal on the next frame.
    st.recoverIfGestureStuck(tester.getCenter(box));
    await tester.pump();

    expect(st.gestureEpoch, epochBefore + 1,
        reason: 'wedged recognizer disposed via a gestureEpoch key bump');
    expect(changedTo, isNotNull,
        reason: 'recovery selects the tab under the lift point');
  });

  testWidgets(
      'indicator drag recognizer disposed mid-gesture cancels without throwing',
      (tester) async {
    await tester.pumpWidget(_wrap(_box(_bar(GlassQuality.standard))));
    await tester.pump();

    // Begin a drag on the selected indicator (tab 0) so the recognizer is live.
    final center = tester.getCenter(find.text('Home').first);
    final gesture = await tester.startGesture(center);
    await tester.pump();
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump();

    // Dispose the bar's gesture subtree mid-drag — exactly what the non-premium
    // press rebuild does on-device. The recognizer is torn down while active.
    await tester.pumpWidget(_wrap(_box(const SizedBox.shrink())));
    await tester.pump();
    await gesture.up();

    expect(
      tester.takeException(),
      isNull,
      reason: 'a drag recognizer disposed mid-gesture must cancel silently, '
          'not setState() during the locked teardown',
    );
  });

  testWidgets(
      'tabIsDragging stays true throughout drag — indicator never collapses '
      'when dragging over the selected tab', (tester) async {
    // Regression guard for the thickness-spring gate fix (0.21.1).
    //
    // Before fix — gate was:
    //   tabIsDown || (alignment.x - targetAlignment).abs() > 0.05
    // When dragging back over the selected tab, alignment ≈ targetAlignment,
    // so the gate returned false → spring targeted 0.0 → glass indicator
    // morphed back to the resting pill mid-gesture.
    //
    // After fix — gate is:
    //   tabIsDown || tabIsDragging || (alignment.x - targetAlignment).abs() > 0.05
    // tabIsDragging stays true for the full gesture, keeping the spring at 1.0.
    late _RecoverHarnessState harness;
    await tester.pumpWidget(_wrap(
      _RecoverHarness(onChange: (_) {}, onState: (s) => harness = s),
    ));

    // Drag start — tabIsDragging must flip true.
    harness.onBarDragStart(
      DragStartDetails(globalPosition: Offset.zero, localPosition: Offset.zero),
    );
    await tester.pump();
    expect(harness.tabIsDragging, isTrue,
        reason: 'tabIsDragging must be true at drag start');

    // Mid-drag moving right (away from selected tab).
    harness.onBarDragUpdate(DragUpdateDetails(
      globalPosition: const Offset(40, 0),
      localPosition: const Offset(40, 0),
      delta: const Offset(40, 0),
      primaryDelta: 40.0,
    ));
    await tester.pump();
    expect(harness.tabIsDragging, isTrue,
        reason: 'tabIsDragging must stay true while dragging away');

    // Drag back toward the selected tab — the collapse trigger before the fix.
    harness.onBarDragUpdate(DragUpdateDetails(
      globalPosition: const Offset(2, 0),
      localPosition: const Offset(2, 0),
      delta: const Offset(-38, 0),
      primaryDelta: -38.0,
    ));
    await tester.pump();
    expect(harness.tabIsDragging, isTrue,
        reason: 'tabIsDragging must stay true when dragging back over the '
            'selected tab — this is the regression this test guards');

    // Drag end — only now should tabIsDragging clear.
    harness.onBarDragEnd(DragEndDetails(primaryVelocity: 0));
    await tester.pump();
    expect(harness.tabIsDragging, isFalse,
        reason: 'tabIsDragging must be false only after drag ends');
  });
}
