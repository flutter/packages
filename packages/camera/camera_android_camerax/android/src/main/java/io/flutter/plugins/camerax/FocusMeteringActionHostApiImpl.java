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
        @NonNull MeteringPoint meteringPoint, @Nullable meteringMode) {
      FocusMeteringAction.Builder focusMeteringActionBuilder;
      if (meteringMode == null) {
        focusMeteringActionBuilder = new FocusMeteringAction.Builder(meteringPoint);
      } else {
        focusMeteringActionBuilder = new FocusMeteringAction.Builder(meteringPoint, meteringMode);
      }

      return focusMeteringActionBuilder.build();
    }

    public @NonNull FocusMeteringAction create(
        @NonNull FocusMeteringAction focusMeteringAction,
        @NonNull MeteringPoint meteringPoint, @Nullable meteringMode) {
        FocusMetering newFocusMeteringAction;
        if (meteringMode == null) {
        newFocusMeteringAction = focusMeteringAction.addPoint(meteringPoint);
      } else {
        newFocusMeteringAction = focusMeteringAction.addPoint(meteringPoint, meteringMode);
      }

        return newFocusMeteringAction;
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
  public void create(@NonNull Long identifier, @NonNull Long meteringPointId, @Nullable Long meteringMode) {
    instanceManager.addDartCreatedInstance(
        proxy.create(Objects.requireNonNull(instanceManager.getInstance(meteringPointId)), meteringMode), identifier);
  }

  @Override
  @NonNull 
    Long addPoint(@NonNull Long identifier, @NonNull Long meteringPointId, @Nullable Long meteringMode) {
        FocusMeteringAction newFocusMeteringAction = proxy.addPoint(Objects.requireNonNull(instanceManager.getInstance(identifier)), Objects.requireNonNull(instanceManager.getInstance(meteringPointId)), meteringMode);
        final FocusMeteringActionFlutterApiImpl flutterApi =
          new FocusMeteringActionFlutterApiImpl(binaryMessenger, instanceManager);
        flutterApi.create(newFocusMeteringAction, reply -> {});
        return instanceManager.getIdentifierForStrongReference(newFocusMeteringAction);
    }
}
