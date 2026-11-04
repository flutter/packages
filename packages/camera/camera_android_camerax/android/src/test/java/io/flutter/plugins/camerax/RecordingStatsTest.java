// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.video.RecordingStats;
import org.junit.Test;

public class RecordingStatsTest {
  @Test
  public void recordedDurationNanos_returnsExpectedValue() {
    final PigeonApiRecordingStats api = new TestProxyApiRegistrar().getPigeonApiRecordingStats();
    final RecordingStats instance = mock(RecordingStats.class);

    when(instance.getRecordedDurationNanos()).thenReturn(123456789L);

    assertEquals(123456789L, api.recordedDurationNanos(instance));
  }

  @Test
  public void numBytesRecorded_returnsExpectedValue() {
    final PigeonApiRecordingStats api = new TestProxyApiRegistrar().getPigeonApiRecordingStats();
    final RecordingStats instance = mock(RecordingStats.class);

    when(instance.getNumBytesRecorded()).thenReturn(987654L);

    assertEquals(987654L, api.numBytesRecorded(instance));
  }
}
