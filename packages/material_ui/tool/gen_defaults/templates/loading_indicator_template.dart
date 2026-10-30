// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/loading_indicator.dart';
import 'template.dart';

class LoadingIndicatorTemplateM3E extends TokenTemplateM3E {
  const LoadingIndicatorTemplateM3E();

  @override
  String get name => 'Loading Indicator';

  @override
  String get parentFilePath => 'loading_indicator.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends LoadingIndicatorThemeData {
  $className(this.context)
    : super(containerShape: ${shape(TokenLoadingIndicator.containerShape)});

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => ${color(TokenLoadingIndicator.activeIndicatorColor)};

  @override
  Color? get containedColor => ${color(TokenLoadingIndicator.containedActiveIndicatorColor)};

  @override
  Color? get containerColor => ${color(TokenLoadingIndicator.containedContainerColor)};

  /// The default size of the container that the active indicator is drawn in.
  Size get containerSize => const Size(${number(TokenLoadingIndicator.containerWidth)}, ${number(TokenLoadingIndicator.containerHeight)});

  /// The default size of the active indicator.
  double get activeIndicatorSize => ${number(TokenLoadingIndicator.activeIndicatorSize)};
}
''';
}
