// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.UseCase;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ProcessCameraProviderHostApi;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class ProcessCameraProviderHostApiImpl implements ProcessCameraProviderHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @Nullable private Context context;
  @Nullable private LifecycleOwner lifecycleOwner;

  public ProcessCameraProviderHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
  }

  public void setLifecycleOwner(@Nullable LifecycleOwner lifecycleOwner) {
    this.lifecycleOwner = lifecycleOwner;
  }

  /**
   * Sets the context that the {@code ProcessCameraProvider} will use to attach the lifecycle of the
   * camera to.
   *
   * <p>If using the camera plugin in an add-to-app context, ensure that a new instance of the
   * {@code ProcessCameraProvider} is fetched via {@code #getInstance} anytime the context changes.
   */
  public void setContext(@NonNull Context context) {
    this.context = context;
  }

  /**
   * Returns the instance of the {@code ProcessCameraProvider} to manage the lifecycle of the camera
   * for the current {@code Context}.
   */
  @Override
  public void getInstance(@NonNull GeneratedCameraXLibrary.Result<Long> result) {
    if (context == null) {
      throw new IllegalStateException("Context must be set to get ProcessCameraProvider instance.");
    }

    ListenableFuture<ProcessCameraProvider> processCameraProviderFuture =
        ProcessCameraProvider.getInstance(context);

    processCameraProviderFuture.addListener(
        () -> {
          try {
            // Camera provider is now guaranteed to be available.
            ProcessCameraProvider processCameraProvider = processCameraProviderFuture.get();

            final ProcessCameraProviderFlutterApiImpl flutterApi =
                new ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
            if (!instanceManager.containsInstance(processCameraProvider)) {
              flutterApi.create(processCameraProvider, reply -> {});
            }
            result.success(instanceManager.getIdentifierForStrongReference(processCameraProvider));
          } catch (Exception e) {
            result.error(e);
          }
        },
        ContextCompat.getMainExecutor(context));
  }

  /** Returns cameras available to the {@code ProcessCameraProvider}. */
  @NonNull
  @Override
  public List<Long> getAvailableCameraInfos(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));

    List<CameraInfo> availableCameras = processCameraProvider.getAvailableCameraInfos();
    List<Long> availableCamerasIds = new ArrayList<>();
    final CameraInfoFlutterApiImpl cameraInfoFlutterApi =
        new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);

    for (CameraInfo cameraInfo : availableCameras) {
      if (!instanceManager.containsInstance(cameraInfo)) {
        cameraInfoFlutterApi.create(cameraInfo, result -> {});
      }
      availableCamerasIds.add(instanceManager.getIdentifierForStrongReference(cameraInfo));
    }
    return availableCamerasIds;
  }

  /**
   * Binds specified {@code UseCase}s to the lifecycle of the {@code LifecycleOwner} that
   * corresponds to this instance and returns the instance of the {@code Camera} whose lifecycle
   * that {@code LifecycleOwner} reflects.
   */
  @Override
  public @NonNull Long bindToLifecycle(
      @NonNull Long identifier,
      @NonNull Long cameraSelectorIdentifier,
      @NonNull List<Long> useCaseIds) {
    if (lifecycleOwner == null) {
      throw new IllegalStateException(
          "LifecycleOwner must be set to get ProcessCameraProvider instance.");
    }

    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    CameraSelector cameraSelector =
        (CameraSelector)
            Objects.requireNonNull(instanceManager.getInstance(cameraSelectorIdentifier));
    UseCase[] useCases = new UseCase[useCaseIds.size()];
    for (int i = 0; i < useCaseIds.size(); i++) {
      useCases[i] =
          (UseCase)
              Objects.requireNonNull(
                  instanceManager.getInstance(((Number) useCaseIds.get(i)).longValue()));
    }

    Camera camera = processCameraProvider.bindToLifecycle(lifecycleOwner, cameraSelector, useCases);

    final CameraFlutterApiImpl cameraFlutterApi =
        new CameraFlutterApiImpl(binaryMessenger, instanceManager);
    if (!instanceManager.containsInstance(camera)) {
      cameraFlutterApi.create(camera, result -> {});
    }

    return Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(camera));
  }

  @Override
  public @NonNull Boolean isBound(@NonNull Long identifier, @NonNull Long useCaseIdentifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    UseCase useCase =
        (UseCase) Objects.requireNonNull(instanceManager.getInstance(useCaseIdentifier));
    return processCameraProvider.isBound(useCase);
  }

  @Override
  public void unbind(@NonNull Long identifier, @NonNull List<Long> useCaseIds) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    UseCase[] useCases = new UseCase[useCaseIds.size()];
    for (int i = 0; i < useCaseIds.size(); i++) {
      useCases[i] =
          (UseCase)
              Objects.requireNonNull(
                  instanceManager.getInstance(((Number) useCaseIds.get(i)).longValue()));
    }
    processCameraProvider.unbind(useCases);
  }

  @Override
  public void unbindAll(@NonNull Long identifier) {
    ProcessCameraProvider processCameraProvider =
        (ProcessCameraProvider) Objects.requireNonNull(instanceManager.getInstance(identifier));
    processCameraProvider.unbindAll();
  }
}
