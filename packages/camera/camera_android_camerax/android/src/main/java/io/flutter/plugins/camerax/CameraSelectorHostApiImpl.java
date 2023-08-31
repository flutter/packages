// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraSelectorHostApi;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class CameraSelectorHostApiImpl implements CameraSelectorHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public @NonNull CameraXProxy cameraXProxy = new CameraXProxy();

  public CameraSelectorHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public void create(@NonNull Long identifier, @Nullable Long lensFacing) {
    CameraSelector.Builder cameraSelectorBuilder = cameraXProxy.createCameraSelectorBuilder();
    if (lensFacing != null) {
      cameraSelectorBuilder = cameraSelectorBuilder.requireLensFacing(lensFacing.intValue());
    }
    instanceManager.addDartCreatedInstance(cameraSelectorBuilder.build(), identifier);
  }

  @Override
  public @NonNull List<Long> filter(@NonNull Long identifier, @NonNull List<Long> cameraInfoIds) {
    CameraSelector cameraSelector =
        (CameraSelector) Objects.requireNonNull(instanceManager.getInstance(identifier));
    List<CameraInfo> cameraInfosForFilter = new ArrayList<>();

    for (Number cameraInfoAsNumber : cameraInfoIds) {
      Long cameraInfoId = cameraInfoAsNumber.longValue();

      CameraInfo cameraInfo =
          (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(cameraInfoId));
      cameraInfosForFilter.add(cameraInfo);
    }

    List<CameraInfo> filteredCameraInfos = cameraSelector.filter(cameraInfosForFilter);
    List<Long> filteredCameraInfosIds = new ArrayList<>();

    for (CameraInfo cameraInfo : filteredCameraInfos) {
      Long filteredCameraInfoId = instanceManager.getIdentifierForStrongReference(cameraInfo);
      filteredCameraInfosIds.add(filteredCameraInfoId);
    }

    return filteredCameraInfosIds;
  }
}
