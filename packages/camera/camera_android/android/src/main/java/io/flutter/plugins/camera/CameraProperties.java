// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.graphics.Rect;
import android.os.Build.VERSION_CODES;
import android.util.Range;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

/** An interface allowing access to the different characteristics of the device's camera. */
public interface CameraProperties {

  /**
   * Returns the name (or identifier) of the camera device.
   *
   * @return String The name of the camera device.
   */
  @NonNull
  String getCameraName();

  /**
   * Returns the list of frame rate ranges for @see android.control.aeTargetFpsRange supported by
   * this camera device.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_AE_TARGET_FPS_RANGE key.
   *
   * @return android.util.Range<Integer>[] List of frame rate ranges supported by this camera
   *     device.
   */
  @NonNull
  Range<Integer>[] getControlAutoExposureAvailableTargetFpsRanges();

  /**
   * Returns the maximum and minimum exposure compensation values for @see
   * android.control.aeExposureCompensation, in counts of @see android.control.aeCompensationStep,
   * that are supported by this camera device.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_AE_COMPENSATION_RANGE key.
   *
   * @return android.util.Range<Integer> Maximum and minimum exposure compensation supported by this
   *     camera device.
   */
  @NonNull
  Range<Integer> getControlAutoExposureCompensationRange();

  /**
   * Returns the smallest step by which the exposure compensation can be changed.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_AE_COMPENSATION_STEP key.
   *
   * @return double Smallest step by which the exposure compensation can be changed.
   */
  double getControlAutoExposureCompensationStep();

  /**
   * Returns a list of auto-focus modes for @see android.control.afMode that are supported by this
   * camera device.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_AF_AVAILABLE_MODES key.
   *
   * @return int[] List of auto-focus modes supported by this camera device.
   */
  @NonNull
  int[] getControlAutoFocusAvailableModes();

  /**
   * Returns the maximum number of metering regions that can be used by the auto-exposure routine.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_MAX_REGIONS_AE key.
   *
   * @return Integer Maximum number of metering regions that can be used by the auto-exposure
   *     routine.
   */
  @NonNull
  Integer getControlMaxRegionsAutoExposure();

  /**
   * Returns the maximum number of metering regions that can be used by the auto-focus routine.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_MAX_REGIONS_AF key.
   *
   * @return Integer Maximum number of metering regions that can be used by the auto-focus routine.
   */
  @NonNull
  Integer getControlMaxRegionsAutoFocus();

  /**
   * Returns a list of distortion correction modes for @see android.distortionCorrection.mode that
   * are supported by this camera device.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#DISTORTION_CORRECTION_AVAILABLE_MODES key.
   *
   * @return int[] List of distortion correction modes supported by this camera device.
   */
  @RequiresApi(api = VERSION_CODES.P)
  @Nullable
  int[] getDistortionCorrectionAvailableModes();

  /**
   * Returns whether this camera device has a flash unit.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#FLASH_INFO_AVAILABLE key.
   *
   * @return Boolean Whether this camera device has a flash unit.
   */
  @NonNull
  Boolean getFlashInfoAvailable();

  /**
   * Returns the direction the camera faces relative to device screen.
   *
   * <p><string>Possible values:</string>
   *
   * <ul>
   *   <li>@see android.hardware.camera2.CameraMetadata.LENS_FACING_FRONT
   *   <li>@see android.hardware.camera2.CameraMetadata.LENS_FACING_BACK
   *   <li>@see android.hardware.camera2.CameraMetadata.LENS_FACING_EXTERNAL
   * </ul>
   *
   * <p>By default maps to the @see android.hardware.camera2.CameraCharacteristics.LENS_FACING key.
   *
   * @return int Direction the camera faces relative to device screen.
   */
  int getLensFacing();

  /**
   * Returns the shortest distance from front most surface of the lens that can be brought into
   * sharp focus.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#LENS_INFO_MINIMUM_FOCUS_DISTANCE key.
   *
   * @return Float Shortest distance from front most surface of the lens that can be brought into
   *     sharp focus.
   */
  @Nullable
  Float getLensInfoMinimumFocusDistance();

