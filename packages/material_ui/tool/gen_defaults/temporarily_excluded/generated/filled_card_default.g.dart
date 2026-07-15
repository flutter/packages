// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _FilledCardDefaultsM3 extends CardThemeData {
  _FilledCardDefaultsM3(this.context)
    : super(clipBehavior: Clip.none, elevation: 0.0, margin: const EdgeInsets.all(4.0));

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.surfaceContainerHighest;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape =>
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)));
}
