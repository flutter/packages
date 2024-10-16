// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.app.Activity;
import android.hardware.camera2.CameraAccessException;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.camera.CameraPermissions.PermissionsRegistry;
import io.flutter.plugins.camera.features.CameraFeatureFactoryImpl;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.features.flash.FlashMode;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.view.TextureRegistry;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

final class CameraApiImpl implements Messages.CameraApi {
  private final Activity activity;
  private final BinaryMessenger messenger;
  private final CameraPermissions cameraPermissions;
  private final PermissionsRegistry permissionsRegistry;
  private final TextureRegistry textureRegistry;
  private final EventChannel imageStreamChannel;
  @VisibleForTesting @Nullable Camera camera;

  CameraApiImpl(
      Activity activity,
      BinaryMessenger messenger,
      CameraPermissions cameraPermissions,
      PermissionsRegistry permissionsAdder,
      TextureRegistry textureRegistry) {
    this.activity = activity;
    this.messenger = messenger;
    this.cameraPermissions = cameraPermissions;
    this.permissionsRegistry = permissionsAdder;
    this.textureRegistry = textureRegistry;

    imageStreamChannel =
        new EventChannel(messenger, "plugins.flutter.io/camera_android/imageStream");
    Messages.CameraApi.setUp(messenger, this);
  }

  void tearDownMessageHandler() {
    Messages.CameraApi.setUp(messenger, null);
  }

  private Long instantiateCamera(String cameraName, Messages.PlatformMediaSettings settings)
      throws CameraAccessException {
    TextureRegistry.SurfaceTextureEntry flutterSurfaceTexture =
        textureRegistry.createSurfaceTexture();
    long cameraId = flutterSurfaceTexture.id();
    DartMessenger dartMessenger =
        new DartMessenger(
            new Handler(Looper.getMainLooper()),
            new Messages.CameraGlobalEventApi(messenger),
            new Messages.CameraEventApi(messenger, String.valueOf(cameraId)));
    CameraProperties cameraProperties =
        new CameraPropertiesImpl(cameraName, CameraUtils.getCameraManager(activity));
    Integer fps = (settings.getFps() == null) ? null : settings.getFps().intValue();
    Integer videoBitrate =
        (settings.getVideoBitrate() == null) ? null : settings.getVideoBitrate().intValue();
    Integer audioBitrate =
        (settings.getAudioBitrate() == null) ? null : settings.getAudioBitrate().intValue();
    ResolutionPreset resolutionPreset =
        CameraUtils.resolutionPresetFromPigeon(settings.getResolutionPreset());

    camera =
        new Camera(
            activity,
            flutterSurfaceTexture,
            new CameraFeatureFactoryImpl(),
            dartMessenger,
            cameraProperties,
            new Camera.VideoCaptureSettings(
                resolutionPreset, settings.getEnableAudio(), fps, videoBitrate, audioBitrate));

    return flutterSurfaceTexture.id();
  }

  // We move catching CameraAccessException out of onMethodCall because it causes a crash
  // on plugin registration for sdks incompatible with Camera2 (< 21). We want this plugin to
  // to be able to compile with <21 sdks for apps that want the camera and support earlier version.
  @SuppressWarnings("ConstantConditions")
  private <T> void handleException(Exception exception, Messages.Result<T> result) {
    if (exception instanceof CameraAccessException) {
      result.error(exception);
      return;
    }

    // CameraAccessException can not be cast to a RuntimeException.
    throw (RuntimeException) exception;
  }

  private void handleException(Exception exception, Messages.VoidResult result) {
    if (exception instanceof CameraAccessException) {
      result.error(exception);
      return;
    }

    // CameraAccessException can not be cast to a RuntimeException.
    throw (RuntimeException) exception;
  }

