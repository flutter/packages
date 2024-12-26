// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.Observer;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link Observer}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ObserverProxyApi extends PigeonApiObserver {
  /** Implementation of {@link Observer} that passes arguments of callback methods to Dart. */
  static class ObserverImpl<T> implements Observer<T> {
    private final ObserverProxyApi api;

    ObserverImpl(@NonNull ObserverProxyApi api) {
      this.api = api;
    }

    @Override
    public void onChanged(T t) {
      api.getPigeonRegistrar().runOnMainThread(() -> api.onChanged(this, t, reply -> null));
    }
  }

  ObserverProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public Observer<?> pigeon_defaultConstructor() {
    return new ObserverImpl<>(this);
  }
}