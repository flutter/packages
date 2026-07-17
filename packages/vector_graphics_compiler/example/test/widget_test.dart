// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler_example/main.dart';

void main() {
  testWidgets('ExampleApp renders the Dart logo VectorGraphic', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const ExampleApp());
      await tester.pumpAndSettle();

      // Verify the VectorGraphic widget is present in the tree.
      final Finder vectorGraphicFinder = find.byType(VectorGraphic);
      expect(vectorGraphicFinder, findsOneWidget);

      final VectorGraphic vectorGraphic = tester.widget<VectorGraphic>(vectorGraphicFinder);
      expect(vectorGraphic.loader, isA<AssetBytesLoader>());
      expect((vectorGraphic.loader as AssetBytesLoader).assetName, 'assets/dart_logo.svg');
      expect(vectorGraphic.semanticsLabel, 'Dart logo');

      // Verify accessibility semantics.
      expect(find.bySemanticsLabel('Dart logo'), findsOneWidget);

      // Verify layout constraints.
      final SizedBox sizedBox = tester.widget<SizedBox>(
        find.ancestor(of: vectorGraphicFinder, matching: find.byType(SizedBox)).first,
      );
      expect(sizedBox.width, 200);
      expect(sizedBox.height, 200);
    } finally {
      handle.dispose();
    }
  });
}
