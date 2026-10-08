// ignore_for_file: public_member_api_docs
// Internal sub-widgets for GlassTabBar.searchable.
//
// Extracted from glass_tab_bar.dart to keep that file focused on
// the public API and layout orchestration. Mirrors the pattern established by
// tab_bar_bottom_internal.dart for GlassTabBar.bottom.
//
// None of these widgets are part of the public API.
// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';

import '../../../constants/glass_defaults.dart';
import '../../renderer/liquid_glass_renderer.dart';
import '../../../types/glass_quality.dart';
import '../../../utils/draggable_indicator_physics.dart';
import '../../utils/glass_localizations.dart';
import '../../../utils/glass_spring.dart';
import '../../../theme/glass_theme.dart';
import '../../../widgets/interactive/glass_button.dart';
import '../../../widgets/shared/adaptive_glass.dart';
import '../../../widgets/shared/animated_glass_indicator.dart';
import '../../../widgets/shared/inherited_liquid_glass.dart';
import '../../../widgets/surfaces/shared/tab_bar_types.dart'
    show MaskingQuality, JellyClipper;
import '../../../widgets/surfaces/shared/glass_search_bar_config.dart';
import 'tab_bar_drag_gesture_mixin.dart';

// =============================================================================
// _DismissPill
// =============================================================================
// Rendered inside the parent [AdaptiveLiquidGlassLayer] (same layer as the
// search pill and tab pill) so that all three glass surfaces share the identical
// shader context. This gives perfect colour, blur, and lighting parity with no
// additional configuration required.
//
// Hit-testing works because the parent [SizedBox] expands its height by
// [keyboardH] while the pill is visible, keeping the pill inside the widget's
// layout bounds even when it floats above the keyboard.

class DismissPill extends StatelessWidget {
  const DismissPill({
    required this.onTap,
    required this.pillSize,
    required this.barBorderRadius,
    required this.quality,
    this.cancelButtonColor,
    this.cancelIcon,
    this.cancelIconSize = 24,
    this.indicatorColor,
    this.settings,
    this.semanticLabel,
    super.key,
  });

  final VoidCallback onTap;
  final double pillSize;
  final double barBorderRadius;
  final GlassQuality quality;
  final Color? cancelButtonColor;
  final Widget? cancelIcon;
  final double cancelIconSize;
  final Color? indicatorColor;
  final LiquidGlassSettings? settings;

  /// Screen reader label; defaults to the app's Cupertino "Cancel".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final safeColor = indicatorColor;
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final defaultIconColor =
        isDark ? const Color(0xE6FFFFFF) : const Color(0xE6000000);
    return GlassButton(
      onTap: onTap,
      label: semanticLabel ??
          glassCupertinoLocalizationsOf(context).cancelButtonLabel,
      width: pillSize,
      height: pillSize,
      quality: quality,
      // useOwnLayer defaults to false — the pill participates in the parent
      // AdaptiveLiquidGlassLayer so glass colour, blur and lighting are
      // identical to the adjacent search pill.
      settings:
          settings?.copyWith(glassColor: safeColor ?? settings?.glassColor) ??
              (safeColor != null
                  ? LiquidGlassSettings(glassColor: safeColor)
                  : null),
      shape: LiquidRoundedRectangle(borderRadius: barBorderRadius),
      icon: cancelIcon ??
          Icon(
            CupertinoIcons.xmark,
            color: cancelButtonColor ?? defaultIconColor,
            size: cancelIconSize,
          ),
      iconColor: cancelButtonColor ?? defaultIconColor,
    );
  }
}

// =============================================================================
// SearchableTabIndicator
// =============================================================================

/// Draggable glass indicator for [GlassTabBar.searchable].
///
/// Uses identical spring physics and masking to [GlassTabBar.bottom]'s internal
/// `_TabIndicator`. When `isSearchActive` is `true`, it collapses to show only
/// the [collapsedLogoBuilder] and a tap dismisses search.
class SearchableTabIndicator extends StatefulWidget {
  const SearchableTabIndicator({
    required this.childUnselected,
    required this.selectedTabBuilder,
    required this.tabIndex,
    required this.tabCount,
    required this.onTabChanged,
    required this.visible,
    required this.quality,
    this.backgroundQuality,
    required this.barHeight,
    required this.barBorderRadius,
    this.indicatorBorderRadius,
    required this.tabPadding,
    required this.magnification,
    required this.innerBlur,
    required this.maskingQuality,
    this.passthroughOverPlatformView = false,
    required this.isSearchActive,
    required this.onDismissSearch,
    this.indicatorColor,
    this.indicatorSettings,
    this.indicatorPinchStrength = 0.4,
    this.backgroundKey,
    this.collapsedLogoBuilder,
    this.indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.interactionGlowColor,
    this.nativePressHighlight = false,
    this.interactionGlowRadius = 1.5,
    this.interactionGlowBlurRadius = 0,
    this.interactionGlowSpreadRadius = 0,
    this.interactionGlowOpacity = 1,
    required this.enableBackgroundAnimation,
    required this.backgroundPressScale,
    this.platformViewBackdrop = false,
    this.collapsedSemanticLabel,
    super.key,
  });

  final int tabIndex;
  final int tabCount;
  final bool visible;
  final Widget childUnselected;
  final Widget Function(BuildContext, double, Alignment) selectedTabBuilder;
  final Color? indicatorColor;
  final LiquidGlassSettings? indicatorSettings;

  /// Maximum concave lens pinch strength. Forwarded to [AnimatedGlassIndicator].
  final double indicatorPinchStrength;
  final ValueChanged<int> onTabChanged;
  final GlassQuality quality;
  final GlassQuality? backgroundQuality;
  final double barHeight;
  final double barBorderRadius;
  final double? indicatorBorderRadius;
  final EdgeInsetsGeometry tabPadding;
  final double magnification;
  final double innerBlur;
  final MaskingQuality maskingQuality;

