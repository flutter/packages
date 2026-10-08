import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

import '../../constants/glass_defaults.dart';
import '../../src/renderer/glass_backdrop_group.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../src/types/glass_interaction_behavior.dart';
import '../../types/glass_quality.dart';
import '../overlays/glass_menu.dart' show GlassMenuAlignment;
import '../shared/inherited_liquid_glass.dart';
import 'shared/glass_search_bar_config.dart';
import 'shared/tab_bar_accessory_placement.dart';
import 'shared/tab_bar_extra_button.dart';
import 'shared/tab_bar_minimize_controller.dart';
import 'shared/tab_bar_searchable_controller.dart';
import 'shared/tab_bar_types.dart';
import '../../src/widgets/surfaces/dynamic_preferred_size.dart';
import '../../src/widgets/surfaces/tab_bar_bottom_layout.dart';
import '../../src/widgets/surfaces/tab_bar_searchable_layout.dart';
import '../../src/widgets/surfaces/tab_bar_vertical_layout.dart';
import 'glass_navigation_shell.dart';
import 'glass_vertical_bar.dart';

export 'shared/glass_bar_minimize_behavior.dart';
export 'shared/glass_search_bar_config.dart';
export 'shared/tab_bar_accessory_placement.dart';
export 'shared/tab_bar_minimize_controller.dart';
export 'shared/tab_bar_extra_button.dart'
    show
        GlassTabBarExtraButton,
        GlassExtraButtonPlacement,
        GlassExtraButtonPosition;
export 'shared/tab_bar_types.dart'
    show GlassTabPillAnchor, JellyClipper, MaskingQuality;

/// The iOS 26 structural navigation bar widget.
///
/// [GlassTabBar] covers three placement contexts via named constructors:
///
/// - **[GlassTabBar.bottom]** — floating glass pill at the bottom of the screen.
///   Mirrors Apple's `UITabBarController`.
/// - **[GlassTabBar.searchable]** — bottom pill that morphs into a search bar.
/// - **[GlassTabBar.inline]** — compact, in-page glass tab bar with a refracting
///   `AdaptiveGlass.grouped` track. Use this when you need a glass-backed content
///   switcher (e.g. Apple Music-style section picker). For a flat native-fidelity
///   filter control, use [GlassSegmentedControl] instead.
///
/// ## Constructors
///
/// | Constructor | iOS equivalent | Use-case |
/// |---|---|---|
/// | [GlassTabBar.bottom] | `UITabBar` | App-level bottom navigation |
/// | [GlassTabBar.searchable] | `UITabBar` + search | Bottom nav + morphing search bar |
/// | [GlassTabBar.minimizable] | `tabBarMinimizeBehavior` + `Tab(role: .search)` | Bottom nav that minimizes to the selected tab, with an optional trailing action button |
/// | [GlassTabBar.inline] | Glass-backed `UISegmentedControl` / inline `UITabBar` | In-page content switcher with glass track |
///
/// ## Usage
///
/// ### Bottom navigation bar
/// ```dart
/// GlassTabBar.bottom(
///   tabs: [
///     GlassTab(icon: Icon(Icons.home),   label: 'Home'),
///     GlassTab(icon: Icon(Icons.search), label: 'Search'),
///     GlassTab(icon: Icon(Icons.person), label: 'Profile'),
///   ],
///   selectedIndex: _selectedIndex,
///   onTabSelected: (i) => setState(() => _selectedIndex = i),
/// )
/// ```
///
/// ### With morphing search bar
/// ```dart
/// GlassTabBar.searchable(
///   tabs: [
///     GlassTab(icon: Icon(Icons.home),   label: 'Home'),
///     GlassTab(icon: Icon(Icons.search), label: 'Search'),
///   ],
///   selectedIndex: _selectedIndex,
///   onTabSelected: (i) => setState(() => _selectedIndex = i),
///   searchBarConfig: GlassSearchBarConfig(hintText: 'Search...'),
///   controller: _controller,
/// )
/// ```
///
/// ### Minimizing on scroll, no search
/// ```dart
/// GlassTabBar.minimizable(
///   tabs: [
///     GlassTab(icon: Icon(Icons.home),   label: 'Home'),
///     GlassTab(icon: Icon(Icons.person), label: 'Profile'),
///   ],
///   selectedIndex: _selectedIndex,
///   onTabSelected: (i) => setState(() => _selectedIndex = i),
///   minimized: _scrolledDown,
///   onMinimizedTabTap: () => setState(() => _scrolledDown = false),
///   trailingButton: GlassTabBarTrailingButton(
///     icon: const Icon(CupertinoIcons.plus),
///     onTap: _openComposer,
///   ),
/// )
/// ```
///
/// ### Inline / in-page tab switching
/// ```dart
/// // ✅ Glass-backed track with jelly indicator — Apple Music style
/// GlassTabBar.inline(
///   tabs: const [
///     GlassTab(label: 'Timeline'),
///     GlassTab(label: 'Mentions'),
///   ],
///   selectedIndex: _selectedIndex,
///   onTabSelected: (i) => setState(() => _selectedIndex = i),
/// )
///
/// // ✅ Flat native UISegmentedControl fidelity — filter/mode selection
/// GlassSegmentedControl(
///   segments: const [
///     GlassSegment(label: 'Timeline'),
///     GlassSegment(label: 'Mentions'),
///   ],
///   selectedIndex: _selectedIndex,
///   onSegmentSelected: (i) => setState(() => _selectedIndex = i),
/// )
/// ```
// ---------------------------------------------------------------------------
// Placement discriminant — private, drives constructor dispatch
// ---------------------------------------------------------------------------
enum _GlassTabBarPlacement { bottom, searchable, minimizable, inline }

/// The iOS 26 structural bottom navigation bar.
///
/// Two named constructors cover the two `UITabBarController` use-cases:
///
/// - **[GlassTabBar.bottom]** — floating pill at the screen bottom with safe
///   area handling, jelly physics, and optional extra action button.
///   Replaces the legacy `GlassBottomBar`.
///
/// - **[GlassTabBar.searchable]** — bottom pill that morphs into a search bar.
///   Replaces the legacy `GlassSearchableBottomBar`.
///
/// - **[GlassTabBar.minimizable]** — the searchable placement's morph
///   without the search: the tab pill minimizes to the selected tab's
///   circle (typically on scroll), mirroring SwiftUI's
///   `tabBarMinimizeBehavior`, with an optional plain
///   [GlassTabBarTrailingButton] in the slot the search pill occupies —
///   the generalized `Tab(role: .search)` trailing circle, for bars whose
///   trailing affordance is an action rather than a search field.
///
/// For in-page / inline tab switching, use [GlassSegmentedControl] instead.
///
/// ## Migration from v0.x
///
/// ```dart
/// // BEFORE
/// GlassBottomBar(tabs: [...], ...)
/// GlassSearchableBottomBar(tabs: [...], searchConfig: ..., ...)
///
/// // AFTER
/// GlassTabBar.bottom(tabs: [...], ...)
/// GlassTabBar.searchable(tabs: [...], searchConfig: ..., ...)
/// ```
class GlassTabBar extends StatefulWidget with GlassDynamicPreferredSize {
  // ─── Bottom constructor ────────────────────────────────────────────────────

