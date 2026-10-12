// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _PopupMenuDefaultsM3 extends PopupMenuThemeData {
  _PopupMenuDefaultsM3(this.context) : super(elevation: 3.0);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      // TODO(quncheng): Update this hard-coded value to use the latest tokens.
      final TextStyle style = _textTheme.labelLarge!;
      if (states.contains(WidgetState.disabled)) {
        return style.apply(color: _colors.onSurface.withOpacity(0.38));
      }
      return style.apply(color: _colors.onSurface);
    });
  }

  @override
  Color? get color => _colors.surfaceContainer;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape =>
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));

  // TODO(bleroux): This is taken from https://m3.material.io/components/menus/specs
  // Update this when the token is available.
  @override
  EdgeInsets? get menuPadding => const EdgeInsets.symmetric(vertical: 8.0);

  // TODO(tahatesser): This is taken from https://m3.material.io/components/menus/specs
  // Update this when the token is available.
  static EdgeInsets menuItemPadding = const EdgeInsets.symmetric(horizontal: 12.0);
}
