// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/bottom_app_bar.dart';
import 'template.dart';

class BottomAppBarTemplateM3 extends TokenTemplateM3 {
  const BottomAppBarTemplateM3();

  @override
  String get name => 'Bottom App Bar';

  @override
  String get parentFilePath => 'bottom_app_bar.dart';

  @override
  String generateContents(String className) => '''
class $className extends BottomAppBarThemeData {
  $className(this.context)
    : super(
      elevation: ${number(TokenBottomAppBar.containerElevation)},
      height: ${number(TokenBottomAppBar.containerHeight)},
      shape: const AutomaticNotchedShape(${shape(TokenBottomAppBar.containerShape, '')}),
    );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => ${color(TokenBottomAppBar.containerColor, '_colors')};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;
}
''';
}