  /// Creates a floating bottom tab bar — the iOS 26 `UITabBarController` equivalent.
  ///
  /// This constructor replaces `GlassBottomBar` with identical
  /// parameter names and defaults. Existing `GlassBottomBar` code migrates by
  /// search-replacing `GlassBottomBar(` → `GlassTabBar.bottom(` and
  /// `GlassBottomBarTab(` → `GlassTab(`.
  ///
  /// ## Play-pill / mini-player accessory
  ///
  /// Pass a widget to [bottomAccessory] to render a persistent overlay (e.g. a
  /// mini-player) above the glass tab bar pill — identical to iOS 26's
  /// `tabViewBottomAccessory` modifier.
  ///
  /// Supply [bottomAccessoryHeight] so that [GlassScaffold] can include the
  /// accessory in its `effectiveBottomBarHeight` (via [preferredSize]) and
  /// correctly compute body edge-fades. If omitted the scroll area will be
  /// inset only by the pill height.
  ///
  /// Toggle visibility with [bottomAccessoryEnabled]: the accessory animates
  /// in/out with an `AnimatedSize` so there is no jump.
  const GlassTabBar.bottom({
    required List<GlassTab> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    Key? key,
    GlassTabBarExtraButton? extraButton,
    ScrollController? scrollController,
    Widget? bottomAccessory,
    bool bottomAccessoryEnabled = true,
    double bottomAccessorySpacing = 6.0,
    double? bottomAccessoryHeight,
    double spacing = 8,
    double horizontalPadding = 20,
    double verticalPadding = 20,
    double barHeight = 64,
    double barBorderRadius = _kDefaultBottomBorderRadius,
    EdgeInsetsGeometry tabPadding = const EdgeInsets.symmetric(horizontal: 4),
    double iconLabelSpacing = 4,
    bool enableBlend = true,
    bool groupBackdrop = true,
    double blendAmount = 10,
    LiquidGlassSettings? settings,
    bool showIndicator = true,
    Color? indicatorColor,
    LiquidGlassSettings? indicatorSettings,
    double indicatorPinchStrength = 0.4,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? selectedLabelColor,
    Color? unselectedLabelColor,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    double iconSize = 24,
    double labelFontSize = 11,
    TextStyle? textStyle,
    Duration glowDuration = const Duration(milliseconds: 300),
    double glowBlurRadius = 32,
    double glowSpreadRadius = 8,
    double glowOpacity = 0.6,
    GlassQuality? quality,
    GlassQuality? backgroundQuality,
    double magnification = 1.15,
    double innerBlur = 0.0,
    MaskingQuality maskingQuality = MaskingQuality.high,
    GlobalKey? backgroundKey,
    double? tabWidth,
    double? indicatorBorderRadius,
    EdgeInsetsGeometry indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    Color? interactionGlowColor,
    double? interactionGlowRadius,
    GlassInteractionBehavior interactionBehavior =
        GlassInteractionBehavior.full,
    double pressScale = 1.04,
    bool platformViewBackdrop = false,
    bool adaptiveBrightness = false,
    ValueChanged<Brightness>? onBrightnessChanged,
    ValueListenable<Brightness>? brightnessOverride,
  }) : this._(
          key: key,
          placement: _GlassTabBarPlacement.bottom,
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          extraButton: extraButton,
          scrollController: scrollController,
          bottomAccessory: bottomAccessory,
          bottomAccessoryEnabled: bottomAccessoryEnabled,
          bottomAccessorySpacing: bottomAccessorySpacing,
          bottomAccessoryHeight: bottomAccessoryHeight,
          spacing: spacing,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          barHeight: barHeight,
          barBorderRadius: barBorderRadius,
          tabPadding: tabPadding,
          iconLabelSpacing: iconLabelSpacing,
          enableBlend: enableBlend,
          groupBackdrop: groupBackdrop,
          blendAmount: blendAmount,
          settings: settings,
          showIndicator: showIndicator,
          indicatorColor: indicatorColor,
          indicatorSettings: indicatorSettings,
          indicatorPinchStrength: indicatorPinchStrength,
          selectedIconColor: selectedIconColor,
          unselectedIconColor: unselectedIconColor,
          selectedLabelColor: selectedLabelColor,
          unselectedLabelColor: unselectedLabelColor,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          iconSize: iconSize,
          labelFontSize: labelFontSize,
          textStyle: textStyle,
          glowDuration: glowDuration,
          glowBlurRadius: glowBlurRadius,
          glowSpreadRadius: glowSpreadRadius,
          glowOpacity: glowOpacity,
          quality: quality,
          backgroundQuality: backgroundQuality,
          magnification: magnification,
          innerBlur: innerBlur,
          maskingQuality: maskingQuality,
          backgroundKey: backgroundKey,
          tabWidth: tabWidth,
          indicatorBorderRadius: indicatorBorderRadius,
          indicatorExpansion: indicatorExpansion,
          interactionGlowColor: interactionGlowColor,
          interactionGlowRadius: interactionGlowRadius,
          interactionBehavior: interactionBehavior,
          pressScale: pressScale,
          platformViewBackdrop: platformViewBackdrop,
          adaptiveBrightness: adaptiveBrightness,
          onBrightnessChanged: onBrightnessChanged,
          brightnessOverride: brightnessOverride,
        );

  // ─── Inline constructor ────────────────────────────────────────────────────

  /// Creates a compact, in-page glass tab bar with a refracting glass track.
  ///
  /// Use this when you need a **glass-backed** content switcher embedded inside
  /// a page — e.g. an Apple Music-style section picker or a search results
  /// segment bar that sits on a glass surface.
  ///
  /// The track refracts the background behind it via `AdaptiveGlass.grouped`,
  /// and the indicator uses the same jelly-physics spring as [GlassTabBar.bottom].
  ///
  /// For a flat, native-fidelity filter/mode control (matching the default
  /// `UISegmentedControl` appearance), use [GlassSegmentedControl] instead.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// GlassTabBar.inline(
  ///   tabs: const [
  ///     GlassTab(label: 'For You'),
  ///     GlassTab(label: 'Following'),
  ///     GlassTab(label: 'New'),
  ///   ],
  ///   selectedIndex: _selectedIndex,
  ///   onTabSelected: (i) => setState(() => _selectedIndex = i),
  /// )
  /// ```
  const GlassTabBar.inline({
    required List<GlassTab> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    Key? key,
    // Compact defaults suited for inline placement
    double horizontalPadding = 0,
    double verticalPadding = 0,
    double barHeight = 40,
    double barBorderRadius = 100,
    double labelFontSize = 13,
    double iconSize = 18,
    EdgeInsetsGeometry tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    EdgeInsetsGeometry indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    // No magnification for compact label-centric layout
    double magnification = 1.0,
    double innerBlur = 0.0,
    // Standard shared params
    double spacing = 4,
    double blendAmount = 10,
    bool enableBlend = true,
    bool groupBackdrop = true,
    bool showIndicator = true,
    Color? indicatorColor,
    LiquidGlassSettings? indicatorSettings,
    double indicatorPinchStrength = 0.4,
    double? indicatorBorderRadius,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? selectedLabelColor,
    Color? unselectedLabelColor,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    TextStyle? textStyle,
    double? tabWidth,
    LiquidGlassSettings? settings,
    GlassQuality? quality,
    GlassQuality? backgroundQuality,
    MaskingQuality maskingQuality = MaskingQuality.high,
    GlobalKey? backgroundKey,
    double iconLabelSpacing = 4,
    Duration glowDuration = const Duration(milliseconds: 300),
    double glowBlurRadius = 20,
    double glowSpreadRadius = 4,
    double glowOpacity = 0.5,
    GlassInteractionBehavior interactionBehavior =
        GlassInteractionBehavior.full,
    double pressScale = 1.02,
    Color? interactionGlowColor,
    double? interactionGlowRadius,
    bool platformViewBackdrop = false,
    bool adaptiveBrightness = false,
    ValueChanged<Brightness>? onBrightnessChanged,
    ValueListenable<Brightness>? brightnessOverride,
    // Indicator snap spring — null keeps the shared default. Exposed so
    // inline hosts can match a reference feel (e.g. Apple Music's snappier
    // settle) without forking the physics.
    SpringDescription? springDescription,
  }) : this._(
          key: key,
          placement: _GlassTabBarPlacement.inline,
          springDescription: springDescription,
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          barHeight: barHeight,
          barBorderRadius: barBorderRadius,
          labelFontSize: labelFontSize,
          iconSize: iconSize,
          tabPadding: tabPadding,
          indicatorExpansion: indicatorExpansion,
          magnification: magnification,
          innerBlur: innerBlur,
          spacing: spacing,
          blendAmount: blendAmount,
          enableBlend: enableBlend,
          groupBackdrop: groupBackdrop,
          showIndicator: showIndicator,
          indicatorColor: indicatorColor,
          indicatorSettings: indicatorSettings,
          indicatorPinchStrength: indicatorPinchStrength,
          indicatorBorderRadius: indicatorBorderRadius,
          selectedIconColor: selectedIconColor,
          unselectedIconColor: unselectedIconColor,
          selectedLabelColor: selectedLabelColor,
          unselectedLabelColor: unselectedLabelColor,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          textStyle: textStyle,
          tabWidth: tabWidth,
          settings: settings,
          quality: quality,
          backgroundQuality: backgroundQuality,
          maskingQuality: maskingQuality,
          backgroundKey: backgroundKey,
          iconLabelSpacing: iconLabelSpacing,
          glowDuration: glowDuration,
          glowBlurRadius: glowBlurRadius,
          glowSpreadRadius: glowSpreadRadius,
          glowOpacity: glowOpacity,
          interactionBehavior: interactionBehavior,
          pressScale: pressScale,
          interactionGlowColor: interactionGlowColor,
          interactionGlowRadius: interactionGlowRadius,
          platformViewBackdrop: platformViewBackdrop,
          adaptiveBrightness: adaptiveBrightness,
          onBrightnessChanged: onBrightnessChanged,
          brightnessOverride: brightnessOverride,
        );

  // ─── Searchable constructor ────────────────────────────────────────────────

