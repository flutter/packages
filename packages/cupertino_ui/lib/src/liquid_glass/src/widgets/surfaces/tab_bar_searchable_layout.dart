// ignore_for_file: public_member_api_docs
// Internal layout engine for [GlassTabBar] searchable placement.
//
// Extracted so that [GlassTabBar] is the single owner of all rendering logic.
//
// Do NOT import this file directly — use [GlassTabBar.searchable()] instead.

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../../renderer/glass_backdrop_group.dart';
import '../../renderer/liquid_glass_renderer.dart';
import '../../types/glass_interaction_behavior.dart';
import '../../../types/glass_quality.dart';
import '../../../widgets/shared/adaptive_liquid_glass_layer.dart';
import '../../../widgets/shared/glass_accessibility_scope.dart';
import '../../../widgets/shared/glass_content_aware_scope.dart';
import '../../../theme/glass_theme_data.dart';
import '../../../theme/glass_theme.dart';
import '../../../theme/glass_theme_helpers.dart';
import '../../../widgets/surfaces/shared/tab_bar_extra_button.dart'
    show GlassExtraButtonPosition, GlassTabBarExtraButton;
import '../../../widgets/surfaces/shared/tab_bar_types.dart'
    show GlassTabPillAnchor, MaskingQuality;
import '../../../widgets/surfaces/glass_tab_bar.dart'
    show GlassTab, GlassTabBarTrailingButton;
import '../../../widgets/overlays/glass_menu.dart' show GlassMenu;
import 'tab_bar_bottom_internal.dart'
    show
        BottomBarExtraBtn,
        BottomBarTabItem,
        kBottomBarGlassDefaults,
        resolveBarLabelColor;
import '../../../widgets/surfaces/shared/glass_search_bar_config.dart';
import '../../../widgets/surfaces/shared/tab_bar_searchable_controller.dart';
import 'tab_bar_searchable_internal.dart'
    show
        DismissPill,
        MinimizableTrailingPill,
        SearchPill,
        SearchableTabIndicator;
import '../../../widgets/surfaces/shared/tab_bar_accessory_placement.dart';
import '../../../widgets/surfaces/shared/tab_bar_minimize_controller.dart';
import 'tab_bar_layout_utils.dart';

/// Internal [StatefulWidget] that owns the searchable-placement rendering engine.
///
/// Created by [GlassTabBar._buildSearchable()] when
/// [_GlassTabBarPlacement.searchable] is active. Not part of the public API.
class TabBarSearchableLayout extends StatefulWidget {
  const TabBarSearchableLayout({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.searchConfig,
    this.trailingButton,
    this.onMinimizedTabTap,
    super.key,
    this.controller,
    this.isSearchActive = false,
    this.minimizeController,
    this.isMinimizablePlacement = false,
    this.extraButton,
    this.bottomAccessoryPlacement,
    this.bottomAccessory,
    this.bottomAccessoryEnabled = true,
    this.bottomAccessorySpacing = 6.0,
    this.bottomAccessoryHeight,
    this.spacing = 8,
    this.horizontalPadding = 20,
    this.verticalPadding = 20,
    this.barHeight = 64,
    this.searchBarHeight = 50,
    this.barBorderRadius = _kDefaultBorderRadius,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.iconLabelSpacing = 4,
    this.enableBlend = true,
    this.blendAmount = 10,
    this.settings,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorSettings,
    this.indicatorPinchStrength = 0.4,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.iconSize = 24,
    this.labelFontSize = 11,
    this.textStyle,
    this.glowDuration = const Duration(milliseconds: 300),
    this.glowBlurRadius = 32,
    this.glowSpreadRadius = 8,
    this.glowOpacity = 0.6,
    this.interactionGlowColor,
    this.interactionGlowRadius,
    this.quality,
    this.backgroundQuality,
    this.magnification = 1.15,
    this.innerBlur = 0.0,
    this.platformViewBackdrop = false,
    this.passthroughOverPlatformView = false,
    this.maskingQuality = MaskingQuality.high,
    this.backgroundKey,
    this.springDescription,
    this.tabPillAnchor = GlassTabPillAnchor.start,
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.pressScale,
    this.tabWidth,
    this.indicatorBorderRadius,
    this.indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.onBarTap,
    this.whitenAtBottom = true,
    this.whitenBottomThreshold = 45.0,
    this.whitenAtBottomTarget = 1.0,
    this.scrollController,
    this.adaptiveBrightness = false,
    this.onBrightnessChanged,
    this.brightnessOverride,
  }) : assert(
          searchConfig == null || trailingButton == null,
          'TabBarSearchableLayout: searchConfig and trailingButton are mutually '
          'exclusive. Use searchConfig for GlassTabBar.searchable and '
          'trailingButton for GlassTabBar.minimizable.',
        );

  static const double _kDefaultBorderRadius = 32.0;

  /// iOS 26-style spring for the pill morph animations.
  static const _kSpring =
      SpringDescription(mass: 1.0, stiffness: 350.0, damping: 30.0);

  final List<GlassTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final GlassSearchBarConfig? searchConfig;
  final GlassTabBarTrailingButton? trailingButton;
  final VoidCallback? onMinimizedTabTap;
  final SearchableBottomBarController? controller;
  final bool isSearchActive;

  /// Drives the minimize from scrolling. This engine only attaches it to
  /// [scrollController] — the resulting state arrives through
  /// [isSearchActive], which [GlassTabBar] resolves.
  final GlassTabBarMinimizeController? minimizeController;

