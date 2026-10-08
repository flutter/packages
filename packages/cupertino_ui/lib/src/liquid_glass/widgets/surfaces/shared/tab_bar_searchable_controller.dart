// Extracted layout state machine for GlassTabBar.searchable.
//
// This file is intentionally free of Flutter widget dependencies
// (no BuildContext, no TickerProvider, no setState) so the layout
// math can be unit tested without a widget tree.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';

import 'tab_bar_extra_button.dart' show GlassExtraButtonPosition;
import 'tab_bar_types.dart' show GlassTabPillAnchor;
import '../../../src/widgets/surfaces/tab_bar_layout_utils.dart';

// =============================================================================
// SearchablePillLayout — immutable layout result
// =============================================================================

/// Immutable result of one [SearchableBottomBarController.computeLayout] call.
///
/// All values are in logical pixels and represent the *target* positions
/// for the spring animations — not the current animated positions.
@immutable
class SearchablePillLayout {
  /// Creates a layout result.
  const SearchablePillLayout({
    required this.targetTabW,
    required this.targetSearchLeft,
    required this.targetSearchW,
    required this.floatY,
    required this.extraTargetW,
    required this.dismissReserve,
  });

  /// Target width of the tab pill.
  final double targetTabW;

  /// Target left edge of the search pill.
  final double targetSearchLeft;

  /// Target width of the search pill.
  final double targetSearchW;

  /// Y offset that floats both pills above the keyboard when it is visible.
  final double floatY;

  /// Width reserved for the extra action button in the current state.
  final double extraTargetW;

  /// Width reserved for the dismiss pill (0 when not shown).
  final double dismissReserve;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchablePillLayout &&
          other.targetTabW == targetTabW &&
          other.targetSearchLeft == targetSearchLeft &&
          other.targetSearchW == targetSearchW &&
          other.floatY == floatY &&
          other.extraTargetW == extraTargetW &&
          other.dismissReserve == dismissReserve;

  @override
  int get hashCode => Object.hash(
        targetTabW,
        targetSearchLeft,
        targetSearchW,
        floatY,
        extraTargetW,
        dismissReserve,
      );

  @override
  String toString() => 'SearchablePillLayout('
      'tabW: $targetTabW, '
      'searchLeft: $targetSearchLeft, '
      'searchW: $targetSearchW, '
      'floatY: $floatY, '
      'extraTargetW: $extraTargetW, '
      'dismissReserve: $dismissReserve'
      ')';
}

// =============================================================================
// SpringRetarget — which spring axes changed
// =============================================================================

/// Describes which spring animation axes need to be retargeted.
///
/// Returned by [SearchableBottomBarController.checkRetarget].
@immutable
class SpringRetarget {
  /// Creates a retarget descriptor.
  const SpringRetarget({
    required this.tabW,
    required this.searchLeft,
    required this.searchW,
  });

  /// No axes need retargeting.
  static const none = SpringRetarget(
    tabW: false,
    searchLeft: false,
    searchW: false,
  );

  /// Whether the tab pill width spring needs retargeting.
  final bool tabW;

  /// Whether the search pill left edge spring needs retargeting.
  final bool searchLeft;

  /// Whether the search pill width spring needs retargeting.
  final bool searchW;

  /// `true` when at least one axis needs retargeting.
  bool get any => tabW || searchLeft || searchW;

  @override
  String toString() =>
      'SpringRetarget(tabW: $tabW, searchLeft: $searchLeft, searchW: $searchW)';
}

// =============================================================================
// SearchableBottomBarController
// =============================================================================

