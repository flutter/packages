// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import org.junit.Test;

public class AspectRatioStrategyTest {
  @Test
  public void pigeon_defaultConstructor_createsExpectedAspectRatioStrategyInstance() {
    final PigeonApiAspectRatioStrategy api =
        new TestProxyApiRegistrar().getPigeonApiAspectRatioStrategy();

    final AspectRatioStrategy instance =
        api.pigeon_defaultConstructor(
            io.flutter.plugins.camerax.AspectRatio.RATIO16TO9,
            io.flutter.plugins.camerax.AspectRatioStrategyFallbackRule.AUTO);
    assertEquals(instance.getPreferredAspectRatio(), androidx.camera.core.AspectRatio.RATIO_16_9);
    assertEquals(instance.getFallbackRule(), AspectRatioStrategy.FALLBACK_RULE_AUTO);
  }

  @Test
  public void getFallbackRule_returnsFallbackRuleOfInstance() {
    final PigeonApiAspectRatioStrategy api =
        new TestProxyApiRegistrar().getPigeonApiAspectRatioStrategy();

    final AspectRatioStrategy instance = mock(AspectRatioStrategy.class);
    final AspectRatioStrategyFallbackRule value =
        io.flutter.plugins.camerax.AspectRatioStrategyFallbackRule.AUTO;
    when(instance.getFallbackRule()).thenReturn(AspectRatioStrategy.FALLBACK_RULE_AUTO);

    assertEquals(value, api.getFallbackRule(instance));
  }

  @Test
  public void getPreferredAspectRatio_returnAspectRatioOfInstance() {
    final PigeonApiAspectRatioStrategy api =
        new TestProxyApiRegistrar().getPigeonApiAspectRatioStrategy();

    final AspectRatioStrategy instance = mock(AspectRatioStrategy.class);
    final AspectRatio value = io.flutter.plugins.camerax.AspectRatio.RATIO16TO9;
    when(instance.getPreferredAspectRatio())
        .thenReturn(androidx.camera.core.AspectRatio.RATIO_16_9);

    assertEquals(value, api.getPreferredAspectRatio(instance));
  }
}
