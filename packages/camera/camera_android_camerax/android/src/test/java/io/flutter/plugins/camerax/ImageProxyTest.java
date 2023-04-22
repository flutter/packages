// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageProxyFlutterApi;
import java.util.List;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ImageProxyTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public ImageProxy mockImageProxy;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public ImageProxyFlutterApi mockFlutterApi;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void getPlanes_returnsExpectedPlanesFromExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 0;
    final long mockPlaneProxyIdentifier = 45;
    final ImageProxy.PlaneProxy mockPlaneProxy = mock(ImageProxy.PlaneProxy.class);
    final ImageProxy.PlaneProxy[] returnValue = new ImageProxy.PlaneProxy[] {mockPlaneProxy};

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);
    instanceManager.addDartCreatedInstance(mockPlaneProxy, mockPlaneProxyIdentifier);

    when(mockImageProxy.getPlanes()).thenReturn(returnValue);

    final List<Long> result = hostApi.getPlanes(instanceIdentifier);

    verify(mockImageProxy).getPlanes();
    assertEquals(result.size(), 1);
    assertEquals(result.get(0), Long.valueOf(mockPlaneProxyIdentifier));
  }

  @Test
  public void getFormat_returnsExpectedFormatFromExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 0;
    final int returnValue = 0;

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    when(mockImageProxy.getFormat()).thenReturn(returnValue);

    final Long result = hostApi.getFormat(instanceIdentifier);

    verify(mockImageProxy).getFormat();

    assertEquals(result, Long.valueOf(returnValue));
  }

  @Test
  public void getHeight_returnsExpectedHeightFromExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 0;
    final int returnValue = 0;

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    when(mockImageProxy.getHeight()).thenReturn(returnValue);

    final Long result = hostApi.getHeight(instanceIdentifier);

    verify(mockImageProxy).getHeight();

    assertEquals(result, Long.valueOf(returnValue));
  }

  @Test
  public void getWidth_returnsExpectedHeightFromExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 0;
    final int returnValue = 0;

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    when(mockImageProxy.getWidth()).thenReturn(returnValue);

    final Long result = hostApi.getWidth(instanceIdentifier);

    verify(mockImageProxy).getWidth();

    assertEquals(result, Long.valueOf(returnValue));
  }

  @Test
  public void close_makesCallToCloseExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 0;

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    hostApi.close(instanceIdentifier);

    verify(mockImageProxy).close();
  }

  @Test
  public void flutterApiCreate_makesCallToDartCreate() {
    final ImageProxyFlutterApiImpl flutterApi =
        new ImageProxyFlutterApiImpl(mockBinaryMessenger, instanceManager);

    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockImageProxy, reply -> {});
    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockImageProxy));

    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }
}
