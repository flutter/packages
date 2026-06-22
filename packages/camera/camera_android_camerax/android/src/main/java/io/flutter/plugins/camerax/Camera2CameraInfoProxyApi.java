// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraMetadata;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.camera.camera2.interop.Camera2CameraInfo;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.CameraInfo;

/**
 * ProxyApi implementation for {@link Camera2CameraInfo}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
@OptIn(markerClass = ExperimentalCamera2Interop.class)
class Camera2CameraInfoProxyApi extends PigeonApiCamera2CameraInfo {
  Camera2CameraInfoProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public Camera2CameraInfo from(@NonNull CameraInfo cameraInfo) {
    return Camera2CameraInfo.from(cameraInfo);
  }

  @NonNull
  @Override
  public String getCameraId(Camera2CameraInfo pigeonInstance) {
    return pigeonInstance.getCameraId();
  }

  @Nullable
  @Override
  public Object getCameraCharacteristic(
      Camera2CameraInfo pigeonInstance, @NonNull CameraCharacteristics.Key<?> key) {
    final Object result = pigeonInstance.getCameraCharacteristic(key);
    if (result == null) {
      return null;
    }

    if (CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL.equals(key)) {
      switch ((Integer) result) {
        case CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_3:
          return InfoSupportedHardwareLevel.LEVEL3;
        case CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL:
          return InfoSupportedHardwareLevel.EXTERNAL;
        case CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_FULL:
          return InfoSupportedHardwareLevel.FULL;
        case CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY:
          return InfoSupportedHardwareLevel.LEGACY;
        case CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED:
          return InfoSupportedHardwareLevel.LIMITED;
        default:
          // Fall through to return result.
          break;
      }
    }
    return result;
  }
}
