// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.video.QualitySelector
import androidx.camera.video.FallbackStrategy
import androidx.camera.core.CameraInfo
import android.util.Size
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

public class QualitySelectorProxyApiTest {
  @Test
  public void from() {
    final PigeonApiQualitySelector api = new TestProxyApiRegistrar().getPigeonApiQualitySelector();

    assertTrue(api.from(io.flutter.plugins.camerax.VideoQuality.SD, mock(FallbackStrategy.class)) instanceof QualitySelectorProxyApi.QualitySelector);
  }

  @Test
  public void fromOrderedList() {
    final PigeonApiQualitySelector api = new TestProxyApiRegistrar().getPigeonApiQualitySelector();

    assertTrue(api.fromOrderedList(Arrays.asList(io.flutter.plugins.camerax.VideoQuality.SD), mock(FallbackStrategy.class)) instanceof QualitySelectorProxyApi.QualitySelector);
  }

}
