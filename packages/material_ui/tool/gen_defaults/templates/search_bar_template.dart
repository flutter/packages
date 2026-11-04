// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/search_bar.dart';
import 'template.dart';

class SearchBarTemplateM3 extends TokenTemplateM3 {
  const SearchBarTemplateM3();

  @override
  String get name => 'Search Bar';

  @override
  String get parentFilePath => 'search_anchor.dart';

  // TODO(QuncCccccc): Replace this value if a focused state layer token becomes available.
  static const String _legacyFocusedStateLayerColor = 'Colors.transparent';

  @override
  String generateContents(String className) =>
      '''
class $className extends SearchBarThemeData {
  $className(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
    MaterialStatePropertyAll<Color>(${color(TokenSearchBar.containerColor)});

  @override
  WidgetStateProperty<double>? get elevation =>
    const MaterialStatePropertyAll<double>(${TokenSearchBar.containerElevation});

  @override
  WidgetStateProperty<Color>? get shadowColor =>
    MaterialStatePropertyAll<Color>(_colors.shadow);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
    const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenSearchBar.pressedStateLayerColor, TokenSearchBar.pressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenSearchBar.hoverStateLayerColor, TokenSearchBar.hoverStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return $_legacyFocusedStateLayerColor;
      }
      return Colors.transparent;
    });

  // No default side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
    const MaterialStatePropertyAll<OutlinedBorder>(${shape(TokenSearchBar.containerShape, '')});

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
    const MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 8.0));

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
    MaterialStatePropertyAll<TextStyle?>(${textStyle(TokenSearchBar.inputTextType, '_textTheme')}?.copyWith(
      color: ${color(TokenSearchBar.inputTextColor)},
    ));

  @override
  WidgetStateProperty<TextStyle?> get hintStyle =>
    MaterialStatePropertyAll<TextStyle?>(${textStyle(TokenSearchBar.supportingTextType, '_textTheme')}?.copyWith(
      color: ${color(TokenSearchBar.supportingTextColor)},
    ));

  @override
  BoxConstraints get constraints =>
    const BoxConstraints(minWidth: 360.0, maxWidth: 800.0, minHeight: ${TokenSearchBar.containerHeight});

  @override
  TextCapitalization get textCapitalization => TextCapitalization.none;
}
''';
}
