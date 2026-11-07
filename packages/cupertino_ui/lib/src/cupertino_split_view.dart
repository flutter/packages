// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'colors.dart';
import 'icons.dart';
import 'localizations.dart';
import 'nav_bar.dart';
import 'page_scaffold.dart';
import 'route.dart';
import 'theme.dart';

// Mirrors the curves used by CupertinoRouteTransitionMixin: one curve for a
// page entering and another for a page leaving.
const Curve _kSidebarRevealCurve = Curves.linearToEaseOut;
const Curve _kSidebarCollapseCurve = Curves.easeInToLinear;
const double _kSidebarToggleSize = 44.0;
const EdgeInsetsDirectional _kSidebarTogglePadding = EdgeInsetsDirectional.only(
  start: 16.0,
  top: 4.0,
);
const double _kSidebarToggleReservedWidth = 60.0;

enum _CupertinoSplitViewLayout { compact, overlay, split }

class _DismissSidebarIntent extends Intent {
  const _DismissSidebarIntent();
}

const String _kSidebarNavigatorRoute = '/__cupertino_split_view_sidebar__';
const String _kDetailNavigatorRoute = '/__cupertino_split_view_detail__';

/// The visibility of the columns in a [CupertinoSplitView].
///
/// This mirrors `NavigationSplitViewVisibility` from SwiftUI. A two-column
/// split view can either show both columns or only its detail column.
enum CupertinoSplitViewVisibility {
  /// Uses the platform default.
  ///
  /// In a compact-width layout the sidebar is the navigation root. In a regular
  /// layout, including iPhone landscape and iPad, this starts with only the
  /// detail column visible, matching iOS 18's `NavigationSplitView` behavior.
  automatic,

  /// Shows the sidebar and detail columns side by side.
  doubleColumn,

  /// Shows only the detail column.
  detailOnly,
}

/// Builds the detail column for a [CupertinoSplitView].
///
/// [selection] is null when no sidebar item has been selected.
typedef CupertinoSplitViewDetailBuilder<T> = Widget Function(BuildContext context, T? selection);

/// Builds route settings for a detail page pushed in compact layouts.
typedef CupertinoSplitViewRouteSettingsBuilder<T> = RouteSettings Function(T selection);

/// Builds the title used by the route pushed in compact layouts.
typedef CupertinoSplitViewTitleBuilder<T> = String Function(T selection);

/// Controls the selection and column visibility of a [CupertinoSplitView].
///
/// Passing a controller is optional. Use one when an ancestor needs to select
/// a sidebar item, reveal or collapse the sidebar, or coordinate the split view
/// with other application state. If no controller is supplied,
/// [CupertinoSplitView] creates and owns its internal controller.
///
/// When a controller is supplied, its owner is responsible for disposing it.
///
/// See also:
///
///  * [CupertinoSplitView], the widget controlled by this object.
///  * [CupertinoSplitViewVisibility], the supported column arrangements.
class CupertinoSplitViewController<T> extends ChangeNotifier {
  /// Creates a split view controller.
  ///
  /// The [initialSelection] defaults to null. The [initialColumnVisibility]
  /// defaults to [CupertinoSplitViewVisibility.automatic].
  CupertinoSplitViewController({
    T? initialSelection,
    CupertinoSplitViewVisibility initialColumnVisibility = CupertinoSplitViewVisibility.automatic,
  }) : _selection = initialSelection,
       _columnVisibility = initialColumnVisibility;

  T? _selection;
  CupertinoSplitViewVisibility _columnVisibility;

  /// The currently selected sidebar value, or null when nothing is selected.
  ///
  /// Setting this property notifies listeners. Setting it to the current value
  /// does not notify listeners.
  T? get selection => _selection;

  set selection(T? value) {
    if (_selection == value) {
      return;
    }
    _selection = value;
    notifyListeners();
  }

  /// The requested column visibility.
  ///
  /// In compact layouts the sidebar remains the navigation root regardless of
  /// this value. See [CupertinoSplitViewVisibility] for how each value is
  /// interpreted in a regular-width layout.
  ///
  /// Setting this property notifies listeners. Setting it to the current value
  /// does not notify listeners.
  CupertinoSplitViewVisibility get columnVisibility => _columnVisibility;

  set columnVisibility(CupertinoSplitViewVisibility value) {
    if (_columnVisibility == value) {
      return;
    }
    _columnVisibility = value;
    notifyListeners();
  }

  /// Shows both columns in a regular-width layout.
  ///
  /// This is a convenience for setting [columnVisibility] to
  /// [CupertinoSplitViewVisibility.doubleColumn].
  void showSidebar() {
    columnVisibility = CupertinoSplitViewVisibility.doubleColumn;
  }

  /// Shows only the detail column in a regular-width layout.
  ///
  /// This is a convenience for setting [columnVisibility] to
  /// [CupertinoSplitViewVisibility.detailOnly].
  void hideSidebar() {
    columnVisibility = CupertinoSplitViewVisibility.detailOnly;
  }

  /// Toggles the sidebar in a regular-width layout.
  ///
  /// This is a convenience for switching between
  /// [CupertinoSplitViewVisibility.doubleColumn] and
  /// [CupertinoSplitViewVisibility.detailOnly].
  void toggleSidebar() {
    switch (columnVisibility) {
      case CupertinoSplitViewVisibility.automatic:
      case CupertinoSplitViewVisibility.detailOnly:
        showSidebar();
      case CupertinoSplitViewVisibility.doubleColumn:
        hideSidebar();
    }
  }
}

