import 'package:flutter/cupertino.dart';
import 'glass_focus_ring_painter.dart';

/// A shared accessibility and focus region for interactive glass widgets.
///
/// ## Modes
///
/// ### Interactive mode (default constructor)
///
/// Encapsulates:
/// - Semantic boundaries and roles.
/// - Keyboard focus traversal via [FocusableActionDetector].
/// - Space/Enter [ActivateIntent] mapping.
/// - The iOS 26-style focus ring painting (using a [ValueListenableBuilder] to
///   ensure zero GPU cost for touch users).
///
/// ### Observe mode ([GlassFocusRegion.observe])
///
/// For text inputs and other widgets that already own their [FocusNode]
/// (e.g. [CupertinoTextField]). In this mode the widget:
/// - Does **not** create a [FocusableActionDetector].
/// - Does **not** register any keyboard [Actions].
/// - Simply listens to the provided [FocusNode] and paints the iOS 26-style
///   focus ring when the node gains focus.
///
/// All keyboard intent handling and semantics remain with the wrapped widget.
///
/// **Use this for [GlassTextField], [GlassSearchBar], or any widget where
/// [CupertinoTextField] already manages the focus lifecycle.**
///
/// **State Lifting:**
/// In interactive mode, this region accepts [ValueNotifier]s from the parent
/// widget and updates them, allowing the parent to react to hover/focus
/// changes with zero additional rebuilds.
class GlassFocusRegion extends StatefulWidget {
  /// Interactive mode: full keyboard traversal, semantics, and focus ring.
  const GlassFocusRegion({
    required this.child,
    required this.enabled,
    this.shape,
    this.observedFocusNode,
    this.isFocusedNotifier,
    this.isHoveredNotifier,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.semanticLabel,
    this.isButton = false,
    this.isSlider = false,
    this.tracksSelection = false,
    this.isSelected = false,
    this.toggled,
    this.onKeyboardActivate,
    this.semanticOnTap,
    this.semanticOnLongPress,
    this.semanticValue,
    this.semanticIncreasedValue,
    this.semanticDecreasedValue,
    this.semanticOnIncrease,
    this.semanticOnDecrease,
    super.key,
  });

  /// Observe mode: paints the focus ring by listening to an external
  /// [FocusNode] without creating a [FocusableActionDetector].
  ///
  /// Use this for [GlassTextField], [GlassSearchBar], or any widget where
  /// [CupertinoTextField] already manages the focus lifecycle. The wrapped
  /// widget retains full control of its [FocusNode] and keyboard handling.
  // ignore: prefer_const_constructors_in_immutables
  GlassFocusRegion.observe({
    required this.child,
    required FocusNode focusNode,
    required ShapeBorder
        shape, // non-nullable; field is ShapeBorder? so this.shape would widen the type
    super.key,
  })  : observedFocusNode = focusNode,
        enabled = true,
        shape = shape, // ignore: prefer_initializing_formals
        isFocusedNotifier = null,
        isHoveredNotifier = null,
        focusNode = null,
        canRequestFocus = false,
        autofocus = false,
        semanticLabel = null,
        isButton = false,
        isSlider = false,
        tracksSelection = false,
        isSelected = false,
        toggled = null,
        onKeyboardActivate = null,
        semanticOnTap = null,
        semanticOnLongPress = null,
        semanticValue = null,
        semanticIncreasedValue = null,
        semanticDecreasedValue = null,
        semanticOnIncrease = null,
        semanticOnDecrease = null;

  // ── Shared fields ────────────────────────────────────────────────────────

  /// The widget tree inside the focus region.
  final Widget child;

  /// The exact shape of the widget, used to draw the focus ring.
  /// If null, no visual focus ring is painted by this region.
  final ShapeBorder? shape;

  /// Whether the widget is interactive and focusable.
  final bool enabled;

  // ── Observe-mode only ────────────────────────────────────────────────────

