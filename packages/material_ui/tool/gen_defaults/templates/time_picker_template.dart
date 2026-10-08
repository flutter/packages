// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/time_picker.dart';
import 'template.dart';

class TimePickerTemplateM3 extends TokenTemplateM3 {
  const TimePickerTemplateM3();

  static const String tokenGroup = 'md.comp.time-picker';
  static const String hourMinuteComponent = '$tokenGroup.time-selector';
  static const String dayPeriodComponent = '$tokenGroup.period-selector';
  static const String dialComponent = '$tokenGroup.clock-dial';
  static const String variant = '';

  @override
  String get name => 'Time Picker';

  @override
  String get parentFilePath => 'time_picker.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends _TimePickerDefaults {
  $className(this.context, { this.entryMode = TimePickerEntryMode.dial });

  final BuildContext context;
  final TimePickerEntryMode entryMode;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color get backgroundColor {
    return ${color(TokenTimePicker.containerColor)};
  }

  @override
  ButtonStyle get cancelButtonStyle {
    return TextButton.styleFrom();
  }

  @override
  ButtonStyle get confirmButtonStyle {
    return TextButton.styleFrom();
  }

  @override
  BorderSide get dayPeriodBorderSide {
    return ${border(color(TokenTimePicker.periodSelectorOutlineColor), width: TokenTimePicker.periodSelectorOutlineWidth)};
  }

