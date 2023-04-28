// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PlaneProxyFlutterApi;
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
  public void flutterApiCreate_makesCallToCreateInstanceWithExpectedIdentifier() {
    final PlaneProxyFlutterApiImpl flutterApi =
        new PlaneProxyFlutterApiImpl(mockBinaryMessenger, instanceManager);
    final byte[] buffer = new byte[23];
    final long pixelStride = 20;
    final long rowStride = 2;

    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockPlaneProxy, buffer, pixelStride, rowStride, reply -> {});
    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockPlaneProxy));

    verify(mockFlutterApi)
        .create(eq(instanceIdentifier), eq(buffer), eq(pixelStride), eq(rowStride), any());
  }
}
