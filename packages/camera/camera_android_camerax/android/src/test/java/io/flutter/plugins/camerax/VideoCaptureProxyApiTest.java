// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.video.VideoCapture<*>
import androidx.camera.video.VideoOutput
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class VideoCaptureProxyApiTest {
  @Test
  public void withOutput() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    assertTrue(api.withOutput(mock(VideoOutput.class)) instanceof VideoCaptureProxyApi.VideoCapture);
  }

  @Test
  public void getOutput() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    final VideoCapture instance = mock(VideoCapture.class);
    final androidx.camera.video.VideoOutput value = mock(VideoOutput.class);
    when(instance.getOutput()).thenReturn(value);

    assertEquals(value, api.getOutput(instance ));
  }

  @Test
  public void setTargetRotation() {
    final PigeonApiVideoCapture api = new TestProxyApiRegistrar().getPigeonApiVideoCapture();

    final VideoCapture instance = mock(VideoCapture.class);
    final Long rotation = 0;
    api.setTargetRotation(instance, rotation);

    verify(instance).setTargetRotation(rotation);
  }

}
