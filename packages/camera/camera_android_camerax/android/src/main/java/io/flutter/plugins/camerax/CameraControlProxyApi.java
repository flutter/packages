// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraControl;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.FocusMeteringResult;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * ProxyApi implementation for {@link CameraControl}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class CameraControlProxyApi extends PigeonApiCameraControl {
  CameraControlProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @Override
  public void enableTorch(
      @NonNull CameraControl pigeonInstance,
      boolean torch,
      @NonNull Function1<? super Result<Unit>, Unit> callback) {
    final ListenableFuture<Void> enableTorchFuture = pigeonInstance.enableTorch(torch);

    Futures.addCallback(
        enableTorchFuture,
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

  @Override
  public void setZoomRatio(
      @NonNull CameraControl pigeonInstance,
      double ratio,
      @NonNull Function1<? super Result<Unit>, Unit> callback) {
    float ratioAsFloat = (float) ratio;
    final ListenableFuture<Void> setZoomRatioFuture = pigeonInstance.setZoomRatio(ratioAsFloat);

    Futures.addCallback(
        setZoomRatioFuture,
        new FutureCallback<>() {
          @Override
          public void onSuccess(Void voidResult) {
            ResultCompat.success(null, callback);
          }

          @Override
          public void onFailure(@NonNull Throwable t) {
            if (t instanceof CameraControl.OperationCanceledException) {
              // Operation was canceled due to camera being closed or a new request was submitted, which
              // is not actionable and should not block a new value from potentially being submitted.
              ResultCompat.success(null, callback);
              return;
            }

            ResultCompat.failure(t, callback);
          }
        },
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()));
  }

  @Override
  public void startFocusAndMetering(
      @NonNull CameraControl pigeonInstance,
      @NonNull FocusMeteringAction action,
      @NonNull Function1<? super Result<FocusMeteringResult>, Unit> callback) {
    ListenableFuture<FocusMeteringResult> focusMeteringResultFuture =
        pigeonInstance.startFocusAndMetering(action);

    Futures.addCallback(
        focusMeteringResultFuture,
        new FutureCallback<>() {
          @Override
          public void onSuccess(FocusMeteringResult focusMeteringResult) {
            ResultCompat.success(focusMeteringResult, callback);
          }

          @Override
          public void onFailure(@NonNull Throwable t) {
            if (t instanceof CameraControl.OperationCanceledException) {
              // Operation was canceled due to camera being closed or a new request was submitted, which
              // is not actionable and should not block a new value from potentially being submitted.
              ResultCompat.success(null, callback);
              return;
            }
            ResultCompat.failure(t, callback);
          }
        },
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()));
  }

  @Override
  public void cancelFocusAndMetering(
      @NonNull CameraControl pigeonInstance,
      @NonNull Function1<? super Result<Unit>, Unit> callback) {
    final ListenableFuture<Void> cancelFocusAndMeteringFuture =
        pigeonInstance.cancelFocusAndMetering();

    Futures.addCallback(
        cancelFocusAndMeteringFuture,
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

  @Override
  public void setExposureCompensationIndex(
      @NonNull CameraControl pigeonInstance,
      long index,
      @NonNull Function1<? super Result<Long>, Unit> callback) {
    final ListenableFuture<Integer> setExposureCompensationIndexFuture =
        pigeonInstance.setExposureCompensationIndex((int) index);

    Futures.addCallback(
        setExposureCompensationIndexFuture,
        new FutureCallback<>() {
          @Override
          public void onSuccess(Integer integerResult) {
            ResultCompat.success(integerResult.longValue(), callback);
          }

          @Override
          public void onFailure(@NonNull Throwable t) {
            if (t instanceof CameraControl.OperationCanceledException) {
              // Operation was canceled due to camera being closed or a new request was submitted, which
              // is not actionable and should not block a new value from potentially being submitted.
              ResultCompat.success(null, callback);
              return;
            }
            ResultCompat.failure(t, callback);
          }
        },
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()));
  }
}
