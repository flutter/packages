// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/snackbar.dart';
import 'template.dart';

class SnackbarTemplateM3 extends TokenTemplateM3 {
  const SnackbarTemplateM3();

  @override
  String get name => 'Snackbar';

  @override
  String get parentFilePath => 'snack_bar.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends SnackBarThemeData {
    $className(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor => ${color(TokenSnackbar.containerColor)};

  @override
  Color get actionTextColor =>  WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ${color(TokenSnackbar.actionPressedLabelTextColor)};
    }
    if (states.contains(WidgetState.pressed)) {
      return ${color(TokenSnackbar.actionPressedLabelTextColor)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${color(TokenSnackbar.actionHoverLabelTextColor)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${color(TokenSnackbar.actionFocusLabelTextColor)};
    }
    return ${color(TokenSnackbar.actionLabelTextColor)};
  });

  @override
  Color get disabledActionTextColor =>
    ${color(TokenSnackbar.actionPressedLabelTextColor)};


  @override
  TextStyle get contentTextStyle =>
    ${textStyle(TokenSnackbar.supportingTextType, 'Theme.of(context).textTheme')}!.copyWith
      (color:  ${color(TokenSnackbar.supportingTextColor)},
    );

  @override
  double get elevation => ${TokenSnackbar.containerElevation};

  @override
  ShapeBorder get shape => ${shape(TokenSnackbar.containerShape)};

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  EdgeInsets get insetPadding => const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color? get closeIconColor => ${color(TokenSnackbar.iconColor)};

  @override
  double get actionOverflowThreshold => 0.25;
}
''';
}
