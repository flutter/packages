// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import androidx.camera.core.SurfaceMeteringPointFactory;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

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
    MeteringPointHostApiImpl.MeteringPointProxy proxySpy = spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    MeteringPointHostApiImpl hostApi = new MeteringPointHostApiImpl(testInstanceManager);
    final Long meteringPointIdentifier = 78L;
    final Long x = 0.3;
    final Long y = 0.2;
    final Long size = 6;
    final float surfaceWidth = 1f;
    final float surfaceHeight = 1f;
    SurfaceOrientedMeteringPointFactory mockSurfaceOrientedMeteringPointFactory = mock(SurfaceOrientedMeteringPointFactory.class);

    when(proxySpy.getSurfaceOrientedMeteringPointFactory(surfaceWidth, surfaceHeight)).thenReturn(mockSurfaceOrientedMeteringPointFactory);
    when(mockSurfaceOrientedMeteringPointFactory.createPoint(x.floatValue(), y.floatValue(), size.floatValue())).thenReturn(meteringPoint);

    hostApi.create(meteringPointIdentifier, x, y, size);

    verify(mockSurfaceOrientedMeteringPointFactory.createPoint(x, y, size));
    assertEquals(
    instanceManager.getInstance(meteringPointIdentifier),
    meteringPoint);
  }

  @Test
  public void hostApiCreate_createsExpectedMeteringPointWithoutSizeSpecified() {
    MeteringPointHostApiImpl.MeteringPointProxy proxySpy = spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    MeteringPointHostApiImpl hostApi = new MeteringPointHostApiImpl(testInstanceManager);
    final Long meteringPointIdentifier = 78L;
    final Long x = 0.3;
    final Long y = 0.2;
    final float surfaceWidth = 1f;
    final float surfaceHeight = 1f;
    SurfaceOrientedMeteringPointFactory mockSurfaceOrientedMeteringPointFactory = mock(SurfaceOrientedMeteringPointFactory.class);

    when(proxySpy.getSurfaceOrientedMeteringPointFactory(surfaceWidth, surfaceHeight)).thenReturn(mockSurfaceOrientedMeteringPointFactory);
    when(mockSurfaceOrientedMeteringPointFactory.createPoint(x.floatValue(), y.floatValue())).thenReturn(meteringPoint);

    hostApi.create(meteringPointIdentifier, x, y, null);

    verify(mockSurfaceOrientedMeteringPointFactory.createPoint(x, y));
    assertEquals(
    instanceManager.getInstance(meteringPointIdentifier),
    meteringPoint);
  }

  @Test
  public void getDefaultPointSize_returnsExpectedSize() {
    try (MockedStatic<MeteringPointFactory> mockedMeteringPointFactory = Mockito.mockStatic(MeteringPointFactory.class)) {
      final MeteringPointHostApiImpl meteringPointHostApiImpl =
          new MeteringPointHostApiImpl(testInstanceManager);
      final Long meteringPointIdentifier = 93L;
      final Long index = 2L;
      final Double defaultPointSize = 4D;

      testInstanceManager.addDartCreatedInstance(meteringPoint, meteringPointIdentifier);

        mockedMeteringPointFactory
                    .when(() ->  MeteringPointFactory.getDefaultPointSize())
                    .thenAnswer(
                        (Answer<float>)
                            invocation -> defaultPointSize.floatValue());

      assertEquals(meteringPointHostApiImpl.getDefaultPointSize(), defaultPointSize);
      mockedMeteringPointFactory.verify(
          () -> MeteringPointFactory.getDefaultPointSize()));
    }
}
}
