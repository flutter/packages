// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'elevated_button.dart';
/// @docImport 'floating_action_button.dart';
/// @docImport 'material.dart';
/// @docImport 'outlined_button.dart';
/// @docImport 'text_button.dart';
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'button_style_button.dart';
import 'color_scheme.dart';
import 'colors.dart';
import 'constants.dart';
import 'filled_button_theme.dart';
import 'ink_well.dart';
import 'material_state.dart';
import 'theme.dart';
import 'theme_data.dart';

part 'generated/filled_button_defaults_m3.g.dart';
part 'generated/filled_button_defaults_m3e.g.dart';
part 'generated/filled_tonal_button_defaults_m3.g.dart';
part 'generated/filled_tonal_button_defaults_m3e.g.dart';

enum _FilledButtonVariant { filled, tonal }

/// A Material Design filled button.
///
/// Filled buttons have the most visual impact after the [FloatingActionButton],
/// and should be used for important, final actions that complete a flow,
/// like **Save**, **Join now**, or **Confirm**.
///
/// A filled button is a label [child] displayed on a [Material]
/// widget. The label's [Text] and [Icon] widgets are displayed in
/// [style]'s [ButtonStyle.foregroundColor] and the button's filled
/// background is the [ButtonStyle.backgroundColor].
///
/// The filled button's default style is defined by
/// [defaultStyleOf]. The style of this filled button can be
/// overridden with its [style] parameter. The style of all filled
/// buttons in a subtree can be overridden with the
/// [FilledButtonTheme], and the style of all of the filled
/// buttons in an app can be overridden with the [Theme]'s
/// [ThemeData.filledButtonTheme] property.
///
/// The static [styleFrom] method is a convenient way to create a
/// filled button [ButtonStyle] from simple values.
///
/// If [onPressed] and [onLongPress] callbacks are null, then the
/// button will be disabled.
///
/// To create a 'filled tonal' button, use [FilledButton.tonal].
///
/// To use the Material 3 Expressive style, set
/// [FilledButtonThemeData.variant] to [StyleVariant.material3Expressive].
/// The Expressive size and shape variants can then be selected with
/// [ButtonStyle.sizeVariant] and [ButtonStyle.shapeVariant], and the button
/// becomes a toggle button when [isSelected] is non-null.
///
/// With the Material 3 style, [isSelected] updates [WidgetState.selected] and
/// the button's semantics, but the default style doesn't change the button's
/// appearance when it's selected. To show the selected state, use a [style]
/// that resolves [WidgetState.selected].
///
/// <callout-box>
///
/// This sample produces enabled and disabled filled and filled tonal
/// buttons.
///
// TODO(framework): Replace the following block with a @dartpad directive
// when it's supported. https://github.com/dart-lang/dartdoc/issues/4123
/// {@macro material_ui.dartpad_guide}
///
/// {@example /example/lib/filled_button/filled_button.0.dart#body}
///
/// </callout-box>
///
/// ## Visual density effects
///
/// The button's appearance is affected by the [VisualDensity] from the enclosing
/// [Theme] or from its [style]. Visual density adjusts the [ButtonStyle.padding]
/// and [ButtonStyle.minimumSize] to accommodate different UI densities across platforms.
/// See [VisualDensity] for more details on how it affects component layout and
/// the platform-specific defaults.
///
/// With the Material 3 Expressive style, the button ignores the [VisualDensity]
/// from the enclosing [Theme], so that each [ButtonStyle.sizeVariant] keeps
/// its height on every platform. A [VisualDensity] from its [style] or from
/// [FilledButtonThemeData.style] still applies.
///
/// See also:
///
///  * [ElevatedButton], a filled button with a shadow.
///  * [OutlinedButton], a button with an outlined border and no fill color.
///  * [TextButton], a button with no outline or fill color.
///  * <https://material.io/design/components/buttons.html>
///  * <https://m3.material.io/components/buttons>
class FilledButton extends ButtonStyleButton {
  /// Create a FilledButton.
  const FilledButton({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.isSelected,
    required super.child,
  }) : _variant = _FilledButtonVariant.filled,
       _addPadding = false;

