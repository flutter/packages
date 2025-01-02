// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.FocusMeteringAction.Builder
import androidx.camera.core.MeteringPoint
import androidx.camera.core.FocusMeteringAction
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

public class FocusMeteringActionBuilderProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiFocusMeteringActionBuilder api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringActionBuilder();

    assertTrue(api.pigeon_defaultConstructor(mock(MeteringPoint.class)) instanceof FocusMeteringActionBuilderProxyApi.FocusMeteringActionBuilder);
  }

  @Test
  public void withMode() {
    final PigeonApiFocusMeteringActionBuilder api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringActionBuilder();

    assertTrue(api.withMode(mock(MeteringPoint.class), io.flutter.plugins.camerax.MeteringMode.AE) instanceof FocusMeteringActionBuilderProxyApi.FocusMeteringActionBuilder);
  }

  @Test
  public void addPoint() {
    final PigeonApiFocusMeteringActionBuilder api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringActionBuilder();

    final FocusMeteringActionBuilder instance = mock(FocusMeteringActionBuilder.class);
    final androidx.camera.core.MeteringPoint point = mock(MeteringPoint.class);
    api.addPoint(instance, point);

    verify(instance).addPoint(point);
  }

  @Test
  public void addPointWithMode() {
    final PigeonApiFocusMeteringActionBuilder api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringActionBuilder();

    final FocusMeteringActionBuilder instance = mock(FocusMeteringActionBuilder.class);
    final androidx.camera.core.MeteringPoint point = mock(MeteringPoint.class);
    final MeteringMode mode = io.flutter.plugins.camerax.MeteringMode.AE;
    api.addPointWithMode(instance, point, mode);

    verify(instance).addPointWithMode(point, mode);
  }

  @Test
  public void disableAutoCancel() {
    final PigeonApiFocusMeteringActionBuilder api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringActionBuilder();

    final FocusMeteringActionBuilder instance = mock(FocusMeteringActionBuilder.class);
    api.disableAutoCancel(instance );

    verify(instance).disableAutoCancel();
  }

  @Test
  public void build() {
    final PigeonApiFocusMeteringActionBuilder api = new TestProxyApiRegistrar().getPigeonApiFocusMeteringActionBuilder();

    final FocusMeteringActionBuilder instance = mock(FocusMeteringActionBuilder.class);
    final androidx.camera.core.FocusMeteringAction value = mock(FocusMeteringAction.class);
    when(instance.build()).thenReturn(value);

    assertEquals(value, api.build(instance ));
  }

}
