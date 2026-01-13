// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;

/**
 * ProxyApi implementation for {@link LiveData}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
public class LiveDataProxyApi extends PigeonApiLiveData {
  public static class LiveDataWrapper {
    private final LiveData<?> liveData;
    private final LiveDataSupportedType genericType;

    LiveDataWrapper(@NonNull LiveData<?> liveData, @NonNull LiveDataSupportedType genericType) {
      this.liveData = liveData;
      this.genericType = genericType;
    }

    @NonNull
    public LiveData<?> getLiveData() {
      return liveData;
    }

    @NonNull
    public LiveDataSupportedType getGenericType() {
      return genericType;
    }
  }

  LiveDataProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public LiveDataSupportedType type(@NonNull LiveDataWrapper pigeonInstance) {
    return pigeonInstance.getGenericType();
  }

  @SuppressWarnings("unchecked")
  @Override
  public void observe(@NonNull LiveDataWrapper pigeonInstance, @NonNull Observer<?> observer) {
    final LifecycleOwner lifecycleOwner = getPigeonRegistrar().getLifecycleOwner();
    if (lifecycleOwner == null) {
      throw new IllegalStateException("LifecycleOwner must be set to observe a LiveData instance.");
    }

    final LiveData<Object> castedLiveData = (LiveData<Object>) pigeonInstance.getLiveData();
    castedLiveData.observe(lifecycleOwner, (Observer<Object>) observer);
  }

  @Override
  public void removeObservers(@NonNull LiveDataWrapper pigeonInstance) {
    if (getPigeonRegistrar().getLifecycleOwner() == null) {
      throw new IllegalStateException("LifecycleOwner must be set to remove LiveData observers.");
    }

    pigeonInstance.getLiveData().removeObservers(getPigeonRegistrar().getLifecycleOwner());
  }

  @Nullable
  @Override
  public Object getValue(@NonNull LiveDataWrapper pigeonInstance) {
    return pigeonInstance.getLiveData().getValue();
  }
}
