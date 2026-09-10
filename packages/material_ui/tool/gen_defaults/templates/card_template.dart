// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/elevated_card.dart';
import '../data/filled_card.dart';
import '../data/outlined_card.dart';
import '../data/shape_struct.dart';
import 'template.dart';

enum _CardVariant { elevated, filled, outlined }

class CardTemplateM3 extends TokenTemplateM3 {
  const CardTemplateM3(this.name);

  @override
  final String name;

  @override
  String get parentFilePath => 'card.dart';

  _CardVariant get _variant => switch (name) {
    'Card' => _CardVariant.elevated,
    'Filled Card' => _CardVariant.filled,
    'Outlined Card' => _CardVariant.outlined,
    _ => throw UnsupportedError('Unsupported card template name: $name'),
  };

  double get _containerElevation => switch (_variant) {
    _CardVariant.elevated => TokenElevatedCard.containerElevation,
    _CardVariant.filled => TokenFilledCard.containerElevation,
    _CardVariant.outlined => TokenOutlinedCard.containerElevation,
  };

  TokenColorRole get _containerColor => switch (_variant) {
    _CardVariant.elevated => TokenElevatedCard.containerColor,
    _CardVariant.filled => TokenFilledCard.containerColor,
    _CardVariant.outlined => TokenOutlinedCard.containerColor,
  };

  TokenColorRole get _containerShadowColor => switch (_variant) {
    _CardVariant.elevated => TokenElevatedCard.containerShadowColor,
    _CardVariant.filled => TokenFilledCard.containerShadowColor,
    _CardVariant.outlined => TokenOutlinedCard.containerShadowColor,
  };

  ShapeStruct get _containerShape => switch (_variant) {
    _CardVariant.elevated => TokenElevatedCard.containerShape,
    _CardVariant.filled => TokenFilledCard.containerShape,
    _CardVariant.outlined => TokenOutlinedCard.containerShape,
  };

  String get _shape {
    final String cardShape = shape(_containerShape);
    if (_variant != _CardVariant.outlined) {
      return cardShape;
    }
    return '''
$cardShape.copyWith(
  side: ${border(color(TokenOutlinedCard.outlineColor, '_colors'))},
)''';
  }

  @override
  String generateContents(String className) =>
      '''
class $className extends CardThemeData {
  $className(this.context)
    : super(
        clipBehavior: Clip.none,
        elevation: ${number(_containerElevation)},
        margin: const EdgeInsets.all(4.0),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => ${color(_containerColor, '_colors')};

  @override
  Color? get shadowColor => ${color(_containerShadowColor, '_colors')};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape => $_shape;
}
''';
}
