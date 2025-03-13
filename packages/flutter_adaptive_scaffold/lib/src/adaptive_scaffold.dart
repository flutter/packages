// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'adaptive_layout.dart';
import 'breakpoints.dart';
import 'slot_layout.dart';

/// Spacing value of the compact breakpoint according to
/// the material 3 design spec.
const double kMaterialCompactSpacing = 0;

/// Spacing value of the medium and up breakpoint according to
/// the material 3 design spec.
const double kMaterialMediumAndUpSpacing = 24;

/// Margin value of the compact breakpoint according to the material
/// design 3 spec.
const double kMaterialCompactMargin = 16;

/// Margin value of the medium breakpoint according to the material
/// design 3 spec.
const double kMaterialMediumAndUpMargin = 24;

/// Padding value of the compact breakpoint according to the material
/// design 3 spec.
const double kMaterialPadding = 4;

/// Signature for a builder used by [AdaptiveScaffold.navigationRailDestinationBuilder] that converts a
/// [NavigationDestination] to a [NavigationRailDestination].
typedef NavigationRailDestinationBuilder = NavigationRailDestination Function(
  int index,
  NavigationDestination destination,
);

/// Implements the basic visual layout structure for
/// [Material Design 3](https://m3.material.io/foundations/adaptive-design/overview)
/// that adapts to a variety of screens.
///
/// !["Example of a display made with AdaptiveScaffold"](../../example/demo_files/adaptiveScaffold.gif)
///
/// [AdaptiveScaffold] provides a preset of layout, including positions and
/// animations, by handling macro changes in navigational elements and bodies
/// based on the current features of the screen, namely screen width and platform.
/// For example, the navigational elements would be a [BottomNavigationBar] on a
/// small mobile device or a [Drawer] on a small desktop device and a
/// [NavigationRail] on larger devices. When the app's size changes, for example
/// because its window is resized, the corresponding layout transition is animated.
/// The layout and navigation changes are dictated by "breakpoints" which can be
/// customized or overridden.
///
/// Also provides a variety of helper methods for navigational elements,
/// animations, and more.
///
/// [AdaptiveScaffold] is based on [AdaptiveLayout] but is easier to use at the
/// cost of being less customizable. Apps that would like more refined layout
/// and/or animation should use [AdaptiveLayout].
///
/// ```dart
/// AdaptiveScaffold(
///  destinations: const [
///    NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
///    NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
///    NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
///    NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
///  ],
///  smallBody: (_) => ListView.builder(
///    itemCount: children.length,
///    itemBuilder: (_, idx) => children[idx]
///  ),
///  body: (_) => GridView.count(crossAxisCount: 2, children: children),
/// ),
/// ```
///
/// See also:
///
///  * [AdaptiveLayout], which is what this widget is built upon internally and
///   acts as a more customizable alternative.
///  * [SlotLayout], which handles switching and animations between elements
///   based on [Breakpoint]s.
///  * [SlotLayout.from], which holds information regarding Widgets and the
///   desired way to animate between switches. Often used within [SlotLayout].
///  * [Design Doc](https://flutter.dev/go/adaptive-layout-foldables).
///  * [Material Design 3 Specifications] (https://m3.material.io/foundations/adaptive-design/overview).
class AdaptiveScaffold extends StatefulWidget {
  /// Returns a const [AdaptiveScaffold] by passing information down to an
  /// [AdaptiveLayout].
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.leadingUnextendedNavRail,
    this.leadingExtendedNavRail,
    this.trailingNavRail,
    this.smallBody,
    this.body,
    this.mediumLargeBody,
    this.largeBody,
    this.extraLargeBody,
    this.smallSecondaryBody,
    this.secondaryBody,
    this.mediumLargeSecondaryBody,
    this.largeSecondaryBody,
    this.extraLargeSecondaryBody,
    this.bodyRatio,
    this.smallBreakpoint = Breakpoints.small,
    this.mediumBreakpoint = Breakpoints.medium,
    this.mediumLargeBreakpoint = Breakpoints.mediumLarge,
    this.largeBreakpoint = Breakpoints.large,
    this.extraLargeBreakpoint = Breakpoints.extraLarge,
    this.drawerBreakpoint = Breakpoints.smallDesktop,
    this.internalAnimations = true,
    this.transitionDuration = const Duration(seconds: 1),
    this.bodyOrientation = Axis.horizontal,
    this.onSelectedIndexChange,
    this.useDrawer = true,
    this.appBar,
    this.navigationRailWidth = 72,
    this.extendedNavigationRailWidth = 192,
    this.appBarBreakpoint,
    this.navigationRailDestinationBuilder,
    this.groupAlignment,
  }) : assert(
          destinations.length >= 2,
          'At least two destinations are required',
        );

  /// The destinations to be used in navigation items. These are converted to
  /// [NavigationRailDestination]s and [BottomNavigationBarItem]s and inserted
  /// into the appropriate places. If passing destinations, you must also pass a
  /// selected index to be used by the [NavigationRail].
  final List<NavigationDestination> destinations;

  /// The index to be used by the [NavigationRail].
  final int? selectedIndex;

  /// Option to display a leading widget at the top of the navigation rail
  /// at the middle breakpoint.
  final Widget? leadingUnextendedNavRail;

  /// Option to display a leading widget at the top of the navigation rail
  /// at the largest breakpoint.
  final Widget? leadingExtendedNavRail;

  /// Option to display a trailing widget below the destinations of the
  /// navigation rail at the largest breakpoint.
  final Widget? trailingNavRail;

  /// The alignment of the destinations in the navigation rail.
  final double? groupAlignment;

  /// Widget to be displayed in the body slot at the smallest breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? smallBody;

  /// Widget to be displayed in the body slot at the medium breakpoint.
  ///
  /// The default displayed body.
  final WidgetBuilder? body;

  /// Widget to be displayed in the body slot at the mediumLarge breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? mediumLargeBody;

  /// Widget to be displayed in the body slot at the large breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? largeBody;

  /// Widget to be displayed in the body slot at the extraLarge breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? extraLargeBody;

  /// Widget to be displayed in the secondaryBody slot at the compact
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? smallSecondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the medium breakpoint.
  ///
  /// The default displayed secondaryBody.
  final WidgetBuilder? secondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the mediumLarge
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? mediumLargeSecondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the large
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? largeSecondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the extraLarge
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? extraLargeSecondaryBody;

  /// Defines the fractional ratio of body to the secondaryBody.
  ///
  /// For example 0.3 would mean body takes up 30% of the available space and
  /// secondaryBody takes up the rest.
  ///
  /// If this value is null, the ratio is defined so that the split axis is in
  /// the center of the screen.
  final double? bodyRatio;

  /// The breakpoint defined for the compact size, associated with mobile-like
  /// features.
  ///
  /// Defaults to [Breakpoints.small].
  final Breakpoint smallBreakpoint;

  /// The breakpoint defined for the medium size, associated with tablet-like
  /// features.
  ///
  /// Defaults to [Breakpoints.medium].
  final Breakpoint mediumBreakpoint;

  /// The breakpoint defined for the mediumLarge size, associated with desktop-like
  /// features.
  ///
  /// Defaults to [Breakpoints.mediumLarge].
  final Breakpoint mediumLargeBreakpoint;

  /// The breakpoint defined for the large size, associated with desktop-like
  /// features.
  ///
  /// Defaults to [Breakpoints.large].
  final Breakpoint largeBreakpoint;

  /// The breakpoint defined for the extraLarge size, associated with ultra-wide
  /// features.
  ///
  /// Defaults to [Breakpoints.extraLarge].
  final Breakpoint extraLargeBreakpoint;

  /// Whether or not the developer wants the smooth entering slide transition on
  /// secondaryBody.
  ///
  /// Defaults to true.
  final bool internalAnimations;

  /// Defines the duration of transition between layouts.
  ///
  /// Defaults to [Duration(seconds: 1)].
  final Duration transitionDuration;

  /// The orientation of the body and secondaryBody. Either horizontal (side by
  /// side) or vertical (top to bottom).
  ///
  /// Defaults to Axis.horizontal.
  final Axis bodyOrientation;

  /// Whether to use a [Drawer] over a [BottomNavigationBar] when not on mobile
  /// and Breakpoint is small.
  ///
  /// Defaults to true.
  final bool useDrawer;

  /// Option to override the drawerBreakpoint for the usage of [Drawer] over the
  /// usual [BottomNavigationBar].
  ///
  /// Defaults to [Breakpoints.smallDesktop].
  final Breakpoint drawerBreakpoint;

  /// An optional [Breakpoint] which overrides the [appBar] breakpoint to display
  /// an [AppBar] without depending on the drawer visibility.
  ///
  /// By default, an [AppBar] will show on [Breakpoints.smallDesktop] if [useDrawer] is set
  /// to true.
  final Breakpoint? appBarBreakpoint;

  /// Option to override the default [AppBar] when using drawer in desktop
  /// small.
  final PreferredSizeWidget? appBar;

  /// Callback function for when the index of a [NavigationRail] changes.
  final void Function(int)? onSelectedIndexChange;

  /// The width used for the internal [NavigationRail] at the medium [Breakpoint].
  final double navigationRailWidth;

  /// The width used for the internal extended [NavigationRail] at the large
  /// [Breakpoint].
  final double extendedNavigationRailWidth;

  /// Used to map NavigationDestination to NavigationRailDestination.
  final NavigationRailDestinationBuilder? navigationRailDestinationBuilder;

  /// Callback function for when the index of a [NavigationRail] changes.
  static WidgetBuilder emptyBuilder = (_) => const SizedBox();

  /// Public helper method to be used for creating a [NavigationRailDestination] from
  /// a [NavigationDestination].
  static NavigationRailDestination toRailDestination(
    NavigationDestination destination,
  ) {
    return NavigationRailDestination(
      label: Text(destination.label),
      icon: destination.icon,
      selectedIcon: destination.selectedIcon,
    );
  }

  /// Creates a Material 3 Design Spec abiding [NavigationRail] from a
  /// list of [NavigationDestination]s.
  ///
  /// Takes in a [selectedIndex] property for the current selected item in
  /// the [NavigationRail] and [extended] for whether the [NavigationRail]
  /// is extended or not.
  ///
  /// If [labelType] is null, then the default value is
  /// [NavigationRailLabelType.none].
  static Builder standardNavigationRail({
    required List<NavigationRailDestination> destinations,
    double width = 72,
    int? selectedIndex,
    bool extended = false,
    Color? backgroundColor,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    Widget? leading,
    Widget? trailing,
    void Function(int)? onDestinationSelected,
    double? groupAlignment,
    IconThemeData? selectedIconTheme,
    IconThemeData? unselectedIconTheme,
    TextStyle? selectedLabelTextStyle,
    TextStyle? unSelectedLabelTextStyle,
    NavigationRailLabelType? labelType = NavigationRailLabelType.none,
  }) {
    if (extended && width == 72) {
      width = 192;
    }
    return Builder(builder: (BuildContext context) {
      return Padding(
        padding: padding,
        child: SizedBox(
          width: width,
          height: MediaQuery.sizeOf(context).height,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      labelType: labelType,
                      leading: leading,
                      trailing: trailing,
                      onDestinationSelected: onDestinationSelected,
                      groupAlignment: groupAlignment,
                      backgroundColor: backgroundColor,
                      extended: extended,
                      selectedIndex: selectedIndex,
                      selectedIconTheme: selectedIconTheme,
                      unselectedIconTheme: unselectedIconTheme,
                      selectedLabelTextStyle: selectedLabelTextStyle,
                      unselectedLabelTextStyle: unSelectedLabelTextStyle,
                      destinations: destinations,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  /// Public helper method to be used for creating a [BottomNavigationBar] from
  /// a list of [NavigationDestination]s.
  static Builder standardBottomNavigationBar({
    required List<NavigationDestination> destinations,
    int? currentIndex,
    double iconSize = 24,
    ValueChanged<int>? onDestinationSelected,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final NavigationBarThemeData currentNavBarTheme =
            NavigationBarTheme.of(context);
        return NavigationBarTheme(
          data: currentNavBarTheme.copyWith(
            iconTheme: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                return currentNavBarTheme.iconTheme
                        ?.resolve(states)
                        ?.copyWith(size: iconSize) ??
                    IconTheme.of(context).copyWith(size: iconSize);
              },
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).removePadding(removeTop: true),
            child: NavigationBar(
              selectedIndex: currentIndex ?? 0,
              destinations: destinations,
              onDestinationSelected: onDestinationSelected,
            ),
          ),
        );
      },
    );
  }

  /// Public helper method to be used for creating a staggered grid following m3
  /// specs from a list of [Widget]s
  static Builder toMaterialGrid({
    List<Widget> widgets = const <Widget>[],
    List<Breakpoint> breakpoints = Breakpoints.all,
    double? margin,
    int? itemColumns,
  }) {
    return Builder(builder: (BuildContext context) {
      final Breakpoint? currentBreakpoint =
          Breakpoint.activeBreakpointIn(context, breakpoints);
      final double thisMargin =
          margin ?? currentBreakpoint?.margin ?? kMaterialCompactMargin;
      final int thisColumns =
          itemColumns ?? currentBreakpoint?.recommendedPanes ?? 1;

      return CustomScrollView(
        primary: false,
        controller: ScrollController(),
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(thisMargin),
              child: _BrickLayout(
                columns: thisColumns,
                columnSpacing: thisMargin,
                itemPadding: EdgeInsets.only(bottom: thisMargin),
                children: widgets,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Animation from bottom offscreen up onto the screen.
  static AnimatedWidget bottomToTop(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Animation from on the screen down off the screen.
  static AnimatedWidget topToBottom(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, 1),
      ).animate(animation),
      child: child,
    );
  }

  /// Animation from left off the screen into the screen.
  static AnimatedWidget leftOutIn(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Animation from on screen to left off screen.
  static AnimatedWidget leftInOut(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0),
      ).animate(animation),
      child: child,
    );
  }

  /// Animation from right off screen to on screen.
  static AnimatedWidget rightOutIn(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Fade in animation.
  static Widget fadeIn(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInCubic),
      child: child,
    );
  }

  /// Fade out animation.
  static Widget fadeOut(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: ReverseAnimation(animation),
        curve: Curves.easeInCubic,
      ),
      child: child,
    );
  }

  /// Keep widget on screen while it is leaving
  static Widget stayOnScreen(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 1.0).animate(animation),
      child: child,
    );
  }

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  // Global scaffold key that will help to manage drawer state.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final NavigationRailThemeData navRailTheme =
        Theme.of(context).navigationRailTheme;

    final List<NavigationRailDestination> destinations = widget.destinations
        .map((NavigationDestination destination) =>
            widget.navigationRailDestinationBuilder
                ?.call(widget.destinations.indexOf(destination), destination) ??
            AdaptiveScaffold.toRailDestination(destination))
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.drawerBreakpoint.isActive(context) && widget.useDrawer ||
              (widget.appBarBreakpoint?.isActive(context) ?? false)
          ? widget.appBar ?? AppBar()
          : null,
      drawer: widget.drawerBreakpoint.isActive(context) && widget.useDrawer
          ? Drawer(
              child: NavigationRail(
                extended: true,
                leading: widget.leadingExtendedNavRail,
                trailing: widget.trailingNavRail,
                selectedIndex: widget.selectedIndex,
                destinations: destinations,
                onDestinationSelected: _onDrawerDestinationSelected,
                backgroundColor: navRailTheme.backgroundColor,
                selectedIconTheme: navRailTheme.selectedIconTheme,
                unselectedIconTheme: navRailTheme.unselectedIconTheme,
                selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
                unselectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
                groupAlignment: widget.groupAlignment,
                labelType: navRailTheme.labelType,
              ),
            )
          : null,
      body: AdaptiveLayout(
        transitionDuration: widget.transitionDuration,
        bodyOrientation: widget.bodyOrientation,
        bodyRatio: widget.bodyRatio,
        internalAnimations: widget.internalAnimations,
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            widget.mediumBreakpoint: SlotLayout.from(
              key: const Key('primaryNavigation'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                width: widget.navigationRailWidth,
                leading: widget.leadingUnextendedNavRail,
                trailing: widget.trailingNavRail,
                selectedIndex: widget.selectedIndex,
                destinations: destinations,
                onDestinationSelected: widget.onSelectedIndexChange,
                backgroundColor: navRailTheme.backgroundColor,
                selectedIconTheme: navRailTheme.selectedIconTheme,
                unselectedIconTheme: navRailTheme.unselectedIconTheme,
                selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
                unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
                labelType: navRailTheme.labelType,
                groupAlignment: widget.groupAlignment,
              ),
            ),
            widget.mediumLargeBreakpoint: SlotLayout.from(
              key: const Key('primaryNavigation1'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                width: widget.extendedNavigationRailWidth,
                extended: true,
                leading: widget.leadingExtendedNavRail,
                trailing: widget.trailingNavRail,
                selectedIndex: widget.selectedIndex,
                destinations: destinations,
                onDestinationSelected: widget.onSelectedIndexChange,
                backgroundColor: navRailTheme.backgroundColor,
                selectedIconTheme: navRailTheme.selectedIconTheme,
                unselectedIconTheme: navRailTheme.unselectedIconTheme,
                selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
                unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
                labelType: navRailTheme.labelType,
                groupAlignment: widget.groupAlignment,
              ),
            ),
            widget.largeBreakpoint: SlotLayout.from(
              key: const Key('primaryNavigation2'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                width: widget.extendedNavigationRailWidth,
                extended: true,
                leading: widget.leadingExtendedNavRail,
                trailing: widget.trailingNavRail,
                selectedIndex: widget.selectedIndex,
                destinations: widget.destinations
                    .map((NavigationDestination destination) =>
                        AdaptiveScaffold.toRailDestination(destination))
                    .toList(),
                onDestinationSelected: widget.onSelectedIndexChange,
                backgroundColor: navRailTheme.backgroundColor,
                selectedIconTheme: navRailTheme.selectedIconTheme,
                unselectedIconTheme: navRailTheme.unselectedIconTheme,
                selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
                unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
              ),
            ),
            widget.extraLargeBreakpoint: SlotLayout.from(
              key: const Key('primaryNavigation3'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                width: widget.extendedNavigationRailWidth,
                extended: true,
                leading: widget.leadingExtendedNavRail,
                trailing: widget.trailingNavRail,
                selectedIndex: widget.selectedIndex,
                destinations: widget.destinations
                    .map((NavigationDestination destination) =>
                        AdaptiveScaffold.toRailDestination(destination))
                    .toList(),
                onDestinationSelected: widget.onSelectedIndexChange,
                backgroundColor: navRailTheme.backgroundColor,
                selectedIconTheme: navRailTheme.selectedIconTheme,
                unselectedIconTheme: navRailTheme.unselectedIconTheme,
                selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
                unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
              ),
            ),
          },
        ),
        bottomNavigation:
            !widget.drawerBreakpoint.isActive(context) || !widget.useDrawer
                ? SlotLayout(
                    config: <Breakpoint, SlotLayoutConfig>{
                      widget.smallBreakpoint: SlotLayout.from(
                        key: const Key('bottomNavigation'),
                        builder: (_) =>
                            AdaptiveScaffold.standardBottomNavigationBar(
                          currentIndex: widget.selectedIndex,
                          destinations: widget.destinations,
                          onDestinationSelected: widget.onSelectedIndexChange,
                        ),
                      ),
                    },
                  )
                : null,
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              inAnimation: AdaptiveScaffold.fadeIn,
              outAnimation: AdaptiveScaffold.fadeOut,
              builder: widget.body,
            ),
            if (widget.smallBody != null)
              widget.smallBreakpoint:
                  (widget.smallBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('smallBody'),
                          inAnimation: AdaptiveScaffold.fadeIn,
                          outAnimation: AdaptiveScaffold.fadeOut,
                          builder: widget.smallBody,
                        )
                      : null,
            if (widget.body != null)
              widget.mediumBreakpoint:
                  (widget.body != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('body'),
                          inAnimation: AdaptiveScaffold.fadeIn,
                          outAnimation: AdaptiveScaffold.fadeOut,
                          builder: widget.body,
                        )
                      : null,
            if (widget.mediumLargeBody != null)
              widget.mediumLargeBreakpoint:
                  (widget.mediumLargeBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('mediumLargeBody'),
                          inAnimation: AdaptiveScaffold.fadeIn,
                          outAnimation: AdaptiveScaffold.fadeOut,
                          builder: widget.mediumLargeBody,
                        )
                      : null,
            if (widget.largeBody != null)
              widget.largeBreakpoint:
                  (widget.largeBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('largeBody'),
                          inAnimation: AdaptiveScaffold.fadeIn,
                          outAnimation: AdaptiveScaffold.fadeOut,
                          builder: widget.largeBody,
                        )
                      : null,
            if (widget.extraLargeBody != null)
              widget.extraLargeBreakpoint:
                  (widget.extraLargeBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('extraLargeBody'),
                          inAnimation: AdaptiveScaffold.fadeIn,
                          outAnimation: AdaptiveScaffold.fadeOut,
                          builder: widget.extraLargeBody,
                        )
                      : null,
          },
        ),
        secondaryBody: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('sBody'),
              outAnimation: AdaptiveScaffold.stayOnScreen,
              builder: widget.secondaryBody,
            ),
            if (widget.smallSecondaryBody != null)
              widget.smallBreakpoint:
                  (widget.smallSecondaryBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('smallSBody'),
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          builder: widget.smallSecondaryBody,
                        )
                      : null,
            if (widget.secondaryBody != null)
              widget.mediumBreakpoint:
                  (widget.secondaryBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('sBody'),
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          builder: widget.secondaryBody,
                        )
                      : null,
            if (widget.mediumLargeSecondaryBody != null)
              widget.mediumLargeBreakpoint: (widget.mediumLargeSecondaryBody !=
                      AdaptiveScaffold.emptyBuilder)
                  ? SlotLayout.from(
                      key: const Key('mediumLargeSBody'),
                      outAnimation: AdaptiveScaffold.stayOnScreen,
                      builder: widget.mediumLargeSecondaryBody,
                    )
                  : null,
            if (widget.largeSecondaryBody != null)
              widget.largeBreakpoint:
                  (widget.largeSecondaryBody != AdaptiveScaffold.emptyBuilder)
                      ? SlotLayout.from(
                          key: const Key('largeSBody'),
                          outAnimation: AdaptiveScaffold.stayOnScreen,
                          builder: widget.largeSecondaryBody,
                        )
                      : null,
            if (widget.extraLargeSecondaryBody != null)
              widget.extraLargeBreakpoint: (widget.extraLargeSecondaryBody !=
                      AdaptiveScaffold.emptyBuilder)
                  ? SlotLayout.from(
                      key: const Key('extraLargeSBody'),
                      outAnimation: AdaptiveScaffold.stayOnScreen,
                      builder: widget.extraLargeSecondaryBody,
                    )
                  : null,
          },
        ),
      ),
    );
  }

  void _onDrawerDestinationSelected(int index) {
    if (widget.useDrawer) {
      // If [useDrawer] is true, then retrieve the current state.
      final ScaffoldState? scaffoldCurrentContext = _scaffoldKey.currentState;
      if (scaffoldCurrentContext != null) {
        if (scaffoldCurrentContext.isDrawerOpen) {
          // If drawer is open, call [closeDrawer] to dismiss drawer as per material guidelines.
          scaffoldCurrentContext.closeDrawer();
        }
      }
    }
    widget.onSelectedIndexChange?.call(index);
  }
}

