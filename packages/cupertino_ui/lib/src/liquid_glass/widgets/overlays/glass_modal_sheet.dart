import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_quality.dart';
import '../../utils/glass_morph_controller.dart';
import '../../utils/liquid_morph_physics.dart';
import '../shared/adaptive_glass.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import '../../types/interaction_notification.dart';
import '../../src/widgets/overlays/glass_sheet_defaults.dart';
import '../../src/widgets/surfaces/vertical_bar_title_row.dart';
import '../../constants/glass_defaults.dart';
import '../shared/glass_accessibility_scope.dart';
import '../surfaces/glass_vertical_bar.dart';

part 'shared/glass_modal_sheet_mechanics.dart';
part 'shared/glass_modal_sheet_internal.dart';
part 'shared/glass_modal_sheet_morph.dart';
part 'shared/glass_modal_sheet_state.dart';

/// A high-fidelity, liquid glass modal sheet inspired by iOS 18+ design patterns.
///
/// [GlassModalSheet] provides a fluid, multi-state modal experience (peek, half, full)
/// with advanced glass morphism effects, interactive scaling, and physics-based gestures.
class GlassModalSheet extends StatefulWidget {
  // ===========================================================================
  // Content Properties
  // ===========================================================================

  /// The primary content widget displayed inside the glass sheet.
  final Widget child;

  // ===========================================================================
  // Geometry Properties
  // ===========================================================================

  /// Height in the 'half' state (0.0 - 1.0 fraction or absolute pixels). Default: 0.45.
  final double halfSize;

  /// Maximum sheet height in 'full' state.
  ///
  /// - If 0.0 < value <= 1.0: Treated as fraction of screen height.
  /// - If value > 1.0: Treated as absolute pixels.
  /// - If null: Defaults to screen height minus 90px (iOS Page Sheet style).
  final double? fullSize;

  /// Minimum visible height in the 'peek' state.
  ///
  /// - If 0.0 < value <= 1.0: Treated as a fraction of screen height.
  /// - If value > 1.0: Treated as absolute pixels.
  ///
  /// Default: 90.0 (absolute pixels).
  final double peekSize;

  /// Internal padding for the sheet content.
  final EdgeInsetsGeometry? padding;

  /// Initial state when the sheet is first shown.
  final GlassSheetState initialState;

  // ===========================================================================
  // Appearance Properties
  // ===========================================================================

  /// If null, it will be automatically resolved based on the device's
  /// physical geometry (adaptive radius).
  final double? topBorderRadius;

  /// If null, it will be automatically resolved based on the device's
  /// physical geometry (adaptive radius).
  final double? bottomBorderRadius;

  /// Corner radius of the top edges when fully expanded (full).
  final double? fullTopBorderRadius;

  /// Corner radius of the bottom edges when fully expanded (full).
  final double? fullBottomBorderRadius;

  /// Corner radius specifically for the 'peek' state.
  final double? peekTopBorderRadius;

  /// Corner radius specifically for the 'peek' state.
  final double? peekBottomRadius;

  /// Horizontal padding between the sheet and the screen edges.
  ///
  /// The sheet runs edge to edge at its large detent, except in iPhone Duo's
  /// vertical bar strip layout, where natively it keeps its margins there too.
  final double horizontalMargin;

  /// Where the sheet sits across a screen with room beside it, mirroring
  /// SwiftUI's `presentationPlacement(_:)`.
  ///
  /// Only read in iPhone Duo's vertical bar strip layout; see
  /// [GlassSheetPlacement].
  final GlassSheetPlacement placement;

  /// Horizontal padding specifically for the 'peek' state.
  /// If null, [horizontalMargin] is used.
  final double? peekHorizontalMargin;

  /// Bottom padding from the screen edge.
  final double bottomMargin;

  /// Bottom padding specifically for the 'peek' state.
  /// If null, [bottomMargin] is used.
  final double? peekBottomMargin;

  /// Fixed width for the 'peek' state.
  /// If provided, the sheet will morph from this width to full width.
  final double? peekWidth;

  /// Color/Saturation transition mode when expanding to full state.
  final GlassFillTransition fillTransition;

  /// Threshold (0.0 - 1.0) at which the sheet starts turning into a solid color.
  final double fillThreshold;