/// Manages the layout state machine for [GlassTabBar.searchable].
///
/// Owns the spring target computation, change-detection cache, and focus
/// state so that this logic can be unit tested without a widget tree.
///
/// ### Usage
///
/// Create and hold in a `State` (or provide via a parent widget):
/// ```dart
/// final _searchController = SearchableBottomBarController();
///
/// @override
/// void dispose() {
///   _searchController.dispose();
///   super.dispose();
/// }
/// ```
///
/// Pass to the widget:
/// ```dart
/// GlassTabBar.searchable(
///   controller: _searchController,
///   ...
/// )
/// ```
///
/// Open/close search programmatically via the controller:
/// ```dart
/// _searchController.openSearch();  // expands search bar
/// _searchController.closeSearch(); // collapses back to tabs
/// ```
///
/// Or by driving `isSearchActive` on [GlassTabBar.searchable] directly from
/// your own state — both approaches work and are interchangeable.
class SearchableBottomBarController extends ChangeNotifier {
  // ── Focus state ──────────────────────────────────────────────────────────

  bool _searchFocused = false;

  /// Whether the search text field is currently focused (keyboard visible).
  bool get searchFocused => _searchFocused;

  // ── Initialization guards ─────────────────────────────────────────────────

  bool _pillsInitialized = false;
  bool _pillsInitScheduled = false;

  /// False until the first [initializePills] call completes.
  bool get pillsInitialized => _pillsInitialized;

  /// True while an init post-frame callback is pending.
  bool get pillsInitScheduled => _pillsInitScheduled;

  // ── Programmatic search open/close ──────────────────────────────────────

  bool _isSearchOpen = false;

  /// Whether the search bar is currently open (expanded).
  ///
  /// Set programmatically via [openSearch] / [closeSearch], or kept in sync
  /// with `isSearchActive` on [GlassTabBar.searchable] via [syncSearchActive].
  bool get isSearchOpen => _isSearchOpen;

  /// Expands the search bar.
  ///
  /// Equivalent to setting `isSearchActive: true` on the widget. Notifies
  /// listeners so any parent widget bound to this controller can rebuild.
  ///
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: _searchController.openSearch,
  ///   child: const Text('Search'),
  /// )
  /// ```
  void openSearch() {
    if (_isSearchOpen) return; // idempotent
    _isSearchOpen = true;
    notifyListeners();
  }

  /// Collapses the search bar back to the tab view.
  ///
  /// Equivalent to setting `isSearchActive: false` on the widget. Also
  /// clears [searchFocused] if the keyboard was visible.
  void closeSearch() {
    if (!_isSearchOpen) return; // idempotent
    _isSearchOpen = false;
    if (_searchFocused) _searchFocused = false;
    notifyListeners();
  }

  /// Synchronises [isSearchOpen] with the parent widget's `isSearchActive` prop.
  ///
  /// Called from `didUpdateWidget` when the prop changes externally so that
  /// [isSearchOpen] always reflects the actual widget state.
  void syncSearchActive(bool isActive) {
    if (_isSearchOpen == isActive) return;
    _isSearchOpen = isActive;
    // No notifyListeners — the parent widget is already handling the rebuild.
  }

  // ── Spring target cache ──────────────────────────────────────────────────

  double _prevTabWTarget = double.nan;
  double _prevSearchLeftTarget = double.nan;
  double _prevSearchWTarget = double.nan;

  /// Last known total available width — used to detect layout invalidation.
  double cachedTotalW = 0;

  // ── Core API ─────────────────────────────────────────────────────────────

  /// Called when the search text field gains or loses keyboard focus.
  ///
  /// Notifies listeners so the parent state can schedule a rebuild.
  void onFocusChanged(bool focused) {
    if (_searchFocused == focused) return; // idempotent
    _searchFocused = focused;
    notifyListeners();
  }

  /// Called from `didUpdateWidget` when `isSearchActive` changes on [GlassTabBar.searchable].
  ///
  /// Clears [searchFocused] when search is deactivated externally.
  void onSearchActiveChanged({
    required bool wasActive,
    required bool isActive,
  }) {
    if (wasActive && !isActive && _searchFocused) {
      _searchFocused = false;
      notifyListeners();
    }
  }

  /// Marks initialization as scheduled (guard against duplicate callbacks).
  void markInitScheduled({required double totalW}) {
    _pillsInitScheduled = true;
    cachedTotalW = totalW;
  }

