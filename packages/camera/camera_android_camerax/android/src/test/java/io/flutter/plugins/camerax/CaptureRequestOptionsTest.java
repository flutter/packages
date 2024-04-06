// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CaptureRequestKeySupportedType;
import java.util.HashMap;
import java.util.Map;
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
  public void create_buildsExpectedCaptureKeyRequestOptionsWhenOptionsNonNull() {
    final CaptureRequestOptionsHostApiImpl.CaptureRequestOptionsProxy proxySpy =
        spy(new CaptureRequestOptionsHostApiImpl.CaptureRequestOptionsProxy());
    final CaptureRequestOptionsHostApiImpl hostApi =
        new CaptureRequestOptionsHostApiImpl(testInstanceManager, proxySpy);
    final CaptureRequestOptions.Builder mockBuilder = mock(CaptureRequestOptions.Builder.class);
    final long instanceIdentifier = 44;

    // Map between CaptureRequestOptions indices and a test value for that option.
    final Map<Long, Object> options =
        new HashMap<Long, Object>() {
          {
            put(0L, false);
          }
        };

    when(proxySpy.getCaptureRequestOptionsBuilder()).thenReturn(mockBuilder);
    when(mockBuilder.build()).thenReturn(mockCaptureRequestOptions);

    hostApi.create(instanceIdentifier, options);
    for (CaptureRequestKeySupportedType supportedType : CaptureRequestKeySupportedType.values()) {
      final Long supportedTypeIndex = Long.valueOf(supportedType.index);
      final Object testValueForSupportedType = options.get(supportedTypeIndex);
      switch (supportedType) {
        case CONTROL_AE_LOCK:
          verify(mockBuilder)
              .setCaptureRequestOption(
                  eq(CaptureRequest.CONTROL_AE_LOCK), eq((Boolean) testValueForSupportedType));
          break;
        default:
          throw new IllegalArgumentException(
              "The capture request key is not currently supported by the plugin.");
      }
    }

    assertEquals(testInstanceManager.getInstance(instanceIdentifier), mockCaptureRequestOptions);
  }

  @Test
  public void create_buildsExpectedCaptureKeyRequestOptionsWhenAnOptionIsNull() {
    final CaptureRequestOptionsHostApiImpl.CaptureRequestOptionsProxy proxySpy =
        spy(new CaptureRequestOptionsHostApiImpl.CaptureRequestOptionsProxy());
    final CaptureRequestOptionsHostApiImpl hostApi =
        new CaptureRequestOptionsHostApiImpl(testInstanceManager, proxySpy);
    final CaptureRequestOptions.Builder mockBuilder = mock(CaptureRequestOptions.Builder.class);
    final long instanceIdentifier = 44;

    // Map between CaptureRequestOptions.CONTROL_AE_LOCK index and test value.
    final Map<Long, Object> options =
        new HashMap<Long, Object>() {
          {
            put(0L, null);
          }
        };

    when(proxySpy.getCaptureRequestOptionsBuilder()).thenReturn(mockBuilder);
    when(mockBuilder.build()).thenReturn(mockCaptureRequestOptions);

    hostApi.create(instanceIdentifier, options);

    verify(mockBuilder).clearCaptureRequestOption(CaptureRequest.CONTROL_AE_LOCK);

    assertEquals(testInstanceManager.getInstance(instanceIdentifier), mockCaptureRequestOptions);
  }
}
