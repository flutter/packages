import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import '../../src/utils/glass_localizations.dart';
import '../../utils/glass_morph_controller.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/widgets/surfaces/vertical_bar_presentation.dart';

import '../../constants/glass_defaults.dart';
import '../../types/glass_quality.dart';
import '../containers/glass_container.dart';
import '../shared/inherited_liquid_glass.dart';
import 'glass_menu.dart' show GlassMenuAlignment;
import '../../theme/glass_theme_helpers.dart';
import '../../theme/glass_theme.dart';
import '../shared/glass_accessibility_scope.dart';

part 'shared/glass_popover_internal.dart';

/// A liquid glass popover that morphs from its trigger button.
///
/// [GlassPopover] implements the same iOS 26 liquid morph animation as
/// [GlassMenu], but instead of presenting a list of menu items, it presents
/// **any custom widget**. Use it for tooltips, mini forms, preview cards,
/// colour pickers, or any content that should appear in a glass overlay.
///
/// The popover morphs from the trigger button using spring physics and the
/// dual-blob metaball technique, creating a teardrop expansion effect.
///
/// ## Features
/// - **Liquid morph animation**: Same teardrop physics as [GlassMenu]
/// - **Custom content**: Any widget, not just menu items
/// - **Self-closing**: Content receives a `close` callback
/// - **Auto-positioning**: Detects best alignment from trigger position
/// - **Screen-edge clamping**: Keeps popover within safe area
/// - **Barrier dismissal**: Tap outside to close (configurable)
/// - **Blur ramp**: The backdrop blur eases in with the morph instead of
///   paying its full raster cost from the first frame — see [blurRampDuration]
///
/// ## Usage
///
/// ### Basic Usage
/// ```dart
/// GlassPopover(
///   trigger: Icon(CupertinoIcons.info_circle, color: Colors.white),
///   contentBuilder: (context, close) => Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Hello from the popover!',
///       style: TextStyle(color: Colors.white)),
///   ),
/// )
/// ```
///
/// ### With Interactive Trigger
/// ```dart
/// GlassPopover(
///   triggerBuilder: (context, toggle) => GlassButton(
///     onTap: toggle,
///     child: Text('Show Details'),
///   ),
///   contentBuilder: (context, close) => Padding(
///     padding: EdgeInsets.all(16),
///     child: Column(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         Text('Profile Details', style: TextStyle(color: Colors.white)),
///         SizedBox(height: 12),
///         GlassButton(onTap: close, child: Text('Done')),
///       ],
///     ),
///   ),
/// )
/// ```
///
/// ### With Fixed Height (Scrollable)
/// ```dart
/// GlassPopover(
///   popoverHeight: 300,
///   trigger: Icon(CupertinoIcons.list_bullet),
///   contentBuilder: (context, close) => ListView.builder(
///     itemCount: 50,
///     itemBuilder: (context, i) => ListTile(title: Text('Item $i')),
///   ),
/// )
/// ```
///
/// ### Custom Alignment
/// ```dart
/// GlassPopover(
///   alignment: GlassMenuAlignment.bottomCenter,
///   trigger: Icon(CupertinoIcons.arrow_down),
///   contentBuilder: (context, close) => Text('Below the trigger'),
/// )
/// ```
class GlassPopover extends StatefulWidget {
  /// Creates a liquid glass popover.
  const GlassPopover({
    super.key,
    this.trigger,
    this.triggerBuilder,
    required this.contentBuilder,
    this.popoverWidth = 280,
    this.popoverHeight,
    this.popoverBorderRadius = 24.0,
    this.alignment,
    this.autoAdjustToScreen = true,
    this.screenPadding = const EdgeInsets.all(12),
    this.settings,
    this.quality,
    this.stretch = 0.3,
    this.interactionScale = 1.02,
    this.stretchResistance = 0.08,
    this.stretchAxis,
    this.allowPositiveX,
    this.allowNegativeX,
    this.allowPositiveY,
    this.allowNegativeY,
    this.enableInteractionGlow = true,
    this.glowOnTapOnly = true,
    this.glowColor,
    this.glowRadius = 0.6,
    this.glowIntensity = 0.0,
    this.onClose,
    this.onOpen,
    this.barrierDismissible = true,
    this.blurRampDuration = const Duration(milliseconds: 260),
    this.blurRampCurve = Curves.easeOut,
    this.semanticLabel,
  }) : assert(trigger != null || triggerBuilder != null,
            'Either trigger or triggerBuilder must be provided');

  /// The widget that triggers the popover.
  ///
  /// If provided, this widget will be wrapped in a [GestureDetector] to handle
  /// taps. Use this for simple, non-interactive triggers like Icons or Text.
  ///
  /// If your trigger is interactive (like a [GlassButton]), use
  /// [triggerBuilder] instead to manually handle the tap event.
  final Widget? trigger;

  /// What the [trigger] opens, announced by screen readers (for example
  /// "More actions").
  ///
  /// The [trigger] is exposed as a button. A text trigger names itself, so
  /// this matters most for an icon. Not used with [triggerBuilder], whose
  /// widget carries its own semantics.
  final String? semanticLabel;

  /// A builder for the trigger widget that provides access to the popover
  /// toggle callback.
  ///
  /// Use this when your trigger widget handles its own interactions
  /// (e.g., a [GlassButton] or [IconButton]).
  ///
  /// Example:
  /// ```dart
  /// GlassPopover(
  ///   triggerBuilder: (context, toggle) => GlassButton(
  ///     onTap: toggle,
  ///     child: Text('Open'),
  ///   ),
  ///   ...,
  /// )
  /// ```
  final Widget Function(BuildContext context, VoidCallback togglePopover)?
      triggerBuilder;

