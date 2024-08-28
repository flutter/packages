// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';

/// Converts method channel call [data] for `receivedImageStreamData` to a
/// [CameraImageData].
CameraImageData cameraImageFromPlatformData(Map<dynamic, dynamic> data) {
  return CameraImageData(
      format: const CameraImageFormat(ImageFormatGroup.bgra8888, raw: 0),
      height: data['height'] as int,
      width: data['width'] as int,
      lensAperture: data['lensAperture'] as double?,
      sensorExposureTime: data['sensorExposureTime'] as int?,
      sensorSensitivity: data['sensorSensitivity'] as double?,
      planes: <CameraImagePlane>[
        CameraImagePlane(
          bytes: data['data'] as Uint8List,
          bytesPerRow: (data['width'] as int) * 4,
        )
      ]);
}
