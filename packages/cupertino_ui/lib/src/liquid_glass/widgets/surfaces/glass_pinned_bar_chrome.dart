import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/widgets/surfaces/vertical_bar_title_row.dart';
import '../interactive/glass_button.dart';
import '../interactive/glass_button_group.dart';
import '../overlays/glass_modal_sheet.dart';
import 'glass_app_bar.dart' show DefaultButtonSettings, GlassAppBar;
import 'glass_bar_item.dart';
import 'glass_large_title.dart';
import 'glass_navigation_shell.dart';
import 'glass_vertical_bar.dart';
import 'shared/glass_nav_pinned_host.dart'
    show
        GlassNavBarGroup,
        GlassNavPinnedMetrics,
        fitGlassNavStripGroups,
        groupGlassNavBarItems;

/// The bar chrome to render this frame, handed to a
/// [GlassPinnedBarChrome.builder].
///
/// Drop [leading] and [actions] straight into your bar's slots. They already
/// hold the right thing for the current state: the real glass buttons while
/// the bar still owns its chrome, and same-sized unpainted placeholders once
/// the shell has taken it. Reading [hoisted] and [presenting] is only
/// necessary to draw something other than the package's own chrome.
@immutable
class GlassPinnedBarChromeData {
  /// Creates the chrome for one frame.
  const GlassPinnedBarChromeData({
    required this.leading,
    required this.actions,
    required this.hoisted,
    this.presenting,
  });

  /// The leading slot: the automatic back button, the declared leading items,
  /// their placeholders, or null where the route has neither.
  ///
  /// A single widget rather than a list, so it drops into `AppBar.leading` and
  /// [GlassAppBar.leading] unchanged; where a back button and leading items
  /// both show, it is the [Row] holding the two.
  ///
  /// Always null in iPhone Duo's vertical bar strip
  /// ([GlassVerticalBar.maybeOf]), where the back button and every item that
  /// goes vertical leave the bar for the strip.
  final Widget? leading;

  /// The trailing slot: the actions capsule, its placeholder, or empty where
  /// the route declares no actions.
  ///
  /// A [List] rather than a single widget so it drops into `AppBar.actions`
  /// and [GlassAppBar.actions] unchanged; it holds one entry per shell the
  /// items resolve to — one for a plain run, more where an item asks for its
  /// own background with [GlassBarItemBackground].
  ///
  /// In iPhone Duo's vertical bar strip it holds the items that stay
  /// horizontal instead, leading and trailing alike, which natively gather at
  /// the top-trailing corner of the content beside the title.
  final List<Widget> actions;

  /// Whether the shell has taken this route's chrome.
  ///
  /// False while the bar still draws it, and true once the shell has both
  /// accepted the registration and had a frame to render its copy. It goes
  /// false again for as long as a dialog or a modal sheet is presented over
  /// the route: the shell draws above the [Navigator] and cannot get beneath
  /// one, so the bar takes its chrome back and the presentation covers it.
  /// [leading] and [actions] already account for all of this — read it only to
  /// substitute your own chrome for the package's.
  final bool hoisted;

  /// The [GlassBarItem.sheet] whose sheet is up out of the hoisted chrome, or
  /// null.
  ///
  /// The one exception to the hand-back [hoisted] describes. The capsule a
  /// sheet morphs out of stays the shell's for as long as the sheet is up: the
  /// morph has emptied it, so nothing of it is drawn above the sheet, and
  /// handing it back would take the anchor out from under the droplet. So
  /// while this is set [hoisted] is false, [leading] and [actions] hold the
  /// real buttons for every other group, and the slot this item's group
  /// occupies keeps its placeholder. A bar drawing its own chrome leaves that
  /// capsule unpainted likewise. The instance is the one that was tapped;
  /// compare by `id` if the bar rebuilds its items.
  final GlassBarSheetItem? presenting;
}

/// Builds a bar from the chrome resolved for the current frame.
typedef GlassPinnedBarChromeBuilder = Widget Function(
  BuildContext context,
  GlassPinnedBarChromeData chrome,
);