  /**
   * Returns the maximum ratio between both active area width and crop region width, and active area
   * height and crop region height, for @see android.scaler.cropRegion.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#SCALER_AVAILABLE_MAX_DIGITAL_ZOOM key.
   *
   * @return Float Maximum ratio between both active area width and crop region width, and active
   *     area height and crop region height.
   */
  @NonNull
  Float getScalerAvailableMaxDigitalZoom();

  /**
   * Returns the minimum ratio between the default camera zoom setting and all of the available
   * zoom.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_ZOOM_RATIO_RANGE key's lower value.
   *
   * @return Float Minimum ratio between the default zoom ratio and the minimum possible zoom.
   */
  @Nullable
  @RequiresApi(api = VERSION_CODES.R)
  Float getScalerMinZoomRatio();

  /**
   * Returns the maximum ratio between the default camera zoom setting and all of the available
   * zoom.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#CONTROL_ZOOM_RATIO_RANGE key's upper value.
   *
   * @return Float Maximum ratio between the default zoom ratio and the maximum possible zoom.
   */
  @Nullable
  @RequiresApi(api = VERSION_CODES.R)
  Float getScalerMaxZoomRatio();

  /**
   * Returns the area of the image sensor which corresponds to active pixels after any geometric
   * distortion correction has been applied.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#SENSOR_INFO_ACTIVE_ARRAY_SIZE key.
   *
   * @return android.graphics.Rect area of the image sensor which corresponds to active pixels after
   *     any geometric distortion correction has been applied.
   */
  @NonNull
  Rect getSensorInfoActiveArraySize();

  /**
   * Returns the dimensions of the full pixel array, possibly including black calibration pixels.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#SENSOR_INFO_PIXEL_ARRAY_SIZE key.
   *
   * @return android.util.Size Dimensions of the full pixel array, possibly including black
   *     calibration pixels.
   */
  @NonNull
  Size getSensorInfoPixelArraySize();

  /**
   * Returns the area of the image sensor which corresponds to active pixels prior to the
   * application of any geometric distortion correction.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#SENSOR_INFO_PRE_CORRECTION_ACTIVE_ARRAY_SIZE
   * key.
   *
   * @return android.graphics.Rect Area of the image sensor which corresponds to active pixels prior
   *     to the application of any geometric distortion correction.
   */
  @RequiresApi(api = VERSION_CODES.M)
  @NonNull
  Rect getSensorInfoPreCorrectionActiveArraySize();

  /**
   * Returns the clockwise angle through which the output image needs to be rotated to be upright on
   * the device screen in its native orientation.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#SENSOR_ORIENTATION key.
   *
   * @return int Clockwise angle through which the output image needs to be rotated to be upright on
   *     the device screen in its native orientation.
   */
  int getSensorOrientation();

  /**
   * Returns a level which generally classifies the overall set of the camera device functionality.
   *
   * <p><strong>Possible values:</strong>
   *
   * <ul>
   *   <li>@see android.hardware.camera2.CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY
   *   <li>@see android.hardware.camera2.CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED
   *   <li>@see android.hardware.camera2.CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_FULL
   *   <li>@see android.hardware.camera2.CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_LEVEL_3
   *   <li>@see android.hardware.camera2.CameraMetadata.INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL
   * </ul>
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#INFO_SUPPORTED_HARDWARE_LEVEL key.
   *
   * @return int Level which generally classifies the overall set of the camera device
   *     functionality.
   */
  int getHardwareLevel();

  /**
   * Returns a list of noise reduction modes for @see android.noiseReduction.mode that are supported
   * by this camera device.
   *
   * <p>By default maps to the @see
   * android.hardware.camera2.CameraCharacteristics#NOISE_REDUCTION_AVAILABLE_NOISE_REDUCTION_MODES
   * key.
   *
   * @return int[] List of noise reduction modes that are supported by this camera device.
   */
  @NonNull
  int[] getAvailableNoiseReductionModes();
}
