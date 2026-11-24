// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/progress_indicator.dart';
import '../data/progress_indicator_circular.dart';
import '../data/progress_indicator_linear.dart';
import 'template.dart';

class ProgressIndicatorTemplateM3 extends TokenTemplateM3 {
  const ProgressIndicatorTemplateM3();

  @override
  String get name => 'Progress Indicator';

  @override
  String get parentFilePath => 'progress_indicator.dart';

  @override
  String get className => '';

  @override
  String generateContents(String className) =>
      '''
class _CircularProgressIndicatorDefaultsM3 extends ProgressIndicatorThemeData {
  _CircularProgressIndicatorDefaultsM3(this.context, { required this.indeterminate });

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  final bool indeterminate;

  @override
  Color get color => ${color(TokenProgressIndicator.activeIndicatorColor)};

  @override
  Color? get circularTrackColor => indeterminate ? null : ${color(TokenProgressIndicator.trackColor)};

  @override
  double get strokeWidth => ${TokenProgressIndicatorCircular.trackThickness};

  @override
  double? get strokeAlign => CircularProgressIndicator.strokeAlignInside;

  @override
  BoxConstraints get constraints => const BoxConstraints(
    minWidth: 40.0,
    minHeight: 40.0,
  );

  @override
  double? get trackGap => ${TokenProgressIndicatorCircular.trackActiveIndicatorSpace};

  @override
  EdgeInsetsGeometry? get circularTrackPadding => const EdgeInsets.all(4.0);
}

class _LinearProgressIndicatorDefaultsM3 extends ProgressIndicatorThemeData {
  _LinearProgressIndicatorDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color get color => ${color(TokenProgressIndicator.activeIndicatorColor)};

  @override
  Color get linearTrackColor => ${color(TokenProgressIndicator.trackColor)};

  @override
  double get linearMinHeight => ${TokenProgressIndicatorLinear.trackThickness};

  @override
  BorderRadius get borderRadius => const BorderRadius.all(Radius.circular(${TokenProgressIndicatorLinear.trackThickness} / 2));

  @override
  Color get stopIndicatorColor => ${color(TokenProgressIndicator.stopIndicatorColor)};

  @override
  double? get stopIndicatorRadius => ${TokenProgressIndicatorLinear.stopIndicatorSize} / 2;

  @override
  double? get trackGap => ${TokenProgressIndicatorLinear.trackActiveIndicatorSpace};
}
''';
}