  /// Whether the host is [GlassTabBar.minimizable] rather than
  /// [GlassTabBar.searchable]. Only the former pulls its bottom accessory
  /// inline as the bar shrinks.
  final bool isMinimizablePlacement;
  final GlassTabBarExtraButton? extraButton;
  final GlassTabBarAccessoryPlacement? bottomAccessoryPlacement;
  final Widget? bottomAccessory;
  final bool bottomAccessoryEnabled;
  final double bottomAccessorySpacing;
  final double? bottomAccessoryHeight;
  final double spacing;
  final double horizontalPadding;
  final double verticalPadding;
  final double barHeight;
  final double searchBarHeight;
  final double barBorderRadius;
  final EdgeInsetsGeometry tabPadding;
  final double iconLabelSpacing;
  final bool enableBlend;
  final double blendAmount;
  final LiquidGlassSettings? settings;
  final bool showIndicator;
  final Color? indicatorColor;
  final LiquidGlassSettings? indicatorSettings;
  final double indicatorPinchStrength;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final double iconSize;
  final double labelFontSize;
  final TextStyle? textStyle;
  final Duration glowDuration;
  final double glowBlurRadius;
  final double glowSpreadRadius;
  final double glowOpacity;
  final Color? interactionGlowColor;

  /// Radius of the interaction glow, as a fraction of the layer's shortest
  /// side. Null asks for the iOS 26 calibration — see
  /// [resolveTabBarInteractionGlow].
  final double? interactionGlowRadius;
  final GlassQuality? quality;
  final GlassQuality? backgroundQuality;
  final double magnification;
  final double innerBlur;
  final bool platformViewBackdrop;

  /// See [SearchableTabIndicator.passthroughOverPlatformView]. Set this when
  /// the bar floats over a map, camera preview or other platform view and its
  /// glass is configured to stay transparent instead of painting a body.
  final bool passthroughOverPlatformView;
  final MaskingQuality maskingQuality;
  final GlobalKey? backgroundKey;
  final SpringDescription? springDescription;
  final GlassTabPillAnchor tabPillAnchor;
  final GlassInteractionBehavior interactionBehavior;
  final double? pressScale;
  final double? tabWidth;
  final double? indicatorBorderRadius;
  final EdgeInsetsGeometry indicatorExpansion;
  final VoidCallback? onBarTap;
  final bool whitenAtBottom;
  final double whitenBottomThreshold;
  final double whitenAtBottomTarget;
  final ScrollController? scrollController;
  final bool adaptiveBrightness;
  final ValueChanged<Brightness>? onBrightnessChanged;
  final ValueListenable<Brightness>? brightnessOverride;

  @override
  State<TabBarSearchableLayout> createState() => _TabBarSearchableLayoutState();
}

