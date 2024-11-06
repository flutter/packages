// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.features.flash.FlashMode;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import java.util.List;
import org.junit.Test;

public class CameraUtilsTest {

  @Test
  public void getAvailableCameras_retrievesValidCameras()
      throws CameraAccessException, NumberFormatException {
    final Activity mockActivity = mock(Activity.class);
    final CameraManager mockCameraManager = mock(CameraManager.class);
    final CameraCharacteristics mockCameraCharacteristics = mock(CameraCharacteristics.class);
    final String[] mockCameraIds = {"1394902", "-192930", "0283835", "foobar"};
    final int mockSensorOrientation0 = 90;
    final int mockSensorOrientation2 = 270;
    final int mockLensFacing0 = CameraMetadata.LENS_FACING_FRONT;
    final int mockLensFacing2 = CameraMetadata.LENS_FACING_EXTERNAL;

    when(mockActivity.getSystemService(Context.CAMERA_SERVICE)).thenReturn(mockCameraManager);
    when(mockCameraManager.getCameraIdList()).thenReturn(mockCameraIds);
    when(mockCameraManager.getCameraCharacteristics(anyString()))
        .thenReturn(mockCameraCharacteristics);
    when(mockCameraCharacteristics.get(any()))
        .thenReturn(mockSensorOrientation0)
        .thenReturn(mockLensFacing0)
        .thenReturn(mockSensorOrientation2)
        .thenReturn(mockLensFacing2);

    List<Messages.PlatformCameraDescription> availableCameras =
        CameraUtils.getAvailableCameras(mockActivity);

    assertEquals(availableCameras.size(), 2);
    assertEquals(availableCameras.get(0).getName(), "1394902");
    assertEquals(availableCameras.get(0).getSensorOrientation().intValue(), mockSensorOrientation0);
    assertEquals(
        availableCameras.get(0).getLensDirection(), Messages.PlatformCameraLensDirection.FRONT);
    assertEquals(availableCameras.get(1).getName(), "0283835");
    assertEquals(availableCameras.get(1).getSensorOrientation().intValue(), mockSensorOrientation2);
    assertEquals(
        availableCameras.get(1).getLensDirection(), Messages.PlatformCameraLensDirection.EXTERNAL);
  }

  @Test
  public void orientationToPigeonTest() {
    assertEquals(
        CameraUtils.orientationToPigeon(PlatformChannel.DeviceOrientation.PORTRAIT_UP),
        Messages.PlatformDeviceOrientation.PORTRAIT_UP);
    assertEquals(
        CameraUtils.orientationToPigeon(PlatformChannel.DeviceOrientation.PORTRAIT_DOWN),
        Messages.PlatformDeviceOrientation.PORTRAIT_DOWN);
    assertEquals(
        CameraUtils.orientationToPigeon(PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT),
        Messages.PlatformDeviceOrientation.LANDSCAPE_LEFT);
    assertEquals(
        CameraUtils.orientationToPigeon(PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT),
        Messages.PlatformDeviceOrientation.LANDSCAPE_RIGHT);
  }

  @Test
  public void orientationFromPigeonTest() {
    assertEquals(
        CameraUtils.orientationFromPigeon(Messages.PlatformDeviceOrientation.PORTRAIT_UP),
        PlatformChannel.DeviceOrientation.PORTRAIT_UP);
    assertEquals(
        CameraUtils.orientationFromPigeon(Messages.PlatformDeviceOrientation.PORTRAIT_DOWN),
        PlatformChannel.DeviceOrientation.PORTRAIT_DOWN);
    assertEquals(
        CameraUtils.orientationFromPigeon(Messages.PlatformDeviceOrientation.LANDSCAPE_LEFT),
        PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT);
    assertEquals(
        CameraUtils.orientationFromPigeon(Messages.PlatformDeviceOrientation.LANDSCAPE_RIGHT),
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT);
  }

  @Test
  public void focusModeToPigeonTest() {
    assertEquals(CameraUtils.focusModeToPigeon(FocusMode.auto), Messages.PlatformFocusMode.AUTO);
    assertEquals(
        CameraUtils.focusModeToPigeon(FocusMode.locked), Messages.PlatformFocusMode.LOCKED);
  }

  @Test
  public void focusModeFromPigeonTest() {
    assertEquals(CameraUtils.focusModeFromPigeon(Messages.PlatformFocusMode.AUTO), FocusMode.auto);
    assertEquals(
        CameraUtils.focusModeFromPigeon(Messages.PlatformFocusMode.LOCKED), FocusMode.locked);
  }

  @Test
  public void exposureModeToPigeonTest() {
    assertEquals(
        CameraUtils.exposureModeToPigeon(ExposureMode.auto), Messages.PlatformExposureMode.AUTO);
    assertEquals(
        CameraUtils.exposureModeToPigeon(ExposureMode.locked),
        Messages.PlatformExposureMode.LOCKED);
  }

  @Test
  public void exposureModeFromPigeonTest() {
    assertEquals(
        CameraUtils.exposureModeFromPigeon(Messages.PlatformExposureMode.AUTO), ExposureMode.auto);
    assertEquals(
        CameraUtils.exposureModeFromPigeon(Messages.PlatformExposureMode.LOCKED),
        ExposureMode.locked);
  }

  @Test
  public void resolutionPresetFromPigeonTest() {
    assertEquals(
        CameraUtils.resolutionPresetFromPigeon(Messages.PlatformResolutionPreset.LOW),
        ResolutionPreset.low);
    assertEquals(
        CameraUtils.resolutionPresetFromPigeon(Messages.PlatformResolutionPreset.MEDIUM),
        ResolutionPreset.medium);
    assertEquals(
        CameraUtils.resolutionPresetFromPigeon(Messages.PlatformResolutionPreset.HIGH),
        ResolutionPreset.high);
    assertEquals(
        CameraUtils.resolutionPresetFromPigeon(Messages.PlatformResolutionPreset.VERY_HIGH),
        ResolutionPreset.veryHigh);
    assertEquals(
        CameraUtils.resolutionPresetFromPigeon(Messages.PlatformResolutionPreset.ULTRA_HIGH),
        ResolutionPreset.ultraHigh);
    assertEquals(
        CameraUtils.resolutionPresetFromPigeon(Messages.PlatformResolutionPreset.MAX),
        ResolutionPreset.max);
  }

  @Test
  public void imageFormatGroupFromPigeonTest() {
    assertEquals(
        CameraUtils.imageFormatGroupFromPigeon(Messages.PlatformImageFormatGroup.YUV420).intValue(),
        ImageFormat.YUV_420_888);
    assertEquals(
        CameraUtils.imageFormatGroupFromPigeon(Messages.PlatformImageFormatGroup.JPEG).intValue(),
        ImageFormat.JPEG);
    assertEquals(
        CameraUtils.imageFormatGroupFromPigeon(Messages.PlatformImageFormatGroup.NV21).intValue(),
        ImageFormat.NV21);
  }

  @Test
  public void flashModeFromPigeonTest() {
    assertEquals(CameraUtils.flashModeFromPigeon(Messages.PlatformFlashMode.AUTO), FlashMode.auto);
    assertEquals(
        CameraUtils.flashModeFromPigeon(Messages.PlatformFlashMode.ALWAYS), FlashMode.always);
    assertEquals(CameraUtils.flashModeFromPigeon(Messages.PlatformFlashMode.OFF), FlashMode.off);
    assertEquals(
        CameraUtils.flashModeFromPigeon(Messages.PlatformFlashMode.TORCH), FlashMode.torch);
  }
}
