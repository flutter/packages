// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library;

import 'package:flutter/widgets.dart';

import '../button_style.dart';
import '../button_style_button.dart';
import '../color_scheme.dart';
import '../colors.dart';
import '../constants.dart';
import '../icon_button_theme.dart';
import '../ink_well.dart';
import '../material_state.dart';
import '../theme.dart';
import '../theme_data.dart';

part '../generated/icon_button_m3e_defaults.g.dart';

enum _IconButtonVariant { standard, filled, filledTonal, outlined }

/// A Material Design 3 Expressive icon button.
///
/// M3 Expressive icon buttons support five size variants ([ButtonSize]),
/// shape morphing on press and selection, and updated color tokens.
///
/// Use [IconButton] for a standard icon button, [IconButton.filled] for a
/// filled icon button, [IconButton.filledTonal] for a filled tonal icon button,
/// and [IconButton.outlined] for an outlined icon button.
///
/// The button dimensions are controlled by [ButtonStyle.size]. If not
/// provided, the effective size defaults to [ButtonSize.small] (40dp), or to
/// the size specified by [IconButtonThemeData.style].
///
/// {@tool dartpad}
/// This sample shows how to use M3E [IconButton] with different sizes.
///
/// ** See code in examples/api/lib/material/icon_button/icon_button.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * <https://m3.material.io/components/icon-buttons/specs>
class IconButton extends ButtonStyleButton {
  /// Creates a Material Design 3 Expressive icon button.
  const IconButton({
    super.key,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.onPressed,
    super.onHover,
    super.onLongPress,
    super.isSelected,
    this.selectedIcon,
    super.statesController,
    required this.icon,
  }) : _variant = _IconButtonVariant.standard,
       super(
         onFocusChange: null,
         clipBehavior: Clip.none,
         child: (isSelected ?? false) ? selectedIcon ?? icon : icon,
       );

  /// Creates a filled Material Design 3 Expressive icon button.
  const IconButton.filled({
    super.key,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.onPressed,
    super.onHover,
    super.onLongPress,
    super.isSelected,
    this.selectedIcon,
    super.statesController,
    required this.icon,
  }) : _variant = _IconButtonVariant.filled,
       super(
         onFocusChange: null,
         clipBehavior: Clip.none,
         child: (isSelected ?? false) ? selectedIcon ?? icon : icon,
       );

  /// Creates a filled tonal Material Design 3 Expressive icon button.
  const IconButton.filledTonal({
    super.key,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.onPressed,
    super.onHover,
    super.onLongPress,
    super.isSelected,
    this.selectedIcon,
    super.statesController,
    required this.icon,
  }) : _variant = _IconButtonVariant.filledTonal,
       super(
         onFocusChange: null,
         clipBehavior: Clip.none,
         child: (isSelected ?? false) ? selectedIcon ?? icon : icon,
       );

  /// Creates an outlined Material Design 3 Expressive icon button.
  const IconButton.outlined({
    super.key,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.onPressed,
    super.onHover,
    super.onLongPress,
    super.isSelected,
    this.selectedIcon,
    super.statesController,
    required this.icon,
  }) : _variant = _IconButtonVariant.outlined,
       super(
         onFocusChange: null,
         clipBehavior: Clip.none,
         child: (isSelected ?? false) ? selectedIcon ?? icon : icon,
       );

  /// The icon to display inside the button.
  ///
  /// The [Icon.size] and [Icon.color] of the icon are configured automatically
  /// from the resolved [ButtonStyle] using an [IconTheme] and therefore should
  /// not be explicitly given in the icon widget.
  ///
  /// See [Icon], [ImageIcon].
  final Widget icon;

  /// The icon to display inside the button when [isSelected] is true.
  ///
  /// If this is null, [icon] is used for both selected and unselected states.
  final Widget? selectedIcon;

  final _IconButtonVariant _variant;

