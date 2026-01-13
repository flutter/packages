// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.annotation.Nullable;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper;
import org.junit.Test;

public class LiveDataTest {
  @Test
  public void type_returnsExpectedType() {
    final PigeonApiLiveData api = new TestProxyApiRegistrar().getPigeonApiLiveData();

    final LiveDataSupportedType value =
        io.flutter.plugins.camerax.LiveDataSupportedType.CAMERA_STATE;
    final LiveDataWrapper instance = new LiveDataWrapper(mock(LiveData.class), value);

    assertEquals(value, api.type(instance));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void observe_callsObserveOnInstanceWithLifeCycleOwner() {
    final PigeonApiLiveData api =
        new TestProxyApiRegistrar() {
          @Nullable
          @Override
          public LifecycleOwner getLifecycleOwner() {
            return mock(LifecycleOwner.class);
          }
        }.getPigeonApiLiveData();

    final LiveData<String> liveData = mock(LiveData.class);
    final LiveDataWrapper instance =
        new LiveDataWrapper(liveData, LiveDataSupportedType.CAMERA_STATE);

    final Observer<String> observer = mock(Observer.class);
    api.observe(instance, observer);

    verify(liveData).observe(any(LifecycleOwner.class), eq(observer));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void removeObservers_callsRemoveObserversOnInstance() {
    final PigeonApiLiveData api =
        new TestProxyApiRegistrar() {
          @Nullable
          @Override
          public LifecycleOwner getLifecycleOwner() {
            return mock(LifecycleOwner.class);
          }
        }.getPigeonApiLiveData();

    final LiveData<String> liveData = mock(LiveData.class);
    final LiveDataWrapper instance =
        new LiveDataWrapper(liveData, LiveDataSupportedType.CAMERA_STATE);

    api.removeObservers(instance);

    verify(liveData).removeObservers(any(LifecycleOwner.class));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void getValue_returnsExpectedResult() {
    final PigeonApiLiveData api = new TestProxyApiRegistrar().getPigeonApiLiveData();

    final LiveData<String> liveData = mock(LiveData.class);
    final String result = "result";
    when(liveData.getValue()).thenReturn(result);
    final LiveDataWrapper instance =
        new LiveDataWrapper(liveData, LiveDataSupportedType.CAMERA_STATE);

    assertEquals(result, api.getValue(instance));
  }
}
