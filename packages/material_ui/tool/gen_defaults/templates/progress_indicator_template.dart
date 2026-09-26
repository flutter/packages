// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/progress_indicator.dart';
import '../data/progress_indicator_circular.dart';
import '../data/progress_indicator_linear.dart';
import 'template.dart';

enum _ProgressIndicatorVariant { circular, linear }

class ProgressIndicatorTemplateM3 extends TokenTemplateM3 {
  const ProgressIndicatorTemplateM3(this.name);

  @override
  final String name;

  @override
  String get parentFilePath => 'progress_indicator.dart';

  _ProgressIndicatorVariant get _variant => switch (name) {
    'Circular Progress Indicator' => _ProgressIndicatorVariant.circular,
    'Linear Progress Indicator' => _ProgressIndicatorVariant.linear,
    _ => throw UnsupportedError('Unsupported progress indicator template name: $name'),
  };

  @override
  String generateContents(String className) {
    return switch (_variant) {
      _ProgressIndicatorVariant.circular => _generateCircular(className),
      _ProgressIndicatorVariant.linear => _generateLinear(className),
    };
  }

  String _generateCircular(String className) =>
      '''
class $className extends ProgressIndicatorThemeData {
  $className(this.context, { required this.indeterminate });

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  final bool indeterminate;

  @override
  Color get color => ${color(TokenProgressIndicator.activeIndicatorColor)};

  @override
  Color? get circularTrackColor => indeterminate ? null : ${color(TokenProgressIndicator.trackColor)};

  @override
  double get strokeWidth => ${number(TokenProgressIndicatorCircular.trackThickness)};

  @override
  double? get strokeAlign => CircularProgressIndicator.strokeAlignInside;

  @override
  BoxConstraints get constraints => const BoxConstraints(
    minWidth: 40.0,
    minHeight: 40.0,
  );

  @override
  double? get trackGap => ${number(TokenProgressIndicatorCircular.trackActiveIndicatorSpace)};

  @override
  EdgeInsetsGeometry? get circularTrackPadding => const EdgeInsets.all(4.0);
}
''';

  String _generateLinear(String className) =>
      '''
class $className extends ProgressIndicatorThemeData {
  $className(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color get color => ${color(TokenProgressIndicator.activeIndicatorColor)};

  @override
  Color get linearTrackColor => ${color(TokenProgressIndicator.trackColor)};

  @override
  double get linearMinHeight => ${number(TokenProgressIndicatorLinear.trackThickness)};

  @override
  BorderRadius get borderRadius => const BorderRadius.all(Radius.circular(${number(TokenProgressIndicatorLinear.trackThickness)} / 2));

  @override
  Color get stopIndicatorColor => ${color(TokenProgressIndicator.stopIndicatorColor)};

  @override
  double? get stopIndicatorRadius => ${number(TokenProgressIndicatorLinear.stopIndicatorSize)} / 2;

  @override
  double? get trackGap => ${number(TokenProgressIndicatorLinear.trackActiveIndicatorSpace)};
}
''';
}