/// A two-column iOS navigation split view.
///
/// A split view organizes navigation into a sidebar and a detail column. The
/// layout adapts to the available space while keeping each column's content
/// fully customizable.
///
/// By default, [CupertinoSplitView]:
///
///  * Uses a compact, single-column layout below 600 logical pixels. The
///    sidebar is the navigation root and selecting an item pushes a
///    [CupertinoPageRoute] containing the detail.
///  * Presents a 320-logical-pixel sidebar beside the detail when both
///    dimensions are at least 600 logical pixels.
///  * Presents the sidebar as a modal overlay when the width is regular but
///    the height is compact, as on an iPhone in landscape.
///  * Starts with only the detail column visible in regular-width layouts when
///    [CupertinoSplitViewVisibility.automatic] is used. Set
///    [CupertinoSplitViewVisibility.doubleColumn] to start with both columns.
///  * Shows a floating [CupertinoSplitViewToggleButton] in regular-width
///    layouts. The toggle respects the top and directional leading safe areas.
///  * Uses Cupertino page-transition curves and honors the platform's
///    reduce-motion accessibility setting.
///
/// The [sidebar] and [detailBuilder] content are intentionally not prescribed.
/// They can be any widgets, including [CupertinoPageScaffold],
/// [CupertinoSliverNavigationBar], and [CupertinoListSection.insetGrouped].
/// Sidebar widgets can use [CupertinoSplitView.of] or
/// [CupertinoSplitView.maybeOf] to access the nearest
/// [CupertinoSplitViewState], read its current selection, and select an item.
///
/// ## State management
///
/// If [controller] is null, the split view creates an internal controller using
/// [initialSelection] and [initialColumnVisibility]. The split view disposes
/// that internal controller when it is removed from the tree.
///
/// If [controller] is non-null, the split view listens to it and the owner is
/// responsible for disposing it. In that case, [initialSelection] and
/// [initialColumnVisibility] are ignored. [onSelectionChanged] and
/// [onColumnVisibilityChanged] report changes regardless of whether the
/// controller is internal or externally owned.
///
/// ## Navigation
///
/// Detail content is built directly below the enclosing [Navigator] by
/// default. To keep navigation initiated from the detail column inside that
/// column, set [useNestedNavigation] to true. See that property for details.
///
/// ## Accessibility
///
/// The sidebar and detail columns are exposed as complementary and main
/// semantic regions. An overlay sidebar blocks semantics and focus in the
/// obscured detail column, supports the Escape key and the platform back
/// action, and provides a semantic dismiss action on its scrim. The floating
/// toggle's label describes whether it will show or hide the sidebar.
///
/// The split view uses [CupertinoLocalizations] for accessibility labels. The
/// sidebar itself remains responsible for announcing selection state on
/// individual rows, for example with `Semantics(selected: isSelected, ...)`.
///
/// {@tool snippet}
/// ```dart
/// CupertinoSplitView<String>(
///   sidebar: CupertinoPageScaffold(
///     child: CustomScrollView(
///       slivers: <Widget>[
///         const CupertinoSliverNavigationBar(
///           largeTitle: Text('Mailboxes'),
///         ),
///         SliverToBoxAdapter(
///           child: CupertinoListSection.insetGrouped(
///             children: <Widget>[
///               CupertinoListTile(
///                 title: const Text('Inbox'),
///                 onTap: () {
///                   CupertinoSplitView.of<String>(context).select('inbox');
///                 },
///               ),
///             ],
///           ),
///         ),
///       ],
///     ),
///   ),
///   detailBuilder: (BuildContext context, String? selection) {
///     return Text(selection ?? 'No mailbox selected');
///   },
/// )
/// ```
/// {@end-tool}
///
/// {@example /example/lib/cupertino_split_view/cupertino_split_view.0.dart#body}
///
/// See also:
///
///  * [CupertinoSplitViewController], which controls selection and column
///    visibility from outside the widget.
///  * [CupertinoSplitViewToggleButton], the default sidebar toggle.
///  * [CupertinoPageScaffold], a typical root for each column.
class CupertinoSplitView<T> extends StatefulWidget {
  /// Creates an iOS-style two-column split view.
  ///
  /// The [sidebar] and [detailBuilder] arguments are required.
  ///
  /// If [controller] is null, [initialSelection] and
  /// [initialColumnVisibility] initialize the internally owned controller.
  /// If [controller] is non-null, those two arguments are ignored.
  const CupertinoSplitView({
    super.key,
    this.controller,
    this.initialSelection,
    this.initialColumnVisibility = CupertinoSplitViewVisibility.automatic,
    required this.sidebar,
    required this.detailBuilder,
    this.onSelectionChanged,
    this.onColumnVisibilityChanged,
    this.detailRouteSettings,
    this.detailRouteTitle,
    this.useNestedNavigation = false,
    this.sidebarWidth = 320.0,
    this.regularWidthBreakpoint = 600.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showSidebarToggle = true,
    this.sidebarToggle,
    this.sidebarToggleReservedWidth = _kSidebarToggleReservedWidth,
    this.sidebarTogglePadding = _kSidebarTogglePadding,
  }) : assert(sidebarWidth > 0.0),
       assert(regularWidthBreakpoint > 0.0),
       assert(sidebarToggleReservedWidth >= 0.0);

