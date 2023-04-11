
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ObserverFlutterApi;
import java.util.Objects;

/**
 * Flutter API implementation for `Observer`.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class ObserverFlutterApiWrapper {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private ObserverFlutterApi api;

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
    api = new ObserverFlutterApi(binaryMessenger);
  }

  /**
   * Sends a message to Dart to call `Observer.onChanged` on the Dart object representing
   * `instance`.
   */
  public void onChanged(
      @NonNull Observer<?> instance,
      @NonNull Object value,
      @NonNull ObserverFlutterApi.Reply<Void> callback) {

    if (value instanceof CameraState) {
      CameraState state = (CameraState) value;
      new CameraStateFlutterApiWrapper(binaryMessenger, instanceManager).create(state, state.getType(), state.getError(), reply -> {});
    } else {
      // TODO(camsim99): make this more specific
      throw new UnsupportedOperationException();
    }

    api.onChanged(
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
    this.api = api;
  }
}
