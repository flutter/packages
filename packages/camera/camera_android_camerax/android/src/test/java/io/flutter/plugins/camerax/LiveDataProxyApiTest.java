// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import io.flutter.plugins.camerax.LiveDataProxyApi.LiveDataWrapper
import androidx.lifecycle.Observer<*>
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class LiveDataProxyApiTest {
  @Test
  public void type() {
    final PigeonApiLiveData api = new TestProxyApiRegistrar().getPigeonApiLiveData();

    final LiveData instance = mock(LiveData.class);
    final LiveDataSupportedType value = io.flutter.plugins.camerax.LiveDataSupportedType.CAMERA_STATE;
    when(instance.getType()).thenReturn(value);

    assertEquals(value, api.type(instance));
  }

  @Test
  public void observe() {
    final PigeonApiLiveData api = new TestProxyApiRegistrar().getPigeonApiLiveData();

    final LiveData instance = mock(LiveData.class);
    final androidx.lifecycle.Observer<*> observer = mock(Observer.class);
    api.observe(instance, observer);

    verify(instance).observe(observer);
  }

  @Test
  public void removeObservers() {
    final PigeonApiLiveData api = new TestProxyApiRegistrar().getPigeonApiLiveData();

    final LiveData instance = mock(LiveData.class);
    api.removeObservers(instance );

    verify(instance).removeObservers();
  }

  @Test
  public void getValue() {
    final PigeonApiLiveData api = new TestProxyApiRegistrar().getPigeonApiLiveData();

    final LiveData instance = mock(LiveData.class);
    final Any value = -1;
    when(instance.getValue()).thenReturn(value);

    assertEquals(value, api.getValue(instance ));
  }

}
