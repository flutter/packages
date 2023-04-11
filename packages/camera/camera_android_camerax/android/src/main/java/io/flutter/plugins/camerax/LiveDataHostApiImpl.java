
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import androidx.annotation.NonNull;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataHostApi;
import java.util.Objects;

/**
 * Host API implementation for `LiveData`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class LiveDataHostApiImpl implements LiveDataHostApi {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  public LifecycleOwner fakeLifecycleOwner;

  /**
   * Constructs a {@link LiveDataHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public LiveDataHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {

    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  @SuppressWarnings("unchecked")
  public void observe(@NonNull Long identifier, @NonNull Long observerIdentifier) {

    // tODO(camsim99): get lifecycleowner
    getLiveDataInstance(identifier)
        .observe(fakeLifecycleOwner, Objects.requireNonNull(instanceManager.getInstance(observerIdentifier)));
  }

  @Override
  public void removeObservers(@NonNull Long identifier) {

        // tODO(camsim99): get lifecycleowner
    getLiveDataInstance(identifier).removeObservers(fakeLifecycleOwner);
  }

  private LiveData<?> getLiveDataInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