  /// Creates a bottom bar with a morphing search pill.
  ///
  /// This constructor replaces the legacy `GlassSearchableBottomBar`.
  /// All parameters are identical to that widget. Migrate by replacing
  /// `GlassSearchableBottomBar(` → `GlassTabBar.searchable(`.
  const GlassTabBar.searchable({
    required List<GlassTab> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    required GlassSearchBarConfig searchConfig,
    Key? key,
    SearchableBottomBarController? controller,
    bool isSearchActive = false,
    GlassTabBarExtraButton? extraButton,
    GlassTabBarAccessoryPlacement? bottomAccessoryPlacement,
    Widget? bottomAccessory,
    bool bottomAccessoryEnabled = true,
    double bottomAccessorySpacing = 6.0,
    double? bottomAccessoryHeight,
    double spacing = 8,
    double horizontalPadding = 20,
    double verticalPadding = 20,
    double barHeight = 64,
    double searchBarHeight = 50,
    double barBorderRadius = _kDefaultBottomBorderRadius,
    EdgeInsetsGeometry tabPadding = const EdgeInsets.symmetric(horizontal: 4),
    double iconLabelSpacing = 4,
    bool enableBlend = true,
    bool groupBackdrop = true,
    double blendAmount = 10,
    LiquidGlassSettings? settings,
    bool showIndicator = true,
    Color? indicatorColor,
    LiquidGlassSettings? indicatorSettings,
    double indicatorPinchStrength = 0.4,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? selectedLabelColor,
    Color? unselectedLabelColor,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    double iconSize = 24,
    double labelFontSize = 11,
    TextStyle? textStyle,
    Duration glowDuration = const Duration(milliseconds: 300),
    double glowBlurRadius = 32,
    double glowSpreadRadius = 8,
    double glowOpacity = 0.6,
    GlassInteractionBehavior interactionBehavior =
        GlassInteractionBehavior.full,
    double? pressScale,
    Color? interactionGlowColor,
    double? interactionGlowRadius,
    GlassQuality? quality,
    GlassQuality? backgroundQuality,
    double magnification = 1.15,
    double innerBlur = 0.0,
    bool platformViewBackdrop = false,
    MaskingQuality maskingQuality = MaskingQuality.high,
    GlobalKey? backgroundKey,
    SpringDescription? springDescription,
    GlassTabPillAnchor tabPillAnchor = GlassTabPillAnchor.start,
    double? tabWidth,
    double? indicatorBorderRadius,
    EdgeInsetsGeometry indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    VoidCallback? onBarTap,
    bool whitenAtBottom = true,
    double whitenBottomThreshold = 45.0,
    double whitenAtBottomTarget = 1.0,
    ScrollController? scrollController,
    bool adaptiveBrightness = false,
    ValueChanged<Brightness>? onBrightnessChanged,
    ValueListenable<Brightness>? brightnessOverride,
  }) : this._(
          key: key,
          placement: _GlassTabBarPlacement.searchable,
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          searchConfig: searchConfig,
          controller: controller,
          isSearchActive: isSearchActive,
          extraButton: extraButton,
          bottomAccessoryPlacement: bottomAccessoryPlacement,
          bottomAccessory: bottomAccessory,
          bottomAccessoryEnabled: bottomAccessoryEnabled,
          bottomAccessorySpacing: bottomAccessorySpacing,
          bottomAccessoryHeight: bottomAccessoryHeight,
          spacing: spacing,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          barHeight: barHeight,
          searchBarHeight: searchBarHeight,
          barBorderRadius: barBorderRadius,
          tabPadding: tabPadding,
          iconLabelSpacing: iconLabelSpacing,
          enableBlend: enableBlend,
          groupBackdrop: groupBackdrop,
          blendAmount: blendAmount,
          settings: settings,
          showIndicator: showIndicator,
          indicatorColor: indicatorColor,
          indicatorSettings: indicatorSettings,
          indicatorPinchStrength: indicatorPinchStrength,
          selectedIconColor: selectedIconColor,
          unselectedIconColor: unselectedIconColor,
          selectedLabelColor: selectedLabelColor,
          unselectedLabelColor: unselectedLabelColor,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          iconSize: iconSize,
          labelFontSize: labelFontSize,
          textStyle: textStyle,
          glowDuration: glowDuration,
          glowBlurRadius: glowBlurRadius,
          glowSpreadRadius: glowSpreadRadius,
          glowOpacity: glowOpacity,
          interactionBehavior: interactionBehavior,
          pressScale: pressScale,
          interactionGlowColor: interactionGlowColor,
          interactionGlowRadius: interactionGlowRadius,
          quality: quality,
          backgroundQuality: backgroundQuality,
          magnification: magnification,
          innerBlur: innerBlur,
          platformViewBackdrop: platformViewBackdrop,
          maskingQuality: maskingQuality,
          backgroundKey: backgroundKey,
          springDescription: springDescription,
          tabPillAnchor: tabPillAnchor,
          tabWidth: tabWidth,
          indicatorBorderRadius: indicatorBorderRadius,
          indicatorExpansion: indicatorExpansion,
          onBarTap: onBarTap,
          whitenAtBottom: whitenAtBottom,
          whitenBottomThreshold: whitenBottomThreshold,
          whitenAtBottomTarget: whitenAtBottomTarget,
          scrollController: scrollController,
          adaptiveBrightness: adaptiveBrightness,
          onBrightnessChanged: onBrightnessChanged,
          brightnessOverride: brightnessOverride,
        );

  // ─── Minimizable constructor ───────────────────────────────────────────────

  /// Creates a bottom bar that minimizes to the selected tab's circle —
  /// SwiftUI's `tabBarMinimizeBehavior`, i.e. the [GlassTabBar.searchable]
  /// morph without the search.
  ///
  /// Drives the same layout engine as the searchable placement, so the
  /// minimize is the identical spring morph, but the API speaks navigation
  /// rather than search: [minimized] replaces `isSearchActive` (the caller
  /// decides when — typically from scroll direction, matching
  /// `.tabBarMinimizeBehavior(.onScrollDown)`), tapping the minimized tab
  /// circle fires [onMinimizedTabTap] (the "bring my tabs back" control),
  /// and the slot the search pill occupies is an optional plain action
  /// button — [trailingButton] — or nothing at all. Both pills render at
  /// [minimizedBarHeight] while minimized, mirroring how the native
  /// minimized bar sits slightly smaller than the expanded one.
  ///
  /// The trailing slot maps onto the native components:
  ///
  /// - `trailingButton: null` — a plain minimizing tab bar; the tabs get the
  ///   full bar width, and the minimized state is the selected tab's circle
  ///   alone.
  /// - With a [trailingButton], the button is present in both states —
  ///   exactly how a `Tab(role: .search)` trailing circle keeps its
  ///   priority visibility through the minimize.
  ///
  /// [trailingButton] may change between builds and the bar animates the
  /// difference: the button spring-scales in and out in place at its slot.
  /// An app that wants a button only while minimized simply passes it only
  /// while [minimized] is true — the appearing button grows in at the
  /// trailing edge as the tab pill shrinks to its circle.
  ///
  /// ### Minimizing on scroll
  ///
  /// Pass a [GlassTabBarMinimizeController] as [minimizeController] and the
  /// bar minimizes itself from the scroll view given to [scrollController] —
  /// the equivalent of `.tabBarMinimizeBehavior(.onScrollDown)`. The
  /// controller then owns the state and [minimized] is ignored:
  ///
  /// ```dart
  /// GlassTabBar.minimizable(
  ///   tabs: tabs,
  ///   selectedIndex: index,
  ///   onTabSelected: onTabSelected,
  ///   minimizeController: _minimize,
  ///   scrollController: _scroll,
  ///   onMinimizedTabTap: _minimize.expand,
  /// )
  /// ```
  ///
  /// A host that cannot reach the current screen's [ScrollController] leaves
  /// [scrollController] off and feeds the minimize controller from a
  /// `NotificationListener` instead — see
  /// [GlassTabBarMinimizeController.handleNotification].
  ///
  /// Without one, [minimized] stays a plain controlled prop and the caller
  /// decides when to flip it.
  ///
  /// A [bottomAccessory] follows the bar: with no explicit
  /// [bottomAccessoryPlacement] it moves inline as the bar minimizes, the way
  /// iOS 26 animates a `tabViewBottomAccessory` down into the minimized bar.
  /// Pass [GlassTabBarAccessoryPlacement.expanded] to pin it.
  const GlassTabBar.minimizable({
    required List<GlassTab> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabSelected,
    Key? key,
    bool minimized = false,
    GlassTabBarMinimizeController? minimizeController,
    VoidCallback? onMinimizedTabTap,
    GlassTabBarTrailingButton? trailingButton,
    GlassTabBarExtraButton? extraButton,
    Widget? bottomAccessory,
    GlassTabBarAccessoryPlacement? bottomAccessoryPlacement,
    bool bottomAccessoryEnabled = true,
    double bottomAccessorySpacing = 6.0,
    double? bottomAccessoryHeight,
    double spacing = 8,
    double horizontalPadding = 20,
    double verticalPadding = 20,
    double barHeight = 64,
    double minimizedBarHeight = 50,
    double barBorderRadius = _kDefaultBottomBorderRadius,
    EdgeInsetsGeometry tabPadding = const EdgeInsets.symmetric(horizontal: 4),
    double iconLabelSpacing = 4,
    bool enableBlend = true,
    bool groupBackdrop = true,
    double blendAmount = 10,
    LiquidGlassSettings? settings,
    bool showIndicator = true,
    Color? indicatorColor,
    LiquidGlassSettings? indicatorSettings,
    double indicatorPinchStrength = 0.4,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? selectedLabelColor,
    Color? unselectedLabelColor,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    double iconSize = 24,
    double labelFontSize = 11,
    TextStyle? textStyle,
    Duration glowDuration = const Duration(milliseconds: 300),
    double glowBlurRadius = 32,
    double glowSpreadRadius = 8,
    double glowOpacity = 0.6,
    GlassInteractionBehavior interactionBehavior =
        GlassInteractionBehavior.full,
    double? pressScale,
    Color? interactionGlowColor,
    double? interactionGlowRadius,
    GlassQuality? quality,
    GlassQuality? backgroundQuality,
    double magnification = 1.15,
    double innerBlur = 0.0,
    bool platformViewBackdrop = false,
    MaskingQuality maskingQuality = MaskingQuality.high,
    GlobalKey? backgroundKey,
    SpringDescription? springDescription,
    GlassTabPillAnchor tabPillAnchor = GlassTabPillAnchor.start,
    double? tabWidth,
    double? indicatorBorderRadius,
    EdgeInsetsGeometry indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    VoidCallback? onBarTap,
    bool whitenAtBottom = true,
    double whitenBottomThreshold = 45.0,
    double whitenAtBottomTarget = 1.0,
    ScrollController? scrollController,
    bool adaptiveBrightness = false,
    ValueChanged<Brightness>? onBrightnessChanged,
    ValueListenable<Brightness>? brightnessOverride,
  }) : this._(
          key: key,
          placement: _GlassTabBarPlacement.minimizable,
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          isSearchActive: minimized,
          onMinimizedTabTap: onMinimizedTabTap,
          trailingButton: trailingButton,
          extraButton: extraButton,
          minimizeController: minimizeController,
          bottomAccessoryPlacement: bottomAccessoryPlacement,
          bottomAccessory: bottomAccessory,
          bottomAccessoryEnabled: bottomAccessoryEnabled,
          bottomAccessorySpacing: bottomAccessorySpacing,
          bottomAccessoryHeight: bottomAccessoryHeight,
          spacing: spacing,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          barHeight: barHeight,
          searchBarHeight: minimizedBarHeight,
          barBorderRadius: barBorderRadius,
          tabPadding: tabPadding,
          iconLabelSpacing: iconLabelSpacing,
          enableBlend: enableBlend,
          groupBackdrop: groupBackdrop,
          blendAmount: blendAmount,
          settings: settings,
          showIndicator: showIndicator,
          indicatorColor: indicatorColor,
          indicatorSettings: indicatorSettings,
          indicatorPinchStrength: indicatorPinchStrength,
          selectedIconColor: selectedIconColor,
          unselectedIconColor: unselectedIconColor,
          selectedLabelColor: selectedLabelColor,
          unselectedLabelColor: unselectedLabelColor,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          iconSize: iconSize,
          labelFontSize: labelFontSize,
          textStyle: textStyle,
          glowDuration: glowDuration,
          glowBlurRadius: glowBlurRadius,
          glowSpreadRadius: glowSpreadRadius,
          glowOpacity: glowOpacity,
          interactionBehavior: interactionBehavior,
          pressScale: pressScale,
          interactionGlowColor: interactionGlowColor,
          interactionGlowRadius: interactionGlowRadius,
          quality: quality,
          backgroundQuality: backgroundQuality,
          magnification: magnification,
          innerBlur: innerBlur,
          platformViewBackdrop: platformViewBackdrop,
          maskingQuality: maskingQuality,
          backgroundKey: backgroundKey,
          springDescription: springDescription,
          tabPillAnchor: tabPillAnchor,
          tabWidth: tabWidth,
          indicatorBorderRadius: indicatorBorderRadius,
          indicatorExpansion: indicatorExpansion,
          onBarTap: onBarTap,
          whitenAtBottom: whitenAtBottom,
          whitenBottomThreshold: whitenBottomThreshold,
          whitenAtBottomTarget: whitenAtBottomTarget,
          scrollController: scrollController,
          adaptiveBrightness: adaptiveBrightness,
          onBrightnessChanged: onBrightnessChanged,
          brightnessOverride: brightnessOverride,
        );

