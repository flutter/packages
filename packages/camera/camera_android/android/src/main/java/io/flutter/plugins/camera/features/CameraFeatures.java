// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features;

import android.app.Activity;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.DartMessenger;
import io.flutter.plugins.camera.features.autofocus.AutoFocusFeature;
import io.flutter.plugins.camera.features.exposurelock.ExposureLockFeature;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetFeature;
import io.flutter.plugins.camera.features.exposurepoint.ExposurePointFeature;
import io.flutter.plugins.camera.features.flash.FlashFeature;
import io.flutter.plugins.camera.features.focuspoint.FocusPointFeature;
import io.flutter.plugins.camera.features.fpsrange.FpsRangeFeature;
import io.flutter.plugins.camera.features.noisereduction.NoiseReductionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;
import io.flutter.plugins.camera.features.zoomlevel.ZoomLevelFeature;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * These are all of our available features in the camera. Used in the Camera to access all features
 * in a simpler way.
 */
public class CameraFeatures {
  private static final String AUTO_FOCUS = "AUTO_FOCUS";
  private static final String EXPOSURE_LOCK = "EXPOSURE_LOCK";
  private static final String EXPOSURE_OFFSET = "EXPOSURE_OFFSET";
  private static final String EXPOSURE_POINT = "EXPOSURE_POINT";
  private static final String FLASH = "FLASH";
  private static final String FOCUS_POINT = "FOCUS_POINT";
  private static final String FPS_RANGE = "FPS_RANGE";
  private static final String NOISE_REDUCTION = "NOISE_REDUCTION";
  private static final String REGION_BOUNDARIES = "REGION_BOUNDARIES";
  private static final String RESOLUTION = "RESOLUTION";
  private static final String SENSOR_ORIENTATION = "SENSOR_ORIENTATION";
  private static final String ZOOM_LEVEL = "ZOOM_LEVEL";

  @NonNull
  public static CameraFeatures init(
      @NonNull CameraFeatureFactory cameraFeatureFactory,
      @NonNull CameraProperties cameraProperties,
      @NonNull Activity activity,
      @NonNull DartMessenger dartMessenger,
      @NonNull ResolutionPreset resolutionPreset) {
    CameraFeatures cameraFeatures = new CameraFeatures();
    cameraFeatures.setAutoFocus(
        cameraFeatureFactory.createAutoFocusFeature(cameraProperties, false));
    cameraFeatures.setExposureLock(
        cameraFeatureFactory.createExposureLockFeature(cameraProperties));
    cameraFeatures.setExposureOffset(
        cameraFeatureFactory.createExposureOffsetFeature(cameraProperties));
    SensorOrientationFeature sensorOrientationFeature =
        cameraFeatureFactory.createSensorOrientationFeature(
            cameraProperties, activity, dartMessenger);
    cameraFeatures.setSensorOrientation(sensorOrientationFeature);
    cameraFeatures.setExposurePoint(
        cameraFeatureFactory.createExposurePointFeature(
            cameraProperties, sensorOrientationFeature));
    cameraFeatures.setFlash(cameraFeatureFactory.createFlashFeature(cameraProperties));
    cameraFeatures.setFocusPoint(
        cameraFeatureFactory.createFocusPointFeature(cameraProperties, sensorOrientationFeature));
    cameraFeatures.setFpsRange(cameraFeatureFactory.createFpsRangeFeature(cameraProperties));
    cameraFeatures.setNoiseReduction(
        cameraFeatureFactory.createNoiseReductionFeature(cameraProperties));
    cameraFeatures.setResolution(
        cameraFeatureFactory.createResolutionFeature(
            cameraProperties, resolutionPreset, cameraProperties.getCameraName()));
    cameraFeatures.setZoomLevel(cameraFeatureFactory.createZoomLevelFeature(cameraProperties));
    return cameraFeatures;
  }

  private final Map<String, CameraFeature<?>> featureMap = new HashMap<>();

  /**
   * Gets a collection of all features that have been set.
   *
   * @return A collection of all features that have been set.
   */
  @NonNull
  public Collection<CameraFeature<?>> getAllFeatures() {
    return this.featureMap.values();
  }

  /**
   * Gets the auto focus feature if it has been set.
   *
   * @return the auto focus feature.
   */
  @NonNull
  public AutoFocusFeature getAutoFocus() {
    return (AutoFocusFeature) featureMap.get(AUTO_FOCUS);
  }

  /**
   * Sets the instance of the auto focus feature.
   *
   * @param autoFocus the {@link AutoFocusFeature} instance to set.
   */
  public void setAutoFocus(@NonNull AutoFocusFeature autoFocus) {
    this.featureMap.put(AUTO_FOCUS, autoFocus);
  }

  /**
   * Gets the exposure lock feature if it has been set.
   *
   * @return the exposure lock feature.
   */
  @NonNull
  public ExposureLockFeature getExposureLock() {
    return (ExposureLockFeature) featureMap.get(EXPOSURE_LOCK);
  }

  /**
   * Sets the instance of the exposure lock feature.
   *
   * @param exposureLock the {@link ExposureLockFeature} instance to set.
   */
  public void setExposureLock(@NonNull ExposureLockFeature exposureLock) {
    this.featureMap.put(EXPOSURE_LOCK, exposureLock);
  }

