// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show DeviceGestureSettings;

import '../../../src/renderer/liquid_glass_renderer.dart';
import '../../../theme/glass_theme.dart';
import '../../../theme/glass_theme_helpers.dart';
import '../../../types/glass_quality.dart';
import '../../../utils/glass_spring.dart';
import '../../../widgets/shared/animated_glass_indicator.dart';
import '../../../widgets/input/glass_text_field.dart';
import '../../../widgets/interactive/glass_button.dart';
import '../../../widgets/surfaces/glass_tab_bar.dart';
import '../../../widgets/surfaces/glass_vertical_bar.dart';
import 'tab_bar_drag_gesture_mixin.dart';
import 'vertical_bar_reservation.dart';
import 'vertical_bar_title_row.dart';

/// [GlassTabBar] in iPhone Duo's vertical bar strip.
///
/// Natively the tab bar becomes an icon-only capsule at the bottom of the
/// strip, one control wide: labels are dropped, the tabs stack top to bottom,
/// and the selected tab sits on a rounded indicator. Four tabs make a 48×212
/// capsule, ending [GlassVerticalBarData.bottom] above the screen's bottom
/// edge.
///
/// The bar is handed whatever box its parent gives a bottom bar — the full
/// width of a [GlassScaffold] — and aligns itself into the strip, so it lands
/// in the same column as the pinned chrome above it.
///
/// Touch it and the labels come back, as UIKit's do: the capsule widens and
/// grows upward, each tab's label appears beneath its icon, and the indicator
/// lifts into a glass lens over the tab under the finger. The lens follows
/// the finger along the capsule, and the tab beneath it is selected on
/// release.
///
/// Where the strip is too short for it ([GlassVerticalBarData.collapsesTabBar])
/// it collapses to a circle holding the selected tab. A tap on the circle
/// opens the capsule again, and choosing a tab collapses it.
///
/// With a [searchConfig] — [GlassTabBar.searchable] — search is the last slot
/// of the capsule, the native `Tab(role: .search)`: a magnifier at the same
/// pitch as the tabs, which takes the indicator while search is active. The
/// field it opens stays horizontal, in the row at the top of the content
/// where the title would be, with its ✕ beside it.
class TabBarVerticalLayout extends StatefulWidget {
  /// Creates the vertical layout of a tab bar.
  const TabBarVerticalLayout({
    super.key,
    required this.bar,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.settings,
    this.quality,
    this.indicatorColor,
    this.indicatorSettings,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.iconSize = 24,
    this.platformViewBackdrop = false,
    this.searchConfig,
    this.isSearchActive = false,
  });

  /// The strip to lay out in.
  final GlassVerticalBarData bar;

  /// The tabs, top to bottom.
  final List<GlassTab> tabs;

  /// The index of the selected tab.
  final int selectedIndex;

  /// Called with a tab's index when it is tapped.
  final ValueChanged<int> onTabSelected;

  /// Glass settings for the capsule.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the capsule.
  final GlassQuality? quality;

  /// Colour of the selected tab's indicator.
  final Color? indicatorColor;

  /// Glass settings for the lens the indicator lifts into under a finger, as
  /// [GlassTabBar.indicatorSettings].
  final LiquidGlassSettings? indicatorSettings;

  /// Colour of the selected tab's icon.
  final Color? selectedIconColor;

  /// Colour of the other tabs' icons.
  final Color? unselectedIconColor;

  /// Size of the tab icons.
  final double iconSize;

  /// Whether the capsule floats over a native platform view.
  final bool platformViewBackdrop;

  /// The search slot and field, for [GlassTabBar.searchable]; null for no
  /// search.
  final GlassSearchBarConfig? searchConfig;

  /// Whether search is active: the magnifier is selected and the field is
  /// open.
  final bool isSearchActive;

  /// Space above the first tab and below the last, inside the capsule.
  static const double _padding = 6.0;

  /// Width and height of the selected tab's indicator.
  ///
  /// Natively it fills the capsule's width less 2pt a side and overhangs its
  /// tab's slot by 4pt at each end.
  static const Size _indicatorSize = Size(44, 58);

  /// The capsule's width while it is touched, with the labels showing.
  static const double _pressedWidth = 76.7;

  /// Distance between two tabs' icons while the capsule is touched.
  static const double _pressedItemExtent = 58.4;