  // ─── Private unified constructor (delegate target) ─────────────────────────

  const GlassTabBar._(
      {required this.tabs,
      required this.selectedIndex,
      required this.onTabSelected,
      required _GlassTabBarPlacement placement,
      super.key,
      // Shared styling
      this.indicatorColor,
      this.selectedIconColor,
      this.unselectedIconColor,
      this.selectedLabelColor,
      this.unselectedLabelColor,
      this.selectedLabelStyle,
      this.unselectedLabelStyle,
      this.iconSize = 24.0,
      this.settings,
      this.quality,
      this.backgroundQuality,
      this.indicatorSettings,
      this.indicatorPinchStrength = 0.4,
      this.indicatorExpansion =
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      this.backgroundKey,
      this.maskingQuality = MaskingQuality.high,
      // Bottom / searchable shared
      this.spacing = 8,
      this.horizontalPadding = 20,
      this.verticalPadding = 20,
      this.barHeight = 64,
      this.barBorderRadius = _kDefaultBottomBorderRadius,
      this.tabPadding = const EdgeInsets.symmetric(horizontal: 4),
      this.iconLabelSpacing = 4,
      this.enableBlend = true,
      this.groupBackdrop = true,
      this.blendAmount = 10,
      this.showIndicator = true,
      this.magnification = 1.15,
      this.innerBlur = 0.0,
      this.glowDuration = const Duration(milliseconds: 300),
      this.glowBlurRadius = 32,
      this.glowSpreadRadius = 8,
      this.glowOpacity = 0.6,
      this.labelFontSize = 11,
      this.textStyle,
      this.tabWidth,
      this.indicatorBorderRadius,
      this.extraButton,
      this.interactionBehavior = GlassInteractionBehavior.full,
      this.pressScale,
      this.interactionGlowColor,
      this.interactionGlowRadius,
      this.platformViewBackdrop = false,
      this.adaptiveBrightness = false,
      this.onBrightnessChanged,
      this.brightnessOverride,
      this.bottomAccessoryPlacement,
      this.bottomAccessory,
      this.bottomAccessoryEnabled = true,
      this.bottomAccessorySpacing = 6.0,
      this.bottomAccessoryHeight,
      // Searchable-only
      this.searchConfig,
      this.controller,
      this.isSearchActive = false,
      this.searchBarHeight = 50,
      // Minimizable-only
      this.onMinimizedTabTap,
      this.trailingButton,
      this.minimizeController,
      this.springDescription,
      this.tabPillAnchor = GlassTabPillAnchor.start,
      this.onBarTap,
      this.whitenAtBottom = true,
      this.whitenBottomThreshold = 45.0,
      this.whitenAtBottomTarget = 1.0,
      this.scrollController})
      : _placement = placement,
        assert(tabs.length >= 1, 'GlassTabBar requires at least 1 tab'),
        assert(
          selectedIndex >= 0 && selectedIndex < tabs.length,
          'selectedIndex must be within bounds of tabs list',
        ),
        assert(
          minimizeController == null || !isSearchActive,
          'Pass either minimizeController or minimized: true, not both — the '
          'controller owns the minimize state when supplied, so a hardcoded '
          'minimized: true would be silently ignored.',
        ),
        assert(
          bottomAccessory == null || bottomAccessoryHeight != null,
          'Provide bottomAccessoryHeight when using bottomAccessory so that '
          'GlassScaffold can correctly compute the body scroll inset and '
          'edge-fade height. Without it, content will scroll behind the accessory.',
        );

  /// List of tabs to display.
  final List<GlassTab> tabs;

  /// Index of the currently selected tab.
  final int selectedIndex;

  /// Called when a tab is selected.
  final ValueChanged<int> onTabSelected;

  /// Color of the pill indicator.
  final Color? indicatorColor;

  /// Icon color for selected tab.
  final Color? selectedIconColor;

  /// Icon color for unselected tabs.
  final Color? unselectedIconColor;

  /// Label color for selected tab.
  final Color? selectedLabelColor;

  /// Label color for unselected tabs.
  final Color? unselectedLabelColor;

  /// Per-state label text style, merged over the base label style — overrides
  /// font / weight / letter-spacing while keeping the resolved label color
  /// unless the style sets its own. Null leaves existing behavior unchanged.
  final TextStyle? selectedLabelStyle;

  /// See [selectedLabelStyle].
  final TextStyle? unselectedLabelStyle;

  /// Size of the icons.
  final double iconSize;

  /// Glass effect settings.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent [InheritedLiquidGlass] or defaults to
  /// [GlassQuality.standard].
  final GlassQuality? quality;

  /// Rendering quality for the tab bar track/background container.
  ///
  /// Matches UIKit's separation of `UITabBarAppearance.backgroundEffect` from
  /// the system selection indicator pill:
  /// - When null (default), inherits from [quality] (backward-compatible).
  /// - When set, controls the quality tier of the track surface independently of
  ///   the indicator pill. For example, setting [backgroundQuality] to
  ///   [GlassQuality.minimal] or [GlassQuality.standard] while keeping [quality]
  ///   at [GlassQuality.premium] delivers full Impeller chromatic refraction and
  ///   jelly morphing on the indicator while saving GPU overhead on the static track.
  final GlassQuality? backgroundQuality;

  /// Controls indicator clipping quality.
  ///
  /// - [MaskingQuality.high] (default): Full jelly-bloom physics — the
  ///   indicator expands 8 px beyond its pill bounds for the iOS 26 spring
  ///   effect. Uses a dual-layer clipping path.
  /// - [MaskingQuality.off]: Simple clipping with no jelly expansion.
  ///   Cheaper on GPU; useful for low-end devices or accessibility modes.
  final MaskingQuality maskingQuality;

  /// Glass settings for the sliding indicator.
  final LiquidGlassSettings? indicatorSettings;

  /// Maximum concave lens pinch strength for the sliding indicator pill.
  ///
  /// - `1.0` (default) — full Apple-calibrated pinch
  /// - `0.0` — pinch fully disabled
  /// Maximum concave lens pinch strength. Forwarded to [AnimatedGlassIndicator].
  ///
  /// Defaults to `0.4` — the iOS 26-calibrated gentle concave lens warp.
  /// Set to `0.0` to disable the effect entirely, or `1.0` to restore the
  /// original full-strength warp.
  final double indicatorPinchStrength;

  /// Expansion padding applied to the active indicator pill during interaction.
  ///
  /// The pill grows by this amount beyond its cell boundary as the user drags,
  /// creating the iOS 26 "jelly" overshoot. Defaults to
  /// `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` for a consistent look
  /// across all indicator widgets.
  final EdgeInsetsGeometry indicatorExpansion;

