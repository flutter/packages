// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/badge.dart';
import 'template.dart';

class BadgeTemplateM3 extends TokenTemplateM3 {
  const BadgeTemplateM3();

  @override
  String get name => 'Badge';

  @override
  String get parentFilePath => 'badge.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends BadgeThemeData {
  $className(this.context) : super(
    smallSize: ${number(TokenBadge.size)},
    largeSize: ${number(TokenBadge.largeSize)},
    padding: const EdgeInsets.symmetric(horizontal: 4),
    alignment: AlignmentDirectional.topEnd,
  );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color? get backgroundColor => ${color(TokenBadge.color, '_colors')};

  @override
  Color? get textColor => ${color(TokenBadge.largeLabelTextColor, '_colors')};

  @override
  TextStyle? get textStyle => Theme.of(context).textTheme.labelSmall;
}
''';
}
