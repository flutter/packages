// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;

import android.os.Handler;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import java.util.ArrayList;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.mockito.invocation.InvocationOnMock;

public class DartMessengerTest {

  private DartMessenger dartMessenger;
  private Messages.CameraGlobalEventApi mockGlobalEventApi;
  private Messages.CameraEventApi mockEventApi;

  @Before
  public void setUp() {
    Handler mockHandler = mock(Handler.class);
    doAnswer(
            (InvocationOnMock invocation) -> {
              Runnable r = invocation.getArgument(0);
              if (r != null) {
                r.run();
              }
              return true;
            })
        .when(mockHandler)
        .post(any(Runnable.class));
    mockGlobalEventApi = mock(Messages.CameraGlobalEventApi.class);
    mockEventApi = mock(Messages.CameraEventApi.class);
    dartMessenger = new DartMessenger(mockHandler, mockGlobalEventApi, mockEventApi);
  }

  @Test
  public void sendCameraErrorEvent_includesErrorDescriptions() {
    final List<String> errorsList = new ArrayList<>();
    doAnswer(
            (InvocationOnMock invocation) -> {
              String description = invocation.getArgument(0);
              errorsList.add(description);
              return null;
            })
        .when(mockEventApi)
        .error(any(), any());

    dartMessenger.sendCameraErrorEvent("error description");

    assertEquals(1, errorsList.size());
    assertEquals("error description", errorsList.get(0));
  }

  @Test
  public void sendCameraInitializedEvent_includesPreviewSize() {
    final List<Messages.PlatformCameraState> statesList = new ArrayList<>();
    doAnswer(
            (InvocationOnMock invocation) -> {
              Messages.PlatformCameraState state = invocation.getArgument(0);
              statesList.add(state);
              return null;
            })
        .when(mockEventApi)
        .initialized(any(), any());
    dartMessenger.sendCameraInitializedEvent(0, 0, ExposureMode.auto, FocusMode.auto, true, true);

    assertEquals(1, statesList.size());
    Messages.PlatformCameraState state = statesList.get(0);
    assertEquals(0, state.getPreviewSize().getWidth(), 0);
    assertEquals(0, state.getPreviewSize().getHeight(), 0);
    assertEquals("ExposureMode auto", Messages.PlatformExposureMode.AUTO, state.getExposureMode());
    assertEquals("FocusMode continuous", Messages.PlatformFocusMode.AUTO, state.getFocusMode());
    assertEquals("exposurePointSupported", true, state.getExposurePointSupported());
    assertEquals("focusPointSupported", true, state.getFocusPointSupported());
  }

  @Test
  public void sendCameraClosingEvent() {
    final List<Integer> calls = new ArrayList<>();
    doAnswer(
            (InvocationOnMock invocation) -> {
              calls.add(1);
              return null;
            })
        .when(mockEventApi)
        .closed(any());
    dartMessenger.sendCameraClosingEvent();

    assertEquals(1, calls.size());
    assertEquals(1, calls.get(0).intValue());
  }

  @Test
  public void sendDeviceOrientationChangedEvent() {
    final List<Messages.PlatformDeviceOrientation> eventsList = new ArrayList<>();
    doAnswer(
            (InvocationOnMock invocation) -> {
              Messages.PlatformDeviceOrientation orientation = invocation.getArgument(0);
              eventsList.add(orientation);
              return null;
            })
        .when(mockGlobalEventApi)
        .deviceOrientationChanged(any(), any());
    dartMessenger.sendDeviceOrientationChangeEvent(PlatformChannel.DeviceOrientation.PORTRAIT_UP);

    assertEquals(1, eventsList.size());
    assertEquals(Messages.PlatformDeviceOrientation.PORTRAIT_UP, eventsList.get(0));
  }
}
