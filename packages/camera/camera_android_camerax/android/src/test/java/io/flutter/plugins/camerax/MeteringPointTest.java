// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import androidx.camera.core.SurfaceOrientedMeteringPointFactory;
import io.flutter.plugin.common.BinaryMessenger;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;

public class MeteringPointTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public MeteringPoint meteringPoint;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void hostApiCreate_createsExpectedMeteringPointWithSizeSpecified() {
    MeteringPointHostApiImpl.MeteringPointProxy proxySpy =
        spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    MeteringPointHostApiImpl hostApi = new MeteringPointHostApiImpl(testInstanceManager, proxySpy);
    final Long meteringPointIdentifier = 78L;
    final Float x = 0.3f;
    final Float y = 0.2f;
    final Float size = 6f;
    final Float surfaceWidth = 1f;
    final Float surfaceHeight = 1f;
    SurfaceOrientedMeteringPointFactory mockSurfaceOrientedMeteringPointFactory =
        mock(SurfaceOrientedMeteringPointFactory.class);

    when(proxySpy.getSurfaceOrientedMeteringPointFactory(surfaceWidth, surfaceHeight))
        .thenReturn(mockSurfaceOrientedMeteringPointFactory);
    when(mockSurfaceOrientedMeteringPointFactory.createPoint(x, y, size)).thenReturn(meteringPoint);

    hostApi.create(meteringPointIdentifier, x.doubleValue(), y.doubleValue(), size.doubleValue());

    verify(mockSurfaceOrientedMeteringPointFactory).createPoint(x, y, size);
    assertEquals(testInstanceManager.getInstance(meteringPointIdentifier), meteringPoint);
  }

  @Test
  public void hostApiCreate_createsExpectedMeteringPointWithoutSizeSpecified() {
    MeteringPointHostApiImpl.MeteringPointProxy proxySpy =
        spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    MeteringPointHostApiImpl hostApi = new MeteringPointHostApiImpl(testInstanceManager, proxySpy);
    final Long meteringPointIdentifier = 78L;
    final Float x = 0.3f;
    final Float y = 0.2f;
    final Float surfaceWidth = 1f;
    final Float surfaceHeight = 1f;
    SurfaceOrientedMeteringPointFactory mockSurfaceOrientedMeteringPointFactory =
        mock(SurfaceOrientedMeteringPointFactory.class);

    when(proxySpy.getSurfaceOrientedMeteringPointFactory(surfaceWidth, surfaceHeight))
        .thenReturn(mockSurfaceOrientedMeteringPointFactory);
    when(mockSurfaceOrientedMeteringPointFactory.createPoint(x, y)).thenReturn(meteringPoint);

    hostApi.create(meteringPointIdentifier, x.doubleValue(), y.doubleValue(), null);

    verify(mockSurfaceOrientedMeteringPointFactory).createPoint(x, y);
    assertEquals(testInstanceManager.getInstance(meteringPointIdentifier), meteringPoint);
  }

  @Test
  public void getDefaultPointSize_returnsExpectedSize() {
    try (MockedStatic<MeteringPointFactory> mockedMeteringPointFactory =
        Mockito.mockStatic(MeteringPointFactory.class)) {
      final MeteringPointHostApiImpl meteringPointHostApiImpl =
          new MeteringPointHostApiImpl(testInstanceManager);
      final Long meteringPointIdentifier = 93L;
      final Long index = 2L;
      final Double defaultPointSize = 4D;

      testInstanceManager.addDartCreatedInstance(meteringPoint, meteringPointIdentifier);

      mockedMeteringPointFactory
          .when(() -> MeteringPointFactory.getDefaultPointSize())
          .thenAnswer((Answer<Float>) invocation -> defaultPointSize.floatValue());

      assertEquals(meteringPointHostApiImpl.getDefaultPointSize(), defaultPointSize);
      mockedMeteringPointFactory.verify(() -> MeteringPointFactory.getDefaultPointSize());
    }
  }
}
