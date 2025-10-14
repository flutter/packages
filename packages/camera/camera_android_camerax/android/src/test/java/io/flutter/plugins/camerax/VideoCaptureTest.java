// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.video.VideoCapture;
import androidx.camera.video.VideoOutput;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class VideoCaptureTest {
  @SuppressWarnings({"unchecked", "rawtypes"})
  @Test
  public void withOutput_createsVideoCaptureWithVideoOutput() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    final VideoCapture<VideoOutput> instance = mock(VideoCapture.class);
    final VideoOutput videoOutput = mock(VideoOutput.class);

    try (MockedStatic<VideoCapture> mockedCamera2CameraInfo =
        Mockito.mockStatic(VideoCapture.class)) {
      mockedCamera2CameraInfo
          .when(() -> VideoCapture.withOutput(videoOutput))
          .thenAnswer((Answer<VideoCapture>) invocation -> instance);

      assertEquals(api.withOutput(videoOutput), instance);
    }
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getOutput_returnsAssociatedRecorder() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    final VideoCapture<VideoOutput> instance = mock(VideoCapture.class);
    final VideoOutput value = mock(VideoOutput.class);
    when(instance.getOutput()).thenReturn(value);

    assertEquals(value, api.getOutput(instance));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void setTargetRotation_makesCallToSetTargetRotation() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    final VideoCapture<VideoOutput> instance = mock(VideoCapture.class);
    final long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation((int) rotation);
  }
}