  /// The controller that manages selection and column visibility.
  ///
  /// If null, the split view creates and owns a controller initialized with
  /// [initialSelection] and [initialColumnVisibility].
  ///
  /// If non-null, the controller's owner must dispose it.
  final CupertinoSplitViewController<T>? controller;

  /// The initial selected sidebar value when [controller] is null.
  ///
  /// This value is ignored when [controller] is non-null.
  final T? initialSelection;

  /// The initial column visibility when [controller] is null.
  ///
  /// This value is ignored when [controller] is non-null.
  final CupertinoSplitViewVisibility initialColumnVisibility;

  /// The sidebar content.
  ///
  /// This widget is built at full width in compact layouts, at [sidebarWidth]
  /// in regular layouts, and with the leading safe-area inset included when
  /// presented as an overlay.
  final Widget sidebar;

  /// Builds the detail column.
  ///
  /// A null `selection` means that the sidebar has not selected an item. Most
  /// applications display an empty-state page in that case. The builder is
  /// called again whenever the selection changes.
  final CupertinoSplitViewDetailBuilder<T> detailBuilder;

  /// Called after the selected sidebar value changes.
  ///
  /// This callback is invoked for internal controller updates as well as
  /// updates made to an externally owned [controller].
  final ValueChanged<T?>? onSelectionChanged;

  /// Called after the requested column visibility changes.
  ///
  /// This callback is invoked for internal controller updates as well as
  /// updates made to an externally owned [controller].
  final ValueChanged<CupertinoSplitViewVisibility>? onColumnVisibilityChanged;

  /// Builds route settings for a detail page pushed in compact layouts.
  ///
  /// This is commonly used to provide a route name and arguments for
  /// deep-linking, restoration, or analytics.
  final CupertinoSplitViewRouteSettingsBuilder<T>? detailRouteSettings;

  /// Builds the route title for a detail page pushed in compact layouts.
  ///
  /// The previous route's title is used as the back-button label by
  /// [CupertinoNavigationBar].
  final CupertinoSplitViewTitleBuilder<T>? detailRouteTitle;

  /// Whether navigation started from the detail column uses nested navigation.
  ///
  /// When false (the default), detail content is built directly below the
  /// enclosing [Navigator]. Calls such as `Navigator.of(context).push(...)`
  /// therefore push onto the enclosing navigation stack, and the complete
  /// [CupertinoSplitView] takes part in the Cupertino route transition.
  ///
  /// When true, regular-width layouts give the detail column its own
  /// [Navigator] clipped to the detail bounds. Navigation performed from the
  /// detail content, including named routes, stays inside the detail column
  /// while the sidebar remains visible. Named routes are resolved with the
  /// enclosing navigator's `onGenerateRoute` and `onUnknownRoute` callbacks.
  ///
  /// System back gestures are coordinated in the same way as
  /// `showCupertinoSheet(useNestedNavigation: true)`: [NavigatorPopHandler]
  /// first pops routes from the detail navigator. Once the detail navigator is
  /// back at its root, a [PopScope] on that root route lets the pop bubble out
  /// to the enclosing navigator.
  ///
  /// In a regular-width layout, changing the selection returns the detail
  /// navigator to its root route so the newly selected item starts with a clear
  /// navigation stack.
  ///
  /// Compact layouts always use the enclosing navigator because the detail is
  /// itself presented as a page in a single-column layout.
  final bool useNestedNavigation;

  /// The content width of the sidebar in regular layouts.
  ///
  /// Defaults to 320.0 logical pixels. On iPhone landscape, the overlay also
  /// extends beneath the leading safe-area inset rather than compressing the
  /// sidebar into it.
  final double sidebarWidth;

  /// The width at or above which a non-compact layout is used.
  ///
  /// Defaults to 600.0 logical pixels. A regular-width layout with a compact
  /// height presents the sidebar as an overlay. When both dimensions are at
  /// least this value, the sidebar is laid out beside the detail.
  final double regularWidthBreakpoint;

  /// The duration of the sidebar reveal and collapse animation.
  ///
  /// Defaults to 300 milliseconds. Reveal uses [Curves.linearToEaseOut] and
  /// collapse uses [Curves.easeInToLinear], following Cupertino page
  /// transitions. The animation is skipped when the platform requests reduced
  /// motion.
  final Duration animationDuration;

  /// Whether to show the floating sidebar toggle in regular layouts.
  ///
  /// Defaults to true. The toggle is rendered once by [CupertinoSplitView]
  /// above both columns, rather than inside either page's navigation bar. It is
  /// never shown in a compact layout.
  ///
  /// Set this to false when providing an application-specific control, such as
  /// [CupertinoSplitViewToggleButton] in a navigation bar.
  final bool showSidebarToggle;

  /// An optional replacement for the floating sidebar toggle.
  ///
  /// When null, a [CupertinoSplitViewToggleButton] is used. A custom widget can
  /// call [CupertinoSplitView.maybeOf] to access [CupertinoSplitViewState] and
  /// invoke [CupertinoSplitViewState.toggleSidebar].
  ///
  /// This widget is ignored when [showSidebarToggle] is false.
  final Widget? sidebarToggle;

