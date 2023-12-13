// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringActionFlutterApi;

/**
 * Flutter API implementation for {@link FocusMeteringAction}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class FocusMeteringActionFlutterApiWrapper {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private FocusMeteringActionFlutterApi focusMeteringActionFlutterApi;

  /**
   * Constructs a {@link FocusMeteringActionFlutterApiWrapper}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public FocusMeteringActionFlutterApiWrapper(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    focusMeteringActionFlutterApi = new FocusMeteringActionFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link FocusMeteringAction} instance and notifies Dart to create and store a new
   * {@link FocusMeteringAction} instance that is attached to this one. If {@code instance} has
   * already been added, this method does nothing.
   */
  public void create(
      @NonNull FocusMeteringAction instance,
      @NonNull Long meteringPointIdArg,
      @Nullable Long meteringModeArg,
      @NonNull Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      focusMeteringActionFlutterApi.create(
          instanceManager.addHostCreatedInstance(instance), code, callback);
    }
  }

  /** Sets the Flutter API used to send messages to Dart. */
  @VisibleForTesting
  void setApi(@NonNull FocusMeteringActionFlutterApi api) {
    this.focusMeteringActionFlutterApi = api;
  }
}