  /// Optional background key for Skia/Web refraction.
  final GlobalKey? backgroundKey;

  // ---------------------------------------------------------------------------
  // Internal placement discriminant
  // ---------------------------------------------------------------------------
  final _GlassTabBarPlacement _placement;

  // GlassDefaults.capsuleRadius is intentional: Flutter's RoundedRectangleBorder
  // clamps the radius to min(r, halfHeight), so any value ≥ halfHeight produces
  // a stadium/capsule. Using a large sentinel means the default capsule look
  // holds at ANY barHeight — if we used 32, a user who sets barHeight: 100 would
  // get visible corners (capsule threshold = 50 > 32) without setting
  // barBorderRadius explicitly.
  //
  // The indicator also receives GlassDefaults.capsuleRadius when the bar is a
  // capsule — the internal "barRadius >= capsuleRadius" guard passes it through
  // directly rather than doing capsuleRadius - 4. This ensures the glass shader
  // always clamps to a true capsule even during jelly-bloom expansion, where
  // the pill canvas grows beyond its rest height.
  static const double _kDefaultBottomBorderRadius = GlassDefaults.capsuleRadius;

  // ---------------------------------------------------------------------------
  // Bottom / searchable fields (all have defaults — safe for inline too)
  // ---------------------------------------------------------------------------

  /// Spacing between adjacent pills (bottom/searchable only). Defaults to 8.
  final double spacing;

  /// Horizontal padding around the full bar content. Defaults to 20.
  final double horizontalPadding;

  /// Vertical padding (top + bottom) around the bar content. Defaults to 20.
  final double verticalPadding;

  /// Height of the pill (bottom/searchable). Defaults to 64.
  final double barHeight;

  /// Corner radius of the pill (bottom/searchable). Defaults to 32.
  final double barBorderRadius;

  /// Internal padding within the tab pill. Defaults to 4 px horizontal.
  final EdgeInsetsGeometry tabPadding;

  /// Vertical spacing between icon and label. Defaults to 4.
  final double iconLabelSpacing;

  /// Enables organic liquid blending between adjacent pills. Defaults to true.
  final bool enableBlend;

  /// Blend amount for the shared glass layer. Defaults to 10.
  final double blendAmount;

  /// Whether the bar's glass reads the backdrop together, in one
  /// [GlassBackdropGroup]: the pill, the search and minimize pills. The
  /// selected-tab indicator lies over the pill and stays out of it, and so
  /// do the search pill while the keyboard moves it, the searchable bar's
  /// extra button (it fades out when search opens) and the bottom
  /// accessory. On Impeller with premium glass this saves a
  /// full-screen backdrop copy per surface. Inside a [GlassBackdropGroup] of
  /// your own the bar joins that group, so one group around an app bar and
  /// a tab bar makes them share a single read. Defaults to true; set false
  /// to keep the bar out of any group, e.g. when glass of your own lies over
  /// it.
  final bool groupBackdrop;

  /// Whether to show the draggable indicator. Defaults to true.
  final bool showIndicator;

  /// Selected-icon magnification inside the indicator (bottom/searchable).
  final double magnification;

  /// Blur applied to content inside the indicator (bottom/searchable).
  final double innerBlur;

  /// Duration of the per-tab glow animation. Defaults to 300 ms.
  final Duration glowDuration;

  /// Blur radius of the tab glow effect. Defaults to 32.
  final double glowBlurRadius;

  /// Spread radius of the tab glow effect. Defaults to 8.
  final double glowSpreadRadius;

  /// Opacity of the tab glow effect. Defaults to 0.6.
  final double glowOpacity;

  /// Font size for tab labels (bottom/searchable). Defaults to 11.
  final double labelFontSize;

  /// Text style for tab labels (bottom/searchable). Overrides [labelFontSize].
  final TextStyle? textStyle;

  /// Fixed width per tab slot. Null = fill all available space.
  final double? tabWidth;

  /// Override border radius for the indicator. Null = inherits from barBorderRadius.
  final double? indicatorBorderRadius;

  /// Optional extra action button (bottom/searchable only).
  final GlassTabBarExtraButton? extraButton;

  /// Which physical interaction effects are active. Defaults to [GlassInteractionBehavior.full].
  final GlassInteractionBehavior interactionBehavior;

  /// Peak scale applied at maximum press depth.
  ///
  /// null (default): the search and trailing circles press like a native
  /// button (~17 pt growth) and the bar surface keeps its subtle 1.04. A
  /// number applies that fixed factor everywhere instead.
  final double? pressScale;

  /// Directional glow color on press. Null = theme default.
  final Color? interactionGlowColor;

  /// Spread radius of the directional glow. Defaults to 1.5.
  /// Radius of the interaction glow, as a fraction of the layer's shortest
  /// side.
  ///
  /// Null — the default — asks for the iOS 26 calibration: a wide 1.6
  /// radius under a sigma-16 Gaussian at a low alpha, the same native mode
  /// [GlassButton] resolves from a null `glowRadius`. Pass a number to keep
  /// the theme's glow palette instead.
  final double? interactionGlowRadius;

  /// Forces BackdropFilter rendering over iOS PlatformViews. Defaults to false.
  final bool platformViewBackdrop;

  /// Adapts brightness to content scrolling underneath. Defaults to false.
  final bool adaptiveBrightness;

  /// Called when the content-aware brightness verdict flips.
  final ValueChanged<Brightness>? onBrightnessChanged;

  /// External brightness source that bypasses the content sampler.
  final ValueListenable<Brightness>? brightnessOverride;

  // ---------------------------------------------------------------------------
  // Accessory / Mini-Player fields
  // ---------------------------------------------------------------------------

  /// The widget to display above the tab bar pill (e.g. a mini-player).
  ///
  /// This mirrors the iOS 26 `tabViewBottomAccessory` API.
  final GlassTabBarAccessoryPlacement? bottomAccessoryPlacement;

  /// The accessory widget rendered above (expanded) or beside (inline) the tab
  /// bar pill. Typically a mini-player or contextual action row.
  ///
  /// The accessory widget can read its current placement via
  /// [GlassTabBarAccessoryPlacementScope.of] to adapt its layout between the
  /// full expanded row and the compact inline strip.
  final Widget? bottomAccessory;

  /// Controls whether the [bottomAccessory] is shown.
  ///
  /// When toggled, the accessory animates in/out using `AnimatedSize` with an
  /// iOS 26-calibrated ease-out cubic curve (300 ms). [preferredSize] is
  /// updated in sync so [GlassScaffold] always reports the correct body inset.
  final bool bottomAccessoryEnabled;

  /// Vertical gap between the [bottomAccessory] and the glass tab bar.
  final double bottomAccessorySpacing;

  /// The known height of the [bottomAccessory].
  ///
  /// **Required for correct [GlassScaffold] integration.** When provided,
  /// [preferredSize] includes this value so the scaffold's body edge-fade
  /// correctly clears the accessory. If omitted, the scaffold sees only the
  /// pill height and content will scroll behind the accessory.
  ///
  /// Must be the rendered height of the accessory widget, excluding
  /// [bottomAccessorySpacing] (which is added automatically).
  final double? bottomAccessoryHeight;

  // ---------------------------------------------------------------------------
  // Searchable-only fields
  // ---------------------------------------------------------------------------

  /// Configuration for the morphing search bar. Required for [GlassTabBar.searchable].
  final GlassSearchBarConfig? searchConfig;

  /// Optional external controller for the search state machine.
  final SearchableBottomBarController? controller;

  /// Whether the search bar is currently expanded (searchable only). For
  /// [GlassTabBar.minimizable] this carries `minimized`, which drives the
  /// identical morph.
  final bool isSearchActive;

  /// Height of the pills while search is active. Defaults to 50.
  final double searchBarHeight;

  /// Tapping the minimized tab circle (minimizable only) — the "bring my
  /// tabs back" control.
  final VoidCallback? onMinimizedTabTap;

  /// The optional plain action button in the trailing slot (minimizable
  /// only). Null means no trailing pill at all, in either state.
  final GlassTabBarTrailingButton? trailingButton;

  /// Custom spring for the pill morph animation. Null = iOS 26 default.
  final SpringDescription? springDescription;

  /// How the tab pill is anchored during the morph animation.
  final GlassTabPillAnchor tabPillAnchor;

  /// Optional tap callback for the whole bar (searchable only).
  final VoidCallback? onBarTap;

  /// Whiten glass at page bottom in light mode. Defaults to true.
  final bool whitenAtBottom;

  /// Scroll offset at which whitening begins. Defaults to 45.0.
  final double whitenBottomThreshold;

  /// Maximum whitening amount. Defaults to 1.0.
  final double whitenAtBottomTarget;

  /// Scroll controller wired for searchable whitening and bottom-bar collapse.
  final ScrollController? scrollController;

  /// Drives [minimized] from scrolling on the minimizable placement — the
  /// equivalent of SwiftUI's `.tabBarMinimizeBehavior(_:)`.
  ///
  /// When supplied it owns the minimize state and [minimized] is ignored;
  /// pass the same [ScrollController] to [scrollController] and to the scroll
  /// view the bar floats over, or drive the controller from a
  /// `NotificationListener` and leave [scrollController] null. See
  /// [GlassTabBarMinimizeController].
  final GlassTabBarMinimizeController? minimizeController;

  /// Whether the bar is minimized right now, from whichever source owns it.
  bool get _effectiveMinimized =>
      minimizeController?.minimized ?? isSearchActive;

