// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/filled_text_field.dart';
import '../data/outlined_text_field.dart';
import 'template.dart';

class InputDecoratorTemplateM3 extends TokenTemplateM3 {
  const InputDecoratorTemplateM3();

  @override
  String get name => 'Input Decorator';

  @override
  String get parentFilePath => 'input_decorator.dart';

  // TODO(QuncCccccc): Use TokenOutlinedTextField.focusOutlineWidth when
  // InputDecorator adopts the latest 3.0 token value.
  static const double _legacyFocusedOutlineWidth = 2.0;

  @override
  String generateContents(String className) =>
      '''
class $className extends InputDecorationThemeData {
  $className(this.context) : super();

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  // For InputDecorator, focused state should take precedence over hovered state.
  // For instance, the focused state increases border width (2dp) and applies bright
  // colors (primary color or error color) while the hovered state has the same border
  // than the non-focused state (1dp) and uses a color a little darker than non-focused
  // state. On desktop, it is also very common that a text field is focused and hovered
  // because users often rely on mouse selection.
  // For other widgets, hovered state takes precedence over focused state, because it
  // is mainly used to determine the overlay color,
  // see https://github.com/flutter/flutter/pull/125905.

  @override
  TextStyle? get hintStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return TextStyle(color: ${colorWithOpacity(TokenFilledTextField.disabledSupportingTextColor, TokenFilledTextField.disabledSupportingTextOpacity)});
    }
    return TextStyle(color: ${color(TokenFilledTextField.supportingTextColor)});
  });

  @override
  Color? get fillColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ${colorWithOpacity(TokenFilledTextField.disabledContainerColor, TokenFilledTextField.disabledContainerOpacity)};
    }
    return ${color(TokenFilledTextField.containerColor)};
  });

  @override
  BorderSide? get activeIndicatorBorder => WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ${border(colorWithOpacity(TokenFilledTextField.disabledActiveIndicatorColor, TokenFilledTextField.disabledActiveIndicatorOpacity), width: TokenFilledTextField.disabledActiveIndicatorHeight)};
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return ${border(color(TokenFilledTextField.errorFocusActiveIndicatorColor), width: TokenFilledTextField.focusActiveIndicatorHeight)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${border(color(TokenFilledTextField.errorHoverActiveIndicatorColor))};
      }
      return ${border(color(TokenFilledTextField.errorActiveIndicatorColor))};
    }
    if (states.contains(WidgetState.focused)) {
      return ${border(color(TokenFilledTextField.focusActiveIndicatorColor), width: TokenFilledTextField.focusActiveIndicatorHeight)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${border(color(TokenFilledTextField.hoverActiveIndicatorColor), width: TokenFilledTextField.hoverActiveIndicatorHeight)};
    }
    return ${border(color(TokenFilledTextField.activeIndicatorColor), width: TokenFilledTextField.activeIndicatorHeight)};
  });

  @override
  BorderSide? get outlineBorder => WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ${border(colorWithOpacity(TokenOutlinedTextField.disabledOutlineColor, TokenOutlinedTextField.disabledOutlineOpacity), width: TokenOutlinedTextField.disabledOutlineWidth)};
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return ${border(color(TokenOutlinedTextField.errorFocusOutlineColor), width: _legacyFocusedOutlineWidth)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${border(color(TokenOutlinedTextField.errorHoverOutlineColor))};
      }
      return ${border(color(TokenOutlinedTextField.errorOutlineColor))};
    }
    if (states.contains(WidgetState.focused)) {
      return ${border(color(TokenOutlinedTextField.focusOutlineColor), width: _legacyFocusedOutlineWidth)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${border(color(TokenOutlinedTextField.hoverOutlineColor), width: TokenOutlinedTextField.hoverOutlineWidth)};
    }
    return ${border(color(TokenOutlinedTextField.outlineColor), width: TokenOutlinedTextField.outlineWidth)};
  });

  @override
  Color? get iconColor => ${color(TokenFilledTextField.leadingIconColor)};

  @override
  Color? get prefixIconColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ${colorWithOpacity(TokenFilledTextField.disabledLeadingIconColor, TokenFilledTextField.disabledLeadingIconOpacity)};
    }
    return ${color(TokenFilledTextField.leadingIconColor)};
  });

  @override
  Color? get suffixIconColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ${colorWithOpacity(TokenFilledTextField.disabledTrailingIconColor, TokenFilledTextField.disabledTrailingIconOpacity)};
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenFilledTextField.errorHoverTrailingIconColor)};
      }
      return ${color(TokenFilledTextField.errorTrailingIconColor)};
    }
    return ${color(TokenFilledTextField.trailingIconColor)};
  });

  @override
  TextStyle? get labelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = ${textStyle(TokenFilledTextField.labelTextType, '_textTheme')} ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: ${colorWithOpacity(TokenFilledTextField.disabledLabelTextColor, TokenFilledTextField.disabledLabelTextOpacity)});
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return textStyle.copyWith(color: ${color(TokenFilledTextField.errorFocusLabelTextColor)});
      }
      if (states.contains(WidgetState.hovered)) {
        return textStyle.copyWith(color: ${color(TokenFilledTextField.errorHoverLabelTextColor)});
      }
      return textStyle.copyWith(color: ${color(TokenFilledTextField.errorLabelTextColor)});
    }
    if (states.contains(WidgetState.focused)) {
      return textStyle.copyWith(color: ${color(TokenFilledTextField.focusLabelTextColor)});
    }
    if (states.contains(WidgetState.hovered)) {
      return textStyle.copyWith(color: ${color(TokenFilledTextField.hoverLabelTextColor)});
    }
    return textStyle.copyWith(color: ${color(TokenFilledTextField.labelTextColor)});
  });

  @override
  TextStyle? get floatingLabelStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = ${textStyle(TokenFilledTextField.labelTextType, '_textTheme')} ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: ${colorWithOpacity(TokenFilledTextField.disabledLabelTextColor, TokenFilledTextField.disabledLabelTextOpacity)});
    }
    if (states.contains(WidgetState.error)) {
      if (states.contains(WidgetState.focused)) {
        return textStyle.copyWith(color: ${color(TokenFilledTextField.errorFocusLabelTextColor)});
      }
      if (states.contains(WidgetState.hovered)) {
        return textStyle.copyWith(color: ${color(TokenFilledTextField.errorHoverLabelTextColor)});
      }
      return textStyle.copyWith(color: ${color(TokenFilledTextField.errorLabelTextColor)});
    }
    if (states.contains(WidgetState.focused)) {
      return textStyle.copyWith(color: ${color(TokenFilledTextField.focusLabelTextColor)});
    }
    if (states.contains(WidgetState.hovered)) {
      return textStyle.copyWith(color: ${color(TokenFilledTextField.hoverLabelTextColor)});
    }
    return textStyle.copyWith(color: ${color(TokenFilledTextField.labelTextColor)});
  });

  @override
  TextStyle? get helperStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = ${textStyle(TokenFilledTextField.supportingTextType, '_textTheme')} ?? const TextStyle();
    if (states.contains(WidgetState.disabled)) {
      return textStyle.copyWith(color: ${colorWithOpacity(TokenFilledTextField.disabledSupportingTextColor, TokenFilledTextField.disabledSupportingTextOpacity)});
    }
    return textStyle.copyWith(color: ${color(TokenFilledTextField.supportingTextColor)});
  });

  @override
  TextStyle? get errorStyle => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    final TextStyle textStyle = ${textStyle(TokenFilledTextField.supportingTextType, '_textTheme')} ?? const TextStyle();
    return textStyle.copyWith(color: ${color(TokenFilledTextField.errorSupportingTextColor)});
  });
}
''';
}
