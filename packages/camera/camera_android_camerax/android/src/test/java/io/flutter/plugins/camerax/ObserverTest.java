// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.Test;

public class ObserverTest {
  @Test
  public void onChanged_makesExpectedCallToDartCallback() {
    final ObserverProxyApi mockApi = mock(ObserverProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final ObserverProxyApi.ObserverImpl<String> instance =
        new ObserverProxyApi.ObserverImpl<>(mockApi);
    final String value = "result";
    instance.onChanged(value);

    verify(mockApi).onChanged(eq(instance), eq(value), any());
  }
}
