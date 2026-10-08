import 'dart:async' show scheduleMicrotask;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../src/utils/glass_localizations.dart';
import '../../utils/glass_morph_controller.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/widgets/surfaces/vertical_bar_presentation.dart';

import '../../constants/glass_defaults.dart';
import '../../types/glass_quality.dart';
import '../containers/glass_container.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import '../shared/inherited_liquid_glass.dart';
import 'glass_menu_item.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../theme/glass_theme.dart';
import '../shared/glass_accessibility_scope.dart';

part 'shared/glass_menu_internal.dart';

/// Controls which edge/corner of the trigger button the menu expands from.
///
/// When [GlassMenu.menuAlignment] is set to one of these values, the menu
/// anchors its opposite edge to that point on the trigger. For example,
/// [topLeft] anchors the menu's top-left corner to the trigger, so
/// the body expands downwards and to the right.
///
/// Use [none] (the default) to let the menu auto-detect the best alignment
/// based on the trigger's screen position.
enum GlassMenuAlignment {
  /// Auto-detect alignment based on screen position (default behaviour).
  none,

  /// Top left alignment.
  topLeft,

  /// Top center alignment.
  topCenter,

  /// Top right alignment.
  topRight,

  /// Center left alignment.
  centerLeft,

  /// Center alignment.
  center,

  /// Center right alignment.
  centerRight,

  /// Bottom left alignment.
  bottomLeft,

  /// Bottom center alignment.
  bottomCenter,

  /// Bottom right alignment.
  bottomRight,
}

/// A liquid glass context menu that morphs from its trigger button.
///
/// [GlassMenu] implements the iOS 26 "liquid glass" morphing pattern where
/// a button seamlessly transforms into a menu. The same glass container
/// transitions between button and menu states using spring physics.
///
/// ## Features
/// - **True morphing**: Button transforms into menu (not overlay)
/// - **Smooth spring physics**: Gentle settle with no harsh bounces (stiffness: 300, damping: 24)
/// - **Liquid swoop**: Subtle 5px parabolic arc for seamless down-and-up motion
/// - **Seamless crossfade**: Button only appears at final 5% to preserve morph illusion
/// - **Dimension interpolation**: Width, height, and border radius morph smoothly
/// - **Position aware**: Menu expands from button position
/// - **Settings inheritance**: Inherits parent layer settings like GlassCard (thin rim by default)
/// - **No button animation**: Trigger button remains static, only shape morphs
class GlassMenu extends StatefulWidget {
  /// The widget that triggers the menu.
  ///
  /// If provided, this widget will be wrapped in a [GestureDetector] to handle
  /// taps. Use this for simple, non-interactive triggers like Icons or Text.
  ///
  /// If your trigger is interactive (like a [GlassButton]), use [triggerBuilder]
  /// instead to manually handle the tap event.
  final Widget? trigger;

  /// What the [trigger] opens, announced by screen readers (for example
  /// "More actions").
  ///
  /// The [trigger] is exposed as a button. A text trigger names itself, so
  /// this matters most for an icon. Not used with [triggerBuilder], whose
  /// widget carries its own semantics.
  final String? semanticLabel;

  /// A builder for the trigger widget that provides access to the menu toggle callback.
  ///
  /// Use this when your trigger widget handles its own interactions (e.g., a [GlassButton]
  /// or [IconButton]).
  ///
  /// Example:
  /// ```dart
  /// GlassMenu(
  ///   triggerBuilder: (context, toggle) => GlassButton(
  ///     onTap: toggle,
  ///     child: Text('Open'),
  ///   ),
  ///   ...
  /// )
  /// ```
  final Widget Function(BuildContext context, VoidCallback toggleMenu)?
      triggerBuilder;

  /// The list of items to display in the menu.
  ///
  /// Typically contains [GlassMenuItem] and [GlassMenuDivider].
  final List<Widget> items;

  /// The alignment of the menu relative to the trigger.
  final GlassMenuAlignment? menuAlignment;

  /// Whether to automatically adjust the menu position to keep it on screen.
  final bool autoAdjustToScreen;

  /// Width of the expanded menu.
  final double menuWidth;

  /// Border radius of the expanded menu.
  ///
  /// Defaults to 32.0 for a modern rounded look.
  final double menuBorderRadius;

  /// Border radius of the selection highlight and menu items.
  ///
  /// Defaults to 24.0.
  final double itemBorderRadius;

  /// Custom glass settings for the menu container.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  /// Liquid stretch factor. Default: 0.5.
  final double stretch;

  /// Scale factor applied on touch. Default: 1.02.
  final double interactionScale;

  /// The resistance factor to apply to the drag offset.
  /// Higher values make the drag feel "stickier". Default: 0.08.
  final double stretchResistance;

  /// The axis to constrain the stretch to. If null, stretches in both axes.
  final Axis? stretchAxis;

  /// Whether to allow stretch in the positive X direction (Right).
  /// If null, automatically determined by menu position.
  final bool? allowPositiveX;

  /// Whether to allow stretch in the negative X direction (Left).
  /// If null, automatically determined by menu position.
  final bool? allowNegativeX;

