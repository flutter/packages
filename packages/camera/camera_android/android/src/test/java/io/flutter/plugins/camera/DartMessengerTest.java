// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static junit.framework.TestCase.assertNull;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;

import android.os.Handler;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

public class DartMessengerTest {
  /** A {@link BinaryMessenger} implementation that does nothing but save its messages. */
  private static class FakeBinaryMessenger implements BinaryMessenger {
    private final List<ByteBuffer> sentMessages = new ArrayList<>();

    @Override
    public void send(@NonNull String channel, ByteBuffer message) {
      sentMessages.add(message);
    }

    @Override
    public void send(@NonNull String channel, ByteBuffer message, BinaryReply callback) {
      send(channel, message);
    }

    @Override
    public void setMessageHandler(@NonNull String channel, BinaryMessageHandler handler) {}

    List<ByteBuffer> getMessages() {
      return new ArrayList<>(sentMessages);
    }
  }

  private Handler mockHandler;
  private DartMessenger dartMessenger;
  private FakeBinaryMessenger fakeBinaryMessenger;
  private Messages.CameraGlobalEventApi mockGlobalEventApi;
  private Messages.CameraEventApi mockEventApi;

  @Before
  public void setUp() {
    mockHandler = mock(Handler.class);
    mockGlobalEventApi = mock(Messages.CameraGlobalEventApi.class);
    mockEventApi = mock(Messages.CameraEventApi.class);
    fakeBinaryMessenger = new FakeBinaryMessenger();
    dartMessenger = new DartMessenger(fakeBinaryMessenger, 0, mockHandler, mockGlobalEventApi, mockEventApi);
  }

  @Test
  public void sendCameraErrorEvent_includesErrorDescriptions() {
    final List<String> errorsList = new ArrayList<>();
    doAnswer((InvocationOnMock invocation) -> {
      String description = invocation.getArgument(0);
      errorsList.add(description);
      return null;
    }).when(mockEventApi).error(any(), any());

    dartMessenger.sendCameraErrorEvent("error description");

    assertEquals(1, errorsList.size());
    assertEquals("error description", errorsList.get(0));
  }

  @Test
  public void sendCameraInitializedEvent_includesPreviewSize() {
    final List<Messages.PlatformCameraState> statesList = new ArrayList<>();
    doAnswer((InvocationOnMock invocation) -> {
      Messages.PlatformCameraState state = invocation.getArgument(0);
      statesList.add(state);
      return null;
    }).when(mockEventApi).initialized(any(), any());
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
    doAnswer(createPostHandlerAnswer()).when(mockHandler).post(any(Runnable.class));
    dartMessenger.sendCameraClosingEvent();

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals("camera_closing", call.method);
    assertNull(call.argument("description"));
  }

  @Test
  public void sendDeviceOrientationChangedEvent() {
    final List<Messages.PlatformDeviceOrientation> eventsList = new ArrayList<>();
    doAnswer((InvocationOnMock invocation) -> {
      Messages.PlatformDeviceOrientation orientation = invocation.getArgument(0);
      eventsList.add(orientation);
      return null;
    }).when(mockGlobalEventApi).deviceOrientationChanged(any(), any());
    dartMessenger.sendDeviceOrientationChangeEvent(PlatformChannel.DeviceOrientation.PORTRAIT_UP);

    assertEquals(1, eventsList.size());
    assertEquals(Messages.PlatformDeviceOrientation.PORTRAIT_UP, eventsList.get(0));
  }

  private static Answer<Boolean> createPostHandlerAnswer() {
    return new Answer<Boolean>() {
      @Override
      public Boolean answer(InvocationOnMock invocation) throws Throwable {
        Runnable runnable = invocation.getArgument(0, Runnable.class);
        if (runnable != null) {
          runnable.run();
        }
        return true;
      }
    };
  }

  private MethodCall decodeSentMessage(ByteBuffer sentMessage) {
    sentMessage.position(0);

    return StandardMethodCodec.INSTANCE.decodeMethodCall(sentMessage);
  }
}