  /// Create a filled button from [icon] and [label].
  ///
  /// The icon and label are arranged in a row with padding at the start and end
  /// and a gap between them.
  ///
  /// With the Material 3 Expressive style, the padding and the gap between the
  /// icon and the label depend on [ButtonStyle.sizeVariant]. See
  /// [defaultStyleOf].
  ///
  /// If [icon] is null, this constructor will create a [FilledButton]
  /// that doesn't display an icon.
  ///
  /// {@macro material_ui.ButtonStyle.iconAlignment}
  ///
  FilledButton.icon({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.isSelected,
    Widget? icon,
    required Widget label,
    IconAlignment? iconAlignment,
  }) : _variant = _FilledButtonVariant.filled,
       _addPadding = icon != null,
       super(
         child: icon != null
             ? _FilledButtonWithIconChild(
                 label: label,
                 icon: icon,
                 buttonStyle: style,
                 iconAlignment: iconAlignment,
               )
             : label,
       );

  /// Create a tonal variant of FilledButton.
  ///
  /// A filled tonal button is an alternative middle ground between
  /// [FilledButton] and [OutlinedButton]. They’re useful in contexts where
  /// a lower-priority button requires slightly more emphasis than an
  /// outline would give, such as "Next" in an onboarding flow.
  const FilledButton.tonal({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.isSelected,
    required super.child,
  }) : _variant = _FilledButtonVariant.tonal,
       _addPadding = false;

  /// Create a filled tonal button from [icon] and [label].
  ///
  /// The [icon] and [label] are arranged in a row with padding at the start and
  /// end and a gap between them.
  ///
  /// With the Material 3 Expressive style, the padding and the gap between the
  /// icon and the label depend on [ButtonStyle.sizeVariant]. See
  /// [defaultStyleOf].
  ///
  /// If [icon] is null, this constructor will create a [FilledButton]
  /// that doesn't display an icon.
  FilledButton.tonalIcon({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.isSelected,
    Widget? icon,
    required Widget label,
    IconAlignment? iconAlignment,
  }) : _variant = _FilledButtonVariant.tonal,
       _addPadding = icon != null,
       super(
         child: icon != null
             ? _FilledButtonWithIconChild(
                 label: label,
                 icon: icon,
                 buttonStyle: style,
                 iconAlignment: iconAlignment,
               )
             : label,
       );