  /// When non-null, this widget operates in "observe" mode.
  ///
  /// See [GlassFocusRegion.observe].
  final FocusNode? observedFocusNode;

  // ── Interactive-mode fields ───────────────────────────────────────────────

  /// Externally provided focus node (from the parent's widget parameter).
  final FocusNode? focusNode;

  /// Whether the widget can request focus.
  final bool canRequestFocus;

  /// Whether to request focus immediately.
  final bool autofocus;

  /// A notifier that this region will update when keyboard focus arrives/leaves.
  /// If null, the region will manage its own internal state.
  final ValueNotifier<bool>? isFocusedNotifier;

  /// A notifier that this region will update when mouse hover enters/exits.
  /// If null, the region will manage its own internal state.
  final ValueNotifier<bool>? isHoveredNotifier;

  /// The semantic label for screen readers.
  ///
  /// When non-null, this label **replaces** the semantics of [child]: the
  /// child's own text is excluded so the control is announced once, by this
  /// name, on a single node. Leave it null when [child] should name the
  /// control itself (e.g. a list tile's title and subtitle).
  final String? semanticLabel;

  /// Whether this region should announce as a button to screen readers.
  final bool isButton;

  /// Whether this is a slider for screen readers.
  final bool isSlider;

  /// Whether this region participates in a mutual exclusivity group (like a
  /// segmented control).
  ///
  /// When true, unselected states emit `hasSelectedState: true` (with `selected: false`)
  /// so screen readers announce "not selected", making it clear this is a selectable
  /// option among others. When false (e.g. for standard buttons), unselected
  /// states omit the selected trait entirely to avoid confusing announcements.
  final bool tracksSelection;

  /// Whether the widget is currently selected (if it supports selection).
  final bool isSelected;

  /// The toggled state (for switches). If null, this semantic is not applied.
  final bool? toggled;

  /// Callback fired when the user presses Space or Enter while focused.
  final VoidCallback? onKeyboardActivate;

  /// Callback fired when screen readers invoke a tap.
  final VoidCallback? semanticOnTap;

  /// Callback fired when screen readers invoke a long press.
  final VoidCallback? semanticOnLongPress;

  /// Semantic value for sliders (e.g. '50%').
  final String? semanticValue;

  /// Semantic increased value for sliders.
  final String? semanticIncreasedValue;

  /// Semantic decreased value for sliders.
  final String? semanticDecreasedValue;

  /// Callback for increasing the slider value.
  final VoidCallback? semanticOnIncrease;

  /// Callback for decreasing the slider value.
  final VoidCallback? semanticOnDecrease;

  // ── Private helpers ───────────────────────────────────────────────────────

  bool get _isObserveMode => observedFocusNode != null;

  @override
  State<GlassFocusRegion> createState() => _GlassFocusRegionState();
}

class _GlassFocusRegionState extends State<GlassFocusRegion> {
  // Interactive-mode only. Empty in observe mode — never accessed there.
  Map<Type, Action<Intent>> _actions = const {};

  // Observe-mode only tracking to differentiate mouse clicks from Tab traversal.
  bool _hadRecentPointerEvent = false;
  bool _suppressRing = false;

  late final ValueNotifier<bool> _isFocusedNotifier;
  late final ValueNotifier<bool> _isHoveredNotifier;

  // null in observe mode; owned or adopted in interactive mode.
  FocusNode? _internalFocusNode;

  bool _ownsFocusNotifier = false;
  bool _ownsHoverNotifier = false;