  /// The leading width reserved inside nested detail navigation bars while the
  /// sidebar is collapsed.
  ///
  /// Defaults to 60.0 logical pixels: the default toggle's 44.0-point tap
  /// target plus its 16.0-point leading inset. When [useNestedNavigation] is
  /// true, this width is added to the localized leading
  /// [MediaQueryData.padding] for the detail navigator so its navigation bars
  /// keep their leading content clear of the floating toggle. Set this to the
  /// width of [sidebarToggle] when supplying a custom toggle, or to zero to
  /// disable the reservation.
  final double sidebarToggleReservedWidth;

  /// The inset of the floating sidebar toggle from the localized leading edge
  /// and the top safe area.
  ///
  /// Defaults to 16.0 logical pixels from the leading safe area and 4.0 logical
  /// pixels below the top safe area.
  final EdgeInsetsDirectional sidebarTogglePadding;

  /// Returns the nearest split view state of type [T], or null if there is none.
  ///
  /// Prefer [of] when the caller requires a [CupertinoSplitView] ancestor.
  static CupertinoSplitViewState<T>? maybeOf<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoSplitViewSelectionScope<T>>()
        ?.state;
  }

  /// Returns the nearest split view state of type [T].
  ///
  /// This is intended for custom sidebar rows that need to select their value.
  /// Calling this method when there is no matching [CupertinoSplitView]
  /// ancestor results in an assertion in debug mode and an exception in release
  /// mode.
  static CupertinoSplitViewState<T> of<T>(BuildContext context) {
    final CupertinoSplitViewState<T>? state = maybeOf<T>(context);
    assert(() {
      if (state == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'CupertinoSplitView.of<$T>() was called with a context that does '
            'not contain a CupertinoSplitView<$T> widget.',
          ),
          ErrorDescription('The context used was:\n$context'),
        ]);
      }
      return true;
    }());
    return state!;
  }

  @override
  CupertinoSplitViewState<T> createState() => CupertinoSplitViewState<T>();
}

/// State for a [CupertinoSplitView].
///
/// Sidebar and detail descendants can retrieve this object with
/// [CupertinoSplitView.of] or [CupertinoSplitView.maybeOf]. The state exposes
/// the current layout, selection, and visibility, and provides methods for
/// changing the selection or toggling the sidebar.
class CupertinoSplitViewState<T> extends State<CupertinoSplitView<T>> {
  late CupertinoSplitViewController<T> _controller;
  late bool _ownsController;
  late T? _lastSelection;
  late CupertinoSplitViewVisibility _lastColumnVisibility;

  final GlobalKey<NavigatorState> _sidebarNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _detailNavigatorKey = GlobalKey<NavigatorState>();
  final HeroController _sidebarHeroController = HeroController();
  final HeroController _detailHeroController = HeroController();
  final FocusScopeNode _overlaySidebarFocusScope = FocusScopeNode(
    debugLabel: 'CupertinoSplitView sidebar overlay',
  );
  final FocusScopeNode _detailFocusScope = FocusScopeNode(debugLabel: 'CupertinoSplitView detail');

  _CupertinoSplitViewLayout _layout = _CupertinoSplitViewLayout.compact;
  bool _detailRouteOpen = false;
  bool _detailPushScheduled = false;
  T? _lastPushedSelection;
  Route<void>? _pushedRoute;

  /// Whether the split view is currently using its compact, single-column
  /// layout.
  bool get isCompact => _layout == _CupertinoSplitViewLayout.compact;

  /// Whether a non-compact layout is currently showing its sidebar.
  ///
  /// In a compact layout this is always false because the sidebar is the
  /// navigation root rather than a separately visible column.
  bool get isSidebarVisible =>
      !isCompact && _effectiveColumnVisibility != CupertinoSplitViewVisibility.detailOnly;

  /// The currently selected sidebar value, or null when nothing is selected.
  T? get selection => _controller.selection;

