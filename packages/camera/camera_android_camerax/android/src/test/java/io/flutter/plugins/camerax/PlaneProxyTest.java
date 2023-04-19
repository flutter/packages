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
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PlaneProxyFlutterApi;
import io.flutter.plugin.common.BinaryMessenger;

import java.nio.ByteBuffer;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class PlaneProxyTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public ImageProxy.PlaneProxy mockPlaneProxy;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public PlaneProxyFlutterApi mockFlutterApi;

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
  public void getBuffer_returnsExpectedBytes() {
    final PlaneProxyHostApiImpl hostApi =
        new PlaneProxyHostApiImpl(instanceManager);
    final long instanceIdentifier = 0;
    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    final ByteBuffer mockByteBuffer = mock(ByteBuffer.class);
    final int bufferRemaining = 23;
    final byte[] returnValue = new byte[bufferRemaining];;

    instanceManager.addDartCreatedInstance(mockPlaneProxy, instanceIdentifier);

    hostApi.cameraXProxy = mockCameraXProxy;

    when(mockPlaneProxy.getBuffer()).thenReturn(mockByteBuffer);
    when(mockByteBuffer.remaining()).thenReturn(bufferRemaining);
    when(mockCameraXProxy.getBytesFromBuffer(bufferRemaining)).thenReturn(returnValue);

    final byte[] result = hostApi.getBuffer(instanceIdentifier);

    verify(mockPlaneProxy).getBuffer();
    assertEquals(result, returnValue);
  }

  @Test
  public void getPixelStride_makesExpectedCallAndReturnsExpectedValue() {
    final PlaneProxyHostApiImpl hostApi =
        new PlaneProxyHostApiImpl(instanceManager);
    final long instanceIdentifier = 0;
    final int returnValue = 0;

    instanceManager.addDartCreatedInstance(mockPlaneProxy, instanceIdentifier);

    when(mockPlaneProxy.getPixelStride()).thenReturn(returnValue);

    final Long result = hostApi.getPixelStride(instanceIdentifier);

    verify(mockPlaneProxy).getPixelStride();
    assertEquals(result, Long.valueOf(returnValue));
  }


  @Test
  public void getRowStride_makesExpectedCallAndReturnsExpectedValue() {
    final PlaneProxyHostApiImpl hostApi =
        new PlaneProxyHostApiImpl(instanceManager);
    final long instanceIdentifier = 0;
    final int returnValue = 25;

    instanceManager.addDartCreatedInstance(mockPlaneProxy, instanceIdentifier);

    when(mockPlaneProxy.getRowStride()).thenReturn(returnValue);

    final Long result = hostApi.getRowStride(instanceIdentifier);

    verify(mockPlaneProxy).getRowStride();
    assertEquals(result, Long.valueOf(returnValue));
  }


  @Test
  public void flutterApiCreate_makesCallToCreateInstanceWithExpectedIdentifier() {
    final PlaneProxyFlutterApiImpl flutterApi =
        new PlaneProxyFlutterApiImpl(mockBinaryMessenger, instanceManager);

    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockPlaneProxy, reply -> {});
    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockPlaneProxy));
    
    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }
}
