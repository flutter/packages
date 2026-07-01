// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ResolutionSelectorTest {
  @Test
  public void pigeon_defaultConstructor_createsExpectedResolutionSelectorInstance() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionFilter resolutionFilter = mock(ResolutionFilter.class);
    final ResolutionStrategy resolutionStrategy = mock(ResolutionStrategy.class);
    final AspectRatioStrategy aspectRatioStrategy = mock(AspectRatioStrategy.class);

    final ResolutionSelector instance =
        api.pigeon_defaultConstructor(
            resolutionFilter, resolutionStrategy, null, aspectRatioStrategy);

    assertEquals(instance.getResolutionFilter(), resolutionFilter);
    assertEquals(instance.getResolutionStrategy(), resolutionStrategy);
    assertEquals(instance.getAspectRatioStrategy(), aspectRatioStrategy);
  }

  @Test
  public void
      pigeon_defaultConstructor_setsPreferHigherResolutionOverCaptureRateWhenRequested() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionSelector instance =
        api.pigeon_defaultConstructor(
            null,
            ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY,
            (long) ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE,
            null);

    assertEquals(
        ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE,
        instance.getAllowedResolutionMode());
  }

  @Test
  public void
      pigeon_defaultConstructor_setsPreferCaptureRateOverHigherResolutionWhenRequested() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionSelector instance =
        api.pigeon_defaultConstructor(
            null,
            ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY,
            (long) ResolutionSelector.PREFER_CAPTURE_RATE_OVER_HIGHER_RESOLUTION,
            null);

    assertEquals(
        ResolutionSelector.PREFER_CAPTURE_RATE_OVER_HIGHER_RESOLUTION,
        instance.getAllowedResolutionMode());
  }

  @Test
  public void allowedResolutionMode_returnsExpectedAllowedResolutionMode() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionSelector instance =
        new ResolutionSelector.Builder()
            .setAllowedResolutionMode(
                ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE)
            .build();

    assertEquals(
        (long) ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE,
        api.allowedResolutionMode(instance).longValue());
  }

  @Test
  public void resolutionFilter_returnsExpectedResolutionFilter() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionSelector instance = mock(ResolutionSelector.class);
    final androidx.camera.core.resolutionselector.ResolutionFilter value =
        mock(ResolutionFilter.class);
    when(instance.getResolutionFilter()).thenReturn(value);

    assertEquals(value, api.resolutionFilter(instance));
  }

  @Test
  public void resolutionStrategy_returnsExpectedResolutionStrategy() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionSelector instance = mock(ResolutionSelector.class);
    final androidx.camera.core.resolutionselector.ResolutionStrategy value =
        mock(ResolutionStrategy.class);
    when(instance.getResolutionStrategy()).thenReturn(value);

    assertEquals(value, api.resolutionStrategy(instance));
  }

  @Test
  public void getAspectRatioStrategy() {
    final PigeonApiResolutionSelector api =
        new TestProxyApiRegistrar().getPigeonApiResolutionSelector();

    final ResolutionSelector instance = mock(ResolutionSelector.class);
    final androidx.camera.core.resolutionselector.AspectRatioStrategy value =
        mock(AspectRatioStrategy.class);
    when(instance.getAspectRatioStrategy()).thenReturn(value);

    assertEquals(value, api.getAspectRatioStrategy(instance));
  }
}
