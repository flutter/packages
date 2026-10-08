import 'package:flutter/cupertino.dart';
import '../../theme/glass_theme.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../types/glass_quality.dart';
import '../interactive/glass_button.dart';
import '../../src/utils/glass_localizations.dart';
import 'glass_text_field.dart';

/// A glass morphism search bar following Apple's iOS 26 design patterns.
///
/// [GlassSearchBar] provides a sophisticated search field with pill shape,
/// animated clear button, and optional cancel button that slides in from the
/// right. It matches iOS's UISearchBar appearance and behavior with glass
/// morphism effects.
///
/// ## Key Features
///
/// - **Pill-Shaped Glass**: Rounded search field with glass effect
/// - **Animated Clear Button**: Appears/fades when text is entered
/// - **Cancel Button**: Optional slide-in cancel button (iOS pattern)
/// - **Search Icon**: Leading search icon with customizable color
/// - **Auto-focus Support**: Can auto-focus on appearance
/// - **Dual Mode**: Grouped or standalone rendering
///
/// ## Usage
///
/// ### Basic Usage
/// ```dart
/// String query = '';
///
/// GlassSearchBar(
///   placeholder: 'Search',
///   onChanged: (value) {
///     setState(() => query = value);
///   },
/// )
/// ```
///
/// ### With Cancel Button
/// ```dart
/// GlassSearchBar(
///   placeholder: 'Search messages',
///   showsCancelButton: true,
///   onCancel: () {
///     // Clear search and dismiss keyboard
///   },
/// )
/// ```
///
/// ### Within LiquidGlassLayer (Grouped Mode)
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 8,
///     refractiveIndex: 1.59,
///   ),
///   child: Column(
///     children: [
///       GlassSearchBar(
///         placeholder: 'Search',
///         onChanged: (value) => _performSearch(value),
///       ),
///       // Search results...
///     ],
///   ),
/// )
/// ```
///
/// ### Standalone Mode
/// ```dart
/// GlassSearchBar(
///   placeholder: 'Search',
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 8,
///   ),
///   onChanged: (value) => _performSearch(value),
/// )
/// ```
///
/// ### Custom Styling
/// ```dart
/// GlassSearchBar(
///   placeholder: 'Search products...',
///   searchIconColor: Colors.blue,
///   clearIconColor: Colors.blue,
///   cancelButtonColor: Colors.blue,
///   textStyle: TextStyle(fontSize: 18, color: Colors.white),
///   height: 48,
/// )
/// ```
class GlassSearchBar extends StatefulWidget {
  /// Creates a glass search bar.
  const GlassSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onCancel,
    this.showsCancelButton = false,
    this.autofocus = false,
    this.enabled = true,
    this.searchIconColor,
    this.clearIconColor,
    this.cancelButtonColor,
    this.cancelIcon,
    this.cancelIconSize = 24,
    this.textStyle,
    this.placeholderStyle,
    this.height = 44.0,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.clearButtonSemanticLabel,
    this.cancelButtonSemanticLabel,
  });

  // ===========================================================================
  // Search Bar Properties
  // ===========================================================================

  /// Controls the text being edited.
  ///
  /// If null, a controller will be created internally.
  final TextEditingController? controller;

  /// Optional focus node for the search field.
  ///
  /// Providing a [FocusNode] gives you programmatic control over keyboard
  /// focus independently of [autofocus]:
  ///
  /// - `focusNode.requestFocus()` — open keyboard at any moment.
  /// - `focusNode.unfocus()` — dismiss keyboard without clearing text.
  /// - `focusNode.addListener(...)` — react to focus changes in your own code.
  ///
  /// **Lifecycle:** the caller is responsible for disposing the node.
  /// The widget will never dispose a caller-provided [FocusNode].
  ///
  /// If null, an internal node is created and disposed automatically.
  final FocusNode? focusNode;

  /// Placeholder text shown when the field is empty.
  ///
  /// Defaults to 'Search'.
  final String placeholder;

  /// Called when the search text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search.
  final ValueChanged<String>? onSubmitted;

  /// Called when the cancel button is tapped.
  ///
  /// If [showsCancelButton] is true and this callback is provided,
  /// the cancel button will be shown.
  final VoidCallback? onCancel;

  /// Whether to show the cancel button.
  ///
  /// When true, the cancel button slides in from the right when the search
  /// bar is focused, matching iOS behavior.
  ///
  /// Defaults to false.
  final bool showsCancelButton;

  /// Whether the search field should auto-focus.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// Whether the search field is enabled.
  ///
  /// Defaults to true.
  final bool enabled;

  // ===========================================================================
  // Style Properties
  // ===========================================================================

  /// Color of the search icon.
  ///
  /// Defaults to white with 60% opacity.
  final Color? searchIconColor;

  /// Color of the clear button icon.
  ///
  /// Defaults to white with 60% opacity.
  final Color? clearIconColor;

  /// Color of the cancel (×) icon.
  ///
  /// Defaults to white with 90% opacity.
  final Color? cancelButtonColor;

  /// Custom icon widget for the cancel button.
  ///
  /// When non-null, replaces the default [CupertinoIcons.xmark] glyph inside
  /// the glass dismiss pill. The widget is rendered as-is, so it should carry
  /// its own color and size. When null, [cancelButtonColor] and
  /// [cancelIconSize] apply to the default × icon.
  final Widget? cancelIcon;

  /// Size of the cancel (×) icon in logical pixels.
  ///
  /// Defaults to `24`, matching the visual weight of the search and clear icons.
  final double cancelIconSize;

  /// Screen reader label of the clear (×) button inside the field.
  ///
  /// Defaults to the app's [CupertinoLocalizations.clearButtonLabel].
  final String? clearButtonSemanticLabel;

  /// Screen reader label of the cancel button beside the field.
  ///
  /// Defaults to the app's [CupertinoLocalizations.cancelButtonLabel].
  final String? cancelButtonSemanticLabel;

  /// The style of the search text.
  final TextStyle? textStyle;

  /// The style of the placeholder text.
  final TextStyle? placeholderStyle;

  /// Height of the search bar.
  ///
  /// Defaults to 44 (iOS standard).
  final double height;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Glass effect settings (only used when [useOwnLayer] is true).
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass.
  ///
  /// Defaults to false (grouped mode).
  final bool useOwnLayer;

  /// Rendering quality for the glass effect.
  ///
  /// Defaults to [GlassQuality.standard], which uses the lightweight fragment
  /// shader. This works reliably in all contexts, including scrollable lists.
  ///
  /// Use [GlassQuality.premium] for full-pipeline shader with texture capture
  /// and chromatic aberration (Impeller only) in static layouts.
  final GlassQuality? quality;

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _hasText = false;
  bool _showCancelButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _onFocusChanged() {
    if (widget.showsCancelButton) {
      final hasFocus = _focusNode.hasFocus;
      if (hasFocus != _showCancelButton) {
        setState(() => _showCancelButton = hasFocus);
      }
    }
  }

  void _handleTapOutside(PointerDownEvent event) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Offset localPosition = renderBox.globalToLocal(event.position);
      if (renderBox.paintBounds.contains(localPosition)) {
        // Tap was inside the search bar row (e.g., on the cancel button), do nothing.
        return;
      }
    }
    _focusNode.unfocus();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  void _handleCancel() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onCancel?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;

    final searchIconColor = widget.searchIconColor ??
        (isDark ? const Color(0x99FFFFFF) : const Color(0x99000000));
    final clearIconColor = widget.clearIconColor ??
        (isDark ? const Color(0x99FFFFFF) : const Color(0x99000000));
    final cancelButtonColor = widget.cancelButtonColor ??
        (isDark ? const Color(0xE6FFFFFF) : const Color(0xE6000000));

    return Row(
      children: [
        // Search field
        Expanded(
          child: GlassTextField.search(
            controller: _controller,
            focusNode: _focusNode,
            placeholder: widget.placeholder,
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 20,
              color: searchIconColor,
            ),
            // AnimatedSwitcher cross-fades and scales the × in/out as the
            // user types — identical mechanism to _SearchPill for consistency.
            // No AnimationController needed; the bool setState drives it.
            suffixIcon: RepaintBoundary(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: _hasText
                    ? Icon(
                        CupertinoIcons.clear_circled_solid,
                        key: const ValueKey('clear'),
                        size: 18,
                        color: clearIconColor,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
            onSuffixTap: _hasText ? _handleClear : null,
            suffixSemanticLabel: widget.clearButtonSemanticLabel ??
                glassCupertinoLocalizationsOf(context).clearButtonLabel,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            onTapOutside: _handleTapOutside,
            textStyle: widget.textStyle,
            placeholderStyle: widget.placeholderStyle,
            height: widget.height,
            shape: LiquidRoundedRectangle(
              borderRadius: widget.height / 2,
            ),
            settings: widget.settings,
            useOwnLayer: widget.useOwnLayer,
            quality: widget.quality,
          ),
        ),

        // Cancel button — text style (iOS Spotlight / Messages pattern).
        // Note: GlassTabBar.searchable uses a glass ×‑icon button instead;
        // the two patterns are intentionally different — each matches the iOS
        // convention for its context (standalone screen vs. bottom bar).
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          child: AnimatedOpacity(
            opacity: _showCancelButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: _showCancelButton
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: GlassButton(
                      onTap: _handleCancel,
                      label: widget.cancelButtonSemanticLabel ??
                          glassCupertinoLocalizationsOf(context)
                              .cancelButtonLabel,
                      width: widget.height,
                      height: widget.height,
                      shape: const LiquidOval(),
                      settings: widget.settings,
                      useOwnLayer: widget.useOwnLayer,
                      quality: widget.quality,
                      icon: widget.cancelIcon ??
                          Icon(
                            CupertinoIcons.xmark,
                            color: cancelButtonColor,
                            size: widget.cancelIconSize,
                          ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
