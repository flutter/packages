// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.video.RecordingStats;
import androidx.camera.video.VideoRecordEvent;
import org.junit.Test;

public class VideoRecordEventTest {
  @Test
  public void getRecordingStats_returnsExpectedValue() {
    final PigeonApiVideoRecordEvent api =
        new TestProxyApiRegistrar().getPigeonApiVideoRecordEvent();
    final VideoRecordEvent instance = mock(VideoRecordEvent.class);
    final RecordingStats stats = mock(RecordingStats.class);

    when(instance.getRecordingStats()).thenReturn(stats);

    assertEquals(stats, api.getRecordingStats(instance));
  }
}
