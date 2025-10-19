// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import androidx.lifecycle.Lifecycle.Event;
import androidx.lifecycle.LifecycleRegistry;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ProxyLifecycleProviderTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock Activity activity;
  @Mock Application application;
  @Mock LifecycleRegistry mockLifecycleRegistry;

  private final int testHashCode = 27;

  @Before
  public void setUp() {
    when(activity.getApplication()).thenReturn(application);
  }

  @Test
  public void onActivityCreated_handlesOnCreateEvent() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    Bundle mockBundle = mock(Bundle.class);

    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivityCreated(activity, mockBundle);

    verify(mockLifecycleRegistry).handleLifecycleEvent(Event.ON_CREATE);
  }

  @Test
  public void onActivityStarted_handlesOnActivityStartedEvent() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivityStarted(activity);

    verify(mockLifecycleRegistry).handleLifecycleEvent(Event.ON_START);
  }

  @Test
  public void onActivityResumed_handlesOnActivityResumedEvent() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivityResumed(activity);

    verify(mockLifecycleRegistry).handleLifecycleEvent(Event.ON_RESUME);
  }

  @Test
  public void onActivityPaused_handlesOnActivityPausedEvent() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivityPaused(activity);

    verify(mockLifecycleRegistry).handleLifecycleEvent(Event.ON_PAUSE);
  }

  @Test
  public void onActivityStopped_handlesOnActivityStoppedEvent() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivityStopped(activity);

    verify(mockLifecycleRegistry).handleLifecycleEvent(Event.ON_STOP);
  }

  @Test
  public void onActivityDestroyed_handlesOnActivityDestroyed() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivityDestroyed(activity);

    verify(mockLifecycleRegistry).handleLifecycleEvent(Event.ON_DESTROY);
  }

  @Test
  public void onActivitySaveInstanceState_doesNotHandleLifecycleEvvent() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
    Bundle mockBundle = mock(Bundle.class);

    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    proxyLifecycleProvider.onActivitySaveInstanceState(activity, mockBundle);

    verifyNoInteractions(mockLifecycleRegistry);
  }

  @Test
  public void getLifecycle_returnsExpectedLifecycle() {
    ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);

    proxyLifecycleProvider.lifecycle = mockLifecycleRegistry;

    assertEquals(proxyLifecycleProvider.getLifecycle(), mockLifecycleRegistry);
  }
}
