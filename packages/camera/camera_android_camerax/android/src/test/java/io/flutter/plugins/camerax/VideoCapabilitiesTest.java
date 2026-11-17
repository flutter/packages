// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.DynamicRange;
import androidx.camera.video.VideoCapabilities;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import org.junit.Test;

public class VideoCapabilitiesTest {
  @Test
  public void getSupportedDynamicRanges_returnsOnlyTheRangesThePluginKnows() {
    final PigeonApiVideoCapabilities api =
        new TestProxyApiRegistrar().getPigeonApiVideoCapabilities();
    final VideoCapabilities instance = mock(VideoCapabilities.class);
    when(instance.getSupportedDynamicRanges())
        .thenReturn(
            new HashSet<>(
                Arrays.asList(
                    DynamicRange.SDR, DynamicRange.HLG_10_BIT, DynamicRange.HDR10_10_BIT)));

    final List<DynamicRangeType> result = api.getSupportedDynamicRanges(instance);

    assertEquals(Arrays.asList(DynamicRangeType.SDR, DynamicRangeType.HLG10), result);
  }

  @Test
  public void getSupportedDynamicRanges_isSdrOnlyWithoutHlg() {
    final PigeonApiVideoCapabilities api =
        new TestProxyApiRegistrar().getPigeonApiVideoCapabilities();
    final VideoCapabilities instance = mock(VideoCapabilities.class);
    when(instance.getSupportedDynamicRanges())
        .thenReturn(new HashSet<>(Arrays.asList(DynamicRange.SDR)));

    assertEquals(Arrays.asList(DynamicRangeType.SDR), api.getSupportedDynamicRanges(instance));
  }
}
