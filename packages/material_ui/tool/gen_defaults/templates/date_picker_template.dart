// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/date_picker_modal.dart';
import '../data/state.dart';
import 'template.dart';

class DatePickerTemplateM3 extends TokenTemplateM3 {
  const DatePickerTemplateM3();

  @override
  String get name => 'Date Picker';

  @override
  String get parentFilePath => 'date_picker_theme.dart';

  String get _textThemePrefix => '_textTheme';

  @override
  String generateContents(String className) =>
      '''
class $className extends DatePickerThemeData {
  $className(this.context)
    : super(
        elevation: ${TokenDatePickerModal.containerElevation},
        shape: ${shape(TokenDatePickerModal.containerShape)},
        // TODO(tahatesser): Update this to use token when gen_defaults
        // supports `CircleBorder` for fully rounded corners.
        dayShape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
        yearShape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        rangePickerElevation: ${TokenDatePickerModal.rangeSelectionContainerElevation},
        rangePickerShape: ${shape(TokenDatePickerModal.rangeSelectionContainerShape)},
      );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get backgroundColor => ${color(TokenDatePickerModal.containerColor)};

  @override
  Color? get subHeaderForegroundColor => ${color(TokenDatePickerModal.weekdaysLabelTextColor)}.withOpacity(0.60);

  @override
  TextStyle? get toggleButtonTextStyle => ${textStyle(TokenDatePickerModal.rangeSelectionMonthSubheadType, _textThemePrefix)}?.apply(
    color: subHeaderForegroundColor,
  );

  @override
  ButtonStyle get cancelButtonStyle {
    return TextButton.styleFrom();
  }

  @override
  ButtonStyle get confirmButtonStyle {
    return TextButton.styleFrom();
  }

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get headerBackgroundColor => Colors.transparent;

  @override
  Color? get headerForegroundColor => ${color(TokenDatePickerModal.headerHeadlineColor)};

  @override
  TextStyle? get headerHeadlineStyle => ${textStyle(TokenDatePickerModal.headerHeadlineType, _textThemePrefix)};

  @override
  TextStyle? get headerHelpStyle => ${textStyle(TokenDatePickerModal.headerSupportingTextType, _textThemePrefix)};

  @override
  TextStyle? get weekdayStyle => ${textStyle(TokenDatePickerModal.weekdaysLabelTextType, _textThemePrefix)}?.apply(
    color: ${color(TokenDatePickerModal.weekdaysLabelTextColor)},
  );

  @override
  TextStyle? get dayStyle => ${textStyle(TokenDatePickerModal.dateLabelTextType, _textThemePrefix)};

  @override
  WidgetStateProperty<Color?>? get dayForegroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenDatePickerModal.dateSelectedLabelTextColor)};
      } else if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenDatePickerModal.dateUnselectedLabelTextColor, TokenState.disabledStateLayerOpacity)};
      }
      return ${color(TokenDatePickerModal.dateUnselectedLabelTextColor)};
    });

  @override
  WidgetStateProperty<Color?>? get dayBackgroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenDatePickerModal.dateSelectedContainerColor)};
      }
      return null;
    });

  @override
  WidgetStateProperty<Color?>? get dayOverlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenDatePickerModal.dateSelectedPressedStateLayerColor, TokenDatePickerModal.datePressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenDatePickerModal.dateSelectedHoverStateLayerColor, TokenDatePickerModal.dateHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenDatePickerModal.dateSelectedFocusStateLayerColor, TokenDatePickerModal.dateFocusStateLayerOpacity)};
        }
      } else {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenDatePickerModal.dateUnselectedPressedStateLayerColor, TokenDatePickerModal.datePressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenDatePickerModal.dateUnselectedHoverStateLayerColor, TokenDatePickerModal.dateHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenDatePickerModal.dateUnselectedFocusStateLayerColor, TokenDatePickerModal.dateFocusStateLayerOpacity)};
        }
      }
      return null;
    });

  @override
  WidgetStateProperty<Color?>? get todayForegroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenDatePickerModal.dateSelectedLabelTextColor)};
      } else if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenDatePickerModal.dateTodayLabelTextColor, TokenState.disabledStateLayerOpacity)};
      }
      return ${color(TokenDatePickerModal.dateTodayLabelTextColor)};
    });

  @override
  WidgetStateProperty<Color?>? get todayBackgroundColor => dayBackgroundColor;

  @override
  BorderSide? get todayBorder => ${border(color(TokenDatePickerModal.dateTodayContainerOutlineColor), width: TokenDatePickerModal.dateTodayContainerOutlineWidth)};

  @override
  TextStyle? get yearStyle => ${textStyle(TokenDatePickerModal.yearSelectionYearLabelTextType, _textThemePrefix)};

  @override
  WidgetStateProperty<Color?>? get yearForegroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenDatePickerModal.yearSelectionYearSelectedLabelTextColor)};
      } else if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearUnselectedLabelTextColor, TokenState.disabledStateLayerOpacity)};
      }
      return ${color(TokenDatePickerModal.yearSelectionYearUnselectedLabelTextColor)};
    });

  @override
  WidgetStateProperty<Color?>? get yearBackgroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenDatePickerModal.yearSelectionYearSelectedContainerColor)};
      }
      return null;
    });

  @override
  WidgetStateProperty<Color?>? get yearOverlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearSelectedPressedStateLayerColor, TokenDatePickerModal.yearSelectionYearPressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearSelectedHoverStateLayerColor, TokenDatePickerModal.yearSelectionYearHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearSelectedFocusStateLayerColor, TokenDatePickerModal.yearSelectionYearFocusStateLayerOpacity)};
        }
      } else {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearUnselectedPressedStateLayerColor, TokenDatePickerModal.yearSelectionYearPressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearUnselectedHoverStateLayerColor, TokenDatePickerModal.yearSelectionYearHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenDatePickerModal.yearSelectionYearUnselectedFocusStateLayerColor, TokenDatePickerModal.yearSelectionYearFocusStateLayerOpacity)};
        }
      }
      return null;
    });

  @override
  Color? get rangePickerShadowColor => Colors.transparent;

  @override
  Color? get rangePickerSurfaceTintColor => Colors.transparent;

  @override
  Color? get rangeSelectionBackgroundColor => ${color(TokenDatePickerModal.rangeSelectionActiveIndicatorContainerColor)};

  @override
  WidgetStateProperty<Color?>? get rangeSelectionOverlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenDatePickerModal.rangeSelectionDateInRangePressedStateLayerColor, TokenDatePickerModal.rangeSelectionDateInRangePressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenDatePickerModal.rangeSelectionDateInRangeHoverStateLayerColor, TokenDatePickerModal.rangeSelectionDateInRangeHoverStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenDatePickerModal.rangeSelectionDateInRangeFocusStateLayerColor, TokenDatePickerModal.rangeSelectionDateInRangeFocusStateLayerOpacity)};
      }
      return null;
    });

  @override
  Color? get rangePickerHeaderBackgroundColor => Colors.transparent;

  @override
  Color? get rangePickerHeaderForegroundColor => ${color(TokenDatePickerModal.headerHeadlineColor)};

  @override
  TextStyle? get rangePickerHeaderHeadlineStyle => ${textStyle(TokenDatePickerModal.rangeSelectionHeaderHeadlineType, _textThemePrefix)};

  @override
  TextStyle? get rangePickerHeaderHelpStyle => ${textStyle(TokenDatePickerModal.rangeSelectionMonthSubheadType, _textThemePrefix)};
}
''';
}
