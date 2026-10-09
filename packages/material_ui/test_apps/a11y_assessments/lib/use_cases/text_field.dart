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
    final int? maxLines = MediaQuery.textScalerOf(context).scale(1.0) > 1.0 ? null : 1;
    return Scaffold(
      appBar: AppBar(title: Semantics(headingLevel: 1, child: Text('$pageTitle Demo'))),
      body: ListView(
        children: <Widget>[
          Semantics(
            label: 'Input field with suffix @gmail.com',
            child: TextField(
              key: const Key('enabled text field'),
              maxLines: maxLines,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                suffixText: '@gmail.com',
                hintText: 'Enter your email',
              ),
            ),
          ),
          Semantics(
            label: 'Input field with suffix @gmail.com',
            child: TextField(
              key: const Key('disabled text field'),
              maxLines: maxLines,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                suffixText: '@gmail.com',
                hintText: 'Enter your email',
              ),
              enabled: false,
              controller: TextEditingController(text: 'xyz'),
            ),
          ),
        ],
      ),
    );
  }
}
