// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/dialog.dart';
import '../data/full_screen_dialog.dart';
import 'template.dart';

class DialogTemplateM3 extends TokenTemplateM3 {
  const DialogTemplateM3();

  @override
  String get name => 'Dialog';

  @override
  String get parentFilePath => 'dialog.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends DialogThemeData {
  $className(this.context)
    : super(
        alignment: Alignment.center,
        elevation: ${number(TokenDialog.containerElevation)},
        shape: ${shape(TokenDialog.containerShape)},
        clipBehavior: Clip.none,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get iconColor => ${color(TokenDialog.withIconIconColor)};

  @override
  Color? get backgroundColor => ${color(TokenDialog.containerColor)};

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  TextStyle? get titleTextStyle => ${textStyle(TokenDialog.headlineType, '_textTheme')};

  @override
  TextStyle? get contentTextStyle => ${textStyle(TokenDialog.supportingTextType, '_textTheme')};

  @override
  EdgeInsetsGeometry? get actionsPadding => const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0);
}
''';
}

class DialogFullscreenTemplateM3 extends TokenTemplateM3 {
  const DialogFullscreenTemplateM3();

  @override
  String get name => 'Dialog Fullscreen';

  @override
  String get parentFilePath => 'dialog.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends DialogThemeData {
  const $className(this.context): super(clipBehavior: Clip.none);

  final BuildContext context;

  @override
  Color? get backgroundColor => ${color(TokenFullScreenDialog.containerColor, 'Theme.of(context).colorScheme')};
}
''';
}
