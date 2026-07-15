// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _NavigationRailDefaultsM3 extends NavigationRailThemeData {
  _NavigationRailDefaultsM3(this.context)
    : super(
        elevation: 0.0,
        groupAlignment: -1,
        labelType: NavigationRailLabelType.none,
        useIndicator: true,
        minWidth: 80.0,
        minExtendedWidth: 256,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(size: 24.0, color: _colors.onSurfaceVariant);
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(size: 24.0, color: _colors.onSecondaryContainer);
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();
}
