// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _TextButtonDefaultsM3 extends ButtonStyle {
  _TextButtonDefaultsM3(this.context)
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
      MaterialStatePropertyAll<TextStyle?>(Theme.of(context).textTheme.labelLarge);

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withOpacity(0.38);
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.primary.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.primary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.primary.withOpacity(0.1);
        }
        return null;
      });

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      MaterialStatePropertyAll<EdgeInsetsGeometry>(_scaledPadding(context));

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      const MaterialStatePropertyAll<Size>(Size(64.0, 40.0));

  // No default fixedSize

  @override
  WidgetStateProperty<double>? get iconSize => const MaterialStatePropertyAll<double>(18.0);

  @override
  WidgetStateProperty<Color>? get iconColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return _colors.onSurface.withOpacity(0.38);
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.primary;
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.primary;
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.primary;
      }
      return _colors.primary;
    });
  }

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  // No default side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const MaterialStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => Theme.of(context).visualDensity;

  @override
  MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}
