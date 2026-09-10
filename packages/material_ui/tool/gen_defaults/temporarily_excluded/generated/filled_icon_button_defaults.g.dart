// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _FilledIconButtonDefaultsM3 extends ButtonStyle {
  _FilledIconButtonDefaultsM3(this.context, this.toggleable)
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  // No default text style

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return _colors.primary;
        }
        if (toggleable) {
          // toggleable but unselected case
          return _colors.surfaceContainerHighest;
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        if (states.contains(WidgetState.selected)) {
          return _colors.onPrimary;
        }
        if (toggleable) {
          // toggleable but unselected case
          return _colors.primary;
        }
        return _colors.onPrimary;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
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
        }
        if (toggleable) {
          // toggleable but unselected case
          if (states.contains(WidgetState.pressed)) {
            return _colors.primary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return _colors.primary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return _colors.primary.withOpacity(0.1);
          }
        }
        if (states.contains(WidgetState.pressed)) {
          return _colors.onPrimary.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onPrimary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onPrimary.withOpacity(0.1);
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      const MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(8.0));

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      const MaterialStatePropertyAll<Size>(Size(40.0, 40.0));

  // No default fixedSize

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize => const MaterialStatePropertyAll<double>(24.0);

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const MaterialStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}
