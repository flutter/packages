// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.DynamicRange;
import androidx.camera.video.Quality;
import androidx.camera.video.VideoCapabilities;
import java.util.Arrays;
import java.util.Collections;
import org.junit.Test;

public class VideoCapabilitiesTest {
  @Test
  public void getSupportedQualities_returnsExpectedQualities() {
    final PigeonApiVideoCapabilities api =
        new TestProxyApiRegistrar().getPigeonApiVideoCapabilities();

    final VideoCapabilities instance = mock(VideoCapabilities.class);
    when(instance.getSupportedQualities(DynamicRange.SDR))
        .thenReturn(Arrays.asList(Quality.UHD, Quality.FHD, Quality.HD, Quality.SD));

    assertEquals(
        Arrays.asList(VideoQuality.UHD, VideoQuality.FHD, VideoQuality.HD, VideoQuality.SD),
        api.getSupportedQualities(instance, DynamicRange.SDR));
  }

  @Test
  public void getSupportedQualities_skipsQualitiesWithoutVideoQuality() {
    final PigeonApiVideoCapabilities api =
        new TestProxyApiRegistrar().getPigeonApiVideoCapabilities();

    final VideoCapabilities instance = mock(VideoCapabilities.class);
    when(instance.getSupportedQualities(DynamicRange.SDR))
        .thenReturn(Arrays.asList(Quality.QHD, Quality.FHD, Quality.HD));

    assertEquals(
        Arrays.asList(VideoQuality.FHD, VideoQuality.HD),
        api.getSupportedQualities(instance, DynamicRange.SDR));
  }

  @Test
  public void getSupportedQualities_returnsEmptyListWhenNoQualityIsSupported() {
    final PigeonApiVideoCapabilities api =
        new TestProxyApiRegistrar().getPigeonApiVideoCapabilities();

    final VideoCapabilities instance = mock(VideoCapabilities.class);
    when(instance.getSupportedQualities(DynamicRange.SDR)).thenReturn(Collections.emptyList());

    assertEquals(Collections.emptyList(), api.getSupportedQualities(instance, DynamicRange.SDR));
  }
}
