import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/types/glass_interaction_behavior.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_glass.dart';
import '../shared/glass_focus_region.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../theme/glass_theme.dart';

/// A glass text field widget following Apple's input field design.
///
/// [GlassTextField] provides a text input field with glass morphism effect,
/// matching iOS design patterns with customizable styling.
///
/// ## Usage Modes
///
/// ### Grouped Mode (default)
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(...),
///   child: Column(
///     children: [
///       GlassTextField(
///         placeholder: 'Email',
///         keyboardType: TextInputType.emailAddress,
///       ),
///       GlassTextField(
///         placeholder: 'Password',
///         obscureText: true,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Standalone Mode
/// ```dart
/// GlassTextField(
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(...),
///   placeholder: 'Search...',
///   prefixIcon: Icon(Icons.search, size: 20, color: Colors.white70),
/// )
/// ```
///
/// ## Customization Examples
///
/// ### With prefix and suffix icons:
/// ```dart
/// GlassTextField(
///   placeholder: 'Search',
///   prefixIcon: Icon(Icons.search, size: 20, color: Colors.white70),
///   suffixIcon: Icon(Icons.clear, size: 20, color: Colors.white70),
///   onSuffixTap: () => controller.clear(),
/// )
/// ```
///
/// ### Multiline text area:
/// ```dart
/// GlassTextField(
///   placeholder: 'Enter your message...',
///   maxLines: 5,
///   minLines: 3,
/// )
/// ```
class GlassTextField extends StatefulWidget {
  /// Creates a glass text field.
  const GlassTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffixSemanticLabel,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onLineCountChanged,
    this.inputFormatters,
    this.textStyle,
    this.placeholderStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.iconSpacing = 12.0,
    this.iconAlignment = CrossAxisAlignment.center,
    this.height,
    this.minHeight,
    this.maxHeight,
    this.bottom,
    this.shape = const LiquidRoundedRectangle(borderRadius: 10),
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    // ── iOS 26 interaction ────────────────────────────────────────────────────────────
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.pressScale = 1.03,
    this.glowColor,
    this.glowRadius = 1.5,
    this.onTapOutside,
  }) : assert(
          height == null || (minHeight == null && maxHeight == null),
          'height is mutually exclusive with minHeight / maxHeight. '
          'Use either height for a fixed size, or minHeight/maxHeight for '
          'a constrained range.',
        );

  /// Creates a glass text field styled specifically for search, matching
  /// the compact layout and visuals of [GlassSearchBar].
  const GlassTextField.search({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffixSemanticLabel,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textStyle,
    this.placeholderStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.iconSpacing = 8.0,
    this.height = 44.0,
    this.shape = const LiquidRoundedRectangle(borderRadius: 22),
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.pressScale = 1.03,
    this.glowColor,
    this.glowRadius = 1.5,
    this.onTapOutside,
  })  : obscureText = false,
        keyboardType = TextInputType.text,
        textInputAction = TextInputAction.search,
        maxLines = 1,
        minLines = 1,
        maxLength = null,
        onLineCountChanged = null,
        iconAlignment = CrossAxisAlignment.center,
        minHeight = null,
        maxHeight = null,
        bottom = null;

  // ===========================================================================
  // Text Field Properties
  // ===========================================================================

  /// Controls the text being edited.
  ///
  /// If null, a controller will be created internally.
  final TextEditingController? controller;

  /// Controls the focus state of the text field.
  ///
  /// If null, a focus node will be created internally.
  final FocusNode? focusNode;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// Widget displayed at the start of the field.
  final Widget? prefixIcon;

  /// Widget displayed at the end of the field.
  final Widget? suffixIcon;

  /// Callback when suffix icon is tapped.
  final VoidCallback? onSuffixTap;

  /// What tapping the suffix icon does, announced by screen readers (for
  /// example "Clear text").
  ///
  /// Used only when [onSuffixTap] is set: the suffix is then exposed as a
  /// button of its own. An icon has no text, so without a label the button is
  /// announced by its role alone.
  final String? suffixSemanticLabel;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// The action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Maximum number of lines for the text field.
  ///
  /// Defaults to 1 for single-line input.
  final int maxLines;

  /// Minimum number of lines for the text field.
  final int? minLines;

  /// Maximum number of characters allowed.
  final int? maxLength;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// Whether the text field should auto-focus.
  final bool autofocus;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Called when the user taps outside the text field.
  ///
  /// Defaults to unfocusing the field, which dismisses the keyboard.
  final TapRegionCallback? onTapOutside;

  /// Called when the number of rendered text lines changes.
  ///
  /// The callback receives the current line count after layout. This is
  /// the **rendered** line count (accounting for text wrapping), not the
  /// number of `\n` characters in the text.
  ///
  /// Fires on initial build and on every subsequent change. Does NOT fire
  /// when the line count stays the same.
  ///
  /// Useful for animating the surrounding container’s height or shape
  /// (e.g. reducing `borderRadius` as lines increase):
  ///
  /// ```dart
  /// GlassTextField(
  ///   maxLines: 6,
  ///   onLineCountChanged: (lines) {
  ///     setState(() => _lines = lines);
  ///   },
  /// )
  /// ```
  final ValueChanged<int>? onLineCountChanged;

  // ===========================================================================
  // Style Properties
  // ===========================================================================

  /// The style of the text being edited.
  final TextStyle? textStyle;

  /// The style of the placeholder text.
  final TextStyle? placeholderStyle;

  /// Padding inside the text field.
  ///
  /// Defaults to 16px horizontal, 12px vertical.
  final EdgeInsetsGeometry padding;

  /// Spacing between the icons and the text field.
  ///
  /// Defaults to 12.
  final double iconSpacing;

  /// Shape of the text field.
  ///
  /// Defaults to [LiquidRoundedRectangle] with 10px border radius.
  final LiquidShape shape;

  /// Vertical alignment of prefix and suffix icons.
  ///
  /// Controls where icons are positioned when the field spans multiple lines:
  ///
  /// - [CrossAxisAlignment.center] — icons centered vertically (default)
  /// - [CrossAxisAlignment.start] — icons pinned to top
  /// - [CrossAxisAlignment.end] — icons pinned to bottom
  ///
  /// For single-line fields this has no visible effect.
  /// Defaults to [CrossAxisAlignment.center] (preserves existing behaviour).
  ///
  /// ```dart
  /// // Pin icons to bottom — common in chat message composers:
  /// GlassTextField(
  ///   maxLines: 6,
  ///   iconAlignment: CrossAxisAlignment.end,
  ///   suffixIcon: Icon(Icons.send),
  /// )
  /// ```
  final CrossAxisAlignment iconAlignment;

  // ===========================================================================
  // Size Properties
  // ===========================================================================

  /// Fixed height of the text field.
  ///
  /// If non-null, the field is wrapped in a `SizedBox` with this height.
  /// Mutually exclusive with [minHeight] / [maxHeight].
  ///
  /// Set to `44` to match [GlassSearchBar.height] for visual parity in
  /// single-line mode.
  final double? height;

  /// Minimum height constraint.
  ///
  /// When set alongside [maxHeight], wraps the field in a `ConstrainedBox`.
  /// The field grows from [minHeight] up to [maxHeight] as lines are added.
  final double? minHeight;

  /// Maximum height constraint.
  ///
  /// When set, the field will not grow beyond this height and will scroll
  /// internally once the content exceeds the available space.
  final double? maxHeight;

  /// Optional widget displayed below the text area, inside the same glass card.
  ///
  /// Use this to build a "rich composer" layout — a text input on top with an
  /// action bar, attachment strip, or formatting toolbar below, all sharing one
  /// glass surface.
  ///
  /// The panel inherits the frosted-well darkening of the surrounding glass
  /// card. Callers can add a [Divider] between the text area and the panel if
  /// a visual separator is desired.
  ///
  /// ```dart
  /// GlassTextField(
  ///   maxLines: 5,
  ///   bottom: Padding(
  ///     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ///     child: Row(
  ///       children: [
  ///         IconButton(icon: Icon(Icons.attach_file), onPressed: _attach),
  ///         const Spacer(),
  ///         IconButton(icon: Icon(Icons.send), onPressed: _send),
  ///       ],
  ///     ),
  ///   ),
  /// )
  /// ```
  ///
  /// Not available on [GlassTextField.search] (single-line; `bottom` is
  /// always `null` there).
  final Widget? bottom;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Glass effect settings (only used when [useOwnLayer] is true).
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass.
  final bool useOwnLayer;

  /// Rendering quality for the glass effect.
  ///
  /// Defaults to [GlassQuality.standard], which uses backdrop filter rendering.
  /// This works reliably in all contexts, including scrollable lists.
  ///
  /// Use [GlassQuality.premium] for shader-based glass in static layouts only.
  final GlassQuality? quality;

  // ── iOS 26 interaction ────────────────────────────────────────────────────

  /// Controls which press-interaction effects are active on this field.
  ///
  /// Mirrors the API on [GlassTabBar] for
  /// a consistent developer experience across all glass surfaces:
  ///
  /// | Value | Glow | Scale-on-focus |
  /// |---|---|---|
  /// | `none` | ✗ | ✗ |
  /// | `glowOnly` | ✓ | ✗ |
  /// | `scaleOnly` | ✗ | ✓ |
  /// | `full` *(default)* | ✓ | ✓ |
  ///
  /// **Glow** — the iOS 26-style directional spotlight that tracks the touch
  /// position across the glass surface.
  ///
  /// **Scale** — the subtle press-bounce animation (`pressScale`) that fires
  /// when the user presses down on the field, then springs back on release,
  /// matching iOS 26 touch feedback.
  ///
  /// Defaults to [GlassInteractionBehavior.full], preserving the existing
  /// visual behaviour.
  final GlassInteractionBehavior interactionBehavior;

  /// Scale factor applied when the field is pressed.
  ///
  /// Only active when [interactionBehavior] includes scale
  /// ([GlassInteractionBehavior.scaleOnly] or [GlassInteractionBehavior.full]).
  ///
  /// A value of `1.03` means the field grows 3% when pressed.
  /// Defaults to `1.03`.
  final double pressScale;

  /// Colour of the directional glow.
  ///
  /// Only active when [interactionBehavior] includes glow. If null, falls back
  /// to a soft `Colors.white` at ~12% opacity — visibly lighter than
  /// [GlassButton]'s `white24` to match the iOS 26 input look.
  final Color? glowColor;

  /// Spread radius of the directional glow relative to the field's dimensions.
  ///
  /// A value of `1.5` means the glow spreads 150% of the field's shorter
  /// dimension, creating a wide, diffuse ambient highlight across the surface.
  ///
  /// Defaults to `1.5`.
  final double glowRadius;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late FocusNode _focusNode;
  // Tracks whether _focusNode was created by us (true) or provided externally.
  bool _ownsNode = false;
  bool _isPressed = false;
  int _currentLineCount = 0;
  TextEditingController? _effectiveController;

  /// Current rendered line count.
  ///
  /// Access via a `GlobalKey<_GlassTextFieldState>`.
  int get lineCount => _currentLineCount;

  final GlobalKey _textFieldKey = GlobalKey();

  /// Wraps [child] in a [GlassGlow] sensor only when [interactionBehavior]
  /// includes glow. Skips the widget entirely otherwise — zero allocation cost.
  Widget _wrapWithGlow(Widget child, bool isDark) {
    if (!widget.interactionBehavior.hasGlow) return child;
    return GlassGlow(
      glowColor: widget.glowColor ??
          (isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000)),
      glowRadius: widget.glowRadius,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsNode = true;
    }

    _initController();

    // Schedule initial line count measurement after first layout.
    if (widget.onLineCountChanged != null) {
      _scheduleLineCountCheck();
    }
  }

  void _initController() {
    _effectiveController = widget.controller;
    _effectiveController?.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (widget.onLineCountChanged != null) {
      _scheduleLineCountCheck();
    }
  }

  @override
  void didUpdateWidget(GlassTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the external focusNode reference changed, rewire ownership.
    // GlassFocusRegion.observe handles its own listener — we only manage
    // node creation/disposal here.
    if (oldWidget.focusNode != widget.focusNode) {
      // Dispose the old node only if we owned it.
      if (_ownsNode) _focusNode.dispose();

      if (widget.focusNode != null) {
        // Caller is providing an external node — adopt it.
        _focusNode = widget.focusNode!;
        _ownsNode = false;
      } else {
        // Caller removed the external node — create a fresh internal one.
        _focusNode = FocusNode();
        _ownsNode = true;
      }
    }
    // If the external controller reference changed, rewire the listener.
    if (oldWidget.controller != widget.controller) {
      _effectiveController?.removeListener(_onControllerChange);
      _initController();
    }
    // If disabled, cancel any in-flight press so the spring always returns.
    if (!widget.enabled && _isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  void dispose() {
    if (_ownsNode) _focusNode.dispose();
    _effectiveController?.removeListener(_onControllerChange);
    super.dispose();
  }

  // ── Line count tracking ──────────────────────────────────────────────────

  // Guard state: track (text, width) rather than size.
  // Tracking only `size` was the bug: when the outer container has a fixed
  // `height` (e.g. `SizedBox(height: 46)`), the inner TextField RenderBox
  // size stays constant even as lines change — the size guard exited early
  // and `onLineCountChanged` silently stopped firing after the first call.
  // Tracking text + width is the minimal correct guard: size.width changing
  // means available wrapping space changed; text changing means content
  // changed. Either is enough to warrant a re-measurement.
  String _lastMeasuredText = '';
  double _lastMeasuredWidth = 0.0;
  bool _lineCheckScheduled = false;

  /// Schedules a line count measurement for the next frame.
  ///
  /// Debounced: both `onChanged` and the controller listener call this on
  /// every keystroke — the flag ensures only one callback is queued per frame.
  void _scheduleLineCountCheck() {
    if (_lineCheckScheduled) return;
    _lineCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lineCheckScheduled = false;
      if (!mounted) return;
      _measureLineCount();
    });
  }

  /// Measures the TextField's rendered height and infers line count.
  /// Fires [onLineCountChanged] only when the count actually changes.
  void _measureLineCount() {
    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    if (size.width <= 0) return;

    final currentText = _effectiveController?.text ?? '';

    // Guard: skip only when both text AND available width are unchanged.
    // We intentionally do NOT guard on size.height — a fixed outer height
    // (e.g. height: 46) keeps the RenderBox height constant while the number
    // of rendered lines may still change as the user types.
    if (currentText == _lastMeasuredText && size.width == _lastMeasuredWidth) {
      return;
    }
    _lastMeasuredText = currentText;
    _lastMeasuredWidth = size.width;

    // Use MediaQuery textScaler for accurate line height calculation.
    final textScaler = MediaQuery.textScalerOf(context);
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;

    final defaultTextStyle = TextStyle(
      color: isDark
          ? const Color.fromRGBO(255, 255, 255, 0.9)
          : const Color.fromRGBO(0, 0, 0, 0.9),
      fontSize: 16,
      height: 1.2,
    );
    final effectiveStyle = defaultTextStyle.merge(widget.textStyle);
    final fontSize = effectiveStyle.fontSize ?? 16.0;
    final effectiveLineHeight =
        textScaler.scale(fontSize) * (effectiveStyle.height ?? 1.2);

    final lineCount =
        (size.height / effectiveLineHeight).round().clamp(1, 9999);

    if (lineCount != _currentLineCount) {
      _currentLineCount = lineCount;
      widget.onLineCountChanged?.call(lineCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;

    final defaultTextStyle = TextStyle(
      color: isDark
          ? const Color.fromRGBO(255, 255, 255, 0.9)
          : const Color.fromRGBO(0, 0, 0, 0.9),
      fontSize: 16,
      height: 1.2,
    );

    final defaultPlaceholderStyle = TextStyle(
      color: isDark
          ? const Color.fromRGBO(255, 255, 255, 0.5)
          : const Color.fromRGBO(0, 0, 0, 0.5),
      fontSize: 16,
    );

    // In fixed-height mode, force CrossAxisAlignment.center so that icon
    // position is immune to system text scaling. With .center inside
    // Align(center), the icon position simplifies to (container − icon) / 2
    // which is independent of the Row's intrinsic height. The .end/.start
    // alignments depend on Row height and therefore drift when text scales.
    // In dynamic-height mode, respect the caller's iconAlignment as-is.
    final effectiveIconAlignment = widget.height != null
        ? CrossAxisAlignment.center
        : widget.iconAlignment;

    // Build the icon + text row.
    final rowContent = Row(
      crossAxisAlignment: effectiveIconAlignment,
      children: [
        // Prefix icon
        if (widget.prefixIcon != null) ...[
          widget.prefixIcon!,
          SizedBox(width: widget.iconSpacing),
        ],

        // Text field
        Expanded(
          child: CupertinoTextField(
            key: _textFieldKey,
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            onChanged: (value) {
              widget.onChanged?.call(value);
              _scheduleLineCountCheck();
            },
            onSubmitted: widget.onSubmitted,
            onTapOutside: widget.onTapOutside ??
                (event) => FocusManager.instance.primaryFocus?.unfocus(),
            inputFormatters: widget.inputFormatters,
            style: defaultTextStyle.merge(widget.textStyle),
            placeholder: widget.placeholder,
            placeholderStyle:
                defaultPlaceholderStyle.merge(widget.placeholderStyle),
            padding: EdgeInsets.zero,
            decoration: null,
          ),
        ),

        // Suffix icon
        if (widget.suffixIcon != null) ...[
          SizedBox(width: widget.iconSpacing),
          // Its own button node while tappable, so the tap is not merged
          // into the field and a screen reader can reach it. A Semantics
          // inside the icon (as GlassPasswordField sets) merges into it. The
          // wrapper stays in the tree when the tap goes away so a suffix that
          // animates (GlassSearchBar's clear button) is not remounted.
          Semantics(
            container: widget.onSuffixTap != null,
            button: widget.onSuffixTap != null ? true : null,
            label:
                widget.onSuffixTap != null ? widget.suffixSemanticLabel : null,
            child: GestureDetector(
              onTap: widget.onSuffixTap,
              child: widget.suffixIcon,
            ),
          ),
        ],
      ],
    );

    // Fixed-height mode: strip vertical padding and center the row so that
    // placeholder text stays vertically centred regardless of system font
    // scale. Dynamic/constrained-height modes use the full padding as before.
    final resolvedPadding = widget.padding.resolve(Directionality.of(context));
    Widget textFieldContent = widget.height != null
        ? Padding(
            padding: EdgeInsets.only(
              left: resolvedPadding.left,
              right: resolvedPadding.right,
            ),
            child: Align(alignment: Alignment.center, child: rowContent),
          )
        : Padding(padding: widget.padding, child: rowContent);

    // Bottom panel: wrap in a Column when caller provides an action bar,
    // attachment strip, etc. — all sharing the same glass surface.
    //
    // The text area is Flexible so the bottom panel always gets its natural
    // height first. The text area takes whatever space remains within the
    // height / maxHeight constraint. Without Flexible the Column has no flex
    // children and overflows when (text area + bottom) > maxHeight.
    if (widget.bottom != null) {
      textFieldContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(child: textFieldContent),
          widget.bottom!,
        ],
      );
    }

    // Inherit quality from parent layer if not explicitly set
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    // Apply glass effect
    // iOS 26: wrap in GlassGlow only when interactionBehavior includes glow.
    // _wrapWithGlow skips the widget entirely when glow is suppressed,
    // saving 3 widget/render-object allocations — same pattern as GlassTabBar.bottom.
    Widget glassWidget = AdaptiveGlass(
      shape: widget.shape,
      settings: GlassThemeHelpers.resolveSettings(
        context,
        explicit: widget.settings,
      ),
      quality: effectiveQuality,
      useOwnLayer: widget.useOwnLayer,
      child: _wrapWithGlow(textFieldContent, isDark),
    );

    // GlassGlowLayer is now automatically provided by GlassGlow internally.

    // iOS 26: animate scale on press — field squishes/inflates on tap, springs back on release.
    // Only active when interactionBehavior includes scale.
    if (widget.interactionBehavior.hasScale) {
      glassWidget = AnimatedScale(
        scale: _isPressed ? widget.pressScale : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: glassWidget,
      );

      // Wrap with Listener to capture pointer down/up state for the bounce animation
      glassWidget = Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: glassWidget,
      );
    }

    // ── Focus ring (keyboard navigation) ─────────────────────────────────────
    // GlassFocusRegion.observe() listens to _focusNode internally and paints
    // the ring without creating a FocusableActionDetector — preserving
    // CupertinoTextField's full ownership of the focus lifecycle.
    //
    final shapeRadius = widget.shape.toBorderRadius();
    final ShapeBorder ringShape = shapeRadius != null
        ? RoundedRectangleBorder(borderRadius: shapeRadius)
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(22));

    // Semantics: declare as a text field so screen readers announce correctly.
    // CupertinoTextField's own semantics handle editing actions/value/cursor.
    return Semantics(
      textField: true,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        child: GlassFocusRegion.observe(
          focusNode: _focusNode,
          shape: ringShape,
          child: _wrapWithConstraints(glassWidget),
        ),
      ),
    );
  }

  /// Wraps [child] in height constraints when [height], [minHeight], or
  /// [maxHeight] is specified. Returns [child] unchanged otherwise.
  Widget _wrapWithConstraints(Widget child) {
    if (widget.height != null) {
      return SizedBox(height: widget.height, child: child);
    }
    if (widget.minHeight != null || widget.maxHeight != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.minHeight ?? 0,
          maxHeight: widget.maxHeight ?? double.infinity,
        ),
        child: child,
      );
    }
    return child;
  }
}
