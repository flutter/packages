// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/search_view.dart';
import 'template.dart';

class SearchViewTemplateM3 extends TokenTemplateM3 {
  const SearchViewTemplateM3();

  @override
  String get name => 'Search View';

  @override
  String get parentFilePath => 'search_anchor.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends SearchViewThemeData {
  $className(this.context, {required this.isFullScreen});

  final BuildContext context;
  final bool isFullScreen;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  static double fullScreenBarHeight = ${TokenSearchView.fullScreenHeaderContainerHeight};

  @override
  Color? get backgroundColor => ${color(TokenSearchView.containerColor)};

  @override
  double? get elevation => ${TokenSearchView.containerElevation};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  // No default side

  @override
  OutlinedBorder? get shape => isFullScreen
    ? ${shape(TokenSearchView.fullScreenContainerShape)}
    : ${shape(TokenSearchView.dockedContainerShape)};

  @override
  TextStyle? get headerTextStyle => ${textStyle(TokenSearchView.headerInputTextType, '_textTheme')}?.copyWith(color: ${color(TokenSearchView.headerInputTextColor)});

  @override
  TextStyle? get headerHintStyle => ${textStyle(TokenSearchView.headerSupportingTextType, '_textTheme')}?.copyWith(color: ${color(TokenSearchView.headerSupportingTextColor)});

  @override
  BoxConstraints get constraints => const BoxConstraints(minWidth: 360.0, minHeight: 240.0);

  @override
  EdgeInsetsGeometry? get barPadding => const EdgeInsets.symmetric(horizontal: 8.0);

  @override
  bool get shrinkWrap => false;

  @override
  Color? get dividerColor => ${color(TokenSearchView.dividerColor)};
}
''';
}