  /// Whether to allow stretch in the positive Y direction (Down).
  /// If null, automatically determined by menu position.
  final bool? allowPositiveY;

  /// Whether to allow stretch in the negative Y direction (Up).
  /// If null, automatically determined by menu position.
  final bool? allowNegativeY;

  /// Whether to show glow/glare on touch for tactile feedback. Default: true.
  final bool enableInteractionGlow;

  /// Whether the glow should act as a momentary tap indicator.
  ///
  /// If true, the glow will appear on tap but will automatically fade out
  /// if the user starts dragging. It will not reappear until a new tap starts.
  ///
  /// Defaults to `false` for [GlassMenu]: the menu has a dismiss barrier and
  /// no scroll rows, so the specular light should continue to track the
  /// finger as it moves between items. Set to `true` only on menus that
  /// contain scrollable content where a drag gesture must not leave a
  /// persistent glare behind.
  final bool glowOnTapOnly;

  /// Custom color for the touch interaction glow.
  final Color? glowColor;

  /// Radius of the touch interaction glow. Default: 0.6.
  final double glowRadius;

  /// The intensity of the interactive glow.
  ///
  /// Defaults to 0.0.
  final double glowIntensity;

  /// Custom color for the menu selection background.
  final Color selectionColor;

  /// Optional fixed height for the menu.
  ///
  /// If null, the menu will size itself to fit its items.
  /// If provided, the menu will have a fixed height and internal scrolling.
  final double? menuHeight;

  /// The minimum distance between the menu and the screen edges.
  ///
  /// Only applies when [autoAdjustToScreen] is true.
  /// Defaults to 0.0 (touches the edge). Set to a value like 12.0 for a safe margin.
  final EdgeInsets menuPadding;

  /// Called when the menu begins closing.
  ///
  /// Fires immediately when a close is triggered — tap outside the barrier,
  /// re-tapping the trigger button, or selecting a menu item — **before** the
  /// close animation completes. Use this to synchronise external state (e.g.
  /// stopping a morph controller) that should react as soon as the close
  /// gesture is confirmed.
  ///
  /// If you need to act only after the animation has fully settled, listen to
  /// [GlassMorphController] status changes directly.
  final VoidCallback? onClose;

  /// Optional controller to drive the menu imperatively
  /// ([GlassMenuController.open] / [GlassMenuController.close]) instead of — or
  /// in addition to — tapping the trigger.
  ///
  /// Tapping the trigger goes through [_GlassMenuState._toggleMenu], which is
  /// gated on the morph progress (a close that lands while the menu is still
  /// expanding is ignored). The controller commands [_GlassMenuState._openMenu]
  /// / [_GlassMenuState._closeMenu] directly, so it is deterministic for any
  /// timing — useful when an external gesture owner (e.g. a central gesture
  /// arena) decides when to show and dismiss the menu.
  final GlassMenuController? controller;

  /// Whether to render the full-screen tap-to-dismiss barrier behind the open
  /// menu. Defaults to `true` (modal: a tap outside the menu closes it).
  ///
  /// Set to `false` when an external gesture owner (e.g. a canvas gesture arena)
  /// must keep receiving pointer events while the menu is open and will handle
  /// dismissal itself — the barrier otherwise sits in the root overlay above
  /// everything and swallows all input. Pairs with [controller]-driven open/close.
  final bool showDismissBarrier;

  /// Whether the open/close morph blooms from a zero-size point at the trigger
  /// center instead of from a glass blob the size of the trigger. Defaults to
  /// `false` (the menu spawns as a small rounded "metaball" matching the trigger
  /// and morphs outward — the standard iOS-26 liquid-glass behavior).
  ///
  /// Set to `true` when the trigger is invisible or zero-sized (e.g. an
  /// imperatively-driven menu positioned by an external gesture owner via
  /// [controller]), so there is no button for the spawn blob to grow from. In
  /// that case the trigger ghost (Blob A) is suppressed entirely and the menu
  /// body lerps its size from 0 → full while keeping the identical teardrop
  /// shape morph (radius circle→rounded-rect, J-curve travel, and spring). The
  /// shape still spawns at — and collapses back to — the trigger center, so a
  /// zero-sized trigger reads as a point bloom rather than an 8px glass dot.
  final bool morphFromZero;

  /// When true (typically for iOS PlatformViews), forces the BackdropFilter
  /// fallback render path instead of the Impeller-native shader. Forwarded to
  /// the underlying [AdaptiveLiquidGlassLayer].
  final bool platformViewBackdrop;

  /// Speed profile for the open/close morph animation.
  ///
  /// Defaults to [MorphSpeed.normal] for native iOS 26 parity. Use
  /// [MorphSpeed.fast] on high-frequency trigger surfaces (e.g. toolbars where
  /// users tap repeatedly) or [MorphSpeed.instant] when Reduce Motion is
  /// active and you want a single-frame transition without bouncing.
  final MorphSpeed morphSpeed;

