// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ObserverHostApi;
import java.util.Objects;

/**
 * Host API implementation for {@link Observer}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ObserverHostApiImpl implements ObserverHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final ObserverProxy observerProxy;

  /** Proxy for constructors and static method of {@link Observer}. */
  @VisibleForTesting
  public static class ObserverProxy {

    /** Creates an instance of {@link Observer}. */
    @NonNull
    public <T> ObserverImpl<T> create(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      return new ObserverImpl<T>(binaryMessenger, instanceManager);
    }
  }

  /** Implementation of {@link Observer} that passes arguments of callback methods to Dart. */
  public static class ObserverImpl<T> implements Observer<T> {
    private ObserverFlutterApiWrapper observerFlutterApiWrapper;

    /**
     * Constructs an instance of {@link Observer} that passes arguments of callbacks methods to
     * Dart.
     */
    public ObserverImpl(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      super();
      observerFlutterApiWrapper = new ObserverFlutterApiWrapper(binaryMessenger, instanceManager);
    }

    /** Method called when the data in observance is changed to {@code value}. */
    @Override
    public void onChanged(T value) {
      observerFlutterApiWrapper.onChanged(this, value, reply -> {});
    }

    /** Flutter API used to send messages back to Dart. */
    @VisibleForTesting
    void setApi(@NonNull ObserverFlutterApiWrapper api) {
      this.observerFlutterApiWrapper = api;
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
   * @param proxy proxy for constructors and static method of {@link Observer}
   */
  @VisibleForTesting
  ObserverHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull ObserverProxy observerProxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.observerProxy = observerProxy;
  }

  /** Creates an {@link Observer} instance with the specified observer. */
  @Override
  public void create(@NonNull Long identifier) {
    instanceManager.addDartCreatedInstance(
        observerProxy.create(binaryMessenger, instanceManager), identifier);
  }

  private Observer<?> getObserverInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
