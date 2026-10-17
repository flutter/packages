// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _SegmentedButtonDefaultsM3 extends SegmentedButtonThemeData {
  _SegmentedButtonDefaultsM3(this.context);
  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  @override
  ButtonStyle? get style {
    return ButtonStyle(
      textStyle: WidgetStatePropertyAll<TextStyle?>(Theme.of(context).textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _colors.secondaryContainer;
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSecondaryContainer;
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSecondaryContainer;
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSecondaryContainer;
          }
          return _colors.onSecondaryContainer;
        } else {
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
      }),
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSecondaryContainer.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSecondaryContainer.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSecondaryContainer.withOpacity(0.1);
          }
        } else {
          if (states.contains(WidgetState.pressed)) {
            return _colors.onSurface.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.onSurface.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.onSurface.withOpacity(0.1);
          }
        }
        return null;
      }),
      surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double>(0),
      iconSize: const WidgetStatePropertyAll<double?>(18.0),
      side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: _colors.onSurface.withOpacity(0.12));
        }
        return BorderSide(color: _colors.outline);
      }),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
      minimumSize: const WidgetStatePropertyAll<Size?>(Size.fromHeight(40.0)),
    );
  }

  @override
  Widget? get selectedIcon => const Icon(Icons.check);

  static WidgetStateProperty<Color?> resolveStateColor(
    Color? unselectedColor,
    Color? selectedColor,
    Color? overlayColor,
  ) {
    final Color? selected = overlayColor ?? selectedColor;
    final Color? unselected = overlayColor ?? unselectedColor;
    return WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color?>{
      WidgetState.selected & WidgetState.pressed: selected?.withOpacity(0.1),
      WidgetState.selected & WidgetState.hovered: selected?.withOpacity(0.08),
      WidgetState.selected & WidgetState.focused: selected?.withOpacity(0.1),
      WidgetState.pressed: unselected?.withOpacity(0.1),
      WidgetState.hovered: unselected?.withOpacity(0.08),
      WidgetState.focused: unselected?.withOpacity(0.1),
      WidgetState.any: Colors.transparent,
    });
  }
}
