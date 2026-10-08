// Internal state lifecycle mixin for interactive glass container widgets.
//
// NOT part of the public API — do not export from liquid_glass_widgets.dart.
library;

import 'package:flutter/widgets.dart';

/// State lifecycle mixin for interactive glass container widgets.
///
/// Provides [isPressed], [isFocused], and [isHovered] [ValueNotifier]s and
/// their most common [Listenable.merge] combinations, with guaranteed
/// disposal in [dispose].
///
/// ## Why a mixin, not a widget?
///
/// Container item widgets in this package ([GlassListTile], [GlassMenuItem],
/// `_ActionSheetButton`, `_GlassGroupItemWidget`) share the same interaction
/// *state lifecycle* but have fundamentally different rendering: distinct
/// shapes, decorations, scale effects, and external press states. A shared
/// "wrapper widget" would accumulate all those render differences as
/// constructor parameters, producing a God Widget.
///
/// A mixin supplies only the shared infrastructure — the [ValueNotifier]s and
/// their merged [Listenable]s — while leaving each widget's rendering exactly
/// where it belongs: in its own `build` method. This mirrors how Flutter's
/// own framework handles similar problems: [SingleTickerProviderStateMixin]
/// provides a [Ticker] without imposing how the animation is painted;
/// [AutomaticKeepAliveClientMixin] keeps a subtree alive without changing
/// its build output.
///
/// ## Usage
///
/// Apply to a [State] subclass, then use [isPressed], [isFocused], or
/// [isHovered] wherever you previously declared them as fields:
///
/// ```dart
/// class _MyState extends State<MyWidget>
///     with GlassInteractionStateMixin {
///   @override
///   Widget build(BuildContext context) {
///     return GlassFocusRegion(
///       isFocusedNotifier: isFocused,
///       child: GestureDetector(
///         onTapDown: (_) => isPressed.value = true,
///         onTapUp:   (_) => isPressed.value = false,
///         onTapCancel:  () => isPressed.value = false,
///         child: ListenableBuilder(
///           listenable: pressedAndFocused,
///           builder: (context, child) {
///             final highlight = isPressed.value || isFocused.value;
///             return AnimatedContainer(
///               duration: isPressed.value
///                   ? Duration.zero
///                   : const Duration(milliseconds: 150),
///               color: highlight
///                   ? const Color(0x1AFFFFFF)
///                   : const Color(0x00000000),
///               child: child,
///             );
///           },
///           child: ...,
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// **Do not** update [isFocused] or [isHovered] directly; pass them to
/// [GlassFocusRegion] via `isFocusedNotifier` and `isHoveredNotifier` and
/// let the region manage them.
mixin GlassInteractionStateMixin<T extends StatefulWidget> on State<T> {
  // ---------------------------------------------------------------------------
  // ValueNotifiers
  // ---------------------------------------------------------------------------

  /// Whether the user is currently pressing this widget.
  ///
  /// Set `true` on `onTapDown` / `onPointerDown`, `false` on
  /// `onTapUp` / `onTapCancel` / `onPointerUp` / `onPointerCancel`.
  final ValueNotifier<bool> isPressed = ValueNotifier(false);

  /// Whether keyboard focus is currently on this widget.
  ///
  /// Managed automatically by [GlassFocusRegion] when you pass this as its
  /// `isFocusedNotifier`. Do not update directly.
  final ValueNotifier<bool> isFocused = ValueNotifier(false);

  /// Whether the pointer is currently hovering over this widget.
  ///
  /// Managed automatically by [GlassFocusRegion] when you pass this as its
  /// `isHoveredNotifier`. Do not update directly.
  final ValueNotifier<bool> isHovered = ValueNotifier(false);

  // ---------------------------------------------------------------------------
  // Pre-merged Listenables
  //
  // Two combinations cover every current use case:
  //   • pressedAndFocused — list tiles, action sheet rows (no hover response)
  //   • allInteraction    — menu items (hover + focus + press)
  //
  // Using pre-built Listenables rather than calling Listenable.merge() in each
  // widget's build() avoids allocating a new _MergingListenable on every
  // rebuild and keeps the wiring uniform across files.
  // ---------------------------------------------------------------------------

  /// A [Listenable] that fires when [isPressed] or [isFocused] change.
  ///
  /// Use this as the `listenable` of a [ListenableBuilder] that drives a
  /// background highlight responding to both pointer presses and keyboard
  /// focus but not hover (e.g. [GlassListTile], `_ActionSheetButton`).
  late final Listenable pressedAndFocused;

  /// A [Listenable] that fires when [isPressed], [isFocused], or [isHovered]
  /// change.
  ///
  /// Use this for widgets that respond to all three interaction states
  /// (e.g. [GlassMenuItem]).
  late final Listenable allInteraction;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    pressedAndFocused = Listenable.merge([isPressed, isFocused]);
    allInteraction = Listenable.merge([isPressed, isFocused, isHovered]);
  }

  @mustCallSuper
  @override
  void dispose() {
    isPressed.dispose();
    isFocused.dispose();
    isHovered.dispose();
    super.dispose();
  }
}
