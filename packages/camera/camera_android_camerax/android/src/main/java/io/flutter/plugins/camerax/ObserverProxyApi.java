// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.lifecycle.Observer;
import java.util.Objects;

/**
 * ProxyApi implementation for {@link Observer}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class ObserverProxyApi extends PigeonApiObserver {
  /** Implementation of {@link Observer} that passes arguments of callback methods to Dart. */
  static class ObserverImpl<T> implements Observer<T> {
    final ObserverProxyApi api;

    ObserverImpl(@NonNull ObserverProxyApi api) {
      this.api = api;
    }

    @Override
    public void onChanged(T t) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              new ProxyApiRegistrar.FlutterMethodRunnable() {
                @Override
                public void run() {
                  api.onChanged(
                      ObserverImpl.this,
                      t,
                      ResultCompat.asCompatCallback(
                          result -> {
                            if (result.isFailure()) {
                              onFailure(
                                  "Observer.onChanged",
                                  Objects.requireNonNull(result.exceptionOrNull()));
                            }
                            return null;
                          }));
                }
              });
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
