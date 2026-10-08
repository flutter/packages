import 'package:flutter/widgets.dart';

import '../overlays/glass_menu.dart';
import '../overlays/glass_modal_sheet.dart';
import 'glass_navigation_shell.dart';
import 'glass_vertical_bar.dart';

/// How an item's glass background is drawn.
///
/// Mirrors the two booleans iOS 26 added to `UIBarButtonItem`:
/// `sharesBackground` (default `YES`) and `hidesSharedBackground` (default
/// `NO`). Their four combinations describe three distinct results, which are
/// the first three values here; [own] is [none] for content that is itself
/// glass.
///
/// Both are documented as being ignored for an item inside an explicit group
/// of more than one; the equivalent here is that [GlassBarItemBackground.shared]
/// is the only value that lets an item join its neighbours.
enum GlassBarItemBackground {
  /// The item joins one glass capsule with its neighbours.
  ///
  /// `sharesBackground = YES` — the default, and the only value that groups.
  shared,

  /// The item gets a glass capsule of its own, sharing with nothing.
  ///
  /// `sharesBackground = NO`. A lone icon in its own capsule is the circular
  /// button iOS 26 draws for a single bar item.
  separate,

  /// No glass is drawn behind the item at all.
  ///
  /// `hidesSharedBackground = YES`. For content that carries its own shape —
  /// a profile photo, a coloured badge — where a capsule behind it would read
  /// as a second, competing surface.
  none,

  /// The item's content is itself a glass surface.
  ///
  /// `hidesSharedBackground = YES`, as [none] — but the pinned chrome fades
  /// and blurs ordinary content under opacity and image-filter layers, and a
  /// glass surface painted under either has no backdrop to sample. An [own]
  /// item dissolves through its surface's own visibility instead, the channel
  /// `GlassMaterialize` uses. Two such items matched across a route change
  /// take turns rather than cross-fading, since each would sample the other.
  /// For a capsule built from `GlassButton.custom`; plain content stays
  /// [none].
  own,
}

/// Whether an item moves into iPhone Duo's vertical bar strip.
///
/// Mirrors SwiftUI's `ToolbarItem.axisBehavior(_:)`. Only read where a
/// [GlassNavigationShell] has resolved a strip; see [GlassVerticalBar].
enum GlassBarItemAxisBehavior {
  /// The system decides, as natively: icons go vertical, and custom content
  /// stays behind in a horizontal capsule at the top-trailing corner of the
  /// content, beside the title.
  ///
  /// [GlassBarItem.icon], [GlassBarItem.menu] and [GlassBarItem.sheet] go
  /// vertical; [GlassBarItem.custom] stays horizontal.
  automatic,

  /// The item stays in the horizontal capsule even where its kind would go
  /// vertical.
  horizontalOnly,

  /// The item goes vertical even where its kind would stay horizontal.
  ///
  /// For [GlassBarItem.custom] content that works squeezed to the strip's
  /// 48pt width — an unread count, a small avatar. It is laid out at that
  /// width and whatever height it asks for.
  verticalPreferred,
}

/// A single item in a pinned navigation-bar cluster.
///
/// Mirrors UIKit's `UIBarButtonItem`: items are declared as **data**, and the
/// system owns their placement. There is deliberately no way to offset or
/// reposition a cluster — iOS 26 provides no such API either, and the only
/// lever it does provide (splitting the shared background) is modelled by
/// [GlassBarItem.spacer].
///
/// That constraint is what makes custom content simple: a custom widget is an
/// *item*, so the cluster measures and lays itself out around it. A screen
/// never has to tell the bar to make room.
///
/// ```dart
/// GlassAppBar.pinned(
///   title: const Text('Repository'),
///   actions: [
///     GlassBarItem.icon(icon: const Icon(CupertinoIcons.add), id: 'add', onTap: _add),
///     GlassBarItem.custom(child: UnreadPill(count: 3), onTap: _openInbox),
///   ],
/// )
/// ```
sealed class GlassBarItem {
  /// Const base constructor for the sealed hierarchy.
  const GlassBarItem();

