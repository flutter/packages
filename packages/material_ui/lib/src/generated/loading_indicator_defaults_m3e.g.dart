// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../loading_indicator.dart';

class _LoadingIndicatorDefaultsM3E extends LoadingIndicatorThemeData {
  _LoadingIndicatorDefaultsM3E(this.context) : super(containerShape: const StadiumBorder());

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.primary;

  @override
  Color? get containedColor => _colors.onPrimaryContainer;

  @override
  Color? get containerColor => _colors.primaryContainer;

  /// The default size of the container that the active indicator is drawn in.
  Size get containerSize => const Size(48.0, 48.0);

  /// The default size of the active indicator.
  double get activeIndicatorSize => 38.0;
}
