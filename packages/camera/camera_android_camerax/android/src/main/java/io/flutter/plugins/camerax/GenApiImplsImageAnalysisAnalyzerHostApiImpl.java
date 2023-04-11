
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Fix name of generated pigeon file
// TODO(bparrishMines): Import native classes
import GeneratedPigeonFilename.ImageAnalysisAnalyzerHostApi;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;

/**
 * Host API implementation for `ImageAnalysisAnalyzer`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class ImageAnalysisAnalyzerHostApiImpl implements ImageAnalysisAnalyzerHostApi {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;

  private final ImageAnalysisAnalyzerProxy proxy;

  /** Proxy for constructors and static method of `ImageAnalysisAnalyzer`. */
  @VisibleForTesting
  public static class ImageAnalysisAnalyzerProxy {

    /** Creates an instance of `ImageAnalysisAnalyzer`. */
    public ImageAnalysisAnalyzerImpl create(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      //
      // return new ImageAnalysisAnalyzerImpl(
      //
      //    binaryMessenger, instanceManager);
    }
  }

  /**
   * Implementation of `ImageAnalysisAnalyzer` that passes arguments of callback methods to Dart.
   */
  public static class ImageAnalysisAnalyzerImpl extends ImageAnalysisAnalyzer {
    private ImageAnalysisAnalyzerFlutterApiImpl api;

    /**
     * Constructs an instance of `ImageAnalysisAnalyzer` that passes arguments of callbacks methods
     * to Dart.
     */
    public ImageAnalysisAnalyzerImpl(
        @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
      super();
      api = new ImageAnalysisAnalyzerFlutterApiImpl(binaryMessenger, instanceManager);
    }

    // TODO(bparrishMines): Need to handle inherited callback methods

    @Override
    public void analyze() {
      api.analyze(this, reply -> {});
    }

    /**
     * Flutter API used to send messages back to Dart.
     *
     * <p>This is only visible for testing.
     */
    @SuppressWarnings("unused")
    @VisibleForTesting
    void setApi(@NonNull ImageAnalysisAnalyzerFlutterApiImpl api) {
      this.api = api;
    }
  }

  /**
   * Constructs a {@link ImageAnalysisAnalyzerHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageAnalysisAnalyzerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {

    this(binaryMessenger, instanceManager, new ImageAnalysisAnalyzerProxy());
  }

  /**
   * Constructs a {@link ImageAnalysisAnalyzerHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructors and static method of `ImageAnalysisAnalyzer`
   */
  @VisibleForTesting
  ImageAnalysisAnalyzerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull ImageAnalysisAnalyzerProxy proxy) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(@NonNull Long identifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(binaryMessenger, instanceManager), identifier);
  }

  private ImageAnalysisAnalyzer getImageAnalysisAnalyzerInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