  /// An icon button inside the pinned cluster.
  ///
  /// [id] mirrors `UIBarButtonItem.identifier`: items that share an [id]
  /// across two routes are treated as the *same* item during a navigation
  /// transition, so the item stays put while everything around it morphs.
  /// When [id] is null, items are matched positionally from the trailing
  /// edge — the same heuristic UIKit documents as its default.
  const factory GlassBarItem.icon({
    required Widget icon,
    required VoidCallback onTap,
    Object? id,
    String? label,
    bool enabled,
    GlassBarItemBackground background,
    Color? tintColor,
    GlassBarItemAxisBehavior axisBehavior,
  }) = GlassBarIconItem;

  /// An arbitrary widget inside the pinned cluster.
  ///
  /// Equivalent to `UIBarButtonItem(customView:)`. The widget is measured at
  /// its intrinsic width during layout and the capsule sizes itself around it,
  /// so it participates in the pinned morph exactly like an icon does — it
  /// stays put while the page slides, and animates between routes.
  ///
  /// Constrained to the cluster's height; give the child its own padding if it
  /// needs breathing room. Supply [id] to keep it matched across routes.
  ///
  /// [onTap] is optional here, unlike on [GlassBarItem.icon]: a custom view is
  /// as often a status readout as it is a button, and one that handles its own
  /// gestures wants the cluster to stay out of the way.
  const factory GlassBarItem.custom({
    required Widget child,
    VoidCallback onTap,
    Object? id,
    String? label,
    bool enabled,
    GlassBarItemBackground background,
    Color? tintColor,
    GlassBarItemAxisBehavior axisBehavior,
  }) = GlassBarCustomItem;

  /// An icon that opens a [GlassMenu] pull-down, mirroring
  /// `UIBarButtonItem.menu` — the standard iOS 26 overflow button.
  ///
  /// The whole capsule morphs into the menu rather than just the icon's slot,
  /// matching iOS 26's `GlassEffectContainer` behaviour and
  /// [GlassButtonGroupItem.menu]. Only the first menu item in a cluster opens
  /// a menu; a second is treated as a plain icon.
  ///
  /// [menuItems] takes [GlassMenuItem] and [GlassMenuDivider] widgets — the
  /// same contract as [GlassMenu.items]. An open menu is dismissed if
  /// navigation starts underneath it.
  const factory GlassBarItem.menu({
    required Widget icon,
    required List<Widget> menuItems,
    GlassMenuAlignment? menuAlignment,
    double menuWidth,
    double? menuHeight,
    Object? id,
    String? label,
    GlassBarItemBackground background,
    Color? tintColor,
    GlassBarItemAxisBehavior axisBehavior,
  }) = GlassBarMenuItem;

  /// An icon whose tap presents a `GlassModalSheet` that morphs out of the
  /// capsule, mirroring the iOS 26 bar button that grows into a sheet.
  ///
  /// [onPresent] is handed the [GlassMorphAnchor] of the capsule this item
  /// sits in; pass it to `GlassModalSheet.show(morphFrom:)` and the capsule
  /// empties, stretches into the sheet, and is poured back on dismissal. It is
  /// the capsule rather than the icon's own slot for the reason
  /// [GlassBarItem.menu] morphs the whole capsule: on screen the cluster is one
  /// control, and a droplet crawling out of a hole in it reads as a second
  /// object arriving.
  ///
  /// The anchor is the capsule actually on screen: the route's own where the
  /// bar draws in-route, and the hoisted copy under a `GlassNavigationShell`.
  /// A presentation hands the chrome back to its route, but the shell keeps
  /// this capsule through the sheet — the morph has emptied it, so nothing of
  /// it is drawn above the sheet, and the droplet has somewhere to come home
  /// to. It is the group's own box where the group draws no glass
  /// ([GlassBarItemBackground.none] and [GlassBarItemBackground.own]).
  ///
  /// [onPresent] may take its time — measure the sheet's content, await a
  /// fetch: the shell keeps the capsule on the strength of the tap until a
  /// route is presented over this one, and lets go only if that presentation
  /// arrives without the morph.
  ///
  /// Dismiss the sheet before navigating, as an open [GlassMenu] is dismissed
  /// for you.
  const factory GlassBarItem.sheet({
    required Widget icon,
    required void Function(GlassMorphAnchor? anchor) onPresent,
    Object? id,
    String? label,
    bool enabled,
    GlassBarItemBackground background,
    Color? tintColor,
    GlassBarItemAxisBehavior axisBehavior,
  }) = GlassBarSheetItem;