  /// The requested column visibility.
  CupertinoSplitViewVisibility get columnVisibility => _controller.columnVisibility;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(CupertinoSplitView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      _attachController(widget.controller);
    }
  }

  void _attachController(CupertinoSplitViewController<T>? controller) {
    _ownsController = controller == null;
    _controller =
        controller ??
        CupertinoSplitViewController<T>(
          initialSelection: widget.initialSelection,
          initialColumnVisibility: widget.initialColumnVisibility,
        );
    _lastSelection = _controller.selection;
    _lastColumnVisibility = _controller.columnVisibility;
    _controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    final T? previousSelection = _lastSelection;
    final CupertinoSplitViewVisibility previousVisibility = _lastColumnVisibility;
    _lastSelection = _controller.selection;
    _lastColumnVisibility = _controller.columnVisibility;

    if (!mounted) {
      return;
    }

    setState(() {});

    if (previousSelection != _lastSelection) {
      widget.onSelectionChanged?.call(_lastSelection);
      if (widget.useNestedNavigation && !isCompact) {
        _scheduleDetailStackReset();
      }
      if (isCompact && _lastSelection != null && _lastSelection != _lastPushedSelection) {
        _scheduleDetailPush();
      }
    }
    if (previousVisibility != _lastColumnVisibility) {
      widget.onColumnVisibilityChanged?.call(_lastColumnVisibility);
      _scheduleFocusForOverlayVisibilityChange();
    }
  }

  CupertinoSplitViewVisibility get _effectiveColumnVisibility {
    return switch (_controller.columnVisibility) {
      CupertinoSplitViewVisibility.automatic ||
      CupertinoSplitViewVisibility.detailOnly => CupertinoSplitViewVisibility.detailOnly,
      CupertinoSplitViewVisibility.doubleColumn => CupertinoSplitViewVisibility.doubleColumn,
    };
  }

  /// Selects [value], or clears the selection when [value] is null.
  ///
  /// In a compact layout this pushes the detail page. In a regular layout it
  /// updates the detail column in place.
  void select(T? value) {
    final alreadySelected = _controller.selection == value;
    _controller.selection = value;
    if (value != null && isCompact && (alreadySelected || _lastPushedSelection != value)) {
      _scheduleDetailPush(value: value);
    }
  }

  /// Shows the sidebar, or hides it when it is already visible.
  ///
  /// In a compact layout this method does nothing because navigation is handled
  /// by the surrounding [Navigator] and its [CupertinoPageRoute].
  void toggleSidebar() {
    if (isCompact) {
      return;
    }

    final CupertinoSplitViewVisibility target =
        _effectiveColumnVisibility == CupertinoSplitViewVisibility.detailOnly
        ? CupertinoSplitViewVisibility.doubleColumn
        : CupertinoSplitViewVisibility.detailOnly;
    _controller.columnVisibility = target;
  }

  void _hideSidebar() {
    if (!isCompact) {
      _controller.columnVisibility = CupertinoSplitViewVisibility.detailOnly;
    }
  }

  void _scheduleFocusForOverlayVisibilityChange() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || _layout != _CupertinoSplitViewLayout.overlay) {
        return;
      }
      final FocusScopeNode target =
          _effectiveColumnVisibility == CupertinoSplitViewVisibility.detailOnly
          ? _detailFocusScope
          : _overlaySidebarFocusScope;
      if (target.canRequestFocus) {
        target.requestFocus();
      }
    });
  }

  void _scheduleDetailPush({T? value}) {
    if (!mounted || _detailPushScheduled) {
      return;
    }
    final T? selected = value ?? _controller.selection;
    if (selected == null) {
      return;
    }
    if (_detailRouteOpen && selected == _lastPushedSelection) {
      return;
    }

    _detailPushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _detailPushScheduled = false;
      if (!mounted || !isCompact) {
        return;
      }
      if (_detailRouteOpen && selected == _lastPushedSelection) {
        return;
      }
      _pushDetail(selected);
    });
  }

  void _pushDetail(T selected) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      return;
    }

    final bool replaceCurrentRoute = _detailRouteOpen;
    final route = CupertinoPageRoute<void>(
      settings: widget.detailRouteSettings?.call(selected),
      title: widget.detailRouteTitle?.call(selected),
      builder: (BuildContext routeContext) {
        return _wrapWithScopes(
          _buildDetailSemantics(routeContext, widget.detailBuilder(routeContext, selected)),
          isCompact: true,
          isSidebarVisible: false,
        );
      },
    );

    _detailRouteOpen = true;
    _lastPushedSelection = selected;
    _pushedRoute = route;
    final Future<void> routeFuture = replaceCurrentRoute
        ? navigator.pushReplacement<void, void>(route)
        : navigator.push<void>(route);
    routeFuture.whenComplete(() {
      if (_pushedRoute == route) {
        _detailRouteOpen = false;
        _pushedRoute = null;
      }
    });
  }

  Widget _wrapWithScopes(Widget child, {required bool isCompact, required bool isSidebarVisible}) {
    return _CupertinoSplitViewScope(
      isCompact: isCompact,
      isSidebarVisible: isSidebarVisible,
      toggleSidebar: toggleSidebar,
      child: _CupertinoSplitViewSelectionScope<T>(
        state: this,
        selection: selection,
        isCompact: isCompact,
        child: child,
      ),
    );
  }

  Route<dynamic>? _generateOuterRoute(RouteSettings settings) {
    final NavigatorState? outerNavigator = Navigator.maybeOf(context);
    final Route<dynamic>? route = outerNavigator?.widget.onGenerateRoute?.call(settings);
    if (route != null) {
      return route;
    }
    return outerNavigator?.widget.onUnknownRoute?.call(settings);
  }

  Widget _buildColumnNavigator({
    required GlobalKey<NavigatorState> navigatorKey,
    required HeroController heroController,
    required String initialRouteName,
    required Widget Function(BuildContext context) contentBuilder,
    required bool isSidebarVisible,
    bool interceptInitialPop = false,
    bool handleSystemPop = false,
  }) {
    Route<void> buildInitialRoute() {
      return CupertinoPageRoute<void>(
        settings: RouteSettings(name: initialRouteName),
        builder: (BuildContext routeContext) {
          final Widget content = ListenableBuilder(
            listenable: _controller,
            builder: (BuildContext contentContext, Widget? _) {
              return contentBuilder(contentContext);
            },
          );
          if (!interceptInitialPop) {
            return content;
          }
          return PopScope<dynamic>(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if (didPop) {
                return;
              }
              _popEnclosingRoute(result);
            },
            child: content,
          );
        },
      );
    }

    Widget navigator = HeroControllerScope(
      controller: heroController,
      child: Navigator(
        key: navigatorKey,
        initialRoute: initialRouteName,
        onGenerateInitialRoutes: (NavigatorState navigator, String initialRoute) {
          return <Route<dynamic>>[buildInitialRoute()];
        },
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == initialRouteName) {
            return buildInitialRoute();
          }
          return _generateOuterRoute(settings);
        },
      ),
    );
    if (handleSystemPop) {
      navigator = NavigatorPopHandler<dynamic>(
        onPopWithResult: (dynamic _) {
          navigatorKey.currentState?.maybePop();
        },
        child: navigator,
      );
    }
    return _wrapWithScopes(navigator, isCompact: false, isSidebarVisible: isSidebarVisible);
  }

  Widget _buildDetailContent() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? _) {
        return widget.detailBuilder(context, _controller.selection);
      },
    );
  }

  Widget _buildDetailSemantics(BuildContext context, Widget child) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: CupertinoLocalizations.of(context).splitViewDetailLabel,
      role: SemanticsRole.main,
      child: FocusTraversalGroup(child: child),
    );
  }

  Widget _buildSidebarColumn(
    BuildContext context, {
    required bool isSidebarVisible,
    bool isOverlay = false,
  }) {
    Widget sidebarColumn = _buildColumnNavigator(
      navigatorKey: _sidebarNavigatorKey,
      heroController: _sidebarHeroController,
      initialRouteName: _kSidebarNavigatorRoute,
      contentBuilder: (BuildContext _) => widget.sidebar,
      isSidebarVisible: isSidebarVisible,
    );
    if (isOverlay) {
      sidebarColumn = FocusScope(node: _overlaySidebarFocusScope, child: sidebarColumn);
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: CupertinoLocalizations.of(context).splitViewSidebarLabel,
      role: SemanticsRole.complementary,
      child: FocusTraversalGroup(child: sidebarColumn),
    );
  }

  Widget _buildDetailColumn(
    BuildContext context, {
    required bool isSidebarVisible,
    double navigationBarLeadingInset = 0.0,
  }) {
    Widget detailColumn;
    if (!widget.useNestedNavigation) {
      detailColumn = _wrapWithScopes(
        _buildDetailContent(),
        isCompact: false,
        isSidebarVisible: isSidebarVisible,
      );
    } else {
      detailColumn = _buildColumnNavigator(
        navigatorKey: _detailNavigatorKey,
        heroController: _detailHeroController,
        initialRouteName: _kDetailNavigatorRoute,
        contentBuilder: (BuildContext _) => _buildDetailContent(),
        isSidebarVisible: isSidebarVisible,
        interceptInitialPop: true,
        handleSystemPop: true,
      );
    }

    detailColumn = FocusScope(
      node: _detailFocusScope,
      child: _buildDetailSemantics(context, detailColumn),
    );
    if (!widget.useNestedNavigation ||
        !widget.showSidebarToggle ||
        navigationBarLeadingInset <= 0.0) {
      return detailColumn;
    }

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: isRtl
            ? mediaQuery.padding.copyWith(
                right: mediaQuery.padding.right + navigationBarLeadingInset,
              )
            : mediaQuery.padding.copyWith(
                left: mediaQuery.padding.left + navigationBarLeadingInset,
              ),
      ),
      child: detailColumn,
    );
  }

  void _popEnclosingRoute(dynamic result) {
    final NavigatorState? enclosingNavigator = Navigator.maybeOf(context);
    if (enclosingNavigator == null || !enclosingNavigator.canPop()) {
      return;
    }
    enclosingNavigator.pop<dynamic>(result);
  }

  void _scheduleDetailStackReset() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || isCompact || !widget.useNestedNavigation) {
        return;
      }
      _detailNavigatorKey.currentState?.popUntil((Route<dynamic> route) {
        return route.isFirst;
      });
    });
  }

  Widget? _buildFloatingToggle(
    BuildContext context, {
    required bool isSidebarVisible,
    bool visible = true,
  }) {
    if (!widget.showSidebarToggle || !visible) {
      return null;
    }

    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    final double safeAreaStart = Directionality.of(context) == TextDirection.rtl
        ? safeAreaPadding.right
        : safeAreaPadding.left;
    return PositionedDirectional(
      start: safeAreaStart + widget.sidebarTogglePadding.start,
      top: safeAreaPadding.top + widget.sidebarTogglePadding.top,
      child: _wrapWithScopes(
        widget.sidebarToggle ??
            const CupertinoSplitViewToggleButton(
              key: ValueKey<String>('cupertino-split-view-toggle'),
            ),
        isCompact: false,
        isSidebarVisible: isSidebarVisible,
      ),
    );
  }

  Widget _buildOverlayLayout(
    BuildContext context, {
    required bool showSidebar,
    required double availableWidth,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);
    final double safeAreaStart = isRtl ? safeAreaPadding.right : safeAreaPadding.left;
    final double availableContentWidth = availableWidth > safeAreaStart
        ? availableWidth - safeAreaStart
        : 0.0;
    final double contentWidth = widget.sidebarWidth < availableContentWidth
        ? widget.sidebarWidth
        : availableContentWidth;
    final double sidebarWidth = contentWidth + safeAreaStart;
    final Widget? floatingToggle = _buildFloatingToggle(
      context,
      isSidebarVisible: showSidebar,
      visible: !showSidebar,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: showSidebar ? 1.0 : 0.0),
      duration: _effectiveAnimationDuration(context),
      curve: showSidebar ? _kSidebarRevealCurve : _kSidebarCollapseCurve,
      builder: (BuildContext context, double progress, Widget? _) {
        final Widget detail = ExcludeSemantics(
          excluding: showSidebar,
          child: ExcludeFocus(
            excluding: showSidebar,
            child: _buildDetailColumn(
              context,
              isSidebarVisible: showSidebar,
              navigationBarLeadingInset: widget.sidebarToggleReservedWidth * (1.0 - progress),
            ),
          ),
        );

        final Widget stack = Stack(
          children: <Widget>[
            Positioned.fill(child: detail),
            if (progress > 0.0) ...<Widget>[
              Positioned.fill(
                child: BlockSemantics(
                  child: Semantics(
                    button: true,
                    excludeSemantics: true,
                    label: CupertinoLocalizations.of(context).splitViewDismissSidebarButtonLabel,
                    onTap: _hideSidebar,
                    child: GestureDetector(
                      key: const ValueKey<String>('cupertino-split-view-sidebar-scrim'),
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      onTap: _hideSidebar,
                      child: ColoredBox(
                        color: CupertinoColors.black.withValues(alpha: 0.2 * progress),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 0.0,
                top: 0.0,
                bottom: 0.0,
                width: sidebarWidth,
                child: FractionalTranslation(
                  translation: Offset(isRtl ? 1.0 - progress : progress - 1.0, 0.0),
                  child: KeyedSubtree(
                    key: const ValueKey<String>('cupertino-split-view-sidebar-overlay'),
                    child: _buildSidebarColumn(context, isSidebarVisible: true, isOverlay: true),
                  ),
                ),
              ),
            ],
            ?floatingToggle,
          ],
        );

        if (!showSidebar) {
          return stack;
        }

        return Semantics(
          container: true,
          explicitChildNodes: true,
          scopesRoute: true,
          namesRoute: true,
          label: CupertinoLocalizations.of(context).splitViewSidebarLabel,
          child: stack,
        );
      },
    );
  }

  Widget _buildSplitLayout(
    BuildContext context, {
    required bool showSidebar,
    required double availableWidth,
  }) {
    final double sidebarWidth = widget.sidebarWidth < availableWidth
        ? widget.sidebarWidth
        : availableWidth;
    final targetWidth = showSidebar ? sidebarWidth : 0.0;

    final Widget splitContent = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetWidth),
      duration: _effectiveAnimationDuration(context),
      curve: _curveForSidebarVisibility(showSidebar),
      builder: (BuildContext context, double width, Widget? _) {
        final bool sidebarFullyVisible = width >= sidebarWidth - 0.01;
        final double navigationBarLeadingInset = widget.sidebarToggleReservedWidth > width
            ? widget.sidebarToggleReservedWidth - width
            : 0.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (width > 0.0) ...<Widget>[
              SizedBox(
                width: width,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: AlignmentDirectional.centerStart,
                    minWidth: sidebarWidth,
                    maxWidth: sidebarWidth,
                    child: _buildSidebarColumn(context, isSidebarVisible: sidebarFullyVisible),
                  ),
                ),
              ),
              const _CupertinoSplitViewDivider(
                key: ValueKey<String>('cupertino-split-view-divider'),
              ),
            ],
            Expanded(
              child: _buildDetailColumn(
                context,
                isSidebarVisible: sidebarFullyVisible,
                navigationBarLeadingInset: navigationBarLeadingInset,
              ),
            ),
          ],
        );
      },
    );

    final Widget? floatingToggle = _buildFloatingToggle(context, isSidebarVisible: showSidebar);
    if (floatingToggle == null) {
      return splitContent;
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(child: splitContent),
        floatingToggle,
      ],
    );
  }

  Curve _curveForSidebarVisibility(bool visible) {
    return visible ? _kSidebarRevealCurve : _kSidebarCollapseCurve;
  }

  Duration _effectiveAnimationDuration(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : widget.animationDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): _DismissSidebarIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _DismissSidebarIntent: CallbackAction<_DismissSidebarIntent>(
            onInvoke: (_DismissSidebarIntent intent) {
              if (_layout == _CupertinoSplitViewLayout.overlay && isSidebarVisible) {
                _hideSidebar();
              }
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size viewSize = MediaQuery.sizeOf(context);
              final double availableWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : viewSize.width;
              final double availableHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : viewSize.height;

              if (availableWidth < widget.regularWidthBreakpoint) {
                _layout = _CupertinoSplitViewLayout.compact;
              } else if (availableHeight < widget.regularWidthBreakpoint) {
                _layout = _CupertinoSplitViewLayout.overlay;
              } else {
                _layout = _CupertinoSplitViewLayout.split;
              }

              Widget content;
              if (isCompact) {
                if (_controller.selection != null &&
                    _lastPushedSelection != _controller.selection) {
                  _scheduleDetailPush();
                }
                content = _wrapWithScopes(widget.sidebar, isCompact: true, isSidebarVisible: true);
              } else {
                final showSidebar =
                    _effectiveColumnVisibility != CupertinoSplitViewVisibility.detailOnly;
                content = switch (_layout) {
                  _CupertinoSplitViewLayout.overlay => _buildOverlayLayout(
                    context,
                    showSidebar: showSidebar,
                    availableWidth: availableWidth,
                  ),
                  _CupertinoSplitViewLayout.split => _buildSplitLayout(
                    context,
                    showSidebar: showSidebar,
                    availableWidth: availableWidth,
                  ),
                  _CupertinoSplitViewLayout.compact => throw StateError(
                    'Compact layout is handled before the regular layout '
                    'switch.',
                  ),
                };
                if (_layout == _CupertinoSplitViewLayout.overlay) {
                  content = PopScope<dynamic>(
                    canPop: !showSidebar,
                    onPopInvokedWithResult: (bool didPop, dynamic result) {
                      if (!didPop && showSidebar) {
                        _hideSidebar();
                      }
                    },
                    child: content,
                  );
                }
              }

              return content;
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _sidebarHeroController.dispose();
    _detailHeroController.dispose();
    _overlaySidebarFocusScope.dispose();
    _detailFocusScope.dispose();
    super.dispose();
  }
}

