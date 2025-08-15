// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../types/types.dart';

/// Converts method channel call [data] for `receivedImageStreamData` to a
/// [CameraImageData].
CameraImageData cameraImageFromPlatformData(Map<dynamic, dynamic> data) {
  return CameraImageData(
      format: _cameraImageFormatFromPlatformData(data['format']),
      height: data['height'] as int,
      width: data['width'] as int,
      lensAperture: data['lensAperture'] as double?,
      sensorExposureTime: data['sensorExposureTime'] as int?,
      sensorSensitivity: data['sensorSensitivity'] as double?,
      planes: List<CameraImagePlane>.unmodifiable(
          (data['planes'] as List<dynamic>).map<CameraImagePlane>(
              (dynamic planeData) => _cameraImagePlaneFromPlatformData(
                  planeData as Map<dynamic, dynamic>))));
}

CameraImageFormat _cameraImageFormatFromPlatformData(dynamic data) {
  return CameraImageFormat(_imageFormatGroupFromPlatformData(data), raw: data);
}

ImageFormatGroup _imageFormatGroupFromPlatformData(dynamic data) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    switch (data) {
      case 35: // android.graphics.ImageFormat.YUV_420_888
        return ImageFormatGroup.yuv420;
      case 256: // android.graphics.ImageFormat.JPEG
        return ImageFormatGroup.jpeg;
    }
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    switch (data) {
      case 875704438: // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        return ImageFormatGroup.yuv420;

      case 1111970369: // kCVPixelFormatType_32BGRA
        return ImageFormatGroup.bgra8888;
    }
  }

  return ImageFormatGroup.unknown;
}

CameraImagePlane _cameraImagePlaneFromPlatformData(Map<dynamic, dynamic> data) {
  return CameraImagePlane(
      bytes: data['bytes'] as Uint8List,
      bytesPerPixel: data['bytesPerPixel'] as int?,
      bytesPerRow: data['bytesPerRow'] as int,
      height: data['height'] as int?,
      width: data['width'] as int?);
}
