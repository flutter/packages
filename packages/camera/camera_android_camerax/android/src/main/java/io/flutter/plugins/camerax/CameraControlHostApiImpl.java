// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraControl;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.FocusMeteringResult;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraControlHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link CameraControl}.
 *
 * <p>This class handles instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class CameraControlHostApiImpl implements CameraControlHostApi {
  private final InstanceManager instanceManager;
  private final CameraControlProxy proxy;

  /** Proxy for constructors and static method of {@link CameraControl}. */
  @VisibleForTesting
  public static class CameraControlProxy {
    Context context;

    /** Enables or disables the torch of the specified {@link CameraControl} instance. */
    @NonNull
    public void enableTorch(
        @NonNull CameraControl cameraControl,
        @NonNull Boolean torch,
        @NonNull GeneratedCameraXLibrary.Result<Void> result) {
      ListenableFuture<Void> enableTorchFuture = cameraControl.enableTorch(torch);

      Futures.addCallback(
          enableTorchFuture,
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

    /** Sets the zoom ratio of the specified {@link CameraControl} instance. */
    @NonNull
    public void setZoomRatio(
        @NonNull CameraControl cameraControl,
        @NonNull Double ratio,
        @NonNull GeneratedCameraXLibrary.Result<Void> result) {
      float ratioAsFloat = ratio.floatValue();
      ListenableFuture<Void> setZoomRatioFuture = cameraControl.setZoomRatio(ratioAsFloat);

      Futures.addCallback(
          setZoomRatioFuture,
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

    public void startFocusAndMetering(
        @NonNull CameraControl cameraControl,
        @NonNull FocusMeteringAction focusMeteringAction,
        @NonNull GeneratedCameraXLibrary.Result<Long> result) {
      ListenableFuture<FocusMeteringResult> focusMeteringResultFuture =
          cameraControl.startFocusAndMetering(action);

      Futures.addCallback(
          focusMeteringResultFuture,
          new FutureCallback<FocusMeteringResult>() {
            public void onSuccess(FocusMeteringResult focusMeteringResult) {
              final FocusMeteringResultFlutterApiImpl flutterApi =
                  new FocusMeteringResultFlutterApiImpl(binaryMessenger, instanceManager);
              flutterApi.create(focusMeteringResult, reply -> {});
              result.success(instanceManager.getIdentifierForStrongReference(focusMeteringResult));
            }

            public void onFailure(Throwable t) {
              result.error(t);
            }
          },
          ContextCompat.getMainExecutor(context));
    }

   public void cancelFocusAndMetering(@NonNull CameraControl cameraControl, @NonNull Result<Void> result) {
      ListenableFuture<Void> cancelFocusAndMeteringFuture = cameraControl.cancelFocusAndMetering();

      Futures.addCallback(
        cancelFocusAndMeteringFuture,
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

    public void setExposureCompensationIndex(@NonNull CameraControl cameraControl, @NonNull Long index, @NonNull Result<Long> result) {
      ListenableFuture<Integer> setExposureCompensationIndexFuture = cameraControl.setExposureCompensationIndex(index.intValue());

      Futures.addCallback(
        setExposureCompensationIndexFuture,
        new FutureCallback<Integer>() {
          public void onSuccess(Integer integerResult) {
            result.success(integerResult);
          }

          public void onFailure(Throwable t) {
            result.error(t);
          }
        },
        ContextCompat.getMainExecutor(context));
  }

  /**
   * Constructs an {@link CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public CameraControlHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull Context context) {
    this(instanceManager, new CameraControlProxy(), context);
  }

  /**
   * Constructs an {@link CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link CameraControl}
   * @param context {@link Context} used to retrieve {@code Executor} used to enable torch mode
   */
  @VisibleForTesting
  CameraControlHostApiImpl(
      @NonNull InstanceManager instanceManager,
      @NonNull CameraControlProxy proxy,
      @NonNull Context context) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
    proxy.context = context;
  }

  /**
   * Sets the context that the {@code ProcessCameraProvider} will use to enable/disable torch mode
   * and set the zoom ratio.
   *
   * <p>If using the camera plugin in an add-to-app context, ensure that a new instance of the
   * {@code CameraControl} is fetched via {@code #enableTorch} anytime the context changes.
   */
  public void setContext(@NonNull Context context) {
    this.proxy.context = context;
  }

  @Override
  public void enableTorch(
      @NonNull Long identifier,
      @NonNull Boolean torch,
      @NonNull GeneratedCameraXLibrary.Result<Void> result) {
    proxy.enableTorch(getCameraControlInstance(identifier), torch, result);
  }

  @Override
  public void setZoomRatio(
      @NonNull Long identifier,
      @NonNull Double ratio,
      @NonNull GeneratedCameraXLibrary.Result<Void> result) {
    proxy.setZoomRatio(getCameraControlInstance(identifier), ratio, result);
  }

  @Override
  public void startFocusAndMetering(
      @NonNull Long identifier, @NonNull Long focusMeteringActionId, @NonNull Result<Long> result) {
    proxy.startFocusAndMetering(
        getCameraControlInstance(identifier),
        Objects.requireNonNull(instanceManager.getInstance(focusMeteringActionId)),
        result);
  }

  @Override
  public void cancelFocusAndMetering(@NonNull Long identifier, @NonNull Result<Void> result) {
    proxy.cancelFocusAndMetering(getCameraControlInstance(identifier), result);
  }

  @Override
  public void setExposureCompensationIndex(@NonNull Long identifier, @NonNull Long index, @NonNull Result<Long> result) {
    proxy.setExposureCompensationIndex(getCameraControlInstance(identifier), index, result);
  }


  private CameraControl getCameraControlInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