  @override
  void initState() {
    super.initState();

    if (widget._isObserveMode) {
      // Observe mode: listen to the external FocusNode; no FocusableActionDetector.
      // We also listen to FocusManager.highlightMode so the ring only shows for
      // keyboard-driven focus — not mouse clicks. This mirrors iOS 26 behaviour
      // where text field rings are only visible to keyboard/external-keyboard users.
      _isFocusedNotifier = ValueNotifier(false); // starts hidden
      _ownsFocusNotifier = true;
      _isHoveredNotifier = ValueNotifier(false);
      _ownsHoverNotifier = true;
      widget.observedFocusNode!.addListener(_onObservedFocusChange);
      FocusManager.instance.addHighlightModeListener(_onHighlightModeChange);
      return;
    }

    // Interactive mode.
    _internalFocusNode =
        widget.focusNode ?? FocusNode(canRequestFocus: widget.canRequestFocus);
    if (widget.focusNode != null) {
      widget.focusNode!.canRequestFocus = widget.canRequestFocus;
    }
    if (widget.isFocusedNotifier != null) {
      _isFocusedNotifier = widget.isFocusedNotifier!;
    } else {
      _isFocusedNotifier = ValueNotifier(false);
      _ownsFocusNotifier = true;
    }
    if (widget.isHoveredNotifier != null) {
      _isHoveredNotifier = widget.isHoveredNotifier!;
    } else {
      _isHoveredNotifier = ValueNotifier(false);
      _ownsHoverNotifier = true;
    }
    _actions = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (Intent intent) {
          widget.onKeyboardActivate?.call();
          return null;
        },
      ),
    };
  }

  /// Called by the observed [FocusNode] listener in observe mode.
  /// Only activates the ring when focus is keyboard-driven.
  void _onObservedFocusChange() {
    if (!widget._isObserveMode) return;

    final hasFocus = widget.observedFocusNode!.hasFocus;

    if (!hasFocus) {
      _suppressRing = false;
      _isFocusedNotifier.value = false;
      return;
    }

    // If focus was gained while the user is actively pressing on this widget,
    // they used a pointing device. Suppress the focus ring.
    if (_hadRecentPointerEvent) {
      _suppressRing = true;
    }

    final isKeyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

    _isFocusedNotifier.value = isKeyboard && !_suppressRing;
  }

  /// Called when the global highlight mode changes (e.g. user plugs in
  /// a keyboard mid-session). Re-evaluates ring visibility immediately.
  void _onHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted || !widget._isObserveMode) return;
    final isKeyboard = mode == FocusHighlightMode.traditional;
    _isFocusedNotifier.value = (widget.observedFocusNode?.hasFocus ?? false) &&
        isKeyboard &&
        !_suppressRing;
  }

  @override
  void didUpdateWidget(covariant GlassFocusRegion oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._isObserveMode) {
      // Rewire the listener if the caller swapped the focus node.
      if (oldWidget.observedFocusNode != widget.observedFocusNode) {
        oldWidget.observedFocusNode!.removeListener(_onObservedFocusChange);
        widget.observedFocusNode!.addListener(_onObservedFocusChange);
        _isFocusedNotifier.value = widget.observedFocusNode!.hasFocus;
      }
      return;
    }

    // Interactive mode.
    if (oldWidget.canRequestFocus != widget.canRequestFocus) {
      _internalFocusNode!.canRequestFocus = widget.canRequestFocus;
    }
  }

  @override
  void dispose() {
    if (widget._isObserveMode) {
      widget.observedFocusNode!.removeListener(_onObservedFocusChange);
      FocusManager.instance.removeHighlightModeListener(_onHighlightModeChange);
    } else {
      if (widget.focusNode == null) _internalFocusNode?.dispose();
    }
    if (_ownsFocusNotifier) _isFocusedNotifier.dispose();
    if (_ownsHoverNotifier) _isHoveredNotifier.dispose();
    super.dispose();
  }

  /// Wraps [child] in the iOS 26-style focus ring [Stack] when [isFocused]
  /// is true and [widget.shape] is non-null.
  ///
  /// Shared between interactive and observe mode to eliminate duplication.
  Widget _buildRing(bool isFocused, Widget child) {
    if (!isFocused || widget.shape == null) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: GlassFocusRingPainter(
                color: CupertinoColors.activeBlue.resolveFrom(context),
                shape: widget.shape!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// An enabled region that cannot take focus still reacts to the mouse.
  /// FocusableActionDetector only reports hover while it is enabled, which it
  /// is not here, so a MouseRegion drives the hover notifier instead.
  Widget _withHover(Widget child) {
    if (!widget.enabled || widget.canRequestFocus) return child;
    return MouseRegion(
      onEnter: (_) => _isHoveredNotifier.value = true,
      onExit: (_) => _isHoveredNotifier.value = false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Observe mode ──────────────────────────────────────────────────────────
    // No semantics wrapper, no FocusableActionDetector.
    // The wrapped CupertinoTextField handles all of that itself.
    if (widget._isObserveMode) {
      return Listener(
        onPointerDown: (_) => _hadRecentPointerEvent = true,
        onPointerUp: (_) => _hadRecentPointerEvent = false,
        onPointerCancel: (_) => _hadRecentPointerEvent = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isFocusedNotifier,
          builder: (context, isFocused, child) => _buildRing(isFocused, child!),
          child: widget.child,
        ),
      );
    }

    // ── Interactive mode ──────────────────────────────────────────────────────
    //
    // A control must surface as exactly ONE semantics node (#381):
    //
    // - `focusable` is deliberately not set on the Semantics below. The
    //   FocusableActionDetector already contributes isFocusable/isFocused and
    //   the focus action. Declaring the flag on both makes the configurations
    //   incompatible, and the focus semantics split off into a second node:
    //   an unlabelled stop for TalkBack, or — when the child has text — a
    //   duplicate stop that VoiceOver reads a second time.
    // - When the region names itself, the child's own semantics are excluded,
    //   otherwise the now-merged node would read the label and the visible
    //   text back to back.
    final hasSemanticLabel =
        widget.semanticLabel != null && widget.semanticLabel!.isNotEmpty;
    final content =
        hasSemanticLabel ? ExcludeSemantics(child: widget.child) : widget.child;

    return Semantics(
      // container: true creates an isolated semantics boundary so that the
      // label and tap action stay on this node and are not merged into an
      // ancestor container (which would concatenate the label with unrelated
      // text, e.g. an app-bar title, and put the tap on a different node).
      container: widget.isButton || widget.isSlider || hasSemanticLabel,
      button: widget.isButton,
      slider: widget.isSlider,
      // Only set `selected` when this region tracks selection state.
      // Passing `selected: false` unconditionally emits `hasSelectedState`
      // which breaks semantics checks on plain buttons (GlassButton, GlassChip).
      // However, segmented controls MUST emit `hasSelectedState` even when unselected
      // so users know it's a selectable option.
      selected: widget.tracksSelection
          ? widget.isSelected
          : (widget.isSelected ? true : null),
      toggled: widget.toggled,
      label: hasSemanticLabel ? widget.semanticLabel : null,
      value: widget.semanticValue,
      increasedValue: widget.semanticIncreasedValue,
      decreasedValue: widget.semanticDecreasedValue,
      enabled: widget.enabled,
      onTap: widget.semanticOnTap,
      onLongPress: widget.semanticOnLongPress,
      onIncrease: widget.semanticOnIncrease,
      onDecrease: widget.semanticOnDecrease,
      child: _withHover(
        FocusableActionDetector(
          // FocusableActionDetector writes its own `enabled` into the focus
          // node's canRequestFocus on every build, so canRequestFocus must be
          // folded in here or it is silently overridden (a non-focusable
          // region would still take keyboard focus and expose a focus node).
          enabled: widget.enabled && widget.canRequestFocus,
          focusNode: _internalFocusNode!,
          autofocus: widget.autofocus,
          actions: _actions,
          mouseCursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onShowFocusHighlight: (v) => _isFocusedNotifier.value = v,
          onShowHoverHighlight: (v) => _isHoveredNotifier.value = v,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isFocusedNotifier,
            builder: (context, isFocused, child) =>
                _buildRing(isFocused, child!),
            child: content,
          ),
        ),
      ),
    );
  }
}
