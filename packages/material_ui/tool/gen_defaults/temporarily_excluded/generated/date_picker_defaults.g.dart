// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _DatePickerDefaultsM3 extends DatePickerThemeData {
  _DatePickerDefaultsM3(this.context)
    : super(
        elevation: 6.0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28.0))),
        // TODO(tahatesser): Update this to use token when gen_defaults
        // supports `CircleBorder` for fully rounded corners.
        dayShape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
        yearShape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        rangePickerElevation: 0.0,
        rangePickerShape: const RoundedRectangleBorder(),
      );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainerHigh;

  @override
  Color? get subHeaderForegroundColor => _colors.onSurface.withOpacity(0.60);

  @override
  TextStyle? get toggleButtonTextStyle =>
      _textTheme.titleSmall?.apply(color: subHeaderForegroundColor);

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
  Color? get headerForegroundColor => _colors.onSurfaceVariant;

  @override
  TextStyle? get headerHeadlineStyle => _textTheme.headlineLarge;

  @override
  TextStyle? get headerHelpStyle => _textTheme.labelLarge;

  @override
  TextStyle? get weekdayStyle => _textTheme.bodyLarge?.apply(color: _colors.onSurface);

  @override
  TextStyle? get dayStyle => _textTheme.bodyLarge;

  @override
  WidgetStateProperty<Color?>? get dayForegroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        } else if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        return _colors.onSurface;
      });

  @override
  WidgetStateProperty<Color?>? get dayBackgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return _colors.primary;
        }
        return null;
      });

  @override
  WidgetStateProperty<Color?>? get dayOverlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onPrimary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onPrimary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onPrimary.withOpacity(0.1);
          }
        } else {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSurfaceVariant.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSurfaceVariant.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSurfaceVariant.withOpacity(0.1);
          }
        }
        return null;
      });

  @override
  WidgetStateProperty<Color?>? get todayForegroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        } else if (states.contains(WidgetState.disabled)) {
          return _colors.primary.withOpacity(0.38);
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<Color?>? get todayBackgroundColor => dayBackgroundColor;

  @override
  BorderSide? get todayBorder => BorderSide(color: _colors.primary);

  @override
  TextStyle? get yearStyle => _textTheme.bodyLarge;

  @override
  WidgetStateProperty<Color?>? get yearForegroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        } else if (states.contains(WidgetState.disabled)) {
          return _colors.onSurfaceVariant.withOpacity(0.38);
        }
        return _colors.onSurfaceVariant;
      });

  @override
  WidgetStateProperty<Color?>? get yearBackgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return _colors.primary;
        }
        return null;
      });

  @override
  WidgetStateProperty<Color?>? get yearOverlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onPrimary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onPrimary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onPrimary.withOpacity(0.1);
          }
        } else {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSurfaceVariant.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSurfaceVariant.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSurfaceVariant.withOpacity(0.1);
          }
        }
        return null;
      });

  @override
  Color? get rangePickerShadowColor => Colors.transparent;

  @override
  Color? get rangePickerSurfaceTintColor => Colors.transparent;

  @override
  Color? get rangeSelectionBackgroundColor => _colors.secondaryContainer;

  @override
  WidgetStateProperty<Color?>? get rangeSelectionOverlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.onPrimaryContainer.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onPrimaryContainer.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onPrimaryContainer.withOpacity(0.1);
        }
        return null;
      });

  @override
  Color? get rangePickerHeaderBackgroundColor => Colors.transparent;

  @override
  Color? get rangePickerHeaderForegroundColor => _colors.onSurfaceVariant;

  @override
  TextStyle? get rangePickerHeaderHeadlineStyle => _textTheme.titleLarge;

  @override
  TextStyle? get rangePickerHeaderHelpStyle => _textTheme.titleSmall;
}
