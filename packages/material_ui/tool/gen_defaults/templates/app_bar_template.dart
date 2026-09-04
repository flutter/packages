// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/app_bar.dart';
import '../data/app_bar_large.dart';
import '../data/app_bar_medium.dart';
import '../data/app_bar_small.dart';
import 'template.dart';

class AppBarTemplateM3 extends TokenTemplateM3 {
  const AppBarTemplateM3();

  @override
  String get name => 'App Bar';

  @override
  String get parentFilePath => 'app_bar.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends AppBarThemeData {
  $className(this.context)
    : super(
      elevation: ${number(TokenAppBar.containerElevation)},
      scrolledUnderElevation: ${number(TokenAppBar.onScrollContainerElevation)},
      titleSpacing: NavigationToolbar.kMiddleSpacing,
      toolbarHeight: ${number(TokenAppBarSmall.containerHeight)},
    );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get backgroundColor => ${color(TokenAppBar.containerColor, '_colors')};

  @override
  Color? get foregroundColor => ${color(TokenAppBar.titleColor, '_colors')};

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  IconThemeData? get iconTheme => IconThemeData(
    color: ${color(TokenAppBar.leadingIconColor, '_colors')},
    size: ${number(TokenAppBar.iconSize)},
  );

  @override
  IconThemeData? get actionsIconTheme => IconThemeData(
    color: ${color(TokenAppBar.trailingIconColor, '_colors')},
    size: ${number(TokenAppBar.iconSize)},
  );

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

  static const double collapsedHeight = ${number(TokenAppBarSmall.containerHeight)};
  static const double expandedHeight = ${number(TokenAppBarMedium.containerHeight)};

  @override
  TextStyle? get collapsedTextStyle =>
    _textTheme.titleLarge?.apply(color: ${color(TokenAppBar.titleColor, '_colors')});

  @override
  TextStyle? get expandedTextStyle =>
    _textTheme.headlineSmall?.apply(color: ${color(TokenAppBar.titleColor, '_colors')});

  @override
  EdgeInsetsGeometry get expandedTitlePadding => const EdgeInsets.fromLTRB(16, 0, 16, 20);
}

class _LargeScrollUnderFlexibleConfig with _ScrollUnderFlexibleConfig {
  _LargeScrollUnderFlexibleConfig(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  static const double collapsedHeight = ${number(TokenAppBarSmall.containerHeight)};
  static const double expandedHeight = ${number(TokenAppBarLarge.containerHeight)};

  @override
  TextStyle? get collapsedTextStyle =>
    _textTheme.titleLarge?.apply(color: ${color(TokenAppBar.titleColor, '_colors')});

  @override
  TextStyle? get expandedTextStyle =>
    _textTheme.headlineMedium?.apply(color: ${color(TokenAppBar.titleColor, '_colors')});

  @override
  EdgeInsetsGeometry get expandedTitlePadding => const EdgeInsets.fromLTRB(16, 0, 16, 28);
}
''';
}
