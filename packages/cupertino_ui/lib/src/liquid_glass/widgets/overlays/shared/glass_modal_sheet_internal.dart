part of '../glass_modal_sheet.dart';

class _SheetLayout extends StatelessWidget {
  final double interactionScale;
  final bool enableInteractionGlow;
  final Color? glowColor;
  final double glowRadius;
  final double stretch;
  final double interactionStretch;
  final double resistance;
  final double left;
  final double right;
  final double effectiveBottom;
  final double effectiveHeight;
  final double topRadius;
  final double bottomRadius;
  final double colorOpacity;
  final double glassOpacity;
  final Color effectiveExpandedColor;
  final LiquidGlassSettings fadedSettings;
  final GlassQuality effectiveQuality;
  final bool platformViewBackdrop;
  final Animation<double> saturationAnimation;
  final double expandProgress;
  final PointerDownEventListener onPointerDown;
  final PointerMoveEventListener onPointerMove;
  final PointerUpEventListener onPointerUp;
  final PointerCancelEventListener onPointerCancel;
  final ScrollController scrollController;
  final ValueNotifier<GlassSheetState> currentStateNotifier;
  final double expandProgressValue;

  /// Progress toward the topmost detent; gates inner content scrolling.
  /// Distinct from [expandProgressValue] (the half→full visual crossfade) so
  /// a half-only sheet — whose crossfade stays 0 to keep the glass look —
  /// still scrolls its content once it reaches its max (half) detent.
  final double contentScrollProgress;
  final Widget child;
  final bool showDragIndicator;
  final Color? dragIndicatorColor;
  final double dragIndicatorWidth;
  final double dragIndicatorHeight;
  final double dragIndicatorTopPadding;
  final EdgeInsetsGeometry? padding;
  final bool maintainContentGlass;
  final LiquidGlassSettings? fullStateContentSettings;
  final bool enableTopFade;
  final double topFadeHeight;
  final bool enableSaturationGlow;
  final bool suppressInteractionOnChildren;
  final VoidCallback? onDismiss;