  /// A static convenience method that constructs a filled button
  /// [ButtonStyle] given simple values.
  ///
  /// The [foregroundColor] and [disabledForegroundColor] colors are used
  /// to create a [WidgetStateProperty] [ButtonStyle.foregroundColor], and
  /// a derived [ButtonStyle.overlayColor] if [overlayColor] isn't specified.
  ///
  /// If [overlayColor] is specified and its value is [Colors.transparent]
  /// then the pressed/focused/hovered highlights are effectively defeated.
  /// Otherwise a [WidgetStateProperty] with the same opacities as the
  /// default is created.
  ///
  /// The [backgroundColor] and [disabledBackgroundColor] colors are
  /// used to create a [WidgetStateProperty] [ButtonStyle.backgroundColor].
  ///
  /// Similarly, the [enabledMouseCursor] and [disabledMouseCursor]
  /// parameters are used to construct [ButtonStyle.mouseCursor].
  ///
  /// The [iconColor], [disabledIconColor] are used to construct
  /// [ButtonStyle.iconColor] and [iconSize] is used to construct
  /// [ButtonStyle.iconSize].
  ///
  /// If [iconColor] is null, the button icon will use [foregroundColor]. If [foregroundColor] is also
  /// null, the button icon will use the default icon color.
  ///
  /// All of the other parameters are either used directly or used to
  /// create a [WidgetStateProperty] with a single value for all
  /// states.
  ///
  /// The [sizeVariant] and [shapeVariant] parameters are Material 3 Expressive
  /// options. They provide extra-small through extra-large sizes and round or
  /// square shapes through [ButtonStyle.sizeVariant] and
  /// [ButtonStyle.shapeVariant].
  ///
  /// When [FilledButtonThemeData.variant] is
  /// [StyleVariant.material3Expressive] and these properties are null,
  /// Material 3 Expressive [FilledButton] defaults use
  /// [ButtonSizeVariant.small] and [ButtonShapeVariant.round].
  ///
  /// All parameters default to null, by default this method returns
  /// a [ButtonStyle] that doesn't override anything.
  ///
  /// For example, to override the default text and icon colors for a
  /// [FilledButton], as well as its overlay color, with all of the
  /// standard opacity adjustments for the pressed, focused, and
  /// hovered states, one could write:
  ///
  /// ```dart
  /// FilledButton(
  ///   style: FilledButton.styleFrom(foregroundColor: Colors.green),
  ///   onPressed: () {},
  ///   child: const Text('Filled button'),
  /// );
  /// ```
  ///
  /// or for a Filled tonal variant:
  /// ```dart
  /// FilledButton.tonal(
  ///   style: FilledButton.styleFrom(foregroundColor: Colors.green),
  ///   onPressed: () {},
  ///   child: const Text('Filled tonal button'),
  /// );
  /// ```
  static ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disabledForegroundColor,
    Color? disabledBackgroundColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? iconColor,
    double? iconSize,
    IconAlignment? iconAlignment,
    Color? disabledIconColor,
    Color? overlayColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    ButtonLayerBuilder? backgroundBuilder,
    ButtonLayerBuilder? foregroundBuilder,
    ButtonSizeVariant? sizeVariant,
    ButtonShapeVariant? shapeVariant,
  }) {
    final WidgetStateProperty<Color?>? overlayColorProp = switch ((foregroundColor, overlayColor)) {
      (null, null) => null,
      (_, Color(a: 0.0)) => WidgetStatePropertyAll<Color?>(overlayColor),
      (_, final Color color) || (final Color color, _) => WidgetStateProperty<Color?>.fromMap(
        <WidgetState, Color?>{
          WidgetState.pressed: color.withOpacity(0.1),
          WidgetState.hovered: color.withOpacity(0.08),
          WidgetState.focused: color.withOpacity(0.1),
        },
      ),
    };

    return ButtonStyle(
      textStyle: MaterialStatePropertyAll<TextStyle?>(textStyle),
      backgroundColor: ButtonStyleButton.defaultColor(backgroundColor, disabledBackgroundColor),
      foregroundColor: ButtonStyleButton.defaultColor(foregroundColor, disabledForegroundColor),
      overlayColor: overlayColorProp,
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      surfaceTintColor: ButtonStyleButton.allOrNull<Color>(surfaceTintColor),
      iconColor: ButtonStyleButton.defaultColor(iconColor, disabledIconColor),
      iconSize: ButtonStyleButton.allOrNull<double>(iconSize),
      iconAlignment: iconAlignment,
      elevation: ButtonStyleButton.allOrNull(elevation),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      fixedSize: ButtonStyleButton.allOrNull<Size>(fixedSize),
      maximumSize: ButtonStyleButton.allOrNull<Size>(maximumSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      mouseCursor: WidgetStateProperty<MouseCursor?>.fromMap(<WidgetStatesConstraint, MouseCursor?>{
        WidgetState.disabled: disabledMouseCursor,
        WidgetState.any: enabledMouseCursor,
      }),
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
      backgroundBuilder: backgroundBuilder,
      foregroundBuilder: foregroundBuilder,
      sizeVariant: sizeVariant,
      shapeVariant: shapeVariant,
    );
  }

  final _FilledButtonVariant _variant;
  final bool _addPadding;

  /// Defines the button's default appearance.
  ///
  /// The button [child]'s [Text] and [Icon] widgets are rendered with
  /// the [ButtonStyle]'s foreground color. The button's [InkWell] adds
  /// the style's overlay color when the button is focused, hovered
  /// or pressed. The button's background color becomes its [Material]
  /// color.
  ///
  /// All of the ButtonStyle's defaults appear below. In this list
  /// "Theme.foo" is shorthand for `Theme.of(context).foo`. Color
  /// scheme values like "onSurface(0.38)" are shorthand for
  /// `onSurface.withOpacity(0.38)`. [WidgetStateProperty] valued
  /// properties that are not followed by a sublist have the same
  /// value for all states, otherwise the values are as specified for
  /// each state, and "others" means all other states.
  ///
  /// {@macro material_ui.elevated_button.default_font_size}
  ///
  /// The color of the [ButtonStyle.textStyle] is not used, the
  /// [ButtonStyle.foregroundColor] color is used instead.
  ///
  /// ## Material 2 defaults
  ///
  /// If [ThemeData.useMaterial3] is false, the Material 3 defaults below are
  /// used, except for `padding`:
  ///
  /// * `padding`
  ///   * `default font size <= 14` - horizontal(16)
  ///   * `14 < default font size <= 28` - lerp(horizontal(16), horizontal(8))
  ///   * `28 < default font size <= 42` - lerp(horizontal(8), horizontal(4))
  ///   * `42 < default font size` - horizontal(4)
  ///
  /// The default padding values for the [FilledButton.icon] and
  /// [FilledButton.tonalIcon] factories are slightly different:
  ///
  /// * `padding`
  ///   * `default font size <= 14` - start(12) end(16)
  ///   * `14 < default font size <= 28` - lerp(start(12) end(16), horizontal(8))
  ///   * `28 < default font size <= 42` - lerp(horizontal(8), start(8) end(4))
  ///   * `42 < default font size` - start(8) end(4)
  ///
  /// The default value for `side`, which defines the appearance of the button's
  /// outline, is null. That means that the outline is defined by the button
  /// shape's [OutlinedBorder.side]. Typically the default value of an
  /// [OutlinedBorder]'s side is [BorderSide.none], so an outline is not drawn.
  ///
  /// ## Material 3 defaults
  ///
  /// With the Material 3 style, that is, when [ThemeData.useMaterial3] is true
  /// and [FilledButtonThemeData.variant] isn't
  /// [StyleVariant.material3Expressive], the following defaults will be used:
  ///
  /// * `textStyle` - Theme.textTheme.labelLarge
  /// * `backgroundColor`
  ///   * disabled - Theme.colorScheme.onSurface(0.12)
  ///   * others
  ///     - Theme.colorScheme.primary in `FilledButton`
  ///     - Theme.colorScheme.secondaryContainer in `FilledButton.tonal`
  /// * `foregroundColor`
  ///   * disabled - Theme.colorScheme.onSurface(0.38)
  ///   * others
  ///     - Theme.colorScheme.onPrimary in `FilledButton`
  ///     - Theme.colorScheme.onSecondaryContainer in `FilledButton.tonal`
  /// * `overlayColor`
  ///   * hovered
  ///     - Theme.colorScheme.onPrimary(0.08) in `FilledButton`
  ///     - Theme.colorScheme.onSecondaryContainer(0.08) in `FilledButton.tonal`
  ///   * focused or pressed
  ///     - Theme.colorScheme.onPrimary(0.1) in `FilledButton`
  ///     - Theme.colorScheme.onSecondaryContainer(0.1) in `FilledButton.tonal`
  /// * `shadowColor` - Theme.colorScheme.shadow
  /// * `surfaceTintColor` - Colors.transparent
  /// * `elevation`
  ///   * disabled - 0
  ///   * default - 0
  ///   * hovered - 1
  ///   * focused or pressed - 0
  /// * `padding`
  ///   * `default font size <= 14` - horizontal(24)
  ///   * `14 < default font size <= 28` - lerp(horizontal(24), horizontal(12))
  ///   * `28 < default font size <= 42` - lerp(horizontal(12), horizontal(6))
  ///   * `42 < default font size` - horizontal(6)
  /// * `minimumSize` - Size(64, 40)
  /// * `fixedSize` - null
  /// * `maximumSize` - Size.infinite
  /// * `iconSize` - 18
  /// * `iconColor` - same as `foregroundColor`
  /// * `side` - null
  /// * `shape` - StadiumBorder()
  /// * `mouseCursor` - WidgetStateMouseCursor.adaptiveClickable
  /// * `visualDensity` - Theme.visualDensity
  /// * `tapTargetSize` - Theme.materialTapTargetSize
  /// * `animationDuration` - kThemeChangeDuration
  /// * `enableFeedback` - true
  /// * `alignment` - Alignment.center
  /// * `splashFactory` - Theme.splashFactory
  ///
  /// For the [FilledButton.icon] and [FilledButton.tonalIcon] factories, the
  /// start (generally the left) value of [ButtonStyle.padding] is reduced from
  /// 24 to 16.
  ///
  /// ## Material 3 Expressive defaults
  ///
  // TODO(QuncCccccc): Clean up [ThemeData.useMaterial3] once useMaterial3 is removed.
  /// With the Material 3 Expressive style, that is, when
  /// [ThemeData.useMaterial3] is true and [FilledButtonThemeData.variant] is
  /// [StyleVariant.material3Expressive], the following defaults will be used.
  /// Values listed per size are for [ButtonSizeVariant.xSmall],
  /// [ButtonSizeVariant.small], [ButtonSizeVariant.medium],
  /// [ButtonSizeVariant.large], and [ButtonSizeVariant.xLarge] respectively.
  /// The button becomes a toggle button when [isSelected] is non-null. The
  /// selected and unselected values only apply to toggle buttons.
  ///
  /// * `textStyle` - based on [ButtonStyle.sizeVariant]
  ///   * xSmall or small - Theme.textTheme.labelLarge
  ///   * medium - Theme.textTheme.titleMedium
  ///   * large - Theme.textTheme.headlineSmall
  ///   * xLarge - Theme.textTheme.headlineLarge
  /// * `backgroundColor`
  ///   * disabled - Theme.colorScheme.onSurface(0.1)
  ///   * selected
  ///     - Theme.colorScheme.primary in `FilledButton`
  ///     - Theme.colorScheme.secondary in `FilledButton.tonal`
  ///   * unselected
  ///     - Theme.colorScheme.surfaceContainer in `FilledButton`
  ///     - Theme.colorScheme.secondaryContainer in `FilledButton.tonal`
  ///   * others
  ///     - Theme.colorScheme.primary in `FilledButton`
  ///     - Theme.colorScheme.secondaryContainer in `FilledButton.tonal`
  /// * `foregroundColor`
  ///   * disabled - Theme.colorScheme.onSurface(0.38)
  ///   * selected
  ///     - Theme.colorScheme.onPrimary in `FilledButton`
  ///     - Theme.colorScheme.onSecondary in `FilledButton.tonal`
  ///   * unselected
  ///     - Theme.colorScheme.onSurfaceVariant in `FilledButton`
  ///     - Theme.colorScheme.onSecondaryContainer in `FilledButton.tonal`
  ///   * others
  ///     - Theme.colorScheme.onPrimary in `FilledButton`
  ///     - Theme.colorScheme.onSecondaryContainer in `FilledButton.tonal`
  /// * `overlayColor` - the `foregroundColor` of the same selection state
  ///   * hovered - with opacity 0.08
  ///   * focused or pressed - with opacity 0.1
  /// * `shadowColor` - Theme.colorScheme.shadow
  /// * `surfaceTintColor` - Colors.transparent
  /// * `elevation` - 0
  /// * `padding` - based on [ButtonStyle.sizeVariant]; horizontal(12),
  ///   horizontal(16), horizontal(24), horizontal(48), horizontal(64)
  /// * `minimumSize` - based on [ButtonStyle.sizeVariant]; Size(64, 32),
  ///   Size(64, 40), Size(64, 56), Size(64, 96), Size(64, 136)
  /// * `fixedSize` - null
  /// * `maximumSize` - Size.infinite
  /// * `iconSize` - based on [ButtonStyle.sizeVariant]; 20, 20, 24, 32, 40
  /// * `iconColor` - same as `foregroundColor`
  /// * `side` - null
  /// * `shape` - based on [ButtonStyle.sizeVariant], [ButtonStyle.shapeVariant],
  ///   and state
  ///   * pressed - RoundedRectangleBorder with radius 8, 8, 12, 16, 16
  ///   * selected
  ///     * round - RoundedRectangleBorder with radius 12, 12, 16, 28, 28
  ///     * square - StadiumBorder()
  ///   * others
  ///     * round - StadiumBorder()
  ///     * square - RoundedRectangleBorder with radius 12, 12, 16, 28, 28
  /// * `mouseCursor` - WidgetStateMouseCursor.adaptiveClickable
  /// * `visualDensity` - VisualDensity.standard
  /// * `tapTargetSize` - MaterialTapTargetSize.padded
  /// * `animationDuration` - kThemeChangeDuration
  /// * `enableFeedback` - true
  /// * `alignment` - Alignment.center
  /// * `splashFactory` - Theme.splashFactory
  /// * `sizeVariant` - ButtonSizeVariant.small
  /// * `shapeVariant` - ButtonShapeVariant.round
  ///
  /// For the [FilledButton.icon] and [FilledButton.tonalIcon] factories, the
  /// padding is the same, and the gap between the icon and the label is 4, 8,
  /// 8, 12, or 16 based on [ButtonStyle.sizeVariant].
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final bool useExpressive =
        Theme.of(context).useMaterial3 &&
        FilledButtonTheme.variantOf(context) == StyleVariant.material3Expressive;
    if (useExpressive) {
      final FilledButtonThemeData filledButtonTheme = FilledButtonTheme.of(context);
      final ButtonSizeVariant? effectiveSize =
          style?.sizeVariant ?? filledButtonTheme.style?.sizeVariant;
      final ButtonShapeVariant? effectiveShape =
          style?.shapeVariant ?? filledButtonTheme.style?.shapeVariant;
      // The Material 3 Expressive defaults use the same padding with or
      // without an icon.
      return switch (_variant) {
        _FilledButtonVariant.filled => _FilledButtonDefaultsM3E(
          context,
          isSelected != null,
          effectiveSize,
          effectiveShape,
        ),
        _FilledButtonVariant.tonal => _FilledTonalButtonDefaultsM3E(
          context,
          isSelected != null,
          effectiveSize,
          effectiveShape,
        ),
      };
    }

    final ButtonStyle buttonStyle = switch (_variant) {
      _FilledButtonVariant.filled => _FilledButtonDefaultsM3(context),
      _FilledButtonVariant.tonal => _FilledTonalButtonDefaultsM3(context),
    };

    if (_addPadding) {
      final bool useMaterial3 = Theme.of(context).useMaterial3;
      final double defaultFontSize =
          buttonStyle.textStyle?.resolve(const <WidgetState>{})?.fontSize ?? 14.0;
      final double effectiveTextScale =
          MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0;

      final EdgeInsetsGeometry scaledPadding = useMaterial3
          ? ButtonStyleButton.scaledPadding(
              const EdgeInsetsDirectional.fromSTEB(16, 0, 24, 0),
              const EdgeInsetsDirectional.fromSTEB(8, 0, 12, 0),
              const EdgeInsetsDirectional.fromSTEB(4, 0, 6, 0),
              effectiveTextScale,
            )
          : ButtonStyleButton.scaledPadding(
              const EdgeInsetsDirectional.fromSTEB(12, 0, 16, 0),
              const EdgeInsets.symmetric(horizontal: 8),
              const EdgeInsetsDirectional.fromSTEB(8, 0, 4, 0),
              effectiveTextScale,
            );
      return buttonStyle.copyWith(
        padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(scaledPadding),
      );
    }

    return buttonStyle;
  }

  /// Returns the [FilledButtonThemeData.style] of the closest
  /// [FilledButtonTheme] ancestor.
  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return FilledButtonTheme.of(context).style;
  }
}

