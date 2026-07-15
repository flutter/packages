// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _TimePickerDefaultsM3 extends _TimePickerDefaults {
  _TimePickerDefaultsM3(this.context, {this.entryMode = TimePickerEntryMode.dial});

  final BuildContext context;
  final TimePickerEntryMode entryMode;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color get backgroundColor {
    return _colors.surfaceContainerHigh;
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
    return BorderSide(color: _colors.outline);
  }

  @override
  Color get dayPeriodColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return _colors.tertiaryContainer;
      }
      // The unselected day period should match the overall picker dialog color.
      // Making it transparent enables that without being redundant and allows
      // the optional elevation overlay for dark mode to be visible.
      return Colors.transparent;
    });
  }

  @override
  OutlinedBorder get dayPeriodShape {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ).copyWith(side: dayPeriodBorderSide);
  }

  @override
  Size get dayPeriodPortraitSize {
    return const Size(52, 80);
  }

  @override
  Size get dayPeriodLandscapeSize {
    return const Size(216, 38);
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
          return _colors.onTertiaryContainer;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onTertiaryContainer;
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onTertiaryContainer;
        }
        return _colors.onTertiaryContainer;
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurfaceVariant;
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurfaceVariant;
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSurfaceVariant;
      }
      return _colors.onSurfaceVariant;
    });
  }

  @override
  TextStyle get dayPeriodTextStyle {
    return _textTheme.titleMedium!.copyWith(color: dayPeriodTextColor);
  }

  @override
  Color get dialBackgroundColor {
    return _colors.surfaceContainerHighest;
  }

  @override
  Color get dialHandColor {
    return _colors.primary;
  }

  @override
  Size get dialSize {
    return const Size.square(256.0);
  }

  @override
  double get handWidth {
    return const Size(2, double.infinity).width;
  }

  @override
  double get dotRadius {
    return const Size.square(48.0).width / 2;
  }

  @override
  double get centerRadius {
    return const Size.square(8.0).width / 2;
  }

  @override
  Color get dialTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return _colors.onPrimary;
      }
      return _colors.onSurface;
    });
  }

  @override
  TextStyle get dialTextStyle {
    return _textTheme.bodyLarge!;
  }

  @override
  double get elevation {
    return 6.0;
  }

  @override
  Color get entryModeIconColor {
    return _colors.onSurface;
  }

  @override
  TextStyle get helpTextStyle {
    return WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
      final TextStyle textStyle = _textTheme.labelMedium!;
      return textStyle.copyWith(color: _colors.onSurfaceVariant);
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
        Color overlayColor = _colors.primaryContainer;
        if (states.contains(WidgetState.pressed)) {
          overlayColor = _colors.onPrimaryContainer;
        } else if (states.contains(WidgetState.hovered)) {
          const hoverOpacity = 0.08;
          overlayColor = _colors.onPrimaryContainer.withOpacity(hoverOpacity);
        } else if (states.contains(WidgetState.focused)) {
          const focusOpacity = 0.1;
          overlayColor = _colors.onPrimaryContainer.withOpacity(focusOpacity);
        }
        return Color.alphaBlend(overlayColor, _colors.primaryContainer);
      } else {
        Color overlayColor = _colors.surfaceContainerHighest;
        if (states.contains(WidgetState.pressed)) {
          overlayColor = _colors.onSurface;
        } else if (states.contains(WidgetState.hovered)) {
          const hoverOpacity = 0.08;
          overlayColor = _colors.onSurface.withOpacity(hoverOpacity);
        } else if (states.contains(WidgetState.focused)) {
          const focusOpacity = 0.1;
          overlayColor = _colors.onSurface.withOpacity(focusOpacity);
        }
        return Color.alphaBlend(overlayColor, _colors.surfaceContainerHighest);
      }
    });
  }

  @override
  ShapeBorder get hourMinuteShape {
    return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)));
  }

  @override
  Size get hourMinuteSize {
    return const Size(96, 80);
  }

  @override
  Size get hourMinuteSize24Hour {
    return Size(const Size(114, double.infinity).width, hourMinuteSize.height);
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
          return _colors.onPrimaryContainer;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onPrimaryContainer;
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onPrimaryContainer;
        }
        return _colors.onPrimaryContainer;
      } else {
        // unselected
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSurface;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSurface;
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onSurface;
        }
        return _colors.onSurface;
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
        TimePickerEntryMode.dial || TimePickerEntryMode.dialOnly => _textTheme.displayLarge!
            .copyWith(color: _hourMinuteTextColor.resolve(states)),
        TimePickerEntryMode.input || TimePickerEntryMode.inputOnly => _textTheme.displayMedium!
            .copyWith(color: _hourMinuteTextColor.resolve(states)),
      };
    });
  }

  @override
  InputDecorationThemeData get inputDecorationTheme {
    // This is NOT correct, but there's no token for
    // 'time-input.container.shape', so this is using the radius from the shape
    // for the hour/minute selector. It's a BorderRadiusGeometry, so we have to
    // resolve it before we can use it.
    final BorderRadius selectorRadius = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ).borderRadius.resolve(Directionality.of(context));
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
    return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28.0)));
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
