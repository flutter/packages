// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.CameraControl;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Camera2CameraControlHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link Camera2CameraControl}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class Camera2CameraControlHostApiImpl implements Camera2CameraControlHostApi {
  private final InstanceManager instanceManager;
  private final Camera2CameraControlProxy proxy;

  /** Proxy for constructor and methods of {@link Camera2CameraControl}. */
  @VisibleForTesting
  public static class Camera2CameraControlProxy {
    Context context;

    /**
     * Creates an instance of {@link Camera2CameraControl} derived from specified {@link
     * CameraControl} instance.
     */
    @OptIn(markerClass = androidx.camera.camera2.interop.ExperimentalCamera2Interop.class)
    public @NonNull Camera2CameraControl create(@NonNull CameraControl cameraControl) {
      return Camera2CameraControl.from(cameraControl);
    }

    /**
     * Adds a {@link CaptureRequestOptions} to update the capture session with the options it
     * contains.
     */
    @OptIn(markerClass = androidx.camera.camera2.interop.ExperimentalCamera2Interop.class)
    public void addCaptureRequestOptions(
        @NonNull Camera2CameraControl camera2CameraControl,
        @NonNull CaptureRequestOptions bundle,
        @NonNull GeneratedCameraXLibrary.Result<Void> result) {
      if (context == null) {
        throw new IllegalStateException("Context must be set to add capture request options.");
      }

      ListenableFuture<Void> addCaptureRequestOptionsFuture =
          camera2CameraControl.addCaptureRequestOptions(bundle);

      Futures.addCallback(
          addCaptureRequestOptionsFuture,
          new FutureCallback<Void>() {
            public void onSuccess(Void voidResult) {
              result.success(null);
            }

            public void onFailure(Throwable t) {
              result.error(t);
            }
          },
          ContextCompat.getMainExecutor(context));
    }
  }

  /**
   * Constructs a {@link Camera2CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param context {@link Context} used to retrieve {@code Executor}
   */
  public Camera2CameraControlHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull Context context) {
    this(instanceManager, new Camera2CameraControlProxy(), context);
  }

  /**
   * Constructs a {@link Camera2CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor and methods of {@link Camera2CameraControl}
   * @param context {@link Context} used to retrieve {@code Executor}
   */
  @VisibleForTesting
  Camera2CameraControlHostApiImpl(
      @NonNull InstanceManager instanceManager,
      @NonNull Camera2CameraControlProxy proxy,
      @NonNull Context context) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
    proxy.context = context;
  }

  /**
   * Sets the context that the {@code Camera2CameraControl} will use to listen for the result of
   * setting capture request options.
   *
   * <p>If using the camera plugin in an add-to-app context, ensure that this is called anytime that
   * the context changes.
   */
  public void setContext(@NonNull Context context) {
    this.proxy.context = context;
  }

  @Override
  public void create(@NonNull Long identifier, @NonNull Long cameraControlIdentifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(Objects.requireNonNull(instanceManager.getInstance(cameraControlIdentifier))),
        identifier);
  }

  @Override
  public void addCaptureRequestOptions(
      @NonNull Long identifier,
      @NonNull Long captureRequestOptionsIdentifier,
      @NonNull GeneratedCameraXLibrary.Result<Void> result) {
    proxy.addCaptureRequestOptions(
        getCamera2CameraControlInstance(identifier),
        Objects.requireNonNull(instanceManager.getInstance(captureRequestOptionsIdentifier)),
        result);
  }

  /**
   * Retrieves the {@link Camera2CameraControl} instance associated with the specified {@code
   * identifier}.
   */
  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  private Camera2CameraControl getCamera2CameraControlInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
