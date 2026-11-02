// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/extended_fab.dart';
import '../data/fab.dart';
import '../data/fab_large.dart';
import '../data/fab_primary_container.dart';
import '../data/fab_small.dart';
import 'template.dart';

class FabTemplateM3 extends TokenTemplateM3 {
  const FabTemplateM3();

  @override
  String get name => 'FAB';

  @override
  String get parentFilePath => 'floating_action_button.dart';

  @override
  String get className => '_FABDefaultsM3';

  @override
  String generateContents(String className) =>
      '''
class $className extends FloatingActionButtonThemeData {
  $className(this.context, this.type, this.hasChild)
    : super(
        elevation: ${number(TokenFabPrimaryContainer.containerElevation)},
        focusElevation: ${number(TokenFabPrimaryContainer.focusedContainerElevation)},
        hoverElevation: ${number(TokenFabPrimaryContainer.hoveredContainerElevation)},
        highlightElevation: ${number(TokenFabPrimaryContainer.pressedContainerElevation)},
        enableFeedback: true,
        sizeConstraints: const BoxConstraints.tightFor(
          width: ${number(TokenFab.containerWidth)},
          height: ${number(TokenFab.containerHeight)},
        ),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: ${number(TokenFabSmall.containerWidth)},
          height: ${number(TokenFabSmall.containerHeight)},
        ),
        largeSizeConstraints: const BoxConstraints.tightFor(
          width: ${number(TokenFabLarge.containerWidth)},
          height: ${number(TokenFabLarge.containerHeight)},
        ),
        extendedSizeConstraints: const BoxConstraints.tightFor(
          height: ${number(TokenExtendedFab.containerHeight)},
        ),
        extendedIconLabelSpacing: 8.0,
      );

  final BuildContext context;
  final _FloatingActionButtonType type;
  final bool hasChild;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  bool get _isExtended => type == _FloatingActionButtonType.extended;

  @override Color? get foregroundColor => ${color(TokenFabPrimaryContainer.iconColor)};
  @override Color? get backgroundColor => ${color(TokenFabPrimaryContainer.containerColor)};
  @override Color? get splashColor => ${colorWithOpacity(TokenFabPrimaryContainer.pressedStateLayerColor, TokenFabPrimaryContainer.pressedStateLayerOpacity)};
  @override Color? get focusColor => ${colorWithOpacity(TokenFabPrimaryContainer.focusedStateLayerColor, TokenFabPrimaryContainer.focusedStateLayerOpacity)};
  @override Color? get hoverColor => ${colorWithOpacity(TokenFabPrimaryContainer.hoveredStateLayerColor, TokenFabPrimaryContainer.hoveredStateLayerOpacity)};

  @override
  ShapeBorder? get shape => switch (type) {
    _FloatingActionButtonType.regular  => ${shape(TokenFab.containerShape)},
    _FloatingActionButtonType.small    => ${shape(TokenFabSmall.containerShape)},
    _FloatingActionButtonType.large    => ${shape(TokenFabLarge.containerShape)},
    _FloatingActionButtonType.extended => ${shape(TokenExtendedFab.containerShape)},
  };

  @override
  double? get iconSize => switch (type) {
    _FloatingActionButtonType.regular  => ${number(TokenFab.iconSize)},
    _FloatingActionButtonType.small    => ${number(TokenFabSmall.iconSize)},
    _FloatingActionButtonType.large    => ${number(TokenFabLarge.iconSize)},
    _FloatingActionButtonType.extended => ${number(TokenExtendedFab.iconSize)},
  };

  @override EdgeInsetsGeometry? get extendedPadding => EdgeInsetsDirectional.only(start: hasChild && _isExtended ? ${number(TokenExtendedFab.leadingSpace)} : ${number(TokenExtendedFab.trailingSpace)}, end: ${number(TokenExtendedFab.trailingSpace)});
  @override TextStyle? get extendedTextStyle => ${textStyle(TokenExtendedFab.labelText, '_textTheme')};
}
''';
}
