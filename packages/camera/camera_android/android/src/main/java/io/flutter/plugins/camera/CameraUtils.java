// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.Context;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import java.util.ArrayList;
import java.util.List;

/** Provides various utilities for camera. */
public final class CameraUtils {

  private CameraUtils() {}

  /**
   * Gets the {@link CameraManager} singleton.
   *
   * @param context The context to get the {@link CameraManager} singleton from.
   * @return The {@link CameraManager} singleton.
   */
  static CameraManager getCameraManager(Context context) {
    return (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
  }

  /**
   * Serializes the {@link PlatformChannel.DeviceOrientation} to a string value.
   *
   * @param orientation The orientation to serialize.
   * @return The serialized orientation.
   * @throws UnsupportedOperationException when the provided orientation not have a corresponding
   *     string value.
   */
  static String serializeDeviceOrientation(PlatformChannel.DeviceOrientation orientation) {
    if (orientation == null)
      throw new UnsupportedOperationException("Could not serialize null device orientation.");
    switch (orientation) {
      case PORTRAIT_UP:
        return "portraitUp";
      case PORTRAIT_DOWN:
        return "portraitDown";
      case LANDSCAPE_LEFT:
        return "landscapeLeft";
      case LANDSCAPE_RIGHT:
        return "landscapeRight";
      default:
        throw new UnsupportedOperationException(
            "Could not serialize device orientation: " + orientation.toString());
    }
  }

  /**
   * Deserializes a string value to its corresponding {@link PlatformChannel.DeviceOrientation}
   * value.
   *
   * @param orientation The string value to deserialize.
   * @return The deserialized orientation.
   * @throws UnsupportedOperationException when the provided string value does not have a
   *     corresponding {@link PlatformChannel.DeviceOrientation}.
   */
  static PlatformChannel.DeviceOrientation deserializeDeviceOrientation(String orientation) {
    if (orientation == null)
      throw new UnsupportedOperationException("Could not deserialize null device orientation.");
    switch (orientation) {
      case "portraitUp":
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
      case "portraitDown":
        return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
      case "landscapeLeft":
        return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
      case "landscapeRight":
        return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
      default:
        throw new UnsupportedOperationException(
            "Could not deserialize device orientation: " + orientation);
    }
  }

  /**
   * Converts a raw integer to a PlatformCameraLensDirection enum.
   *
   * @param lensDirection One of CameraMetadata.LENS_FACING_FRONT, LENS_FACING_BACK, or
   *     LENS_FACING_EXTERNAL.
   * @return One of Messages.PlatformCameraLensDirection.FRONT, BACK, or EXTERNAL.
   */
  static Messages.PlatformCameraLensDirection lensDirectionFromInteger(int lensDirection) {
    switch (lensDirection) {
      case CameraMetadata.LENS_FACING_FRONT:
        return Messages.PlatformCameraLensDirection.FRONT;
      case CameraMetadata.LENS_FACING_BACK:
        return Messages.PlatformCameraLensDirection.BACK;
      case CameraMetadata.LENS_FACING_EXTERNAL:
        return Messages.PlatformCameraLensDirection.EXTERNAL;
    }
    // CameraMetadata is defined in the Android API. In the event that a new value is added, a
    // default fallback value of FRONT is returned.
    return Messages.PlatformCameraLensDirection.FRONT;
  }

  /**
   * Gets all the available cameras for the device.
   *
   * @param activity The current Android activity.
   * @return A map of all the available cameras, with their name as their key.
   * @throws CameraAccessException when the camera could not be accessed.
   */
  @NonNull
  public static List<Messages.PlatformCameraDescription> getAvailableCameras(
      @NonNull Activity activity) throws CameraAccessException {
    CameraManager cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
    String[] cameraNames = cameraManager.getCameraIdList();
    List<Messages.PlatformCameraDescription> cameras = new ArrayList<>();
    for (String cameraName : cameraNames) {
      int cameraId;
      try {
        cameraId = Integer.parseInt(cameraName, 10);
      } catch (NumberFormatException e) {
        cameraId = -1;
      }
      if (cameraId < 0) {
        continue;
      }

      CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
      int sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);

      int lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING);
      Messages.PlatformCameraLensDirection lensDirection = lensDirectionFromInteger(lensFacing);
      Messages.PlatformCameraDescription details =
          new Messages.PlatformCameraDescription.Builder()
              .setName(cameraName)
              .setSensorOrientation((long) sensorOrientation)
              .setLensDirection(lensDirection)
              .build();
      cameras.add(details);
    }
    return cameras;
  }
}