/// Hands a route's bar chrome to the enclosing [GlassNavigationShell], and
/// builds whatever the bar should render in the meantime.
///
/// This is the registration [GlassAppBar.pinned] performs internally, exposed
/// for bars this package does not build — a Material `AppBar` carrying its own
/// backdrop, a collapsing large-title sliver, or anything else an existing
/// design system already owns. Declare the items as data once and drop the
/// resolved slots into your bar:
///
/// ```dart
/// GlassPinnedBarChrome(
///   actions: [
///     GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), onTap: _create),
///   ],
///   builder: (context, chrome) => AppBar(
///     automaticallyImplyLeading: false,
///     leading: chrome.leading,
///     actions: chrome.actions,
///     title: const Text('Repository'),
///   ),
/// )
/// ```
///
/// The slots swap themselves at the right moment. Until the shell has both
/// accepted the registration and had a frame to render its copy, they hold the
/// real glass back button and actions capsule — the same widgets the shell
/// will draw. After, they hold unpainted placeholders that lay out the real
/// content, so the bar keeps the layout it had and the title never shifts. The
/// hand-over is deliberately a frame late: at the swap both copies are static
/// and identical, so they never overlap and never both disappear.
///
/// The hand-over runs in reverse too. While a dialog or a modal sheet is
/// presented over the route the shell has nowhere valid to draw — it sits
/// above the [Navigator] the presentation was pushed into — so the slots take
/// the real buttons back and the presentation covers them along with the rest
/// of the page. The capsule a [GlassBarItem.sheet] morphs out of is the one
/// exception: the morph has emptied it, so it stays hoisted and its slot keeps
/// the placeholder until the droplet is poured back.
///
/// Where there is no shell — or the device cannot render the effect — the
/// slots simply keep the real buttons, so a bar written this way works either
/// way with no fallback of its own.
///
/// On iPhone Duo, where the shell has resolved a vertical bar strip
/// ([GlassVerticalBar]), the slots keep only the items that stay horizontal,
/// and everything else — the back button first — stacks in the strip. The
/// shell draws the strip while it has the chrome; while it has handed the
/// chrome back, this widget draws it, above its own route and below whatever
/// is presented over it.
///
/// A bar inside a presented route — a [GlassModalSheet]'s — never registers:
/// the presentation comes up over the stack the shell pins across, so it is
/// the bar's container, and the bar draws its own chrome there. In the strip
/// layout it follows the sheet's own strip.
class GlassPinnedBarChrome extends StatefulWidget {
  /// Creates a registrant that pins [leading], [actions] and an automatic
  /// back button.
  const GlassPinnedBarChrome({
    super.key,
    required this.builder,
    this.leading = const <GlassBarItem>[],
    this.actions = const <GlassBarItem>[],
    this.backButton = true,
    this.leadingItemsSupplementBackButton = false,
    this.onBack,
    this.buttonSettings,
    this.horizontalInset,
    this.platformViewBackdrop = false,
    this.largeTitleController,
    this.enabled = true,
  });

  /// Builds the bar from the chrome resolved for this frame.
  final GlassPinnedBarChromeBuilder builder;

  /// The leading bar items to pin, declared as data.
  ///
  /// A non-empty list **replaces** the automatic back button, mirroring
  /// `UINavigationItem.leftBarButtonItems` and [AppBar.leading]; set
  /// [leadingItemsSupplementBackButton] to show both.
  final List<GlassBarItem> leading;

  /// Whether [leading] appears in addition to the automatic back button rather
  /// than instead of it.
  ///
  /// Mirrors `UINavigationItem.leftItemsSupplementBackButton`, which is
  /// likewise false by default.
  final bool leadingItemsSupplementBackButton;

  /// The trailing bar items to pin, declared as data.
  ///
  /// Defaults to empty, which still pins: an empty list opts the route into
  /// the shell with a back button and no capsule, it does not opt out.
  final List<GlassBarItem> actions;

  /// Whether the automatic back button is offered to the shell.
  ///
  /// It only appears where the route can actually be popped
  /// ([ModalRoute.impliesAppBarDismissal]), so a root route never shows one,
  /// and a non-empty [leading] replaces it unless
  /// [leadingItemsSupplementBackButton] is set.
  final bool backButton;

  /// Overrides the back button's default `Navigator.maybePop()`.
  ///
  /// Set this for router-specific semantics such as go_router's
  /// `context.pop()`.
  final VoidCallback? onBack;

  /// Glass settings applied to this route's pinned chrome.
  ///
  /// Applied to the in-route buttons as well as the pinned ones, so the two
  /// look identical across the hand-over.
  final LiquidGlassSettings? buttonSettings;

