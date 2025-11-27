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
                  // Check if this observer instance is still in the instance manager.
                  // During hot restart, old observers may remain attached to LiveData but
                  // are no longer tracked in the instance manager.
                  if (!api.getPigeonRegistrar()
                      .getInstanceManager()
                      .containsInstance(ObserverImpl.this)) {
                    android.util.Log.w(
                        "ObserverProxyApi",
                        "Ignoring onChanged callback for Observer not in InstanceManager (likely from previous hot restart): "
                            + ObserverImpl.this);
                    return;
                  }

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
