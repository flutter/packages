
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
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CaptureRequestOptionsFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CaptureRequestOptionsTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CaptureRequestOptions mockCaptureRequestOptions;

  @Mock public BinaryMessenger mockBinaryMessenger;

  @Mock public CaptureRequestOptionsFlutterApi mockFlutterApi;

  @Mock public CaptureRequestOptionsHostApiImpl.CaptureRequestOptionsProxy mockProxy;

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
  public void hostApiCreate() {

    final List options = new ArrayList<Object>();

    when(mockProxy.create(options)).thenReturn(mockCaptureRequestOptions);

    final CaptureRequestOptionsHostApiImpl hostApi =
        new CaptureRequestOptionsHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier, options);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockCaptureRequestOptions);
  }

  @Test
  public void flutterApiCreate() {
    final CaptureRequestOptionsFlutterApiImpl flutterApi =
        new CaptureRequestOptionsFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final List options = new ArrayList<Object>();

    flutterApi.create(mockCaptureRequestOptions, options, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockCaptureRequestOptions));
    verify(mockFlutterApi).create(eq(instanceIdentifier), eq(options), any());
  }
}
