// Coverage for SearchablePillLayout, SpringRetarget, SearchableBottomBarController.
// All uncovered lines (60-124) are pure Dart — no widget tree needed.

import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/tab_bar_extra_button.dart'
    show GlassExtraButtonPosition;
import 'package:liquid_glass_widgets/widgets/surfaces/shared/tab_bar_types.dart'
    show GlassTabPillAnchor;
import 'package:liquid_glass_widgets/widgets/surfaces/shared/tab_bar_searchable_controller.dart';

void main() {
  // ── SearchablePillLayout value-type ───────────────────────────────────────

  group('SearchablePillLayout', () {
    const a = SearchablePillLayout(
      targetTabW: 100,
      targetSearchLeft: 200,
      targetSearchW: 50,
      floatY: 0,
      extraTargetW: 0,
      dismissReserve: 0,
    );
    const b = SearchablePillLayout(
      targetTabW: 100,
      targetSearchLeft: 200,
      targetSearchW: 50,
      floatY: 0,
      extraTargetW: 0,
      dismissReserve: 0,
    );
    const c = SearchablePillLayout(
      targetTabW: 99,
      targetSearchLeft: 200,
      targetSearchW: 50,
      floatY: 0,
      extraTargetW: 0,
      dismissReserve: 0,
    );

    test('equality: identical instances are equal', () => expect(a, equals(b)));
    test('hashCode: equal instances share hashCode',
        () => expect(a.hashCode, b.hashCode));
    test('inequality: different tabW', () => expect(a, isNot(equals(c))));
    test('identical() short-circuit', () => expect(a == a, isTrue));

    test('toString contains field names', () {
      final s = a.toString();
      expect(s, contains('tabW'));
      expect(s, contains('searchLeft'));
    });

    test('floatY / extraTargetW / dismissReserve inequality', () {
      const d = SearchablePillLayout(
        targetTabW: 100,
        targetSearchLeft: 200,
        targetSearchW: 50,
        floatY: 10,
        extraTargetW: 5,
        dismissReserve: 8,
      );
      expect(a, isNot(equals(d)));
    });
  });

  // ── SpringRetarget ────────────────────────────────────────────────────────

  group('SpringRetarget', () {
    test('any is false when all false', () {
      expect(SpringRetarget.none.any, isFalse);
    });

    test('any is true when tabW true', () {
      expect(
        const SpringRetarget(tabW: true, searchLeft: false, searchW: false).any,
        isTrue,
      );
    });

    test('any is true when searchLeft true', () {
      expect(
        const SpringRetarget(tabW: false, searchLeft: true, searchW: false).any,
        isTrue,
      );
    });

    test('toString contains all fields', () {
      final s = SpringRetarget.none.toString();
      expect(s, contains('tabW'));
      expect(s, contains('searchLeft'));
      expect(s, contains('searchW'));
    });
  });

  // ── SearchableBottomBarController ─────────────────────────────────────────

  group('SearchableBottomBarController', () {
    late SearchableBottomBarController ctrl;
    setUp(() => ctrl = SearchableBottomBarController());
    tearDown(() => ctrl.dispose());

    // onFocusChanged
    test('onFocusChanged: true → sets searchFocused', () {
      ctrl.onFocusChanged(true);
      expect(ctrl.searchFocused, isTrue);
    });

    test('onFocusChanged: idempotent when value unchanged', () {
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.onFocusChanged(false); // already false
      expect(notifyCount, 0);
    });

    test('onFocusChanged: notifies when value changes', () {
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.onFocusChanged(true);
      expect(notifyCount, 1);
    });

    // onSearchActiveChanged
    test('clears searchFocused when search deactivated while focused', () {
      ctrl.onFocusChanged(true);
      ctrl.onSearchActiveChanged(wasActive: true, isActive: false);
      expect(ctrl.searchFocused, isFalse);
    });

    test('no-op when wasActive=false', () {
      ctrl.onFocusChanged(true);
      ctrl.onSearchActiveChanged(wasActive: false, isActive: false);
      expect(ctrl.searchFocused, isTrue); // unchanged
    });

    test('no-op when not focused', () {
      ctrl.onSearchActiveChanged(wasActive: true, isActive: false);
      expect(ctrl.searchFocused, isFalse);
    });

    // markInitScheduled / initializePills
    test('markInitScheduled sets scheduled flag and caches totalW', () {
      ctrl.markInitScheduled(totalW: 320);
      expect(ctrl.pillsInitScheduled, isTrue);
      expect(ctrl.cachedTotalW, 320);
    });

    test('initializePills sets initialized and clears scheduled', () {
      ctrl.markInitScheduled(totalW: 320);
      ctrl.initializePills(tabW: 100, searchLeft: 150, searchW: 60);
      expect(ctrl.pillsInitialized, isTrue);
      expect(ctrl.pillsInitScheduled, isFalse);
    });

    // checkRetarget
    test('checkRetarget detects all axes changed', () {
      ctrl.initializePills(tabW: 100, searchLeft: 150, searchW: 60);
      const layout = SearchablePillLayout(
        targetTabW: 200,
        targetSearchLeft: 300,
        targetSearchW: 90,
        floatY: 0,
        extraTargetW: 0,
        dismissReserve: 0,
      );
      final retarget = ctrl.checkRetarget(layout);
      expect(retarget.tabW, isTrue);
      expect(retarget.searchLeft, isTrue);
      expect(retarget.searchW, isTrue);
      expect(retarget.any, isTrue);
    });

    test('checkRetarget returns none when nothing changed', () {
      ctrl.initializePills(tabW: 100, searchLeft: 150, searchW: 60);
      const layout = SearchablePillLayout(
        targetTabW: 100,
        targetSearchLeft: 150,
        targetSearchW: 60,
        floatY: 0,
        extraTargetW: 0,
        dismissReserve: 0,
      );
      final retarget = ctrl.checkRetarget(layout);
      expect(retarget.any, isFalse);
    });

    // makeSpring
    test('makeSpring returns a valid SpringSimulation', () {
      final spring = SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 500,
        ratio: 0.8,
      );
      final sim = SearchableBottomBarController.makeSpring(
        spring: spring,
        from: 0,
        to: 100,
      );
      expect(sim, isA<SpringSimulation>());
    });

    // computeLayout — keyboard float path (floatY branch)
    test('computeLayout: floatY > 0 when focused and keyboard present', () {
      ctrl.onFocusChanged(true); // _searchFocused = true
      final layout = ctrl.computeLayout(
        totalW: 400,
        searching: true,
        expandWhenActive: true,
        barHeight: 56,
        searchBarHeight: 44,
        spacing: 8,
        hasDismiss: false,
        dismissVisible: false,
        collapsedTabWidth: null,
        tabPillAnchor: GlassTabPillAnchor.start,
        extraFullW: 0,
        extraPos: GlassExtraButtonPosition.afterSearch,
        extraCollapsesOnSearch: false,
        isKeyboardActive: true,
        keyboardH: 300,
        tabCount: 4,
        perTabWidth: null,
      );
      expect(layout.floatY, 300);
    });

    test('computeLayout: with extraButton before search', () {
      final layout = ctrl.computeLayout(
        totalW: 400,
        searching: false,
        expandWhenActive: false,
        barHeight: 56,
        searchBarHeight: 44,
        spacing: 8,
        hasDismiss: true,
        dismissVisible: true,
        collapsedTabWidth: 60,
        tabPillAnchor: GlassTabPillAnchor.center,
        extraFullW: 48,
        extraPos: GlassExtraButtonPosition.beforeSearch,
        extraCollapsesOnSearch: true,
        isKeyboardActive: false,
        keyboardH: 0,
        tabCount: 3,
        perTabWidth: 80,
      );
      expect(layout.extraTargetW, 48);
      expect(layout.dismissReserve, greaterThan(0));
    });
  });
}
