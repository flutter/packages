// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.FocusMeteringResult;
import org.junit.Test;

public class FocusMeteringResultTest {
  @Test
  public void isFocusSuccessful_returnsExpectedResult() {
    final PigeonApiFocusMeteringResult api =
        new TestProxyApiRegistrar().getPigeonApiFocusMeteringResult();

    final FocusMeteringResult instance = mock(FocusMeteringResult.class);
    final Boolean value = true;
    when(instance.isFocusSuccessful()).thenReturn(value);

    assertEquals(value, api.isFocusSuccessful(instance));
  }
}
