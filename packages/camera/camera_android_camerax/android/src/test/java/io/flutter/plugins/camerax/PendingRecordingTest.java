// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recording;
import androidx.camera.video.VideoRecordEvent;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import java.util.concurrent.Executor;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class PendingRecordingTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public PendingRecording mockPendingRecording;
  @Mock public Recording mockRecording;
  @Mock public RecordingFlutterApiImpl mockRecordingFlutterApi;
  @Mock public Context mockContext;
  @Mock public SystemServicesFlutterApiImpl mockSystemServicesFlutterApi;
  @Mock public PendingRecordingFlutterApiImpl mockPendingRecordingFlutterApi;
  @Mock public VideoRecordEvent.Finalize event;
  @Mock public Throwable throwable;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = spy(InstanceManager.create(identifier -> {}));
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void testStart() {
    final Long mockPendingRecordingId = 3L;
    final Long mockRecordingId = testInstanceManager.addHostCreatedInstance(mockRecording);
    testInstanceManager.addDartCreatedInstance(mockPendingRecording, mockPendingRecordingId);

    doReturn(mockRecording).when(mockPendingRecording).start(any(), any());
    doNothing().when(mockRecordingFlutterApi).create(any(Recording.class), any());
    PendingRecordingHostApiImpl spy =
        spy(new PendingRecordingHostApiImpl(mockBinaryMessenger, testInstanceManager, mockContext));
    doReturn(mock(Executor.class)).when(spy).getExecutor();
    spy.recordingFlutterApi = mockRecordingFlutterApi;
    assertEquals(spy.start(mockPendingRecordingId), mockRecordingId);
    verify(mockRecordingFlutterApi).create(eq(mockRecording), any());

    testInstanceManager.remove(mockPendingRecordingId);
    testInstanceManager.remove(mockRecordingId);
  }

  @Test
  public void testHandleVideoRecordEventSendsError() {
    PendingRecordingHostApiImpl pendingRecordingHostApi =
        new PendingRecordingHostApiImpl(mockBinaryMessenger, testInstanceManager, mockContext);
    pendingRecordingHostApi.systemServicesFlutterApi = mockSystemServicesFlutterApi;
    pendingRecordingHostApi.pendingRecordingFlutterApi = mockPendingRecordingFlutterApi;
    final String eventMessage = "example failure message";

    when(event.hasError()).thenReturn(true);
    when(event.getCause()).thenReturn(throwable);
    when(throwable.toString()).thenReturn(eventMessage);
    doNothing().when(mockSystemServicesFlutterApi).sendCameraError(any(), any());

    pendingRecordingHostApi.handleVideoRecordEvent(event);

    verify(mockPendingRecordingFlutterApi).sendVideoRecordingFinalizedEvent(any());
    verify(mockSystemServicesFlutterApi).sendCameraError(eq(eventMessage), any());
  }

  @Test
  public void handleVideoRecordEvent_SendsVideoRecordingFinalizedEvent() {
    PendingRecordingHostApiImpl pendingRecordingHostApi =
        new PendingRecordingHostApiImpl(mockBinaryMessenger, testInstanceManager, mockContext);
    pendingRecordingHostApi.pendingRecordingFlutterApi = mockPendingRecordingFlutterApi;

    when(event.hasError()).thenReturn(false);

    pendingRecordingHostApi.handleVideoRecordEvent(event);

    verify(mockPendingRecordingFlutterApi).sendVideoRecordingFinalizedEvent(any());
  }

  @Test
  public void handleVideoRecordEvent_SendsVideoRecordingStartedEvent() {
    PendingRecordingHostApiImpl pendingRecordingHostApi =
        new PendingRecordingHostApiImpl(mockBinaryMessenger, testInstanceManager, mockContext);
    pendingRecordingHostApi.pendingRecordingFlutterApi = mockPendingRecordingFlutterApi;
    VideoRecordEvent.Start mockStartEvent = mock(VideoRecordEvent.Start.class);

    pendingRecordingHostApi.handleVideoRecordEvent(mockStartEvent);

    verify(mockPendingRecordingFlutterApi).sendVideoRecordingStartedEvent(any());
  }

  @Test
  public void flutterApiCreateTest() {
    final PendingRecordingFlutterApiImpl spyPendingRecordingFlutterApi =
        spy(new PendingRecordingFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    spyPendingRecordingFlutterApi.create(mockPendingRecording, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(mockPendingRecording));
    verify(spyPendingRecordingFlutterApi).create(eq(identifier), any());
  }
}
