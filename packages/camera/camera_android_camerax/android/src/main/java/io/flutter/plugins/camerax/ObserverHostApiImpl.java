
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ObserverHostApi;
import java.util.Objects;

/**
 * Host API implementation for `Observer`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ObserverHostApiImpl implements ObserverHostApi {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  private final ObserverProxy proxy;

  /** Proxy for constructors and static method of `Observer`. */
  @VisibleForTesting
  public static class ObserverProxy {

    /** Creates an instance of `Observer`. */
    public <T>ObserverImpl<T> create(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
     return new ObserverImpl<T>(binaryMessenger, instanceManager);
    }
  }

  /** Implementation of `Observer` that passes arguments of callback methods to Dart. */
  public static class ObserverImpl<T> implements Observer<T> {
    private ObserverFlutterApiWrapper api;

    /** Constructs an instance of `Observer` that passes arguments of callbacks methods to Dart. */
    public ObserverImpl(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      super();
      api = new ObserverFlutterApiWrapper(binaryMessenger, instanceManager);
    }

    // TODO(bparrishMines): Need to handle inherited callback methods

    @Override
    public void onChanged(T value) {
      api.onChanged(this, value, reply -> {});
    }

    /**
     * Flutter API used to send messages back to Dart.
     *
     * <p>This is only visible for testing.
     */
    @SuppressWarnings("unused")
    @VisibleForTesting
    void setApi(@NonNull ObserverFlutterApiWrapper api) {
      this.api = api;
    }
  }

  /**
   * Constructs a {@link ObserverHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ObserverHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {

    this(binaryMessenger, instanceManager, new ObserverProxy());
  }

  /**
   * Constructs a {@link ObserverHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of `Observer`
   */
  @VisibleForTesting
  ObserverHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull ObserverProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(@NonNull Long identifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(binaryMessenger, instanceManager), identifier);
  }

  private Observer<?> getObserverInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