  const _SheetLayout({
    required this.interactionScale,
    required this.enableInteractionGlow,
    this.glowColor,
    required this.glowRadius,
    required this.stretch,
    required this.interactionStretch,
    required this.resistance,
    required this.left,
    required this.right,
    required this.effectiveBottom,
    required this.effectiveHeight,
    required this.topRadius,
    required this.bottomRadius,
    required this.colorOpacity,
    required this.glassOpacity,
    required this.effectiveExpandedColor,
    required this.fadedSettings,
    required this.effectiveQuality,
    required this.platformViewBackdrop,
    required this.saturationAnimation,
    required this.expandProgress,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onPointerCancel,
    required this.scrollController,
    required this.currentStateNotifier,
    required this.expandProgressValue,
    required this.contentScrollProgress,
    required this.child,
    required this.showDragIndicator,
    this.dragIndicatorColor,
    required this.dragIndicatorWidth,
    required this.dragIndicatorHeight,
    required this.dragIndicatorTopPadding,
    this.padding,
    required this.maintainContentGlass,
    this.fullStateContentSettings,
    required this.enableTopFade,
    required this.topFadeHeight,
    required this.enableSaturationGlow,
    required this.suppressInteractionOnChildren,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final handleZone = _SheetHandleZone(
      indicatorWidth: dragIndicatorWidth,
      indicatorHeight: dragIndicatorHeight,
      topPadding: dragIndicatorTopPadding,
      color: dragIndicatorColor,
      onDismiss: onDismiss,
    );

    final contentZone = _SheetContent(
      scrollController: scrollController,
      isFullScreen: contentScrollProgress > _kTopDetentThreshold,
      padding: padding,
      child: child,
    );

    return Positioned(
      left: left,
      right: right,
      bottom: effectiveBottom,
      height: effectiveHeight,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
        child: AnimatedBuilder(
          animation: saturationAnimation,
          child: _applyTopFade(contentZone),
          builder: (context, child) {
            final pulseT = saturationAnimation.value;
            final pulsedSettings = fadedSettings.copyWith(
              lightIntensity: lerpDouble(
                fadedSettings.lightIntensity,
                0.8 * glassOpacity,
                pulseT,
              )!,
              saturation: lerpDouble(
                fadedSettings.saturation,
                2.2 * glassOpacity + (1.0 - glassOpacity),
                pulseT,
              )!,
            );

            final currentTopRadius = topRadius;
            final currentBottomRadius = bottomRadius;

            // Content settings: vibrant glass settings when maintainContentGlass
            // is true and the sheet is nearly full.
            final contentSettings =
                (maintainContentGlass && expandProgressValue > 0.9)
                    ? (fullStateContentSettings ??
                        pulsedSettings.copyWith(
                          lightIntensity:
                              pulsedSettings.lightIntensity.clamp(0.4, 1.0),
                          saturation: pulsedSettings.saturation.clamp(1.5, 3.0),
                          blur: pulsedSettings.blur.clamp(15.0, 40.0),
                        ))
                    : pulsedSettings;

            // Compute dynamic glass visibility for current expansion state.
            final bool isFullyExpanded = expandProgressValue > 0.98;
            // Below full, hold the glass at full strength — including on the way
            // down to dismiss. This previously ramped glassVisibility to 0 over
            // the last stretch of the collapse (glassOpacity × 5), fading the
            // sheet's own surface out as it closed; Apple instead keeps the
            // surface opaque and just slides it off the bottom (only the
            // background dim fades). See discussions #130 / #156.
            final double glassVisibility =
                isFullyExpanded ? (maintainContentGlass ? 1.0 : 0.0) : 1.0;

            // Fade glass uniformly via settings rather than an Opacity widget.
            //
            // IMPORTANT: blur is clamped to a minimum of 0.001 rather than
            // allowing it to reach exactly 0. When `AdaptiveGlass` receives
            // `settings.effectiveBlur == 0` it switches its return type from
            // the normal glass widget to `_FrostedFallback`. A type change at
            // the same slot causes Flutter to tear down the existing element
            // subtree and rebuild it from scratch — firing `initState` on all
            // child `State` objects and destroying scroll positions, controllers,
            // etc. A 0.001 blur is visually imperceptible but keeps the tree
            // structure (and therefore the element identity) stable.
            final currentSettings = contentSettings.copyWith(
              glassColor: contentSettings.glassColor.withValues(
                alpha: contentSettings.glassColor.a * glassVisibility,
              ),
              blur: (contentSettings.blur * glassVisibility)
                  .clamp(0.001, double.infinity),
              thickness: contentSettings.thickness * glassVisibility,
            );

            final shape = LiquidVerticalRoundedSuperellipse(
              topRadius: currentTopRadius,
              bottomRadius: currentBottomRadius,
            );

            return GlassModalSheetStateProvider(
              info: SheetStateInfo(
                state: currentStateNotifier.value,
                progress: expandProgressValue,
                isExpanded: expandProgressValue > 0.9,
                submergedBottom: effectiveBottom < 0 ? -effectiveBottom : 0.0,
              ),
              child: LiquidStretch(
                interactionScale: interactionScale,
                stretch: interactionStretch,
                resistance: resistance,
                hitTestBehavior: HitTestBehavior.translucent,
                suppressInteractionOnChildren: suppressInteractionOnChildren,
                axis: Axis.vertical,
                allowPositive: false,
                allowNegative: true,
                anchorStretch:
                    false, // Modal sheets use jelly-follow, not anchored
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Empty slot placeholder — kept so the glass surface below
                    //    keeps its element identity (this Stack is sensitive to slot
                    //    shifts re-initing the glass). It used to hold a BoxShadow
                    //    for faux depth, but behind the transparent fill + the
                    //    translucent frost it never read as a drop shadow: it bled
                    //    THROUGH the glass as interior darkening (an inner-shadow /
                    //    vignette), was invisible behind the opaque full state, and
                    //    broke light mode. Apple's glass sheets don't darken their
                    //    interior — removed.
                    Positioned.fill(
                      child: const SizedBox.shrink(
                        key: Key('glass_modal_sheet_shadow_slot'),
                      ),
                    ),
                    // 2. Single unified glass surface — owns the SDF clip,
                    //    solid fill, glow, and content. Consolidating into one
                    //    AdaptiveGlass prevents the dual-stencil fragmentation
                    //    that caused ghosting in Impeller Premium mode.
                    Positioned.fill(
                      child: AdaptiveGlass(
                        shape: shape,
                        settings: currentSettings,
                        quality: effectiveQuality,
                        platformViewBackdrop: platformViewBackdrop,
                        useOwnLayer: true,
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // 3. Solid fill — inside AdaptiveGlass so it shares
                            //    the same SDF mask and clip path. Always rendered
                            //    (transparent when colorOpacity≈0) to keep the
                            //    Stack structure stable — inserting/removing this
                            //    child would shift GlassGlow's slot index, causing
                            //    Flutter to tear down its subtree and fire
                            //    initState on all child State objects.
                            Positioned.fill(
                              child: DecoratedBox(
                                key: const Key('glass_modal_sheet_fill'),
                                decoration: BoxDecoration(
                                  color: effectiveExpandedColor.withValues(
                                    alpha: colorOpacity,
                                  ),
                                ),
                              ),
                            ),
                            // 4. Glow overlay + content.
                            Positioned.fill(
                              child: Builder(builder: (innerContext) {
                                final isDark =
                                    GlassTheme.brightnessOf(innerContext) ==
                                        Brightness.dark;
                                return GlassGlow(
                                  glowColor: (enableInteractionGlow &&
                                          glassOpacity > 0.05 &&
                                          expandProgress < 0.9)
                                      ? (glowColor ??
                                          (isDark
                                              ? CupertinoColors.white
                                                  .withValues(
                                                      alpha: GlassDefaults
                                                          .specularLightAlpha)
                                              : CupertinoColors.black
                                                  .withValues(
                                                      alpha: GlassDefaults
                                                          .specularDarkAlpha)))
                                      : const Color(0x00000000),
                                  glowRadius: glowRadius,
                                  hitTestBehavior: HitTestBehavior.translucent,
                                  pulse: (enableSaturationGlow &&
                                          expandProgress < 0.9)
                                      ? saturationAnimation.value
                                      : 0,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        // Replaces Material(color: transparent) — SizedBox.expand
                                        // provides identical visual output for a glass sheet child.
                                        child: SizedBox.expand(child: child!),
                                      ),
                                      if (showDragIndicator)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: 44,
                                          child: handleZone,
                                        ),
                                    ],
                                  ),
                                ); // GlassGlow
                              }), // Builder
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _applyTopFade(Widget content) {
    if (!enableTopFade) return content;

    // Use a smooth fade for the ShaderMask stops to avoid abrupt tree mutations
    // and provide a seamless transition as the sheet reaches the top.
    final fadeT = ((expandProgressValue - 0.8) / 0.2).clamp(0.0, 1.0);

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        // When fadeT is 0, the 'transparent' stop is pushed above the bounds (0.0),
        // effectively making the whole mask opaque.
        final stop = lerpDouble(0.0, topFadeHeight, fadeT)!;
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00000000),
            Color(0xFF000000),
          ],
          stops: [0.0, (stop / bounds.height).clamp(0.0, 1.0)],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: content,
    );
  }
}

// ===========================================================================
// Internal UI Support
// ===========================================================================

class _SheetHandleZone extends StatelessWidget {
  const _SheetHandleZone({
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.topPadding,
    this.color,
    this.onDismiss,
  });

  final double indicatorWidth;
  final double indicatorHeight;
  final double topPadding;
  final Color? color;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final state = GlassModalSheetStateProvider.of(context);
    final isGlass = state != null ? state.progress < 0.9 : true;

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding),
          _GlassDragIndicator(
            isGlass: isGlass,
            width: indicatorWidth,
            height: indicatorHeight,
            color: color,
            onDismiss: onDismiss,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GlassDragIndicator extends StatelessWidget {
  const _GlassDragIndicator({
    required this.isGlass,
    required this.width,
    required this.height,
    this.color,
    this.onDismiss,
  });

  final bool isGlass;
  final double width;
  final double height;
  final Color? color;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    // iOS 26: white at 35% in dark mode, black at 20% in light mode
    final defaultColor =
        isDark ? const Color(0x59FFFFFF) : const Color(0x33000000);

    return Semantics(
      label: 'Drag handle',
      hint: 'Swipe down to dismiss',
      onTap: onDismiss ?? () => Navigator.maybePop(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? defaultColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;
  final bool isFullScreen;
  final EdgeInsetsGeometry? padding;

  const _SheetContent({
    required this.child,
    required this.scrollController,
    required this.isFullScreen,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollPhysics physics = isFullScreen
        ? const _ClampingTopScrollPhysics()
        : const _ExpandFirstScrollPhysics();

    return ScrollControllerProvider(
      controller: scrollController,
      physics: physics,
      // Publishing the physics is not enough on its own: content that never
      // reads the provider would keep the platform default and lose both the
      // expand-first gate and the handover, silently.
      child: ScrollConfiguration(
        behavior: _SheetScrollBehavior(
          parent: ScrollConfiguration.of(context),
          physics: physics,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

// ===========================================================================
// Custom Scroll Physics
// ===========================================================================

/// Physics for a sheet below its topmost detent: the drag is accepted and only
/// its forward movement is refused.
///
/// [NeverScrollableScrollPhysics] refuses the gesture itself, and a [Scrollable]
/// that never started a drag has nothing to continue with when the sheet tops
/// out mid-swipe — the finger has to lift and swipe again. Staying in the drag
/// and zeroing the forward offset keeps the [Scrollable] live, so reaching the
/// top detent hands the same gesture over instead of ending it.
class _ExpandFirstScrollPhysics extends ClampingScrollPhysics {
  const _ExpandFirstScrollPhysics({super.parent});

  @override
  _ExpandFirstScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ExpandFirstScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // A negative offset drives `pixels` forward — the finger travelling up,
    // which below the top detent belongs to the sheet. Backward offsets pass
    // through untouched so content left scrolled by an earlier expansion can be
    // pulled back to its top before the drag becomes the collapse.
    if (offset < 0.0) return 0.0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // The release velocity reaches the list as well as the sheet. Without this
    // a flick the sheet answered by expanding also flings the list the moment
    // the finger lifts.
    if (velocity > 0.0 &&
        !position.outOfRange &&
        position.pixels <= position.minScrollExtent) {
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

/// Applies the sheet's physics to the vertical scrollables inside it, and
/// delegates every other concern to the ambient behavior.
///
/// Only vertical drags are ambiguous between scrolling the content and moving
/// the sheet, so a horizontal scrollable keeps the ambient physics and a
/// carousel inside a sheet still feels native.
class _SheetScrollBehavior extends ScrollBehavior {
  const _SheetScrollBehavior({required this.parent, required this.physics});

  /// The ambient behavior; everything except vertical physics defers to it.
  final ScrollBehavior parent;

  /// The physics applied to vertical scrollables at the sheet's current detent.
  final ScrollPhysics physics;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Physics are resolved from the Scrollable's own element, so the widget at
    // this context is the Scrollable being configured.
    final Widget scrollable = context.widget;
    if (scrollable is Scrollable &&
        axisDirectionToAxis(scrollable.axisDirection) != Axis.vertical) {
      return parent.getScrollPhysics(context);
    }
    return physics.applyTo(parent.getScrollPhysics(context));
  }

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      parent.getPlatform(context);

  @override
  Set<PointerDeviceKind> get dragDevices => parent.dragDevices;

  @override
  MultitouchDragStrategy getMultitouchDragStrategy(BuildContext context) =>
      parent.getMultitouchDragStrategy(context);

  @override
  Set<LogicalKeyboardKey> get pointerAxisModifiers =>
      parent.pointerAxisModifiers;

  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      parent.buildScrollbar(context, child, details);

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      parent.buildOverscrollIndicator(context, child, details);

  @override
  GestureVelocityTrackerBuilder velocityTrackerBuilder(BuildContext context) =>
      parent.velocityTrackerBuilder(context);

  @override
  bool shouldNotify(covariant _SheetScrollBehavior oldDelegate) =>
      oldDelegate.parent != parent || oldDelegate.physics != physics;
}

class _ClampingTopScrollPhysics extends BouncingScrollPhysics {
  const _ClampingTopScrollPhysics({super.parent});

  @override
  _ClampingTopScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ClampingTopScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels; // Under-scroll (top)
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent; // Hit top
    }
    return super.applyBoundaryConditions(position, value);
  }
}

// ===========================================================================
// State Providers
// ===========================================================================

/// [InheritedWidget] that propagates a [ScrollController] and [ScrollPhysics]
/// to descendant widgets inside a [GlassModalSheet].
///
/// The sheet installs [physics] on its vertical scrollables itself, so content
/// need not read this provider to behave correctly; it remains the way to reach
/// the shared [controller], and to opt a scrollable in explicitly. Below the
/// topmost detent the published physics hold the content still so drags grow
/// the sheet instead of scrolling the list inside it.
class ScrollControllerProvider extends InheritedWidget {
  /// The [ScrollController] shared with descendant scrollable widgets.
  final ScrollController controller;

  /// The [ScrollPhysics] that the sheet applies at the current expansion level.
  final ScrollPhysics physics;

  /// Creates a [ScrollControllerProvider] that exposes [controller] and
  /// [physics] to its subtree.
  const ScrollControllerProvider({
    super.key,
    required this.controller,
    required this.physics,
    required super.child,
  });

  /// Returns the nearest [ScrollControllerProvider] in [context], or null.
  static ScrollControllerProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScrollControllerProvider>();
  }

  @override
  bool updateShouldNotify(ScrollControllerProvider old) =>
      controller != old.controller || physics != old.physics;
}

/// Information about the current state of a [GlassModalSheet].
class SheetStateInfo {
  /// The current snap state.
  final GlassSheetState state;

  /// Expansion progress from 0.0 (hidden/peek) to 1.0 (full).
  final double progress;

  /// Whether the sheet is currently in its expanded (full) state.
  final bool isExpanded;

  /// The distance in logical pixels that the sheet's bottom edge is submerged
  /// past the bottom of the device screen (e.g. to hide bottom rounded corners
  /// in [GlassSheetState.full]), or 0.0 if resting at or above the screen edge.
  final double submergedBottom;

  /// Creates a [SheetStateInfo] snapshot.
  const SheetStateInfo({
    required this.state,
    required this.progress,
    required this.isExpanded,
    this.submergedBottom = 0.0,
  });
}

/// Inherited widget that provides [SheetStateInfo] to its descendants.
class GlassModalSheetStateProvider extends InheritedWidget {
  /// The current sheet state information.
  final SheetStateInfo info;

  /// Creates a provider that exposes [info] to the widget subtree.
  const GlassModalSheetStateProvider({
    super.key,
    required this.info,
    required super.child,
  });

  /// Returns the nearest [SheetStateInfo] in [context], or null.
  static SheetStateInfo? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GlassModalSheetStateProvider>()
        ?.info;
  }

  @override

  /// Returns true when any field of [info] has changed.
  bool updateShouldNotify(GlassModalSheetStateProvider oldWidget) {
    return info.state != oldWidget.info.state ||
        info.progress != oldWidget.info.progress ||
        info.isExpanded != oldWidget.info.isExpanded ||
        info.submergedBottom != oldWidget.info.submergedBottom;
  }
}

// ===========================================================================
// Scaffold implementation
// ===========================================================================

/// A convenience scaffold that layers a [GlassModalSheet] over a [body] widget.
///
/// Composes the sheet and its underlying content (e.g. a map, a photo grid)
/// into a single widget. Use [GlassModalSheetScaffold] when you want a
/// self-contained sheet + content stack without managing the [Stack] yourself.
///
/// If you need finer control \u2014 e.g. the sheet sits inside an existing
/// [Stack] or its overlay is managed externally \u2014 use [GlassModalSheet]
/// directly.
class GlassModalSheetScaffold extends StatelessWidget {
  /// Body widget (e.g., a map or a list) that stays under the sheet.
  final Widget body;

  /// Sheet widget displayed inside the glass sheet.
  final Widget sheet;

  /// Height in the 'half' state (0.0 - 1.0 fraction or absolute pixels). Default: 0.45.
  final double halfSize;

  /// Maximum sheet height in 'full' state. If null, defaults to screen height minus 90px.
  final double? fullSize;

  /// Initial state when the scaffold is first displayed.
  final GlassSheetState initialState;

  /// Minimum visible height in the 'peek' state.
  ///
  /// - If 0.0 < value <= 1.0: Treated as a fraction of screen height.
  /// - If value > 1.0: Treated as absolute pixels.
  ///
  /// Default: 90.0 (absolute pixels).
  final double peekSize;

  /// Corner radius of the top edges in its floating state.
  final double? topBorderRadius;

  /// Corner radius of the bottom edges in its floating state.
  final double? bottomBorderRadius;

  /// Corner radius of the top edges when fully expanded.
  final double? fullTopBorderRadius;

  /// Corner radius of the bottom edges when fully expanded.
  final double? fullBottomBorderRadius;

  /// Horizontal padding between the sheet and the screen edges.
  final double horizontalMargin;

  /// Bottom padding from the screen edge.
  final double bottomMargin;

  /// Threshold (0.0 - 1.0) at which the sheet starts turning into a solid color.
  final double fillThreshold;

  /// Glass morphism effect settings (blur, thickness, lighting).
  final LiquidGlassSettings? settings;

  /// Background color used when the sheet is fully expanded and opaque.
  final Color? expandedColor;

  /// [expandedColor] while the glass brightness is dark.
  final Color? expandedDarkColor;

  /// Rendering quality (BackdropFilter vs Shader). Defaults to standard.
  final GlassQuality? quality;

  /// Forces the BackdropFilter fallback so premium glass renders cleanly over
  /// an iOS PlatformView. Forwarded to the sheet's [AdaptiveGlass].
  final bool platformViewBackdrop;

  /// Color/Saturation transition mode when expanding to full.
  final GlassFillTransition fillTransition;

  /// Scale factor applied during interaction for tactile feedback. Default: 1.01.
  final double interactionScale;

  /// Whether to show glow/glare on touch for tactile feedback. Default: true.
  final bool enableInteractionGlow;

  /// Whether to pulse saturation/lighting of the whole sheet on touch. Default: true.
  final bool enableSaturationGlow;

  /// Optional state-specific settings that override the base [settings].
  final LiquidGlassSettings? peekSettings;

  /// The settings applied when the sheet is at its half-height detent.
  final LiquidGlassSettings? halfSettings;

  /// The settings applied when the sheet is fully expanded.
  final LiquidGlassSettings? fullSettings;

  /// Liquid stretch multiplier for over-scroll/drag effects. Default: 0.5.
  final double stretch;

  /// Resistance factor when dragging beyond bounds. Default: 0.08.
  final double resistance;

  /// Snap progress threshold (0.0 - 1.0). Default: 0.4.
  final double snapThreshold;

  /// Velocity threshold for flick gestures (pixels/sec). Default: 700.0.
  final double velocityThreshold;

  /// Custom color for the touch interaction glow.
  final Color? glowColor;

  /// Radius of the touch interaction glow. Default: 1.5.
  final double glowRadius;

  /// Whether to prevent sheet scaling when interacting with children. Default: false.
  final bool suppressInteractionOnChildren;

  /// Internal padding for the sheet content.
  final EdgeInsetsGeometry? padding;

  /// Controller for programmatic sheet control.
  final GlassModalSheetController? controller;

  /// Callback triggered when the sheet snaps to a new state.
  final ValueChanged<GlassSheetState>? onStateChanged;

  /// Interaction mode (dismissible vs persistent). Default: [GlassSheetMode.dismissible].
  final GlassSheetMode mode;

  /// Whether to show the iOS-style drag handle at the top. Default: true.
  final bool showDragIndicator;

  /// Custom color for the drag handle.
  final Color? dragIndicatorColor;

  /// Width of the drag handle pill in logical pixels. Defaults to 36
  /// (iOS native). Bump higher (e.g. 64) for sheets where the handle
  /// reads as the primary affordance and the thinner default feels
  /// too subtle relative to the rest of the sheet's content.
  final double dragIndicatorWidth;

  /// Thickness of the drag handle pill in logical pixels. Defaults to 4.
  final double dragIndicatorHeight;

  /// Gap between the sheet's top edge and the drag handle pill. Defaults
  /// to 8.
  final double dragIndicatorTopPadding;

  /// Whether to enable a gradient fade effect at the top.
  final bool enableTopFade;

  /// Height of the top fade effect.
  final double topFadeHeight;

  /// Whether to maintain high glass vibrancy for content even when the sheet is solid (full state).
  final bool maintainContentGlass;

  /// Custom glass settings for content specifically for the 'full' state.
  final LiquidGlassSettings? fullStateContentSettings;

  /// The resting detents offered (small = peek floor, medium = half glass,
  /// large = full opaque).
  /// Must be non-empty. Forwarded to the sheet.
  final Set<GlassSheetDetent> detents;

  /// Whether the sheet can be swiped down to dismiss. When false the sheet
  /// rubber-bands at its lowest detent instead. Forwarded to the sheet.
  final bool dismissible;

  /// Horizontal padding specifically for the 'peek' state.
  final double? peekHorizontalMargin;

  /// Bottom padding specifically for the 'peek' state.
  final double? peekBottomMargin;

  /// Fixed width for the 'peek' state.
  final double? peekWidth;

  /// Corner radius for 'peek' state.
  final double? peekTopBorderRadius;

  /// Corner radius for 'peek' state.
  final double? peekBottomRadius;

  /// Where the sheet sits across a screen with room beside it.
  ///
  /// See [GlassModalSheet.placement].
  final GlassSheetPlacement placement;

  /// Creates a [GlassModalSheetScaffold].
  const GlassModalSheetScaffold({
    super.key,
    required this.body,
    required this.sheet,
    this.halfSize = 0.45,
    this.fullSize,
    this.initialState = GlassSheetState.half,
    this.topBorderRadius,
    this.bottomBorderRadius,
    this.fullTopBorderRadius,
    this.fullBottomBorderRadius,
    this.horizontalMargin = 8.0,
    this.bottomMargin = 8.0,
    this.fillThreshold = 0.85,
    this.settings,
    this.expandedColor,
    this.expandedDarkColor,
    this.controller,
    this.onStateChanged,
    this.mode = GlassSheetMode.dismissible,
    this.peekSize = 90.0,
    this.quality = GlassQuality.standard,
    this.platformViewBackdrop = false,
    this.interactionScale = 1.01,
    this.enableInteractionGlow = true,
    this.enableSaturationGlow = true,
    this.peekSettings,
    this.halfSettings,
    this.fullSettings,
    this.stretch = 0.5,
    this.resistance = 0.08,
    this.snapThreshold = 0.4,
    this.velocityThreshold = 700.0,
    this.fillTransition = GlassFillTransition.gradual,
    this.showDragIndicator = true,
    this.dragIndicatorColor,
    this.dragIndicatorWidth = 36,
    this.dragIndicatorHeight = 4,
    this.dragIndicatorTopPadding = 8,
    this.glowColor,
    this.glowRadius = 1.5,
    this.suppressInteractionOnChildren = false,
    this.padding,
    this.enableTopFade = false,
    this.topFadeHeight = 40.0,
    this.maintainContentGlass = true,
    this.fullStateContentSettings,
    this.detents = const {GlassSheetDetent.medium, GlassSheetDetent.large},
    this.dismissible = true,
    this.peekHorizontalMargin,
    this.peekBottomMargin,
    this.peekWidth,
    this.peekTopBorderRadius,
    this.peekBottomRadius,
    this.placement = GlassSheetPlacement.automatic,
  }) : assert(
            detents.length > 0,
            'GlassModalSheetScaffold needs at least one detent — add medium '
            'and/or large (small alone is a floor, not a resting height).');

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: mode == GlassSheetMode.dismissible
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // A pointer convenience over the whole page: as a semantic
                  // tap it would merge into whatever node encloses the body.
                  // Screen readers dismiss through the sheet's drag handle,
                  // which carries its own tap action while it is shown
                  // (showDragIndicator); without it the app's own close
                  // control is the way out.
                  excludeFromSemantics: true,
                  onTap: () {
                    controller?.snapToState(GlassSheetState.hidden);
                  },
                  child: RepaintBoundary(child: body),
                )
              : RepaintBoundary(child: body),
        ),
        GlassModalSheet(
          halfSize: halfSize,
          fullSize: fullSize,
          initialState: initialState,
          topBorderRadius: topBorderRadius,
          bottomBorderRadius: bottomBorderRadius,
          fullTopBorderRadius: fullTopBorderRadius,
          fullBottomBorderRadius: fullBottomBorderRadius,
          horizontalMargin: horizontalMargin,
          bottomMargin: bottomMargin,
          fillThreshold: fillThreshold,
          settings: settings,
          expandedColor: expandedColor,
          expandedDarkColor: expandedDarkColor,
          controller: controller,
          onStateChanged: onStateChanged,
          mode: mode,
          peekSize: peekSize,
          quality: quality,
          platformViewBackdrop: platformViewBackdrop,
          interactionScale: interactionScale,
          enableInteractionGlow: enableInteractionGlow,
          enableSaturationGlow: enableSaturationGlow,
          peekSettings: peekSettings,
          halfSettings: halfSettings,
          fullSettings: fullSettings,
          stretch: stretch,
          resistance: resistance,
          snapThreshold: snapThreshold,
          velocityThreshold: velocityThreshold,
          fillTransition: fillTransition,
          showDragIndicator: showDragIndicator,
          dragIndicatorColor: dragIndicatorColor,
          dragIndicatorWidth: dragIndicatorWidth,
          dragIndicatorHeight: dragIndicatorHeight,
          dragIndicatorTopPadding: dragIndicatorTopPadding,
          glowColor: glowColor,
          glowRadius: glowRadius,
          suppressInteractionOnChildren: suppressInteractionOnChildren,
          padding: padding,
          enableTopFade: enableTopFade,
          topFadeHeight: topFadeHeight,
          maintainContentGlass: maintainContentGlass,
          fullStateContentSettings: fullStateContentSettings,
          detents: detents,
          dismissible: dismissible,
          peekHorizontalMargin: peekHorizontalMargin,
          peekBottomMargin: peekBottomMargin,
          peekWidth: peekWidth,
          peekTopBorderRadius: peekTopBorderRadius,
          peekBottomRadius: peekBottomRadius,
          placement: placement,
          child: sheet,
        ),
      ],
    );
  }
}