/// A button that reveals or collapses a [CupertinoSplitView].
///
/// This widget must be a descendant of a [CupertinoSplitView].
///
/// In a compact layout it renders a [CupertinoNavigationBarBackButton] when the
/// current detail route can be popped. In a regular-width layout it renders a
/// [CupertinoButton] whose label and icon describe whether the sidebar will be
/// shown or hidden.
///
/// [CupertinoSplitView] uses this button for its floating toggle by default.
/// To place the toggle inside a navigation bar instead, set
/// [CupertinoSplitView.showSidebarToggle] to false and add this widget to the
/// desired navigation bar.
class CupertinoSplitViewToggleButton extends StatelessWidget {
  /// Creates a split view navigation-bar toggle button.
  const CupertinoSplitViewToggleButton({
    super.key,
    this.previousPageTitle,
    this.icon,
    this.color,
    this.semanticLabel,
  });

  /// The title shown next to the back chevron in a compact layout.
  ///
  /// This is passed to [CupertinoNavigationBarBackButton]. It is ignored in a
  /// regular-width layout.
  final String? previousPageTitle;

  /// The icon used in a regular-width layout.
  ///
  /// When null, the icon follows the ambient [TextDirection]:
  /// [CupertinoIcons.sidebar_left] is used in left-to-right layouts and
  /// [CupertinoIcons.sidebar_right] is used in right-to-left layouts.
  final IconData? icon;