  /// Distance from the last tab's icon to the capsule's bottom while it is
  /// touched, which leaves room for its label.
  static const double _pressedEndInset = 44.5;

  /// How far the capsule's bottom edge drops while it is touched.
  static const double _pressedDrop = 10.7;

  /// How much the capsule swells under a finger before the labels come.
  static const double _pressScale = 1.063;

  /// How far a finger moves on the capsule before it drags: the labels come
  /// at once, and the lens follows from there.
  static const double _dragSlop = 4.0;

  /// How long a finger rests on the capsule before the labels come.
  static const Duration _labelDelay = Duration(milliseconds: 180);

  /// Distance from a tab's icon to the middle of its label.
  static const double _labelOffset = 22.3;

  /// The labels' text style.
  static const TextStyle _labelStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  /// Size of the lens the indicator lifts into while the capsule is touched.
  static const Size _lensSize = Size(89.3, 86.7);

  /// How far below its tab's icon the lens is centred, over the icon and its
  /// label.
  static const double _lensOffset = 7.7;

  /// The capsule's height for [count] tabs.
  static double heightFor(int count) =>
      2 * _padding + count * GlassVerticalBarMetrics.itemExtent;

  /// Height of the open search field and of the ✕ beside it, in a compact
  /// width.
  ///
  /// Natively 44pt: there the field of a search tab keeps a horizontal bar's
  /// size, where the strip's own controls are 48pt. In a regular width it
  /// takes the strip's [GlassVerticalBarMetrics.controlExtent].
  static const double _compactSearchFieldHeight = 44.0;

  /// Gap between the open search field and its ✕ in a compact width; a
  /// regular width uses the strip's [GlassVerticalBarMetrics.spacing].
  static const double _compactSearchFieldSpacing = 10.0;

  /// Width of the open search field in a regular width, where natively it
  /// sits beside the title rather than taking its row.
  static const double _regularSearchFieldWidth = 280.0;

  @override
  State<TabBarVerticalLayout> createState() => _TabBarVerticalLayoutState();
}

