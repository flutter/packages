// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';

import 'messages.g.dart';

/// Converts method channel call [data] for `receivedImageStreamData` to a
/// [CameraImageData].
CameraImageData cameraImageFromPlatformData(PlatformCameraImageData data) {
  return CameraImageData(
    format: _cameraImageFormatFromPlatformImageFormat(data.formatCode),
    width: data.width,
    height: data.height,
    lensAperture: data.lensAperture,
    sensorExposureTime: data.sensorExposureTimeNanoseconds,
    sensorSensitivity: data.sensorSensitivity,
    planes: List<CameraImagePlane>.unmodifiable(
      data.planes.map<CameraImagePlane>(
        (PlatformCameraImagePlane planeData) =>
            _cameraImagePlaneFromPlatformData(planeData),
      ),
    ),
  );
}

CameraImageFormat _cameraImageFormatFromPlatformImageFormat(int data) {
  return CameraImageFormat(
    _imageFormatGroupFromPlatformImageFormat(data),
    raw: data,
  );
}

ImageFormatGroup _imageFormatGroupFromPlatformImageFormat(int data) {
  switch (data) {
    case 875704438: // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
      return ImageFormatGroup.yuv420;

    case 1111970369: // kCVPixelFormatType_32BGRA
      return ImageFormatGroup.bgra8888;
  }

  return ImageFormatGroup.unknown;
}

CameraImagePlane _cameraImagePlaneFromPlatformData(
  PlatformCameraImagePlane data,
) {
  return CameraImagePlane(
    bytes: data.bytes,
    bytesPerRow: data.bytesPerRow,
    width: data.width,
    height: data.height,
  );
}
