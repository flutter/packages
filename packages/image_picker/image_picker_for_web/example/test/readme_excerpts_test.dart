// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web_integration_tests/readme_excerpts.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  testWidgets('getImageFromPath loads image from XFile path',
      (WidgetTester tester) async {
    final XFile file = createXFileWeb();

    // Use the excerpt code to get an Image from the XFile path.
    final Image image = getImageFromPath(file);

    // Create a simple widget with the Image.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: image,
      ),
    ));

    // Check if Image widget is present.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('getImageFromBytes loads image from XFile bytes',
      (WidgetTester tester) async {
    final XFile file = createXFileWeb();

    // Use the excerpt code to get an Image from the XFile byte data.
    final Image image = await getImageFromBytes(file);

    // Create a simple widget with the Image.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: image,
      ),
    ));

    // Check if Image widget is present.
    expect(find.byType(Image), findsOneWidget);
  });
}

XFile createXFileWeb() {
  const String content = '1001';
  final Uint8List data = Uint8List.fromList(content.codeUnits);
  return XFile.fromData(data,
      name: 'identity.png', lastModified: DateTime.now());
}
