// ignore_for_file: public_member_api_docs
// Internal layout engine for [GlassTabBar] bottom placement.
//
// Extracted so that [GlassTabBar] is the single owner of all rendering logic.
//
// Do NOT import this file directly — use [GlassTabBar.bottom()] instead.

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../../renderer/liquid_glass_renderer.dart';
import '../../types/glass_interaction_behavior.dart';
import '../../../types/glass_quality.dart';
import '../../../widgets/shared/adaptive_liquid_glass_layer.dart';
import '../../../widgets/shared/glass_content_aware_scope.dart';
import '../../../theme/glass_theme_data.dart';
import '../../../theme/glass_theme.dart';
import '../../../theme/glass_theme_helpers.dart';
import '../../../widgets/surfaces/shared/tab_bar_extra_button.dart'
    show GlassExtraButtonPlacement, GlassTabBarExtraButton;
import '../../../widgets/surfaces/shared/tab_bar_types.dart'
    show MaskingQuality;
import '../../../widgets/surfaces/glass_tab_bar.dart' show GlassTab;
import 'tab_bar_bottom_internal.dart'
    show
        BottomBarExtraBtn,
        BottomBarTabItem,
        TabIndicator,
        kBottomBarGlassDefaults,
        resolveBarLabelColor;
import '../../../widgets/surfaces/shared/tab_bar_accessory_placement.dart';
import 'tab_bar_layout_utils.dart';

/// Internal [StatefulWidget] that owns the bottom-placement rendering engine.
///
/// Created by [GlassTabBar._buildBottom()] when [_GlassTabBarPlacement.bottom]
/// is active. Not part of the public API.
class TabBarBottomLayout extends StatefulWidget {
  const TabBarBottomLayout({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    super.key,
    this.extraButton,
    this.bottomAccessory,
    this.bottomAccessoryEnabled = true,
    this.bottomAccessorySpacing = 6.0,
    this.spacing = 8,
    this.horizontalPadding = 20,
    this.verticalPadding = 20,
    this.barHeight = 64,
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
    this.quality,
    this.backgroundQuality,
    this.magnification = 1.15,
    this.innerBlur = 0.0,
    this.maskingQuality = MaskingQuality.high,
    this.backgroundKey,
    this.tabWidth,
    this.indicatorBorderRadius,
    this.indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.interactionGlowColor,
    this.interactionGlowRadius,
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.pressScale = 1.04,
    this.platformViewBackdrop = false,
    this.adaptiveBrightness = false,
    this.onBrightnessChanged,
    this.brightnessOverride,
    this.scrollController,
    this.springDescription,
  });

  static const double _kDefaultBorderRadius = 32.0;

  final List<GlassTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final GlassTabBarExtraButton? extraButton;
  final Widget? bottomAccessory;
  final bool bottomAccessoryEnabled;
  final double bottomAccessorySpacing;
  final double spacing;
  final double horizontalPadding;
  final double verticalPadding;
  final double barHeight;
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
  final GlassQuality? quality;
  final GlassQuality? backgroundQuality;
  final double magnification;
  final double innerBlur;
  final MaskingQuality maskingQuality;
  final GlobalKey? backgroundKey;
  final double? tabWidth;
  final double? indicatorBorderRadius;
  final EdgeInsetsGeometry indicatorExpansion;
  final Color? interactionGlowColor;

  /// Radius of the interaction glow, as a fraction of the layer's shortest
  /// side. Null asks for the iOS 26 calibration — see
  /// [resolveTabBarInteractionGlow].
  final double? interactionGlowRadius;
  final GlassInteractionBehavior interactionBehavior;
  final double pressScale;
  final bool platformViewBackdrop;
  final bool adaptiveBrightness;
  final ValueChanged<Brightness>? onBrightnessChanged;
  final ValueListenable<Brightness>? brightnessOverride;
  final ScrollController? scrollController;
  final SpringDescription? springDescription;

  @override
  State<TabBarBottomLayout> createState() => _TabBarBottomLayoutState();
}