class _TabBarSearchableLayoutState extends State<TabBarSearchableLayout>
    with TickerProviderStateMixin {
  static const _defaultGlassSettings = kBottomBarGlassDefaults;

  late SearchableBottomBarController _controller;
  bool _ownsController = false;

  // Stable identity for the tab indicator. Without it the indicator's State is
  // torn down + recreated on every rebuild — which orphans a live press-hold
  // gesture mid-flight and freezes the bar (reproduced at standard/minimal over
  // an iOS PlatformView; the premium render path happens to avoid the churn). A
  // GlobalKey preserves the State across rebuilds AND across the
  // AdaptiveLiquidGlassLayer wrapper's quality-path reparenting.
  final GlobalKey _indicatorKey = GlobalKey();

  /// Lays out the tab [Row] in physical (LTR) order regardless of the ambient
  /// direction, so the first child is on the left — matching the indicator and
  /// gesture coordinate space. RTL ordering is carried by the reversed tab data
  /// in [_buildBar], not by the ambient direction of these Rows. Scoping the
  /// pin to the Rows keeps `Directionality.of(context)` intact for the rest of
  /// the subtree (notably [indicatorExpansion] / [tabPadding] resolution).
  static Widget _ltrTabRow({required List<Widget> children}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(children: children),
    );
  }

  void _onControllerChanged() => setState(() {});

  // D1: whitenBoostCtrl still uses setState — it fires at most once per scroll-to-bottom
  // (200 ms easeOut, not a 120 Hz spring). Full rebuild cost is acceptable here.
  // The three spring controllers (_tabWCtrl, _searchLeftCtrl, _searchWCtrl) drive
  // ListenableBuilder widgets directly — no setState on spring ticks.
  void _onWhitenTick() => setState(() {});

  late AnimationController _tabWCtrl;
  late AnimationController _searchLeftCtrl;
  late AnimationController _searchWCtrl;
  late AnimationController _whitenBoostCtrl;
  double _whitenTarget = 0.0;

  // Appear/disappear scale for the search pill — 1 present, 0 gone.
  late AnimationController _pillScaleCtrl;

  GlassTabBarTrailingButton? _lastTrailingButton;

  /// Whether the trailing action or search pill exists.
  bool get _pillShown {
    if (widget.searchConfig != null) {
      return widget.searchConfig!.showPill;
    }
    return widget.trailingButton != null;
  }

  // D1: hoisted — avoids allocating a new _MergedListenable on every LayoutBuilder call.
  late Listenable _searchPillListenable;

  @override
  void initState() {
    super.initState();
    if (widget.trailingButton != null) {
      _lastTrailingButton = widget.trailingButton;
    }
    // searchConfig and trailingButton are mutually exclusive rendering paths:
    // searchConfig → SearchPill (text field, focus machinery, cancel pill)
    // trailingButton → MinimizableTrailingPill (icon-only, no search machinery)
    // Passing both is a misconfiguration — trailingButton would be silently ignored.
    assert(
      widget.searchConfig == null || widget.trailingButton == null,
      'TabBarSearchableLayout: searchConfig and trailingButton are mutually '
      'exclusive. Use searchConfig for GlassTabBar.searchable and '
      'trailingButton for GlassTabBar.minimizable.',
    );
    assert(
      widget.searchConfig?.collapsedTabWidth == null ||
          widget.searchConfig!.collapsedTabWidth! > 0,
      'GlassSearchBarConfig.collapsedTabWidth must be positive',
    );
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = SearchableBottomBarController();
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);

    // D1: no addListener — these controllers drive ListenableBuilder widgets directly.
    // Spring ticks rebuild only the single Positioned child they animate, not the
    // full State.build(). See the Stack children in _buildBar.
    _tabWCtrl = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
    _searchLeftCtrl = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
    _searchWCtrl = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
    _whitenBoostCtrl = AnimationController(vsync: this)
      ..addListener(_onWhitenTick);
    // Starts settled — a pill that should be absent right now was never on
    // screen to animate away.
    _pillScaleCtrl = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
      value: _pillShown ? 1.0 : 0.0,
    );
    // D1: create once — the controllers never change after initState.
    _searchPillListenable =
        Listenable.merge([_searchLeftCtrl, _searchWCtrl, _pillScaleCtrl]);
    widget.scrollController?.addListener(_onScrollMaybeWhiten);
    widget.minimizeController?.attach(widget.scrollController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScrollMaybeWhiten();
    });
  }

  @override
  void didUpdateWidget(covariant TabBarSearchableLayout old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) _controller.dispose();
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = SearchableBottomBarController();
        _ownsController = true;
      }
      _controller.addListener(_onControllerChanged);
    }
    if (widget.scrollController != old.scrollController) {
      old.scrollController?.removeListener(_onScrollMaybeWhiten);
      widget.scrollController?.addListener(_onScrollMaybeWhiten);
      _onScrollMaybeWhiten();
    }
    // Both controllers can change independently. Handle the minimize
    // controller swap first so a re-attach uses the CURRENT scroll controller;
    // attach() itself is idempotent on identity and re-baselines either way.
    if (widget.minimizeController != old.minimizeController) {
      old.minimizeController?.detach();
      widget.minimizeController?.attach(widget.scrollController);
    } else if (widget.scrollController != old.scrollController) {
      widget.minimizeController?.attach(widget.scrollController);
    }
    if (widget.trailingButton != null) {
      _lastTrailingButton = widget.trailingButton;
    }
    _controller.onSearchActiveChanged(
      wasActive: old.isSearchActive,
      isActive: widget.isSearchActive,
    );
    // Spring the pill's appear/disappear scale when its presence changes.
    final oldPillShown = old.searchConfig != null
        ? old.searchConfig!.showPill
        : old.trailingButton != null;
    if (oldPillShown != _pillShown) {
      // Reduce Motion: the pill appears and goes without the spring.
      if (GlassAccessibilityData.of(context).reduceMotion) {
        _pillScaleCtrl.value = _pillShown ? 1.0 : 0.0;
        return;
      }
      _pillScaleCtrl.animateWith(
        SearchableBottomBarController.makeSpring(
          spring: widget.springDescription ?? TabBarSearchableLayout._kSpring,
          from: _pillScaleCtrl.value,
          to: _pillShown ? 1.0 : 0.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabWCtrl.dispose();
    _searchLeftCtrl.dispose();
    _searchWCtrl.dispose();
    _pillScaleCtrl.dispose();
    widget.scrollController?.removeListener(_onScrollMaybeWhiten);
    // Detach, never dispose — the minimize controller belongs to the app.
    widget.minimizeController?.detach();
    _whitenBoostCtrl.dispose();
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onFocusLost() => _controller.onFocusChanged(false);

  void _onScrollMaybeWhiten() {
    final c = widget.scrollController;
    // hasClients alone is not enough: ScrollController.position asserts when
    // more than one scroll view is attached, which happens for a few hundred
    // milliseconds whenever two of them share a controller across an
    // AnimatedSwitcher cross-fade or a Navigator transition. Skip those frames
    // rather than crashing — GlassScaffold guards its header fade the same way.
    final p = (c != null && c.hasClients && c.positions.length == 1)
        ? c.positions.single
        : null;
    final atBottom = widget.whitenAtBottom &&
        p != null &&
        p.maxScrollExtent > 0 &&
        (p.maxScrollExtent - p.pixels) <= widget.whitenBottomThreshold;
    final target = atBottom ? 1.0 : 0.0;
    if (_whitenTarget != target) {
      _whitenTarget = target;
      _whitenBoostCtrl.animateTo(target,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  LiquidGlassSettings _applyWhiten(LiquidGlassSettings s, bool isLight) {
    final base = s.whitenStrength;
    final t = (widget.whitenAtBottom && isLight) ? _whitenBoostCtrl.value : 0.0;
    final eff = (base + (widget.whitenAtBottomTarget - base) * t)
        .clamp(0.0, 1.0)
        .toDouble();
    return s.copyWith(whitenStrength: eff);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.adaptiveBrightness && widget.brightnessOverride == null) {
      return _buildBar(context, null);
    }
    return GlassContentAwareBrightness(
      brightnessOverride: widget.brightnessOverride,
      onBrightnessChanged: widget.onBrightnessChanged,
      builder: (context, brightness, darkAmount) =>
          _buildBar(context, darkAmount),
    );
  }

  Widget _buildBar(BuildContext context, double? darkAmount) {
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
      fallback: GlassQuality.premium,
    );
    final effectiveBackgroundQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.backgroundQuality ?? widget.quality,
      fallback: GlassQuality.premium,
    );

    final resolvedGlowColors =
        GlassThemeData.of(context).glowColorsFor(context);
    // A null radius asks for native mode — the same resolution the bottom bar
    // runs, through the same helper, so the two cannot drift apart again.
    final glow = resolveTabBarInteractionGlow(
      interactionGlowRadius: widget.interactionGlowRadius,
      interactionGlowColor: widget.interactionGlowColor,
      themeGlowColor: resolvedGlowColors.primary,
      themeGlowBlurRadius: resolvedGlowColors.glowBlurRadius,
      isDark: GlassTheme.brightnessOf(context) == Brightness.dark,
    );
    final effectiveInteractionGlowColor = glow.color;

    final dynamicLabelColor = resolveBarLabelColor(context, darkAmount);
    final resolvedSelectedIconColor =
        widget.selectedIconColor ?? dynamicLabelColor;
    final resolvedUnselectedIconColor =
        widget.unselectedIconColor ?? dynamicLabelColor;
    // A minimized bar still shows its selected tab; a searching one shows the
    // tab search was opened from, which the search has since replaced.
    final resolvedCollapsedIconColor = widget.isMinimizablePlacement
        ? resolvedSelectedIconColor
        : resolvedUnselectedIconColor;

    // Native mode owns the blur: the radius and the falloff are one
    // calibration. Everything else stays the theme's.
    final effectiveGlowBlurRadius = glow.blurRadius;
    final effectiveGlowSpreadRadius = resolvedGlowColors.glowSpreadRadius;
    final effectiveGlowOpacity = resolvedGlowColors.glowOpacity;

    final bool isLight = GlassTheme.brightnessOf(context) == Brightness.light;
    final effectiveSettings =
        _applyWhiten(widget.settings ?? _defaultGlassSettings, isLight);
    final searching = widget.isSearchActive;

    // RTL support.
    //
    // The indicator/gesture coordinate system and the [AnimatedGlassIndicator]
    // position both operate in physical, left-anchored alignment space (x == -1
    // is always the left edge), and the gesture math is derived from the render
    // box geometry — all direction-independent. The only direction-sensitive
    // part is the two tab [Row]s, which honour the ambient [Directionality] and
    // visually reverse under RTL. That reversal is what disagrees with the
    // physical coordinate space, so the pill — and the tap/drag hit-testing —
    // land on the mirror-image tab.
    //
    // Normalise by reversing the tab data and mirroring the selected index and
    // the tap callback, then pin *only* the tab Rows to LTR (see [_ltrTabRow])
    // so their physical order matches the coordinate space. Net effect under
    // RTL: correct ordering (the first tab sits on the trailing/right edge)
    // with the pill and hit-testing aligned to it. In LTR everything is a
    // no-op.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final tabs = isRtl ? widget.tabs.reversed.toList() : widget.tabs;
    final selectedIndex = isRtl
        ? widget.tabs.length - 1 - widget.selectedIndex
        : widget.selectedIndex;
    final onTabSelected = isRtl
        ? (int i) => widget.onTabSelected(widget.tabs.length - 1 - i)
        : widget.onTabSelected;
    // The interactive buttons/pills render the even GlassButton press lift
    // unless the glow was customised — per widget or through the theme's glowColors.
    final themeGlowPrimary =
        GlassThemeData.of(context).variantFor(context).glowColors?.primary;
    final nativePressHighlight = widget.interactionGlowColor == null &&
        themeGlowPrimary == null &&
        widget.interactionBehavior.hasGlow;

    Widget barContent = TweenAnimationBuilder<double>(
      tween: Tween<double>(
          end: searching ? widget.searchBarHeight : widget.barHeight),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, animH, child) {
        return AdaptiveLiquidGlassLayer(
          settings: effectiveSettings,
          quality: effectiveQuality,
          platformViewBackdrop: widget.platformViewBackdrop,
          blendAmount: widget.enableBlend ? widget.blendAmount : 0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding,
              vertical: widget.verticalPadding,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalW = constraints.maxWidth;

                final keyboardH = MediaQuery.viewInsetsOf(context).bottom;
                final keyboardPresent = keyboardH > 0;
                final isKeyboardActive =
                    _controller.searchFocused && keyboardPresent;

                final extraPos = widget.extraButton?.position ??
                    GlassExtraButtonPosition.beforeSearch;
                final extraFullW = widget.extraButton?.size ?? 0.0;
                final extraCollapsesOnSearch =
                    widget.extraButton?.collapseOnSearchFocus ?? true;
                final hasDismiss =
                    widget.searchConfig?.showsCancelButton ?? false;
                final dismissVisible = searching &&
                    _controller.searchFocused &&
                    hasDismiss &&
                    keyboardPresent;

                final layout = _controller.computeLayout(
                  totalW: totalW,
                  searching: widget.isSearchActive,
                  expandWhenActive:
                      widget.searchConfig?.expandWhenActive ?? false,
                  barHeight: widget.barHeight,
                  searchBarHeight: widget.searchBarHeight,
                  spacing: widget.spacing,
                  hasDismiss: hasDismiss,
                  dismissVisible: dismissVisible,
                  collapsedTabWidth: widget.searchConfig?.collapsedTabWidth,
                  tabPillAnchor: widget.tabPillAnchor,
                  extraFullW: extraFullW,
                  extraPos: extraPos,
                  extraCollapsesOnSearch: extraCollapsesOnSearch,
                  isKeyboardActive: isKeyboardActive,
                  keyboardH: keyboardH,
                  tabCount: widget.tabs.length,
                  perTabWidth: widget.tabWidth,
                  showPill: _pillShown,
                );

                final targetTabW = layout.targetTabW;
                final targetSearchLeft = layout.targetSearchLeft;
                final targetSearchW = layout.targetSearchW;
                final targetH =
                    searching ? widget.searchBarHeight : widget.barHeight;
                final extraTargetW = layout.extraTargetW;
                final extraWLeft = (extraFullW > 0 &&
                        extraPos == GlassExtraButtonPosition.beforeSearch)
                    ? (extraTargetW + widget.spacing)
                    : 0.0;
                final doCollapseLayout =
                    isKeyboardActive && extraCollapsesOnSearch;
                final targetDismissReserve = layout.dismissReserve;
                final centeredTab =
                    widget.tabPillAnchor == GlassTabPillAnchor.center;
                // Mirrors computeLayout — an absent pill reserves nothing.
                final maxTabW = totalW -
                    (_pillShown ? targetH + widget.spacing : 0.0) -
                    (extraFullW > 0 &&
                            extraPos == GlassExtraButtonPosition.beforeSearch
                        ? extraFullW + widget.spacing
                        : 0.0) -
                    (extraFullW > 0 &&
                            extraPos == GlassExtraButtonPosition.afterSearch
                        ? extraFullW + widget.spacing
                        : 0.0);

                if (!_controller.pillsInitialized &&
                    !_controller.pillsInitScheduled) {
                  _controller.markInitScheduled(totalW: totalW);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _tabWCtrl.value = targetTabW;
                    _searchLeftCtrl.value = targetSearchLeft;
                    _searchWCtrl.value = targetSearchW;
                    _controller.initializePills(
                      tabW: targetTabW,
                      searchLeft: targetSearchLeft,
                      searchW: targetSearchW,
                    );
                  });
                } else if (_controller.pillsInitialized) {
                  final retarget = _controller.checkRetarget(layout);
                  if (retarget.any) {
                    final toTabW = targetTabW;
                    final toLeft = targetSearchLeft;
                    final toSearchW = targetSearchW;
                    // Read during build: the callback below runs after the
                    // frame, where an inherited lookup no longer belongs.
                    final reduceMotion =
                        GlassAccessibilityData.of(context).reduceMotion;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      // Reduce Motion: the pills take their new widths and
                      // positions at once instead of springing across.
                      if (reduceMotion) {
                        if (retarget.tabW) _tabWCtrl.value = toTabW;
                        if (retarget.searchLeft) {
                          _searchLeftCtrl.value = toLeft;
                        }
                        if (retarget.searchW) _searchWCtrl.value = toSearchW;
                        return;
                      }
                      final spring = widget.springDescription ??
                          TabBarSearchableLayout._kSpring;
                      // Read `from` and the in-flight velocity HERE, not during
                      // build: any still-running simulation ticks once more
                      // between the two, so a value captured in build would
                      // start the new spring a frame behind — visible when a
                      // morph reverses at peak speed.
                      if (retarget.tabW) {
                        _tabWCtrl.animateWith(
                            SearchableBottomBarController.makeSpring(
                                spring: spring,
                                from: _tabWCtrl.value,
                                to: toTabW,
                                velocity: _tabWCtrl.velocity));
                      }
                      if (retarget.searchLeft) {
                        _searchLeftCtrl.animateWith(
                            SearchableBottomBarController.makeSpring(
                                spring: spring,
                                from: _searchLeftCtrl.value,
                                to: toLeft,
                                velocity: _searchLeftCtrl.velocity));
                      }
                      if (retarget.searchW) {
                        _searchWCtrl.animateWith(
                            SearchableBottomBarController.makeSpring(
                                spring: spring,
                                from: _searchWCtrl.value,
                                to: toSearchW,
                                velocity: _searchWCtrl.velocity));
                      }
                    });
                  }
                  if (totalW != _controller.cachedTotalW) {
                    _controller.cachedTotalW = totalW;
                  }
                }

                // D1: curTabW, curTabLeft, curSearchLeft, curSearchW are now computed
                // inside their respective ListenableBuilder builders below, so each
                // Positioned child reads a fresh controller value on its own tick
                // without involving the enclosing LayoutBuilder or State.build().

                final floatY = layout.floatY;
                final totalH = animH + floatY;

                return SizedBox(
                  width: totalW,
                  height: totalH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Search pill / Trailing Action Pill — D1: left/width track spring controllers.
                      ListenableBuilder(
                        listenable: _searchPillListenable,
                        builder: (context, _) {
                          final pillScale =
                              _pillScaleCtrl.value.clamp(0.0, 1.25).toDouble();
                          if (pillScale < 0.02) {
                            return const SizedBox.shrink();
                          }
                          final curSearchLeft = (_controller.pillsInitialized
                                  ? _searchLeftCtrl.value
                                  : targetSearchLeft)
                              .clamp(0.0, totalW);
                          final curSearchW = (_controller.pillsInitialized
                                  ? _searchWCtrl.value
                                  : targetSearchW)
                              .clamp(0.0, totalW);

                          final Widget pillChild;
                          if (widget.searchConfig != null) {
                            pillChild = SearchPill(
                              config: widget.searchConfig!,
                              nativePressHighlight: nativePressHighlight,
                              isActive: searching,
                              barBorderRadius: widget.barBorderRadius,
                              // Chrome-plane peer: matches the track background,
                              // not the indicator pill (effectiveQuality).
                              quality: effectiveBackgroundQuality,
                              platformViewBackdrop: widget.platformViewBackdrop,
                              enableBackgroundAnimation:
                                  widget.interactionBehavior.hasScale,
                              backgroundPressScale: widget.pressScale,
                              iconColor: resolvedUnselectedIconColor,
                              interactionGlowColor:
                                  widget.interactionBehavior.hasGlow
                                      ? effectiveInteractionGlowColor
                                      : const Color(0x00000000),
                              interactionGlowRadius: glow.radius,
                              interactionGlowBlurRadius:
                                  effectiveGlowBlurRadius,
                              interactionGlowSpreadRadius:
                                  effectiveGlowSpreadRadius,
                              interactionGlowOpacity: effectiveGlowOpacity,
                              onFocusChanged: (focused) {
                                if (focused) {
                                  _controller.onFocusChanged(true);
                                } else {
                                  _onFocusLost();
                                }
                                widget.searchConfig?.onSearchFocusChanged
                                    ?.call(focused);
                              },
                            );
                          } else {
                            final renderedTrailing =
                                widget.trailingButton ?? _lastTrailingButton;

                            Widget buildTrailingPill({VoidCallback? onTap}) {
                              return MinimizableTrailingPill(
                                icon: renderedTrailing?.icon,
                                nativePressHighlight: nativePressHighlight,
                                onTap: onTap,
                                label: renderedTrailing?.label,
                                barBorderRadius: widget.barBorderRadius,
                                // Chrome-plane peer: matches the track background,
                                // not the indicator pill (effectiveQuality).
                                quality: effectiveBackgroundQuality,
                                platformViewBackdrop:
                                    widget.platformViewBackdrop,
                                enableBackgroundAnimation:
                                    widget.interactionBehavior.hasScale,
                                backgroundPressScale: widget.pressScale,
                                iconColor: resolvedUnselectedIconColor,
                                interactionGlowColor:
                                    widget.interactionBehavior.hasGlow
                                        ? effectiveInteractionGlowColor
                                        : const Color(0x00000000),
                                interactionGlowRadius: glow.radius,
                                interactionGlowBlurRadius:
                                    effectiveGlowBlurRadius,
                                interactionGlowSpreadRadius:
                                    effectiveGlowSpreadRadius,
                                interactionGlowOpacity: effectiveGlowOpacity,
                              );
                            }

                            if (renderedTrailing?.isMenu == true) {
                              pillChild = GlassMenu(
                                menuAlignment: renderedTrailing!.menuAlignment,
                                menuWidth: renderedTrailing.menuWidth,
                                menuHeight: renderedTrailing.menuHeight,
                                autoAdjustToScreen: true,
                                items: renderedTrailing.menuItems!,
                                triggerBuilder: (context, toggleMenu) =>
                                    buildTrailingPill(
                                  onTap: renderedTrailing.enabled
                                      ? toggleMenu
                                      : null,
                                ),
                              );
                            } else {
                              pillChild = buildTrailingPill(
                                onTap: (renderedTrailing?.enabled == true)
                                    ? widget.trailingButton?.onTap
                                    : null,
                              );
                            }
                          }

                          return Positioned(
                            left: curSearchLeft,
                            bottom: floatY,
                            width: math.max(0.01, curSearchW),
                            height: animH,
                            child: IgnorePointer(
                              ignoring: !_pillShown,
                              child: Transform.scale(
                                scale: pillScale,
                                // While the keyboard is up or moving, the
                                // pill spans the bar and rides above the tab
                                // pill, which paints after it: glass over
                                // glass, so it leaves the bar's group.
                                child: GlassBackdropGroup(
                                  enabled: !_controller.searchFocused &&
                                      !keyboardPresent,
                                  child: pillChild,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // 2. Optional extra button — D1: left position tracks _searchLeftCtrl.
                      if (widget.extraButton != null)
                        ListenableBuilder(
                          listenable: _searchLeftCtrl,
                          builder: (context, _) {
                            final curSearchLeft = (_controller.pillsInitialized
                                    ? _searchLeftCtrl.value
                                    : targetSearchLeft)
                                .clamp(0.0, totalW);
                            return Positioned(
                              left: extraPos ==
                                      GlassExtraButtonPosition.beforeSearch
                                  ? curSearchLeft - extraWLeft
                                  : null,
                              right: extraPos ==
                                      GlassExtraButtonPosition.afterSearch
                                  ? (dismissVisible
                                      ? targetDismissReserve
                                      : 0.0)
                                  : null,
                              bottom: extraCollapsesOnSearch ? 0 : floatY,
                              width: doCollapseLayout
                                  ? math.min(extraTargetW, animH)
                                  : extraTargetW,
                              height: animH,
                              child: AnimatedOpacity(
                                opacity: (searching && extraCollapsesOnSearch)
                                    ? 0.0
                                    : 1.0,
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                child: IgnorePointer(
                                  ignoring: searching && extraCollapsesOnSearch,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: BottomBarExtraBtn(
                                      config: widget.extraButton!,
                                      // Chrome-plane peer: matches the track background,
                                      // not the indicator pill (effectiveQuality).
                                      quality: effectiveBackgroundQuality,
                                      iconColor:
                                          widget.extraButton!.iconColor ??
                                              resolvedUnselectedIconColor,
                                      enableBlend: widget.enableBlend,
                                      borderRadius: widget.barBorderRadius ==
                                              TabBarSearchableLayout
                                                  ._kDefaultBorderRadius
                                          ? null
                                          : widget.barBorderRadius,
                                      platformViewBackdrop:
                                          widget.platformViewBackdrop,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      // 3. Tab pill — D1: rebuilt only when _tabWCtrl ticks.
                      //    childUnselected is passed as ListenableBuilder.child so the
                      //    unselected row is built once and reused across spring ticks.
                      ListenableBuilder(
                        listenable: _tabWCtrl,
                        child: _buildTabRow(
                          tabs: tabs,
                          selectedIndex: selectedIndex,
                          onTabSelected: onTabSelected,
                          selected: false,
                          resolvedSelectedIconColor: resolvedSelectedIconColor,
                          resolvedUnselectedIconColor:
                              resolvedUnselectedIconColor,
                        ),
                        builder: (context, child) {
                          final curTabW = (_controller.pillsInitialized
                                  ? _tabWCtrl.value
                                  : targetTabW)
                              .clamp(0.0, totalW);
                          final curTabLeft = centeredTab
                              ? ((maxTabW - curTabW) / 2).clamp(0.0, maxTabW)
                              : 0.0;
                          return Positioned(
                            left: curTabLeft,
                            bottom: 0,
                            width: math.max(0.01, curTabW),
                            height: animH,
                            child: SearchableTabIndicator(
                              key: _indicatorKey,
                              quality: effectiveQuality,
                              backgroundQuality: effectiveBackgroundQuality,
                              visible: widget.showIndicator && !searching,
                              tabIndex: selectedIndex,
                              tabCount: tabs.length,
                              onTabChanged: onTabSelected,
                              barHeight: animH,
                              barBorderRadius: widget.barBorderRadius,
                              indicatorBorderRadius:
                                  widget.indicatorBorderRadius,
                              tabPadding: widget.tabPadding,
                              maskingQuality: widget.maskingQuality,
                              magnification: widget.magnification,
                              innerBlur: widget.innerBlur,
                              indicatorColor: widget.indicatorColor,
                              indicatorExpansion: widget.indicatorExpansion,
                              indicatorSettings: widget.indicatorSettings,
                              indicatorPinchStrength:
                                  widget.indicatorPinchStrength,
                              backgroundKey: widget.backgroundKey,
                              platformViewBackdrop: widget.platformViewBackdrop,
                              passthroughOverPlatformView:
                                  widget.passthroughOverPlatformView,
                              isSearchActive: searching,
                              collapsedSemanticLabel:
                                  tabs[selectedIndex].semanticLabel ??
                                      tabs[selectedIndex].label,
                              nativePressHighlight: nativePressHighlight,
                              interactionGlowColor:
                                  widget.interactionBehavior.hasGlow
                                      ? effectiveInteractionGlowColor
                                      : const Color(0x00000000),
                              interactionGlowRadius: glow.radius,
                              interactionGlowBlurRadius:
                                  effectiveGlowBlurRadius,
                              interactionGlowSpreadRadius:
                                  effectiveGlowSpreadRadius,
                              interactionGlowOpacity: effectiveGlowOpacity,
                              enableBackgroundAnimation:
                                  widget.interactionBehavior.hasScale,
                              backgroundPressScale: widget.pressScale,
                              collapsedLogoBuilder:
                                  widget.searchConfig?.collapsedLogoBuilder ??
                                      (context) {
                                        final currentTab = tabs[selectedIndex];
                                        return Center(
                                          child: IconTheme(
                                            data: IconThemeData(
                                              color: resolvedCollapsedIconColor,
                                              size: widget.iconSize,
                                            ),
                                            child: currentTab.activeIcon ??
                                                currentTab.icon ??
                                                const SizedBox.shrink(),
                                          ),
                                        );
                                      },
                              onDismissSearch: () {
                                if (widget.onMinimizedTabTap != null) {
                                  widget.onMinimizedTabTap!();
                                } else {
                                  widget.searchConfig?.onSearchToggle(false);
                                }
                              },
                              childUnselected: child!,
                              selectedTabBuilder: (ctx, intensity, alignment) =>
                                  _buildTabRow(
                                tabs: tabs,
                                selectedIndex: selectedIndex,
                                onTabSelected: onTabSelected,
                                selected: true,
                                intensity: intensity,
                                alignment: alignment,
                                resolvedSelectedIconColor:
                                    resolvedSelectedIconColor,
                                resolvedUnselectedIconColor:
                                    resolvedUnselectedIconColor,
                              ),
                            ),
                          );
                        },
                      ),

                      // 4. Dismiss × pill
                      if (hasDismiss &&
                          dismissVisible &&
                          widget.searchConfig != null)
                        Positioned(
                          right: 0,
                          bottom: floatY,
                          width: animH,
                          height: animH,
                          child: DismissPill(
                            onTap: () {
                              widget.searchConfig?.onCancelTap?.call();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            pillSize: animH,
                            barBorderRadius: widget.barBorderRadius,
                            // Chrome-plane peer: matches the track background,
                            // not the indicator pill (effectiveQuality).
                            quality: effectiveBackgroundQuality,
                            indicatorColor: widget.indicatorColor,
                            settings: widget.settings,
                            cancelButtonColor:
                                widget.searchConfig!.cancelButtonColor,
                            cancelIcon: widget.searchConfig!.cancelIcon,
                            cancelIconSize: widget.searchConfig!.cancelIconSize,
                            semanticLabel:
                                widget.searchConfig!.cancelButtonSemanticLabel,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (widget.bottomAccessory != null) {
      // Phase 2 — iOS 26 tabViewBottomAccessory inline/expanded layout.
      //
      // Expanded state (searching == false):
      //   Column: [accessory widget above] → [glass pill below]
      //   The accessory is positioned above the pill with bottomAccessorySpacing gap.
      //
      // Inline state (searching == true / mini-mode):
      //   Stack: the glass pill animates to searchBarHeight (handled by
      //   TweenAnimationBuilder inside barContent). The accessory slides from
      //   above-the-pill to beside-the-pill at the same vertical level, filling
      //   the horizontal space to the right of the collapsed search capsule.
      //   This exactly mirrors Apple's "tabViewBottomAccessory(.inline)" behaviour.
      //
      // Inline positions are derived from widget constants (horizontalPadding,
      // collapsedTabWidth, searchBarHeight) — no GlobalKey measurement needed.
      final accessoryH = widget.bottomAccessoryHeight ?? 0.0;

      // The collapsed (search-active) bar height as it appears visually — the
      // glass pill shrinks from barHeight → searchBarHeight.
      // We add verticalPadding *2 to match the Padding inside AdaptiveLiquidGlassLayer.
      final pillH = widget.barHeight + widget.verticalPadding * 2;
      final collapsedPillH =
          widget.searchBarHeight + widget.verticalPadding * 2;

      // When inline, the accessory sits exactly between the collapsed tab pill (left)
      // and the collapsed search capsule (right).
      final collapsedTabW =
          widget.searchConfig?.collapsedTabWidth ?? widget.searchBarHeight;
      final inlineAccessoryLeft = widget.horizontalPadding +
          collapsedTabW +
          widget.bottomAccessorySpacing;
      // Only reserve the trailing capsule's slot when there is one to reserve.
      final inlineAccessoryRight = _pillShown
          ? widget.horizontalPadding +
              widget.searchBarHeight +
              widget.bottomAccessorySpacing
          : widget.horizontalPadding;

      // Total height of the combined widget.
      // Jumps instantly with `searching` to match `preferredSize` changes.
      // When tabs (148), when search (134).
      final expandedH = (searching
              ? collapsedPillH - (pillH - collapsedPillH)
              : collapsedPillH) +
          widget.bottomAccessorySpacing +
          accessoryH;

      final innerBarContent = barContent;

      // Must resolve identically to GlassTabBar.preferredSize's call, or the
      // scaffold reserves a height this engine does not draw.
      final accessoryInline = resolveAccessoryPlacement(
            explicit: widget.bottomAccessoryPlacement,
            minimized: searching,
            isMinimizablePlacement: widget.isMinimizablePlacement,
          ) ==
          GlassTabBarAccessoryPlacement.inline;

      barContent = GlassTabBarAccessoryPlacementScope(
        placement: accessoryInline
            ? GlassTabBarAccessoryPlacement.inline
            : GlassTabBarAccessoryPlacement.expanded,
        // Two independent TweenAnimationBuilders drive two independent axes:
        //
        //   accessoryT (outer): drives the CONTAINER height, accessory
        //     left/right width, and coarse vertical position. Controlled by
        //     `accessoryInline` — 0.0 means expanded above the pill, 1.0 means
        //     inline beside the pill.
        //
        //   searchT (inner): tracks the search bar morphing. Used to compute
        //     the live `expandedBottom` so the play pill moves down as the bar
        //     shrinks, maintaining a perfect 6px overlap with the top of the glass.
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: accessoryInline ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, accessoryT, _) {
            // Outer container height follows the ACCESSORY state.
            final height =
                ui.lerpDouble(expandedH, collapsedPillH, accessoryT)!;

            // Accessory left/right: constant when expanded, narrows when inline.
            final accessoryLeft = ui.lerpDouble(
              widget.horizontalPadding,
              inlineAccessoryLeft,
              accessoryT,
            )!;
            final accessoryRight = ui.lerpDouble(
              widget.horizontalPadding,
              inlineAccessoryRight,
              accessoryT,
            )!;

            return SizedBox(
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Accessory: position/width driven by accessoryT AND searchT.
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: searching ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    builder: (context, searchT, _) {
                      // Move down by 14px (= pillH - collapsedPillH) when searching
                      final expandedBottom = ui.lerpDouble(
                        collapsedPillH + widget.bottomAccessorySpacing,
                        collapsedPillH +
                            widget.bottomAccessorySpacing -
                            (pillH - collapsedPillH),
                        searchT,
                      )!;

                      return Positioned(
                        left: accessoryLeft,
                        right: accessoryRight,
                        bottom: ui.lerpDouble(
                          expandedBottom,
                          (collapsedPillH - accessoryH) / 2,
                          accessoryT,
                        )!,
                        height: accessoryH,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          opacity: widget.bottomAccessoryEnabled ? 1.0 : 0.0,
                          // The accessory overlaps the pill's top edge, so
                          // glass in it stays out of the bar's group.
                          child: GlassBackdropGroup(
                            enabled: false,
                            child: widget.bottomAccessory!,
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Glass pill: anchored to bottom. Its height is managed
                  //    internally by the animH TweenAnimationBuilder inside
                  //    barContent (searching → searchBarHeight morph). ────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: innerBarContent,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (widget.onBarTap == null) return barContent;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onBarTap,
      child: barContent,
    );
  }

  Widget _buildTabRow({
    required List<GlassTab> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    required bool selected,
    required Color resolvedSelectedIconColor,
    required Color resolvedUnselectedIconColor,
    double intensity = 0,
    Alignment alignment = Alignment.center,
  }) {
    if (selected) {
      final scale = ui.lerpDouble(1.0, widget.magnification, intensity) ?? 1.0;
      final currentTabFloat = ((alignment.x + 1) / 2) * tabs.length;
      final aStart = (currentTabFloat - 1).floor().clamp(0, tabs.length - 1);
      final aEnd = (currentTabFloat + 1).ceil().clamp(0, tabs.length - 1);

      return ExcludeSemantics(
        child: _ltrTabRow(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: (i >= aStart && i <= aEnd)
                    ? Transform.scale(
                        scale: scale,
                        child: BottomBarTabItem(
                          tab: tabs[i],
                          selected: true,
                          selectedIconColor: resolvedSelectedIconColor,
                          unselectedIconColor: resolvedUnselectedIconColor,
                          selectedLabelColor: widget.selectedLabelColor,
                          unselectedLabelColor: widget.unselectedLabelColor,
                          selectedLabelStyle: widget.selectedLabelStyle,
                          unselectedLabelStyle: widget.unselectedLabelStyle,
                          iconSize: widget.iconSize,
                          labelFontSize: widget.labelFontSize,
                          textStyle: widget.textStyle,
                          iconLabelSpacing: widget.iconLabelSpacing,
                          glowDuration: widget.glowDuration,
                          glowBlurRadius: widget.glowBlurRadius,
                          glowSpreadRadius: widget.glowSpreadRadius,
                          glowOpacity: widget.glowOpacity,
                          onTap: null,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      );
    }

    return _ltrTabRow(
      children: [
        for (var i = 0; i < tabs.length; i++)
          Expanded(
            child: BottomBarTabItem(
              tab: tabs[i],
              selected: false,
              semanticsSelected: i == selectedIndex,
              selectedIconColor: resolvedSelectedIconColor,
              unselectedIconColor: resolvedUnselectedIconColor,
              selectedLabelColor: widget.selectedLabelColor,
              unselectedLabelColor: widget.unselectedLabelColor,
              selectedLabelStyle: widget.selectedLabelStyle,
              unselectedLabelStyle: widget.unselectedLabelStyle,
              iconSize: widget.iconSize,
              labelFontSize: widget.labelFontSize,
              textStyle: widget.textStyle,
              iconLabelSpacing: widget.iconLabelSpacing,
              glowDuration: widget.glowDuration,
              glowBlurRadius: widget.glowBlurRadius,
              glowSpreadRadius: widget.glowSpreadRadius,
              glowOpacity: widget.glowOpacity,
              onTap: null,
              // Pointer selection stays with the indicator; this is the tap
              // action a screen reader and the keyboard activate.
              semanticOnTap: () => onTabSelected(i),
            ),
          ),
      ],
    );
  }
}