class _TabBarVerticalLayoutState extends State<TabBarVerticalLayout>
    with TabDragGestureMixin<TabBarVerticalLayout> {
  /// The box the tabs' slots span, which touches map against.
  final GlobalKey _track = GlobalKey();

  /// Bumped to move the indicator straight to a touch rather than slide it
  /// there: natively it lifts out from under the finger.
  int _teleports = 0;

  /// The slot the finger came down on, which a tap selects.
  ///
  /// Held from the touch rather than re-read when the tap is recognised: by
  /// then the capsule has grown under the finger, which no longer sits over
  /// the same slot.
  int? _touchedSlot;

  /// Whether the labels show: once a finger has rested on the capsule for
  /// [TabBarVerticalLayout._labelDelay], or started to drag.
  bool _labelled = false;
  Timer? _labelTimer;

  /// Where the finger came down, which a drag is measured from.
  Offset? _downPosition;

  void _onPointerMove(PointerMoveEvent event) {
    final down = _downPosition;
    if (_labelled || down == null) return;
    if ((event.position - down).distance > TabBarVerticalLayout._dragSlop) {
      setState(() => _labelled = true);
    }
  }

  @override
  void onBarPointerDown(Offset position) {
    super.onBarPointerDown(position);
    final slot = super.tabIndexFromGlobal(position);
    _downPosition = position;
    _labelTimer?.cancel();
    _labelTimer = Timer(TabBarVerticalLayout._labelDelay, () {
      if (mounted && (tabIsDown || tabIsDragging)) {
        setState(() => _labelled = true);
      }
    });
    setState(() {
      _labelled = false;
      _touchedSlot = slot;
      tabXAlign = computeTabAlignment(slot);
      _teleports++;
    });
  }

  @override
  void onBarDragStart(DragStartDetails d) {
    super.onBarDragStart(d);
    setState(() => _labelled = true);
  }

  @override
  void dispose() {
    _labelTimer?.cancel();
    super.dispose();
  }

  @override
  int tabIndexFromGlobal(Offset globalPosition) =>
      tabIsDown && !tabIsDragging && _touchedSlot != null
          ? _touchedSlot!
          : super.tabIndexFromGlobal(globalPosition);

  int _slotCountOf(TabBarVerticalLayout layout) =>
      layout.tabs.length + (layout.searchConfig == null ? 0 : 1);

  int _selectedSlotOf(TabBarVerticalLayout layout) =>
      layout.searchConfig != null && layout.isSearchActive
          ? layout.tabs.length
          : layout.selectedIndex;

  @override
  int get tabCount => _slotCountOf(widget);

  @override
  int get tabIndex => _selectedSlotOf(widget);

  @override
  bool get isPlatformViewBackdrop => widget.platformViewBackdrop;

  @override
  Axis get tabAxis => Axis.vertical;

  @override
  BuildContext get tabTrackContext => _track.currentContext ?? context;

  @override
  bool get selectsOnRelease => true;

  @override
  void notifyTabChanged(int index) {
    if (index < widget.tabs.length) {
      _select(index);
    } else if (!widget.isSearchActive) {
      _openSearch();
    }
  }

  @override
  void didUpdateWidget(TabBarVerticalLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateTabAlignIfNeeded(_selectedSlotOf(oldWidget), _slotCountOf(oldWidget));
  }

  /// Whether a collapsed bar has been tapped open.
  bool _expanded = false;

  void _select(int index) {
    setState(() => _expanded = false);
    // Choosing a tab leaves the search tab, as natively.
    if (widget.isSearchActive) widget.searchConfig!.onSearchToggle(false);
    widget.onTabSelected(index);
  }

  void _openSearch() {
    setState(() => _expanded = false);
    widget.searchConfig!.onSearchToggle(true);
  }

  void _closeSearch() {
    final config = widget.searchConfig!;
    FocusManager.instance.primaryFocus?.unfocus();
    config.onSearchToggle(false);
    config.onCancelTap?.call();
  }

  /// The capsule of tabs, which comes alive under a finger.
  ///
  /// At rest it is [TabBarVerticalLayout.heightFor] tall and one control wide,
  /// and that is the space it takes in the strip. Touched, it widens about its
  /// middle and grows upward to [TabBarVerticalLayout._pressedItemExtent] a
  /// tab with each label beneath its icon, and the indicator lifts into a lens
  /// that follows the finger. Each tab is drawn twice: in its own colour, and
  /// again in the selected colour clipped to the indicator, so whatever the
  /// indicator covers takes the selected colour as it passes.
  Widget _buildCapsule(
    BuildContext context, {
    required List<(GlassTab, Color)> slots,
    required Color selectedColor,
  }) {
    const restWidth = GlassVerticalBarMetrics.controlExtent;
    const restExtent = GlassVerticalBarMetrics.itemExtent;
    const firstIcon = TabBarVerticalLayout._padding + restExtent / 2;
    const pill = TabBarVerticalLayout._indicatorSize;
    const lens = TabBarVerticalLayout._lensSize;
    final count = slots.length;
    final touched = tabIsDown || tabIsDragging;
    final labelled = touched && _labelled;
    final quality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
      fallback: GlassQuality.premium,
    );
    final indicatorColor = widget.indicatorColor ??
        CupertinoColors.secondarySystemFill.resolveFrom(context);

    // The pill at rest and the lens it lifts into, [lift] of the way: the
    // background beneath the tabs, or the glass over them.
    Widget indicator(
      Rect rect, {
      required double lift,
      required double velocity,
      required bool glass,
    }) =>
        Positioned.fromRect(
          rect: rect,
          child: IgnorePointer(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedGlassIndicator(
                  velocity: velocity,
                  itemCount: 1,
                  alignment: Alignment.center,
                  direction: Axis.vertical,
                  thickness: lift,
                  quality: quality,
                  indicatorColor: indicatorColor,
                  isBackgroundIndicator: false,
                  paintBackground: !glass,
                  paintGlass: glass,
                  settings: widget.indicatorSettings,
                  padding: EdgeInsets.zero,
                  // Sized by [rect] itself: an expansion this large would
                  // outgrow the glass layer's clip.
                  expansion: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );

    return SizedBox(
      width: restWidth,
      height: TabBarVerticalLayout.heightFor(count),
      // The capsule swells under the finger at once, then opens into the
      // labelled form once the finger rests there.
      child: SpringBuilder(
        spring: touched && !labelled
            ? GlassSpring.snappy(duration: const Duration(milliseconds: 150))
            : GlassSpring.smooth(duration: const Duration(milliseconds: 300)),
        value: touched && !labelled ? 1.0 : 0.0,
        builder: (context, pressValue, _) => SpringBuilder(
          // The labels fade quickly either way, ahead of the capsule.
          spring:
              GlassSpring.smooth(duration: const Duration(milliseconds: 100)),
          value: labelled ? 1.0 : 0.0,
          builder: (context, labelsIn, _) => SpringBuilder(
            // Opening overshoots by about a sixth before it settles, as
            // natively; closing barely does.
            spring: labelled
                ? GlassSpring.bouncy(
                    duration: const Duration(milliseconds: 400),
                    extraBounce: 0.2,
                  )
                : GlassSpring.snappy(
                    duration: const Duration(milliseconds: 300),
                  ),
            value: labelled ? 1.0 : 0.0,
            builder: (context, openValue, _) => VelocitySpringBuilder(
              value: tabXAlign,
              springWhenActive: GlassSpring.interactive(),
              springWhenReleased: GlassSpring.snappy(
                duration: const Duration(milliseconds: 350),
              ),
              active: tabIsDragging,
              teleportEpoch: _teleports,
              builder: (context, align, velocity, _) => SpringBuilder(
                // The lens lifts out from under the finger at once, and
                // settles back into the pill more slowly.
                spring: touched
                    ? GlassSpring.interactive()
                    : GlassSpring.snappy(
                        duration: const Duration(milliseconds: 300),
                      ),
                value: touched ||
                        (align - computeTabAlignment(tabIndex)).abs() > 0.05
                    ? 1.0
                    : 0.0,
                builder: (context, lift, _) {
                  // A spring comes to rest a hair off its target; at rest the
                  // capsule sits exactly where it did before any touch.
                  final press = pressValue.abs() < 1e-3 ? 0.0 : pressValue;
                  final open = openValue.abs() < 1e-3 ? 0.0 : openValue;
                  final width = lerpDouble(
                      restWidth, TabBarVerticalLayout._pressedWidth, open)!;
                  final pitch = lerpDouble(restExtent,
                      TabBarVerticalLayout._pressedItemExtent, open)!;
                  final height = firstIcon +
                      (count - 1) * pitch +
                      lerpDouble(firstIcon,
                          TabBarVerticalLayout._pressedEndInset, open)!;
                  final labels = labelsIn.clamp(0.0, 1.0);
                  final capsule = Rect.fromLTWH(
                    (restWidth - width) / 2,
                    TabBarVerticalLayout.heightFor(count) +
                        TabBarVerticalLayout._pressedDrop * open -
                        height,
                    width,
                    height,
                  );

                  final lensHeight =
                      lerpDouble(pill.height, lens.height, lift)!;
                  final slot = (align + 1) / 2 * (count - 1);
                  final centre = (firstIcon +
                          slot * pitch +
                          TabBarVerticalLayout._lensOffset * open)
                      .clamp(lensHeight / 2,
                          math.max(lensHeight / 2, height - lensHeight / 2))
                      .toDouble();
                  // In the capsule's own coordinates.
                  final rest = Rect.fromCenter(
                    center: Offset(width / 2, centre),
                    width: pill.width,
                    height: pill.height,
                  );
                  final covered = Rect.fromCenter(
                    center: rest.center,
                    width: lerpDouble(pill.width, lens.width, lift)!,
                    height: lensHeight,
                  );

                  // One layer of tabs, every icon and label in [colorOf]'s
                  // colour.
                  List<Widget> tabsIn(Color Function(int slot) colorOf,
                          {required bool semantics, Rect? within}) =>
                      [
                        for (var i = 0; i < count; i++)
                          // Only the tabs the indicator reaches: the icon, and
                          // the label beneath it while it shows.
                          if (within == null ||
                              (firstIcon + i * pitch - widget.iconSize / 2 <
                                      within.bottom &&
                                  firstIcon +
                                          i * pitch +
                                          widget.iconSize / 2 +
                                          TabBarVerticalLayout._labelOffset *
                                              labels >
                                      within.top))
                            ..._slot(
                              slots[i].$1,
                              slot: i,
                              centre: Offset(width / 2, firstIcon + i * pitch),
                              color: colorOf(i),
                              labels: labels,
                              semantics: semantics,
                            ),
                      ];

                  return Transform.scale(
                    scale: lerpDouble(
                        1.0, TabBarVerticalLayout._pressScale, press),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fromRect(
                          rect: capsule,
                          child: GlassButton.custom(
                            onTap:
                                () {}, // The capsule handles its own touches.
                            shape:
                                LiquidRoundedRectangle(borderRadius: width / 2),
                            settings: widget.settings,
                            quality: widget.quality,
                            platformViewBackdrop: widget.platformViewBackdrop,
                            canRequestFocus: false,
                            excludeFromSemantics: true,
                            width: width,
                            height: height,
                            // Its own layer, so it is painted beneath the lens
                            // rather than composited over it with the page's glass.
                            useOwnLayer: true,
                            // It grows rather than squashes under the finger.
                            interactionScale: 1.0,
                            stretch: 0.0,
                            child: Listener(
                              // Raw pointer events, so the indicator lifts on the
                              // touch itself rather than once a recogniser has won.
                              onPointerDown: (e) =>
                                  onBarPointerDown(e.position),
                              onPointerMove: _onPointerMove,
                              onPointerUp: (e) => onBarPointerUp(e.position),
                              onPointerCancel: (e) =>
                                  onBarPointerCancel(e.position),
                              // A drag starts sooner than Flutter's default
                              // allows, as UIKit's does.
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  gestureSettings: const DeviceGestureSettings(
                                    touchSlop: TabBarVerticalLayout._dragSlop,
                                  ),
                                ),
                                child: GestureDetector(
                                  key: ValueKey(gestureEpoch),
                                  behavior: HitTestBehavior.opaque,
                                  excludeFromSemantics: true,
                                  onVerticalDragDown: onBarDragDown,
                                  onVerticalDragStart: onBarDragStart,
                                  onVerticalDragUpdate: onBarDragUpdate,
                                  onVerticalDragEnd: onBarDragEnd,
                                  onVerticalDragCancel: onBarDragCancel,
                                  onTapDown: onBarTapDown,
                                  onTapUp: onBarTapUp,
                                  onTapCancel: onBarTapCancel,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // The slots touches map against.
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        top: firstIcon - pitch / 2,
                                        height: count * pitch,
                                        child: SizedBox(key: _track),
                                      ),
                                      indicator(covered,
                                          lift: lift,
                                          velocity: velocity,
                                          glass: false),
                                      ...tabsIn((i) => slots[i].$2,
                                          semantics: true),
                                      ClipPath(
                                        clipper: _IndicatorClipper(covered),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: tabsIn((_) => selectedColor,
                                              semantics: false,
                                              within: covered),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // The lens overhangs the capsule, so it is drawn over it
                        // rather than inside it.
                        indicator(covered.shift(capsule.topLeft),
                            lift: lift, velocity: velocity, glass: true),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// One tab's icon centred on [centre], and its label beneath it at
  /// [labels] opacity.
  List<Widget> _slot(
    GlassTab tab, {
    required int slot,
    required Offset centre,
    required Color color,
    required double labels,
    required bool semantics,
  }) {
    const extent = GlassVerticalBarMetrics.itemExtent;
    const width = GlassVerticalBarMetrics.controlExtent;
    final selected = slot == tabIndex;
    final icon = selected ? (tab.activeIcon ?? tab.icon) : tab.icon;
    Widget content = SizedBox(
      width: width,
      height: extent,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(color: color, size: widget.iconSize),
          // A label-only tab keeps its label, shrunk to the slot.
          child: icon ??
              FittedBox(
                child: Text(
                  tab.label!,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ),
        ),
      ),
    );
    content = semantics
        ? Semantics(
            button: true,
            selected: selected,
            label: tab.semanticLabel ?? tab.label,
            onTap: () => notifyTabChanged(slot),
            child: content,
          )
        : ExcludeSemantics(child: content);
    final label = tab.label;
    return [
      Positioned(
        left: centre.dx - width / 2,
        top: centre.dy - extent / 2,
        width: width,
        height: extent,
        child: content,
      ),
      if (icon != null && label != null && labels > 0)
        Positioned(
          left: 0,
          right: 0,
          top: centre.dy + TabBarVerticalLayout._labelOffset - extent / 2,
          height: extent,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Opacity(
                opacity: labels,
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style:
                        TabBarVerticalLayout._labelStyle.copyWith(color: color),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const width = GlassVerticalBarMetrics.controlExtent;
    final bar = widget.bar;
    final tabs = widget.tabs;
    final search = widget.searchConfig;
    final searching = search != null && widget.isSearchActive;
    // The slot holding the indicator: the magnifier's, after the tabs, while
    // search is active.
    final selectedSlot = searching ? tabs.length : widget.selectedIndex;
    final label = CupertinoColors.label.resolveFrom(context);
    final selectedColor = widget.selectedIconColor ?? label;
    final unselectedColor = widget.unselectedIconColor ?? label;
    // The capsule sits in the strip's column: its inner edge
    // GlassVerticalBarMetrics.inset from the content, the rest of the strip
    // between it and the screen edge.
    final outerInset = bar.width - GlassVerticalBarMetrics.inset - width;
    final trailingStrip = bar.edge == GlassVerticalBarEdge.trailing;
    final collapsed = bar.collapsesTabBar && !_expanded;

    Widget searchSlot({required double extent, VoidCallback? onTap}) =>
        _VerticalTab(
          tab: GlassTab(
            icon: search!.searchIcon ?? const Icon(CupertinoIcons.search),
            label: search.hintText,
          ),
          selected: searching,
          color: searching
              ? selectedColor
              : search.searchIconColor ?? unselectedColor,
          iconSize: widget.iconSize,
          extent: extent,
          onTap: onTap,
        );

    // Each control brings its own layer, as the horizontal bar does, so the
    // bar renders without a GlassScaffold above it to isolate it.
    final Widget capsule = collapsed
        ? GlassButton.custom(
            onTap: () => setState(() => _expanded = true),
            shape: const LiquidRoundedRectangle(borderRadius: width / 2),
            settings: widget.settings,
            quality: widget.quality,
            useOwnLayer: true,
            platformViewBackdrop: widget.platformViewBackdrop,
            label: searching
                ? search.hintText
                : tabs[selectedSlot].semanticLabel ??
                    tabs[selectedSlot].label ??
                    '',
            width: width,
            height: width,
            child: searching
                ? searchSlot(extent: width)
                : _VerticalTab(
                    tab: tabs[selectedSlot],
                    selected: true,
                    color: selectedColor,
                    iconSize: widget.iconSize,
                    extent: width,
                    onTap: null,
                  ),
          )
        : _buildCapsule(
            context,
            slots: [
              for (final tab in tabs) (tab, unselectedColor),
              if (search != null)
                (
                  GlassTab(
                    icon:
                        search.searchIcon ?? const Icon(CupertinoIcons.search),
                    label: search.hintText,
                  ),
                  search.searchIconColor ?? unselectedColor,
                ),
            ],
            selectedColor: selectedColor,
          );

    final Widget strip = Align(
      alignment: trailingStrip
          ? AlignmentDirectional.bottomEnd
          : AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: bar.bottom,
          start: trailingStrip ? 0 : outerInset,
          end: trailingStrip ? outerInset : 0,
        ),
        child: VerticalBarBottomReservation(child: capsule),
      ),
    );
    if (!searching) return strip;

    // The open field sits in the row at the top of the content. In a compact
    // width it takes the row, from the title's inset to the strip's inner
    // edge; in a regular width it is a fixed width at the row's end, and the
    // title stays beside it. It needs the full height of the screen to get
    // there, which GlassScaffold gives a bar in the strip.
    final regular = VerticalBarTitleRow.regularWidth(context);
    final height = regular
        ? GlassVerticalBarMetrics.controlExtent
        : TabBarVerticalLayout._compactSearchFieldHeight;
    final spacing = regular
        ? GlassVerticalBarMetrics.spacing
        : TabBarVerticalLayout._compactSearchFieldSpacing;
    final rowEnd =
        trailingStrip ? bar.width : GlassVerticalBarMetrics.titleInset;
    final rowStart =
        trailingStrip ? GlassVerticalBarMetrics.titleInset : bar.width;
    return Stack(
      children: [
        strip,
        PositionedDirectional(
          top: bar.rowTop,
          start: regular ? null : rowStart,
          end: rowEnd,
          width: regular
              ? TabBarVerticalLayout._regularSearchFieldWidth + spacing + height
              : null,
          height: height,
          child: _VerticalSearchField(
            config: search,
            settings: widget.settings,
            quality: widget.quality,
            height: height,
            spacing: spacing,
            onClose: _closeSearch,
          ),
        ),
      ],
    );
  }
}

/// The search field [TabBarVerticalLayout] opens at the top of the content,
/// with a ✕ that ends search.
class _VerticalSearchField extends StatelessWidget {
  const _VerticalSearchField({
    required this.config,
    required this.settings,
    required this.quality,
    required this.height,
    required this.spacing,
    required this.onClose,
  });

  final GlassSearchBarConfig config;
  final LiquidGlassSettings? settings;
  final GlassQuality? quality;

  /// Height of the field and of its ✕.
  final double height;

  /// Gap between the field and its ✕.
  final double spacing;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Dynamic colours resolve against the glass brightness, not the
    // platform's, as the horizontal search pill does.
    final dark = GlassTheme.brightnessOf(context) == Brightness.dark;
    Color resolve(Color color) => color is CupertinoDynamicColor
        ? (dark ? color.darkColor : color.color)
        : color;
    // Natively the field's magnifier is drawn in the label colour, and the
    // placeholder and typed text at 17pt, as in the horizontal search pill.
    final hintColor = config.hintStyle?.color;
    final iconColor = resolve(config.searchIconColor ?? CupertinoColors.label);
    final textStyle = (config.hintStyle ?? const TextStyle()).copyWith(
      fontSize: config.hintStyle?.fontSize ?? 17,
      fontWeight: config.hintStyle?.fontWeight ?? FontWeight.w400,
    );
    final defaultCancelColor =
        dark ? const Color(0xE6FFFFFF) : const Color(0xE6000000);

    return Row(
      children: [
        Expanded(
          child: GlassTextField.search(
            controller: config.controller,
            focusNode: config.focusNode,
            placeholder: config.hintText,
            prefixIcon: Icon(CupertinoIcons.search, size: 20, color: iconColor),
            onChanged: config.onChanged,
            onSubmitted: config.onSubmitted,
            autofocus: config.autoFocusOnExpand,
            textStyle: textStyle.copyWith(
              color: resolve(
                config.textColor ?? hintColor ?? CupertinoColors.label,
              ),
            ),
            placeholderStyle: textStyle.copyWith(
              color: resolve(hintColor ?? CupertinoColors.secondaryLabel),
            ),
            height: height,
            shape: LiquidRoundedRectangle(borderRadius: height / 2),
            settings: settings,
            quality: quality,
            useOwnLayer: true,
          ),
        ),
        if (config.showsCancelButton) ...[
          SizedBox(width: spacing),
          GlassButton(
            onTap: onClose,
            label: 'Cancel',
            width: height,
            height: height,
            shape: const LiquidOval(),
            settings: settings,
            quality: quality,
            useOwnLayer: true,
            icon: config.cancelIcon ??
                Icon(
                  CupertinoIcons.xmark,
                  color: config.cancelButtonColor ?? defaultCancelColor,
                  size: config.cancelIconSize,
                ),
          ),
        ],
      ],
    );
  }
}

/// One tab in the vertical capsule: its icon alone, with the label kept for
/// semantics.
class _VerticalTab extends StatelessWidget {
  const _VerticalTab({
    required this.tab,
    required this.selected,
    required this.color,
    required this.iconSize,
    required this.onTap,
    this.extent = GlassVerticalBarMetrics.itemExtent,
  });

  final GlassTab tab;
  final bool selected;
  final Color color;
  final double iconSize;

  /// Called on a tap; null where the enclosing control handles it.
  final VoidCallback? onTap;

  /// Height of the tab's slot.
  final double extent;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? (tab.activeIcon ?? tab.icon) : tab.icon;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.semanticLabel ?? tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: GlassVerticalBarMetrics.controlExtent,
          height: extent,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(color: color, size: iconSize),
              // A label-only tab keeps its label, shrunk to the slot.
              child: icon ??
                  FittedBox(
                    child: Text(
                      tab.label!,
                      style: TextStyle(color: color, fontSize: 11),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips the selected-colour layer to the indicator: [rect], rounded to a
/// capsule.
class _IndicatorClipper extends CustomClipper<Path> {
  const _IndicatorClipper(this.rect);

  final Rect rect;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2)));

  @override
  bool shouldReclip(_IndicatorClipper oldClipper) => oldClipper.rect != rect;
}
