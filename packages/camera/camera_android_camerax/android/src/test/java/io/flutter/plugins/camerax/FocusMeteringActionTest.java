// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.MeteringPoint;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class FocusMeteringActionTest {
  @Test
  public void meteringPointsAe_returnsExpectedAeMeteringPoints() {
    final PigeonApiFocusMeteringAction api =
        new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final List<MeteringPoint> value = Collections.singletonList(mock(MeteringPoint.class));
    when(instance.getMeteringPointsAe()).thenReturn(value);

    assertEquals(value, api.meteringPointsAe(instance));
  }

  @Test
  public void meteringPointsAf_returnsExpectedAfMeteringPoints() {
    final PigeonApiFocusMeteringAction api =
        new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final List<androidx.camera.core.MeteringPoint> value =
        Collections.singletonList(mock(MeteringPoint.class));
    when(instance.getMeteringPointsAf()).thenReturn(value);

    assertEquals(value, api.meteringPointsAf(instance));
  }

  @Test
  public void meteringPointsAwb_returnsExpectedAwbMeteringPoints() {
    final PigeonApiFocusMeteringAction api =
        new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final List<androidx.camera.core.MeteringPoint> value =
        Collections.singletonList(mock(MeteringPoint.class));
    when(instance.getMeteringPointsAwb()).thenReturn(value);

    assertEquals(value, api.meteringPointsAwb(instance));
  }

  @Test
  public void isAutoCancelEnabled_callsIsAutoCancelEnabledOnInstance() {
    final PigeonApiFocusMeteringAction api =
        new TestProxyApiRegistrar().getPigeonApiFocusMeteringAction();

    final FocusMeteringAction instance = mock(FocusMeteringAction.class);
    final Boolean value = true;
    when(instance.isAutoCancelEnabled()).thenReturn(value);

    assertEquals(value, api.isAutoCancelEnabled(instance));
  }
}