  /// Glass morphism effect settings (blur, thickness, lighting).
  final LiquidGlassSettings? settings;

  /// Background color used when the sheet is fully expanded and opaque.
  final Color? expandedColor;

  /// [expandedColor] while [GlassTheme.brightnessOf] is dark.
  ///
  /// Picked on every build, so an open sheet follows a light/dark switch.
  /// Falls back to [expandedColor].
  final Color? expandedDarkColor;

  /// Rendering quality (BackdropFilter vs Shader). Defaults to standard.
  final GlassQuality? quality;

  /// When true (typically over an iOS PlatformView), forces the BackdropFilter
  /// fallback render path so premium glass renders cleanly over the
  /// PlatformView instead of as a solid slab. Forwarded to the sheet's
  /// underlying [AdaptiveGlass]. Defaults to false.
  final bool platformViewBackdrop;

  // ===========================================================================
  // Physics & Interaction Properties
  // ===========================================================================

  /// Scale factor applied during interaction for tactile feedback. Default: 1.01.
  final double interactionScale;

  /// Whether to show glow/glare on touch for tactile feedback. Default: true.
  final bool enableInteractionGlow;

  /// Whether to pulse saturation/lighting of the whole sheet on touch. Default: true.
  final bool enableSaturationGlow;

  /// Optional state-specific settings that override the base [settings].
  final LiquidGlassSettings? peekSettings;

  /// The settings applied when the sheet is half open.
  final LiquidGlassSettings? halfSettings;

  /// The settings applied when the sheet is fully open.
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

  /// Controller for programmatic sheet control (snap, animate).
  final GlassModalSheetController? controller;

  /// Callback triggered when the sheet snaps to a new state.
  final ValueChanged<GlassSheetState>? onStateChanged;

  /// Interaction mode (dismissible vs persistent).
  final GlassSheetMode mode;

  /// The resting detents this sheet offers. Appearance follows the detent:
  /// [GlassSheetDetent.small] is the peek floor, [GlassSheetDetent.medium] is
  /// content-height glass, [GlassSheetDetent.large] is screen-height opaque.
  ///
  ///   • `{medium}`             → half-only glass (Apple Pay / Sign in with Apple)
  ///   • `{large}`              → full-only opaque, opens straight to full (Maps / Music)
  ///   • `{medium, large}`      → the default two-stop sheet
  ///   • `{small, medium, large}` → adds the maps-style peek floor underneath
  ///
  /// Must be non-empty. [GlassSheetMode.persistent] keeps its peek floor even
  /// when [GlassSheetDetent.small] is absent — a persistent sheet is defined by
  /// resting somewhere instead of dismissing. Style the small detent with the
  /// `peek*` params ([peekSettings], [peekWidth], …).
  final Set<GlassSheetDetent> detents;

  /// Whether a downward drag can dismiss the sheet. When false, a peek-less
  /// sheet rubber-bands at its lowest detent instead of closing on swipe-down
  /// (guarding against an accidental dismiss — the Apple Pay pattern); close
  /// it programmatically via the controller. Default: true.
  final bool dismissible;

  // ===========================================================================
  // Drag Indicator Properties
  // ===========================================================================

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
  /// Apple's sheets draw theirs 5pt thick.
  final double dragIndicatorHeight;

  /// Gap between the sheet's top edge and the drag handle pill, in logical
  /// pixels. Defaults to 8. Apple's sheets sit theirs about 5pt down, which
  /// also leaves more room between the pill and a header row beneath it.
  final double dragIndicatorTopPadding;

  /// Whether to enable a gradient fade effect at the top of the sheet.
  final bool enableTopFade;

  /// The height of the top fade effect in pixels. Default: 40.0.
  final double topFadeHeight;

  /// Whether to maintain high glass vibrancy for content even when the sheet is solid (full state).
  final bool maintainContentGlass;

  /// Custom glass settings for content specifically for the 'full' state.
  final LiquidGlassSettings? fullStateContentSettings;

