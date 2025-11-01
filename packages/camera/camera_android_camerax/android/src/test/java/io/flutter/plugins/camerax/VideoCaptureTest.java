// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import androidx.camera.camera2.interop.Camera2Interop;
import androidx.camera.video.VideoCapture;
import androidx.camera.video.VideoOutput;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedConstruction;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class VideoCaptureTest {
  @SuppressWarnings({"unchecked", "rawtypes"})
  @Test
  public void withOutput_createsVideoCaptureWithVideoOutput() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    final VideoOutput videoOutput = mock(VideoOutput.class);
    final long targetFps = 30;

    try (MockedConstruction<Camera2Interop.Extender> mockCamera2InteropExtender =
        Mockito.mockConstruction(
            Camera2Interop.Extender.class,
            (mock, context) -> {
              when(mock.setCaptureRequestOption(
                      CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                      new Range<>(targetFps, targetFps)))
                  .thenReturn(mock);
            })) {
      final VideoCapture videoCapture = api.withOutput(videoOutput, targetFps);

      assertEquals(1, mockCamera2InteropExtender.constructed().size());
      assertEquals(videoOutput, videoCapture.getOutput());
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
