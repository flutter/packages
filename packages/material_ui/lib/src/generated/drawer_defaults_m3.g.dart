// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../drawer.dart';

class _DrawerDefaultsM3 extends DrawerThemeData {
  _DrawerDefaultsM3(this.context) : super(elevation: 1.0, clipBehavior: Clip.hardEdge);

  final BuildContext context;
  late final TextDirection direction = Directionality.of(context);

  @override
  Color? get backgroundColor => Theme.of(context).colorScheme.surfaceContainerLow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  // There isn't currently a token for this value, but it is shown in the spec,
  // so hard coding here for now.
  @override
  ShapeBorder? get shape => RoundedRectangleBorder(
    borderRadius: const BorderRadiusDirectional.horizontal(
      end: Radius.circular(16.0),
    ).resolve(direction),
  );

  // There isn't currently a token for this value, but it is shown in the spec,
  // so hard coding here for now.
  @override
  ShapeBorder? get endShape => RoundedRectangleBorder(
    borderRadius: const BorderRadiusDirectional.horizontal(
      start: Radius.circular(16.0),
    ).resolve(direction),
  );
}
