// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:camera_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test snackbar', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(const CameraApp());
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('CameraDescription toggles will not overflow', (
    WidgetTester tester,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    // Adds 10 fake camera descriptions.
    for (var i = 0; i < 10; i++) {
      cameras.add(
        CameraDescription(
          name: 'camera_$i',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
      );
    }
    await tester.pumpWidget(const CameraApp());
    await tester.pumpAndSettle();
  });
}
