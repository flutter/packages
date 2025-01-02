// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.FocusMeteringAction
import androidx.camera.core.MeteringPoint
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

public class FocusMeteringActionProxyApiTest {
  @Test
  public void meteringPointsAe() {
    final PigeonApiFocusMeteringAction api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final List<androidx.camera.core.MeteringPoint> value = Arrays.asList(mock(MeteringPoint.class));
    when(instance.getMeteringPointsAe()).thenReturn(value);

    assertEquals(value, api.meteringPointsAe(instance));
  }

  @Test
  public void meteringPointsAf() {
    final PigeonApiFocusMeteringAction api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final List<androidx.camera.core.MeteringPoint> value = Arrays.asList(mock(MeteringPoint.class));
    when(instance.getMeteringPointsAf()).thenReturn(value);

    assertEquals(value, api.meteringPointsAf(instance));
  }

  @Test
  public void meteringPointsAwb() {
    final PigeonApiFocusMeteringAction api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final List<androidx.camera.core.MeteringPoint> value = Arrays.asList(mock(MeteringPoint.class));
    when(instance.getMeteringPointsAwb()).thenReturn(value);

    assertEquals(value, api.meteringPointsAwb(instance));
  }

  @Test
  public void isAutoCancelEnabled() {
    final PigeonApiFocusMeteringAction api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final Boolean value = true;
    when(instance.getIsAutoCancelEnabled()).thenReturn(value);

    assertEquals(value, api.isAutoCancelEnabled(instance));
  }

}
