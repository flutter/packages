// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _InputDecoratorDefaultsM3 extends InputDecorationThemeData {
  _InputDecoratorDefaultsM3(this.context) : super();

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  // For InputDecorator, focused state should take precedence over hovered state.
  // For instance, the focused state increases border width (2dp) and applies bright
  // colors (primary color or error color) while the hovered state has the same border
  // than the non-focused state (1dp) and uses a color a little darker than non-focused
  // state. On desktop, it is also very common that a text field is focused and hovered
  // because users often rely on mouse selection.
  // For other widgets, hovered state takes precedence over focused state, because it
  // is mainly used to determine the overlay color,
  // see https://github.com/flutter/flutter/pull/125905.

  @override
  TextStyle? get hintStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return TextStyle(color: _colors.onSurface.withOpacity(0.38));
    }
    return TextStyle(color: _colors.onSurfaceVariant);
  });

  @override
  Color? get fillColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return _colors.onSurface.withOpacity(0.04);
    }
    return _colors.surfaceContainerHighest;
  });

  @override
  BorderSide? get activeIndicatorBorder =>
      WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: _colors.onSurface.withOpacity(0.38));
        }
        if (states.contains(WidgetState.error)) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: _colors.error, width: 2.0);
          }
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(color: _colors.onErrorContainer);
          }
          return BorderSide(color: _colors.error);
        }
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: _colors.primary, width: 2.0);
        }
        if (states.contains(WidgetState.hovered)) {
          return BorderSide(color: _colors.onSurface);
        }
        return BorderSide(color: _colors.onSurfaceVariant);
      });

  @override
  BorderSide? get outlineBorder => WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return BorderSide(color: _colors.onSurface.withOpacity(0.12));
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(color: _colors.error, width: 2.0);
      }
      if (states.contains(WidgetState.hovered)) {
        return BorderSide(color: _colors.onErrorContainer);
      }
      return BorderSide(color: _colors.error);
    }
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: _colors.primary, width: 2.0);
    }
    if (states.contains(WidgetState.hovered)) {
      return BorderSide(color: _colors.onSurface);
    }
    return BorderSide(color: _colors.outline);
  });

  @override
  Color? get iconColor => _colors.onSurfaceVariant;

  @override
  Color? get prefixIconColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return _colors.onSurface.withOpacity(0.38);
    }
    return _colors.onSurfaceVariant;
  });

  @override
  Color? get suffixIconColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return _colors.onSurface.withOpacity(0.38);
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.hovered)) {
        return _colors.onErrorContainer;
      }
      return _colors.error;
    }
    return _colors.onSurfaceVariant;
  });

  @override
  TextStyle? get labelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = _textTheme.bodyLarge ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: _colors.onSurface.withOpacity(0.38));
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return textStyle.copyWith(color: _colors.error);
      }
      if (states.contains(WidgetState.hovered)) {
        return textStyle.copyWith(color: _colors.onErrorContainer);
      }
      return textStyle.copyWith(color: _colors.error);
    }
    if (states.contains(WidgetState.focused)) {
      return textStyle.copyWith(color: _colors.primary);
    }
    if (states.contains(WidgetState.hovered)) {
      return textStyle.copyWith(color: _colors.onSurfaceVariant);
    }
    return textStyle.copyWith(color: _colors.onSurfaceVariant);
  });

  @override
  TextStyle? get floatingLabelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = _textTheme.bodyLarge ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: _colors.onSurface.withOpacity(0.38));
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return textStyle.copyWith(color: _colors.error);
      }
      if (states.contains(WidgetState.hovered)) {
        return textStyle.copyWith(color: _colors.onErrorContainer);
      }
      return textStyle.copyWith(color: _colors.error);
    }
    if (states.contains(WidgetState.focused)) {
      return textStyle.copyWith(color: _colors.primary);
    }
    if (states.contains(WidgetState.hovered)) {
      return textStyle.copyWith(color: _colors.onSurfaceVariant);
    }
    return textStyle.copyWith(color: _colors.onSurfaceVariant);
  });

  @override
  TextStyle? get helperStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = _textTheme.bodySmall ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: _colors.onSurface.withOpacity(0.38));
    }
    return textStyle.copyWith(color: _colors.onSurfaceVariant);
  });

  @override
  TextStyle? get errorStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = _textTheme.bodySmall ?? const TextStyle();
    return textStyle.copyWith(color: _colors.error);
  });
}