  @override
  Color get dayPeriodColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenTimePicker.periodSelectorSelectedContainerColor)};
      }
      // The unselected day period should match the overall picker dialog color.
      // Making it transparent enables that without being redundant and allows
      // the optional elevation overlay for dark mode to be visible.
      return Colors.transparent;
    });
  }

  @override
  OutlinedBorder get dayPeriodShape {
    return ${shape(TokenTimePicker.periodSelectorContainerShape)}.copyWith(side: dayPeriodBorderSide);
  }

  @override
  Size get dayPeriodPortraitSize {
    return const Size(${number(TokenTimePicker.periodSelectorVerticalContainerWidth)}, ${number(TokenTimePicker.periodSelectorVerticalContainerHeight)});
  }

  @override
  Size get dayPeriodLandscapeSize {
    return const Size(${number(TokenTimePicker.periodSelectorHorizontalContainerWidth)}, ${number(TokenTimePicker.periodSelectorHorizontalContainerHeight)});
  }

  @override
  Size get dayPeriodInputSize {
    // Input size is eight pixels smaller than the portrait size in the spec,
    // but there's not token for it yet.
    return Size(dayPeriodPortraitSize.width, dayPeriodPortraitSize.height - 8);
  }

  @override
  Color get dayPeriodTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.focused)) {
          return ${color(TokenTimePicker.periodSelectorSelectedFocusLabelTextColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(TokenTimePicker.periodSelectorSelectedHoverLabelTextColor)};
        }
        if (states.contains(WidgetState.pressed)) {
          return ${color(TokenTimePicker.periodSelectorSelectedPressedLabelTextColor)};
        }
        return ${color(TokenTimePicker.periodSelectorSelectedLabelTextColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenTimePicker.periodSelectorUnselectedFocusLabelTextColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenTimePicker.periodSelectorUnselectedHoverLabelTextColor)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenTimePicker.periodSelectorUnselectedPressedLabelTextColor)};
      }
      return ${color(TokenTimePicker.periodSelectorUnselectedLabelTextColor)};
    });
  }

  @override
  TextStyle get dayPeriodTextStyle {
    return ${textStyle(TokenTimePicker.periodSelectorLabelTextType, '_textTheme')}!.copyWith(color: dayPeriodTextColor);
  }

  @override
  Color get dialBackgroundColor {
    return ${color(TokenTimePicker.clockDialColor)};
  }

  @override
  Color get dialHandColor {
    return ${color(TokenTimePicker.clockDialSelectorHandleContainerColor)};
  }

  @override
  Size get dialSize {
    return const Size.square(${number(TokenTimePicker.clockDialContainerSize)});
  }

  @override
  double get handWidth {
    return ${number(TokenTimePicker.clockDialSelectorTrackContainerWidth)};
  }

  @override
  double get dotRadius {
    return ${number(TokenTimePicker.clockDialSelectorHandleContainerSize)} / 2;
  }

  @override
  double get centerRadius {
    return ${number(TokenTimePicker.clockDialSelectorCenterContainerSize)} / 2;
  }

  @override
  Color get dialTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ${color(TokenTimePicker.clockDialSelectedLabelTextColor)};
      }
      return ${color(TokenTimePicker.clockDialUnselectedLabelTextColor)};
    });
  }

  @override
  TextStyle get dialTextStyle {
    return ${textStyle(TokenTimePicker.clockDialLabelTextType, '_textTheme')}!;
  }

  @override
  double get elevation {
    return ${number(TokenTimePicker.containerElevation)};
  }

  @override
  Color get entryModeIconColor {
    return _colors.onSurface;
  }

  @override
  TextStyle get helpTextStyle {
    return WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
      final TextStyle textStyle = ${textStyle(TokenTimePicker.headlineType, '_textTheme')}!;
      return textStyle.copyWith(color: ${color(TokenTimePicker.headlineColor)});
    });
  }

  @override
  EdgeInsetsGeometry get padding {
    return const EdgeInsets.all(24);
  }

  @override
  Color get hourMinuteColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        Color overlayColor = ${color(TokenTimePicker.timeSelectorSelectedContainerColor)};
        if (states.contains(WidgetState.pressed)) {
          overlayColor = ${color(TokenTimePicker.timeSelectorSelectedPressedStateLayerColor)};
        } else if (states.contains(WidgetState.hovered)) {
          overlayColor = ${colorWithOpacity(TokenTimePicker.timeSelectorSelectedHoverStateLayerColor, TokenTimePicker.timeSelectorHoverStateLayerOpacity)};
        } else if (states.contains(WidgetState.focused)) {
          overlayColor = ${colorWithOpacity(TokenTimePicker.timeSelectorSelectedFocusStateLayerColor, TokenTimePicker.timeSelectorFocusStateLayerOpacity)};
        }
        return Color.alphaBlend(overlayColor, ${color(TokenTimePicker.timeSelectorSelectedContainerColor)});
      } else {
        Color overlayColor = ${color(TokenTimePicker.timeSelectorUnselectedContainerColor)};
        if (states.contains(WidgetState.pressed)) {
          overlayColor = ${color(TokenTimePicker.timeSelectorUnselectedPressedStateLayerColor)};
        } else if (states.contains(WidgetState.hovered)) {
          overlayColor = ${colorWithOpacity(TokenTimePicker.timeSelectorUnselectedHoverStateLayerColor, TokenTimePicker.timeSelectorHoverStateLayerOpacity)};
        } else if (states.contains(WidgetState.focused)) {
          overlayColor = ${colorWithOpacity(TokenTimePicker.timeSelectorUnselectedFocusStateLayerColor, TokenTimePicker.timeSelectorFocusStateLayerOpacity)};
        }
        return Color.alphaBlend(overlayColor, ${color(TokenTimePicker.timeSelectorUnselectedContainerColor)});
      }
    });
  }

  @override
  ShapeBorder get hourMinuteShape {
    return ${shape(TokenTimePicker.timeSelectorContainerShape)};
  }

  @override
  Size get hourMinuteSize {
    return const Size(${number(TokenTimePicker.timeSelectorContainerWidth)}, ${number(TokenTimePicker.timeSelectorContainerHeight)});
  }

  @override
  Size get hourMinuteSize24Hour {
    return Size(${number(TokenTimePicker.timeSelector24hVerticalContainerWidth)}, hourMinuteSize.height);
  }

  @override
  Size get hourMinuteInputSize {
    // Input size is eight pixels smaller than the regular size in the spec, but
    // there's not token for it yet.
    return Size(hourMinuteSize.width, hourMinuteSize.height - 8);
  }

  @override
  Size get hourMinuteInputSize24Hour {
    // Input size is eight pixels smaller than the regular size in the spec, but
    // there's not token for it yet.
    return Size(hourMinuteSize24Hour.width, hourMinuteSize24Hour.height - 8);
  }

  @override
  Color get hourMinuteTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      return _hourMinuteTextColor.resolve(states);
    });
  }

  WidgetStateProperty<Color> get _hourMinuteTextColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${color(TokenTimePicker.timeSelectorSelectedPressedLabelTextColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(TokenTimePicker.timeSelectorSelectedHoverLabelTextColor)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${color(TokenTimePicker.timeSelectorSelectedFocusLabelTextColor)};
        }
        return ${color(TokenTimePicker.timeSelectorSelectedLabelTextColor)};
      } else {
        // unselected
        if (states.contains(WidgetState.pressed)) {
          return ${color(TokenTimePicker.timeSelectorUnselectedPressedLabelTextColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(TokenTimePicker.timeSelectorUnselectedHoverLabelTextColor)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${color(TokenTimePicker.timeSelectorUnselectedFocusLabelTextColor)};
        }
        return ${color(TokenTimePicker.timeSelectorUnselectedLabelTextColor)};
      }
    });
  }

  @override
  TextStyle get hourMinuteTextStyle {
    return WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
      // TODO(tahatesser): Update this when https://github.com/flutter/flutter/issues/131247 is fixed.
      // This is using the correct text style from Material 3 spec.
      // https://m3.material.io/components/time-pickers/specs#fd0b6939-edab-4058-82e1-93d163945215
      return switch (entryMode) {
        TimePickerEntryMode.dial || TimePickerEntryMode.dialOnly
          => _textTheme.displayLarge!.copyWith(color: _hourMinuteTextColor.resolve(states)),
        TimePickerEntryMode.input || TimePickerEntryMode.inputOnly
          => _textTheme.displayMedium!.copyWith(color: _hourMinuteTextColor.resolve(states)),
      };
    });
  }

  @override
  InputDecorationThemeData get inputDecorationTheme {
    // This is NOT correct, but there's no token for
    // 'time-input.container.shape', so this is using the radius from the shape
    // for the hour/minute selector. It's a BorderRadiusGeometry, so we have to
    // resolve it before we can use it.
    final BorderRadius selectorRadius = ${shape(TokenTimePicker.timeSelectorContainerShape)}
      .borderRadius
      .resolve(Directionality.of(context));
    return InputDecorationThemeData(
      contentPadding: EdgeInsets.zero,
      filled: true,
      // This should be derived from a token, but there isn't one for 'time-input'.
      fillColor: hourMinuteColor,
      // This should be derived from a token, but there isn't one for 'time-input'.
      focusColor: _colors.primaryContainer,
      enabledBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.primary, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      hintStyle: hourMinuteTextStyle.copyWith(color: _colors.onSurface.withOpacity(0.36)),
      // Prevent the error text from appearing.
      // TODO(rami-a): Remove this workaround once
      // https://github.com/flutter/flutter/issues/54104
      // is fixed.
      errorStyle: const TextStyle(fontSize: 0),
    );
  }

  @override
  ShapeBorder get shape {
    return ${shape(TokenTimePicker.containerShape)};
  }

  @override
  WidgetStateProperty<Color?>? get timeSelectorSeparatorColor {
    // TODO(tahatesser): Update this when tokens are available.
    // This is taken from https://m3.material.io/components/time-pickers/specs.
    return MaterialStatePropertyAll<Color>(_colors.onSurface);
  }

  @override
  WidgetStateProperty<TextStyle?>? get timeSelectorSeparatorTextStyle {
    // TODO(tahatesser): Update this when tokens are available.
    // This is taken from https://m3.material.io/components/time-pickers/specs.
    return MaterialStatePropertyAll<TextStyle?>(_textTheme.displayLarge);
  }
}
''';
}
