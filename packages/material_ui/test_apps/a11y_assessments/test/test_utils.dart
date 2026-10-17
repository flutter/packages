// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:a11y_assessments/use_cases/use_cases.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> pumpsUseCase(WidgetTester tester, UseCase useCase) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return useCase.buildWithTitle(context);
        },
      ),
    ),
  );
}

List<String> descendantSemanticsLabels(SemanticsNode node) {
  final labels = <String>[];
  node.visitChildren((SemanticsNode child) {
    labels.add(child.label);
    labels.addAll(descendantSemanticsLabels(child));
    return true;
  });
  return labels;
}
