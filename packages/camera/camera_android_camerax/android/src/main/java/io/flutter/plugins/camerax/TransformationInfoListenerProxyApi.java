// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.SurfaceRequest.TransformationInfo;
import androidx.camera.core.SurfaceRequest.TransformationInfoListener;
import java.util.Objects;

/**
 * ProxyApi implementation for {@link TransformationInfoListener}.
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class TransformationInfoListenerProxyApi extends PigeonApiTransformationInfoListener {
  TransformationInfoListenerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  /**
   * Implementation of {@link TransformationInfoListener} that passes arguments of callback methods
   * to Dart.
   */
  static class TransformationInfoListenerImpl implements TransformationInfoListener {
    final TransformationInfoListenerProxyApi api;

    TransformationInfoListenerImpl(@NonNull TransformationInfoListenerProxyApi api) {
      this.api = api;
    }

    @Override
    public void onTransformationInfoUpdate(@NonNull TransformationInfo transformationInfo) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              new ProxyApiRegistrar.FlutterMethodRunnable() {
                @Override
                public void run() {
                  api.onTransformationInfoUpdate(
                      TransformationInfoListenerImpl.this,
                      transformationInfo,
                      ResultCompat.asCompatCallback(
                          result -> {
                            if (result.isFailure()) {
                              onFailure(
                                  "TransformationInfoListener.onTransformationInfoUpdate",
                                  Objects.requireNonNull(result.exceptionOrNull()));
                            }
                            return null;
                          }));
                }
              });
    }
  }

  @NonNull
  @Override
  public TransformationInfoListener pigeon_defaultConstructor() {
    return new TransformationInfoListenerImpl(this);
  }
}
