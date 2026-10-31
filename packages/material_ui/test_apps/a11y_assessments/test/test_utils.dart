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

/// The WCAG contrast ratio between two colors, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// The color the given text is painted with, after default styles are applied.
Color paintedTextColor(WidgetTester tester, Finder text) {
  final RichText richText = tester.widget<RichText>(
    find.descendant(of: text, matching: find.byType(RichText)),
  );
  return richText.text.style!.color!;
}
