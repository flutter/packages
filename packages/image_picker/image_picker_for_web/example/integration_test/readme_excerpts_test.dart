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
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getImageFromPath loads image from XFile path',
      (WidgetTester tester) async {
    final XFile file = createXFileWeb();

    // Use the excerpt code to get an Image from the XFile path.
    final Image image = getImageFromPath(file);

    await pumpImage(tester, image);

    // Check if Image widget is present.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('getImageFromBytes loads image from XFile bytes',
      (WidgetTester tester) async {
    final XFile file = createXFileWeb();

    // Use the excerpt code to get an Image from the XFile byte data.
    final Image image = await getImageFromBytes(file);

    await pumpImage(tester, image);

    // Check if Image widget is present.
    expect(find.byType(Image), findsOneWidget);
  });
}

/// Creates an XFile with a 1x1 png file.
XFile createXFileWeb() {
  const String pixel = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR'
      '42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
  final Uint8List data = base64Decode(pixel);
  return XFile.fromData(
    data,
    name: 'identity.png',
    mimeType: 'image/png',
    lastModified: DateTime.now(),
  );
}

/// Pumps an [image] widget into a [tester].
Future<void> pumpImage(WidgetTester tester, Image image) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: image,
    ),
  ));
}
