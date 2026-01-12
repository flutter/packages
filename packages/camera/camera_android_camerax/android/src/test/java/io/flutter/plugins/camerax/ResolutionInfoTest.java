// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.util.Size;
import androidx.camera.core.ResolutionInfo;
import org.junit.Test;

public class ResolutionInfoTest {
  @Test
  public void resolution_returnsExpectedResolution() {
    final PigeonApiResolutionInfo api = new TestProxyApiRegistrar().getPigeonApiResolutionInfo();

    final ResolutionInfo instance = mock(ResolutionInfo.class);
    final Size value = mock(Size.class);
    when(instance.getResolution()).thenReturn(value);

    assertEquals(value, api.resolution(instance));
  }
}