  /**
   * Gets the exposure offset feature if it has been set.
   *
   * @return the exposure offset feature.
   */
  @NonNull
  public ExposureOffsetFeature getExposureOffset() {
    return (ExposureOffsetFeature) Objects.requireNonNull(featureMap.get(EXPOSURE_OFFSET));
  }

  /**
   * Sets the instance of the exposure offset feature.
   *
   * @param exposureOffset the {@link ExposureOffsetFeature} instance to set.
   */
  public void setExposureOffset(@NonNull ExposureOffsetFeature exposureOffset) {
    this.featureMap.put(EXPOSURE_OFFSET, exposureOffset);
  }

  /**
   * Gets the exposure point feature if it has been set.
   *
   * @return the exposure point feature.
   */
  @NonNull
  public ExposurePointFeature getExposurePoint() {
    return (ExposurePointFeature) Objects.requireNonNull(featureMap.get(EXPOSURE_POINT));
  }

  /**
   * Sets the instance of the exposure point feature.
   *
   * @param exposurePoint the {@link ExposurePointFeature} instance to set.
   */
  public void setExposurePoint(@NonNull ExposurePointFeature exposurePoint) {
    this.featureMap.put(EXPOSURE_POINT, exposurePoint);
  }

  /**
   * Gets the flash feature if it has been set.
   *
   * @return the flash feature.
   */
  @NonNull
  public FlashFeature getFlash() {
    return (FlashFeature) Objects.requireNonNull(featureMap.get(FLASH));
  }

  /**
   * Sets the instance of the flash feature.
   *
   * @param flash the {@link FlashFeature} instance to set.
   */
  public void setFlash(@NonNull FlashFeature flash) {
    this.featureMap.put(FLASH, flash);
  }

  /**
   * Gets the focus point feature if it has been set.
   *
   * @return the focus point feature.
   */
  @NonNull
  public FocusPointFeature getFocusPoint() {
    return (FocusPointFeature) Objects.requireNonNull(featureMap.get(FOCUS_POINT));
  }

  /**
   * Sets the instance of the focus point feature.
   *
   * @param focusPoint the {@link FocusPointFeature} instance to set.
   */
  public void setFocusPoint(@NonNull FocusPointFeature focusPoint) {
    this.featureMap.put(FOCUS_POINT, focusPoint);
  }

  /**
   * Gets the fps range feature if it has been set.
   *
   * @return the fps range feature.
   */
  @NonNull
  public FpsRangeFeature getFpsRange() {
    return (FpsRangeFeature) Objects.requireNonNull(featureMap.get(FPS_RANGE));
  }

  /**
   * Sets the instance of the fps range feature.
   *
   * @param fpsRange the {@link FpsRangeFeature} instance to set.
   */
  public void setFpsRange(@NonNull FpsRangeFeature fpsRange) {
    this.featureMap.put(FPS_RANGE, fpsRange);
  }

  /**
   * Gets the noise reduction feature if it has been set.
   *
   * @return the noise reduction feature.
   */
  @NonNull
  public NoiseReductionFeature getNoiseReduction() {
    return (NoiseReductionFeature) Objects.requireNonNull(featureMap.get(NOISE_REDUCTION));
  }

  /**
   * Sets the instance of the noise reduction feature.
   *
   * @param noiseReduction the {@link NoiseReductionFeature} instance to set.
   */
  public void setNoiseReduction(@NonNull NoiseReductionFeature noiseReduction) {
    this.featureMap.put(NOISE_REDUCTION, noiseReduction);
  }

  /**
   * Gets the resolution feature if it has been set.
   *
   * @return the resolution feature.
   */
  @NonNull
  public ResolutionFeature getResolution() {
    return (ResolutionFeature) Objects.requireNonNull(featureMap.get(RESOLUTION));
  }

  /**
   * Sets the instance of the resolution feature.
   *
   * @param resolution the {@link ResolutionFeature} instance to set.
   */
  public void setResolution(@NonNull ResolutionFeature resolution) {
    this.featureMap.put(RESOLUTION, resolution);
  }

  /**
   * Gets the sensor orientation feature if it has been set.
   *
   * @return the sensor orientation feature.
   */
  @NonNull
  public SensorOrientationFeature getSensorOrientation() {
    return (SensorOrientationFeature) Objects.requireNonNull(featureMap.get(SENSOR_ORIENTATION));
  }

  /**
   * Sets the instance of the sensor orientation feature.
   *
   * @param sensorOrientation the {@link SensorOrientationFeature} instance to set.
   */
  public void setSensorOrientation(@NonNull SensorOrientationFeature sensorOrientation) {
    this.featureMap.put(SENSOR_ORIENTATION, sensorOrientation);
  }

  /**
   * Gets the zoom level feature if it has been set.
   *
   * @return the zoom level feature.
   */
  @NonNull
  public ZoomLevelFeature getZoomLevel() {
    return (ZoomLevelFeature) Objects.requireNonNull(featureMap.get(ZOOM_LEVEL));
  }

  /**
   * Sets the instance of the zoom level feature.
   *
   * @param zoomLevel the {@link ZoomLevelFeature} instance to set.
   */
  public void setZoomLevel(@NonNull ZoomLevelFeature zoomLevel) {
    this.featureMap.put(ZOOM_LEVEL, zoomLevel);
  }
}
