// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

import androidx.camera.video.Recorder;
import androidx.camera.video.VideoCapture;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
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
public class VideoCaptureTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public Recorder mockRecorder;
  @Mock public VideoCaptureFlutterApiImpl mockVideoCaptureFlutterApi;
  @Mock public VideoCapture<Recorder> mockVideoCapture;

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
  public void getOutput_returnsAssociatedRecorder() {
    final Long recorderId = 5L;
    final Long videoCaptureId = 6L;
    VideoCapture<Recorder> videoCapture = VideoCapture.withOutput(mockRecorder);

    testInstanceManager.addDartCreatedInstance(mockRecorder, recorderId);
    testInstanceManager.addDartCreatedInstance(videoCapture, videoCaptureId);

    VideoCaptureHostApiImpl videoCaptureHostApi =
        new VideoCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager);
    assertEquals(videoCaptureHostApi.getOutput(videoCaptureId), recorderId);
    testInstanceManager.remove(recorderId);
    testInstanceManager.remove(videoCaptureId);
  }

  @Test
  @SuppressWarnings("unchecked")
  public void withOutput_returnsNewVideoCaptureWithAssociatedRecorder() {
    final Long recorderId = 5L;
    testInstanceManager.addDartCreatedInstance(mockRecorder, recorderId);

    VideoCaptureHostApiImpl videoCaptureHostApi =
        new VideoCaptureHostApiImpl(mockBinaryMessenger, testInstanceManager);
    VideoCaptureHostApiImpl spyVideoCaptureApi = spy(videoCaptureHostApi);
    final Long videoCaptureId = videoCaptureHostApi.withOutput(recorderId);
    VideoCapture<Recorder> videoCapture = testInstanceManager.getInstance(videoCaptureId);
    assertEquals(videoCapture.getOutput(), mockRecorder);

    testInstanceManager.remove(recorderId);
    testInstanceManager.remove(videoCaptureId);
  }

  @Test
  public void flutterApiCreateTest() {
    final VideoCaptureFlutterApiImpl spyVideoCaptureFlutterApi =
        spy(new VideoCaptureFlutterApiImpl(mockBinaryMessenger, testInstanceManager));
    spyVideoCaptureFlutterApi.create(mockVideoCapture, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(mockVideoCapture));
    verify(spyVideoCaptureFlutterApi).create(eq(identifier), any());
  }
}