class _TabBarBottomLayoutState extends State<TabBarBottomLayout>
    with TickerProviderStateMixin {
  // Delegate to the shared const — single source of truth in tab_bar_bottom_internal.dart.
  // Both bars reference kBottomBarGlassDefaults so their glass is guaranteed identical.
  static const _defaultGlassSettings = kBottomBarGlassDefaults;
  static const _kGestureRegionKey = ValueKey<String>(
    'glass_tab_bar_gesture_region',
  );

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TabBarBottomLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  GlassTabBarExtraButton _resolvedExtraButtonConfig() {
    return widget.extraButton!;
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

  /// Builds the bar. [darkAmount] is the animated light→dark cross-fade
  /// position when the adaptive brightness machinery is active, or null in
  /// the classic (ambient-brightness) path.
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
    // A null radius asks for native mode: the calibration GlassButton has
    // resolved from a null `glowRadius` since 1.3.0. An explicit radius keeps
    // the theme's palette, so a tuned app keeps what it tuned. The resolved
    // colour may still be null, which lets the internal widget fall back to
    // its own hardcoded highlight.
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

    // Spread and opacity come from the theme; they cannot be set per-widget
    // because they are part of the theme palette. The blur is the exception:
    // native mode owns it, because the radius and the falloff are one
    // calibration and a wide radius under the theme's sigma-4 is a disc with
    // an edge on it.
    final effectiveGlowBlurRadius = glow.blurRadius;
    final effectiveGlowSpreadRadius = resolvedGlowColors.glowSpreadRadius;
    final effectiveGlowOpacity = resolvedGlowColors.glowOpacity;

    final effectiveSettings = widget.settings ?? _defaultGlassSettings;

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
    //
    // The pin is deliberately scoped to the Rows: [TabIndicator] resolves
    // [indicatorExpansion] and [tabPadding] against `Directionality.of(context)`,
    // so wrapping the whole subtree would force those to LTR and silently ignore
    // any `EdgeInsetsDirectional` a consumer passes in an RTL app.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final tabs = isRtl ? widget.tabs.reversed.toList() : widget.tabs;
    final selectedIndex = isRtl
        ? widget.tabs.length - 1 - widget.selectedIndex
        : widget.selectedIndex;
    final onTabSelected = isRtl
        ? (int i) => widget.onTabSelected(widget.tabs.length - 1 - i)
        : widget.onTabSelected;

    final pillLayer = AdaptiveLiquidGlassLayer(
      clipExpansion:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
            final resolvedExtraButton = widget.extraButton != null
                ? _resolvedExtraButtonConfig()
                : null;
            final extraPlacement = resolvedExtraButton?.placement ??
                GlassExtraButtonPlacement.right;
            final extraOnLeft =
                extraPlacement == GlassExtraButtonPlacement.left;
            final extraBtnW = resolvedExtraButton != null
                ? resolvedExtraButton.size + widget.spacing
                : 0.0;
            final maxTabW = constraints.maxWidth - extraBtnW;
            final tabPillW = resolveTabPillWidth(
              tabWidth: widget.tabWidth,
              tabCount: tabs.length,
              maxAvailable: maxTabW,
            );
            final expandedTabLeft = extraOnLeft ? extraBtnW : 0.0;

            final content = SizedBox(
              key: _kGestureRegionKey,
              height: widget.barHeight,
              child: Builder(
                builder: (context) {
                  final extraButton = resolvedExtraButton != null
                      ? Positioned(
                          left: extraOnLeft ? 0 : null,
                          right: extraOnLeft ? null : 0,
                          top: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: resolvedExtraButton.size,
                            height: widget.barHeight,
                            child: BottomBarExtraBtn(
                              config: resolvedExtraButton,
                              // Chrome-plane peer: matches the track background,
                              // not the indicator pill (effectiveQuality).
                              quality: effectiveBackgroundQuality,
                              iconColor: resolvedExtraButton.iconColor ??
                                  resolvedUnselectedIconColor,
                              enableBlend: widget.enableBlend,
                              borderRadius: widget.barBorderRadius ==
                                      TabBarBottomLayout._kDefaultBorderRadius
                                  ? null
                                  : widget.barBorderRadius,
                              platformViewBackdrop: widget.platformViewBackdrop,
                            ),
                          ),
                        )
                      : null;

                  final tabPill = Positioned(
                    left: expandedTabLeft,
                    top: 0,
                    width: tabPillW,
                    height: widget.barHeight,
                    // Keep the pill un-clipped so press interactions
                    // can overflow horizontally the same way
                    // GlassTabBar.searchable does.
                    child: SizedBox(
                      width: tabPillW,
                      height: widget.barHeight,
                      child: TabIndicator(
                        quality: effectiveQuality,
                        backgroundQuality: effectiveBackgroundQuality,
                        springDescription: widget.springDescription,
                        visible: widget.showIndicator,
                        tabIndex: selectedIndex,
                        tabCount: tabs.length,
                        indicatorColor: widget.indicatorColor,
                        indicatorSettings: widget.indicatorSettings,
                        indicatorPinchStrength: widget.indicatorPinchStrength,
                        onTabChanged: onTabSelected,
                        barHeight: widget.barHeight,
                        barBorderRadius: widget.barBorderRadius,
                        indicatorBorderRadius: widget.indicatorBorderRadius,
                        tabPadding: widget.tabPadding,
                        backgroundKey: widget.backgroundKey,
                        maskingQuality: widget.maskingQuality,
                        indicatorExpansion: widget.indicatorExpansion,
                        platformViewBackdrop: widget.platformViewBackdrop,
                        interactionGlowColor: widget.interactionBehavior.hasGlow
                            ? effectiveInteractionGlowColor
                            : const Color(0x00000000),
                        interactionGlowRadius: glow.radius,
                        interactionGlowBlurRadius: effectiveGlowBlurRadius,
                        interactionGlowSpreadRadius: effectiveGlowSpreadRadius,
                        interactionGlowOpacity: effectiveGlowOpacity,
                        interactionScale: widget.interactionBehavior.hasScale
                            ? widget.pressScale
                            : 1.0,
                        childUnselected: _ltrTabRow(
                          children: [
                            for (var i = 0; i < tabs.length; i++)
                              Expanded(
                                child: BottomBarTabItem(
                                  tab: tabs[i],
                                  selected: false,
                                  selectedIconColor: resolvedSelectedIconColor,
                                  unselectedIconColor:
                                      resolvedUnselectedIconColor,
                                  selectedLabelColor: widget.selectedLabelColor,
                                  unselectedLabelColor:
                                      widget.unselectedLabelColor,
                                  selectedLabelStyle: widget.selectedLabelStyle,
                                  unselectedLabelStyle:
                                      widget.unselectedLabelStyle,
                                  iconSize: widget.iconSize,
                                  labelFontSize: widget.labelFontSize,
                                  textStyle: widget.textStyle,
                                  iconLabelSpacing: widget.iconLabelSpacing,
                                  glowDuration: widget.glowDuration,
                                  glowBlurRadius: widget.glowBlurRadius,
                                  glowSpreadRadius: widget.glowSpreadRadius,
                                  glowOpacity: widget.glowOpacity,
                                  semanticsSelected: i == selectedIndex,
                                  onTap: null,
                                  // Pointer selection stays with the
                                  // indicator; this is the tap action a screen
                                  // reader and the keyboard activate. Under
                                  // RTL [onTabSelected] is the mirrored
                                  // wrapper, so `i` reports the logical index.
                                  semanticOnTap: () => onTabSelected(i),
                                ),
                              ),
                          ],
                        ),
                        selectedTabBuilder: (context, intensity, alignment) =>
                            _buildSelectedTabs(
                                intensity,
                                alignment,
                                tabs,
                                resolvedSelectedIconColor,
                                resolvedUnselectedIconColor),
                        magnification: widget.magnification,
                        innerBlur: widget.innerBlur,
                      ),
                    ),
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (extraButton != null) extraButton,
                      tabPill,
                    ],
                  );
                },
              ),
            );
            return content;
          },
        ),
      ),
    );

    if (widget.bottomAccessory == null) return pillLayer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassTabBarAccessoryPlacementScope(
          placement: GlassTabBarAccessoryPlacement.expanded,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: widget.bottomAccessoryEnabled
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.bottomAccessory!,
                      SizedBox(height: widget.bottomAccessorySpacing),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        pillLayer,
      ],
    );
  }

  Widget _buildSelectedTabs(
      double intensity,
      Alignment alignment,
      List<GlassTab> tabs,
      Color resolvedSelectedIconColor,
      Color resolvedUnselectedIconColor) {
    final scale = ui.lerpDouble(1.0, widget.magnification, intensity) ?? 1.0;

    final currentTabFloat = ((alignment.x + 1) / 2) * tabs.length;
    final affectedStart =
        (currentTabFloat - 1).floor().clamp(0, tabs.length - 1);
    final affectedEnd = (currentTabFloat + 1).ceil().clamp(0, tabs.length - 1);

    return ExcludeSemantics(
      child: _ltrTabRow(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: (i >= affectedStart && i <= affectedEnd)
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
}
