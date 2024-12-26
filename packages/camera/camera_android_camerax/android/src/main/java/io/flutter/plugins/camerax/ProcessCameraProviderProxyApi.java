// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.core.UseCase;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.Camera;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.google.common.util.concurrent.ListenableFuture;

import java.util.List;

import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * ProxyApi implementation for {@link ProcessCameraProvider}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ProcessCameraProviderProxyApi extends PigeonApiProcessCameraProvider {
  ProcessCameraProviderProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @Override
  public void getInstance(@NonNull Function1<? super Result<ProcessCameraProvider>, Unit> callback) {
    final ListenableFuture<ProcessCameraProvider> processCameraProviderFuture =
        ProcessCameraProvider.getInstance(getPigeonRegistrar().getContext());

    processCameraProviderFuture.addListener(
        () -> {
          try {
            // Camera provider is now guaranteed to be available.
            ResultCompat.success(processCameraProviderFuture.get(), callback);
          } catch (Exception e) {
            ResultCompat.failure(e, callback);
          }
        },
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()));
  }

  @NonNull
  @Override
  public List<CameraInfo> getAvailableCameraInfos(ProcessCameraProvider pigeon_instance) {
    return pigeon_instance.getAvailableCameraInfos();
  }

  @NonNull
  @Override
  public Camera bindToLifecycle(@NonNull ProcessCameraProvider pigeon_instance, @NonNull CameraSelector cameraSelector, @NonNull List<? extends UseCase> useCases) {
    final LifecycleOwner lifecycleOwner = getPigeonRegistrar().getLifecycleOwner();
    if (lifecycleOwner != null) {
      return pigeon_instance.bindToLifecycle(lifecycleOwner, cameraSelector, useCases.toArray(new UseCase[0]));
    }

    throw new IllegalStateException(
        "LifecycleOwner must be set to get ProcessCameraProvider instance.");
  }

  @Override
  public boolean isBound(ProcessCameraProvider pigeon_instance, @NonNull UseCase useCase) {
    return pigeon_instance.isBound(useCase);
  }

  @Override
  public void unbind(ProcessCameraProvider pigeon_instance, @NonNull List<? extends UseCase> useCases) {
    pigeon_instance.unbind(useCases.toArray(new UseCase[0]));
  }

  @Override
  public void unbindAll(ProcessCameraProvider pigeon_instance) {
    pigeon_instance.unbindAll();
  }
}
