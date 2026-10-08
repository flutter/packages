// Pure unit tests for SearchableBottomBarController.
//
// No testWidgets, no widget tree — pure Dart test() calls.
// This is the coverage gain point: the layout math was previously inside
// LayoutBuilder (unreachable by widget tests) and is now directly testable.
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  late SearchableBottomBarController ctrl;

  setUp(() {
    ctrl = SearchableBottomBarController();
  });

  tearDown(() {
    ctrl.dispose();
  });

  // ── Initial state ──────────────────────────────────────────────────────────

  group('initial state', () {
    test('searchFocused starts false', () {
      expect(ctrl.searchFocused, isFalse);
    });

    test('pillsInitialized starts false', () {
      expect(ctrl.pillsInitialized, isFalse);
    });

    test('pillsInitScheduled starts false', () {
      expect(ctrl.pillsInitScheduled, isFalse);
    });
  });

  // ── onFocusChanged ─────────────────────────────────────────────────────────

  group('onFocusChanged', () {
    test('false→true sets searchFocused', () {
      ctrl.onFocusChanged(true);
      expect(ctrl.searchFocused, isTrue);
    });

    test('true→false clears searchFocused', () {
      ctrl.onFocusChanged(true);
      ctrl.onFocusChanged(false);
      expect(ctrl.searchFocused, isFalse);
    });

    test('notifies listeners on change', () {
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.onFocusChanged(true);
      expect(calls, 1);
    });

    test('idempotent — same value does not notify', () {
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.onFocusChanged(false); // already false
      expect(calls, 0);
    });

    test('true→true does not notify', () {
      ctrl.onFocusChanged(true);
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.onFocusChanged(true); // already true
      expect(calls, 0);
    });
  });

  // ── onSearchActiveChanged ──────────────────────────────────────────────────

  group('onSearchActiveChanged', () {
    test('deactivating while focused: clears searchFocused', () {
      ctrl.onFocusChanged(true);
      ctrl.onSearchActiveChanged(wasActive: true, isActive: false);
      expect(ctrl.searchFocused, isFalse);
    });

    test('deactivating while focused: notifies listeners', () {
      ctrl.onFocusChanged(true);
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.onSearchActiveChanged(wasActive: true, isActive: false);
      expect(calls, 1);
    });

    test('deactivating while NOT focused: no change', () {
      // _searchFocused is false by default
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.onSearchActiveChanged(wasActive: true, isActive: false);
      expect(ctrl.searchFocused, isFalse);
      expect(calls, 0);
    });

    test('activating: no focus state change', () {
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.onSearchActiveChanged(wasActive: false, isActive: true);
      expect(ctrl.searchFocused, isFalse);
      expect(calls, 0);
    });
  });

  // ── initializePills / markInitScheduled ───────────────────────────────────

  group('initializePills', () {
    test('sets pillsInitialized', () {
      ctrl.markInitScheduled(totalW: 400);
      ctrl.initializePills(tabW: 300, searchLeft: 310, searchW: 50);
      expect(ctrl.pillsInitialized, isTrue);
    });

    test('clears pillsInitScheduled', () {
      ctrl.markInitScheduled(totalW: 400);
      expect(ctrl.pillsInitScheduled, isTrue);
      ctrl.initializePills(tabW: 300, searchLeft: 310, searchW: 50);
      expect(ctrl.pillsInitScheduled, isFalse);
    });

    test('caches totalW via markInitScheduled', () {
      ctrl.markInitScheduled(totalW: 400);
      expect(ctrl.cachedTotalW, 400);
    });

    test('notifies listeners', () {
      int calls = 0;
      ctrl.addListener(() => calls++);
      ctrl.initializePills(tabW: 300, searchLeft: 310, searchW: 50);
      expect(calls, 1);
    });
  });

  // ── computeLayout — non-searching ─────────────────────────────────────────

  group('computeLayout — not searching', () {
    const totalW = 400.0;
    const barH = 64.0;
    const searchH = 50.0;
    const spacing = 8.0;
    const compactW = barH; // targetH = barH when not searching

    SearchablePillLayout compute({
      bool hasDismiss = false,
      bool dismissVisible = false,
      double extraFullW = 0,
      GlassExtraButtonPosition extraPos = GlassExtraButtonPosition.beforeSearch,
      bool extraCollapsesOnSearch = true,
      bool isKeyboardActive = false,
      double keyboardH = 0,
    }) =>
        ctrl.computeLayout(
          totalW: totalW,
          searching: false,
          expandWhenActive: true,
          barHeight: barH,
          searchBarHeight: searchH,
          spacing: spacing,
          hasDismiss: hasDismiss,
          dismissVisible: dismissVisible,
          collapsedTabWidth: null,
          tabPillAnchor: GlassTabPillAnchor.start,
          extraFullW: extraFullW,
          extraPos: extraPos,
          extraCollapsesOnSearch: extraCollapsesOnSearch,
          isKeyboardActive: isKeyboardActive,
          keyboardH: keyboardH,
          tabCount: 3,
          perTabWidth: null, // expand — preserves legacy semantics
        );

    test('tabW fills full zone (maxTabW) when not searching', () {
      final l = compute();
      // maxTabW = totalW - compactW - spacing = 400 - 64 - 8 = 328
      expect(l.targetTabW, closeTo(328, 0.01));
    });

    test('searchLeft = right edge - compactW', () {
      final l = compute();
      // totalW - compactW - extraWRight = 400 - 64 - 0 = 336
      expect(l.targetSearchLeft, closeTo(336, 0.01));
    });

    test('searchW = compactW (collapsed icon pill)', () {
      final l = compute();
      expect(l.targetSearchW, closeTo(compactW, 0.01));
    });

    test('floatY = 0 when not focused', () {
      final l = compute();
      expect(l.floatY, 0.0);
    });

    test('extraTargetW = full size when not searching', () {
      final l = compute(extraFullW: 60);
      expect(l.extraTargetW, 60.0);
    });

    test('tabW accounts for beforeSearch extra button', () {
      final l = compute(
          extraFullW: 60, extraPos: GlassExtraButtonPosition.beforeSearch);
      // maxTabW = 400 - 64 - 8 - (60 + 8) = 260
      expect(l.targetTabW, closeTo(260, 0.01));
    });

    test('tabW accounts for afterSearch extra button', () {
      final l = compute(
          extraFullW: 60, extraPos: GlassExtraButtonPosition.afterSearch);
      // maxTabW = 400 - 64 - 8 - (60 + 8) = 260
      expect(l.targetTabW, closeTo(260, 0.01));
    });
  });

  // ── computeLayout — searching ─────────────────────────────────────────────

  group('computeLayout — searching', () {
    const totalW = 400.0;
    const barH = 64.0;
    const searchH = 50.0;
    const spacing = 8.0;

    SearchablePillLayout compute({
      bool hasDismiss = false,
      bool dismissVisible = false,
      double? collapsedTabWidth,
      GlassTabPillAnchor anchor = GlassTabPillAnchor.start,
      double extraFullW = 0,
      GlassExtraButtonPosition extraPos = GlassExtraButtonPosition.beforeSearch,
      bool extraCollapsesOnSearch = true,
      bool isKeyboardActive = false,
      double keyboardH = 0,
    }) =>
        ctrl.computeLayout(
          totalW: totalW,
          searching: true,
          expandWhenActive: true,
          barHeight: barH,
          searchBarHeight: searchH,
          spacing: spacing,
          hasDismiss: hasDismiss,
          dismissVisible: dismissVisible,
          collapsedTabWidth: collapsedTabWidth,
          tabPillAnchor: anchor,
          extraFullW: extraFullW,
          extraPos: extraPos,
          extraCollapsesOnSearch: extraCollapsesOnSearch,
          isKeyboardActive: isKeyboardActive,
          keyboardH: keyboardH,
          tabCount: 3,
          perTabWidth: null, // expand — preserves legacy semantics
        );

    test('tabW = searchBarHeight when collapsedTabWidth is null', () {
      final l = compute();
      expect(l.targetTabW, closeTo(searchH, 0.01)); // 50
    });

    test('tabW = explicit collapsedTabWidth', () {
      final l = compute(collapsedTabWidth: 44);
      expect(l.targetTabW, 44.0);
    });

    test('searchLeft (start anchor) = targetTabW + spacing', () {
      final l = compute();
      // targetTabW = 50, spacing = 8 → 58
      expect(l.targetSearchLeft, closeTo(58, 0.01));
    });

    test('searchLeft (center anchor) positions based on midpoint', () {
      final l =
          compute(anchor: GlassTabPillAnchor.center, collapsedTabWidth: 50);
      // maxTabW = 400 - 50 - 8 = 342
      // searchLeft = (maxTabW + targetTabW) / 2 + 0 + 8
      //            = (342 + 50) / 2 + 8 = 196 + 8 = 204
      expect(l.targetSearchLeft, closeTo(204, 0.01));
    });

    test('searchW fills remaining space (no dismiss)', () {
      final l = compute();
      // searchLeft=58, searchW = totalW - searchLeft = 400 - 58 = 342
      expect(l.targetSearchW, closeTo(342, 0.01));
    });

    test('searchW shrinks when dismiss pill visible', () {
      // First set focus so floatY triggers correctly
      ctrl.onFocusChanged(true);
      final l = compute(hasDismiss: true, dismissVisible: true);
      // dismissReserve = searchH + spacing = 50 + 8 = 58
      // searchW = 400 - 58 - 0 - 58 = 284
      expect(l.targetSearchW, closeTo(284, 0.01));
      expect(l.dismissReserve, closeTo(58, 0.01));
    });

    test('keyboard active: searchLeft = 0 (full width)', () {
      ctrl.onFocusChanged(true);
      final l = compute(isKeyboardActive: true);
      expect(l.targetSearchLeft, closeTo(0, 0.01));
    });

    test('extraTargetW = min(extraFullW, targetH) when searching', () {
      // extraFullW=80, targetH=searchH=50 → extraTargetW = 50
      final l = compute(extraFullW: 80);
      expect(l.extraTargetW, closeTo(50, 0.01));
    });

    test('extraTargetW = extraFullW when extraFullW < targetH', () {
      final l = compute(extraFullW: 30);
      expect(l.extraTargetW, closeTo(30, 0.01));
    });
  });

  // ── computeLayout — floatY ────────────────────────────────────────────────

  group('computeLayout — floatY', () {
    test('floatY = keyboardH when focused + keyboard present', () {
      ctrl.onFocusChanged(true);
      final l = ctrl.computeLayout(
        totalW: 400,
        searching: true,
        expandWhenActive: true,
        barHeight: 64,
        searchBarHeight: 50,
        spacing: 8,
        hasDismiss: false,
        dismissVisible: false,
        collapsedTabWidth: null,
        tabPillAnchor: GlassTabPillAnchor.start,
        extraFullW: 0,
        extraPos: GlassExtraButtonPosition.beforeSearch,
        extraCollapsesOnSearch: true,
        isKeyboardActive: true,
        keyboardH: 336,
        tabCount: 3,
        perTabWidth: null,
      );
      expect(l.floatY, 336.0);
    });

    test('floatY = 0 when focused but keyboard not present', () {
      ctrl.onFocusChanged(true);
      final l = ctrl.computeLayout(
        totalW: 400,
        searching: true,
        expandWhenActive: true,
        barHeight: 64,
        searchBarHeight: 50,
        spacing: 8,
        hasDismiss: false,
        dismissVisible: false,
        collapsedTabWidth: null,
        tabPillAnchor: GlassTabPillAnchor.start,
        extraFullW: 0,
        extraPos: GlassExtraButtonPosition.beforeSearch,
        extraCollapsesOnSearch: true,
        isKeyboardActive: false,
        keyboardH: 0,
        tabCount: 3,
        perTabWidth: null,
      );
      expect(l.floatY, 0.0);
    });
  });

  // ── checkRetarget ─────────────────────────────────────────────────────────

  group('checkRetarget', () {
    SearchablePillLayout layout(
            double tabW, double searchLeft, double searchW) =>
        SearchablePillLayout(
          targetTabW: tabW,
          targetSearchLeft: searchLeft,
          targetSearchW: searchW,
          floatY: 0,
          extraTargetW: 0,
          dismissReserve: 0,
        );

    setUp(() {
      ctrl.initializePills(tabW: 300, searchLeft: 310, searchW: 50);
    });

    test('no change → all false', () {
      final r = ctrl.checkRetarget(layout(300, 310, 50));
      expect(r.tabW, isFalse);
      expect(r.searchLeft, isFalse);
      expect(r.searchW, isFalse);
      expect(r.any, isFalse);
    });

    test('tabW change → tabW=true, others false', () {
      final r = ctrl.checkRetarget(layout(200, 310, 50));
      expect(r.tabW, isTrue);
      expect(r.searchLeft, isFalse);
      expect(r.searchW, isFalse);
    });

    test('searchLeft change → searchLeft=true', () {
      final r = ctrl.checkRetarget(layout(300, 250, 50));
      expect(r.searchLeft, isTrue);
      expect(r.tabW, isFalse);
      expect(r.searchW, isFalse);
    });

    test('searchW change → searchW=true', () {
      final r = ctrl.checkRetarget(layout(300, 310, 100));
      expect(r.searchW, isTrue);
      expect(r.tabW, isFalse);
    });

    test('all three change → all true', () {
      final r = ctrl.checkRetarget(layout(200, 250, 100));
      expect(r.any, isTrue);
      expect(r.tabW, isTrue);
      expect(r.searchLeft, isTrue);
      expect(r.searchW, isTrue);
    });

    test('same value twice → no retrigger', () {
      ctrl.checkRetarget(layout(200, 250, 100)); // first change
      final r = ctrl.checkRetarget(layout(200, 250, 100)); // same values
      expect(r.any, isFalse);
    });

    test('any is false when all axes unchanged', () {
      final r = ctrl.checkRetarget(layout(300, 310, 50));
      expect(r.any, isFalse);
    });
  });

  // ── SearchablePillLayout equality ─────────────────────────────────────────

  group('SearchablePillLayout equality', () {
    const a = SearchablePillLayout(
      targetTabW: 300,
      targetSearchLeft: 310,
      targetSearchW: 50,
      floatY: 0,
      extraTargetW: 0,
      dismissReserve: 0,
    );

    test('identical instances are equal', () {
      const b = SearchablePillLayout(
        targetTabW: 300,
        targetSearchLeft: 310,
        targetSearchW: 50,
        floatY: 0,
        extraTargetW: 0,
        dismissReserve: 0,
      );
      expect(a, equals(b));
    });

    test('different targetTabW → not equal', () {
      const b = SearchablePillLayout(
        targetTabW: 200,
        targetSearchLeft: 310,
        targetSearchW: 50,
        floatY: 0,
        extraTargetW: 0,
        dismissReserve: 0,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ── SpringRetarget ────────────────────────────────────────────────────────

  group('SpringRetarget', () {
    test('none has all false', () {
      expect(SpringRetarget.none.tabW, isFalse);
      expect(SpringRetarget.none.searchLeft, isFalse);
      expect(SpringRetarget.none.searchW, isFalse);
      expect(SpringRetarget.none.any, isFalse);
    });
  });

  // ── makeSpring ────────────────────────────────────────────────────────────

  group('makeSpring', () {
    test('produces a SpringSimulation', () {
      const spring = SpringDescription(mass: 1, stiffness: 350, damping: 30);
      final sim = SearchableBottomBarController.makeSpring(
        spring: spring,
        from: 0,
        to: 100,
      );
      expect(sim, isA<SpringSimulation>());
      // Initial position should be 0.
      expect(sim.x(0), closeTo(0, 0.01));
      // After settling, position should approach 100.
      expect(sim.x(5), closeTo(100, 1));
    });
  });

  // ── computeLayout — tabWidth (compact sizing) ─────────────────────────────

  group('computeLayout — tabWidth', () {
    // totalW=390, barH=64, spacing=8
    // maxTabW = 390 - 64 - 8 = 318  (no extra button)
    const totalW = 390.0;
    const barH = 64.0;
    const searchH = 50.0;
    const spacing = 8.0;

    SearchablePillLayout compact({
      required int tabCount,
      required double? perTabWidth,
      bool searching = false,
      double? collapsedTabWidth,
    }) =>
        ctrl.computeLayout(
          totalW: totalW,
          searching: searching,
          expandWhenActive: true,
          barHeight: barH,
          searchBarHeight: searchH,
          spacing: spacing,
          hasDismiss: false,
          dismissVisible: false,
          collapsedTabWidth: collapsedTabWidth,
          tabPillAnchor: GlassTabPillAnchor.start,
          extraFullW: 0,
          extraPos: GlassExtraButtonPosition.beforeSearch,
          extraCollapsesOnSearch: true,
          isKeyboardActive: false,
          keyboardH: 0,
          tabCount: tabCount,
          perTabWidth: perTabWidth,
        );

    // ── Compact width calculation ───────────────────────────────────────────

    test('2 tabs × 88 px → 176 px pill', () {
      expect(compact(tabCount: 2, perTabWidth: 88).targetTabW, 176.0);
    });

    test('3 tabs × 88 px → 264 px pill', () {
      expect(compact(tabCount: 3, perTabWidth: 88).targetTabW, 264.0);
    });

    test('4 tabs × 88 px → clamped to maxTabW (352 > 318)', () {
      // 4 × 88 = 352, but maxTabW = 390 - 64 - 8 = 318 → clamped
      expect(compact(tabCount: 4, perTabWidth: 88).targetTabW, 318.0);
    });

    test('wider perTabWidth (110) produces correct pill', () {
      // 3 × 110 = 330 ≤ maxTabW(318)? No, 330 > 318, so clamp to 318.
      expect(compact(tabCount: 3, perTabWidth: 110).targetTabW, 318.0);
    });

    test('perTabWidth 72 (icon-only) with 3 tabs → 216 px', () {
      expect(compact(tabCount: 3, perTabWidth: 72).targetTabW, 216.0);
    });

    // ── Null = expand (legacy) ────────────────────────────────────────────────

    test('perTabWidth null → fills maxTabW regardless of tab count', () {
      final two = compact(tabCount: 2, perTabWidth: null);
      final three = compact(tabCount: 3, perTabWidth: null);
      // Both should equal maxTabW = 318
      expect(two.targetTabW, 318.0);
      expect(three.targetTabW, 318.0);
    });

    // ── Clamping ──────────────────────────────────────────────────────────────

    test('natural width > maxTabW is clamped to maxTabW', () {
      // 5 × 88 = 440 > 318 → clamp
      final l = compact(tabCount: 5, perTabWidth: 88);
      expect(l.targetTabW, 318.0);
    });

    test('targetTabW never exceeds totalW', () {
      final l = compact(tabCount: 10, perTabWidth: 200);
      expect(l.targetTabW, lessThanOrEqualTo(totalW));
    });

    // ── Search pill geometry ──────────────────────────────────────────────────
    //
    // When not searching, the search pill is a compact circle pinned to the
    // RIGHT EDGE — its position and size don't change with tabWidth.
    // The tabWidth benefit is purely that the tab PILL is narrower, leaving
    // visible glass gap between the pill right edge and the search button.

    test('compact tab pill is narrower than expand for same tab count', () {
      final cmp = compact(tabCount: 3, perTabWidth: 88);
      final exp = compact(tabCount: 3, perTabWidth: null);
      expect(cmp.targetTabW, lessThan(exp.targetTabW));
    });

    test('search button is pinned to right edge regardless of tabWidth', () {
      final cmp = compact(tabCount: 2, perTabWidth: 88);
      final exp = compact(tabCount: 2, perTabWidth: null);
      // Both land at totalW - barH = 390 - 64 = 326
      expect(cmp.targetSearchLeft, 326.0);
      expect(exp.targetSearchLeft, 326.0);
    });

    test('search button width is barHeight (compact circle) when not searching',
        () {
      final l = compact(tabCount: 2, perTabWidth: 88);
      expect(l.targetSearchW, barH); // 64
    });

    // ── Collapsed state during search ─────────────────────────────────────────

    test('when searching, collapsedTabWidth overrides perTabWidth', () {
      final l = compact(
        tabCount: 3,
        perTabWidth: 88,
        searching: true,
        collapsedTabWidth: 56,
      );
      expect(l.targetTabW, 56.0);
    });

    test(
        'when searching without collapsedTabWidth, falls back to searchBarHeight',
        () {
      final l = compact(tabCount: 3, perTabWidth: 88, searching: true);
      expect(l.targetTabW, searchH); // 50
    });
  });

  // ── computeLayout — showPill ───────────────────────────────────────────────

  group('computeLayout — showPill', () {
    const totalW = 400.0;
    const barH = 64.0;
    const searchH = 50.0;
    const spacing = 8.0;

    SearchablePillLayout compute({
      required bool searching,
      bool showPill = true,
    }) =>
        ctrl.computeLayout(
          totalW: totalW,
          searching: searching,
          expandWhenActive: false,
          barHeight: barH,
          searchBarHeight: searchH,
          spacing: spacing,
          hasDismiss: false,
          dismissVisible: false,
          collapsedTabWidth: null,
          tabPillAnchor: GlassTabPillAnchor.start,
          extraFullW: 0,
          extraPos: GlassExtraButtonPosition.beforeSearch,
          extraCollapsesOnSearch: true,
          isKeyboardActive: false,
          keyboardH: 0,
          tabCount: 3,
          perTabWidth: null,
          showPill: showPill,
        );

    test('defaults to shown — the pill slot stays reserved', () {
      final l = compute(searching: false);
      // maxTabW = totalW - barH - spacing = 400 - 64 - 8 = 328
      expect(l.targetTabW, closeTo(328, 0.01));
    });

    test('an absent pill gives the tab pill the full bar', () {
      final l = compute(searching: false, showPill: false);
      expect(l.targetTabW, totalW);
    });

    test('an absent pill leaves the searching tab circle untouched', () {
      final l = compute(searching: true, showPill: false);
      expect(l.targetTabW, searchH); // collapsed circle
    });

    test('search pill targets are identical shown or absent', () {
      // Hiding is the layout widget's job (the pill is unmounted and scaled
      // in place at its slot) — the pill's own position/size targets must
      // never morph with showPill, or (re)appearing would slide it in from
      // wherever the hidden targets parked it.
      for (final searching in [false, true]) {
        final shown = compute(searching: searching);
        final absent = compute(searching: searching, showPill: false);
        expect(absent.targetSearchLeft, shown.targetSearchLeft,
            reason: 'searching=$searching');
        expect(absent.targetSearchW, shown.targetSearchW,
            reason: 'searching=$searching');
      }
    });
  });
}
