// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.AnalyzerHostApi;

/**
 * Host API implementation for {@link ImageAnalysis.Analyzer}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class AnalyzerHostApiImpl implements AnalyzerHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final AnalyzerProxy proxy;

  /** Proxy for constructors and static method of {@link ImageAnalysis.Analyzer}. */
  @VisibleForTesting
  public static class AnalyzerProxy {

    /** Creates an instance of {@link AnalyzerImpl}. */
    @NonNull
    public AnalyzerImpl create(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      return new AnalyzerImpl(binaryMessenger, instanceManager);
    }
  }

  /**
   * Implementation of {@link ImageAnalysis.Analyzer} that passes arguments of callback methods to
   * Dart.
   */
  public static class AnalyzerImpl implements ImageAnalysis.Analyzer {
    private BinaryMessenger binaryMessenger;
    private InstanceManager instanceManager;
    private AnalyzerFlutterApiImpl api;

    @VisibleForTesting @NonNull public ImageProxyFlutterApiImpl imageProxyApi;

    /**
     * Constructs an instance of {@link ImageAnalysis.Analyzer} that passes arguments of callbacks
     * methods to Dart.
     */
    public AnalyzerImpl(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      super();
      this.binaryMessenger = binaryMessenger;
      this.instanceManager = instanceManager;
      api = new AnalyzerFlutterApiImpl(binaryMessenger, instanceManager);
      imageProxyApi = new ImageProxyFlutterApiImpl(binaryMessenger, instanceManager);
    }

    @Override
    public void analyze(@NonNull ImageProxy imageProxy) {
      Long imageFormat = Long.valueOf(imageProxy.getFormat());
      Long imageHeight = Long.valueOf(imageProxy.getHeight());
      Long imageWidth = Long.valueOf(imageProxy.getWidth());
      imageProxyApi.create(imageProxy, imageFormat, imageHeight, imageWidth, reply -> {});

      api.analyze(this, imageProxy, reply -> {});
    }

    /**
     * Flutter API used to send messages back to Dart.
     *
     * <p>This is only visible for testing.
     */
    @VisibleForTesting
    void setApi(@NonNull AnalyzerFlutterApiImpl api) {
      this.api = api;
    }
  }

  /**
   * Constructs a {@link AnalyzerHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public AnalyzerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this(binaryMessenger, instanceManager, new AnalyzerProxy());
  }

  /**
   * Constructs a {@link AnalyzerHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of {@link ImageAnalysis.Analyzer}
   */
  @VisibleForTesting
  AnalyzerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull AnalyzerProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates an {@link AnalyzerProxy} that represents an {@link ImageAnalysis.Analyzer} instance
   * with the specified identifier.
   */
  @Override
  public void create(@NonNull Long identifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(binaryMessenger, instanceManager), identifier);
  }
}
