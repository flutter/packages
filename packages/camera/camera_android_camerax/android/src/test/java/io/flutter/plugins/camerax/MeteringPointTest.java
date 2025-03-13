// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.view.Display;
import android.view.WindowManager;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.DisplayOrientedMeteringPointFactory;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.MeteringPointFactory;
import io.flutter.plugin.common.BinaryMessenger;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
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
  @Config(sdk = 30)
  public void hostApiCreate_createsExpectedMeteringPointWithSizeSpecified_AboveAndroid30() {
    final MeteringPointHostApiImpl.MeteringPointProxy proxySpy =
        spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    final MeteringPointHostApiImpl hostApi =
        new MeteringPointHostApiImpl(testInstanceManager, proxySpy);
    final Long meteringPointIdentifier = 78L;
    final Float x = 0.25f;
    final Float y = 0.18f;
    final Float size = 0.6f;
    final Float surfaceWidth = 1f;
    final Float surfaceHeight = 1f;
    final DisplayOrientedMeteringPointFactory mockDisplayOrientedMeteringPointFactory =
        mock(DisplayOrientedMeteringPointFactory.class);
    final Activity mockActivity = mock(Activity.class);
    final Display mockDisplay = mock(Display.class);
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final long mockCameraInfoId = 55L;

    hostApi.setActivity(mockActivity);
    testInstanceManager.addDartCreatedInstance(mockCameraInfo, mockCameraInfoId);

    when(mockActivity.getDisplay()).thenReturn(mockDisplay);
    when(proxySpy.getDisplayOrientedMeteringPointFactory(
            mockDisplay, mockCameraInfo, surfaceWidth, surfaceHeight))
        .thenReturn(mockDisplayOrientedMeteringPointFactory);
    when(mockDisplayOrientedMeteringPointFactory.createPoint(x, y, size)).thenReturn(meteringPoint);

    hostApi.create(
        meteringPointIdentifier,
        x.doubleValue(),
        y.doubleValue(),
        size.doubleValue(),
        mockCameraInfoId);

    verify(mockDisplayOrientedMeteringPointFactory).createPoint(x, y, size);
    assertEquals(testInstanceManager.getInstance(meteringPointIdentifier), meteringPoint);
  }

  @Test
  @Config(sdk = 29)
  @SuppressWarnings("deprecation")
  public void hostApiCreate_createsExpectedMeteringPointWithSizeSpecified_BelowAndroid30() {
    final MeteringPointHostApiImpl.MeteringPointProxy proxySpy =
        spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    final MeteringPointHostApiImpl hostApi =
        new MeteringPointHostApiImpl(testInstanceManager, proxySpy);
    final Long meteringPointIdentifier = 78L;
    final Float x = 0.3f;
    final Float y = 0.2f;
    final Float size = 6f;
    final Float surfaceWidth = 1f;
    final Float surfaceHeight = 1f;
    final DisplayOrientedMeteringPointFactory mockDisplayOrientedMeteringPointFactory =
        mock(DisplayOrientedMeteringPointFactory.class);
    final Activity mockActivity = mock(Activity.class);
    final WindowManager mockWindowManager = mock(WindowManager.class);
    final Display mockDisplay = mock(Display.class);
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final long mockCameraInfoId = 5L;

    hostApi.setActivity(mockActivity);
    testInstanceManager.addDartCreatedInstance(mockCameraInfo, mockCameraInfoId);

    when(mockActivity.getSystemService(Context.WINDOW_SERVICE)).thenReturn(mockWindowManager);
    when(mockWindowManager.getDefaultDisplay()).thenReturn(mockDisplay);
    when(proxySpy.getDisplayOrientedMeteringPointFactory(
            mockDisplay, mockCameraInfo, surfaceWidth, surfaceHeight))
        .thenReturn(mockDisplayOrientedMeteringPointFactory);
    when(mockDisplayOrientedMeteringPointFactory.createPoint(x, y, size)).thenReturn(meteringPoint);

    hostApi.create(
        meteringPointIdentifier,
        x.doubleValue(),
        y.doubleValue(),
        size.doubleValue(),
        mockCameraInfoId);

    verify(mockDisplayOrientedMeteringPointFactory).createPoint(x, y, size);
    assertEquals(testInstanceManager.getInstance(meteringPointIdentifier), meteringPoint);
  }

  @Test
  @Config(sdk = 30)
  public void hostApiCreate_createsExpectedMeteringPointWithoutSizeSpecified_AboveAndroid30() {
    final MeteringPointHostApiImpl.MeteringPointProxy proxySpy =
        spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    final MeteringPointHostApiImpl hostApi =
        new MeteringPointHostApiImpl(testInstanceManager, proxySpy);
    final Long meteringPointIdentifier = 78L;
    final Float x = 0.23f;
    final Float y = 0.32f;
    final Float surfaceWidth = 1f;
    final Float surfaceHeight = 1f;
    final DisplayOrientedMeteringPointFactory mockDisplayOrientedMeteringPointFactory =
        mock(DisplayOrientedMeteringPointFactory.class);
    final Activity mockActivity = mock(Activity.class);
    final Display mockDisplay = mock(Display.class);
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final long mockCameraInfoId = 6L;

    hostApi.setActivity(mockActivity);
    testInstanceManager.addDartCreatedInstance(mockCameraInfo, mockCameraInfoId);

    when(mockActivity.getDisplay()).thenReturn(mockDisplay);
    when(proxySpy.getDisplayOrientedMeteringPointFactory(
            mockDisplay, mockCameraInfo, surfaceWidth, surfaceHeight))
        .thenReturn(mockDisplayOrientedMeteringPointFactory);
    when(mockDisplayOrientedMeteringPointFactory.createPoint(x, y)).thenReturn(meteringPoint);

    hostApi.create(
        meteringPointIdentifier, x.doubleValue(), y.doubleValue(), null, mockCameraInfoId);

    verify(mockDisplayOrientedMeteringPointFactory).createPoint(x, y);
    assertEquals(testInstanceManager.getInstance(meteringPointIdentifier), meteringPoint);
  }

  @Test
  @Config(sdk = 29)
  @SuppressWarnings("deprecation")
  public void hostApiCreate_createsExpectedMeteringPointWithoutSizeSpecified_BelowAndroid30() {
    final MeteringPointHostApiImpl.MeteringPointProxy proxySpy =
        spy(new MeteringPointHostApiImpl.MeteringPointProxy());
    final MeteringPointHostApiImpl hostApi =
        new MeteringPointHostApiImpl(testInstanceManager, proxySpy);
    final Long meteringPointIdentifier = 78L;
    final Float x = 0.1f;
    final Float y = 0.8f;
    final Float surfaceWidth = 1f;
    final Float surfaceHeight = 1f;
    final DisplayOrientedMeteringPointFactory mockDisplayOrientedMeteringPointFactory =
        mock(DisplayOrientedMeteringPointFactory.class);
    final Activity mockActivity = mock(Activity.class);
    final WindowManager mockWindowManager = mock(WindowManager.class);
    final Display mockDisplay = mock(Display.class);
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final long mockCameraInfoId = 7L;

    hostApi.setActivity(mockActivity);
    testInstanceManager.addDartCreatedInstance(mockCameraInfo, mockCameraInfoId);

    when(mockActivity.getSystemService(Context.WINDOW_SERVICE)).thenReturn(mockWindowManager);
    when(mockWindowManager.getDefaultDisplay()).thenReturn(mockDisplay);
    when(proxySpy.getDisplayOrientedMeteringPointFactory(
            mockDisplay, mockCameraInfo, surfaceWidth, surfaceHeight))
        .thenReturn(mockDisplayOrientedMeteringPointFactory);
    when(mockDisplayOrientedMeteringPointFactory.createPoint(x, y)).thenReturn(meteringPoint);

    hostApi.create(
        meteringPointIdentifier, x.doubleValue(), y.doubleValue(), null, mockCameraInfoId);

    verify(mockDisplayOrientedMeteringPointFactory).createPoint(x, y);
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