  /// Creates a new [GlassModalSheet].
  const GlassModalSheet({
    super.key,
    required this.child,
    this.halfSize = 0.45,
    this.fullSize,
    this.initialState = GlassSheetState.half,
    this.topBorderRadius = 56,
    this.bottomBorderRadius,
    this.fullTopBorderRadius = 46,
    this.fullBottomBorderRadius,
    this.horizontalMargin = 5.0,
    this.bottomMargin = 6.0,
    this.fillThreshold = 0.60,
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
    this.settings,
    this.quality,
    this.platformViewBackdrop = false,
    this.expandedColor,
    this.expandedDarkColor,
    this.controller,
    this.onStateChanged,
    this.mode = GlassSheetMode.dismissible,
    this.peekSize = 90.0,
    this.fillTransition = GlassFillTransition.instant,
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
            'GlassModalSheet needs at least one detent — add medium and/or large '
            '(small alone is a floor, not a resting height).');

  /// Shows a high-fidelity glass modal sheet.
  ///
  /// ## Morphing from a trigger
  ///
  /// Wrap the trigger in a [GlassMorphTrigger] and hand its [GlassMorphAnchor]
  /// to [morphFrom] to present the sheet with the iOS 26 liquid morph instead
  /// of the default slide-up: the trigger empties, a glass droplet detaches and
  /// inflates as it travels, and lands as the sheet. Dismissing reverses it
  /// back into the trigger. This is the same [GlassMorphController] engine
  /// `GlassMenu` uses — see `docs/LIQUID_MORPH_ENGINE.md`.
  ///
  /// ```dart
  /// GlassMorphTrigger(
  ///   builder: (context, anchor) => GlassButton(
  ///     onTap: () => GlassModalSheet.show(
  ///       context: context,
  ///       morphFrom: anchor,
  ///       builder: (context) => const MySheetBody(),
  ///     ),
  ///     child: const Icon(CupertinoIcons.add),
  ///   ),
  /// )
  /// ```
  ///
  /// The wrapper is what makes the trigger *empty*: nothing in Flutter lets one
  /// widget hide another it doesn't own, and a trigger still painting under the
  /// droplet reads as a duplicated button rather than a morph.
  ///
  /// [morphFromRect] is the escape hatch for a trigger that can't be wrapped —
  /// an explicit global [Rect]. The morph still runs, but since the trigger
  /// stays painted the anchor blob is suppressed and the droplet blooms from
  /// the rect's centre instead of stretching a teardrop out of it. Pass at most
  /// one of [morphFrom] / [morphFromRect].
  ///
  /// Leave both null and the sheet presents exactly as it always has — the
  /// slide transition is untouched. [morphSpeed] tunes the spring profile; the
  /// default [MorphSpeed.normal] is the 375 ms native-parity profile.
  ///
  /// The morph needs the metaball blend that draws the teardrop neck, so it
  /// falls back to the slide transition when that is unavailable: on Skia/web
  /// (`ImageFilter.isShaderFilterSupported == false`), in
  /// [GlassQuality.minimal], and under [platformViewBackdrop]. Reduce Motion is
  /// honoured by the engine, which swaps in its instant spring so the sheet
  /// resolves straight away instead of travelling.
  ///
  /// Every dismissal morphs back into the trigger. One that leaves the sheet
  /// at rest — barrier tap, back gesture, [GlassModalSheetController] close —
  /// morphs from its resting frame. A swipe morphs from wherever the finger
  /// let go: below the lowest detent the sheet detaches from the bottom edge,
  /// follows the finger on both axes and shrinks uniformly with the *vertical*
  /// travel, and the release hands that exact frame to the morph. A swipe
  /// released short of the dismiss threshold springs back to the detent, at
  /// full size and centred.
  ///
  /// This interactive shrink belongs to the morph, not to the sheet — the same
  /// split iOS draws between its zoom transition and its detents. Present
  /// without [morphFrom] and the sheet keeps its plain slide-away dismissal.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double halfSize = 0.45,
    double? fullSize,
    GlassSheetState initialState = GlassSheetState.half,
    double fillThreshold = 0.60,
    LiquidGlassSettings? settings,
    Color? expandedColor,
    Color? expandedDarkColor,
    ValueChanged<GlassSheetState>? onStateChanged,
    GlassSheetMode mode = GlassSheetMode.dismissible,
    double peekSize = 90.0,
    GlassQuality? quality,
    bool platformViewBackdrop = false,
    Color barrierColor = GlassDefaults.barrierColor,
    bool isDismissible = true,
    bool useRootNavigator = false,
    double interactionScale = 1.01,
    bool enableInteractionGlow = true,
    bool enableSaturationGlow = true,
    LiquidGlassSettings? peekSettings,
    LiquidGlassSettings? halfSettings,
    LiquidGlassSettings? fullSettings,
    double stretch = 0.5,
    GlassModalSheetController? controller,
    GlassFillTransition fillTransition = GlassFillTransition.instant,
    bool showDragIndicator = true,
    Color? dragIndicatorColor,
    double dragIndicatorWidth = 36,
    double dragIndicatorHeight = 4,
    double dragIndicatorTopPadding = 8,
    double? topBorderRadius = 56,
    double? bottomBorderRadius,
    double? fullTopBorderRadius = 46,
    double? fullBottomBorderRadius,
    double horizontalMargin = 8.0,
    double bottomMargin = 8.0,
    double resistance = 0.08,
    double snapThreshold = 0.4,
    double velocityThreshold = 700.0,
    Color? glowColor,
    double glowRadius = 1.5,
    bool suppressInteractionOnChildren = false,
    EdgeInsetsGeometry? padding,
    bool enableTopFade = false,
    double topFadeHeight = 40.0,
    bool maintainContentGlass = true,
    LiquidGlassSettings? fullStateContentSettings,
    Set<GlassSheetDetent> detents = const {
      GlassSheetDetent.medium,
      GlassSheetDetent.large
    },
    bool dismissible = true,
    double? peekHorizontalMargin,
    double? peekBottomMargin,
    double? peekWidth,
    double? peekTopBorderRadius,
    double? peekBottomRadius,
    GlassSheetPlacement placement = GlassSheetPlacement.automatic,
    GlassMorphAnchor? morphFrom,
    Rect? morphFromRect,
    MorphSpeed morphSpeed = MorphSpeed.normal,
  }) {
    assert(
        morphFrom == null || morphFromRect == null,
        'Pass either morphFrom (the GlassMorphAnchor from a GlassMorphTrigger) '
        'or morphFromRect (an explicit global rect) — not both.');
    assert(
        detents.isNotEmpty,
        'GlassModalSheet.show() needs at least one detent — add medium '
        'and/or large (small alone is a floor, not a resting height).');
    assert(() {
      if (mode == GlassSheetMode.persistent &&
          barrierColor == const Color(0x00000000)) {
        debugPrint(
          '[GlassModalSheet] WARNING: show() with persistent mode and '
          'transparent barrier does NOT provide true hit-through interaction. '
          'Use GlassModalSheetScaffold directly for maps-style hit-through UI.',
        );
      }
      return true;
    }());

    // Fall back to an offered detent if the caller asked to open on one
    // that isn't in the set (the assert guarantees the set is non-empty).
    GlassSheetState resolvedInitialState = initialState;
    if (initialState == GlassSheetState.half &&
        !detents.contains(GlassSheetDetent.medium)) {
      resolvedInitialState = GlassSheetState.full;
    } else if (initialState == GlassSheetState.full &&
        !detents.contains(GlassSheetDetent.large)) {
      resolvedInitialState = GlassSheetState.half;
    }

    final effectiveController = controller ?? GlassModalSheetController();
    bool isClosing = false;

    // Resolved once, before the route is pushed: the trigger's rect has to be
    // read while the trigger is still laid out, and the render capabilities
    // decide which transition the route is built with in the first place.
    final morphTriggerRect = _resolveMorphTriggerRect(morphFrom, morphFromRect);
    final morphing = morphTriggerRect != null &&
        _supportsMorph(
          context,
          quality: quality,
          platformViewBackdrop: platformViewBackdrop,
        );

    // The morph owns its own spring clock; the route duration only has to be
    // long enough to keep the page mounted (and the barrier fading) for as long
    // as the morph runs — most visibly on the way out, where the route reverse
    // is the window the closing morph plays in.
    final transitionDuration = morphing
        ? _morphRouteDuration(morphSpeed)
        : const Duration(milliseconds: 500);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: morphing
          // When morphing, the presenter drives the scrim itself via the liquid
          // spring so it stays in lockstep with the blob. A route-level barrier
          // would fade linearly on an independent clock, creating the "two
          // separate things" visual that GlassMenu avoids by having no route
          // barrier at all. Pass transparent here so showGeneralDialog's built-in
          // linear fade does not run alongside the spring-driven scrim.
          ? const Color(0x00000000)
          : barrierColor,
      useRootNavigator: useRootNavigator,
      transitionDuration: transitionDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Morphing: the droplet IS the transition. Mapping the engine onto this
        // linear route animation would flatten the J-curve and the underdamped
        // catch, so the page passes straight through.
        if (morphing) return child;
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        final scaffold = GlassModalSheetScaffold(
          controller: effectiveController,
          halfSize: halfSize,
          fullSize: fullSize,
          initialState: resolvedInitialState,
          fillThreshold: fillThreshold,
          settings: settings,
          expandedColor: expandedColor,
          expandedDarkColor: expandedDarkColor,
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
          fillTransition: fillTransition,
          showDragIndicator: showDragIndicator,
          dragIndicatorColor: dragIndicatorColor,
          dragIndicatorWidth: dragIndicatorWidth,
          dragIndicatorHeight: dragIndicatorHeight,
          dragIndicatorTopPadding: dragIndicatorTopPadding,
          topBorderRadius: topBorderRadius,
          bottomBorderRadius: bottomBorderRadius,
          fullTopBorderRadius: fullTopBorderRadius,
          fullBottomBorderRadius: fullBottomBorderRadius,
          horizontalMargin: horizontalMargin,
          bottomMargin: bottomMargin,
          resistance: resistance,
          snapThreshold: snapThreshold,
          velocityThreshold: velocityThreshold,
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
          onStateChanged: (state) {
            onStateChanged?.call(state);
            if (state == GlassSheetState.hidden && !isClosing) {
              isClosing = true;
              Navigator.of(context).pop();
            }
          },
          body: const SizedBox.shrink(),
          sheet: builder(context),
        );

        if (!morphing) return scaffold;

        return GlassSheetMorphPresenter(
          routeAnimation: animation,
          triggerRect: morphTriggerRect,
          anchor: morphFrom,
          speed: morphSpeed,
          restingState: resolvedInitialState,
          controller: effectiveController,
          // Built from the same inputs as the sheet's own _buildGeometry, so
          // the droplet aims at the detent the sheet will actually rest at.
          geometry: SheetGeometry(
            mode: mode,
            halfSize: halfSize,
            fullSize: fullSize ?? _stripFullSize(context),
            peekSize: peekSize,
            enablePeek: SheetGeometry.resolvePeek(
              detents: detents,
              mode: mode,
            ),
            enableHalf: detents.contains(GlassSheetDetent.medium),
            enableFull: detents.contains(GlassSheetDetent.large),
            dismissible: dismissible,
          ),
          horizontalMargin: horizontalMargin,
          bottomMargin: bottomMargin,
          topBorderRadius: topBorderRadius,
          fullTopBorderRadius: fullTopBorderRadius,
          bottomBorderRadius: bottomBorderRadius,
          fullBottomBorderRadius: fullBottomBorderRadius,
          settings: settings,
          peekSettings: peekSettings,
          halfSettings: halfSettings,
          fullSettings: fullSettings,
          expandedColor: expandedColor,
          expandedDarkColor: expandedDarkColor,
          quality: quality,
          peekHorizontalMargin: peekHorizontalMargin,
          peekBottomMargin: peekBottomMargin,
          peekWidth: peekWidth,
          peekTopBorderRadius: peekTopBorderRadius,
          platformViewBackdrop: platformViewBackdrop,
          // The route-level barrier is transparent above; the presenter drives
          // the scrim itself via the liquid spring for single-unified-motion.
          barrierColor: barrierColor,
          placement: placement,
          child: scaffold,
        );
      },
    );
  }

  /// Resolves the trigger's global rect from whichever of [morphFrom] /
  /// [morphFromRect] the caller supplied, or null when neither was given.
  ///
  /// An anchor whose trigger isn't laid out is a caller mistake, so it asserts
  /// in debug; in release it degrades to the slide transition rather than
  /// morphing out of a rect that doesn't exist.
  static Rect? _resolveMorphTriggerRect(
    GlassMorphAnchor? morphFrom,
    Rect? morphFromRect,
  ) {
    if (morphFromRect != null) return morphFromRect;
    if (morphFrom == null) return null;

    final rect = morphFrom._rect;
    assert(
        rect != null,
        'GlassModalSheet.show(morphFrom:) needs a GlassMorphAnchor whose '
        'GlassMorphTrigger is mounted and laid out. It was not on screen when '
        'show() was called — pass morphFromRect if the trigger has no render '
        'box of its own.');
    return rect;
  }

  /// Whether the current render path can draw the morph.
  ///
  /// The teardrop neck is an Impeller-only SDF metaball blend, and a degraded
  /// morph — two glass shapes with no bridge between them — reads worse than
  /// the slide it replaces. So anything that suppresses blending falls back
  /// wholesale: Skia/web, [GlassQuality.minimal], and the BackdropFilter path
  /// forced by [platformViewBackdrop] (both of which skip the
  /// [LiquidGlassBlendGroup] entirely — see #214).
  static bool _supportsMorph(
    BuildContext context, {
    required GlassQuality? quality,
    required bool platformViewBackdrop,
  }) {
    if (platformViewBackdrop) return false;
    final resolved = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
      fallback: GlassQuality.premium,
    );
    if (resolved == GlassQuality.minimal) return false;
    return debugMorphSupportsBlending ?? ImageFilter.isShaderFilterSupported;
  }

  /// Test-only override for the Impeller probe in [_supportsMorph].
  ///
  /// A headless test run reports `ImageFilter.isShaderFilterSupported == false`
  /// — correctly, since there is no Impeller — which makes the morph path
  /// unreachable from a widget test and would leave the route wiring untested.
  /// Set this to `true` to exercise it, and back to `null` in a `tearDown`.
  ///
  /// It stands in for the render-capability probe only; [platformViewBackdrop]
  /// and [GlassQuality.minimal] still disable the morph, so those fallbacks
  /// stay honest under the override.
  @visibleForTesting
  static bool? debugMorphSupportsBlending;

  /// The large detent's height in iPhone Duo's vertical bar strip layout, or
  /// null elsewhere, where [fullSize]'s default applies.
  ///
  /// The status bar is in the strip there, so natively a sheet rises to 8pt
  /// from the top of the screen instead of stopping short of the status bar.
  static double? _stripFullSize(BuildContext context) =>
      GlassVerticalBar.maybeOf(context) == null
          ? null
          : MediaQuery.sizeOf(context).height - _kStripSheetTop;

  /// Route transition duration that covers a morph at [speed].
  ///
  /// Sized to the droplet's journey — the moment it is caught by the trigger —
  /// and no longer. The route's modal barrier swallows every touch while it is
  /// mounted, so holding it open for the spring's full settle would leave the
  /// trigger visibly back but dead to the touch for a few hundred milliseconds.
  /// `GlassMenu` drops its own barrier 30 % into the close for the same reason.
  ///
  /// The tail of the bounce is not lost: [GlassMorphTrigger] continues the
  /// spring on its own ticker once the droplet is handed back, so it keeps
  /// easing home after this route is gone.
  ///
  /// Measured against the profiles in [GlassMorphController], with headroom:
  ///
  /// | speed   | droplet caught | route |
  /// |---------|----------------|-------|
  /// | slow    | 408 ms         | 480   |
  /// | normal  | 304 ms         | 380   |
  /// | fast    | 240 ms         | 300   |
  /// | instant | 160 ms         | 210   |
  static Duration _morphRouteDuration(MorphSpeed speed) {
    switch (speed) {
      case MorphSpeed.slow:
        return const Duration(milliseconds: 480);
      case MorphSpeed.normal:
        return const Duration(milliseconds: 380);
      case MorphSpeed.fast:
        return const Duration(milliseconds: 300);
      case MorphSpeed.instant:
        return const Duration(milliseconds: 210);
    }
  }

  @override
  State<GlassModalSheet> createState() => _GlassModalSheetState();
}