  /// The icon color. Defaults to the Cupertino theme's primary color.
  final Color? color;

  /// An optional semantic label override for the regular-width button.
  ///
  /// When null, the label is selected from [CupertinoLocalizations] based on
  /// whether the sidebar is currently visible. The compact back button
  /// continues to use the standard Cupertino back-button semantics.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final _CupertinoSplitViewScope? scope = context
        .dependOnInheritedWidgetOfExactType<_CupertinoSplitViewScope>();

    assert(() {
      if (scope == null) {
        throw FlutterError(
          'CupertinoSplitViewToggleButton requires a CupertinoSplitView '
          'ancestor, but none was found.\n'
          'This widget must be built inside the sidebar or detail content of '
          'a CupertinoSplitView.',
        );
      }
      return true;
    }());
    if (scope == null) {
      return const SizedBox.shrink();
    }

    if (scope.isCompact) {
      if (!Navigator.canPop(context)) {
        return const SizedBox.shrink();
      }
      return CupertinoNavigationBarBackButton(previousPageTitle: previousPageTitle);
    }

    final CupertinoLocalizations localizations = CupertinoLocalizations.of(context);
    final String effectiveSemanticLabel =
        semanticLabel ??
        (scope.isSidebarVisible
            ? localizations.splitViewHideSidebarButtonLabel
            : localizations.splitViewShowSidebarButtonLabel);
    final IconData effectiveIcon =
        icon ??
        (Directionality.of(context) == TextDirection.rtl
            ? CupertinoIcons.sidebar_right
            : CupertinoIcons.sidebar_left);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(_kSidebarToggleSize),
      sizeStyle: CupertinoButtonSize.medium,
      onPressed: scope.toggleSidebar,
      child: Semantics(
        excludeSemantics: true,
        label: effectiveSemanticLabel,
        child: Icon(effectiveIcon, color: color ?? CupertinoTheme.of(context).primaryColor),
      ),
    );
  }
}

