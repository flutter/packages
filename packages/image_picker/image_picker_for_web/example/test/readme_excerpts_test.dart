// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web_integration_tests/readme_excerpts.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  testWidgets('getImageFromPath loads image from XFile path',
      (WidgetTester tester) async {
    // Create an XFile using the test image path.
    final XFile pickedFile = XFile('assets/flutter-mark-square-64.png');

    // Use the excerpt code to get an Image from the XFile path.
    final Image image = getImageFromPath(pickedFile);

    // Create a simple widget with the Image.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: image,
      ),
    ));

    // Check if Image widget is present.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('getImageFromPath loads image from XFile bytes',
      (WidgetTester tester) async {
    // Encode a small Base64 image (1x1 pixel transparent PNG).
    const String base64Image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAYUBjVgJBK4AAAAASUVORK5CYII=';

    // Decode the Base64 string to bytes.
    final Uint8List bytes = base64Decode(base64Image);

    // Create an XFile from the byte data.
    final XFile pickedFile = XFile.fromData(bytes);

    // Use the excerpt code to get an Image from the XFile byte data.
    final Image image = await getImageFromBytes(pickedFile);

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
