
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ImageProxyPlaneProxyTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ImageProxyPlaneProxy mockImageProxyPlaneProxy;

  @Mock public BinaryMessenger mockBinaryMessenger;

  // TODO(bparrishMines): Fix name of generated pigeon file
  @Mock public GeneratedPigeonFilename.ImageProxyPlaneProxyFlutterApi mockFlutterApi;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void getRowStride() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxyPlaneProxy, instanceIdentifier);

    final dynamic returnValue = mock(dynamic.class);

    when(mockImageProxyPlaneProxy.getRowStride(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyPlaneProxyHostApiImpl hostApi =
        new ImageProxyPlaneProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getRowStride(instanceIdentifier);

    verify(mockImageProxyPlaneProxy).getRowStride();

    assertEquals(result, instanceManager.getIdentifierForStrongReference(returnValue));
  }

  @Test
  public void getPixelStride() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxyPlaneProxy, instanceIdentifier);

    final Long returnValue = 0;

    when(mockImageProxyPlaneProxy.getPixelStride(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyPlaneProxyHostApiImpl hostApi =
        new ImageProxyPlaneProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getPixelStride(instanceIdentifier);

    verify(mockImageProxyPlaneProxy).getPixelStride();

    assertEquals(result, returnValue);
  }

  @Test
  public void getRowStride() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxyPlaneProxy, instanceIdentifier);

    final Long returnValue = 0;

    when(mockImageProxyPlaneProxy.getRowStride(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyPlaneProxyHostApiImpl hostApi =
        new ImageProxyPlaneProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getRowStride(instanceIdentifier);

    verify(mockImageProxyPlaneProxy).getRowStride();

    assertEquals(result, returnValue);
  }

  @Test
  public void flutterApiCreate() {
    final ImageProxyPlaneProxyFlutterApiImpl flutterApi =
        new ImageProxyPlaneProxyFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockImageProxyPlaneProxy, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockImageProxyPlaneProxy));
    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }
}
