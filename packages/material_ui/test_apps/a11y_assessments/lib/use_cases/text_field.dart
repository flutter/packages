// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import '../utils.dart';
import 'use_cases.dart';

class TextFieldUseCase extends UseCase {
  TextFieldUseCase();

  @override
  String get name => 'TextField';

  @override
  String get route => '/text-field';

  @override
  List<Tag> get tags => <Tag>[Tag.batch1, Tag.core];

  @override
  Widget build(BuildContext context) => _MainWidget();
}

class _MainWidget extends StatelessWidget {
  _MainWidget();

  final String pageTitle = getUseCaseName(TextFieldUseCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Semantics(headingLevel: 1, child: Text('$pageTitle Demo'))),
      body: ListView(
        semanticChildCount: 0,
        addSemanticIndexes: false,
        children: <Widget>[
          const TextField(
            key: Key('enabled text field'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: <String>[AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              // The field is single-line, so let the hint wrap at large
              // text scales, one line per word.
              hintMaxLines: 3,
            ),
          ),
          TextField(
            key: const Key('disabled text field'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              // The field is single-line, so let the hint wrap at large
              // text scales, one line per word.
              hintMaxLines: 3,
            ),
            enabled: false,
            controller: TextEditingController(text: 'xyz'),
          ),
        ],
      ),
    );
  }
}