  /// Inset from each screen edge to the pinned chrome, in logical pixels.
  ///
  /// Defaults to [GlassNavPinnedMetrics.horizontalPadding], the inset
  /// [GlassAppBar] uses for its own. Pass the inset **your** bar draws its
  /// capsules at, so the two land on the same guide and the hand-over between
  /// them is invisible — a bar aligned to its app's page gutter otherwise
  /// steps sideways every time a sheet hands the chrome back.
  final double? horizontalInset;

  /// Whether the bar floats over a native platform view — an iOS map, say.
  ///
  /// Forwarded to every capsule this bar draws, in-route and pinned alike, so
  /// the two look identical across the hand-over. The glass shader reads a
  /// captured backdrop the platform view is never part of, so without this a
  /// capsule over one has nothing to refract; the flag routes it to the live
  /// `BackdropFilter` instead, as [GlassButton.platformViewBackdrop] does.
  final bool platformViewBackdrop;

  /// The large title this bar collapses with, if it has one.
  ///
  /// Pass the controller the bar shares with its [GlassLargeTitle]. In
  /// iPhone Duo's vertical bar strip the title row holds the large title, so
  /// the items that stay horizontal beside it scroll away with it, and the
  /// strip hides with the rest of the bar while the title's search is open.
  /// Elsewhere it is not read.
  final GlassLargeTitleController? largeTitleController;

  /// Whether this bar participates in pinning at all.
  ///
  /// When false the widget behaves as if no shell were installed: any existing
  /// registration is dropped and the bar keeps drawing its own chrome.
  ///
  /// The shell ranks registered routes against one another, which only has
  /// meaning inside a single [Navigator]. An app with a nested navigator — a
  /// go_router `ShellRoute` for tabs, say — should therefore keep the nested
  /// stack's roots out of the shell:
  ///
  /// ```dart
  /// enabled: ModalRoute.of(context)?.impliesAppBarDismissal ?? false,
  /// ```
  final bool enabled;

  @override
  State<GlassPinnedBarChrome> createState() => _GlassPinnedBarChromeState();
}

class _GlassPinnedBarChromeState extends State<GlassPinnedBarChrome> {
  /// Shows the in-route strip in the route's own overlay, so it paints above
  /// the page and below anything presented over it.
  final OverlayPortalController _strip = OverlayPortalController()..show();

  GlassNavigationShellState? _shell;
  ModalRoute<dynamic>? _route;
  bool _handedOver = false;

  /// The sheet item whose capsule the shell has kept through its sheet, if
  /// any. See [GlassPinnedBarChromeData.presenting].
  GlassBarSheetItem? _presenting;

  /// The shell notification this bar is currently following, if any.
  Listenable? _chromeChanges;

