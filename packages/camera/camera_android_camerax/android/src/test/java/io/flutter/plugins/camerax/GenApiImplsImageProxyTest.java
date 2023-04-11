
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
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

public class ImageProxyTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ImageProxy mockImageProxy;

  @Mock public BinaryMessenger mockBinaryMessenger;

  // TODO(bparrishMines): Fix name of generated pigeon file
  @Mock public GeneratedPigeonFilename.ImageProxyFlutterApi mockFlutterApi;

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
  public void getPlanes() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    final List returnValue = new ArrayList<Object>();

    when(mockImageProxy.getPlanes(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final List result = hostApi.getPlanes(instanceIdentifier);

    verify(mockImageProxy).getPlanes();

    assertEquals(result, returnValue);
  }

  @Test
  public void getFormat() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    final Long returnValue = 0;

    when(mockImageProxy.getFormat(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getFormat(instanceIdentifier);

    verify(mockImageProxy).getFormat();

    assertEquals(result, returnValue);
  }

  @Test
  public void getHeight() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    final Long returnValue = 0;

    when(mockImageProxy.getHeight(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getHeight(instanceIdentifier);

    verify(mockImageProxy).getHeight();

    assertEquals(result, returnValue);
  }

  @Test
  public void getWidth() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    final Long returnValue = 0;

    when(mockImageProxy.getWidth(instanceIdentifier)).thenReturn(returnValue);

    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getWidth(instanceIdentifier);

    verify(mockImageProxy).getWidth();

    assertEquals(result, returnValue);
  }

  @Test
  public void close() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockImageProxy, instanceIdentifier);

    final ImageProxyHostApiImpl hostApi =
        new ImageProxyHostApiImpl(mockBinaryMessenger, instanceManager);

    hostApi.close(instanceIdentifier);

    verify(mockImageProxy).close();
  }

  @Test
  public void flutterApiCreate() {
    final ImageProxyFlutterApiImpl flutterApi =
        new ImageProxyFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockImageProxy, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockImageProxy));
    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }
}
