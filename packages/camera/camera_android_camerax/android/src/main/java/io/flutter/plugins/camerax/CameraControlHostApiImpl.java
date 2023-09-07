// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraControl;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraControlHostApi;

/**
 * Host API implementation for {@link CameraControl}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class CameraControlHostApiImpl implements CameraControlHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final CameraControlProxy proxy;
  private final SystemServicesFlutterApiImpl systemServicesFlutterApi;

  @VisibleForTesting public @NonNull CameraXProxy cameraXProxy = new CameraXProxy();

  /** Proxy for constructors and static method of {@link CameraControl}. */
  @VisibleForTesting
  public static class CameraControlProxy {

    /** Enables or disables the torch of the specified {@link CameraControl} instance. */
    @NonNull
    public void enableTorch(
        @NonNull CameraControl cameraControl,
        @NonNull Boolean torch,
        @NonNull Result<Void> result) {
      ListenableFuture<Void> enableTorchFuture = cameraControl.enableTorch(torch);

      Futures.addCallback(
          enableTorchFuture,
          new FutureCallback<Void>() {
            public void onSuccess() {
              result.succes();
            }

            public void onFailure(Throwable t) {
              systemServicesFlutterApi.sendCameraError(
                  "Unable to change the torch state: " + t.getMessage(), reply -> {});
            }
          },
          ContextCompat.getMainExecutor(context));
    }
  }

  /**
   * Constructs an {@link CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public CameraControlHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(instanceManager, new CameraControlProxy());
  }

  /**
   * Constructs an {@link CameraControlHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link CameraControl}
   */
  @VisibleForTesting
  CameraControlHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull CameraControlProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
    systemServicesFlutterApi = cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
  }

  @Override
  public void enableTorch(
      @NonNull Long identifier, @NonNull Boolean torch, @NonNull Result<Void> result) {
    proxy.enableTorch(
        Objects.requireNonNull(instanceManager.getInstance(identifier)), torch, result);
  }
}