  /// The bar only changes height on its own when a minimize controller drives
  /// it — otherwise the size follows the widget's own props and the scaffold
  /// re-reads it on the rebuild that changed them.
  @override
  Listenable? get preferredSizeListenable => minimizeController;

  /// Whether this bar moves into iPhone Duo's vertical bar strip where a
  /// [GlassNavigationShell] has resolved one ([GlassVerticalBar.maybeOf]).
  ///
  /// True for [GlassTabBar.bottom], [GlassTabBar.minimizable] and
  /// [GlassTabBar.searchable], whose search becomes the last slot of the
  /// capsule. The inline placement is part of the content rather than a bar.
  bool get followsVerticalBar => _placement != _GlassTabBarPlacement.inline;

  @override
  Size get preferredSize {
    final minimized = _effectiveMinimized;
    final isMinimizable = _placement == _GlassTabBarPlacement.minimizable;
    final isMorphing =
        _placement == _GlassTabBarPlacement.searchable || isMinimizable;

    // Base pill height. The searchable variant alternates between barHeight
    // (expanded) and searchBarHeight (inline/mini) — use whichever is active.
    // Both branches multiply verticalPadding by 2 (top + bottom) to match
    // the symmetric Padding applied inside AdaptiveLiquidGlassLayer.
    final effectivePillH = (isMorphing && minimized)
        ? searchBarHeight + verticalPadding * 2
        : barHeight + verticalPadding * 2;

    double total = effectivePillH;

    // In inline mode the accessory sits BESIDE the pill (no extra height).
    // This MUST resolve identically to the layout engine's own call, or the
    // scaffold reserves a height the bar does not draw.
    final isInline = resolveAccessoryPlacement(
          explicit: bottomAccessoryPlacement,
          minimized: minimized,
          isMinimizablePlacement: isMinimizable,
        ) ==
        GlassTabBarAccessoryPlacement.inline;

    if (bottomAccessory != null &&
        !isInline &&
        bottomAccessoryEnabled &&
        bottomAccessoryHeight != null) {
      // Guard: gapAdjustment only makes sense in the searchable placement when
      // both heights differ. For .bottom placement isSearchActive is always false
      // so effectivePillH == barHeight + vertPad*2 and gapAdjustment == 0.
      final gapAdjustment =
          (isMorphing && minimized) ? barHeight - searchBarHeight : 0.0;
      total = effectivePillH -
          gapAdjustment +
          bottomAccessorySpacing +
          bottomAccessoryHeight!;
    }
    return Size.fromHeight(total);
  }

  @override
  State<GlassTabBar> createState() => _GlassTabBarState();
}

class _GlassTabBarState extends State<GlassTabBar> {
  @override
  void initState() {
    super.initState();
    widget.minimizeController?.addListener(_onMinimizeChanged);
  }

  @override
  void didUpdateWidget(GlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minimizeController != oldWidget.minimizeController) {
      oldWidget.minimizeController?.removeListener(_onMinimizeChanged);
      widget.minimizeController?.addListener(_onMinimizeChanged);
    }
  }

  @override
  void dispose() {
    widget.minimizeController?.removeListener(_onMinimizeChanged);
    super.dispose();
  }

  /// The bar has to subscribe on its own account, even though [GlassScaffold]
  /// also listens: the scaffold re-parents the SAME [GlassTabBar] instance on
  /// its rebuild, and the framework skips an update when the widget is
  /// identical — so without this the bar would never re-render.
  void _onMinimizeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => GlassBackdropGroup(
        enabled: widget.groupBackdrop,
        joinEnclosing: true,
        child: Builder(builder: _buildPlacement),
      );

  Widget _buildPlacement(BuildContext context) {
    // In iPhone Duo's vertical bar strip the bottom placements become an
    // icon-only capsule at the bottom of the strip.
    final verticalBar =
        widget.followsVerticalBar ? GlassVerticalBar.maybeOf(context) : null;
    if (verticalBar != null) return _buildVertical(context, verticalBar);

    // Dispatch to the correct rendering engine based on placement.
    switch (widget._placement) {
      case _GlassTabBarPlacement.bottom:
        return _buildBottom(context);
      case _GlassTabBarPlacement.searchable:
        return _buildSearchable(context);
      case _GlassTabBarPlacement.minimizable:
        return _buildMinimizable(context);
      case _GlassTabBarPlacement.inline:
        return _buildInline(context);
    }
  }

  /// Dispatches to [TabBarVerticalLayout] — the bar in iPhone Duo's vertical
  /// bar strip.
  Widget _buildVertical(BuildContext context, GlassVerticalBarData bar) {
    final searchable = widget._placement == _GlassTabBarPlacement.searchable;
    return TabBarVerticalLayout(
      bar: bar,
      tabs: widget.tabs,
      selectedIndex: widget.selectedIndex,
      onTabSelected: widget.onTabSelected,
      settings: widget.settings,
      quality: widget.quality,
      indicatorColor: widget.indicatorColor,
      selectedIconColor: widget.selectedIconColor,
      unselectedIconColor: widget.unselectedIconColor,
      iconSize: widget.iconSize,
      platformViewBackdrop: widget.platformViewBackdrop,
      searchConfig: searchable ? widget.searchConfig : null,
      // An active bar that keeps its search pill compact is minimized rather
      // than searching — Apple Music's mini mode — and the strip has no
      // minimized form of its own.
      isSearchActive: searchable &&
          widget.isSearchActive &&
          widget.searchConfig!.expandWhenActive,
    );
  }

  /// Dispatches to [TabBarBottomLayout] — the iOS 26-style bottom placement engine.
  Widget _buildBottom(BuildContext context) {
    return TabBarBottomLayout(
      tabs: widget.tabs,
      selectedIndex: widget.selectedIndex,
      onTabSelected: widget.onTabSelected,
      extraButton: widget.extraButton,
      bottomAccessory: widget.bottomAccessory,
      bottomAccessoryEnabled: widget.bottomAccessoryEnabled,
      bottomAccessorySpacing: widget.bottomAccessorySpacing,
      spacing: widget.spacing,
      horizontalPadding: widget.horizontalPadding,
      verticalPadding: widget.verticalPadding,
      barHeight: widget.barHeight,
      barBorderRadius: widget.barBorderRadius,
      tabPadding: widget.tabPadding,
      iconLabelSpacing: widget.iconLabelSpacing,
      enableBlend: widget.enableBlend,
      blendAmount: widget.blendAmount,
      settings: widget.settings,
      showIndicator: widget.showIndicator,
      indicatorColor: widget.indicatorColor,
      indicatorSettings: widget.indicatorSettings,
      indicatorPinchStrength: widget.indicatorPinchStrength,
      selectedIconColor: widget.selectedIconColor,
      unselectedIconColor: widget.unselectedIconColor,
      selectedLabelColor: widget.selectedLabelColor,
      unselectedLabelColor: widget.unselectedLabelColor,
      selectedLabelStyle: widget.selectedLabelStyle,
      unselectedLabelStyle: widget.unselectedLabelStyle,
      iconSize: widget.iconSize,
      labelFontSize: widget.labelFontSize,
      textStyle: widget.textStyle,
      glowDuration: widget.glowDuration,
      glowBlurRadius: widget.glowBlurRadius,
      glowSpreadRadius: widget.glowSpreadRadius,
      glowOpacity: widget.glowOpacity,
      quality: widget.quality,
      backgroundQuality: widget.backgroundQuality,
      magnification: widget.magnification,
      innerBlur: widget.innerBlur,
      maskingQuality: widget.maskingQuality,
      backgroundKey: widget.backgroundKey,
      tabWidth: widget.tabWidth,
      indicatorBorderRadius: widget.indicatorBorderRadius,
      indicatorExpansion: widget.indicatorExpansion,
      interactionGlowColor: widget.interactionGlowColor,
      interactionGlowRadius: widget.interactionGlowRadius,
      interactionBehavior: widget.interactionBehavior,
      pressScale: widget.pressScale ?? 1.04,
      platformViewBackdrop: widget.platformViewBackdrop,
      adaptiveBrightness: widget.adaptiveBrightness,
      onBrightnessChanged: widget.onBrightnessChanged,
      brightnessOverride: widget.brightnessOverride,
      scrollController: widget.scrollController,
      springDescription: widget.springDescription,
    );
  }

  /// Dispatches to [TabBarBottomLayout] with inline-appropriate defaults —
  /// compact height, no floating margins, no icon magnification.
  ///
  /// The track glass comes from [AdaptiveGlass.grouped] inside [TabBarBottomLayout]
  /// exactly as in the bottom placement — no new rendering path needed.
  Widget _buildInline(BuildContext context) {
    return TabBarBottomLayout(
      tabs: widget.tabs,
      selectedIndex: widget.selectedIndex,
      onTabSelected: widget.onTabSelected,
      spacing: widget.spacing,
      horizontalPadding: widget.horizontalPadding,
      verticalPadding: widget.verticalPadding,
      barHeight: widget.barHeight,
      barBorderRadius: widget.barBorderRadius,
      tabPadding: widget.tabPadding,
      iconLabelSpacing: widget.iconLabelSpacing,
      enableBlend: widget.enableBlend,
      blendAmount: widget.blendAmount,
      settings: widget.settings,
      showIndicator: widget.showIndicator,
      indicatorColor: widget.indicatorColor,
      indicatorSettings: widget.indicatorSettings,
      indicatorPinchStrength: widget.indicatorPinchStrength,
      selectedIconColor: widget.selectedIconColor,
      unselectedIconColor: widget.unselectedIconColor,
      selectedLabelColor: widget.selectedLabelColor,
      unselectedLabelColor: widget.unselectedLabelColor,
      selectedLabelStyle: widget.selectedLabelStyle,
      unselectedLabelStyle: widget.unselectedLabelStyle,
      iconSize: widget.iconSize,
      labelFontSize: widget.labelFontSize,
      textStyle: widget.textStyle,
      glowDuration: widget.glowDuration,
      glowBlurRadius: widget.glowBlurRadius,
      glowSpreadRadius: widget.glowSpreadRadius,
      glowOpacity: widget.glowOpacity,
      quality: widget.quality,
      backgroundQuality: widget.backgroundQuality,
      magnification: widget.magnification,
      innerBlur: widget.innerBlur,
      maskingQuality: widget.maskingQuality,
      backgroundKey: widget.backgroundKey,
      tabWidth: widget.tabWidth,
      indicatorBorderRadius: widget.indicatorBorderRadius,
      indicatorExpansion: widget.indicatorExpansion,
      interactionGlowColor: widget.interactionGlowColor,
      interactionGlowRadius: widget.interactionGlowRadius,
      interactionBehavior: widget.interactionBehavior,
      pressScale: widget.pressScale ?? 1.04,
      platformViewBackdrop: widget.platformViewBackdrop,
      adaptiveBrightness: widget.adaptiveBrightness,
      onBrightnessChanged: widget.onBrightnessChanged,
      brightnessOverride: widget.brightnessOverride,
      springDescription: widget.springDescription,
      // No extra button in inline placement
    );
  }

  /// Dispatches to [TabBarSearchableLayout] — the iOS 26-style searchable placement engine.
  Widget _buildSearchable(BuildContext context) => _buildSearchableEngine(
        context,
        searchConfig: widget.searchConfig,
      );

  /// Dispatches to [TabBarSearchableLayout] configured for minimizable placement.
  Widget _buildMinimizable(BuildContext context) => _buildSearchableEngine(
        context,
        trailingButton: widget.trailingButton,
        onMinimizedTabTap: widget.onMinimizedTabTap,
      );

  Widget _buildSearchableEngine(
    BuildContext context, {
    GlassSearchBarConfig? searchConfig,
    GlassTabBarTrailingButton? trailingButton,
    VoidCallback? onMinimizedTabTap,
  }) {
    return TabBarSearchableLayout(
      tabs: widget.tabs,
      selectedIndex: widget.selectedIndex,
      onTabSelected: widget.onTabSelected,
      searchConfig: searchConfig,
      trailingButton: trailingButton,
      onMinimizedTabTap: onMinimizedTabTap,
      controller: widget.controller,
      isSearchActive: widget._effectiveMinimized,
      minimizeController: widget.minimizeController,
      isMinimizablePlacement:
          widget._placement == _GlassTabBarPlacement.minimizable,
      extraButton: widget.extraButton,
      bottomAccessoryPlacement: widget.bottomAccessoryPlacement,
      bottomAccessory: widget.bottomAccessory,
      bottomAccessoryEnabled: widget.bottomAccessoryEnabled,
      bottomAccessorySpacing: widget.bottomAccessorySpacing,
      bottomAccessoryHeight: widget.bottomAccessoryHeight,
      spacing: widget.spacing,
      horizontalPadding: widget.horizontalPadding,
      verticalPadding: widget.verticalPadding,
      barHeight: widget.barHeight,
      searchBarHeight: widget.searchBarHeight,
      barBorderRadius: widget.barBorderRadius,
      tabPadding: widget.tabPadding,
      iconLabelSpacing: widget.iconLabelSpacing,
      enableBlend: widget.enableBlend,
      blendAmount: widget.blendAmount,
      settings: widget.settings,
      showIndicator: widget.showIndicator,
      indicatorColor: widget.indicatorColor,
      indicatorSettings: widget.indicatorSettings,
      indicatorPinchStrength: widget.indicatorPinchStrength,
      selectedIconColor: widget.selectedIconColor,
      unselectedIconColor: widget.unselectedIconColor,
      selectedLabelColor: widget.selectedLabelColor,
      unselectedLabelColor: widget.unselectedLabelColor,
      selectedLabelStyle: widget.selectedLabelStyle,
      unselectedLabelStyle: widget.unselectedLabelStyle,
      iconSize: widget.iconSize,
      labelFontSize: widget.labelFontSize,
      textStyle: widget.textStyle,
      glowDuration: widget.glowDuration,
      glowBlurRadius: widget.glowBlurRadius,
      glowSpreadRadius: widget.glowSpreadRadius,
      glowOpacity: widget.glowOpacity,
      interactionBehavior: widget.interactionBehavior,
      pressScale: widget.pressScale,
      interactionGlowColor: widget.interactionGlowColor,
      interactionGlowRadius: widget.interactionGlowRadius,
      quality: widget.quality,
      backgroundQuality: widget.backgroundQuality,
      magnification: widget.magnification,
      innerBlur: widget.innerBlur,
      platformViewBackdrop: widget.platformViewBackdrop,
      maskingQuality: widget.maskingQuality,
      backgroundKey: widget.backgroundKey,
      springDescription: widget.springDescription,
      tabPillAnchor: widget.tabPillAnchor,
      tabWidth: widget.tabWidth,
      indicatorBorderRadius: widget.indicatorBorderRadius,
      indicatorExpansion: widget.indicatorExpansion,
      onBarTap: widget.onBarTap,
      whitenAtBottom: widget.whitenAtBottom,
      whitenBottomThreshold: widget.whitenBottomThreshold,
      whitenAtBottomTarget: widget.whitenAtBottomTarget,
      scrollController: widget.scrollController,
      adaptiveBrightness: widget.adaptiveBrightness,
      onBrightnessChanged: widget.onBrightnessChanged,
      brightnessOverride: widget.brightnessOverride,
    );
  }
}

