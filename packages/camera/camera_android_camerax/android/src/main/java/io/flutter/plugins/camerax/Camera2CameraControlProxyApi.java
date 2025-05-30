// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.CameraControl;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * ProxyApi implementation for {@link Camera2CameraControl}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
@OptIn(markerClass = ExperimentalCamera2Interop.class)
class Camera2CameraControlProxyApi extends PigeonApiCamera2CameraControl {
  Camera2CameraControlProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public Camera2CameraControl from(@NonNull CameraControl cameraControl) {
    return Camera2CameraControl.from(cameraControl);
  }

  @Override
  public void addCaptureRequestOptions(
      @NonNull Camera2CameraControl pigeonInstance,
      @NonNull CaptureRequestOptions bundle,
      @NonNull Function1<? super Result<Unit>, Unit> callback) {
    final ListenableFuture<Void> addCaptureRequestOptionsFuture =
        pigeonInstance.addCaptureRequestOptions(bundle);

    Futures.addCallback(
        addCaptureRequestOptionsFuture,
        new FutureCallback<>() {
          @Override
          public void onSuccess(Void voidResult) {
            ResultCompat.success(null, callback);
          }

          @Override
          public void onFailure(@NonNull Throwable t) {
            ResultCompat.failure(t, callback);
          }
        },
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()));
  }
}
