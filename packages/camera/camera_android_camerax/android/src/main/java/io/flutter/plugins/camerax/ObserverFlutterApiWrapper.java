// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ObserverFlutterApi;
import java.util.Objects;

/**
 * Flutter API implementation for {@link Observer}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class ObserverFlutterApiWrapper {

  private static final String TAG = "ObserverFlutterApi";

  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private ObserverFlutterApi observerFlutterApi;

  @VisibleForTesting @Nullable public CameraStateFlutterApiWrapper cameraStateFlutterApiWrapper;
  @VisibleForTesting @Nullable public ZoomStateFlutterApiImpl zoomStateFlutterApiImpl;

  /**
   * Constructs a {@link ObserverFlutterApiWrapper}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ObserverFlutterApiWrapper(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    observerFlutterApi = new ObserverFlutterApi(binaryMessenger);
  }

  /**
   * Sends a message to Dart to call {@link Observer.onChanged} on the Dart object representing
   * {@code instance}.
   */
  public <T> void onChanged(
      @NonNull Observer<T> instance,
      @NonNull T value,
      @NonNull ObserverFlutterApi.Reply<Void> callback) {

    // Cast value to type of data that is being observed and create it on the Dart side
    // if supported by this plugin.
    //
    // The supported types can be found in GeneratedCameraXLibrary.java as the
    // LiveDataSupportedType enum. To add a new type, please follow the instructions
    // found in pigeons/camerax_library.dart in the documentation for LiveDataSupportedType.
    if (value instanceof CameraState) {
      createCameraState((CameraState) value);
    } else if (value instanceof ZoomState) {
      createZoomState((ZoomState) value);
    } else {
      throw new UnsupportedOperationException(
          "The type of value that was observed is not handled by this plugin.");
    }

    Long observerIdentifier = instanceManager.getIdentifierForStrongReference(instance);
    if (observerIdentifier == null) {
      Log.e(
          TAG,
          "The Observer that received a callback has been garbage collected. Please create a new instance to receive any further data changes.");
      return;
    }

    observerFlutterApi.onChanged(
        Objects.requireNonNull(observerIdentifier),
        instanceManager.getIdentifierForStrongReference(value),
        callback);
  }

  /** Creates a {@link CameraState} on the Dart side. */
  private void createCameraState(CameraState cameraState) {
    if (cameraStateFlutterApiWrapper == null) {
      cameraStateFlutterApiWrapper =
          new CameraStateFlutterApiWrapper(binaryMessenger, instanceManager);
    }
    cameraStateFlutterApiWrapper.create(
        cameraState,
        CameraStateFlutterApiWrapper.getCameraStateType(cameraState.getType()),
        cameraState.getError(),
        reply -> {});
  }

  /** Creates a {@link ZoomState} on the Dart side. */
  private void createZoomState(ZoomState zoomState) {
    if (zoomStateFlutterApiImpl == null) {
      zoomStateFlutterApiImpl = new ZoomStateFlutterApiImpl(binaryMessenger, instanceManager);
    }
    zoomStateFlutterApiImpl.create(zoomState, reply -> {});
  }

  /** Sets the Flutter API used to send messages to Dart. */
  @VisibleForTesting
  void setApi(@NonNull ObserverFlutterApi api) {
    this.observerFlutterApi = api;
  }
}