  /// A static convenience method that constructs an icon button [ButtonStyle]
  /// given simple values.
  static ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disabledForegroundColor,
    Color? disabledBackgroundColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? overlayColor,
    double? elevation,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    double? iconSize,
    BorderSide? side,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    ButtonSize? size,
    IconButtonWidth? iconButtonWidth,
  }) {
    final Color? overlayFallback = overlayColor ?? foregroundColor;
    WidgetStateProperty<Color?>? overlayColorProp;
    if ((hoverColor ?? focusColor ?? highlightColor ?? overlayFallback) != null) {
      overlayColorProp = switch (overlayColor) {
        Color(a: 0.0) => WidgetStatePropertyAll<Color>(overlayColor),
        _ => WidgetStateProperty<Color?>.fromMap(<WidgetState, Color?>{
          WidgetState.pressed: highlightColor ?? overlayFallback?.withOpacity(0.1),
          WidgetState.hovered: hoverColor ?? overlayFallback?.withOpacity(0.08),
          WidgetState.focused: focusColor ?? overlayFallback?.withOpacity(0.1),
        }),
      };
    }

    return ButtonStyle(
      backgroundColor: ButtonStyleButton.defaultColor(backgroundColor, disabledBackgroundColor),
      foregroundColor: ButtonStyleButton.defaultColor(foregroundColor, disabledForegroundColor),
      overlayColor: overlayColorProp,
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      surfaceTintColor: ButtonStyleButton.allOrNull<Color>(surfaceTintColor),
      elevation: ButtonStyleButton.allOrNull<double>(elevation),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      fixedSize: ButtonStyleButton.allOrNull<Size>(fixedSize),
      maximumSize: ButtonStyleButton.allOrNull<Size>(maximumSize),
      iconSize: ButtonStyleButton.allOrNull<double>(iconSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      mouseCursor: disabledMouseCursor == null && enabledMouseCursor == null
          ? null
          : WidgetStateProperty<MouseCursor?>.fromMap(<WidgetStatesConstraint, MouseCursor?>{
              WidgetState.disabled: disabledMouseCursor,
              WidgetState.any: enabledMouseCursor,
            }),
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
      size: size,
      iconButtonWidth: iconButtonWidth,
    );
  }

  /// Resolves the effective [ButtonSize] from widget, theme, and defaults.
  ButtonSize _resolveSize(BuildContext context) {
    return style?.size ?? IconButtonTheme.of(context).style?.size ?? ButtonSize.small;
  }

  /// Resolves the effective [IconButtonWidth] from widget, theme, and defaults.
  IconButtonWidth _resolveWidth(BuildContext context) {
    return style?.iconButtonWidth ??
        IconButtonTheme.of(context).style?.iconButtonWidth ??
        IconButtonWidth.standard;
  }

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ButtonSize effectiveSize = _resolveSize(context);
    final IconButtonWidth effectiveWidth = _resolveWidth(context);
    final ButtonStyle style = switch (_variant) {
      _IconButtonVariant.filled => _M3EFilledIconButtonDefaults(
        context,
        isSelected != null,
        effectiveSize,
        effectiveWidth,
      ),
      _IconButtonVariant.filledTonal => _M3EFilledTonalIconButtonDefaults(
        context,
        isSelected != null,
        effectiveSize,
        effectiveWidth,
      ),
      _IconButtonVariant.outlined => _M3EOutlinedIconButtonDefaults(
        context,
        isSelected != null,
        effectiveSize,
        effectiveWidth,
      ),
      _IconButtonVariant.standard => _M3EIconButtonDefaults(
        context,
        isSelected != null,
        effectiveSize,
        effectiveWidth,
      ),
    };
    return style;
  }

  /// Returns the [IconButtonThemeData.style] of the closest [IconButtonTheme] ancestor.
  /// The color and icon size can also be configured by the [IconTheme] if the same property
  /// has a null value in [IconButtonTheme]. However, if any of the properties exist
  /// in both [IconButtonTheme] and [IconTheme], [IconTheme] will be overridden.
  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final isDefaultSize = iconTheme.size == const IconThemeData.fallback().size;
    final bool isDefaultColor = identical(iconTheme.color, switch (Theme.brightnessOf(context)) {
      Brightness.light => kDefaultIconDarkColor,
      Brightness.dark => kDefaultIconLightColor,
    });

    final ButtonStyle iconThemeStyle = IconButton.styleFrom(
      foregroundColor: isDefaultColor ? null : iconTheme.color,
      iconSize: isDefaultSize ? null : iconTheme.size,
    );

    return IconButtonTheme.of(context).style?.merge(iconThemeStyle) ?? iconThemeStyle;
  }
}
