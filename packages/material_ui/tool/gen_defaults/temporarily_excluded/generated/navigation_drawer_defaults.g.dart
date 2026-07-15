// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _NavigationDrawerDefaultsM3 extends NavigationDrawerThemeData {
  _NavigationDrawerDefaultsM3(this.context)
    : super(
        elevation: 1.0,
        tileHeight: 56.0,
        indicatorShape: const StadiumBorder(),
        indicatorSize: const Size(336.0, 56.0),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainerLow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color:
            states.contains(WidgetState.disabled)
                ? _colors.onSurfaceVariant.withOpacity(0.38)
                : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = _textTheme.labelLarge!;
      return style.apply(
        color:
            states.contains(WidgetState.disabled)
                ? _colors.onSurfaceVariant.withOpacity(0.38)
                : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }
}
