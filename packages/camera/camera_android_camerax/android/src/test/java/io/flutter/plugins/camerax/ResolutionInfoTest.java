// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.ResolutionInfo;
import android.util.Size;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class ResolutionInfoTest {
  @Test
  public void resolution() {
    final PigeonApiResolutionInfo api = new TestProxyApiRegistrar().getPigeonApiResolutionInfo();

    final ResolutionInfo instance = mock(ResolutionInfo.class);
    final Size value = mock(Size.class);
    when(instance.getResolution()).thenReturn(value);

    assertEquals(value, api.resolution(instance));
  }
}
