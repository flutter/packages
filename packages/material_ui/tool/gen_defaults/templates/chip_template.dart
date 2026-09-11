// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/filter_chip.dart';
import 'template.dart';

class ChipTemplateM3 extends TokenTemplateM3 {
  const ChipTemplateM3();

  @override
  String get name => 'Chip';

  @override
  String get parentFilePath => 'chip.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends ChipThemeData {
  $className(this.context, this.isEnabled)
    : super(
        elevation: ${number(TokenFilterChip.flatContainerElevation)},
        shape: ${shape(TokenFilterChip.containerShape)},
        showCheckmark: true,
      );

  final BuildContext context;
  final bool isEnabled;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  TextStyle? get labelStyle => ${textStyle(TokenFilterChip.labelTextType, '_textTheme')}?.copyWith(
    color: isEnabled
      ? ${color(TokenFilterChip.unselectedLabelTextColor, '_colors')}
      : ${color(TokenFilterChip.disabledLabelTextColor, '_colors')},
  );

  @override
  WidgetStateProperty<Color?>? get color => null; // Subclasses override this getter

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get checkmarkColor => null;

  @override
  Color? get deleteIconColor => isEnabled
    ? ${color(TokenFilterChip.withTrailingIconUnselectedTrailingIconColor, '_colors')}
    : ${color(TokenFilterChip.withTrailingIconDisabledTrailingIconColor, '_colors')};

  @override
  BorderSide? get side => isEnabled
    ? ${border(color(TokenFilterChip.flatUnselectedOutlineColor, '_colors'), width: TokenFilterChip.flatUnselectedOutlineWidth)}
    : ${border(colorWithOpacity(TokenFilterChip.flatDisabledUnselectedOutlineColor, TokenFilterChip.flatDisabledUnselectedOutlineOpacity, '_colors'))};

  @override
  IconThemeData? get iconTheme => IconThemeData(
    color: isEnabled
      ? ${color(TokenFilterChip.withLeadingIconUnselectedLeadingIconColor, '_colors')}
      : ${color(TokenFilterChip.withLeadingIconDisabledLeadingIconColor, '_colors')},
    size: ${number(TokenFilterChip.withIconIconSize)},
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