  /// Called in the post-frame callback after the first layout pass.
  ///
  /// Sets [pillsInitialized] and caches the layout targets to prime change-detection.
  void initializePills({
    required double tabW,
    required double searchLeft,
    required double searchW,
  }) {
    _prevTabWTarget = tabW;
    _prevSearchLeftTarget = searchLeft;
    _prevSearchWTarget = searchW;
    _pillsInitialized = true;
    _pillsInitScheduled = false;
    notifyListeners();
  }

  // ── Layout computation ───────────────────────────────────────────────────

  /// Computes pill layout targets from the given constraints.
  ///
  /// Pure function — no Flutter dependency, fully unit testable.
  ///
  /// [totalW]               — available width from `LayoutBuilder.maxWidth`.
  /// [searching]            — whether search is currently active.
  /// [barHeight]            — full tab-bar height (pixels).
  /// [searchBarHeight]      — compact pill height when search is active.
  /// [spacing]              — gap between adjacent pills.
  /// [hasDismiss]           — whether the dismiss pill is configured.
  /// [dismissVisible]       — whether the dismiss pill is currently shown.
  /// [collapsedTabWidth]    — explicit collapsed tab width, or null → uses targetH.
  /// [tabPillAnchor]        — start or center anchor mode.
  /// [extraFullW]           — extra button's full size (0 if none).
  /// [extraPos]             — whether extra button is before or after search pill.
  /// [extraCollapsesOnSearch] — whether extra button hides when focused.
  /// [isKeyboardActive]     — _searchFocused && keyboardPresent.
  /// [keyboardH]            — current keyboard height (for floatY).
  /// [perTabWidth]          — width per tab slot when compact sizing is used;
  ///                           null means the tab pill fills all available space.
  /// [tabCount]             — number of tabs; used with [perTabWidth] to compute
  ///                           natural pill width.
  /// [showPill]             — whether the search pill exists. An absent pill
  ///                           stops reserving tab-pill width; its own
  ///                           position/size targets stay unchanged either
  ///                           way, because hiding is the layout's job (the
  ///                           pill is unmounted and scaled in place), never
  ///                           a zero-width morph.
  SearchablePillLayout computeLayout({
    required double totalW,
    required bool searching,
    required bool expandWhenActive,
    required double barHeight,
    required double searchBarHeight,
    required double spacing,
    required bool hasDismiss,
    required bool dismissVisible,
    required double? collapsedTabWidth,
    required GlassTabPillAnchor tabPillAnchor,
    required double extraFullW,
    required GlassExtraButtonPosition extraPos,
    required bool extraCollapsesOnSearch,
    required bool isKeyboardActive,
    required double keyboardH,
    required int tabCount,
    required double? perTabWidth,
    bool showPill = true,
  }) {
    final targetH = searching ? searchBarHeight : barHeight;

    // ── Extra button sizing ────────────────────────────────────────────────
    final extraTargetW = extraFullW > 0
        ? (searching ? math.min(extraFullW, targetH) : extraFullW)
        : 0.0;

    final extraWLeft =
        (extraFullW > 0 && extraPos == GlassExtraButtonPosition.beforeSearch)
            ? (extraTargetW + spacing)
            : 0.0;
    final extraWRight =
        (extraFullW > 0 && extraPos == GlassExtraButtonPosition.afterSearch)
            ? (extraTargetW + spacing)
            : 0.0;
    final extraFullWLeft =
        (extraFullW > 0 && extraPos == GlassExtraButtonPosition.beforeSearch)
            ? (extraFullW + spacing)
            : 0.0;
    final extraFullWRight =
        (extraFullW > 0 && extraPos == GlassExtraButtonPosition.afterSearch)
            ? (extraFullW + spacing)
            : 0.0;

    final doCollapseLayout = isKeyboardActive && extraCollapsesOnSearch;
    final curExtraWLeft = doCollapseLayout ? 0.0 : extraWLeft;
    final curExtraWRight = doCollapseLayout ? 0.0 : extraWRight;

    // ── Dismiss pill ───────────────────────────────────────────────────────
    final targetCompactW = targetH;
    final dismissReserve = hasDismiss ? (targetH + spacing) : 0.0;

    // maxTabW: maximum space the tab pill can ever occupy (when fully expanded).
    // Uses FULL (non-collapsed) extra widths for stability across states.
    // An absent pill reserves nothing — the tab pill takes the whole bar.
    final pillReserve = showPill ? targetCompactW + spacing : 0.0;
    final maxTabW = totalW - pillReserve - extraFullWLeft - extraFullWRight;

    // naturalTabW: intrinsic width when perTabWidth is specified.
    // Delegates to the shared resolveTabPillWidth function, which is also
    // used by GlassTabBar.bottom — single source of truth for this calculation.
    final naturalTabW = resolveTabPillWidth(
      tabWidth: perTabWidth,
      tabCount: tabCount,
      maxAvailable: maxTabW,
    );

    final targetTabW =
        !searching ? naturalTabW : (collapsedTabWidth ?? targetH);

    // ── Search pill ────────────────────────────────────────────────────────
    final centeredTab = tabPillAnchor == GlassTabPillAnchor.center;

    final targetSearchLeft = !searching || !expandWhenActive
        ? totalW - targetCompactW - extraWRight
        : isKeyboardActive
            ? curExtraWLeft
            : centeredTab
                ? (maxTabW + targetTabW) / 2 + curExtraWLeft + spacing
                : targetTabW + curExtraWLeft + spacing;

    final targetSearchW = !searching || !expandWhenActive
        ? targetCompactW
        : totalW -
            targetSearchLeft -
            curExtraWRight -
            (dismissVisible ? dismissReserve : 0.0);

    // ── Keyboard float ─────────────────────────────────────────────────────
    final floatY = (_searchFocused && keyboardH > 0) ? keyboardH : 0.0;

    return SearchablePillLayout(
      targetTabW: targetTabW,
      targetSearchLeft: targetSearchLeft,
      targetSearchW: targetSearchW,
      floatY: floatY,
      extraTargetW: extraTargetW,
      dismissReserve: dismissReserve,
    );
  }

