// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringActionHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQuality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQualityData;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Host API implementation for {@link FocusMeteringAction}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class FocusMeteringActionHostApiImpl implements FocusMeteringActionHostApi {
  private final InstanceManager instanceManager;

  private final FocusMeteringActionProxy proxy;

  /** Proxy for constructors and static method of {@link FocusMeteringAction}. */
  @VisibleForTesting
  public static class FocusMeteringActionProxy {
    /** Creates an instance of {@link FocusMeteringAction}. */
    public @NonNull FocusMeteringAction create(
        @NonNull List<MeteringPoint> meteringPoints, @NonNull List<Integer> meteringPointModes) {
      if (meteringPoints.size() != meteringPointModes.size()) {
        throw new IllegalArgumentException("The number of specified metering points must match the number of specified metering point modes.");
      }
      FocusMeteringAction.Builder focusMeteringActionBuilder;

      for (int i = 0; i < meteringPoints.size(); i++) {
        MeteringPoint meteringPoint = meteringPoints.get(i);
        Integer meteringMode = meteringPointModes.get(i);
        if (i == 0) {
          // On the first iteration, create the builder to add points to.
          if (meteringMode == null) {
            focusMeteringActionBuilder = new FocusMeteringAction.Builder(meteringPoint);
          } else {
            focusMeteringActionBuilder = new FocusMeteringAction.Builder(meteringPoint, meteringMode);
          }
          continue;
        }

        // For any i(teration) > 0, add metering points in order as specified by input lists.
        if (meteringMode == null) {
          focusMeteringActionBuilder.add(meteringPoint);
        } else {
          focusMeteringActionBuilder.add(meteringPoint, meteringMode);
        }
      }

      return focusMeteringActionBuilder.build();
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
   * @param proxy proxy for constructors and static method of {@link FocusMeteringAction}
   */
  FocusMeteringActionHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull FocusMeteringActionProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }


  @Override
  public void create(@NonNull Long identifier, @NonNull List<MeteringPointInfo> meteringPointInfos) {
    final List<MeteringPoint> meteringPoints = new ArrayList<MeteringPoint>();
    final List<Integer> meteringPointModes = new ArrayList<int>();
    for (MeteringPointInfo meteringPointInfo : meteringPointInfos) {
      meteringPoint.add(instanceManager.getInstance(meteringPointInfo.getMeteringPointId()));
      meteringPointModes.add(meteringPointIngo.getMeteringMode().intValue());
    }

    instanceManager.addDartCreatedInstance(
        proxy.create(meteringPoints, meteringPointModes), identifier);
  }
}
