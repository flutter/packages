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
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.annotation.Config;

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

  @Config(sdk = 21)
  @Test
  public void getPlanes_returnsExpectedPlanesFromExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    final PlaneProxyFlutterApiImpl mockPlaneProxyFlutterApiImpl =
        mock(PlaneProxyFlutterApiImpl.class);
    final long instanceIdentifier = 24;
    final long mockPlaneProxyIdentifier = 45;
    final ImageProxy.PlaneProxy mockPlaneProxy = mock(ImageProxy.PlaneProxy.class);
    final ImageProxy.PlaneProxy[] returnValue = new ImageProxy.PlaneProxy[] {mockPlaneProxy};
    final ByteBuffer mockByteBuffer = mock(ByteBuffer.class);
    final int bufferRemaining = 23;
    final byte[] buffer = new byte[bufferRemaining];
    final int pixelStride = 2;
    final int rowStride = 65;

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    hostApi.cameraXProxy = mockCameraXProxy;
    hostApi.planeProxyFlutterApiImpl = mockPlaneProxyFlutterApiImpl;

    when(mockImageProxy.getPlanes()).thenReturn(returnValue);
    when(mockPlaneProxy.getBuffer()).thenReturn(mockByteBuffer);
    when(mockByteBuffer.remaining()).thenReturn(bufferRemaining);
    when(mockCameraXProxy.getBytesFromBuffer(bufferRemaining)).thenReturn(buffer);
    when(mockPlaneProxy.getPixelStride()).thenReturn(pixelStride);
    when(mockPlaneProxy.getRowStride()).thenReturn(rowStride);

    final List<Long> result = hostApi.getPlanes(instanceIdentifier);

    verify(mockImageProxy).getPlanes();
    verify(mockPlaneProxyFlutterApiImpl)
        .create(
            eq(mockPlaneProxy),
            eq(buffer),
            eq(Long.valueOf(pixelStride)),
            eq(Long.valueOf(rowStride)),
            any());
    assertEquals(result.size(), 1);
  }

  @Test
  public void close_makesCallToCloseExpectedImageProxyInstance() {
    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 9;

    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    hostApi.close(instanceIdentifier);

    verify(mockImageProxy).close();
  }

  @Test
  public void flutterApiCreate_makesCallToDartCreate() {
    final ImageProxyFlutterApiImpl flutterApi =
        new ImageProxyFlutterApiImpl(mockBinaryMessenger, instanceManager);
    final long format = 3;
    final long height = 2;
    final long width = 1;

    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockImageProxy, format, height, width, reply -> {});
    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockImageProxy));

    verify(mockFlutterApi).create(eq(instanceIdentifier), eq(format), eq(height), eq(width), any());
  }
}
