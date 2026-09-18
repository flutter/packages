// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/filter_chip.dart';
import 'template.dart';

class FilterChipTemplateM3 extends TokenTemplateM3 {
  const FilterChipTemplateM3();

  @override
  String get name => 'Filter Chip';

  @override
  String get parentFilePath => 'filter_chip.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends ChipThemeData {
  $className(
    this.context,
    this.isEnabled,
    this.isSelected,
    this._chipVariant,
  ) : super(
        shape: ${shape(TokenFilterChip.containerShape)},
        showCheckmark: true,
      );

  final BuildContext context;
  final bool isEnabled;
  final bool isSelected;
  final _ChipVariant _chipVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  double? get elevation => _chipVariant == _ChipVariant.flat
    ? ${TokenFilterChip.flatContainerElevation}
    : isEnabled ? ${TokenFilterChip.elevatedContainerElevation} : ${TokenFilterChip.elevatedDisabledContainerElevation};

  @override
  double? get pressElevation => ${TokenFilterChip.elevatedPressedContainerElevation};

  @override
  TextStyle? get labelStyle => ${textStyle(TokenFilterChip.labelTextType, '_textTheme')}?.copyWith(
    color: isEnabled
      ? isSelected
        ? ${color(TokenFilterChip.selectedLabelTextColor)}
        : ${color(TokenFilterChip.unselectedLabelTextColor)}
      : ${color(TokenFilterChip.disabledLabelTextColor)},
  );

  @override
  WidgetStateProperty<Color?>? get color =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) {
        return _chipVariant == _ChipVariant.flat
          ? ${colorWithOpacity(TokenFilterChip.flatDisabledSelectedContainerColor, TokenFilterChip.flatDisabledSelectedContainerOpacity)}
          : ${colorWithOpacity(TokenFilterChip.elevatedDisabledContainerColor, TokenFilterChip.elevatedDisabledContainerOpacity)};
      }
      if (states.contains(WidgetState.disabled)) {
        return _chipVariant == _ChipVariant.flat
          ? null
          : ${colorWithOpacity(TokenFilterChip.elevatedDisabledContainerColor, TokenFilterChip.elevatedDisabledContainerOpacity)};
      }
      if (states.contains(WidgetState.selected)) {
        return _chipVariant == _ChipVariant.flat
          ? ${color(TokenFilterChip.flatSelectedContainerColor)}
          : ${color(TokenFilterChip.elevatedSelectedContainerColor)};
      }
      return _chipVariant == _ChipVariant.flat
        ? null
        : ${color(TokenFilterChip.elevatedUnselectedContainerColor)};
    });

  @override
  Color? get shadowColor => _chipVariant == _ChipVariant.flat
    ? Colors.transparent
    : ${color(TokenFilterChip.elevatedContainerShadowColor)};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get checkmarkColor => isEnabled
    ? isSelected
      ? ${color(TokenFilterChip.withLeadingIconSelectedLeadingIconColor)}
      : ${color(TokenFilterChip.withLeadingIconUnselectedLeadingIconColor)}
    : ${color(TokenFilterChip.withLeadingIconDisabledLeadingIconColor)};

  @override
  Color? get deleteIconColor => isEnabled
    ? isSelected
      ? ${color(TokenFilterChip.withTrailingIconSelectedTrailingIconColor)}
      : ${color(TokenFilterChip.withTrailingIconUnselectedTrailingIconColor)}
    : ${color(TokenFilterChip.withTrailingIconDisabledTrailingIconColor)};

  @override
  BorderSide? get side => _chipVariant == _ChipVariant.flat && !isSelected
    ? isEnabled
      ? ${border(color(TokenFilterChip.flatUnselectedOutlineColor), width: TokenFilterChip.flatUnselectedOutlineWidth)}
      : ${border(colorWithOpacity(TokenFilterChip.flatDisabledUnselectedOutlineColor, TokenFilterChip.flatDisabledUnselectedOutlineOpacity))}
    : const BorderSide(color: Colors.transparent);

  @override
  IconThemeData? get iconTheme => IconThemeData(
    color: isEnabled
      ? isSelected
        ? ${color(TokenFilterChip.withLeadingIconSelectedLeadingIconColor)}
        : ${color(TokenFilterChip.withLeadingIconUnselectedLeadingIconColor)}
      : ${color(TokenFilterChip.withLeadingIconDisabledLeadingIconColor)},
    size: ${TokenFilterChip.withIconIconSize},
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
