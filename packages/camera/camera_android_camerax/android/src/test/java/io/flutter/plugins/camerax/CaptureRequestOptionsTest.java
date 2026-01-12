// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureRequest.Key;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import java.util.Map;
import org.junit.Test;

public class CaptureRequestOptionsTest {
  @SuppressWarnings("unchecked")
  @Test
  public void pigeon_defaultConstructor_buildsExpectedCaptureKeyRequestOptions() {
    final CaptureRequestOptions.Builder mockBuilder = mock(CaptureRequestOptions.Builder.class);
    final CaptureRequestOptions mockOptions = mock(CaptureRequestOptions.class);
    when(mockBuilder.build()).thenReturn(mockOptions);
    final PigeonApiCaptureRequestOptions api =
        new CaptureRequestOptionsProxyApi(mock(ProxyApiRegistrar.class)) {
          @Override
          CaptureRequestOptions.Builder createBuilder() {
            return mockBuilder;
          }
        };

    final Key<Integer> mockKey = mock(CaptureRequest.Key.class);
    final int value = -1;
    final Map<CaptureRequest.Key<?>, Object> options = Map.of(mockKey, value);
    final CaptureRequestOptions instance = api.pigeon_defaultConstructor(options);

    verify(mockBuilder).setCaptureRequestOption(mockKey, value);
    assertEquals(instance, mockOptions);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getCaptureRequestOption_returnsExpectedCorrespondingRequestOption() {
    final PigeonApiCaptureRequestOptions api =
        new TestProxyApiRegistrar().getPigeonApiCaptureRequestOptions();

    final CaptureRequestOptions instance = mock(CaptureRequestOptions.class);
    final Key<Integer> key = mock(CaptureRequest.Key.class);
    final int value = -1;
    when(instance.getCaptureRequestOption(key)).thenReturn(value);

    assertEquals(value, api.getCaptureRequestOption(instance, key));
  }
}