// =============================================================================
// GlassTabBarTrailingButton — the minimizable placement's action button
// =============================================================================

/// The plain action button in [GlassTabBar.minimizable]'s trailing slot —
/// the circular glass pill the searchable placement uses for search, carrying
/// an ordinary tap action instead. The generalized form of SwiftUI's
/// `Tab(role: .search)` trailing circle.
///
/// Not to be confused with [GlassTabBarExtraButton], which is an *additional*
/// button rendered beside the pills. This one *is* the trailing pill: it
/// shares the bar's glass blend layer, morphs with the same springs, and
/// shrinks to [GlassTabBar.minimizable]'s `minimizedBarHeight` alongside the
/// minimized tab circle. Like its native counterpart it is present in both
/// states; pass it conditionally (see [GlassTabBar.minimizable]) for
/// app-defined policies such as a button that exists only while minimized.
class GlassTabBarTrailingButton {
  static void _noOp() {}

  /// Creates the trailing button.
  const GlassTabBarTrailingButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.enabled = true,
  })  : menuItems = null,
        menuAlignment = null,
        menuWidth = 200,
        menuHeight = null;

  /// Opens a [GlassMenu] pull-down when the trailing pill is tapped.
  ///
  /// The whole pill morphs into the menu — the same liquid-spring behavior
  /// as [GlassButtonGroupItem.menu] and [GlassBarItem.menu]. Equivalent to
  /// a `UIBarButtonItem(image:menu:)` placed in the tab bar's trailing slot.
  ///
  /// [menuItems] accepts [GlassMenuItem] and [GlassMenuDivider] widgets —
  /// the same contract as [GlassMenu.items].
  ///
  /// [menuAlignment] defaults to auto-detection, which for a bottom-of-screen
  /// button always expands upward — pass [GlassMenuAlignment.topLeft] or
  /// [GlassMenuAlignment.topRight] to pin the direction explicitly.
  const GlassTabBarTrailingButton.menu({
    required this.icon,
    required List<Widget> this.menuItems,
    this.label,
    this.enabled = true,
    this.menuAlignment,
    this.menuWidth = 200,
    this.menuHeight,
  }) : onTap = _noOp;

  /// The glyph centered on the pill.
  final Widget icon;

  /// Called when the pill is tapped.
  final VoidCallback onTap;

  /// Optional accessibility label for the button.
  final String? label;

  /// Whether the button is interactive. Defaults to true.
  final bool enabled;

  /// When non-null, tapping this button opens a [GlassMenu] pull-down.
  final List<Widget>? menuItems;

  /// Controls where the menu expands relative to the trigger button.
  final GlassMenuAlignment? menuAlignment;

  /// Width of the expanded menu panel in logical pixels. Defaults to 200.
  final double menuWidth;

  /// Optional fixed height of the expanded menu panel in logical pixels.
  final double? menuHeight;

  /// Whether this button opens a menu rather than firing a tap callback.
  bool get isMenu => menuItems != null;
}

// =============================================================================
// GlassSegment — configuration for a single segment in GlassSegmentedControl
// =============================================================================

/// What a horizontal drag means on a scrollable segmented control.
enum SegmentDragBehavior {
  /// A drag beginning on the selected segment drags the INDICATOR from
  /// choice to choice (the `UISegmentedControl` gesture); drags elsewhere
  /// scroll the list. The right feel when every choice is visible.
  selectIndicator,