class _CupertinoSplitViewScope extends InheritedWidget {
  const _CupertinoSplitViewScope({
    required this.isCompact,
    required this.isSidebarVisible,
    required this.toggleSidebar,
    required super.child,
  });

  final bool isCompact;
  final bool isSidebarVisible;
  final VoidCallback toggleSidebar;

  @override
  bool updateShouldNotify(_CupertinoSplitViewScope oldWidget) {
    return isCompact != oldWidget.isCompact ||
        isSidebarVisible != oldWidget.isSidebarVisible ||
        toggleSidebar != oldWidget.toggleSidebar;
  }
}

class _CupertinoSplitViewSelectionScope<T> extends InheritedWidget {
  const _CupertinoSplitViewSelectionScope({
    required this.state,
    required this.selection,
    required this.isCompact,
    required super.child,
  });

  final CupertinoSplitViewState<T> state;
  final T? selection;
  final bool isCompact;

  @override
  bool updateShouldNotify(_CupertinoSplitViewSelectionScope<T> oldWidget) {
    return state != oldWidget.state ||
        selection != oldWidget.selection ||
        isCompact != oldWidget.isCompact;
  }
}

class _CupertinoSplitViewDivider extends StatelessWidget {
  const _CupertinoSplitViewDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final divider = BorderSide(
      color: CupertinoColors.separator.resolveFrom(context),
      width: 1.0 / MediaQuery.devicePixelRatioOf(context),
    );
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(right: divider)),
      child: SizedBox(width: divider.width),
    );
  }
}
