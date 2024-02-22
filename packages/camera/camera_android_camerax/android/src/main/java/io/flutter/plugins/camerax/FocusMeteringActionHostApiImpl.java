// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.MeteringPoint;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringActionHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.MeteringPointInfo;
import java.util.ArrayList;
import java.util.List;

/**
 * Host API implementation for {@link FocusMeteringAction}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class FocusMeteringActionHostApiImpl implements FocusMeteringActionHostApi {
  private final InstanceManager instanceManager;

  private final FocusMeteringActionProxy proxy;

  /** Proxy for constructor of {@link FocusMeteringAction}. */
  @VisibleForTesting
  public static class FocusMeteringActionProxy {
    /** Creates an instance of {@link FocusMeteringAction}. */
    public @NonNull FocusMeteringAction create(
        @NonNull List<MeteringPoint> meteringPoints,
        @NonNull List<Integer> meteringPointModes,
        @Nullable Boolean disableAutoCancel) {
      if (meteringPoints.size() >= 1 && meteringPoints.size() != meteringPointModes.size()) {
        throw new IllegalArgumentException(
            "One metering point must be specified and the number of specified metering points must match the number of specified metering point modes.");
      }

      FocusMeteringAction.Builder focusMeteringActionBuilder;

      // Create builder to potentially add more MeteringPoints to.
      MeteringPoint firstMeteringPoint = meteringPoints.get(0);
      Integer firstMeteringPointMode = meteringPointModes.get(0);
      if (firstMeteringPointMode == null) {
        focusMeteringActionBuilder = getFocusMeteringActionBuilder(firstMeteringPoint);
      } else {
        focusMeteringActionBuilder =
            getFocusMeteringActionBuilder(firstMeteringPoint, firstMeteringPointMode);
      }

      // Add any additional metering points in order as specified by input lists.
      for (int i = 1; i < meteringPoints.size(); i++) {
        MeteringPoint meteringPoint = meteringPoints.get(i);
        Integer meteringMode = meteringPointModes.get(i);

        if (meteringMode == null) {
          focusMeteringActionBuilder.addPoint(meteringPoint);
        } else {
          focusMeteringActionBuilder.addPoint(meteringPoint, meteringMode);
        }
      }

      if (disableAutoCancel != null && disableAutoCancel == true) {
        focusMeteringActionBuilder.disableAutoCancel();
      }

      return focusMeteringActionBuilder.build();
    }

    @VisibleForTesting
    @NonNull
    public FocusMeteringAction.Builder getFocusMeteringActionBuilder(
        @NonNull MeteringPoint meteringPoint) {
      return new FocusMeteringAction.Builder(meteringPoint);
    }

    @VisibleForTesting
    @NonNull
    public FocusMeteringAction.Builder getFocusMeteringActionBuilder(
        @NonNull MeteringPoint meteringPoint, int meteringMode) {
      return new FocusMeteringAction.Builder(meteringPoint, meteringMode);
    }
  }

  /**
   * Constructs a {@link FocusMeteringActionHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public FocusMeteringActionHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new FocusMeteringActionProxy());
  }

  /**
   * Constructs a {@link FocusMeteringActionHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link FocusMeteringAction}
   */
  FocusMeteringActionHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull FocusMeteringActionProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  @Override
  public void create(
      @NonNull Long identifier,
      @NonNull List<MeteringPointInfo> meteringPointInfos,
      @Nullable Boolean disableAutoCancel) {
    final List<MeteringPoint> meteringPoints = new ArrayList<MeteringPoint>();
    final List<Integer> meteringPointModes = new ArrayList<Integer>();
    for (MeteringPointInfo meteringPointInfo : meteringPointInfos) {
      meteringPoints.add(instanceManager.getInstance(meteringPointInfo.getMeteringPointId()));
      Long meteringPointMode = meteringPointInfo.getMeteringMode();
      meteringPointModes.add(meteringPointMode == null ? null : meteringPointMode.intValue());
    }

    instanceManager.addDartCreatedInstance(
        proxy.create(meteringPoints, meteringPointModes, disableAutoCancel), identifier);
  }
}
