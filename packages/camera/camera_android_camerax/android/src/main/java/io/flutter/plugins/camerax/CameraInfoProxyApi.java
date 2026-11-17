// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.DynamicRange;
import androidx.camera.core.ExperimentalLensFacing;
import androidx.camera.core.ExperimentalZeroShutterLag;
import androidx.camera.core.ExposureState;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * ProxyApi implementation for {@link CameraInfo}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class CameraInfoProxyApi extends PigeonApiCameraInfo {
  CameraInfoProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long sensorRotationDegrees(CameraInfo pigeonInstance) {
    return pigeonInstance.getSensorRotationDegrees();
  }

  @Override
  @OptIn(markerClass = ExperimentalLensFacing.class)
  public LensFacing lensFacing(CameraInfo pigeonInstance) {
    int lensFacing = pigeonInstance.getLensFacing();
    switch (lensFacing) {
      case CameraSelector.LENS_FACING_FRONT:
        return LensFacing.FRONT;
      case CameraSelector.LENS_FACING_BACK:
        return LensFacing.BACK;
      case CameraSelector.LENS_FACING_EXTERNAL:
        return LensFacing.EXTERNAL;
      default:
        return LensFacing.UNKNOWN;
    }
  }

  @NonNull
  @Override
  public ExposureState exposureState(CameraInfo pigeonInstance) {
    return pigeonInstance.getExposureState();
  }

  @NonNull
  @Override
  public LiveDataProxyApi.LiveDataWrapper getCameraState(CameraInfo pigeonInstance) {
    return new LiveDataProxyApi.LiveDataWrapper(
        pigeonInstance.getCameraState(), LiveDataSupportedType.CAMERA_STATE);
  }

  @NonNull
  @Override
  public LiveDataProxyApi.LiveDataWrapper getZoomState(CameraInfo pigeonInstance) {
    return new LiveDataProxyApi.LiveDataWrapper(
        pigeonInstance.getZoomState(), LiveDataSupportedType.ZOOM_STATE);
  }

  @Override
  @OptIn(markerClass = ExperimentalZeroShutterLag.class)
  public boolean isZslSupported(CameraInfo pigeonInstance) {
    return pigeonInstance.isZslSupported();
  }

  @NonNull
  @Override
  public List<DynamicRangeType> querySupportedDynamicRanges(
      @NonNull CameraInfo pigeonInstance, @NonNull List<? extends DynamicRangeType> candidates) {
    final Set<DynamicRange> candidateRanges = new HashSet<>();
    for (DynamicRangeType candidate : candidates) {
      switch (candidate) {
        case SDR:
          candidateRanges.add(DynamicRange.SDR);
          break;
        case HLG10:
          candidateRanges.add(DynamicRange.HLG_10_BIT);
          break;
      }
    }

    final Set<DynamicRange> supported = pigeonInstance.querySupportedDynamicRanges(candidateRanges);
    final List<DynamicRangeType> result = new ArrayList<>();
    if (supported.contains(DynamicRange.SDR)) {
      result.add(DynamicRangeType.SDR);
    }
    if (supported.contains(DynamicRange.HLG_10_BIT)) {
      result.add(DynamicRangeType.HLG10);
    }
    return result;
  }
}
