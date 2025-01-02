// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.resolutionselector.AspectRatioStrategy
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

public class AspectRatioStrategyProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiAspectRatioStrategy api = new TestProxyApiRegistrar().getPigeonApiAspectRatioStrategy();

    assertTrue(api.pigeon_defaultConstructor(io.flutter.plugins.camerax.AspectRatio.RATIO16TO9, io.flutter.plugins.camerax.AspectRatioStrategyFallbackRule.AUTO) instanceof AspectRatioStrategyProxyApi.AspectRatioStrategy);
  }

}