class _BrickLayout extends StatelessWidget {
  const _BrickLayout({
    this.columns = 1,
    this.itemPadding = EdgeInsets.zero,
    this.columnSpacing = 0,
    required this.children,
  });

  final int columns;
  final double columnSpacing;
  final EdgeInsetsGeometry itemPadding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    int i = -1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: CustomMultiChildLayout(
            delegate: _BrickLayoutDelegate(
              columns: columns,
              columnSpacing: columnSpacing,
              itemPadding: itemPadding,
            ),
            children: children
                .map<Widget>(
                  (Widget child) => LayoutId(id: i += 1, child: child),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _BrickLayoutDelegate extends MultiChildLayoutDelegate {
  _BrickLayoutDelegate({
    this.columns = 1,
    this.columnSpacing = 0,
    this.itemPadding = EdgeInsets.zero,
  });

  final int columns;
  final EdgeInsetsGeometry itemPadding;
  final double columnSpacing;

  @override
  void performLayout(Size size) {
    final BoxConstraints looseConstraints = BoxConstraints.loose(size);
    final BoxConstraints fullWidthConstraints =
        looseConstraints.tighten(width: size.width);

    final List<Size> childSizes = <Size>[];
    int childCount = 0;
    // Count how many children we have.
    for (; hasChild(childCount); childCount += 1) {}
    final BoxConstraints itemConstraints = BoxConstraints(
      maxWidth: fullWidthConstraints.maxWidth / columns -
          columnSpacing / 2 -
          itemPadding.horizontal,
    );

    for (int i = 0; i < childCount; i += 1) {
      childSizes.add(layoutChild(i, itemConstraints));
    }

    int columnIndex = 0;
    int childId = 0;
    final double totalColumnSpacing = columnSpacing * (columns - 1);
    final double columnWidth = (size.width - totalColumnSpacing) / columns;
    final double topPadding = itemPadding.resolve(TextDirection.ltr).top;
    final List<double> columnUsage =
        List<double>.generate(columns, (int index) => topPadding);
    for (final Size childSize in childSizes) {
      positionChild(
        childId,
        Offset(
          columnSpacing * columnIndex +
              columnWidth * columnIndex +
              (columnWidth - childSize.width) / 2,
          columnUsage[columnIndex],
        ),
      );
      columnUsage[columnIndex] += childSize.height + itemPadding.vertical;
      columnIndex = (columnIndex + 1) % columns;
      childId += 1;
    }
  }

  @override
  bool shouldRelayout(_BrickLayoutDelegate oldDelegate) {
    return itemPadding != oldDelegate.itemPadding ||
        columnSpacing != oldDelegate.columnSpacing;
  }
}
