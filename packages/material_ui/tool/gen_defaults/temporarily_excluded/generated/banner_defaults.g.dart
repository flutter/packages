// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _BannerDefaultsM3 extends MaterialBannerThemeData {
  _BannerDefaultsM3(this.context) : super(elevation: 1.0);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainerLow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get dividerColor => _colors.outlineVariant;

  @override
  TextStyle? get contentTextStyle => _textTheme.bodyMedium;
}