  @NonNull
  @Override
  public List<Messages.PlatformCameraDescription> getAvailableCameras() {
    if (activity == null) {
      return Collections.emptyList();
    }
    try {
      return CameraUtils.getAvailableCameras(activity);
    } catch (CameraAccessException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void create(
      @NonNull String cameraName,
      @NonNull Messages.PlatformMediaSettings settings,
      @NonNull Messages.Result<Long> result) {
    if (camera != null) {
      camera.close();
    }

    cameraPermissions.requestPermissions(
        activity,
        permissionsRegistry,
        settings.getEnableAudio(),
        (String errCode, String errDesc) -> {
          if (errCode == null) {
            try {
              result.success(instantiateCamera(cameraName, settings));
            } catch (Exception e) {
              handleException(e, result);
            }
          } else {
            result.error(new Messages.FlutterError(errCode, errDesc, null));
          }
        });
  }

  @Override
  public void initialize(@NonNull Messages.PlatformImageFormatGroup imageFormat) {
    if (camera != null) {
      try {
        camera.open(CameraUtils.imageFormatGroupFromPigeon(imageFormat));
      } catch (CameraAccessException e) {
        throw new Messages.FlutterError("CameraAccessException", e.getMessage(), null);
      }
    } else {
      throw new Messages.FlutterError(
          "cameraNotFound",
          "Camera not found. Please call the 'create' method before calling 'initialize'.",
          null);
    }
  }

  @Override
  public void takePicture(@NonNull Messages.Result<String> result) {
    camera.takePicture(result);
  }

  @Override
  public void startVideoRecording(@NonNull Boolean enableStream) {
    camera.startVideoRecording(Objects.equals(enableStream, true) ? imageStreamChannel : null);
  }

  @NonNull
  @Override
  public String stopVideoRecording() {
    return camera.stopVideoRecording();
  }

  @Override
  public void pauseVideoRecording() {
    camera.pauseVideoRecording();
  }

  @Override
  public void resumeVideoRecording() {
    camera.resumeVideoRecording();
  }

  @Override
  public void setFlashMode(
      @NonNull Messages.PlatformFlashMode flashMode, @NonNull Messages.VoidResult result) {
    FlashMode mode = CameraUtils.flashModeFromPigeon(flashMode);
    if (mode == null) {
      result.error(
          new Messages.FlutterError(
              "setFlashModeFailed", "Unknown flash mode " + flashMode.name(), null));
      return;
    }
    try {
      camera.setFlashMode(result, mode);
    } catch (Exception e) {
      handleException(e, result);
    }
  }

  @Override
  public void setExposureMode(
      @NonNull Messages.PlatformExposureMode exposureMode, @NonNull Messages.VoidResult result) {
    ExposureMode mode = CameraUtils.exposureModeFromPigeon(exposureMode);
    if (mode == null) {
      result.error(
          new Messages.FlutterError(
              "setExposureModeFailed", "Unknown exposure mode " + mode.name(), null));
      return;
    }
    try {
      camera.setExposureMode(result, mode);
    } catch (Exception e) {
      handleException(e, result);
    }
  }

  @Override
  public void setExposurePoint(
      @Nullable Messages.PlatformPoint point, @NonNull Messages.VoidResult result) {

    Double x = null;
    Double y = null;
    if (point != null) {
      x = point.getX();
      y = point.getY();
    }
    try {
      camera.setExposurePoint(result, new Point(x, y));
    } catch (Exception e) {
      handleException(e, result);
    }
  }

  @NonNull
  @Override
  public Double getMinExposureOffset() {
    return camera.getMinExposureOffset();
  }

  @NonNull
  @Override
  public Double getMaxExposureOffset() {
    return camera.getMaxExposureOffset();
  }

  @NonNull
  @Override
  public Double getExposureOffsetStepSize() {
    return camera.getExposureOffsetStepSize();
  }

  @Override
  public void setExposureOffset(@NonNull Double offset, @NonNull Messages.Result<Double> result) {

    try {
      camera.setExposureOffset(result, offset);
    } catch (Exception e) {
      handleException(e, result);
    }
  }

  @Override
  public void setFocusMode(@NonNull Messages.PlatformFocusMode focusMode) {
    FocusMode mode = CameraUtils.focusModeFromPigeon(focusMode);
    if (mode == null) {
      throw new Messages.FlutterError(
          "setFocusModeFailed", "Unknown focus mode " + mode.name(), null);
    }
    camera.setFocusMode(mode);
  }

  @Override
  public void setFocusPoint(
      @Nullable Messages.PlatformPoint point, @NonNull Messages.VoidResult result) {
    Double x = null;
    Double y = null;
    if (point != null) {
      x = point.getX();
      y = point.getY();
    }
    try {
      camera.setFocusPoint(result, new Point(x, y));
    } catch (Exception e) {
      handleException(e, result);
    }
  }

  @Override
  public void startImageStream() {

    try {
      camera.startPreviewWithImageStream(imageStreamChannel);
    } catch (CameraAccessException e) {
      throw new Messages.FlutterError("CameraAccessException", e.getMessage(), null);
    }
  }

  @Override
  public void stopImageStream() {
    try {
      camera.startPreview();
    } catch (Exception e) {
      throw new Messages.FlutterError(e.getClass().getName(), e.getMessage(), null);
    }
  }

  @NonNull
  @Override
  public Double getMaxZoomLevel() {

    assert camera != null;

    return (double) camera.getMaxZoomLevel();
  }

  @NonNull
  @Override
  public Double getMinZoomLevel() {

    assert camera != null;
    return (double) camera.getMinZoomLevel();
  }

  @Override
  public void setZoomLevel(@NonNull Double zoom, @NonNull Messages.VoidResult result) {

    assert camera != null;
    camera.setZoomLevel(result, zoom.floatValue());
  }

  @Override
  public void lockCaptureOrientation(
      @NonNull Messages.PlatformDeviceOrientation platformOrientation) {

    PlatformChannel.DeviceOrientation orientation =
        CameraUtils.orientationFromPigeon(platformOrientation);

    camera.lockCaptureOrientation(orientation);
  }

  @Override
  public void unlockCaptureOrientation() {

    camera.unlockCaptureOrientation();
  }

  @Override
  public void pausePreview() {

    try {
      camera.pausePreview();
    } catch (CameraAccessException e) {
      throw new Messages.FlutterError("CameraAccessException", e.getMessage(), null);
    }
  }

  @Override
  public void resumePreview() {

    try {
      camera.resumePreview();
    } catch (Exception e) {
      throw new Messages.FlutterError("CameraAccessException", e.getMessage(), null);
    }
  }

  @Override
  public void setDescriptionWhileRecording(@NonNull String cameraName) {

    try {
      CameraProperties cameraProperties =
          new CameraPropertiesImpl(cameraName, CameraUtils.getCameraManager(activity));
      camera.setDescriptionWhileRecording(cameraProperties);
    } catch (Exception e) {
      throw new Messages.FlutterError("CameraAccessException", e.getMessage(), null);
    }
  }

  @Override
  public void dispose() {

    if (camera != null) {
      camera.dispose();
    }
  }
}
