import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../src/renderer/glass_backdrop_group.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/widgets/surfaces/vertical_bar_title_row.dart';
import '../../types/glass_quality.dart';
import '../interactive/glass_button.dart';
import '../shared/glass_isolation_scope.dart';
import 'glass_bar_item.dart';
import 'glass_large_title.dart' show GlassLargeTitleController;
import 'glass_navigation_shell.dart';
import 'glass_pinned_bar_chrome.dart';
import 'glass_vertical_bar.dart';

/// A navigation bar layout widget following Apple's iOS 26 design patterns.
///
/// [GlassAppBar] renders a solid or transparent bar with leading widget,
/// centered title, and trailing actions. Glass effects belong on the
/// individual interactive elements (buttons, pills) — not the bar surface
/// itself. This matches iOS 26's navigation bar where the bar is a simple
/// layout container and glass is reserved for buttons.
///
/// ## Large-title collapse (iOS 26 pattern)
///
/// Pair with [GlassLargeTitle] and [GlassLargeTitleController] to get
/// automatic cross-fade between the large title (in the scroll view) and the
/// inline bar title — with zero boilerplate:
///
/// ```dart
/// final _titleController = GlassLargeTitleController();
///
/// GlassScaffold(
///   appBar: GlassAppBar(
///     title: Text('Chats'),
///     largeTitleController: _titleController,   // ← fades in as user scrolls
///   ),
///   body: CustomScrollView(
///     controller: _titleController.scrollController,
///     slivers: [
///       GlassLargeTitle(text: 'Chats', controller: _titleController),
///       // ... content slivers
///     ],
///   ),
/// )
/// ```
///
/// ## Transparent (default — iOS 26 style)
///
/// ```dart
/// GlassAppBar(
///   title: Text('Messages'),
///   leading: GlassButton(
///     icon: Icon(CupertinoIcons.back),
///     onTap: () => Navigator.pop(context),
///   ),
/// )
/// ```
///
/// ## Solid background (WhatsApp / Player style)
///
/// ```dart
/// GlassAppBar(
///   backgroundColor: Color(0xFF2C2C2E),
///   title: Text('Now Playing'),
///   leading: GlassButton(
///     icon: Icon(CupertinoIcons.back),
///     onTap: () => Navigator.pop(context),
///   ),
/// )
/// ```
///
/// ## Custom button settings (all buttons inherit)
///
/// ```dart
/// GlassAppBar(
///   buttonSettings: LiquidGlassSettings(
///     glassColor: Color(0x33FFFFFF),
///     thickness: 20,
///   ),
///   leading: GlassButton(...),   // inherits buttonSettings
///   actions: [GlassButton(...)], // inherits buttonSettings
/// )
/// ```
///
/// This widget implements [ObstructingPreferredSizeWidget] for use in both
/// [Scaffold.appBar] and [CupertinoPageScaffold.navigationBar].
class GlassAppBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  /// Creates a glass app bar with widget-based [leading] and [actions].
  ///
  /// The bar itself is a simple layout container with a [backgroundColor].
  /// Glass effects are rendered by individual child widgets (e.g. [GlassButton])
  /// inside the bar — not by the bar surface.
  ///
  /// A bar built this way never participates in navigation pinning: its
  /// widgets live in the route and slide with the page. Use
  /// [GlassAppBar.pinned] for the iOS 26 behaviour where the back button and
  /// actions stay put across route transitions.
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    // Whitelisted: Structural transparent default, not a Material colour.
    this.backgroundColor = const Color(0x00000000),
    this.toolbarHeight = 44.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.buttonSettings,
    this.largeTitleController,
    this.bottom,
    this.groupBackdrop = true,
  })  : pinnedActions = null,
        pinnedLeading = const <GlassBarItem>[],
        pinnedBackButton = true,
        pinnedLeadingItemsSupplementBackButton = false,
        onBack = null;

  /// Creates a glass app bar whose chrome pins above the [Navigator].
  ///
  /// Inside a [GlassNavigationShell], the automatic back button and the
  /// [actions] capsule stay put while the page slides during push and pop,
  /// morphing in place into the next route's items — the iOS 26 navigation
  /// bar behaviour. Without a shell (or where the effect cannot render) the
  /// same items render inside this bar, so screens work either way.
  ///
  /// [leading] and [actions] are declared as data ([GlassBarItem]), mirroring
  /// `UIBarButtonItem` — there is no widget-based `leading`/`actions` in this
  /// mode, because arbitrary widgets cannot be hoisted to the shell. Items
  /// sharing an id across routes morph as the same item; see
  /// [GlassBarItem.icon].
  ///
  /// The back button appears whenever the route can be popped and never on a
  /// root route. A non-empty [leading] **replaces** it — UIKit's rule for
  /// `leftBarButtonItems`, and Flutter's for [AppBar.leading], which implies a
  /// leading only when none was given. Set
  /// [leadingItemsSupplementBackButton] to show both, mirroring
  /// `UINavigationItem.leftItemsSupplementBackButton`. Set [backButton] to
  /// false to suppress the back button outright, and [onBack] to replace its
  /// default `Navigator.maybePop()` — for example with go_router's
  /// `context.pop()`.
  const GlassAppBar.pinned({
    super.key,
    this.title,
    List<GlassBarItem> leading = const [],
    List<GlassBarItem> actions = const [],
    bool backButton = true,
    bool leadingItemsSupplementBackButton = false,
    this.onBack,
    this.centerTitle = true,
    // Whitelisted: Structural transparent default, not a Material colour.
    this.backgroundColor = const Color(0x00000000),
    this.toolbarHeight = 44.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.buttonSettings,
    this.largeTitleController,
    this.bottom,
    this.groupBackdrop = true,
  })  : pinnedActions = actions,
        pinnedLeading = leading,
        pinnedBackButton = backButton,
        pinnedLeadingItemsSupplementBackButton =
            leadingItemsSupplementBackButton,
        leading = null,
        actions = null;

  // ===========================================================================
  // Properties
  // ===========================================================================

  /// The primary content of the app bar, typically a [Text] widget.
  final Widget? title;

  /// A widget to display before the title, typically a back button.
  final Widget? leading;

  /// A list of widgets to display after the title.
  final List<Widget>? actions;

  /// Whether the [title] should be centered.
  final bool centerTitle;

  /// The background color of the app bar.
  ///
  /// Defaults to [const Color(0x00000000)] to match iOS 26's transparent
  /// navigation bar pattern. Use an opaque colour for solid bars
  /// (e.g. WhatsApp conversation, music player).
  final Color backgroundColor;

  /// The height of the toolbar row (excluding [bottom]).
  ///
  /// Defaults to `44.0` to match iOS 26 navigation bar height.
  final double toolbarHeight;

  /// A widget to display at the bottom of the app bar, below the title row.
  ///
  /// Typically a [TabBar]. Must implement [PreferredSizeWidget] so the
  /// scaffold can measure the total bar height correctly.
  ///
  /// When non-null, [preferredSize] is `toolbarHeight + bottom.preferredSize.height`.
  final PreferredSizeWidget? bottom;

  /// Trailing bar items declared as data, pinned above the [Navigator] by an
  /// enclosing [GlassNavigationShell].
  ///
  /// Set by [GlassAppBar.pinned] (its `actions` parameter, defaulting to
  /// empty) and always null for the widget-based constructor — the
  /// constructor choice is what decides whether the bar participates in
  /// pinning. When a shell is present these items stay put during push and
  /// pop while the page slides beneath them, morphing in place into the next
  /// route's items; without a shell they render inside this bar as a normal
  /// glass capsule.
  final List<GlassBarItem>? pinnedActions;

  /// Leading bar items declared as data, pinned above the [Navigator] by an
  /// enclosing [GlassNavigationShell].
  ///
  /// Set by [GlassAppBar.pinned] (its `leading` parameter, defaulting to
  /// empty); always empty on the plain constructor, which uses the
  /// widget-based [leading] instead.
  final List<GlassBarItem> pinnedLeading;

  /// Whether a [GlassAppBar.pinned] bar shows the automatic back button when
  /// the route can be popped.
  ///
  /// The button is never shown on a root route, matching
  /// [ModalRoute.impliesAppBarDismissal], and a non-empty [pinnedLeading]
  /// replaces it unless [pinnedLeadingItemsSupplementBackButton] is set.
  final bool pinnedBackButton;

  /// Whether [pinnedLeading] appears in addition to the automatic back button
  /// rather than instead of it.
  ///
  /// Mirrors `UINavigationItem.leftItemsSupplementBackButton`, which is
  /// likewise false by default.
  final bool pinnedLeadingItemsSupplementBackButton;

  /// Overrides the automatic back button's action on a [GlassAppBar.pinned]
  /// bar.
  ///
  /// Defaults to `Navigator.maybePop`, which routers built on the Pages API
  /// (go_router, auto_route, beamer) handle correctly. Supply this to use a
  /// router-specific pop instead, such as `context.pop()`.
  final VoidCallback? onBack;

  /// The total preferred size of the app bar (toolbar + bottom widget).
  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  /// Whether this app bar fully obstructs the content behind it.
  ///
  /// Returns `true` only when [backgroundColor] is fully opaque (alpha = 1.0).
  /// With the default transparent background, this returns `false`, which
  /// tells [CupertinoPageScaffold] to extend the body behind the bar —
  /// matching the iOS 26 transparent navigation bar pattern.
  @override
  bool shouldFullyObstruct(BuildContext context) => backgroundColor.a >= 1.0;

  /// Padding around the app bar content.
  ///
  /// A [GlassAppBar.pinned] bar in iPhone Duo's vertical bar strip lays its
  /// title row out to [GlassVerticalBarMetrics] instead, so it lines up with
  /// the chrome the shell draws there.
  final EdgeInsetsGeometry padding;

  /// Default glass settings for buttons inside this app bar.
  ///
  /// When provided, all [GlassButton] descendants that don't specify their
  /// own `settings` will inherit these. This avoids repeating the same
  /// settings on every button in the bar.
  ///
  /// Individual buttons can still override this with their own `settings`.
  ///
  /// ```dart
  /// GlassAppBar(
  ///   buttonSettings: LiquidGlassSettings(
  ///     glassColor: Color(0x33FFFFFF),
  ///     thickness: 20,
  ///   ),
  ///   leading: GlassButton(...),   // uses buttonSettings
  ///   actions: [
  ///     GlassButton(
  ///       settings: myCustomSettings, // overrides buttonSettings
  ///       ...
  ///     ),
  ///   ],
  /// )
  /// ```
  final LiquidGlassSettings? buttonSettings;

  /// Whether the bar's glass, its leading and action buttons and the glass
  /// in [bottom], reads the backdrop together in one [GlassBackdropGroup].
  /// On Impeller with premium glass that saves a full-screen backdrop copy
  /// per button. Inside a [GlassBackdropGroup] of your own the bar joins
  /// that group instead of starting one. Defaults to true; set false to keep
  /// the bar out of any group, e.g. when glass in the bar lies over other
  /// glass of the bar.
  final bool groupBackdrop;

  /// Optional controller that drives the inline title opacity.
  ///
  /// When provided, the [title] widget is automatically wrapped in a
  /// [ListenableBuilder] that fades it **in** as [GlassLargeTitle]
  /// (the large title in the scroll view) fades **out**.
  ///
  /// This replicates iOS 26's `UINavigationBar.prefersLargeTitles` collapse
  /// behaviour with zero boilerplate. See [GlassLargeTitle] and
  /// [GlassLargeTitleController] for full usage.
  final GlassLargeTitleController? largeTitleController;

  @override
  Widget build(BuildContext context) {
    // Pinned items are registered with the shell, which decides whether it can
    // host them. Until then — and whenever there is no shell — this bar draws
    // them itself, so a screen renders correctly either way.
    if (pinnedActions != null) {
      return GlassPinnedBarChrome(
        leading: pinnedLeading,
        actions: pinnedActions!,
        backButton: pinnedBackButton,
        leadingItemsSupplementBackButton:
            pinnedLeadingItemsSupplementBackButton,
        onBack: onBack,
        buttonSettings: buttonSettings,
        largeTitleController: largeTitleController,
        builder: (context, chrome) => _buildBar(context, chrome: chrome),
      );
    }
    return _buildBar(context);
  }

  /// Builds the bar itself.
  ///
  /// A pinned bar takes its slots from [chrome], which holds real buttons
  /// until the shell has taken them and same-sized placeholders after — so the
  /// centred title is constrained identically either way and keeps sliding
  /// with the page. A widget-based bar uses its own [leading] and [actions].
  Widget _buildBar(BuildContext context, {GlassPinnedBarChromeData? chrome}) {
    final Widget? effectiveLeading = chrome == null ? leading : chrome.leading;
    final List<Widget>? effectiveActions = chrome == null
        ? actions
        : (chrome.actions.isEmpty ? null : chrome.actions);

    // In iPhone Duo's vertical bar strip only the title stays behind, leading
    // in a row at the top of the content, beside whatever items stay
    // horizontal. Only a pinned bar moves: UIKit moves the bars a container
    // owns, and the shell is this bar's container.
    final verticalBar =
        chrome == null ? null : GlassVerticalBar.maybeOf(context);

    Widget toolbarRow = SafeArea(
      bottom: false,
      child: Padding(
        padding: verticalBar == null
            ? padding
            : verticalBar.edge == GlassVerticalBarEdge.trailing
                ? EdgeInsetsDirectional.only(
                    start: verticalBar.titleInset,
                    end: GlassVerticalBarMetrics.rowInset,
                    top: verticalBar.rowTop,
                  )
                : EdgeInsetsDirectional.only(
                    start: GlassVerticalBarMetrics.rowInset,
                    end: verticalBar.titleInset,
                    top: verticalBar.rowTop,
                  ),
        child: SizedBox(
          height: verticalBar == null
              ? toolbarHeight
              : GlassVerticalBarMetrics.rowHeight,
          child: CustomMultiChildLayout(
            delegate: _ToolbarLayout(
              centerTitle: centerTitle && verticalBar == null,
              textDirection: Directionality.of(context),
            ),
            children: [
              if (effectiveLeading != null)
                LayoutId(
                  id: _ToolbarSlot.leading,
                  child: effectiveLeading,
                ),
              LayoutId(
                id: _ToolbarSlot.title,
                child: _buildTitle(context, inStrip: verticalBar != null),
              ),
              if (effectiveActions != null)
                LayoutId(
                  id: _ToolbarSlot.actions,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: effectiveActions,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // A large title in the strip's row takes the row with it as the content
    // scrolls, and hides it while its search is open.
    if (verticalBar != null) {
      toolbarRow = VerticalBarTitleRow(
        controller: largeTitleController,
        child: toolbarRow,
      );
    }

    Widget content = ColoredBox(
      color: backgroundColor,
      child: bottom != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [toolbarRow, bottom!],
            )
          : toolbarRow,
    );

    // Wrap with default button settings if provided.
    if (buttonSettings != null) {
      content = DefaultButtonSettings(
        settings: buttonSettings!,
        child: content,
      );
    }

    // Isolate the app bar so that when used in a regular Flutter Scaffold,
    // its glass buttons don't join the page-level blend group (which sits
    // behind the scrolling body), ensuring correct Z-order painting.
    // Premium is the default hint — individual buttons can still override
    // with quality: GlassQuality.standard, and GlassAdaptiveScope will
    // cap to the device ceiling regardless.
    return GlassIsolationScope(
      isolated: true,
      defaultQuality: GlassQuality.premium,
      child: GlassBackdropGroup(
        enabled: groupBackdrop,
        joinEnclosing: true,
        child: content,
      ),
    );
  }

  /// Builds the title widget, optionally driven by [largeTitleController].
  ///
  /// Applies [CupertinoThemeData.navTitleTextStyle] and a [Semantics] header
  /// node — matching [CupertinoNavigationBar]'s internal behaviour so a plain
  /// [Text] widget automatically picks up correct Cupertino typography.
  ///
  /// Alignment (centred vs. leading) is handled by the caller ([build]), not
  /// here. This method is responsible only for styling and the optional
  /// collapse-controller opacity animation.
  ///
  /// With a controller the result is wrapped in a [ListenableBuilder] so only
  /// the title opacity rebuilds on scroll, not the entire bar.
  ///
  /// In iPhone Duo's vertical bar strip ([inStrip]) a large title is drawn
  /// here rather than in the scroll view, in the large title's weight at
  /// [VerticalBarTitleRow.largeTitleFontSize], and there is no inline title to
  /// fade in: natively the row scrolls away with the content and nothing
  /// replaces it.
  Widget _buildTitle(BuildContext context, {bool inStrip = false}) {
    final largeInStrip = inStrip && largeTitleController != null;
    final textTheme = CupertinoTheme.of(context).textTheme;
    final Widget styledTitle = title == null
        ? const SizedBox.shrink()
        : DefaultTextStyle(
            style: largeInStrip
                ? textTheme.navLargeTitleTextStyle.copyWith(
                    fontSize: VerticalBarTitleRow.largeTitleFontSize,
                  )
                : textTheme.navTitleTextStyle,
            // iOS navigation titles are a single truncated line — they never
            // wrap, however little room the bar items leave them.
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            child: Semantics(header: true, child: title),
          );

    if (largeTitleController == null || largeInStrip) return styledTitle;

    return ListenableBuilder(
      listenable: largeTitleController!,
      builder: (context, _) {
        final progress = largeTitleController!.collapseProgress;
        // iOS 26 bar title behaviour: invisible during the first half of the
        // collapse, then fades in with ease-out over the second half.
        // This matches UIKit's two-phase crossfade where the bar title only
        // appears once the large title is mostly gone.
        final barProgress = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
        final barOpacity = Curves.easeOut.transform(barProgress);
        return Opacity(
          opacity: barOpacity,
          child: styledTitle,
        );
      },
    );
  }
}

/// An [InheritedWidget] that provides default [LiquidGlassSettings] for
/// descendant glass buttons.
///
/// Used by [GlassAppBar] to pass `buttonSettings` down the tree. Buttons
/// that don't specify their own `settings` can inherit these defaults.
///
/// To read the nearest ancestor's settings:
/// ```dart
/// final settings = DefaultButtonSettings.of(context);
/// ```
class DefaultButtonSettings extends InheritedWidget {
  /// Creates a default button settings scope.
  const DefaultButtonSettings({
    super.key,
    required this.settings,
    required super.child,
  });

  /// The default glass settings for descendant buttons.
  final LiquidGlassSettings settings;

  /// Returns the settings from the nearest [DefaultButtonSettings] ancestor,
  /// or `null` if none exists.
  static LiquidGlassSettings? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultButtonSettings>()
        ?.settings;
  }

  @override
  bool updateShouldNotify(DefaultButtonSettings oldWidget) =>
      settings != oldWidget.settings;
}

// ─────────────────────────────────────────────────────────────────────────────
// Toolbar layout
// ─────────────────────────────────────────────────────────────────────────────

/// Identifies each child slot in [_ToolbarLayout].
enum _ToolbarSlot { leading, title, actions }

/// A [MultiChildLayoutDelegate] that matches Apple's
/// `_CupertinoNavigationBarLayout` semantics:
///
/// * **Leading** — laid out at its natural size, pinned to the logical-start
///   edge (left in LTR, right in RTL).
/// * **Actions** — laid out at their natural size, pinned to the logical-end
///   edge.
/// * **Title (centred)** — constrained to
///   `barWidth − 2 × max(leadingWidth, actionsWidth)`, then positioned so its
///   centre coincides with `barWidth / 2`.  The equal-margin constraint
///   guarantees the title cannot overlap either button even when the sides
///   are asymmetric.
/// * **Title (leading-aligned)** — constrained to the space between the
///   leading widget and the actions widget (with an 8 px logical-start gap),
///   then pinned to the logical-start edge of that space.
///
/// RTL is handled explicitly via [textDirection]; no assumptions are made
/// about screen vs. logical coordinates.
class _ToolbarLayout extends MultiChildLayoutDelegate {
  _ToolbarLayout({
    required this.centerTitle,
    required this.textDirection,
  });

  final bool centerTitle;
  final TextDirection textDirection;

  /// Horizontal gap between the leading widget and the title.
  static const double _titleGap = 8.0;

  bool get _isLTR => textDirection == TextDirection.ltr;

  /// Returns the y-offset that vertically centres [child] inside [parent].
  static double _centreY(Size parent, Size child) =>
      ((parent.height - child.height) / 2.0).clamp(0.0, parent.height);

  @override
  void performLayout(Size size) {
    double leadingWidth = 0.0;
    double actionsWidth = 0.0;

    // ── Leading ──────────────────────────────────────────────────────────────
    if (hasChild(_ToolbarSlot.leading)) {
      final Size ls = layoutChild(
        _ToolbarSlot.leading,
        BoxConstraints.loose(size),
      );
      leadingWidth = ls.width;
      positionChild(
        _ToolbarSlot.leading,
        Offset(
          _isLTR ? 0.0 : size.width - ls.width,
          _centreY(size, ls),
        ),
      );
    }

    // ── Actions ──────────────────────────────────────────────────────────────
    if (hasChild(_ToolbarSlot.actions)) {
      final Size as = layoutChild(
        _ToolbarSlot.actions,
        BoxConstraints.loose(size),
      );
      actionsWidth = as.width;
      positionChild(
        _ToolbarSlot.actions,
        Offset(
          _isLTR ? size.width - as.width : 0.0,
          _centreY(size, as),
        ),
      );
    }

    // ── Title ─────────────────────────────────────────────────────────────────
    if (!hasChild(_ToolbarSlot.title)) return;

    if (centerTitle) {
      // Equal-margin constraint: widen the narrower side so both margins
      // equal the larger one.  This prevents the centred title from ever
      // reaching either button group.
      final double sideWidth = math.max(leadingWidth, actionsWidth);
      final double maxWidth = math.max(0.0, size.width - 2.0 * sideWidth);

      final Size ts = layoutChild(
        _ToolbarSlot.title,
        BoxConstraints(maxWidth: maxWidth, maxHeight: size.height),
      );

      // Centre on the full bar width (not just the constrained zone).
      positionChild(
        _ToolbarSlot.title,
        Offset(
          (size.width - ts.width) / 2.0,
          _centreY(size, ts),
        ),
      );
    } else {
      // Leading-aligned: title occupies the space between the two side widgets
      // with an 8 px gap when adjacent to a leading or action widget.
      //
      // In both LTR and RTL:
      //   - leading is positioned at the logical-start edge (0 in LTR, width - leadingWidth in RTL).
      //   - actions is positioned at the logical-end edge (width - actionsWidth in LTR, 0 in RTL).
      final double startOccupied = leadingWidth;
      final double endOccupied = actionsWidth;
      final double startGap = startOccupied > 0 ? _titleGap : 0.0;
      final double endGap = endOccupied > 0 ? _titleGap : 0.0;
      final double maxWidth = math.max(
        0.0,
        size.width - startOccupied - startGap - endOccupied - endGap,
      );

      final Size ts = layoutChild(
        _ToolbarSlot.title,
        BoxConstraints(maxWidth: maxWidth, maxHeight: size.height),
      );

      // Pin to logical-start edge (left in LTR, right in RTL).
      final double titleX = _isLTR
          ? startOccupied + startGap
          : size.width - startOccupied - startGap - ts.width;

      positionChild(
        _ToolbarSlot.title,
        Offset(titleX, _centreY(size, ts)),
      );
    }
  }

  @override
  bool shouldRelayout(_ToolbarLayout old) =>
      old.centerTitle != centerTitle || old.textDirection != textDirection;
}
