// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../badge.dart';

class _BadgeDefaultsM3 extends BadgeThemeData {
  _BadgeDefaultsM3(this.context)
    : super(
        smallSize: 6.0,
        largeSize: 16.0,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: AlignmentDirectional.topEnd,
      );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color? get backgroundColor => _colors.error;

  @override
  Color? get textColor => _colors.onError;

  @override
  TextStyle? get textStyle => Theme.of(context).textTheme.labelSmall;
}
