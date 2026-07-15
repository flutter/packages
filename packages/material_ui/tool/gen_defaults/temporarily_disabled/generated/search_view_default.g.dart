// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _SearchViewDefaultsM3 extends SearchViewThemeData {
  _SearchViewDefaultsM3(this.context, {required this.isFullScreen});

  final BuildContext context;
  final bool isFullScreen;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  static double fullScreenBarHeight = 72.0;

  @override
  Color? get backgroundColor => _colors.surfaceContainerHigh;

  @override
  double? get elevation => 6.0;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  // No default side

  @override
  OutlinedBorder? get shape =>
      isFullScreen
          ? const RoundedRectangleBorder()
          : const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28.0)));

  @override
  TextStyle? get headerTextStyle => _textTheme.bodyLarge?.copyWith(color: _colors.onSurface);

  @override
  TextStyle? get headerHintStyle => _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant);

  @override
  BoxConstraints get constraints => const BoxConstraints(minWidth: 360.0, minHeight: 240.0);

  @override
  EdgeInsetsGeometry? get barPadding => const EdgeInsets.symmetric(horizontal: 8.0);

  @override
  bool get shrinkWrap => false;

  @override
  Color? get dividerColor => _colors.outline;
}
