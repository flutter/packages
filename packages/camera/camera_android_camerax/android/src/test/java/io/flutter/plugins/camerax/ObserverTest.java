// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.Test;

public class ObserverTest {
  @Test
  public void onChanged_makesExpectedCallToDartCallback() {
    final ObserverProxyApi mockApi = mock(ObserverProxyApi.class);
    final TestProxyApiRegistrar registrar = new TestProxyApiRegistrar();
    when(mockApi.getPigeonRegistrar()).thenReturn(registrar);

    final ObserverProxyApi.ObserverImpl<String> instance =
        new ObserverProxyApi.ObserverImpl<>(mockApi);

    // Add the observer to the instance manager to simulate normal operation
    registrar.getInstanceManager().addDartCreatedInstance(instance, 0);

    final String value = "result";
    instance.onChanged(value);

    verify(mockApi).onChanged(eq(instance), eq(value), any());
  }

  @Test
  public void onChanged_doesNotCallDartCallbackWhenObserverNotInInstanceManager() {
    final ObserverProxyApi mockApi = mock(ObserverProxyApi.class);
    final TestProxyApiRegistrar registrar = new TestProxyApiRegistrar();
    when(mockApi.getPigeonRegistrar()).thenReturn(registrar);

    final ObserverProxyApi.ObserverImpl<String> instance =
        new ObserverProxyApi.ObserverImpl<>(mockApi);

    final String value = "result";
    instance.onChanged(value);

    // Verify that the Dart callback is NOT invoked for stale observers
    verify(mockApi, never()).onChanged(any(), any(), any());
  }
}
