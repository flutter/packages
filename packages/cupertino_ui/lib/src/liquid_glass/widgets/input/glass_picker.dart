import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_glass.dart';
import '../../theme/glass_theme_helpers.dart';

/// A glass picker widget following iOS design patterns.
///
/// [GlassPicker] displays a selected value in a glass container. Tapping it
/// opens a standard Cupertino picker in a modal bottom sheet.
class GlassPicker extends StatelessWidget {
  /// Creates a glass picker.
  const GlassPicker({
    required this.value,
    this.onTap,
    super.key,
    this.placeholder = 'Select',
    this.icon,
    this.height = 48.0,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textStyle,
    this.placeholderStyle,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.shape = const LiquidRoundedRectangle(borderRadius: 10),
    this.semanticLabel,
  });

  /// The currently selected text value.
  final String? value;

  /// Placeholder when value is null.
  final String placeholder;

  /// Icon widget to display at the end (defaults to chevron down).
  final Widget? icon;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Height of the picker field.
  ///
  /// This is the field's minimum height: with a large system text size the
  /// field grows to fit the text instead of clipping it.
  final double height;

  /// Optional width.
  final double? width;

  /// Padding.
  final EdgeInsetsGeometry padding;

  /// Style for the value text.
  final TextStyle? textStyle;

  /// Style for the placeholder text.
  final TextStyle? placeholderStyle;

  /// Glass settings.
  final LiquidGlassSettings? settings;

  /// Whether to use its own layer (true) or grouped (false).
  final bool useOwnLayer;

  /// Quality.
  final GlassQuality? quality;

  /// Shape of the container.
  final LiquidShape shape;

  /// What the picker chooses, announced by screen readers (for example
  /// "Size"), with the current [value] read as the value.
  ///
  /// When null, the visible text ([value] or [placeholder]) is the label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Inherit quality from parent layer if not explicitly set
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
    );

    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    final effectiveTextStyle =
        TextStyle(fontSize: 16, color: labelColor).merge(textStyle);

    final effectivePlaceholderStyle =
        TextStyle(fontSize: 16, color: secondaryColor).merge(placeholderStyle);

    // A minimum height rather than a fixed one, so the value survives a
    // large system text size (SC 1.4.4); at the default scale it is the same.
    final child = Container(
      constraints: BoxConstraints(minHeight: height),
      width: width,
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value ?? placeholder,
              style: value != null
                  ? effectiveTextStyle
                  : effectivePlaceholderStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconTheme(
            data: IconThemeData(size: 16, color: secondaryColor),
            child: icon ?? const Icon(CupertinoIcons.chevron_up_chevron_down),
          ),
        ],
      ),
    );

    final glassWidget = AdaptiveGlass(
      shape: shape,
      settings: settings ?? const LiquidGlassSettings(blur: 8),
      quality: effectiveQuality,
      useOwnLayer: useOwnLayer,
      child: child,
    );

    final shownText = value ?? placeholder;
    // One node for the whole field: a button named by [semanticLabel] (or the
    // visible text) whose value is the current selection. The text below is
    // excluded so it is not read a second time.
    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      label: semanticLabel ?? shownText,
      value: semanticLabel != null ? shownText : null,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: glassWidget,
      ),
    );
  }

  /// Helper to show a bottom sheet picker.
  static Future<T?> showSheet<T>({
    required BuildContext context,
    required List<T> items,
    required Widget Function(T item) itemBuilder,
    String? title,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            if (title != null)
              Container(
                // Minimum, not fixed, so a scaled-up title is not clipped.
                constraints: const BoxConstraints(minHeight: 50),
                alignment: Alignment.center,
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            Expanded(
              child: CupertinoPicker.builder(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  // Handle live update if needed
                },
                itemBuilder: (context, index) {
                  if (index < 0 || index >= items.length) return null;
                  return itemBuilder(items[index]);
                },
                childCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
