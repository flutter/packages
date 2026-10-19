// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.video.VideoRecordEvent;
import org.junit.Test;

public class VideoRecordEventFinalizeTest {
  @Test
  public void getError_returnsExpectedValue() {
    final PigeonApiVideoRecordEventFinalize api =
        new TestProxyApiRegistrar().getPigeonApiVideoRecordEventFinalize();
    final VideoRecordEvent.Finalize instance = mock(VideoRecordEvent.Finalize.class);

    when(instance.getError()).thenReturn(VideoRecordEvent.Finalize.ERROR_NO_VALID_DATA);

    assertEquals((long) VideoRecordEvent.Finalize.ERROR_NO_VALID_DATA, api.getError(instance));
  }

  @Test
  public void hasError_returnsExpectedValue() {
    final PigeonApiVideoRecordEventFinalize api =
        new TestProxyApiRegistrar().getPigeonApiVideoRecordEventFinalize();
    final VideoRecordEvent.Finalize instance = mock(VideoRecordEvent.Finalize.class);

    when(instance.hasError()).thenReturn(true);

    assertEquals(true, api.hasError(instance));
  }
}