  /// The glass sits over a platform view whose pixels cannot be captured, so
  /// its body is transparent rather than an invented fill colour.
  ///
  /// The indicator refracts the bar's own icon layer in that situation, and
  /// that layer is also drawn on screen - with a see-through body the crisp
  /// copy shows next to the refracted one, i.e. every label appears twice.
  /// So when this is set the selected content is lifted OUT of the refracted
  /// icon layer and drawn ABOVE the glass instead: the layer under the pill
  /// holds nothing, the glass still refracts what surrounds it, and each
  /// label exists exactly once.
  final bool passthroughOverPlatformView;
  final GlobalKey? backgroundKey;
  final bool isSearchActive;
  final VoidCallback onDismissSearch;
  final WidgetBuilder? collapsedLogoBuilder;

  /// Screen reader label of the collapsed circle that leaves search and
  /// returns to the tabs: the current tab's name.
  final String? collapsedSemanticLabel;

  /// How far the jelly indicator's leading and trailing edges expand
  /// past the tab boundary as the indicator translates. Higher values
  /// give a more dramatic "puff" stretch; lower values produce a
  /// tighter, more iOS-native feel. Defaults to `14` to match the
  /// pre-existing visual.
  final EdgeInsetsGeometry indicatorExpansion;

  final Color? interactionGlowColor;
  final bool nativePressHighlight;
  final double interactionGlowRadius;
  final double interactionGlowBlurRadius;
  final double interactionGlowSpreadRadius;
  final double interactionGlowOpacity;
  final bool enableBackgroundAnimation;
  final double? backgroundPressScale;

  /// When true (bar over an iOS PlatformView): the bar background renders via
  /// live BackdropFilter, and the premium indicator refracts the bar's own icon
  /// layer (capturable) instead of the PlatformView backdrop.
  final bool platformViewBackdrop;

  @override
  State<SearchableTabIndicator> createState() => SearchableTabIndicatorState();
}

