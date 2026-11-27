// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import '../data/loading_indicator.dart';
import 'template.dart';

class LoadingIndicatorTemplateM3E extends TokenTemplateM3E {
  const LoadingIndicatorTemplateM3E();

  @override
  String get name => 'Loading Indicator';

  @override
  String get parentFilePath => 'loading_indicator.dart';

  @override
  String get className => '';

  @override
  String generateContents(String className) =>
      '''
class _LoadingIndicatorDefaultsM3E extends LoadingIndicatorThemeData {
  _LoadingIndicatorDefaultsM3E(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => ${color(TokenLoadingIndicator.activeIndicatorColor)};

  @override
  BoxConstraints get constraints => const BoxConstraints(
    minWidth: ${TokenLoadingIndicator.containerWidth},
    minHeight: ${TokenLoadingIndicator.containerHeight},
  );

  /// The size of the active indicator relative to the shortest side of the
  /// loading indicator.
  static const double activeIndicatorScale = ${TokenLoadingIndicator.activeIndicatorSize} / ${math.min(TokenLoadingIndicator.containerWidth, TokenLoadingIndicator.containerHeight)};
}

class _ContainedLoadingIndicatorDefaultsM3E extends LoadingIndicatorThemeData {
  _ContainedLoadingIndicatorDefaultsM3E(this.context)
    : super(containerShape: ${shape(TokenLoadingIndicator.containerShape)});

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => ${color(TokenLoadingIndicator.containedActiveIndicatorColor)};

  @override
  Color? get containerColor => ${color(TokenLoadingIndicator.containedContainerColor)};

  @override
  BoxConstraints get constraints => const BoxConstraints(
    minWidth: ${TokenLoadingIndicator.containerWidth},
    minHeight: ${TokenLoadingIndicator.containerHeight},
  );
}
''';
}
