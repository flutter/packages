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
   * Sends a message to Dart to call {@code ResolutionFilter.filter} on the Dart object representing
   * `instance`.
   */
  public void filter(@NonNull ResolutionFilter instance, @NonNull List<ResolutionInfo> supportedSizes, @NonNull Long rotationDegrees) {
        api.filter(
            Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(instance)),
            supportedSizes,
            rotationDegrees,
            callback,
            reply -> {},
        );
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
