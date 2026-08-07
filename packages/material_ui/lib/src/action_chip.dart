// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'choice_chip.dart';
/// @docImport 'circle_avatar.dart';
/// @docImport 'elevated_button.dart';
/// @docImport 'input_chip.dart';
/// @docImport 'material.dart';
/// @docImport 'outlined_button.dart';
/// @docImport 'text_button.dart';
library;

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/widgets.dart';

import 'chip.dart';
import 'chip_theme.dart';
import 'color_scheme.dart';
import 'colors.dart';
import 'debug.dart';
import 'text_theme.dart';
import 'theme.dart';
import 'theme_data.dart';

part 'generated/action_chip_defaults_m3.g.dart';

enum _ChipVariant { flat, elevated }

/// A Material Design action chip.
///
/// Action chips are a set of options which trigger an action related to primary
/// content. Action chips should appear dynamically and contextually in a UI.
///
/// Action chips can be tapped to trigger an action or show progress and
/// confirmation. For Material 3, a disabled state is supported for Action
/// chips and is specified with [onPressed] being null. For previous versions
/// of Material Design, it is recommended to remove the Action chip from
/// the interface entirely rather than display a disabled chip.
///
/// Action chips are displayed after primary content, such as below a card or
/// persistently at the bottom of a screen.
///
/// The material button widgets, [ElevatedButton], [TextButton], and
/// [OutlinedButton], are an alternative to action chips, which should appear
/// statically and consistently in a UI.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// {@tool dartpad}
/// This example shows how to create an [ActionChip] with a leading icon.
/// The icon is updated when the [ActionChip] is pressed.
///
/// ** See code in examples/api/lib/material/action_chip/action_chip.0.dart **
/// {@end-tool}
///
/// ## Material Design 3
///
/// [ActionChip] can be used for both the Assist and Suggestion chips from
/// Material Design 3. If [ThemeData.useMaterial3] is true, then [ActionChip]
/// will be styled to match the Material Design 3 Assist and Suggestion chips.
///
/// ### Creating an Assist chip
///
/// Assist chips are used to provide a quick way to perform an action.
/// To create an Action chip, set the icon property to the icon
/// that represents the action and set the label to the name of the action.
///
///
/// ### Creating a Suggestion chip
///
/// Suggestion chips usually display generated suggestions for the user,
/// like a suggested response to a message.
///
/// To create a Suggestion chip, set the label to the suggestion
/// and don't set the icon property.
//
///
/// See also:
///
///  * [Chip], a chip that displays information and can be deleted.
///  * [InputChip], a chip that represents a complex piece of information, such
///    as an entity (person, place, or thing) or conversational text, in a
///    compact form.
///  * [ChoiceChip], allows a single selection from a set of options. Choice
///    chips contain related descriptive text or categories.
///  * [CircleAvatar], which shows images or initials of people.
///  * [Wrap], A widget that displays its children in multiple horizontal or
///    vertical runs.
///  * <https://material.io/design/components/chips.html>
class ActionChip extends StatelessWidget
    implements ChipAttributes, TappableChipAttributes, DisabledChipAttributes {
  /// Create a chip that acts like a button.
  ///
  /// The [label], [autofocus], and [clipBehavior] arguments must not be null.
  /// When [onPressed] is null, the [ActionChip] will be disabled. The [pressElevation]
  /// and [elevation] must be null or non-negative. Typically, [pressElevation]
  /// is greater than [elevation].
  const ActionChip({
    super.key,
    this.avatar,
    required this.label,
    this.labelStyle,
    this.labelPadding,
    this.onPressed,
    this.pressElevation,
    this.tooltip,
    this.side,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.backgroundColor,
    this.disabledColor,
    this.padding,
    this.visualDensity,
    this.materialTapTargetSize,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconTheme,
    this.avatarBoxConstraints,
    this.chipAnimationStyle,
    this.mouseCursor,
  }) : assert(pressElevation == null || pressElevation >= 0.0),
       assert(elevation == null || elevation >= 0.0),
       _chipVariant = _ChipVariant.flat;

  /// Create an elevated chip that acts like a button.
  ///
  /// The [label], [autofocus], and [clipBehavior] arguments must not be null.
  /// When [onPressed] is null, the [ActionChip] will be disabled. The [pressElevation]
  /// and [elevation] must be null or non-negative. Typically, [pressElevation]
  /// is greater than [elevation].
  const ActionChip.elevated({
    super.key,
    this.avatar,
    required this.label,
    this.labelStyle,
    this.labelPadding,
    this.onPressed,
    this.pressElevation,
    this.tooltip,
    this.side,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.backgroundColor,
    this.disabledColor,
    this.padding,
    this.visualDensity,
    this.materialTapTargetSize,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconTheme,
    this.avatarBoxConstraints,
    this.chipAnimationStyle,
    this.mouseCursor,
  }) : assert(pressElevation == null || pressElevation >= 0.0),
       assert(elevation == null || elevation >= 0.0),
       _chipVariant = _ChipVariant.elevated;

  @override
  final Widget? avatar;
  @override
  final Widget label;
  @override
  final TextStyle? labelStyle;
  @override
  final EdgeInsetsGeometry? labelPadding;
  @override
  final VoidCallback? onPressed;
  @override
  final double? pressElevation;
  @override
  final String? tooltip;
  @override
  final BorderSide? side;
  @override
  final OutlinedBorder? shape;
  @override
  final Clip clipBehavior;
  @override
  final FocusNode? focusNode;
  @override
  final bool autofocus;
  @override
  final WidgetStateProperty<Color?>? color;
  @override
  final Color? backgroundColor;
  @override
  final Color? disabledColor;
  @override
  final EdgeInsetsGeometry? padding;
  @override
  final VisualDensity? visualDensity;
  @override
  final MaterialTapTargetSize? materialTapTargetSize;
  @override
  final double? elevation;
  @override
  final Color? shadowColor;
  @override
  final Color? surfaceTintColor;
  @override
  final IconThemeData? iconTheme;
  @override
  final BoxConstraints? avatarBoxConstraints;
  @override
  final ChipAnimationStyle? chipAnimationStyle;
  @override
  final MouseCursor? mouseCursor;

  @override
  bool get isEnabled => onPressed != null;

  final _ChipVariant _chipVariant;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ChipThemeData? defaults = Theme.of(context).useMaterial3
        ? _ActionChipDefaultsM3(context, isEnabled, _chipVariant)
        : null;
    return RawChip(
      defaultProperties: defaults,
      avatar: avatar,
      label: label,
      onPressed: onPressed,
      pressElevation: pressElevation,
      tooltip: tooltip,
      labelStyle: labelStyle,
      color: color,
      backgroundColor: backgroundColor,
      side: side,
      shape: shape,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      disabledColor: disabledColor,
      padding: padding,
      visualDensity: visualDensity,
      isEnabled: isEnabled,
      labelPadding: labelPadding,
      materialTapTargetSize: materialTapTargetSize,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      iconTheme: iconTheme,
      avatarBoxConstraints: avatarBoxConstraints,
      chipAnimationStyle: chipAnimationStyle,
      mouseCursor: mouseCursor,
    );
  }
}
