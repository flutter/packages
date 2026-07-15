// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _CheckboxDefaultsM3 extends CheckboxThemeData {
  _CheckboxDefaultsM3(BuildContext context)
    : _theme = Theme.of(context),
      _colors = Theme.of(context).colorScheme;

  final ThemeData _theme;
  final ColorScheme _colors;

  @override
  WidgetStateBorderSide? get side {
    return WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return const BorderSide(width: 2.0, color: Colors.transparent);
        }
        return BorderSide(width: 2.0, color: _colors.onSurface.withOpacity(0.38));
      }
      if (states.contains(WidgetState.selected)) {
        return const BorderSide(width: 0.0, color: Colors.transparent);
      }
      if (states.contains(WidgetState.error)) {
        return BorderSide(width: 2.0, color: _colors.error);
      }
      if (states.contains(WidgetState.pressed)) {
        return BorderSide(width: 2.0, color: _colors.onSurface);
      }
      if (states.contains(WidgetState.hovered)) {
        return BorderSide(width: 2.0, color: _colors.onSurface);
      }
      if (states.contains(WidgetState.focused)) {
        return BorderSide(width: 2.0, color: _colors.onSurface);
      }
      return BorderSide(width: 2.0, color: _colors.onSurfaceVariant);
    });
  }

  @override
  WidgetStateProperty<Color> get fillColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.error)) {
          return _colors.error;
        }
        return _colors.primary;
      }
      return Colors.transparent;
    });
  }

  @override
  WidgetStateProperty<Color> get checkColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return _colors.surface;
        }
        return Colors.transparent; // No icons available when the checkbox is unselected.
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.error)) {
          return _colors.onError;
        }
        return _colors.onPrimary;
      }
      return Colors.transparent; // No icons available when the checkbox is unselected.
    });
  }

  @override
  WidgetStateProperty<Color> get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.error)) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.error.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.error.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.error.withOpacity(0.1);
        }
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSurface.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.primary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.primary.withOpacity(0.1);
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.primary.withOpacity(0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface.withOpacity(0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSurface.withOpacity(0.1);
      }
      return Colors.transparent;
    });
  }

  @override
  double get splashRadius => 40.0 / 2;

  @override
  MaterialTapTargetSize get materialTapTargetSize => _theme.materialTapTargetSize;

  @override
  VisualDensity get visualDensity => VisualDensity.standard;

  @override
  OutlinedBorder get shape =>
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.0)));
}