  /// Whether to enable iOS-style continuous swipe-to-select.
  ///
  /// When true, pressing down on the trigger opens the menu immediately and
  /// allows the user to slide across items and release to activate in a single
  /// unbroken gesture without lifting their finger.
  ///
  /// If the finger is released within [continuousSwipeSlop] of the touch-down
  /// origin, the gesture is treated as a tap and the menu remains open for
  /// subsequent interaction (tap mode).
  ///
  /// Defaults to `false` for raw [GlassMenu] (opt-in for backward compatibility
  /// with custom triggers); enabled by default on [GlassPullDownButton].
  final bool enableContinuousSwipe;

  /// The movement threshold in logical pixels required to arm continuous swipe.
  ///
  /// While the pointer displacement is below this distance, the interaction is
  /// considered within the press deadband, preventing accidental item selection
  /// on quick taps or presses.
  ///
  /// Defaults to 10.0.
  final double continuousSwipeSlop;

  /// Creates a liquid glass menu.
  const GlassMenu({
    super.key,
    this.trigger,
    this.triggerBuilder,
    required this.items,
    this.menuAlignment,
    this.autoAdjustToScreen = false,
    this.menuWidth = 200,
    this.menuBorderRadius = 32.0,
    this.itemBorderRadius = 24.0,
    this.settings,
    this.quality,
    this.stretch = 0.5,
    this.interactionScale = 1.02,
    this.stretchResistance = 0.08,
    this.stretchAxis,
    this.allowPositiveX,
    this.allowNegativeX,
    this.allowPositiveY,
    this.allowNegativeY,
    this.menuHeight,
    this.menuPadding = EdgeInsets.zero,
    this.selectionColor = const Color(0x3DFFFFFF),
    this.enableInteractionGlow = true,
    this.glowOnTapOnly = false,
    this.glowColor,
    this.glowRadius = 0.6,
    this.glowIntensity = 0.0,
    this.onClose,
    this.controller,
    this.showDismissBarrier = true,
    this.morphFromZero = false,
    this.platformViewBackdrop = false,
    this.morphSpeed = MorphSpeed.normal,
    this.enableContinuousSwipe = false,
    this.continuousSwipeSlop = 10.0,
    this.semanticLabel,
  }) : assert(trigger != null || triggerBuilder != null,
            'Either trigger or triggerBuilder must be provided');

  @override
  State<GlassMenu> createState() => _GlassMenuState();
}

/// Drives a [GlassMenu] imperatively, bypassing the trigger tap.
///
/// Pass it to [GlassMenu.controller]. Unlike tapping the trigger (which toggles
/// and is gated on the morph progress), [open] and [close] command the menu's
/// morph directly, so a [close] that lands mid-open reliably dismisses the menu
/// instead of re-opening it. Intended for cases where something other than the
/// menu's own trigger decides when it appears — e.g. a central gesture arena.
///
/// One controller drives one mounted [GlassMenu] at a time.
class GlassMenuController {
  _GlassMenuState? _state;

  void _attach(_GlassMenuState state) => _state = state;

  void _detach(_GlassMenuState state) {
    if (identical(_state, state)) _state = null;
  }

  /// Whether the menu's overlay is currently shown (open, or animating closed).
  bool get isOpen => _state?._overlayController.isShowing ?? false;

  /// Opens the menu, morphing from the trigger's current position. Safe to call
  /// while a close is still animating — the spring reverses toward open.
  void open() => _state?._openMenu();

  /// Closes the menu with the rubber-band morph. Deterministic for any timing:
  /// unlike a trigger tap, it never re-opens a still-expanding menu.
  void close() => _state?._closeMenu();

  /// Nudges the open menu to track a moving anchor: [offset] (screen px) is added
  /// to the menu's captured trigger position every frame until reset. A no-op
  /// while closed; cleared on the next [open]. Used by external gesture owners
  /// that move the anchor AFTER opening — e.g. a canvas tile trailing under a
  /// rubberband, where the menu should stay glued to the tile.
  void setFollowOffset(Offset offset) => _state?.setFollowOffset(offset);

  /// Drives slide-to-select with a pointer the menu never receives itself.
  ///
  /// Use this when your own gesture code owns the finger, for example a
  /// long-press recogniser that opened the menu with [open]. Call it with the
  /// pointer's global position on every move: the item under that point
  /// highlights, with a selection haptic each time the highlight moves to a
  /// new item. As with touch slide-to-select, nothing highlights on a
  /// scrollable menu.
  ///
  /// Returns whether [globalPosition] lies over the open menu. A no-op that
  /// returns `false` while the menu is closed or closing.
  bool glideTo(Offset globalPosition) =>
      _state?._glideTo(globalPosition) ?? false;

  /// Ends a glide started with [glideTo], typically when the finger lifts.
  ///
  /// Activates the highlighted item exactly as a tap would and returns
  /// `true`. With nothing highlighted, it clears the glide, leaves the menu
  /// open, and returns `false`.
  bool endGlide() => _state?._endGlide() ?? false;

  /// Clears a glide's highlight without activating anything, for example
  /// when the gesture that owns the finger is cancelled.
  void cancelGlide() => _state?._cancelGlide();
}