EdgeInsetsGeometry _scaledPadding(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final double defaultFontSize = theme.textTheme.labelLarge?.fontSize ?? 14.0;
  final double effectiveTextScale = MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0;
  final padding1x = theme.useMaterial3 ? 24.0 : 16.0;
  return ButtonStyleButton.scaledPadding(
    EdgeInsets.symmetric(horizontal: padding1x),
    EdgeInsets.symmetric(horizontal: padding1x / 2),
    EdgeInsets.symmetric(horizontal: padding1x / 2 / 2),
    effectiveTextScale,
  );
}

class _FilledButtonWithIconChild extends StatelessWidget {
  const _FilledButtonWithIconChild({
    required this.label,
    required this.icon,
    required this.buttonStyle,
    required this.iconAlignment,
  });

  final Widget label;
  final Widget icon;
  final ButtonStyle? buttonStyle;
  final IconAlignment? iconAlignment;

  @override
  Widget build(BuildContext context) {
    final FilledButtonThemeData filledButtonTheme = FilledButtonTheme.of(context);
    final bool useExpressive =
        Theme.of(context).useMaterial3 &&
        FilledButtonTheme.variantOf(context) == StyleVariant.material3Expressive;
    final double spacing;
    if (useExpressive) {
      final ButtonSizeVariant effectiveSize =
          buttonStyle?.sizeVariant ??
          filledButtonTheme.style?.sizeVariant ??
          ButtonSizeVariant.small;
      // The icon-label space tokens are the same for filled and filled tonal
      // buttons.
      spacing = _FilledButtonDefaultsM3E.iconLabelSpace(effectiveSize);
    } else {
      final double defaultFontSize =
          buttonStyle?.textStyle?.resolve(const <WidgetState>{})?.fontSize ?? 14.0;
      final double scale =
          clampDouble(MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0, 1.0, 2.0) -
          1.0;
      spacing = lerpDouble(8, 4, scale)!;
    }
    final IconAlignment effectiveIconAlignment =
        iconAlignment ??
        filledButtonTheme.style?.iconAlignment ??
        buttonStyle?.iconAlignment ??
        IconAlignment.start;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: effectiveIconAlignment == IconAlignment.start
          ? <Widget>[icon, Flexible(child: label)]
          : <Widget>[Flexible(child: label), icon],
    );
  }
}