class SearchableTabIndicatorState extends State<SearchableTabIndicator>
    with TabDragGestureMixin<SearchableTabIndicator> {
  // ── Mixin interface ────────────────────────────────────────────────────────
  @override
  int get tabCount => widget.tabCount;
  @override
  int get tabIndex => widget.tabIndex;
  @override
  bool get isPlatformViewBackdrop => widget.platformViewBackdrop;
  @override
  void notifyTabChanged(int index) => widget.onTabChanged(index);

  /// RepaintBoundary key for the merged icon layer, so the premium indicator can
  /// refract the icons (capturable) over a PlatformView.
  final GlobalKey _iconLayerKey = GlobalKey();

  // Cached shape to avoid recreation on every animation frame
  late LiquidRoundedRectangle _barShape =
      LiquidRoundedRectangle(borderRadius: widget.barBorderRadius);

  @override
  void didUpdateWidget(covariant SearchableTabIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateTabAlignIfNeeded(oldWidget.tabIndex, oldWidget.tabCount);
    if (oldWidget.barBorderRadius != widget.barBorderRadius) {
      _barShape = LiquidRoundedRectangle(borderRadius: widget.barBorderRadius);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Collapsed / search-active state ─────────────────────────────────────
    if (widget.isSearchActive) {
      // LayoutBuilder detects whether the pill has finished collapsing
      // to a square. When square, LiquidOval gives a perfect circle;
      // while still animating (wider than tall) the superellipse handles
      // non-square rectangles gracefully as a pill.
      return LayoutBuilder(
        builder: (context, constraints) {
          final isSquare =
              (constraints.maxWidth - constraints.maxHeight).abs() < 2;
          final currentShape = isSquare ? const LiquidOval() : _barShape;

          final nativePress = _pressesNatively(
              widget.enableBackgroundAnimation, widget.backgroundPressScale);
          final content = widget.collapsedLogoBuilder != null
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (c, a) =>
                      FadeTransition(opacity: a, child: c),
                  child: SizedBox.expand(
                    key: const ValueKey('logo'),
                    child: widget.collapsedLogoBuilder!(context),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty'));

          return LiquidStretch(
            interactionScale: widget.enableBackgroundAnimation
                ? (widget.backgroundPressScale ?? 1.0)
                : 1.0,
            // The collapsed circle presses like a native button (#272):
            // a null pressScale resolves to the ~17 pt growth with the
            // tremor stretch on top; a number stays a fixed factor, as
            // on GlassButton.
            pressGrowth: nativePress ? LiquidStretch.nativePressGrowth : null,
            anchorStretchSettings: nativePress
                ? AnchorStretchSettings.nativeTremor
                : const AnchorStretchSettings(),
            stretch: widget.platformViewBackdrop ? 0.0 : 0.5,
            resistance: 0.01,
            anchorStretch: true,
            // The collapsed circle is the way back to the tabs: a button
            // named after the current tab. The logo inside is decoration.
            child: Semantics(
              container: true,
              button: true,
              label: widget.collapsedSemanticLabel,
              onTap: widget.onDismissSearch,
              excludeSemantics: widget.collapsedSemanticLabel != null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDismissSearch,
                child: AdaptiveGlass.grouped(
                  quality: widget.backgroundQuality ?? widget.quality,
                  platformViewBackdrop: widget.platformViewBackdrop,
                  shape: currentShape,
                  child: (nativePress && widget.nativePressHighlight)
                      ? PressAmbientLift(child: content)
                      : _wrapWithGlow(child: content),
                ),
              ),
            ),
          );
        },
      );
    }

    // ── Normal draggable tab bar — identical logic to GlassTabBar.bottom ─────
    final brightness = GlassTheme.brightnessOf(context);
    final indicatorColor = widget.indicatorColor ??
        (brightness == Brightness.dark
            ? CupertinoColors.white.withValues(alpha: .1)
            : CupertinoColors.black.withValues(alpha: .1));
    final targetAlignment = computeTabAlignment(widget.tabIndex);
    // Nested-arc default: if the outer bar is a capsule sentinel (≥ 9999),
    // the indicator is also passed 9999 directly, so the glass shader clamps to
    // a true capsule even during jelly-bloom expansion. For custom radii (e.g.
    // GlassTabBar.inline default 100), the indicator subtracts the padding inset
    // (4 px) to produce concentric nested arcs (100 − 4 = 96). An explicit
    // indicatorBorderRadius always takes priority.
    const indicatorPadding = 4.0;
    final indicatorRadius = widget.indicatorBorderRadius ??
        (widget.barBorderRadius >= GlassDefaults.capsuleRadius
            ? GlassDefaults.capsuleRadius
            : (widget.barBorderRadius - indicatorPadding).clamp(
                0.0,
                GlassDefaults.capsuleRadius,
              ));

    // Lateral sway: the bar body subtly follows the interactive pill during
    // horizontal drags, mimicking iOS 26 bottom bar physics. The SpringBuilder
    // animates the offset back to 0.0 when the drag ends.
    return SpringBuilder(
      spring: GlassSpring.smooth(
        duration: const Duration(milliseconds: 250),
      ),
      value: barSwayOffset,
      builder: (context, swayValue, _) {
        return Transform.translate(
          offset: Offset(swayValue, 0),
          child: LiquidStretch(
            interactionScale: widget.enableBackgroundAnimation
                ? (widget.backgroundPressScale ?? 1.04)
                : 1.0,
            stretch:
                0.0, // stretch disabled on platformViewBackdrop to prevent BackdropFilter pixel-snap jitter
            resistance: 0.08,
            anchorStretch: false, // Tab bars use jelly-follow, not anchored
            child: Listener(
              onPointerDown: (e) => onBarPointerDown(e.position),
              onPointerUp: (e) => onBarPointerUp(e.position),
              onPointerCancel: (e) => onBarPointerCancel(e.position),
              child: GestureDetector(
                key: ValueKey(gestureEpoch),
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onHorizontalDragDown: onBarDragDown,
                onHorizontalDragStart: onBarDragStart,
                onHorizontalDragUpdate: onBarDragUpdate,
                onHorizontalDragEnd: onBarDragEnd,
                onHorizontalDragCancel: onBarDragCancel,
                onTapDown: onBarTapDown,
                onTapUp: onBarTapUp,
                onTapCancel: onBarTapCancel,
                child: VelocitySpringBuilder(
                  value: tabXAlign,
                  springWhenActive: GlassSpring.interactive(),
                  springWhenReleased: GlassSpring.snappy(
                    duration: const Duration(milliseconds: 350),
                  ),
                  active: tabIsDragging,
                  builder: (context, value, velocity, child) {
                    final alignment = Alignment(value, 0);
                    return SpringBuilder(
                      spring: GlassSpring.snappy(
                        duration: const Duration(milliseconds: 300),
                      ),
                      value: widget.visible &&
                              (tabIsDown ||
                                  tabIsDragging ||
                                  (alignment.x - targetAlignment).abs() > 0.05)
                          ? 1.0
                          : 0.0,
                      builder: (context, thickness, _) {
                        if (thickness < 0.01 &&
                            !widget.visible &&
                            widget.maskingQuality == MaskingQuality.high) {
                          return Container(
                            height: widget.barHeight,
                            decoration: ShapeDecoration(shape: _barShape),
                            child: AdaptiveGlass.grouped(
                              quality:
                                  widget.backgroundQuality ?? widget.quality,
                              platformViewBackdrop: widget.platformViewBackdrop,
                              shape: _barShape,
                              child: Container(
                                padding: widget.tabPadding,
                                child: widget.childUnselected,
                              ),
                            ),
                          );
                        }

                        final jellyTransform =
                            DraggableIndicatorPhysics.buildJellyTransform(
                          velocity: Offset(velocity, 0),
                          maxDistortion: 0.8,
                          velocityScale: 10,
                        );

                        switch (widget.maskingQuality) {
                          case MaskingQuality.off:
                            return _buildSimple(
                              alignment: alignment,
                              targetAlignment: Alignment(targetAlignment, 0),
                              thickness: thickness,
                              velocity: velocity,
                              indicatorRadius: indicatorRadius,
                              indicatorColor: indicatorColor,
                            );
                          case MaskingQuality.high:
                            return _buildHighQuality(
                              alignment: alignment,
                              thickness: thickness,
                              velocity: velocity,
                              jellyTransform: jellyTransform,
                              indicatorRadius: indicatorRadius,
                              indicatorColor: indicatorColor,
                            );
                        }
                      },
                    ); // SpringBuilder (thickness)
                  }, // VelocitySpringBuilder builder
                ), // VelocitySpringBuilder
              ), // GestureDetector
            ), // Listener
          ), // LiquidStretch
        ); // Transform.translate
      }, // SpringBuilder builder (sway)
    ); // SpringBuilder (sway)
  }

  /// Builds a standalone shadow widget for the tab pill.
  ///
  /// Rendered as a SIBLING in the parent Stack, BELOW the glass pill,
  /// so it doesn't interfere with the blend group compositing.
  /// Returns null in dark mode or when no shadow is configured.
  Widget? buildShadowOverlay(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    if (isDark) return null;

    final effectiveSettings = InheritedLiquidGlass.ofOrDefault(context);
    final shadows = effectiveSettings.effectiveShadow;
    if (shadows.isEmpty) return null;

    return IgnorePointer(
      child: ClipPath(
        clipBehavior: Clip.antiAlias,
        clipper: _InverseSearchBarClipper(_barShape),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius:
                GlassDefaults.safeBorderRadius(widget.barBorderRadius),
            boxShadow: shadows,
          ),
        ),
      ),
    );
  }

  /// Wraps [child] in [GlassGlow] only when the resolved glow color is
  /// non-transparent. Skips the wrapper entirely for
  /// [GlassInteractionBehavior.none] and [scaleOnly], avoiding three extra
  /// widget/render-object allocations per frame.
  Widget _wrapWithGlow({required Widget child}) {
    final effectiveColor =
        widget.interactionGlowColor ?? const Color(0x1FFFFFFF);
    if (effectiveColor.a == 0) return child;
    return GlassGlow(
      clipper: ShapeBorderClipper(shape: _barShape),
      glowColor: effectiveColor,
      glowRadius: widget.interactionGlowRadius,
      glowBlurRadius: widget.interactionGlowBlurRadius,
      glowSpreadRadius: widget.interactionGlowSpreadRadius,
      glowOpacity: widget.interactionGlowOpacity,
      child: child,
    );
  }

  Widget _buildSimple({
    required Alignment alignment,
    required Alignment targetAlignment,
    required double thickness,
    required double velocity,
    required double indicatorRadius,
    required Color indicatorColor,
  }) {
    return SizedBox(
      height: widget.barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _wrapWithGlow(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Glass background (Cached to prevent blur re-rasterization on pill drag)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AdaptiveGlass.grouped(
                        quality: widget.backgroundQuality ?? widget.quality,
                        platformViewBackdrop: widget.platformViewBackdrop,
                        shape: _barShape,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // Unselected icons — all tabs in unselected style (for refraction).
                  Positioned.fill(
                    child: Container(
                      padding: widget.tabPadding,
                      child: widget.childUnselected,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Glass indicator — on top so it refracts the icon layer AND the glow beneath.
          if (widget.visible && thickness > 0.05)
            AnimatedGlassIndicator(
              velocity: velocity,
              itemCount: widget.tabCount,
              alignment: alignment,
              thickness: thickness,
              quality: widget.quality,
              indicatorColor: indicatorColor,
              isBackgroundIndicator: false,
              innerBlur: widget.innerBlur,
              padding: const EdgeInsets.all(4),
              expansion: widget.indicatorExpansion,
              settings: widget.indicatorSettings,
              borderRadius: indicatorRadius,
              pinchStrength: widget.indicatorPinchStrength,
              backgroundKey: widget.backgroundKey,
            ),

          // Persistent selected-icon overlay — always at TARGET position
          // so the selected icon stays vibrant (selected style) at rest.
          if (widget.visible)
            Positioned.fill(
              child: Align(
                alignment: targetAlignment,
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.tabCount,
                  child: Container(
                    padding: widget.tabPadding,
                    height: widget.barHeight,
                    child: widget.selectedTabBuilder(
                        context, 1.0, targetAlignment),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHighQuality({
    required Alignment alignment,
    required double thickness,
    required double velocity,
    required Matrix4 jellyTransform,
    required double indicatorRadius,
    required Color indicatorColor,
  }) {
    final effRadius = indicatorRadius;
    return SizedBox(
      height: widget.barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _wrapWithGlow(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Static Blur Background (Cached)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AdaptiveGlass.grouped(
                        quality: widget.backgroundQuality ?? widget.quality,
                        platformViewBackdrop: widget.platformViewBackdrop,
                        shape: _barShape,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // 1.5. Solid Indicator Background (drawn below icons so selected icons are vibrant)
                  AnimatedGlassIndicator(
                    velocity: velocity,
                    itemCount: widget.tabCount,
                    alignment: alignment,
                    thickness: thickness,
                    quality: widget.quality,
                    indicatorColor: indicatorColor,
                    isBackgroundIndicator: false,
                    paintBackground: true,
                    paintGlass: false,
                    innerBlur: widget.innerBlur,
                    padding: const EdgeInsets.all(4),
                    expansion: widget.indicatorExpansion,
                    settings: widget.indicatorSettings,
                    borderRadius: indicatorRadius,
                    pinchStrength: widget.indicatorPinchStrength,
                    backgroundKey: widget.backgroundKey,
                  ),

                  // 2. Icon Content Layer (Unselected + Selected combined for refraction)
                  // We expand the RepaintBoundary bounds using negative Positioned
                  // offsets matching the indicator expansion. This ensures that when
                  // the active glass pill overshoots its bounds during a jelly animation
                  // or stretch, it never samples outside the captured texture (which
                  // causes extreme wrap-around chromatic aliasing on Impeller).
                  Builder(
                    builder: (context) {
                      final exp = widget.indicatorExpansion
                          .resolve(Directionality.of(context));
                      return Positioned(
                        top: -exp.top,
                        bottom: -exp.bottom,
                        left: -exp.left,
                        right: -exp.right,
                        child: RepaintBoundary(
                          // Keyed so the premium indicator can refract this icon layer
                          // (capturable) over a PlatformView.
                          key: _iconLayerKey,
                          child: Padding(
                            padding: exp,
                            child: Stack(
                              children: [
                                ClipPath(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  clipper: JellyClipper(
                                    itemCount: widget.tabCount,
                                    alignment: alignment,
                                    thickness: thickness,
                                    expansion: widget.indicatorExpansion
                                        .resolve(Directionality.of(context)),
                                    transform: jellyTransform,
                                    borderRadius: effRadius * 2,
                                    inverse: true,
                                  ),
                                  child: Container(
                                    padding: widget.tabPadding,
                                    height: widget.barHeight,
                                    child: widget.childUnselected,
                                  ),
                                ),
                                if (!widget.passthroughOverPlatformView)
                                  ClipPath(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    clipper: JellyClipper(
                                      itemCount: widget.tabCount,
                                      alignment: alignment,
                                      thickness: thickness,
                                      expansion: widget.indicatorExpansion
                                          .resolve(Directionality.of(context)),
                                      transform: jellyTransform,
                                      borderRadius: effRadius * 2,
                                    ),
                                    child: Container(
                                      padding: widget.tabPadding,
                                      height: widget.barHeight,
                                      child: widget.selectedTabBuilder(
                                          context, thickness, alignment),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. Moving Glass Indicator Layer — on top so it refracts
          // the merged icon RepaintBoundary AND the glow beneath it.
          AnimatedGlassIndicator(
            velocity: velocity,
            itemCount: widget.tabCount,
            alignment: alignment,
            thickness: thickness,
            quality: widget.quality,
            indicatorColor: indicatorColor,
            isBackgroundIndicator: false,
            paintBackground: false,
            paintGlass: true,
            padding: const EdgeInsets.all(4),
            expansion:
                widget.indicatorExpansion.resolve(Directionality.of(context)),
            settings: widget.indicatorSettings,
            borderRadius: indicatorRadius,
            pinchStrength: widget.indicatorPinchStrength,
            // Over a PlatformView the normal backdrop (map region) can't be
            // captured by toImageSync, so the premium indicator refracts the
            // bar's own icon layer instead (capturable) — keeping the
            // premium magic-lens over the PlatformView.
            backgroundKey: widget.platformViewBackdrop
                ? _iconLayerKey
                : widget.backgroundKey,
          ),

          // 4. The selected content, lifted above the glass. Only in
          // passthrough: the pill's body is see-through there, so this copy
          // cannot live under it (see [passthroughOverPlatformView]).
          if (widget.passthroughOverPlatformView)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipPath(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  clipper: JellyClipper(
                    itemCount: widget.tabCount,
                    alignment: alignment,
                    thickness: thickness,
                    expansion: widget.indicatorExpansion
                        .resolve(Directionality.of(context)),
                    transform: jellyTransform,
                    borderRadius: indicatorRadius * 2,
                  ),
                  child: Container(
                    padding: widget.tabPadding,
                    height: widget.barHeight,
                    child: widget.selectedTabBuilder(
                        context, thickness, alignment),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// SearchPill
// =============================================================================

/// The morphing search pill. Collapses to a square icon; expands to a
/// real [TextField] with autofocus. Lives inside the parent
/// [AdaptiveLiquidGlassLayer] so its glass rendering blends with the tab pill.
/// Whether a surface presses with the native button sizing: background
/// animation on and no customised press scale — null means native, a number
/// a fixed factor, as on [GlassButton.interactionScale].
bool _pressesNatively(bool enableBackgroundAnimation, double? pressScale) =>
    enableBackgroundAnimation && pressScale == null;

class SearchPill extends StatefulWidget {
  const SearchPill({
    super.key,
    required this.config,
    required this.isActive,
    required this.quality,
    required this.barBorderRadius,
    required this.enableBackgroundAnimation,
    required this.backgroundPressScale,
    this.onFocusChanged,
    this.interactionGlowColor,
    this.nativePressHighlight = false,
    this.interactionGlowRadius = 1.5,
    this.interactionGlowBlurRadius = 0,
    this.interactionGlowSpreadRadius = 0,
    this.interactionGlowOpacity = 1,
    this.platformViewBackdrop = false,
    this.iconColor,
  });

  final GlassSearchBarConfig config;
  final bool isActive;
  final double barBorderRadius;
  final GlassQuality quality;
  final bool enableBackgroundAnimation;
  final double? backgroundPressScale;
  final Color? iconColor;

  /// Render the pill's glass via the live BackdropFilter path so it composites
  /// over a PlatformView.
  final bool platformViewBackdrop;

  /// Called when the search field gains or loses focus.
  /// Used by the parent bar to drive the dismiss pill visibility.
  final ValueChanged<bool>? onFocusChanged;

  /// The color of the directional glow effect when interacting with the pill.
  final Color? interactionGlowColor;

  /// Whether a default-configured press renders the even GlassButton lift
  /// instead of the directional glow — set by the layout when the app has
  /// not customised the glow colour.
  final bool nativePressHighlight;

  /// The radius spread of the directional glow effect when interacting with the pill.
  final double interactionGlowRadius;

  final double interactionGlowBlurRadius;
  final double interactionGlowSpreadRadius;
  final double interactionGlowOpacity;

  @override
  State<SearchPill> createState() => SearchPillState();
}

class SearchPillState extends State<SearchPill> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  // Tracks whether the × clear button should be visible.
  bool _hasText = false;
  // Tracks focus so the outer bar can show/hide the dismiss pill.
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.config.controller != null) {
      _controller = widget.config.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.config.focusNode != null) {
      _focusNode = widget.config.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.isActive && widget.config.autoFocusOnExpand) {
      // Already active on first build — request focus after one frame so the
      // AnimatedContainer has committed its initial expanded layout.
      // 60 ms is enough for a single vsync cycle at 60-120 Hz while still
      // feeling instant to the user (well under the ~100 ms perception threshold).
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted && widget.isActive) _focusNode.requestFocus();
      });
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void didUpdateWidget(covariant SearchPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive &&
        widget.isActive &&
        widget.config.autoFocusOnExpand) {
      // Became active and auto-focus is enabled — request focus after one
      // render frame so the pill has committed its first expanded layout
      // before the IME is attached.
      //
      // 60 ms sits comfortably above a single 120 Hz vsync (~8 ms) and is
      // well below the ~100 ms human-perception threshold for "immediate".
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted && widget.isActive) _focusNode.requestFocus();
      });
    } else if (oldWidget.isActive && !widget.isActive) {
      // Dismissed — unfocus and clear.
      _focusNode.unfocus();
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus != _hasFocus) {
      setState(() => _hasFocus = hasFocus);
      widget.onFocusChanged?.call(hasFocus);
    }
  }

  /// Wraps [child] in [GlassGlow] only when the resolved glow color is
  /// non-transparent. Skips the wrapper entirely for
  /// [GlassInteractionBehavior.none] and [scaleOnly], avoiding three extra
  /// widget/render-object allocations per frame.
  Widget _wrapWithGlow({required Widget child}) {
    final effectiveColor =
        widget.interactionGlowColor ?? const Color(0x1FFFFFFF);
    if (effectiveColor.a == 0) return child;
    return GlassGlow(
      glowColor: effectiveColor,
      glowRadius: widget.interactionGlowRadius,
      glowBlurRadius: widget.interactionGlowBlurRadius,
      glowSpreadRadius: widget.interactionGlowSpreadRadius,
      glowOpacity: widget.interactionGlowOpacity,
      child: child,
    );
  }

  /// Whether the collapsed circle presses with the native button sizing.
  bool get _nativePress => _pressesNatively(
      widget.enableBackgroundAnimation, widget.backgroundPressScale);

  /// The pressed highlight: a native press brightens the whole surface and
  /// holds it wherever the finger goes, so the default renders the even lift
  /// a [GlassButton] has; a customised glow colour keeps the directional glow.
  Widget _pressHighlight({required Widget child}) =>
      _nativePress && widget.nativePressHighlight
          ? PressAmbientLift(child: child)
          : _wrapWithGlow(child: child);

  /// Builds a standalone shadow widget for the search pill.
  ///
  /// Rendered as a SIBLING in the parent Stack, BELOW the glass pill,
  /// so it doesn't interfere with the blend group compositing.
  /// Returns null in dark mode or when no shadow is configured.
  Widget? buildShadowOverlay(BuildContext context, ShapeBorder pillShape) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    if (isDark) return null;

    final effectiveSettings = InheritedLiquidGlass.ofOrDefault(context);
    final shadows = effectiveSettings.effectiveShadow;
    if (shadows.isEmpty) return null;

    return IgnorePointer(
      child: ClipPath(
        clipBehavior: Clip.antiAlias,
        clipper: _InverseSearchBarClipper(pillShape),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius:
                GlassDefaults.safeBorderRadius(widget.barBorderRadius),
            boxShadow: shadows,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use GlassTheme.brightnessOf — the single brightness authority inside
    // this package. CupertinoDynamicColor.resolve() / CupertinoTheme.brightnessOf()
    // bypasses the glass cascade and reads system brightness, giving black icons
    // on dark glass when the device OS brightness is light.
    final brightness = GlassTheme.brightnessOf(context);

    // Resolves a Color that may be a CupertinoDynamicColor using glass brightness.
    Color resolveIconColor(Color c) {
      if (c is CupertinoDynamicColor) {
        return brightness == Brightness.dark ? c.darkColor : c.color;
      }
      return c;
    }

    final rawIconColor = widget.config.searchIconColor ??
        widget.iconColor ??
        CupertinoColors.label;
    final iconColor = resolveIconColor(rawIconColor);
    final micColor =
        resolveIconColor(widget.config.micIconColor ?? rawIconColor);
    final shape = LiquidRoundedRectangle(borderRadius: widget.barBorderRadius);

    // LayoutBuilder reads the ACTUAL rendered width on every frame.
    // When isActive flips true, AnimatedContainer starts at compact width
    // (barHeight ≈ 64 px) and animates outward. The expanded Row needs at
    // least 84 px (padding 32 + icons 52). We gate on 90 px so the Row is
    // never built at compact width → no layout overflow, no content bleed.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const kExpandThreshold = 90.0;

        if (!widget.isActive || w < kExpandThreshold) {
          final isOval = (w - constraints.maxHeight).abs() < 2;
          // LiquidOval, not a rounded rectangle at w / 2: the press growth
          // scales the painted rect, and a layout-time radius squares the
          // corners off as it grows. An oval's radius rides the rect.
          final currentShape = isOval ? const LiquidOval() : shape;

          return Stack(
            fit: StackFit.expand,
            children: [
              LiquidStretch(
                interactionScale: widget.enableBackgroundAnimation
                    ? (widget.backgroundPressScale ?? 1.0)
                    : 1.0,
                // The collapsed circle presses like a native button (#272):
                // a null pressScale resolves to the ~17 pt growth with the
                // tremor stretch on top; a number stays a fixed factor, as
                // on GlassButton.
                pressGrowth:
                    _nativePress ? LiquidStretch.nativePressGrowth : null,
                anchorStretchSettings: _nativePress
                    ? AnchorStretchSettings.nativeTremor
                    : const AnchorStretchSettings(),
                stretch: widget.platformViewBackdrop ? 0.0 : 0.5,
                resistance: 0.01,
                anchorStretch:
                    true, // Matches GlassButton default (keeps it attached so it morphs)
                // The collapsed circle opens search: a button named by the
                // field's own hint text, which the app already localizes.
                child: Semantics(
                  container: true,
                  button: true,
                  label: widget.config.hintText,
                  child: GestureDetector(
                    key: const ValueKey('pill-collapsed'),
                    behavior: HitTestBehavior.opaque,
                    onTap: (widget.isActive && widget.config.expandWhenActive)
                        ? () {}
                        : () => widget.config.onSearchToggle(true),
                    child: AdaptiveGlass.grouped(
                      shape: currentShape,
                      // Over a PlatformView AdaptiveGlass routes to the frost veil
                      // automatically (platformViewBackdrop), so the requested
                      // quality passes through unchanged here.
                      quality: widget.quality,
                      platformViewBackdrop: widget.platformViewBackdrop,
                      child: _pressHighlight(
                        child: Center(
                          // IconTheme ensures custom searchIcon widgets inherit
                          // the resolved color. The fallback Icon also sets
                          // color: explicitly for belt-and-braces safety.
                          child: IconTheme(
                            data: IconThemeData(color: iconColor),
                            child: widget.config.searchIcon ??
                                Icon(CupertinoIcons.search, color: iconColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: 0,
                  child: _buildExpanded(iconColor, micColor),
                ),
              ),
            ],
          );
        }

        // Wrap with an opaque GestureDetector so taps anywhere inside the
        // glass pill — including the 16 px horizontal padding zones — focus
        // the search field instead of passing through to background content.
        // Without this, AdaptiveGlass.grouped defers hit-testing to its
        // children, leaving the padding area as a transparent pass-through.
        //
        // iOS 26: wrapped in GlassGlowLayer so GlassGlow inside can report
        // touch position and paint a soft directional highlight on the surface.
        // iOS 26: directional glow on press (GlassGlowLayer + GlassGlow).
        // The expanded field answers a drag per axis, measured off Photos:
        // along its length a gentle jelly-follow that saturates near ~7 pt
        // of travel however far the finger goes (stretch 0.22 / resistance
        // 0.03), necking into the separate dismiss button; vertically no
        // follow at all, just a couple of points of stretch from the far
        // edge. The vertical part is a second, axis-constrained
        // [LiquidStretch] because the jelly normalises each axis by its own
        // dimension — sized off the field's height, its vertical response
        // would dwarf the native one. A customised pressScale or a platform-
        // view backdrop keeps the still field, like every stretch on these
        // surfaces.
        final fieldStretches = _nativePress && !widget.platformViewBackdrop;
        final Widget field = LiquidStretch(
          // The field keeps its subtle press inflation on a plain hold; only
          // the collapsed circles trade the factor for the native growth.
          interactionScale: widget.enableBackgroundAnimation
              ? (widget.backgroundPressScale ?? 1.04)
              : 1.0,
          stretch: fieldStretches ? 0.22 : 0.0,
          resistance: fieldStretches ? 0.03 : 0.08,
          allowPositiveY: fieldStretches ? false : null,
          allowNegativeY: fieldStretches ? false : null,
          anchorStretch: false, // Search pill uses jelly-follow, not anchored
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Only widens the pointer target to the padding; the text field
            // inside is the control screen readers use.
            excludeFromSemantics: true,
            onTap: _focusNode.requestFocus,
            child: AdaptiveGlass.grouped(
              shape: shape,
              quality: widget.quality,
              platformViewBackdrop: widget.platformViewBackdrop,
              child: _wrapWithGlow(
                child: _buildExpanded(iconColor, micColor),
              ),
            ),
          ), // GestureDetector
        ); // LiquidStretch
        return LiquidStretch(
          interactionScale: 1.0, // the scale lives on the inner layer
          stretch: fieldStretches ? 0.09 : 0.0,
          resistance: 0.03,
          axis: Axis.vertical,
          anchorStretch: false,
          child: field,
        );
      },
    );
  }

  void _handleClear() {
    _controller.clear();
    widget.config.onChanged?.call('');
  }

  Widget _buildExpanded(Color iconColor, Color micColor) {
    final config = widget.config;
    // Eagerly resolve any CupertinoDynamicColor against the glass brightness
    // cascade. CupertinoColors.label.resolveFrom calls
    // CupertinoTheme.brightnessOf, which falls through to
    // MediaQuery.platformBrightness (OS brightness) when no explicit Cupertino
    // theme overrides it. That produces white text on a light-mode pill when
    // the device OS is dark but the app is forced to light. Furthermore, any
    // caller-provided CupertinoDynamicColor passed via config.textColor or
    // config.hintStyle must also be flattened here, otherwise CupertinoTextField
    // will re-resolve it against OS brightness during its own build.
    final glassBrightness = GlassTheme.brightnessOf(context);
    Color resolveDynamicColor(Color c) {
      if (c is CupertinoDynamicColor) {
        return glassBrightness == Brightness.dark ? c.darkColor : c.color;
      }
      return c;
    }

    // Typed text: an explicit config.textColor wins. hintStyle's colour is the
    // fallback only when no textColor was given, so a caller can mute the
    // placeholder without muting what the user types.
    final hintColor = config.hintStyle?.color;
    final effectiveTextColor = resolveDynamicColor(
      config.textColor ?? hintColor ?? CupertinoColors.label,
    );

    final effectiveTextStyle = (config.hintStyle ?? const TextStyle()).copyWith(
      color: effectiveTextColor,
      fontSize: config.hintStyle?.fontSize ?? 17,
      fontWeight: config.hintStyle?.fontWeight ?? FontWeight.w400,
    );

    final placeholderColor =
        hintColor != null ? resolveDynamicColor(hintColor) : iconColor;

    final effectivePlaceholderStyle = (config.hintStyle ??
            const TextStyle(fontSize: 17, fontWeight: FontWeight.w400))
        .copyWith(color: placeholderColor);

    // Trailing slot priority:
    //   1. trailingBuilder — caller has full control.
    //   2. Animated × clear when _hasText (iOS 26 pattern — clears without dismissing).
    //   3. Default mic icon.
    // Note: the dismiss (close-search) × is a SEPARATE sibling pill in the
    // outer bar Row — it is NOT rendered here. This matches the real iOS 26
    // Apple News layout where the × is its own glass button outside the search pill.
    Widget trailing;
    if (config.trailingBuilder != null) {
      trailing = config.trailingBuilder!(context);
    } else {
      trailing = AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: _hasText
            ? Semantics(
                key: const ValueKey('clear'),
                container: true,
                button: true,
                label: config.clearButtonSemanticLabel ??
                    glassCupertinoLocalizationsOf(context).clearButtonLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleClear,
                  child: Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: iconColor,
                    size: 18,
                  ),
                ),
              )
            : Semantics(
                key: const ValueKey('mic'),
                container: config.onMicTap != null,
                button: config.onMicTap != null ? true : null,
                label: config.onMicTap != null
                    ? config.micButtonSemanticLabel
                    : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: config.onMicTap,
                  child: config.onMicTap != null
                      ? Icon(
                          CupertinoIcons.mic_fill,
                          color: micColor,
                          size: 18,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
      );
    }

    // The expanded pill content.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: false,
              onTap: config.onSearchFieldTap,
              onChanged: config.onChanged,
              onSubmitted: config.onSubmitted,
              onTapOutside: config.onTapOutside,
              textInputAction: config.textInputAction,
              keyboardType: config.keyboardType,
              autocorrect: config.autocorrect,
              enableSuggestions: config.enableSuggestions,
              style: effectiveTextStyle,
              // When null, Flutter's standard cursor-color resolution
              // kicks in (textSelectionTheme → Cupertino primaryColor
              // on iOS → colorScheme.primary). Callers wanting the
              // pre-0.13.0 "cursor matches textColor" behaviour pass
              // `cursorColor: textColor` explicitly via [config].
              cursorColor: config.cursorColor,
              placeholder: config.hintText,
              placeholderStyle: effectivePlaceholderStyle,
              padding: EdgeInsets.zero,
              decoration: null,
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

/// Clips out the interior of the bar shape for shadow painting.
class _InverseSearchBarClipper extends CustomClipper<Path> {
  const _InverseSearchBarClipper(this.shape);

  final ShapeBorder shape;

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    final shapePath = shape.getOuterPath(rect);
    final outerRect = rect.inflate(50.0);
    final outerPath = Path()..addRect(outerRect);
    return Path.combine(PathOperation.difference, outerPath, shapePath);
  }

  @override
  bool shouldReclip(_InverseSearchBarClipper oldClipper) =>
      oldClipper.shape != shape;
}

/// A lightweight trailing action pill for [GlassTabBar.minimizable].
///
/// Renders the action button's icon and handles taps without allocating the
/// search text field, focus node, or clear-button machinery that [SearchPill]
/// requires.
class MinimizableTrailingPill extends StatelessWidget {
  const MinimizableTrailingPill({
    super.key,
    required this.icon,
    required this.onTap,
    required this.quality,
    required this.barBorderRadius,
    required this.enableBackgroundAnimation,
    required this.backgroundPressScale,
    this.interactionGlowColor,
    this.nativePressHighlight = false,
    this.interactionGlowRadius = 1.5,
    this.interactionGlowBlurRadius = 0,
    this.interactionGlowSpreadRadius = 0,
    this.interactionGlowOpacity = 1,
    this.platformViewBackdrop = false,
    this.iconColor,
    this.label,
  });

  final Widget? icon;
  final VoidCallback? onTap;
  final String? label;
  final double barBorderRadius;
  final GlassQuality quality;
  final bool enableBackgroundAnimation;
  final double? backgroundPressScale;
  final Color? iconColor;
  final bool platformViewBackdrop;
  final Color? interactionGlowColor;

  /// See [SearchPill.nativePressHighlight].
  final bool nativePressHighlight;
  final double interactionGlowRadius;
  final double interactionGlowBlurRadius;
  final double interactionGlowSpreadRadius;
  final double interactionGlowOpacity;

  Widget _wrapWithGlow({required Widget child}) {
    final effectiveColor = interactionGlowColor ?? const Color(0x1FFFFFFF);
    if (effectiveColor.a == 0) return child;
    return GlassGlow(
      glowColor: effectiveColor,
      glowRadius: interactionGlowRadius,
      glowBlurRadius: interactionGlowBlurRadius,
      glowSpreadRadius: interactionGlowSpreadRadius,
      glowOpacity: interactionGlowOpacity,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = GlassTheme.brightnessOf(context);
    Color resolveIconColor(Color c) {
      if (c is CupertinoDynamicColor) {
        return brightness == Brightness.dark ? c.darkColor : c.color;
      }
      return c;
    }

    final rawIconColor = iconColor ?? CupertinoColors.label;
    final resolvedIconColor = resolveIconColor(rawIconColor);
    final shape = LiquidRoundedRectangle(borderRadius: barBorderRadius);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isOval = (w - constraints.maxHeight).abs() < 2;
        // LiquidOval so the corners ride the press growth — see SearchPill.
        final currentShape = isOval ? const LiquidOval() : shape;

        final nativePress =
            _pressesNatively(enableBackgroundAnimation, backgroundPressScale);
        final content = Center(
          child: IconTheme(
            data: IconThemeData(color: resolvedIconColor),
            child: icon ?? const SizedBox.shrink(),
          ),
        );
        return LiquidStretch(
          interactionScale:
              enableBackgroundAnimation ? (backgroundPressScale ?? 1.0) : 1.0,
          // Presses like a native button (#272), as the search circle does.
          pressGrowth: nativePress ? LiquidStretch.nativePressGrowth : null,
          anchorStretchSettings: nativePress
              ? AnchorStretchSettings.nativeTremor
              : const AnchorStretchSettings(),
          stretch: platformViewBackdrop ? 0.0 : 0.5,
          resistance: 0.01,
          anchorStretch: true,
          child: GestureDetector(
            key: const ValueKey('pill-collapsed'),
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Semantics(
              button: true,
              label: label,
              enabled: onTap != null,
              child: AdaptiveGlass.grouped(
                shape: currentShape,
                quality: quality,
                platformViewBackdrop: platformViewBackdrop,
                child: nativePress && nativePressHighlight
                    ? PressAmbientLift(child: content)
                    : _wrapWithGlow(child: content),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The even, whole-surface brightening a pressed native button holds for as
/// long as the finger is down, wherever it goes — [GlassButton]'s
/// `ambientBaseLight` lift for circles that are not GlassButtons (the
/// collapsed search and trailing pills). Drawn under [child] so the glyph
/// stays crisp.
class PressAmbientLift extends StatefulWidget {
  /// Creates the lift around the pressed content.
  const PressAmbientLift({required this.child, super.key});

  /// The pill content the lift sits beneath.
  final Widget child;

  @override
  State<PressAmbientLift> createState() => _PressAmbientLiftState();
}

class _PressAmbientLiftState extends State<PressAmbientLift>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    // Ramps over the press inflation, collapses on release, as the native
    // highlight does — the timings GlassButton uses.
    duration: GlassDefaults.ambientLiftDuration,
    reverseDuration: GlassDefaults.ambientLiftReverseDuration,
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GlassButton's ambientBaseLight defaults: measured against a native
    // light-mode press, halved in dark mode.
    final target = GlassTheme.brightnessOf(context) == Brightness.dark
        ? GlassDefaults.ambientBaseLightDark
        : GlassDefaults.ambientBaseLight;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      onPointerCancel: (_) => _controller.reverse(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _controller.drive(Tween(begin: 0.0, end: target)),
            child: const IgnorePointer(
              child: ColoredBox(color: Color(0xFFFFFFFF)),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
