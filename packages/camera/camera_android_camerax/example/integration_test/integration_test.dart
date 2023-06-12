// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui';

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax_example/camera_controller.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    CameraPlatform.instance = AndroidCameraCameraX();
  });

  testWidgets('availableCameras only supports valid back or front cameras',
      (WidgetTester tester) async {
    final List<CameraDescription> availableCameras =
        await CameraPlatform.instance.availableCameras();

    for (final CameraDescription cameraDescription in availableCameras) {
      expect(
          cameraDescription.lensDirection, isNot(CameraLensDirection.external));
      expect(cameraDescription.sensorOrientation, anyOf(0, 90, 180, 270));
    }
  });

  testWidgets('takePictures stores a valid image in memory',
      (WidgetTester tester) async {
    final List<CameraDescription> availableCameras =
        await CameraPlatform.instance.availableCameras();
    if (availableCameras.isEmpty) {
      return;
    }
    for (final CameraDescription cameraDescription in availableCameras) {
      final CameraController controller =
          CameraController(cameraDescription, ResolutionPreset.high);
      await controller.initialize();

      // Take Picture
      final XFile file = await controller.takePicture();

      // Try loading picture
      final File fileImage = File(file.path);
      final Image image =
          await decodeImageFromList(fileImage.readAsBytesSync());

      expect(image, isNotNull);
    }
  });
}