  /// Builder for the popover content.
  ///
  /// Receives a `close` callback so content can dismiss the popover
  /// programmatically (e.g., a "Done" button).
  ///
  /// The content is rendered directly inside the morphing [GlassContainer],
  /// so it inherits the glass effect. The widget should use
  /// [MainAxisSize.min] or constrained height to size correctly.
  final Widget Function(BuildContext context, VoidCallback close)
      contentBuilder;

  /// Width of the expanded popover.
  ///
  /// Defaults to 280.
  final double popoverWidth;

  /// Fixed height for the popover.
  ///
  /// If null, the popover sizes itself to fit its content (intrinsic height).
  /// If provided, the popover will have a fixed height — the content is
  /// responsible for its own scrolling.
  final double? popoverHeight;

  /// Border radius of the expanded popover.
  ///
  /// Defaults to 24.0.
  final double popoverBorderRadius;

  /// The alignment of the popover relative to the trigger.
  ///
  /// If null or [GlassMenuAlignment.none], the popover auto-detects the best
  /// alignment based on the trigger's screen position.
  final GlassMenuAlignment? alignment;

  /// Whether to automatically adjust the popover position to keep it on screen.
  ///
  /// Defaults to true.
  final bool autoAdjustToScreen;

  /// Minimum distance between the popover and screen edges.
  ///
  /// Only applies when [autoAdjustToScreen] is true.
  /// Defaults to `EdgeInsets.all(12)`.
  final EdgeInsets screenPadding;

  /// Custom glass settings for the popover container.
  ///
  /// If null, inherits from parent [InheritedLiquidGlass] or uses subtle
  /// overlay defaults.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent quality or defaults via
  /// [GlassThemeHelpers.resolveQuality].
  final GlassQuality? quality;

  /// Liquid stretch factor.
  ///
  /// Defaults to 0.3 (subtle stretch for popovers).
  final double stretch;

  /// Scale factor applied on touch.
  ///
  /// Defaults to 1.02.
  final double interactionScale;

  /// The resistance factor to apply to the drag offset.
  ///
  /// Higher values make the drag feel "stickier". Default: 0.08.
  final double stretchResistance;

  /// The axis to constrain the stretch to. If null, stretches in both axes.
  final Axis? stretchAxis;

  /// Whether to allow stretch in the positive X direction (Right).
  /// If null, automatically determined by popover position.
  final bool? allowPositiveX;

  /// Whether to allow stretch in the negative X direction (Left).
  /// If null, automatically determined by popover position.
  final bool? allowNegativeX;

  /// Whether to allow stretch in the positive Y direction (Down).
  /// If null, automatically determined by popover position.
  final bool? allowPositiveY;

  /// Whether to allow stretch in the negative Y direction (Up).
  /// If null, automatically determined by popover position.
  final bool? allowNegativeY;

  /// Whether to show glow/glare on touch for tactile feedback.
  ///
  /// Defaults to true.
  final bool enableInteractionGlow;

  /// Whether the glow should act as a momentary tap indicator.
  ///
  /// Defaults to true.
  final bool glowOnTapOnly;

  /// Custom color for the touch interaction glow.
  final Color? glowColor;

  /// Radius of the touch interaction glow.
  ///
  /// Defaults to 0.6.
  final double glowRadius;

  /// The intensity of the interactive glow.
  ///
  /// Defaults to 0.0.
  final double glowIntensity;

  /// Called when the popover begins closing.
  ///
  /// Fires immediately when a close is triggered — tap outside the barrier,
  /// re-tapping the trigger, or calling the `close` callback — **before** the
  /// close animation completes.
  final VoidCallback? onClose;

  /// Called when the popover begins opening.
  ///
  /// Fires immediately when the popover is triggered, before the animation starts.
  final VoidCallback? onOpen;

  /// Whether tapping outside the popover dismisses it.
  ///
  /// Defaults to true.
  final bool barrierDismissible;

  /// How long the backdrop blur takes to ramp from `0` up to [settings]'s
  /// `blur` once the popover starts morphing open.
  ///
  /// **Why this exists.** The per-frame [BackdropFilter] blur is the dominant
  /// raster cost while a popover morphs out of its trigger. Rendering it at
  /// full strength from the very first frame pays that cost during the
  /// cheapest, still-growing part of the morph — precisely the frames most
  /// prone to dropping. Easing the blur in over the morph keeps those early
  /// frames cheap and reaches full strength only as the popover settles.
  /// Measured on mid-range mobile GPUs this roughly halves the raster time of
  /// the open transition (see `CHANGELOG.md` for `0.21.7` and
  /// `docs/POPOVER_BLUR_RAMP.md`).
  ///
  /// Because it is animated continuously (rather than snapped on after a fixed
  /// delay) the transition is never visible as an on/off switch — the blur
  /// simply blooms in with the glass.
  ///
  /// Defaults to `Duration(milliseconds: 260)` — about the window the liquid
  /// morph itself settles in. Set to [Duration.zero] to disable the ramp and
  /// render the blur at full strength from the first frame (the behaviour
  /// prior to `0.21.7`). The ramp is also skipped automatically when the
  /// platform "reduce motion" accessibility setting is active.
  final Duration blurRampDuration;

  /// The easing curve the blur ramp follows from `0` → full strength over
  /// [blurRampDuration].
  ///
  /// Defaults to [Curves.easeOut] so the blur arrives gently and is already
  /// near-full by the time the content fades in. Ignored when
  /// [blurRampDuration] is [Duration.zero].
  final Curve blurRampCurve;

  @override
  State<GlassPopover> createState() => _GlassPopoverState();
}