  /// Whether this route shows the automatic back button at all.
  ///
  /// A custom leading replaces it, mirroring UIKit — *"A custom left item
  /// replaces the regular back button unless you set
  /// leftItemsSupplementBackButton to YES"* — and [AppBar], which implies a
  /// leading only when none was given. Whether the route can be popped at all
  /// is decided separately, against [ModalRoute.impliesAppBarDismissal].
  bool get _showsBack =>
      widget.backButton &&
      (widget.leading.isEmpty || widget.leadingItemsSupplementBackButton) &&
      (_route?.impliesAppBarDismissal ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(GlassPinnedBarChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final shell = GlassNavigationShell.maybeOf(context);
    final route = ModalRoute.of(context);

    if (shell != _shell || route != _route) {
      _release();
      _unfollow();
      _shell = shell;
      _route = route;
      _handedOver = false;
      _presenting = null;
      _follow();
    }

    // Deliberately no offstage or TickerMode guard here. Flutter builds a newly
    // pushed route offstage once before the transition starts, and neither
    // `offstage` nor a muted ticker notifies dependents when it flips back — so
    // skipping those builds would strand the route unregistered for the whole
    // transition. Which route is on top is decided by the shell's ordering
    // instead. (Inactive branches of a nested navigator are a known gap.)
    // A bar in a presented route — a modal sheet's — is inside the
    // presentation, which comes up over the stack the shell pins across: the
    // presentation is its container, and the bar draws its own chrome.
    if (!widget.enabled ||
        shell == null ||
        route == null ||
        route is PopupRoute ||
        !shell.isActive) {
      // Drop any stale registration, then draw the chrome in-route again.
      _release();
      if (_handedOver || _presenting != null) {
        setState(() {
          _handedOver = false;
          _presenting = null;
        });
      }
      return;
    }

    shell.register(
      route,
      GlassNavBarRegistration(
        actions: widget.actions,
        leading: widget.leading,
        showsBackButton: _showsBack,
        onBack: widget.onBack,
        buttonSettings: widget.buttonSettings,
        horizontalInset: widget.horizontalInset,
        platformViewBackdrop: widget.platformViewBackdrop,
        largeTitleController: widget.largeTitleController,
      ),
    );
  }

  /// Follows the shell's hand-over decision.
  ///
  /// The shell re-resolves on the frame *after* a registration lands or a
  /// route changes, so the hand-over is deliberately a frame late: at the swap
  /// both copies are static and identical, and they never overlap and never
  /// both disappear. The same holds in reverse when a presentation takes the
  /// chrome back — a route under a dialog or a modal sheet is not moving
  /// either.
  void _follow() {
    final shell = _shell;
    if (shell == null) return;
    _chromeChanges = shell.chromeChanges..addListener(_onChromeChanged);
  }

  void _unfollow() {
    _chromeChanges?.removeListener(_onChromeChanged);
    _chromeChanges = null;
  }

  /// Takes the shell's decision as of this notification.
  ///
  /// Deliberately snapshotted rather than read during [build]: a bar that
  /// asked the shell on every build would answer from routes the shell has not
  /// re-resolved against yet, and swap a frame before it — a frame in which
  /// both copies are on screen. Reading both from the same notification keeps
  /// them one image.
  void _onChromeChanged() {
    final shell = _shell;
    final route = _route;
    final live = widget.enabled && shell != null && route != null;
    final hoisted = live && shell.isHoisting(route);
    final presenting = live ? shell.presentingSheetItem(route) : null;
    if (mounted &&
        (hoisted != _handedOver || !identical(presenting, _presenting))) {
      setState(() {
        _handedOver = hoisted;
        _presenting = presenting;
      });
    }
  }

  void _release() {
    final shell = _shell;
    final route = _route;
    if (shell != null && route != null) {
      shell.unregister(route);
    }
  }

  @override
  void dispose() {
    _release();
    _unfollow();
    super.dispose();
  }

  /// The back button, or the space it occupied once the shell has it.
  Widget _buildBackButton(
    BuildContext context, {
    double backSize = GlassNavPinnedMetrics.backDiameter,
  }) {
    if (_handedOver) {
      return SizedBox(width: backSize, height: backSize);
    }
    return GlassButton(
      icon: const Icon(CupertinoIcons.back),
      width: backSize,
      height: backSize,
      iconSize: GlassNavPinnedMetrics.iconSize,
      platformViewBackdrop: widget.platformViewBackdrop,
      label: Localizations.of<CupertinoLocalizations>(
            context,
            CupertinoLocalizations,
          )?.backButtonLabel ??
          'Back',
      onTap: () {
        final back = widget.onBack;
        if (back != null) {
          back();
        } else {
          Navigator.of(context).maybePop();
        }
      },
    );
  }

  /// Whether [group]'s slot stays a placeholder this frame.
  ///
  /// Every group's while the shell has the chrome; only the presenting
  /// item's while it has handed the rest back for a sheet.
  bool _isPlaceholder(GlassNavBarGroup group) {
    if (_handedOver) return true;
    final presenting = _presenting;
    return presenting != null && group.contains(presenting);
  }

  /// One group of items, drawn as the shell it asked for.
  ///
  /// The morph trigger wraps both renderings and is unconditional, matching
  /// the pinned host's own wrappers: a group that gained or lost one would
  /// remount its glass and pop its backdrop, and spanning the hand-over is
  /// what lets a capsule emptied while the bar was drawn in-route stay emptied
  /// through a hoist. At rest it paints through a zero translation and a full
  /// opacity, neither of which pushes a layer.
  ///
  /// Groups enforce [TextDirection.ltr] internally so items within a capsule
  /// maintain the exact same horizontal sequence whether rendered by the
  /// shell host or handed over in-route under RTL (fixes #374). Ambient
  /// directionality is restored for individual item content.
  Widget _buildGroup(GlassNavBarGroup group) {
    final ambientDirection = Directionality.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GlassMorphTrigger(
        builder: (context, anchor) {
          if (_isPlaceholder(group)) {
            return _measuringGroup(group, ambientDirection);
          }

          VoidCallback tapOf(GlassBarActionItem item) =>
              item is GlassBarSheetItem
                  ? () => item.onPresent(anchor)
                  : item.onTap;

          if (!group.glass) {
            final item = group.items.single;
            return Semantics(
              button: true,
              label: item.label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: item.enabled ? tapOf(item) : null,
                child: SizedBox(
                  height: group.crossExtent,
                  child: Directionality(
                    textDirection: ambientDirection,
                    child: item.content,
                  ),
                ),
              ),
            );
          }
          // For a single-item separate group with a tintColor, fill the capsule
          // using GlassBodyMode.clear — direct alpha-composite tinting that
          // preserves the exact design-token hex while retaining the specular
          // and Fresnel rim, matching iOS 26's coloured bar button behaviour.
          // The tint replaces the body colour only: it starts from the bar's
          // button settings, so the capsule keeps the outline and rim its
          // neighbours get.
          final tintColor =
              group.items.length == 1 ? group.items.first.tintColor : null;
          final groupSettings = tintColor != null
              ? (DefaultButtonSettings.of(context) ??
                      const LiquidGlassSettings())
                  .copyWith(
                  glassColor: tintColor,
                  bodyMode: GlassBodyMode.clear,
                )
              : null;
          return GlassButtonGroup.icons(
            platformViewBackdrop: widget.platformViewBackdrop,
            settings: groupSettings,
            direction: group.axis,
            borderRadius: GlassNavPinnedMetrics.capsuleRadius,
            iconSize: GlassNavPinnedMetrics.iconSize,
            itemPadding: EdgeInsets.zero,
            items: [
              for (final item in group.items)
                if (item is GlassBarMenuItem)
                  GlassButtonGroupItem.menu(
                    icon: _slot(group, item, ambientDirection),
                    menuItems: item.menuItems,
                    menuAlignment: item.menuAlignment,
                    menuWidth: item.menuWidth,
                    menuHeight: item.menuHeight,
                    label: item.label,
                  )
                else
                  GlassButtonGroupItem(
                    icon: _slot(group, item, ambientDirection),
                    onTap: tapOf(item),
                    label: item.label,
                    enabled: item.enabled,
                  ),
            ],
          );
        },
      ),
    );
  }

  /// An unpainted stand-in the size of one group.
  ///
  /// The placeholder lays out the real content and simply isn't painted, so it
  /// measures exactly what the pinned cluster measures — including custom
  /// items of arbitrary width. A fixed width per item would only be correct
  /// for icons, and would mis-constrain a centred title.
  Widget _measuringGroup(
    GlassNavBarGroup group,
    TextDirection ambientDirection,
  ) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Opacity(
          opacity: 0.0,
          child: Flex(
            direction: group.axis,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in group.items)
                _slot(group, item, ambientDirection),
            ],
          ),
        ),
      ),
    );
  }

  /// One item as the pinned cluster lays it out: icons in a slot matching
  /// the group's extent, custom content at its own size.
  Widget _slot(
    GlassNavBarGroup group,
    GlassBarActionItem item,
    TextDirection ambientDirection,
  ) {
    return SizedBox(
      width: item is GlassBarCustomItem
          ? null
          : (group.axis == Axis.horizontal
              ? group.slotExtent
              : group.crossExtent),
      height: item is GlassBarCustomItem
          ? null
          : (group.axis == Axis.vertical
              ? group.slotExtent
              : group.crossExtent),
      child: Center(
        child: Directionality(
          textDirection: ambientDirection,
          child: item.content,
        ),
      ),
    );
  }

  /// The leading slot: the back button where the route shows one, followed by
  /// the declared leading groups.
  Widget? _buildLeading(BuildContext context) {
    final groups = groupGlassNavBarItems(widget.leading);
    final slot = <Widget>[
      if (_showsBack) _buildBackButton(context),
      for (final group in groups) _buildGroup(group),
    ];
    if (slot.isEmpty) return null;
    if (slot.length == 1) return slot.single;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: GlassNavPinnedMetrics.groupGap,
      children: slot,
    );
  }

  /// The trailing slot: one widget per shell the actions resolve to.
  List<Widget> _buildActions() {
    final groups = groupGlassNavBarItems(widget.actions);
    return [for (final group in groups) _buildGroup(group)];
  }

  /// The groups one side's items resolve to in the vertical strip layout:
  /// those that go into the strip, or those that stay in the horizontal row.
  List<GlassNavBarGroup> _stripGroups(
    List<GlassBarItem> items, {
    required bool vertical,
  }) {
    return groupGlassNavBarItems(
      items
          // A spacer stays on both sides, to split whichever items it is
          // between.
          .where((item) =>
              item is! GlassBarActionItem || item.goesVertical == vertical)
          .toList(),
      axis: vertical ? Axis.vertical : Axis.horizontal,
    );
  }

  /// The horizontal row's slot in the strip layout: the items that stay
  /// horizontal, leading before trailing.
  List<Widget> _buildRowActions() {
    return [
      for (final group in [
        ..._stripGroups(widget.leading, vertical: false),
        ..._stripGroups(widget.actions, vertical: false),
      ])
        _buildGroup(group),
    ];
  }

  /// The strip, drawn in-route while the shell does not have the chrome.
  ///
  /// Laid out to the pinned host's numbers, so the hand-over either way is
  /// invisible: a column [GlassVerticalBarMetrics.inset] wider than a control
  /// on each side, starting at the strip's inner edge, overflowing into the
  /// same ••• menu where the bars below leave too little room.
  ///
  /// Placed against the bar itself rather than the overlay, through
  /// [layout]. A screen's bar spans the screen from its top, so the two agree;
  /// a modal sheet's spans the sheet, so its strip stays on the sheet as the
  /// sheet presents, drags and dismisses.
  Widget _buildStrip(
    BuildContext context,
    GlassVerticalBarData bar,
    OverlayChildLayoutInfo layout,
  ) {
    const columnWidth = GlassVerticalBarMetrics.controlExtent +
        2 * GlassVerticalBarMetrics.inset;
    final columnOffset = bar.width - columnWidth;
    final trailingStrip = bar.edge == GlassVerticalBarEdge.trailing;
    final reserved = _shell?.verticalBarBottom ?? 0.0;
    final available = MediaQuery.sizeOf(context).height -
        bar.top -
        (reserved > 0
            ? reserved + GlassVerticalBarMetrics.spacing
            : bar.bottom) -
        (_showsBack
            ? GlassVerticalBarMetrics.controlExtent +
                GlassVerticalBarMetrics.spacing
            : 0.0);
    final strip = Positioned.directional(
      textDirection: Directionality.of(context),
      top: bar.top,
      start: trailingStrip ? null : columnOffset,
      end: trailingStrip ? columnOffset : null,
      width: columnWidth,
      child: VerticalBarTitleRow(
        controller: widget.largeTitleController,
        collapses: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: GlassVerticalBarMetrics.spacing,
          children: [
            if (_showsBack)
              _buildBackButton(
                context,
                backSize: GlassVerticalBarMetrics.controlExtent,
              ),
            for (final group in fitGlassNavStripGroups(
              [
                ..._stripGroups(widget.leading, vertical: true),
                ..._stripGroups(widget.actions, vertical: true),
              ],
              available,
            ))
              _buildGroup(group),
          ],
        ),
      ),
    );
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: layout.childSize.width,
          height: layout.overlaySize.height,
          child: Transform(
            transform: layout.childPaintTransform,
            child: Stack(clipBehavior: Clip.none, children: [strip]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalBar = GlassVerticalBar.maybeOf(context);
    Widget bar = widget.builder(
      context,
      GlassPinnedBarChromeData(
        leading: verticalBar == null ? _buildLeading(context) : null,
        actions: verticalBar == null ? _buildActions() : _buildRowActions(),
        hoisted: _handedOver,
        presenting: _presenting,
      ),
    );

    // Unconditional, as the group wrappers are: inserting the portal when the
    // shell hands the chrome back would remount the bar.
    bar = OverlayPortal.overlayChildLayoutBuilder(
      controller: _strip,
      overlayChildBuilder: (context, layout) =>
          verticalBar == null || _handedOver
              ? const SizedBox.shrink()
              : _buildStrip(context, verticalBar, layout),
      child: bar,
    );

    final settings = widget.buttonSettings;
    if (settings != null) {
      bar = DefaultButtonSettings(settings: settings, child: bar);
    }
    return bar;
  }
}
