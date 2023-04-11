
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Fix name of generated pigeon file
// TODO(bparrishMines): Import native classes
import GeneratedPigeonFilename.ImageAnalysisAnalyzerFlutterApi;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;

/**
 * Flutter API implementation for `ImageAnalysisAnalyzer`.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class ImageAnalysisAnalyzerFlutterApiImpl {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private ImageAnalysisAnalyzerFlutterApi api;

  /**
   * Constructs a {@link ImageAnalysisAnalyzerFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageAnalysisAnalyzerFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new ImageAnalysisAnalyzerFlutterApi(binaryMessenger);
  }

  /**
   * Stores the `ImageAnalysisAnalyzer` instance and notifies Dart to create and store a new
   * `ImageAnalysisAnalyzer` instance that is attached to this one. If `instance` has already been
   * added, this method does nothing.
   */
  public void create(
      @NonNull ImageAnalysisAnalyzer instance,
      @NonNull ImageAnalysisAnalyzerFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(instanceManager.addHostCreatedInstance(instance), callback);
    }
  }

  /**
   * Sends a message to Dart to call `ImageAnalysisAnalyzer.analyze` on the Dart object representing
   * `instance`.
   */
  public void analyze(
      @NonNull ImageAnalysisAnalyzer instance,
      @NonNull ImageAnalysisAnalyzerFlutterApi.Reply<Void> callback) {
    api.analyze(
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(instance)),
        callback);
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull ImageAnalysisAnalyzerFlutterApi api) {
    this.api = api;
  }
}
