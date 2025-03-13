// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.provider.Settings;
import android.view.Display;
import android.view.Surface;
import android.view.WindowManager;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import io.flutter.plugins.camerax.DeviceOrientationManager.DeviceOrientationChangeCallback;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

public class DeviceOrientationManagerTest {
  private Activity mockActivity;
  private DeviceOrientationChangeCallback mockDeviceOrientationChangeCallback;
  private WindowManager mockWindowManager;
  private Display mockDisplay;
  private DeviceOrientationManager deviceOrientationManager;

  @Before
  @SuppressWarnings("deprecation")
  public void before() {
    mockActivity = mock(Activity.class);
    mockDisplay = mock(Display.class);
    mockWindowManager = mock(WindowManager.class);
    mockDeviceOrientationChangeCallback = mock(DeviceOrientationChangeCallback.class);

    when(mockActivity.getSystemService(Context.WINDOW_SERVICE)).thenReturn(mockWindowManager);
    when(mockWindowManager.getDefaultDisplay()).thenReturn(mockDisplay);

    deviceOrientationManager =
        new DeviceOrientationManager(mockActivity, false, 0, mockDeviceOrientationChangeCallback);
  }

  @Test
  public void handleUIOrientationChange_shouldSendMessageWhenSensorAccessIsAllowed() {
    try (MockedStatic<Settings.System> mockedSystem = mockStatic(Settings.System.class)) {
      mockedSystem
          .when(
              () ->
                  Settings.System.getInt(any(), eq(Settings.System.ACCELEROMETER_ROTATION), eq(0)))
          .thenReturn(0);
      setUpUIOrientationMocks(Configuration.ORIENTATION_LANDSCAPE, Surface.ROTATION_0);

      deviceOrientationManager.handleUIOrientationChange();
    }

    verify(mockDeviceOrientationChangeCallback, times(1))
        .onChange(DeviceOrientation.LANDSCAPE_LEFT);
  }

  @Test
  public void handleOrientationChange_shouldSendMessageWhenOrientationIsUpdated() {
    DeviceOrientation previousOrientation = DeviceOrientation.PORTRAIT_UP;
    DeviceOrientation newOrientation = DeviceOrientation.LANDSCAPE_LEFT;

    DeviceOrientationManager.handleOrientationChange(
        newOrientation, previousOrientation, mockDeviceOrientationChangeCallback);

    verify(mockDeviceOrientationChangeCallback, times(1)).onChange(newOrientation);
  }

  @Test
  public void handleOrientationChange_shouldNotSendMessageWhenOrientationIsNotUpdated() {
    DeviceOrientation previousOrientation = DeviceOrientation.PORTRAIT_UP;
    DeviceOrientation newOrientation = DeviceOrientation.PORTRAIT_UP;

    DeviceOrientationManager.handleOrientationChange(
        newOrientation, previousOrientation, mockDeviceOrientationChangeCallback);

    verify(mockDeviceOrientationChangeCallback, never()).onChange(any());
  }

  @Test
  public void getUIOrientation() {
    // Orientation portrait and rotation of 0 should translate to "PORTRAIT_UP".
    setUpUIOrientationMocks(Configuration.ORIENTATION_PORTRAIT, Surface.ROTATION_0);
    DeviceOrientation uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.PORTRAIT_UP, uiOrientation);

    // Orientation portrait and rotation of 90 should translate to "PORTRAIT_UP".
    setUpUIOrientationMocks(Configuration.ORIENTATION_PORTRAIT, Surface.ROTATION_90);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.PORTRAIT_UP, uiOrientation);

    // Orientation portrait and rotation of 180 should translate to "PORTRAIT_DOWN".
    setUpUIOrientationMocks(Configuration.ORIENTATION_PORTRAIT, Surface.ROTATION_180);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.PORTRAIT_DOWN, uiOrientation);

    // Orientation portrait and rotation of 270 should translate to "PORTRAIT_DOWN".
    setUpUIOrientationMocks(Configuration.ORIENTATION_PORTRAIT, Surface.ROTATION_270);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.PORTRAIT_DOWN, uiOrientation);

    // Orientation landscape and rotation of 0 should translate to "LANDSCAPE_LEFT".
    setUpUIOrientationMocks(Configuration.ORIENTATION_LANDSCAPE, Surface.ROTATION_0);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.LANDSCAPE_LEFT, uiOrientation);

    // Orientation landscape and rotation of 90 should translate to "LANDSCAPE_LEFT".
    setUpUIOrientationMocks(Configuration.ORIENTATION_LANDSCAPE, Surface.ROTATION_90);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.LANDSCAPE_LEFT, uiOrientation);

    // Orientation landscape and rotation of 180 should translate to "LANDSCAPE_RIGHT".
    setUpUIOrientationMocks(Configuration.ORIENTATION_LANDSCAPE, Surface.ROTATION_180);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.LANDSCAPE_RIGHT, uiOrientation);

    // Orientation landscape and rotation of 270 should translate to "LANDSCAPE_RIGHT".
    setUpUIOrientationMocks(Configuration.ORIENTATION_LANDSCAPE, Surface.ROTATION_270);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.LANDSCAPE_RIGHT, uiOrientation);

    // Orientation undefined should default to "PORTRAIT_UP".
    setUpUIOrientationMocks(Configuration.ORIENTATION_UNDEFINED, Surface.ROTATION_0);
    uiOrientation = deviceOrientationManager.getUIOrientation();
    assertEquals(DeviceOrientation.PORTRAIT_UP, uiOrientation);
  }

  private void setUpUIOrientationMocks(int orientation, int rotation) {
    Resources mockResources = mock(Resources.class);
    Configuration mockConfiguration = mock(Configuration.class);

    when(mockDisplay.getRotation()).thenReturn(rotation);

    mockConfiguration.orientation = orientation;
    when(mockActivity.getResources()).thenReturn(mockResources);
    when(mockResources.getConfiguration()).thenReturn(mockConfiguration);
  }

  @Test
  public void getDefaultRotation_returnsExpectedValue() {
    final int expectedRotation = 90;
    when(mockDisplay.getRotation()).thenReturn(expectedRotation);

    final int defaultRotation = deviceOrientationManager.getDefaultRotation();

    assertEquals(defaultRotation, expectedRotation);
  }

  @Test
  public void getDisplayTest() {
    Display display = deviceOrientationManager.getDisplay();

    assertEquals(mockDisplay, display);
  }
}
