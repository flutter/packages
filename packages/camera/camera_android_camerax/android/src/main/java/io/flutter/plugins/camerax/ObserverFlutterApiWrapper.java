// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
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
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private ObserverFlutterApi observerFlutterApi;

  @VisibleForTesting public CameraStateFlutterApiWrapper cameraStateFlutterApiWrapper;

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
  public void onChanged(
      @NonNull Observer<?> instance,
      @NonNull Object value,
      @NonNull ObserverFlutterApi.Reply<Void> callback) {

    // Cast value to type of data that is being observed if supported by this plugin.
    if (value instanceof CameraState) {
      CameraState state = (CameraState) value;

      if (cameraStateFlutterApiWrapper == null) {
        cameraStateFlutterApiWrapper =
            new CameraStateFlutterApiWrapper(binaryMessenger, instanceManager);
      }
      cameraStateFlutterApiWrapper.create(
          state,
          CameraStateFlutterApiWrapper.getCameraStateType(state.getType()),
          state.getError(),
          reply -> {});
    } else {
      throw new UnsupportedOperationException(
          "The type of value in observance is not wrapped by this plugin.");
    }

    observerFlutterApi.onChanged(
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(instance)),
        instanceManager.getIdentifierForStrongReference(value),
        callback);
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull ObserverFlutterApi api) {
    this.observerFlutterApi = api;
  }
}
