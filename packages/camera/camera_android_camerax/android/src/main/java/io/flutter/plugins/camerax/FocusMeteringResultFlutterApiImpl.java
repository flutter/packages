// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.FocusMeteringResult;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringResultFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringResultFlutterApi.Reply;

/**
 * Flutter API implementation for {@link FocusMeteringResult}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class FocusMeteringResultFlutterApiImpl {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private FocusMeteringResultFlutterApi focusMeteringResultFlutterApi;

  /**
   * Constructs a {@link FocusMeteringResultFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public FocusMeteringResultFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    focusMeteringResultFlutterApi = new FocusMeteringResultFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link FocusMeteringResult} instance and notifies Dart to create and store a new
   * {@link FocusMeteringResult} instance that is attached to this one. If {@code instance} has
   * already been added, this method does nothing.
   */
  public void create(@NonNull FocusMeteringResult instance, @NonNull Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      focusMeteringResultFlutterApi.create(
          instanceManager.addHostCreatedInstance(instance), callback);
    }
  }

  /** Sets the Flutter API used to send messages to Dart. */
  @VisibleForTesting
  void setApi(@NonNull FocusMeteringResultFlutterApi api) {
    this.focusMeteringResultFlutterApi = api;
  }
}
