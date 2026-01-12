// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.util.Size;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ResolutionStrategyTest {
  @Test
  public void
      pigeon_defaultConstructor_createsExpectedResolutionStrategyInstanceWhenArgumentsValid() {
    final PigeonApiResolutionStrategy api =
        new TestProxyApiRegistrar().getPigeonApiResolutionStrategy();

    final Size size = new Size(1, 2);
    final ResolutionStrategy resolutionStrategy =
        api.pigeon_defaultConstructor(size, ResolutionStrategyFallbackRule.CLOSEST_HIGHER);

    assertEquals(resolutionStrategy.getBoundSize(), size);
    assertEquals(
        resolutionStrategy.getFallbackRule(), ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER);
  }

  @Test
  public void getBoundSize_returnsExpectedSize() {
    final PigeonApiResolutionStrategy api =
        new TestProxyApiRegistrar().getPigeonApiResolutionStrategy();

    final ResolutionStrategy instance = mock(ResolutionStrategy.class);
    final Size value = mock(Size.class);
    when(instance.getBoundSize()).thenReturn(value);

    assertEquals(value, api.getBoundSize(instance));
  }

  @Test
  public void getFallbackRule_returnsExpectedFallbackRule() {
    final PigeonApiResolutionStrategy api =
        new TestProxyApiRegistrar().getPigeonApiResolutionStrategy();

    final ResolutionStrategy instance = mock(ResolutionStrategy.class);
    ;
    when(instance.getFallbackRule())
        .thenReturn(ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER);

    assertEquals(
        ResolutionStrategyFallbackRule.CLOSEST_HIGHER_THEN_LOWER, api.getFallbackRule(instance));
  }
}
