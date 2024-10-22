// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Handler;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;

/** Utility class that facilitates communication to the Flutter client */
public class DartMessenger {
  @NonNull private final Handler handler;
  Messages.CameraGlobalEventApi globalEventApi;
  Messages.CameraEventApi eventApi;

  /**
   * Creates a new instance of the {@link DartMessenger} class.
   *
   * @param handler the handler used to manage the thread's message queue. This should always be a
   *     handler managing the main thread since communication with Flutter should always happen on
   *     the main thread. The handler is mainly supplied so it will be easier test this class.
   * @param globalEventApi the API used to consume calls to dart that are not tied to a specific
   *     camera instance.
   * @param eventApi the API used to consume calls to dart that are tied to this specific camera.
   */
  DartMessenger(
      @NonNull Handler handler,
      Messages.CameraGlobalEventApi globalEventApi,
      Messages.CameraEventApi eventApi) {
    this.handler = handler;
    this.globalEventApi = globalEventApi;
    this.eventApi = eventApi;
  }

  /**
   * Sends a message to the Flutter client informing the orientation of the device has been changed.
   *
   * @param orientation specifies the new orientation of the device.
   */
  public void sendDeviceOrientationChangeEvent(
      @NonNull PlatformChannel.DeviceOrientation orientation) {
    handler.post(
        () ->
            globalEventApi.deviceOrientationChanged(
                CameraUtils.orientationToPigeon(orientation), new NoOpVoidResult()));
  }

  /**
   * Sends a message to the Flutter client informing that the camera has been initialized.
   *
   * @param previewWidth describes the preview width that is supported by the camera.
   * @param previewHeight describes the preview height that is supported by the camera.
   * @param exposureMode describes the current exposure mode that is set on the camera.
   * @param focusMode describes the current focus mode that is set on the camera.
   * @param exposurePointSupported indicates if the camera supports setting an exposure point.
   * @param focusPointSupported indicates if the camera supports setting a focus point.
   */
  void sendCameraInitializedEvent(
      Integer previewWidth,
      Integer previewHeight,
      ExposureMode exposureMode,
      FocusMode focusMode,
      Boolean exposurePointSupported,
      Boolean focusPointSupported) {
    assert (previewWidth != null);
    assert (previewHeight != null);
    assert (exposureMode != null);
    assert (focusMode != null);
    assert (exposurePointSupported != null);
    assert (focusPointSupported != null);
    handler.post(
        () ->
            eventApi.initialized(
                new Messages.PlatformCameraState.Builder()
                    .setPreviewSize(
                        new Messages.PlatformSize.Builder()
                            .setWidth(previewWidth.doubleValue())
                            .setHeight(previewHeight.doubleValue())
                            .build())
                    .setExposurePointSupported(exposurePointSupported)
                    .setFocusPointSupported(focusPointSupported)
                    .setExposureMode(CameraUtils.exposureModeToPigeon(exposureMode))
                    .setFocusMode(CameraUtils.focusModeToPigeon(focusMode))
                    .build(),
                new NoOpVoidResult()));
  }

  /** Sends a message to the Flutter client informing that the camera is closing. */
  void sendCameraClosingEvent() {
    handler.post(() -> eventApi.closed(new NoOpVoidResult()));
  }

  /**
   * Sends a message to the Flutter client informing that an error occurred while interacting with
   * the camera.
   *
   * @param description contains details regarding the error that occurred.
   */
  void sendCameraErrorEvent(@NonNull String description) {
    handler.post(() -> eventApi.error(description, new NoOpVoidResult()));
  }

  /**
   * Send a success payload to a {@link MethodChannel.Result} on the main thread.
   *
   * @param payload The payload to send.
   */
  public <T> void finish(@NonNull Messages.Result<T> result, @NonNull T payload) {
    handler.post(() -> result.success(payload));
  }

  /**
   * Send an error payload to a {@link MethodChannel.Result} on the main thread.
   *
   * @param errorCode error code.
   * @param errorMessage error message.
   * @param errorDetails error details.
   */
  public <T> void error(
      @NonNull Messages.Result<T> result,
      @NonNull String errorCode,
      @Nullable String errorMessage,
      @Nullable Object errorDetails) {
    handler.post(
        () -> result.error(new Messages.FlutterError(errorCode, errorMessage, errorDetails)));
  }
}
