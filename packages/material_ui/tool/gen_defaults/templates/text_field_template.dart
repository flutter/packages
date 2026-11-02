// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/filled_text_field.dart';
import 'template.dart';

class TextFieldTemplateM3 extends TokenTemplateM3 {
  const TextFieldTemplateM3();

  @override
  String get name => 'Text Field';

  @override
  String get parentFilePath => 'text_field.dart';

  @override
  String get className => '';

  @override
  String generateContents(String className) =>
      '''
TextStyle? _m3StateInputStyle(BuildContext context) => WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return TextStyle(color: ${textStyle(TokenFilledTextField.labelTextType, 'Theme.of(context).textTheme')}!.color?.withOpacity(${TokenFilledTextField.disabledLabelTextOpacity}));
  }
  return TextStyle(color: ${textStyle(TokenFilledTextField.labelTextType, 'Theme.of(context).textTheme')}!.color);
});

TextStyle _m3InputStyle(BuildContext context) => ${textStyle(TokenFilledTextField.labelTextType, 'Theme.of(context).textTheme')}!;

TextStyle _m3CounterErrorStyle(BuildContext context) =>
  ${textStyle(TokenFilledTextField.supportingTextType, 'Theme.of(context).textTheme')}!.copyWith(color: ${color(TokenFilledTextField.errorSupportingTextColor, 'Theme.of(context).colorScheme')});
''';
}
