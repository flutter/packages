// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _ExpansionTileDefaultsM3 extends ExpansionTileThemeData {
  _ExpansionTileDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color? get textColor => _colors.onSurface;

  @override
  Color? get iconColor => _colors.primary;

  @override
  Color? get collapsedTextColor => _colors.onSurface;

  @override
  Color? get collapsedIconColor => _colors.onSurfaceVariant;
}
