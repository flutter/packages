// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/input_chip.dart';
import 'template.dart';

class InputChipTemplateM3 extends TokenTemplateM3 {
  const InputChipTemplateM3();

  @override
  String get name => 'Input Chip';

  @override
  String get parentFilePath => 'input_chip.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends ChipThemeData {
  $className(this.context, this.isEnabled, this.isSelected)
    : super(
        elevation: ${TokenInputChip.containerElevation},
        shape: ${shape(TokenInputChip.containerShape)},
        showCheckmark: true,
      );

  final BuildContext context;
  final bool isEnabled;
  final bool isSelected;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  TextStyle? get labelStyle => ${textStyle(TokenInputChip.labelTextType, '_textTheme')}?.copyWith(
    color: isEnabled
      ? isSelected
        ? ${color(TokenInputChip.selectedLabelTextColor)}
        : ${color(TokenInputChip.unselectedLabelTextColor)}
      : ${color(TokenInputChip.disabledLabelTextColor)},
  );

  @override
  WidgetStateProperty<Color?>? get color =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenInputChip.disabledSelectedContainerColor, TokenInputChip.disabledSelectedContainerOpacity)};
      }
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenInputChip.selectedContainerColor)};
      }
      return null;
    });

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get checkmarkColor => isEnabled
    ? isSelected
      ? ${color(TokenInputChip.withLeadingIconSelectedLeadingIconColor)}
      : ${color(TokenInputChip.withLeadingIconUnselectedLeadingIconColor)}
    : ${color(TokenInputChip.withLeadingIconDisabledLeadingIconColor)};

  @override
  Color? get deleteIconColor => isEnabled
    ? isSelected
      ? ${color(TokenInputChip.withTrailingIconSelectedTrailingIconColor)}
      : ${color(TokenInputChip.withTrailingIconUnselectedTrailingIconColor)}
    : ${color(TokenInputChip.withTrailingIconDisabledTrailingIconColor)};

  @override
  BorderSide? get side => !isSelected
    ? isEnabled
      ? ${border(color(TokenInputChip.unselectedOutlineColor), width: TokenInputChip.unselectedOutlineWidth)}
      : ${border(colorWithOpacity(TokenInputChip.disabledUnselectedOutlineColor, TokenInputChip.disabledUnselectedOutlineOpacity))}
    : const BorderSide(color: Colors.transparent);

  @override
  IconThemeData? get iconTheme => IconThemeData(
    color: isEnabled
      ? isSelected
        ? ${color(TokenInputChip.withLeadingIconSelectedLeadingIconColor)}
        : ${color(TokenInputChip.withLeadingIconUnselectedLeadingIconColor)}
      : ${color(TokenInputChip.withLeadingIconDisabledLeadingIconColor)},
    size: ${TokenInputChip.withLeadingIconLeadingIconSize},
  );

  @override
  EdgeInsetsGeometry? get padding => const EdgeInsets.all(8.0);

  /// The label padding of the chip scales with the font size specified in the
  /// [labelStyle], and the system font size settings that scale font sizes
  /// globally.
  ///
  /// The chip at effective font size 14.0 starts with 8px on each side and as
  /// the font size scales up to closer to 28.0, the label padding is linearly
  /// interpolated from 8px to 4px. Once the label has a font size of 2 or
  /// higher, label padding remains 4px.
  @override
  EdgeInsetsGeometry? get labelPadding {
    final double fontSize = labelStyle?.fontSize ?? 14.0;
    final double fontSizeRatio = MediaQuery.textScalerOf(context).scale(fontSize) / 14.0;
    return EdgeInsets.lerp(
      const EdgeInsets.symmetric(horizontal: 8.0),
      const EdgeInsets.symmetric(horizontal: 4.0),
      clampDouble(fontSizeRatio - 1.0, 0.0, 1.0),
    )!;
  }
}
''';
}
