// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.video.Recorder
import androidx.camera.video.QualitySelector
import androidx.camera.video.PendingRecording
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

public class RecorderProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    assertTrue(api.pigeon_defaultConstructor(0, 0, mock(QualitySelector.class)) instanceof RecorderProxyApi.Recorder);
  }

  @Test
  public void getAspectRatio() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder instance = mock(Recorder.class);
    final Long value = 0;
    when(instance.getAspectRatio()).thenReturn(value);

    assertEquals(value, api.getAspectRatio(instance ));
  }

  @Test
  public void getTargetVideoEncodingBitRate() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder instance = mock(Recorder.class);
    final Long value = 0;
    when(instance.getTargetVideoEncodingBitRate()).thenReturn(value);

    assertEquals(value, api.getTargetVideoEncodingBitRate(instance ));
  }

  @Test
  public void prepareRecording() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder instance = mock(Recorder.class);
    final String path = "myString";
    final androidx.camera.video.PendingRecording value = mock(PendingRecording.class);
    when(instance.prepareRecording(path)).thenReturn(value);

    assertEquals(value, api.prepareRecording(instance, path));
  }

}
