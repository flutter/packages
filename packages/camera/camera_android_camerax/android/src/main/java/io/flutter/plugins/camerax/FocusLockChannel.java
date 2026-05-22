// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// yuvrecorder patch: exposes a side method channel that locks the active
// CameraX camera's focus at infinity by setting CONTROL_AF_MODE=OFF and
// LENS_FOCUS_DISTANCE=0 (0 diopters = infinity) via Camera2Interop.
//
// Re-applies the lock on every CameraX use-case rebind (e.g. startImageStream
// recreates the capture session and drops prior Camera2Interop options).

package io.flutter.plugins.camerax;

import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.CameraControl;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@ExperimentalCamera2Interop
final class FocusLockChannel implements MethodChannel.MethodCallHandler {
  static final String CHANNEL = "dev.aircraft.yuvrecorder/camera_focus";

  @Nullable private static volatile CameraControl activeCameraControl;
  // When true, every rebind that produces a fresh CameraControl re-applies
  // infinity focus automatically (CameraX drops Camera2Interop options on
  // use-case rebind, e.g. when startImageStream binds ImageAnalysis).
  private static volatile boolean reapplyAtInfinityOnRebind = false;

  static void setActiveCameraControl(@Nullable CameraControl control) {
    activeCameraControl = control;
    if (control != null && reapplyAtInfinityOnRebind) {
      try {
        Camera2CameraControl.from(control).addCaptureRequestOptions(infinityOptions());
      } catch (Throwable ignored) {
        // Best-effort; explicit method-channel calls surface real failures.
      }
    }
  }

  private static CaptureRequestOptions infinityOptions() {
    return new CaptureRequestOptions.Builder()
        .setCaptureRequestOption(
            CaptureRequest.CONTROL_AF_MODE, CameraMetadata.CONTROL_AF_MODE_OFF)
        .setCaptureRequestOption(CaptureRequest.LENS_FOCUS_DISTANCE, 0.0f)
        .build();
  }

  private final MethodChannel channel;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  FocusLockChannel(@NonNull BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, CHANNEL);
    channel.setMethodCallHandler(this);
  }

  void tearDown() {
    channel.setMethodCallHandler(null);
    activeCameraControl = null;
    reapplyAtInfinityOnRebind = false;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final CameraControl control = activeCameraControl;
    if (control == null) {
      result.error("no_camera", "Camera is not bound yet.", null);
      return;
    }
    switch (call.method) {
      case "lockFocusAtInfinity":
        reapplyAtInfinityOnRebind = true;
        applyOptions(control, infinityOptions(), result);
        return;
      default:
        result.notImplemented();
    }
  }

  private void applyOptions(
      @NonNull CameraControl control,
      @NonNull CaptureRequestOptions options,
      @NonNull MethodChannel.Result result) {
    try {
      Camera2CameraControl.from(control)
          .addCaptureRequestOptions(options)
          .addListener(
              () -> mainHandler.post(() -> result.success(null)),
              command -> command.run());
    } catch (Throwable t) {
      mainHandler.post(() -> result.error("focus_lock_failed", t.getMessage(), null));
    }
  }
}