  /// Splits the shared glass background, mirroring SwiftUI's
  /// `ToolbarSpacer(.fixed)` and UIKit's `UIBarButtonItem.fixedSpace`.
  ///
  /// Items on either side of a spacer render in separate glass capsules, the
  /// standard gap apart. Across a route transition each capsule follows its
  /// items, matched by `id` where they have one, and a capsule that only one
  /// route has buds out of the one beside it, or merges back into it.
  const factory GlassBarItem.spacer() = GlassBarSpacer;
}

/// An item that renders content and can be tapped.
///
/// The shared supertype of [GlassBarIconItem] and [GlassBarCustomItem], so the
/// cluster can match, measure and lay out both kinds uniformly.
sealed class GlassBarActionItem extends GlassBarItem {
  /// Const base constructor.
  const GlassBarActionItem({
    required this.onTap,
    this.id,
    this.label,
    this.enabled = true,
    this.background = GlassBarItemBackground.shared,
    this.tintColor,
    this.axisBehavior = GlassBarItemAxisBehavior.automatic,
  });

  /// The tap handler for items that do not want one, mirroring
  /// `GlassButtonGroupItem.menu`.
  static void _noOp() {}

  /// Called when the item is tapped.
  ///
  /// Never null: an icon in a navigation bar that does nothing is a bug, so
  /// [GlassBarItem.icon] requires one. Passive [GlassBarItem.custom] content
  /// gets an internal no-op instead, keeping every reader of it callable.
  /// [GlassBarItem.menu] does the same — its tap opens the menu, which the
  /// cluster drives directly.
  final VoidCallback onTap;

  /// Identity used to match this item against items on other routes.
  ///
  /// See [GlassBarItem.icon] for the matching rules.
  final Object? id;

  /// Optional semantic label.
  final String? label;

  /// Whether the item responds to taps. Disabled items render dimmed.
  final bool enabled;

  /// How this item's glass background is drawn.
  ///
  /// Defaults to [GlassBarItemBackground.shared], so items form one capsule.
  final GlassBarItemBackground background;

  /// Tints the entire glass capsule with this colour, matching iOS 26's
  /// `.tint()` modifier on a prominent bar button.
  ///
  /// When non-null, the host widget fills the glass body with this colour
  /// (using [GlassBodyMode.clear] for accurate on-screen hex fidelity) and
  /// automatically adjusts the foreground icon/label to high-contrast white
  /// or black based on the colour's luminance.
  ///
  /// **Only effective for [GlassBarItemBackground.separate] items.** A shared
  /// capsule is a single glass mesh — tinting one slot while leaving others
  /// clear is not supported. In debug mode, setting [tintColor] on a
  /// [GlassBarItemBackground.shared] item asserts.
  final Color? tintColor;

  /// Whether this item moves into iPhone Duo's vertical bar strip.
  ///
  /// Defaults to [GlassBarItemAxisBehavior.automatic]. Only read where a
  /// [GlassNavigationShell] has resolved a strip.
  final GlassBarItemAxisBehavior axisBehavior;

  /// Whether this item goes into the vertical strip where there is one.
  ///
  /// Resolves [GlassBarItemAxisBehavior.automatic] by kind: everything but
  /// custom content does.
  bool get goesVertical => switch (axisBehavior) {
        GlassBarItemAxisBehavior.verticalPreferred => true,
        GlassBarItemAxisBehavior.horizontalOnly => false,
        GlassBarItemAxisBehavior.automatic => this is! GlassBarCustomItem,
      };

