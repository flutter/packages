// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/banner.dart';
import '../data/divider.dart';
import 'template.dart';

class BannerTemplateM3 extends TokenTemplateM3 {
  const BannerTemplateM3();

  @override
  String get name => 'Banner';

  @override
  String get parentFilePath => 'banner.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends MaterialBannerThemeData {
  $className(this.context)
    : super(elevation: ${number(TokenBanner.containerElevation)});

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => ${color(TokenBanner.containerColor, '_colors')};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get dividerColor => ${color(TokenDivider.color, '_colors')};

  @override
  TextStyle? get contentTextStyle => _textTheme.bodyMedium;
}
''';
}
