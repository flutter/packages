// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_avfoundation/camera_avfoundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equals should return false if apple capture device type is different',
      () {
    const CameraDescription firstDescription = AVCameraDescription(
      name: 'Test',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
      captureDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
    );
    const CameraDescription secondDescription = AVCameraDescription(
      name: 'Test',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
      captureDeviceType: AVCaptureDeviceType.builtInUltraWideCamera,
    );

    expect(firstDescription == secondDescription, false);
  });

  test('equals should return false if one apple capture device type is null',
      () {
    const CameraDescription firstDescription = AVCameraDescription(
      name: 'Test',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
      captureDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
    );
    const CameraDescription secondDescription = AVCameraDescription(
      name: 'Test',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
    );

    expect(firstDescription == secondDescription, false);
  });

  test('equals should return true if apple capture device type is null', () {
    const CameraDescription firstDescription = AVCameraDescription(
      name: 'Test',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
    );
    const CameraDescription secondDescription = AVCameraDescription(
      name: 'Test',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
    );

    expect(firstDescription == secondDescription, true);
  });
}
