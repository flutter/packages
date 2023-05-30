// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.camera.video.FileOutputOptions;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recorder;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import java.io.File;
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
public class RecorderTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public Recorder mockRecorder;
  private Context context;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = spy(InstanceManager.create(identifier -> {}));
    context = ApplicationProvider.getApplicationContext();
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void createTest() {
    final int recorderId = 0;
    final int aspectRatio = 1;
    final int bitRate = 2;

    final RecorderHostApiImpl recorderHostApi =
        new RecorderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);

    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    final Recorder.Builder mockRecorderBuilder = mock(Recorder.Builder.class);
    recorderHostApi.cameraXProxy = mockCameraXProxy;
    when(mockCameraXProxy.createRecorderBuilder()).thenReturn(mockRecorderBuilder);
    when(mockRecorderBuilder.setAspectRatio(aspectRatio)).thenReturn(mockRecorderBuilder);
    when(mockRecorderBuilder.setTargetVideoEncodingBitRate(bitRate))
        .thenReturn(mockRecorderBuilder);
    when(mockRecorderBuilder.setExecutor(any(Executor.class))).thenReturn(mockRecorderBuilder);
    when(mockRecorderBuilder.build()).thenReturn(mockRecorder);

    recorderHostApi.create(
        Long.valueOf(recorderId), Long.valueOf(aspectRatio), Long.valueOf(bitRate));
    verify(mockCameraXProxy).createRecorderBuilder();
    verify(mockRecorderBuilder).setAspectRatio(aspectRatio);
    verify(mockRecorderBuilder).setTargetVideoEncodingBitRate(bitRate);
    verify(mockRecorderBuilder).build();
    assertEquals(testInstanceManager.getInstance(Long.valueOf(recorderId)), mockRecorder);
    testInstanceManager.remove(Long.valueOf(recorderId));
  }

  @Test
  public void getAspectRatioTest() {
    final int recorderId = 3;
    final int aspectRatio = 6;

    when(mockRecorder.getAspectRatio()).thenReturn(aspectRatio);
    testInstanceManager.addDartCreatedInstance(mockRecorder, Long.valueOf(recorderId));
    final RecorderHostApiImpl recorderHostApi =
        new RecorderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    assertEquals(
        recorderHostApi.getAspectRatio(Long.valueOf(recorderId)), Long.valueOf(aspectRatio));
    verify(mockRecorder).getAspectRatio();
    testInstanceManager.remove(Long.valueOf(recorderId));
  }

  @Test
  public void getTargetVideoEncodingBitRateTest() {
    final int bitRate = 7;
    final int recorderId = 3;

    when(mockRecorder.getTargetVideoEncodingBitRate()).thenReturn(bitRate);
    testInstanceManager.addDartCreatedInstance(mockRecorder, Long.valueOf(recorderId));
    final RecorderHostApiImpl recorderHostApi =
        new RecorderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    assertEquals(
        recorderHostApi.getTargetVideoEncodingBitRate(Long.valueOf(recorderId)),
        Long.valueOf(bitRate));
    verify(mockRecorder).getTargetVideoEncodingBitRate();
    testInstanceManager.remove(Long.valueOf(recorderId));
  }

  @Test
  @SuppressWarnings("unchecked")
  public void prepareRecording_returnsExpectedPendingRecording() {
    final int recorderId = 3;

    PendingRecordingFlutterApiImpl mockPendingRecordingFlutterApi =
        mock(PendingRecordingFlutterApiImpl.class);
    PendingRecording mockPendingRecording = mock(PendingRecording.class);
    testInstanceManager.addDartCreatedInstance(mockRecorder, Long.valueOf(recorderId));
    when(mockRecorder.prepareRecording(any(Context.class), any(FileOutputOptions.class)))
        .thenReturn(mockPendingRecording);
    doNothing().when(mockPendingRecordingFlutterApi).create(any(PendingRecording.class), any());
    Long mockPendingRecordingId = testInstanceManager.addHostCreatedInstance(mockPendingRecording);

    RecorderHostApiImpl spy =
        spy(new RecorderHostApiImpl(mockBinaryMessenger, testInstanceManager, context));
    spy.pendingRecordingFlutterApi = mockPendingRecordingFlutterApi;
    doReturn(mock(File.class)).when(spy).openTempFile(any());
    spy.prepareRecording(Long.valueOf(recorderId), "");

    testInstanceManager.remove(Long.valueOf(recorderId));
    testInstanceManager.remove(mockPendingRecordingId);
  }

  @Test
  @SuppressWarnings("unchecked")
  public void prepareRecording_errorsWhenPassedNullPath() {
    final int recorderId = 3;

    testInstanceManager.addDartCreatedInstance(mockRecorder, Long.valueOf(recorderId));
    RecorderHostApiImpl recorderHostApi =
        new RecorderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    assertThrows(
        RuntimeException.class,
        () -> {
          recorderHostApi.prepareRecording(Long.valueOf(recorderId), null);
        });
    testInstanceManager.remove(Long.valueOf(recorderId));
  }

  @Test
  public void flutterApiCreateTest() {
    final RecorderFlutterApiImpl spyRecorderFlutterApi =
        spy(new RecorderFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    spyRecorderFlutterApi.create(mockRecorder, null, null, reply -> {});

    final long identifier =
        Objects.requireNonNull(testInstanceManager.getIdentifierForStrongReference(mockRecorder));
    verify(spyRecorderFlutterApi).create(eq(identifier), eq(null), eq(null), any());
  }
}
