// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/sheet_bottom.dart';
import 'template.dart';

class BottomSheetTemplateM3 extends TokenTemplateM3 {
  const BottomSheetTemplateM3();

  @override
  String get name => 'Bottom Sheet';

  @override
  String get parentFilePath => 'bottom_sheet.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends BottomSheetThemeData {
  $className(this.context)
    : super(
      elevation: ${number(TokenSheetBottom.dockedStandardContainerElevation)},
      modalElevation: ${number(TokenSheetBottom.dockedModalContainerElevation)},
      shape: ${shape(TokenSheetBottom.dockedContainerShape)},
      constraints: const BoxConstraints(maxWidth: 640),
    );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get backgroundColor => ${color(TokenSheetBottom.dockedContainerColor, '_colors')};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get dragHandleColor => ${color(TokenSheetBottom.dockedDragHandleColor, '_colors')};

  @override
  Size? get dragHandleSize => const Size(${number(TokenSheetBottom.dockedDragHandleWidth)}, ${number(TokenSheetBottom.dockedDragHandleHeight)});

  @override
  BoxConstraints? get constraints => const BoxConstraints(maxWidth: 640.0);
}
''';
}