  /// Every drag scrolls the list — the selected segment included;
  /// selection changes by tap only. The picker behavior: with most
  /// choices off-screen (and especially with
  /// [SegmentSelectionAlignment.center], which parks the selection exactly
  /// where a scrolling thumb naturally lands), navigation is what a drag
  /// means.
  scroll,
}

/// Where a scrollable segmented control keeps its selected segment.
enum SegmentSelectionAlignment {
  /// Scroll only as far as needed for the selection to be fully visible,
  /// with a little edge breathing room (the classic tab-bar behavior).
  minimal,

  /// Keep the selection centered in the viewport whenever possible —
  /// clamped at the ends of the list. The picker behavior: selection lives
  /// at the center and the choices arrange themselves around it.
  center,
}

/// Configuration for a single segment in [GlassSegmentedControl].
///
/// [GlassSegment] is the item type for [GlassSegmentedControl] — the iOS 26
/// `UISegmentedControl` equivalent. It intentionally carries **only** fields
/// that make sense for a segmented control item:
///
/// - [label] — the text label
/// - [icon] — the leading icon (before the label)
/// - [tooltip] — tooltip shown on long-press
/// - [semanticLabel] — overrides the accessibility announcement
/// - [enabled] — whether this segment can be selected
///
/// ## Why not [GlassTab]?
///
/// [GlassTab] is the navigation-tab type for [GlassTabBar.bottom] and
/// [GlassTabBar.searchable]. It carries fields like [GlassTab.glowColor],
/// [GlassTab.activeIcon], and [GlassTab.thickness] that are navigation-specific
/// and have no effect in a segmented control. [GlassSegment] is the correct,
/// minimal API for [GlassSegmentedControl].
///
/// ## Usage
///
/// ```dart
/// GlassSegmentedControl(
///   segments: [
///     GlassSegment(label: 'All'),
///     GlassSegment(label: 'Photos', icon: Icon(CupertinoIcons.photo)),
///     GlassSegment(label: 'Videos', icon: Icon(CupertinoIcons.video_camera)),
///   ],
///   selectedIndex: _index,
///   onSegmentSelected: (i) => setState(() => _index = i),
/// )
/// ```
///
/// ## Icon-only segments
///
/// ```dart
/// GlassSegment(icon: Icon(CupertinoIcons.list_bullet))
/// GlassSegment(icon: Icon(CupertinoIcons.square_grid_2x2))
/// ```
///
/// ## Disabled segment
///
/// ```dart
/// GlassSegment(label: 'Pro Only', enabled: false)
/// ```
class GlassSegment {
  /// Creates a segment configuration.
  ///
  /// At least one of [icon] or [label] must be provided.
  const GlassSegment({
    this.icon,
    this.label,
    this.id,
    this.tooltip,
    this.semanticLabel,
    this.enabled = true,
  }) : assert(
          icon != null || label != null,
          'GlassSegment must have either an icon or a label.',
        );

  /// Icon widget to display before the label (or alone, if [label] is null).
  ///
  /// Standard [Icon] widgets automatically pick up the correct color and size
  /// from the parent [IconTheme]. Typically a [CupertinoIcons] icon.
  final Widget? icon;

  /// Text label for this segment.
  ///
  /// If null, [icon] is used alone. If both are provided, the icon is shown
  /// above the label (same layout as iOS `UISegmentedControl` with images).
  final String? label;

  /// Stable identity for this segment across list changes.
  ///
  /// When the segment list is replaced (items inserted, removed, or the
  /// list re-gridded around a surviving value), segments whose identity
  /// survives keep their underlying elements instead of remounting — only
  /// genuinely new cells build. Falls back to [label]; segments with
  /// neither, or with duplicate identities, get fresh cells each time.
  final Object? id;

  /// Tooltip shown on long-press (optional).
  ///
  /// Useful for icon-only segments where the meaning may not be obvious.
  final String? tooltip;

  /// Overrides the default accessibility announcement.
  ///
  /// If null, falls back to [label] (or an empty string for icon-only segments).
  final String? semanticLabel;

  /// Whether this segment can be selected.
  ///
  /// When `false`, the segment renders at reduced opacity and ignores taps.
  /// Defaults to `true`.
  final bool enabled;
}

// =============================================================================
// GlassTab — unified tab configuration type for GlassTabBar
// =============================================================================

/// Configuration for a tab in [GlassTabBar] (all constructors).
///
/// [GlassTab] is the item type for [GlassTabBar.bottom] and
/// [GlassTabBar.searchable] — the iOS 26 `UITab` / `UITabBarItem` equivalent.
///
/// For [GlassSegmentedControl], use [GlassSegment] instead. [GlassSegment] is
/// a focused type that only carries fields relevant to a segmented control.
///
/// ## Key fields
///
/// - [icon] — shown in unselected state (and selected state if [activeIcon] is null)
/// - [activeIcon] — shown in selected state (optional)
/// - [label] — text label
/// - [glowColor] — per-tab glow colour for the selected indicator
/// - [thickness] — icon shadow halo intensity
///
/// ## Usage
///
/// ```dart
/// GlassTabBar.bottom(
///   tabs: [
///     GlassTab(
///       icon: Icon(CupertinoIcons.home),
///       activeIcon: Icon(CupertinoIcons.house_fill),
///       label: 'Home',
///       glowColor: Colors.blue,
///     ),
///     GlassTab(
///       icon: Icon(CupertinoIcons.search),
///       label: 'Search',
///     ),
///   ],
///   ...
/// )
/// ```
///
/// ## Migration from `GlassBottomBarTab`
///
/// ```dart
/// // BEFORE
/// GlassBottomBarTab(icon: Icon(Icons.home), activeIcon: Icon(Icons.home_fill), label: 'Home', glowColor: Colors.blue)
/// // AFTER
/// GlassTab(icon: Icon(Icons.home), activeIcon: Icon(Icons.home_fill), label: 'Home', glowColor: Colors.blue)
/// ```
class GlassTab {
  /// Creates a tab configuration.
  ///
  /// At least one of [icon] or [label] must be provided.
  const GlassTab({
    this.icon,
    this.activeIcon,
    this.label,
    this.semanticLabel,
    this.glowColor,
    this.thickness,
  }) : assert(
          icon != null || label != null,
          'GlassTab must have either an icon or label',
        );

  /// Icon widget displayed when the tab is **not** selected.
  ///
  /// Also used when selected if [activeIcon] is not provided.
  /// Standard [Icon] widgets automatically pick up the correct color and size
  /// from the parent [IconTheme].
  final Widget? icon;

  /// Icon widget displayed when the tab **is** selected.
  ///
  /// If null, [icon] is used for both selected and unselected states.
  /// Standard [Icon] widgets automatically pick up the correct color and size
  /// from the parent [IconTheme].
  ///
  /// Only used by [GlassTabBar.bottom] and [GlassTabBar.searchable].
  final Widget? activeIcon;

  /// Label text to display in the tab.
  final String? label;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Color of the animated glow effect when this tab is selected.
  ///
  /// If null, no glow effect is shown for this tab.
  /// Only used by [GlassTabBar.bottom] and [GlassTabBar.searchable].
  final Color? glowColor;

  /// Thickness of the icon shadow halo effect.
  ///
  /// When provided, creates a shadow halo around unselected icons for emphasis.
  /// Typical values are between 0.5 and 2.0.
  /// Only used by [GlassTabBar.bottom] and [GlassTabBar.searchable].
  final double? thickness;
}

// =============================================================================
// DividerSettings — configuration for inter-tab dividers
// =============================================================================

/// Configuration for optional vertical dividers between tabs in [GlassTabBar].
///
/// Dividers are rendered as thin vertical lines between tab items and can
/// automatically hide themselves adjacent to the active tab.
class DividerSettings {
  /// Top indent of the divider line.
  final double indent;

  /// Bottom indent of the divider line.
  final double endIndent;

  /// Width (thickness) of the divider line.
  final double thickness;

  /// Optional custom decoration. Defaults to a white 20% opacity line.
  final BoxDecoration? decoration;

  /// Duration of the show/hide animation. Defaults to 200ms.
  final Duration? duration;

  /// Curve of the show/hide animation. Defaults to [Curves.easeInOut].
  final Curve? curve;

  /// When true, dividers adjacent to the selected tab are hidden automatically.
  final bool isHideAutomatically;

  /// Creates a new [DividerSettings].
  const DividerSettings({
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
    this.decoration,
    this.duration,
    this.curve,
    this.isHideAutomatically = true,
  });

  @override
  bool operator ==(Object other) {
    return other is DividerSettings &&
        indent == other.indent &&
        endIndent == other.endIndent &&
        thickness == other.thickness &&
        decoration == other.decoration &&
        duration == other.duration &&
        curve == other.curve &&
        isHideAutomatically == other.isHideAutomatically;
  }

  @override
  int get hashCode => Object.hashAll([
        indent,
        endIndent,
        thickness,
        decoration,
        duration,
        curve,
        isHideAutomatically,
      ]);

  /// Returns a copy of this [DividerSettings] with the given fields replaced.
  DividerSettings copyWith({
    double? indent,
    double? endIndent,
    double? thickness,
    BoxDecoration? decoration,
    Duration? duration,
    Curve? curve,
    bool? isHideAutomatically,
  }) {
    return DividerSettings(
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
      thickness: thickness ?? this.thickness,
      decoration: decoration ?? this.decoration,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      isHideAutomatically: isHideAutomatically ?? this.isHideAutomatically,
    );
  }
}
