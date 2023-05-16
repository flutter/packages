// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedTypeData;

/**
 * Flutter API implementation for {@link LiveData}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class LiveDataFlutterApiWrapper {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private LiveDataFlutterApi liveDataFlutterApi;

  /**
   * Constructs a {@link LiveDataFlutterApiWrapper}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public LiveDataFlutterApiWrapper(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    liveDataFlutterApi = new LiveDataFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link LiveData} instance and notifies Dart to create and store a new {@link
   * LiveData} instance that is attached to this one. If {@code instance} has already been added,
   * this method does nothing.
   */
  public void create(
      @NonNull LiveData<?> instance,
      @NonNull LiveDataSupportedType type,
      @NonNull LiveDataFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      liveDataFlutterApi.create(
          instanceManager.addHostCreatedInstance(instance),
          new LiveDataSupportedTypeData.Builder().setValue(type).build(),
          callback);
    }
  }

  /** Sets the Flutter API used to send messages to Dart. */
  @VisibleForTesting
  void setApi(@NonNull LiveDataFlutterApi api) {
    this.liveDataFlutterApi = api;
  }
}
