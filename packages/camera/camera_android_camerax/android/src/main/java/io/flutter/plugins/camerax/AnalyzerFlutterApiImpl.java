// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.AnalyzerFlutterApi;
import java.util.Objects;

/**
 * Flutter API implementation for {@link ImageAnalysis.Analyzer}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class AnalyzerFlutterApiImpl {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private AnalyzerFlutterApi api;

  /**
   * Constructs a {@link AnalyzerFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public AnalyzerFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new AnalyzerFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link ImageAnalysis.Analyzer} instance and notifies Dart to create and store a new
   * {@code Analyzer} instance that is attached to this one. If {@code instance} has already been
   * added, this method does nothing.
   */
  public void create(
      @NonNull ImageAnalysis.Analyzer instance, @NonNull AnalyzerFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(instanceManager.addHostCreatedInstance(instance), callback);
    }
  }

  /**
   * Sends a message to Dart to call {@code Analyzer.analyze} on the Dart object representing
   * `instance`.
   */
  public void analyze(
      @NonNull ImageAnalysis.Analyzer analyzerInstance,
      @NonNull ImageProxy imageProxyInstance,
      @NonNull AnalyzerFlutterApi.Reply<Void> callback) {
    api.analyze(
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(analyzerInstance)),
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(imageProxyInstance)),
        callback);
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull AnalyzerFlutterApi api) {
    this.api = api;
  }
}
