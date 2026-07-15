// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _AppBarDefaultsM3 extends AppBarThemeData {
  _AppBarDefaultsM3(this.context)
    : super(
        elevation: 0.0,
        scrolledUnderElevation: 3.0,
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: 64.0,
      );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  Color? get foregroundColor => _colors.onSurface;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  IconThemeData? get iconTheme => IconThemeData(color: _colors.onSurface, size: 24.0);

  @override
  IconThemeData? get actionsIconTheme => IconThemeData(color: _colors.onSurfaceVariant, size: 24.0);

  @override
  TextStyle? get toolbarTextStyle => _textTheme.bodyMedium;

  @override
  TextStyle? get titleTextStyle => _textTheme.titleLarge;

  // TODO(Craftplacer): Consider using EdgeInsets.only(right: 8.0) instead of
  // EdgeInsets.zero for Material 3 in the future,
  // https://github.com/flutter/flutter/issues/155747
  @override
  EdgeInsets? get actionsPadding => EdgeInsets.zero;
}

// Variant configuration
class _MediumScrollUnderFlexibleConfig with _ScrollUnderFlexibleConfig {
  _MediumScrollUnderFlexibleConfig(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  static const double collapsedHeight = 64.0;
  static const double expandedHeight = 112.0;

  @override
  TextStyle? get collapsedTextStyle => _textTheme.titleLarge?.apply(color: _colors.onSurface);

  @override
  TextStyle? get expandedTextStyle => _textTheme.headlineSmall?.apply(color: _colors.onSurface);

  @override
  EdgeInsetsGeometry get expandedTitlePadding => const EdgeInsets.fromLTRB(16, 0, 16, 20);
}

class _LargeScrollUnderFlexibleConfig with _ScrollUnderFlexibleConfig {
  _LargeScrollUnderFlexibleConfig(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  static const double collapsedHeight = 64.0;
  static const double expandedHeight = 152.0;

  @override
  TextStyle? get collapsedTextStyle => _textTheme.titleLarge?.apply(color: _colors.onSurface);

  @override
  TextStyle? get expandedTextStyle => _textTheme.headlineMedium?.apply(color: _colors.onSurface);

  @override
  EdgeInsetsGeometry get expandedTitlePadding => const EdgeInsets.fromLTRB(16, 0, 16, 28);
}