  // ── Spring change detection ───────────────────────────────────────────────

  /// Compares [layout] targets against the cached previous targets and
  /// returns which axes have changed.
  ///
  /// Updates the internal cache for changed axes.
  /// Returns [SpringRetarget.none] when nothing changed.
  SpringRetarget checkRetarget(SearchablePillLayout layout) {
    final newTabW = layout.targetTabW != _prevTabWTarget;
    final newLeft = layout.targetSearchLeft != _prevSearchLeftTarget;
    final newSearchW = layout.targetSearchW != _prevSearchWTarget;

    if (newTabW) _prevTabWTarget = layout.targetTabW;
    if (newLeft) _prevSearchLeftTarget = layout.targetSearchLeft;
    if (newSearchW) _prevSearchWTarget = layout.targetSearchW;

    return SpringRetarget(
      tabW: newTabW,
      searchLeft: newLeft,
      searchW: newSearchW,
    );
  }

  // ── Convenience spring factory ────────────────────────────────────────────

  /// Creates a [SpringSimulation] from [from] → [to] using [spring].
  ///
  /// [velocity] carries the in-flight speed of the axis being retargeted.
  /// Passing it matters whenever a morph reverses before it settles — which
  /// scroll-driven minimizing makes routine, since scrolling down and straight
  /// back up is an ordinary gesture. Relaunching from rest in that case reads
  /// as a stall followed by a restart. Defaults to 0.0, which is what an idle
  /// [AnimationController] reports, so a first-launch spring is unchanged.
  static SpringSimulation makeSpring({
    required SpringDescription spring,
    required double from,
    required double to,
    double velocity = 0.0,
  }) =>
      SpringSimulation(spring, from, to, velocity);
}
