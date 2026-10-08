import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/types/glass_interaction_behavior.dart';
import '../../types/glass_quality.dart';
import 'glass_text_field.dart';

/// A multi-line glass text area.
///
/// [GlassTextArea] optimizes [GlassTextField] for multi-line input.
/// It exposes all standard text field and glass configuration options.
class GlassTextArea extends StatelessWidget {
  /// Creates a glass text area.
  const GlassTextArea({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.minLines = 3,
    this.maxLines = 5,
    this.onChanged,
    this.onSubmitted,
    this.onLineCountChanged,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction = TextInputAction.newline,
    this.inputFormatters,
    this.textStyle,
    this.placeholderStyle,
    this.padding = const EdgeInsets.all(16),
    this.iconAlignment = CrossAxisAlignment.center,
    this.height,
    this.minHeight,
    this.maxHeight,
    this.bottom,
    // Glass properties
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.shape = const LiquidRoundedRectangle(borderRadius: 10),
    // ── iOS 26 interaction ────────────────────────────────────────────────────────────
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.pressScale = 1.03,
    this.glowColor,
    this.glowRadius = 1.5,
    this.onTapOutside,
  });

  /// Controls the text.
  final TextEditingController? controller;

  /// Controls focus.
  final FocusNode? focusNode;

  /// Placeholder text.
  final String? placeholder;

  /// Minimum lines.
  final int minLines;

  /// Maximum lines.
  final int maxLines;

  /// Text change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback.
  final ValueChanged<String>? onSubmitted;

  /// Enabled state.
  final bool enabled;

  /// Read-only state.
  final bool readOnly;

  /// Autofocus state.
  final bool autofocus;

  /// Action button.
  final TextInputAction? textInputAction;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Text style.
  final TextStyle? textStyle;

  /// Placeholder style.
  final TextStyle? placeholderStyle;

  /// Padding. Defaults to EdgeInsets.all(16).
  final EdgeInsetsGeometry padding;

  /// Glass settings.
  final LiquidGlassSettings? settings;

  /// Own layer toggle.
  final bool useOwnLayer;

  /// Quality setting.
  final GlassQuality? quality;

  /// Shape setting.
  final LiquidShape shape;

  /// Controls which press-interaction effects are active.
  ///
  /// Mirrors [GlassTextField.interactionBehavior] — see that field for details.
  /// Defaults to [GlassInteractionBehavior.full].
  final GlassInteractionBehavior interactionBehavior;

  /// Scale factor applied when the field is pressed.
  ///
  /// Mirrors [GlassTextField.pressScale]. Defaults to `1.03`.
  final double pressScale;

  /// Colour of the directional glow. Mirrors [GlassTextField.glowColor].
  final Color? glowColor;

  /// Spread radius of the glow. Mirrors [GlassTextField.glowRadius].
  final double glowRadius;

  /// Called when user taps outside. Mirrors [GlassTextField.onTapOutside].
  final TapRegionCallback? onTapOutside;

  /// Called when rendered line count changes. Mirrors [GlassTextField.onLineCountChanged].
  final ValueChanged<int>? onLineCountChanged;

  /// Vertical alignment of prefix/suffix icons. Mirrors [GlassTextField.iconAlignment].
  final CrossAxisAlignment iconAlignment;

  /// Fixed height. Mirrors [GlassTextField.height].
  final double? height;

  /// Minimum height constraint. Mirrors [GlassTextField.minHeight].
  final double? minHeight;

  /// Maximum height constraint. Mirrors [GlassTextField.maxHeight].
  final double? maxHeight;

  /// Optional bottom panel. Mirrors [GlassTextField.bottom].
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      textStyle: textStyle,
      placeholderStyle: placeholderStyle,
      padding: padding,
      settings: settings,
      useOwnLayer: useOwnLayer,
      quality: quality,
      shape: shape,
      iconAlignment: iconAlignment,
      height: height,
      minHeight: minHeight,
      maxHeight: maxHeight,
      onLineCountChanged: onLineCountChanged,
      bottom: bottom,
      interactionBehavior: interactionBehavior,
      pressScale: pressScale,
      glowColor: glowColor,
      glowRadius: glowRadius,
      onTapOutside: onTapOutside,
    );
  }
}
