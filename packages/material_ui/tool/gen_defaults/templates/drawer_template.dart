// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/navigation_drawer.dart';
import 'template.dart';

class DrawerTemplateM3 extends TokenTemplateM3 {
  const DrawerTemplateM3();

  @override
  String get name => 'Drawer';

  @override
  String get parentFilePath => 'drawer.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends DrawerThemeData {
  $className(this.context)
      : super(
          elevation: ${number(TokenNavigationDrawer.modalContainerElevation)},
          clipBehavior: Clip.hardEdge,
        );

  final BuildContext context;
  late final TextDirection direction = Directionality.of(context);

  @override
  Color? get backgroundColor => ${color(TokenNavigationDrawer.modalContainerColor, 'Theme.of(context).colorScheme')};

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
''';
}
