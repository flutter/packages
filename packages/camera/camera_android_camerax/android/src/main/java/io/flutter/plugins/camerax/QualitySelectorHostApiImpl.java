// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import androidx.camera.video.QualitySelector;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.QualitySelectorHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQuality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQualityData;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Host API implementation for {@link QualitySelector}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class QualitySelectorHostApiImpl implements QualitySelectorHostApi {
  private final InstanceManager instanceManager;

  private final QualitySelectorProxy proxy;

  /** Proxy for constructor of {@link QualitySelector}. */
  @VisibleForTesting
  public static class QualitySelectorProxy {
    /** Creates an instance of {@link QualitySelector}. */
    public @NonNull QualitySelector create(
        @NonNull List<VideoQualityData> videoQualityDataList,
        @Nullable FallbackStrategy fallbackStrategy) {
      // Convert each index of VideoQuality to Quality.
      List<Quality> qualityList = new ArrayList<Quality>();
      for (VideoQualityData videoQualityData : videoQualityDataList) {
        qualityList.add(getQualityFromVideoQuality(videoQualityData.getQuality()));
      }

      boolean fallbackStrategySpecified = fallbackStrategy != null;
      if (qualityList.size() == 0) {
        throw new IllegalArgumentException(
            "List of at least one Quality must be supplied to create QualitySelector.");
      } else if (qualityList.size() == 1) {
        Quality quality = qualityList.get(0);
        return fallbackStrategySpecified
            ? QualitySelector.from(quality, fallbackStrategy)
            : QualitySelector.from(quality);
      }

      return fallbackStrategySpecified
          ? QualitySelector.fromOrderedList(qualityList, fallbackStrategy)
          : QualitySelector.fromOrderedList(qualityList);
    }
  }

  /**
   * Constructs a {@link QualitySelectorHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public QualitySelectorHostApiImpl(@NonNull InstanceManager instanceManager) {
    this(instanceManager, new QualitySelectorProxy());
  }

  /**
   * Constructs a {@link QualitySelectorHostApiImpl}.
   *
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   * @param proxy proxy for constructor of {@link QualitySelector}
   */
  QualitySelectorHostApiImpl(
      @NonNull InstanceManager instanceManager, @NonNull QualitySelectorProxy proxy) {
    this.instanceManager = instanceManager;
    this.proxy = proxy;
  }

  /**
   * Creates a {@link QualitySelector} instance with the quality list and {@link FallbackStrategy}
   * with the identifier specified.
   */
  @Override
  public void create(
      @NonNull Long identifier,
      @NonNull List<VideoQualityData> videoQualityDataList,
      @Nullable Long fallbackStrategyIdentifier) {
    instanceManager.addDartCreatedInstance(
        proxy.create(
            videoQualityDataList,
            fallbackStrategyIdentifier == null
                ? null
                : Objects.requireNonNull(instanceManager.getInstance(fallbackStrategyIdentifier))),
        identifier);
  }

  /**
   * Retrieves the corresponding resolution from the input quality for the camera represented by the
   * {@link CameraInfo} represented by the identifier specified.
   */
  @Override
  public @NonNull ResolutionInfo getResolution(
      @NonNull Long cameraInfoIdentifier, @NonNull VideoQuality quality) {
    final Size result =
        QualitySelector.getResolution(
            Objects.requireNonNull(instanceManager.getInstance(cameraInfoIdentifier)),
            getQualityFromVideoQuality(quality));
    return new ResolutionInfo.Builder()
        .setWidth(Long.valueOf(result.getWidth()))
        .setHeight(Long.valueOf(result.getHeight()))
        .build();
  }

  /**
   * Converts the specified {@link VideoQuality to a {@link Quality} that is understood
   * by CameraX.
   */
  public static @NonNull Quality getQualityFromVideoQuality(@NonNull VideoQuality videoQuality) {
    switch (videoQuality) {
      case SD:
        return Quality.SD;
      case HD:
        return Quality.HD;
      case FHD:
        return Quality.FHD;
      case UHD:
        return Quality.UHD;
      case LOWEST:
        return Quality.LOWEST;
      case HIGHEST:
        return Quality.HIGHEST;
    }
    throw new IllegalArgumentException(
        "VideoQuality " + videoQuality + " is unhandled by QualitySelectorHostApiImpl.");
  }
}
