// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'template.dart';

class BottomAppBarTemplate extends TokenTemplateM3 {
  const BottomAppBarTemplate( {
    this.colorSchemePrefix = '_colors.',
  });

  final String colorSchemePrefix;

  @override
  String get name => 'Bottom App Bar';

  @override
  String get parentFilePath => 'bottom_app_bar.dart';

  @override
  String generateContents(String className) => '''
class $className extends BottomAppBarThemeData {
  $className(this.context)
    : super(
      elevation: ${elevation('md.comp.bottom-app-bar.container')},
      height: ${getToken('md.comp.bottom-app-bar.container.height')},
      shape: const AutomaticNotchedShape(${shape('md.comp.bottom-app-bar.container', '')}),
    );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => ${componentColor('md.comp.bottom-app-bar.container')};

  @override
  Color? get surfaceTintColor => ${colorOrTransparent('md.comp.bottom-app-bar.container.surface-tint-layer')};

  @override
  Color? get shadowColor => Colors.transparent;
}
''';
}
