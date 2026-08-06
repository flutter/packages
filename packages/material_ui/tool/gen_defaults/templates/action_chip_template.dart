// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/assist_chip.dart';
import 'template.dart';

class ActionChipTemplateM3 extends TokenTemplateM3 {
  const ActionChipTemplateM3();
  @override
  String get name => 'Action Chip';

  @override
  String get parentFilePath => 'action_chip.dart';
  
  String get _colorSchemePrefix => '_colors';

  String get _textThemePrefix => '_textTheme';

  @override
  String generateContents(String className) =>
      '''
class $className extends ChipThemeData {
  $className(this.context, this.isEnabled, this._chipVariant)
    : super(
        shape: ${shape(TokenAssistChip.containerShape)},
        showCheckmark: true,
      );

  final BuildContext context;
  final bool isEnabled;
  final _ChipVariant _chipVariant;
  late final ColorScheme $_colorSchemePrefix = Theme.of(context).colorScheme;
  late final TextTheme $_textThemePrefix = Theme.of(context).textTheme;

  @override
  double? get elevation => _chipVariant == _ChipVariant.flat
    ? ${TokenAssistChip.flatContainerElevation}
    : isEnabled ? ${TokenAssistChip.elevatedContainerElevation} : ${TokenAssistChip.elevatedDisabledContainerElevation};

  @override
  double? get pressElevation => ${TokenAssistChip.elevatedPressedContainerElevation};

  @override
  TextStyle? get labelStyle => ${textStyle(TokenAssistChip.labelTextType, _textThemePrefix)}?.copyWith(
    color: isEnabled
      ? ${color(TokenAssistChip.labelTextColor, _colorSchemePrefix)}
      : ${color(TokenAssistChip.disabledLabelTextColor, _colorSchemePrefix)},
  );

  @override
  WidgetStateProperty<Color?>? get color =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _chipVariant == _ChipVariant.flat
          ? null
          : ${colorWithOpacity(TokenAssistChip.elevatedDisabledContainerColor, TokenAssistChip.elevatedDisabledContainerOpacity, _colorSchemePrefix)};
      }
      return _chipVariant == _ChipVariant.flat
        ? null
        : ${color(TokenAssistChip.elevatedContainerColor, _colorSchemePrefix)};
    });

  @override
  Color? get shadowColor => _chipVariant == _ChipVariant.flat
    ? Colors.transparent
    : ${color(TokenAssistChip.elevatedContainerShadowColor, _colorSchemePrefix)};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get checkmarkColor => null;

  @override
  Color? get deleteIconColor => null;

  @override
  BorderSide? get side => _chipVariant == _ChipVariant.flat
    ? isEnabled
        ? ${border(color(TokenAssistChip.flatOutlineColor, _colorSchemePrefix), width: TokenAssistChip.flatOutlineWidth)}
        : ${border(colorWithOpacity(TokenAssistChip.flatDisabledOutlineColor, TokenAssistChip.flatDisabledOutlineOpacity, _colorSchemePrefix))}
    : const BorderSide(color: Colors.transparent);

  @override
  IconThemeData? get iconTheme => IconThemeData(
    color: isEnabled
      ? ${color(TokenAssistChip.withIconIconColor, _colorSchemePrefix)}
      : ${color(TokenAssistChip.withIconDisabledIconColor, _colorSchemePrefix)},
    size: ${TokenAssistChip.withIconIconSize},
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