  /// The widget rendered inside the cluster.
  Widget get content;
}

/// An icon item in a pinned navigation-bar cluster.
///
/// Created via [GlassBarItem.icon].
final class GlassBarIconItem extends GlassBarActionItem {
  /// Creates an icon item. Prefer [GlassBarItem.icon].
  const GlassBarIconItem({
    required this.icon,
    required super.onTap,
    super.id,
    super.label,
    super.enabled,
    super.background,
    super.tintColor,
    super.axisBehavior,
  });

  /// The icon widget, typically an [Icon].
  ///
  /// Size and colour are applied by the enclosing cluster.
  final Widget icon;

  @override
  Widget get content => icon;
}

/// A custom-content item in a pinned navigation-bar cluster.
///
/// Created via [GlassBarItem.custom].
final class GlassBarCustomItem extends GlassBarActionItem {
  /// Creates a custom item. Prefer [GlassBarItem.custom].
  const GlassBarCustomItem({
    required this.child,
    super.onTap = GlassBarActionItem._noOp,
    super.id,
    super.label,
    super.enabled,
    super.background,
    super.tintColor,
    super.axisBehavior,
  });

  /// The widget rendered inside the cluster, measured at its intrinsic width.
  final Widget child;

  @override
  Widget get content => child;
}

/// A pull-down menu item in a pinned navigation-bar cluster.
///
/// Created via [GlassBarItem.menu].
final class GlassBarMenuItem extends GlassBarActionItem {
  /// Creates a menu item. Prefer [GlassBarItem.menu].
  const GlassBarMenuItem({
    required this.icon,
    required this.menuItems,
    this.menuAlignment,
    this.menuWidth = 200,
    this.menuHeight,
    super.id,
    super.label,
    super.background,
    super.tintColor,
    super.axisBehavior,
  }) : super(onTap: GlassBarActionItem._noOp);

  /// The icon widget, typically an [Icon]. Conventionally an ellipsis.
  ///
  /// Size and colour are applied by the enclosing cluster.
  final Widget icon;

  /// The menu's contents: [GlassMenuItem] and [GlassMenuDivider] widgets.
  final List<Widget> menuItems;

  /// Where the menu expands relative to the capsule.
  ///
  /// Defaults to auto-detection from the capsule's screen position.
  final GlassMenuAlignment? menuAlignment;

  /// Width of the expanded menu panel, in logical pixels.
  final double menuWidth;

  /// Optional fixed height for the menu panel, in logical pixels.
  final double? menuHeight;

  @override
  Widget get content => icon;
}

/// A sheet-presenting item in a pinned navigation-bar cluster.
///
/// Created via [GlassBarItem.sheet].
final class GlassBarSheetItem extends GlassBarActionItem {
  /// Creates a sheet item. Prefer [GlassBarItem.sheet].
  const GlassBarSheetItem({
    required this.icon,
    required this.onPresent,
    super.id,
    super.label,
    super.enabled,
    super.background,
    super.tintColor,
    super.axisBehavior,
  }) : super(onTap: GlassBarActionItem._noOp);

  /// The icon widget, typically an [Icon].
  ///
  /// Size and colour are applied by the enclosing cluster.
  final Widget icon;

  /// Called on tap with the anchor of the capsule this item sits in.
  ///
  /// Read at tap time, so a bar that moves between the pinned chrome and its
  /// route hands out the anchor that is actually on screen.
  ///
  /// Null when no capsule can be resolved — a bar that renders the items
  /// itself and offers no anchor of its own. `GlassModalSheet.show` takes a
  /// null `morphFrom` and presents the way it always did, so the tap still
  /// does its job and only the morph is lost.
  final void Function(GlassMorphAnchor? anchor) onPresent;

  @override
  Widget get content => icon;
}

/// A glass-background break in a pinned cluster.
///
/// Created via [GlassBarItem.spacer].
final class GlassBarSpacer extends GlassBarItem {
  /// Creates a spacer. Prefer [GlassBarItem.spacer].
  const GlassBarSpacer();
}
