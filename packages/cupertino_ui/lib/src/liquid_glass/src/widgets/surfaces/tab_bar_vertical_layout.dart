import 'package:flutter/cupertino.dart';

import '../../../src/renderer/liquid_glass_renderer.dart';
import '../../../theme/glass_theme.dart';
import '../../../types/glass_quality.dart';
import '../../../widgets/input/glass_text_field.dart';
import '../../../widgets/interactive/glass_button.dart';
import '../../../widgets/surfaces/glass_tab_bar.dart';
import '../../../widgets/surfaces/glass_vertical_bar.dart';
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

class _TabBarVerticalLayoutState extends State<TabBarVerticalLayout> {
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

  @override
  Widget build(BuildContext context) {
    const width = GlassVerticalBarMetrics.controlExtent;
    const itemExtent = GlassVerticalBarMetrics.itemExtent;
    const padding = TabBarVerticalLayout._padding;
    const indicatorSize = TabBarVerticalLayout._indicatorSize;
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
    final indicatorTop = padding +
        selectedSlot * itemExtent -
        (indicatorSize.height - itemExtent) / 2;
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

    final Widget capsule = collapsed
        ? GlassButton.custom(
            onTap: () => setState(() => _expanded = true),
            shape: const LiquidRoundedRectangle(borderRadius: width / 2),
            settings: widget.settings,
            quality: widget.quality,
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
        : GlassButton.custom(
            onTap: () {}, // The tabs handle their own taps.
            shape: const LiquidRoundedRectangle(borderRadius: width / 2),
            settings: widget.settings,
            quality: widget.quality,
            platformViewBackdrop: widget.platformViewBackdrop,
            canRequestFocus: false,
            excludeFromSemantics: true,
            width: width,
            height: TabBarVerticalLayout.heightFor(
              tabs.length + (search == null ? 0 : 1),
            ),
            stretch: 0.15,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: indicatorTop,
                  left: (width - indicatorSize.width) / 2,
                  width: indicatorSize.width,
                  height: indicatorSize.height,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: widget.indicatorColor ??
                          CupertinoColors.secondarySystemFill
                              .resolveFrom(context),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: padding),
                  child: Column(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        _VerticalTab(
                          tab: tabs[i],
                          selected: i == selectedSlot,
                          color: i == selectedSlot
                              ? selectedColor
                              : unselectedColor,
                          iconSize: widget.iconSize,
                          onTap: () => _select(i),
                        ),
                      if (search != null)
                        searchSlot(
                          extent: itemExtent,
                          onTap: searching ? null : _openSearch,
                        ),
                    ],
                  ),
                ),
              ],
            ),
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
          top: GlassVerticalBarMetrics.edgeMargin,
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
