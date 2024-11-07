// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.features.flash.FlashMode;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
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

  /**
   * Converts a DeviceOrientation from the systemchannels package to a PlatformDeviceOrientation
   * from Pigeon.
   *
   * @param orientation A DeviceOrientation.
   * @return The corresponding PlatformDeviceOrientation.
   */
  @NonNull
  public static Messages.PlatformDeviceOrientation orientationToPigeon(
      @NonNull PlatformChannel.DeviceOrientation orientation) {
    switch (orientation) {
      case PORTRAIT_UP:
        return Messages.PlatformDeviceOrientation.PORTRAIT_UP;
      case PORTRAIT_DOWN:
        return Messages.PlatformDeviceOrientation.PORTRAIT_DOWN;
      case LANDSCAPE_LEFT:
        return Messages.PlatformDeviceOrientation.LANDSCAPE_LEFT;
      case LANDSCAPE_RIGHT:
        return Messages.PlatformDeviceOrientation.LANDSCAPE_RIGHT;
    }
    return Messages.PlatformDeviceOrientation.PORTRAIT_UP;
  }

  /**
   * Converts a PlatformDeviceOrientation from Pigeon to DeviceOrientation from PlatformChannel.
   *
   * @param orientation A PlatformDeviceOrientation
   * @return The corresponding DeviceOrientation. Defaults to PORTRAIT_UP.
   */
  @NonNull
  public static PlatformChannel.DeviceOrientation orientationFromPigeon(
      @NonNull Messages.PlatformDeviceOrientation orientation) {
    switch (orientation) {
      case PORTRAIT_UP:
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
      case PORTRAIT_DOWN:
        return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
      case LANDSCAPE_LEFT:
        return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
      case LANDSCAPE_RIGHT:
        return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
    }
    throw new IllegalStateException("Unreachable code");
  }

  /**
   * Converts a FocusMode from the autofocus package to a PlatformFocusMode from Pigeon.
   *
   * @param focusMode A FocusMode.
   * @return The corresponding PlatformFocusMode.
   */
  @NonNull
  public static Messages.PlatformFocusMode focusModeToPigeon(@NonNull FocusMode focusMode) {
    switch (focusMode) {
      case auto:
        return Messages.PlatformFocusMode.AUTO;
      case locked:
        return Messages.PlatformFocusMode.LOCKED;
    }
    return Messages.PlatformFocusMode.AUTO;
  }

  /**
   * Converts a PlatformFocusMode from Pigeon to a FocusMode from the autofocus package.
   *
   * @param focusMode A PlatformFocusMode.
   * @return The corresponding FocusMode.
   */
  @NonNull
  public static FocusMode focusModeFromPigeon(@NonNull Messages.PlatformFocusMode focusMode) {
    switch (focusMode) {
      case AUTO:
        return FocusMode.auto;
      case LOCKED:
        return FocusMode.locked;
    }
    throw new IllegalStateException("Unreachable code");
  }

  /**
   * Converts an ExposureMode from the exposurelock package to a PlatformExposureMode from Pigeon.
   *
   * @param exposureMode An ExposureMode.
   * @return The corresponding PlatformExposureMode.
   */
  @NonNull
  public static Messages.PlatformExposureMode exposureModeToPigeon(
      @NonNull ExposureMode exposureMode) {
    switch (exposureMode) {
      case auto:
        return Messages.PlatformExposureMode.AUTO;
      case locked:
        return Messages.PlatformExposureMode.LOCKED;
    }
    return Messages.PlatformExposureMode.AUTO;
  }

  /**
   * Converts a PlatformExposureMode to ExposureMode from the exposurelock package.
   *
   * @param mode A PlatformExposureMode.
   * @return The corresponding ExposureMode.
   */
  @NonNull
  public static ExposureMode exposureModeFromPigeon(@NonNull Messages.PlatformExposureMode mode) {
    switch (mode) {
      case AUTO:
        return ExposureMode.auto;
      case LOCKED:
        return ExposureMode.locked;
    }
    throw new IllegalStateException("Unreachable code");
  }

  /**
   * Converts a PlatformResolutionPreset from Pigeon to a ResolutionPreset from the resolution
   * package.
   *
   * @param preset A PlatformResolutionPreset.
   * @return The corresponding ResolutionPreset.
   */
  @NonNull
  public static ResolutionPreset resolutionPresetFromPigeon(
      @NonNull Messages.PlatformResolutionPreset preset) {
    switch (preset) {
      case LOW:
        return ResolutionPreset.low;
      case MEDIUM:
        return ResolutionPreset.medium;
      case HIGH:
        return ResolutionPreset.high;
      case VERY_HIGH:
        return ResolutionPreset.veryHigh;
      case ULTRA_HIGH:
        return ResolutionPreset.ultraHigh;
      case MAX:
        return ResolutionPreset.max;
    }
    throw new IllegalStateException("Unreachable code");
  }

  /**
   * Converts a PlatformImageFormatGroup from Pigeon to an Integer representing an image format.
   *
   * @param format A PlatformImageFormatGroup.
   * @return The corresponding integer code. Defaults to YUV_420_888.
   */
  @NonNull
  public static Integer imageFormatGroupFromPigeon(
      @NonNull Messages.PlatformImageFormatGroup format) {
    switch (format) {
      case YUV420:
        return ImageFormat.YUV_420_888;
      case JPEG:
        return ImageFormat.JPEG;
      case NV21:
        return ImageFormat.NV21;
    }
    throw new IllegalStateException("Unreachable code");
  }

  /**
   * Converts a PlatformFlashMode from Pigeon to a FlashMode from the flash package.
   *
   * @param mode A PlatformFlashMode.
   * @return The corresponding FlashMode.
   */
  @NonNull
  public static FlashMode flashModeFromPigeon(@NonNull Messages.PlatformFlashMode mode) {
    switch (mode) {
      case AUTO:
        return FlashMode.auto;
      case OFF:
        return FlashMode.off;
      case ALWAYS:
        return FlashMode.always;
      case TORCH:
        return FlashMode.torch;
    }
    throw new IllegalStateException("Unreachable code");
  }
}
