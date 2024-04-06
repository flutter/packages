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
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraControlHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Result;
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

  /** Proxy for methods of {@link CameraControl}. */
  @VisibleForTesting
  public static class CameraControlProxy {
    Context context;
    BinaryMessenger binaryMessenger;
    InstanceManager instanceManager;

    /** Enables or disables the torch of the specified {@link CameraControl} instance. */
    @NonNull
    public void enableTorch(
        @NonNull CameraControl cameraControl,
        @NonNull Boolean torch,
        @NonNull GeneratedCameraXLibrary.Result<Void> result) {
      if (context == null) {
        throw new IllegalStateException("Context must be set to enable the torch.");
      }

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
      if (context == null) {
        throw new IllegalStateException("Context must be set to set zoom ratio.");
      }

      float ratioAsFloat = ratio.floatValue();
      ListenableFuture<Void> setZoomRatioFuture = cameraControl.setZoomRatio(ratioAsFloat);

      Futures.addCallback(
          setZoomRatioFuture,
          new FutureCallback<Void>() {
            public void onSuccess(Void voidResult) {
              result.success(null);
            }

            public void onFailure(Throwable t) {
              if (t instanceof CameraControl.OperationCanceledException) {
                // Operation was canceled due to camera being closed or a new request was submitted, which
                // is not actionable and should not block a new value from potentially being submitted.
                result.success(null);
                return;
              }
              result.error(t);
            }
          },
          ContextCompat.getMainExecutor(context));
    }

    /**
     * Starts a focus and metering action configured by the {@code FocusMeteringAction}.
     *
     * <p>Will trigger an auto focus action and enable auto focus/auto exposure/auto white balance
     * metering regions.
     *
     * <p>Will send a {@link GeneratedCameraXLibrary.Result} with a null result if operation was
     * canceled.
     */
    public void startFocusAndMetering(
        @NonNull CameraControl cameraControl,
        @NonNull FocusMeteringAction focusMeteringAction,
        @NonNull GeneratedCameraXLibrary.Result<Long> result) {
      if (context == null) {
        throw new IllegalStateException("Context must be set to set zoom ratio.");
      }

      ListenableFuture<FocusMeteringResult> focusMeteringResultFuture =
          cameraControl.startFocusAndMetering(focusMeteringAction);

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
              if (t instanceof CameraControl.OperationCanceledException) {
                // Operation was canceled due to camera being closed or a new request was submitted, which
                // is not actionable and should not block a new value from potentially being submitted.
                result.success(null);
                return;
              }
              result.error(t);
            }
          },
          ContextCompat.getMainExecutor(context));
    }

    /**
     * Cancels current {@code FocusMeteringAction} and clears auto focus/auto exposure/auto white
     * balance regions.
     */
    public void cancelFocusAndMetering(
        @NonNull CameraControl cameraControl, @NonNull Result<Void> result) {
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

    /**
     * Sets the exposure compensation index for the specified {@link CameraControl} instance and
     * returns the new target exposure value.
     *
     * <p>The exposure compensation value set on the camera must be within the range of {@code
     * ExposureState#getExposureCompensationRange()} for the current {@code ExposureState} for the
     * call to succeed.
     *
     * <p>Will send a {@link GeneratedCameraXLibrary.Result} with a null result if operation was
     * canceled.
     */
    public void setExposureCompensationIndex(
        @NonNull CameraControl cameraControl, @NonNull Long index, @NonNull Result<Long> result) {
      ListenableFuture<Integer> setExposureCompensationIndexFuture =
          cameraControl.setExposureCompensationIndex(index.intValue());

      Futures.addCallback(
          setExposureCompensationIndexFuture,
          new FutureCallback<Integer>() {
            public void onSuccess(Integer integerResult) {
              result.success(integerResult.longValue());
            }

            public void onFailure(Throwable t) {
              if (t instanceof CameraControl.OperationCanceledException) {
                // Operation was canceled due to camera being closed or a new request was submitted, which
                // is not actionable and should not block a new value from potentially being submitted.
                result.success(null);
                return;
              }
              result.error(t);
            }
          },
          ContextCompat.getMainExecutor(context));
    }
  }

  /**
   * Constructs an {@link CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param context {@link Context} used to retrieve {@code Executor}
   */
  public CameraControlHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull Context context) {
    this(binaryMessenger, instanceManager, new CameraControlProxy(), context);
  }

  /**
   * Constructs an {@link CameraControlHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for methods of {@link CameraControl}
   * @param context {@link Context} used to retrieve {@code Executor}
   */
  @VisibleForTesting
  CameraControlHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull CameraControlProxy proxy,
      @NonNull Context context) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
    proxy.context = context;
    // proxy.startFocusAndMetering needs to access these to create a FocusMeteringResult when it becomes available:
    proxy.instanceManager = instanceManager;
    proxy.binaryMessenger = binaryMessenger;
  }

  /**
   * Sets the context that the {@code CameraControl} will use to enable/disable torch mode and set
   * the zoom ratio.
   *
   * <p>If using the camera plugin in an add-to-app context, ensure that this is called anytime that
   * the context changes.
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
  public void setExposureCompensationIndex(
      @NonNull Long identifier, @NonNull Long index, @NonNull Result<Long> result) {
    proxy.setExposureCompensationIndex(getCameraControlInstance(identifier), index, result);
  }

  private CameraControl getCameraControlInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
