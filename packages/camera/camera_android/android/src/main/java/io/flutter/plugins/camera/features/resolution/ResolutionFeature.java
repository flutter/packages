// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.resolution;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.graphics.ImageFormat;
import android.hardware.camera2.CaptureRequest;
import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.os.Build;
import android.util.Log;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.SdkCapabilityChecker;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.types.CaptureMode;

import java.util.ArrayList;
import java.util.List;

/**
 * Controls the resolutions configuration on the {@link android.hardware.camera2} API.
 *
 * <p>The {@link ResolutionFeature} is responsible for converting the platform independent {@link
 * ResolutionPreset} into a {@link android.media.CamcorderProfile} which contains all the properties
 * required to configure the resolution using the {@link android.hardware.camera2} API.
 */
public class ResolutionFeature extends CameraFeature<ResolutionPreset> {
  @Nullable
  private Size captureSize;
  @Nullable
  private Size previewSize;
  private CamcorderProfile recordingProfileLegacy;
  private EncoderProfiles recordingProfile;
  @NonNull
  private ResolutionPreset currentSetting;
  private int cameraId;
  @NonNull
  private CaptureMode captureMode;

  /**
   * Creates a new instance of the {@link ResolutionFeature}.
   *
   * @param cameraProperties Collection of characteristics for the current camera device.
   * @param resolutionPreset Platform agnostic enum containing resolution information.
   * @param cameraName       Camera identifier of the camera for which to configure the resolution.
   * @param captureMode      Capture mode to configure the appropriate resolution and aspect ratio.
   */
  public ResolutionFeature(
          @NonNull CameraProperties cameraProperties,
          @NonNull ResolutionPreset resolutionPreset,
          @NonNull String cameraName,
          @NonNull CaptureMode captureMode) {
    super(cameraProperties);
    this.currentSetting = resolutionPreset;
    this.captureMode = captureMode;
    try {
      this.cameraId = Integer.parseInt(cameraName, 10);
    } catch (NumberFormatException e) {
      this.cameraId = -1;
      return;
    }
    configureResolution(resolutionPreset, cameraId, captureMode, cameraProperties.getAvailableOutputSizes(ImageFormat.PRIVATE));
  }

  /**
   * Gets the {@link android.media.CamcorderProfile} containing the information to configure the
   * resolution using the {@link android.hardware.camera2} API.
   *
   * @return Resolution information to configure the {@link android.hardware.camera2} API.
   */
  @Nullable
  public CamcorderProfile getRecordingProfileLegacy() {
    return this.recordingProfileLegacy;
  }

  @Nullable
  public EncoderProfiles getRecordingProfile() {
    return this.recordingProfile;
  }

  /**
   * Gets the optimal preview size based on the configured resolution.
   *
   * @return The optimal preview size.
   */
  @Nullable
  public Size getPreviewSize() {
    return this.previewSize;
  }

  /**
   * Gets the optimal capture size based on the configured resolution.
   *
   * @return The optimal capture size.
   */
  @Nullable
  public Size getCaptureSize() {
    return this.captureSize;
  }

  @NonNull
  @Override
  public String getDebugName() {
    return "ResolutionFeature";
  }

  @SuppressLint("KotlinPropertyAccess")
  @NonNull
  @Override
  public ResolutionPreset getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(@NonNull ResolutionPreset value) {
    this.currentSetting = value;
    configureResolution(currentSetting, cameraId, captureMode, cameraProperties.getAvailableOutputSizes(ImageFormat.PRIVATE));
  }

  @Override
  public boolean checkIsSupported() {
    return cameraId >= 0;
  }

  @Override
  public void updateBuilder(@NonNull CaptureRequest.Builder requestBuilder) {
    // No-op: when setting a resolution there is no need to update the request builder.
  }

  @VisibleForTesting
  static Size computeBestPreviewSize(int cameraId, ResolutionPreset preset, CaptureMode captureMode, Size[] availableOutputSizes)
      throws IndexOutOfBoundsException {
    // Using max resolution for the preview is not a good use of system resources.
    // Limiting the max resolution used for the preview to 720p is a good balance.
    if (preset.ordinal() > ResolutionPreset.high.ordinal()) {
      preset = ResolutionPreset.high;
    }
    if (captureMode == CaptureMode.photo) {
      return getBestAvailableCameraSizeForResolutionPreset(preset, availableOutputSizes);
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      EncoderProfiles profile =
          getBestAvailableCamcorderProfileForResolutionPreset(cameraId, preset);
      List<EncoderProfiles.VideoProfile> videoProfiles = profile.getVideoProfiles();
      EncoderProfiles.VideoProfile defaultVideoProfile = videoProfiles.get(0);

      if (defaultVideoProfile != null) {
        return new Size(defaultVideoProfile.getWidth(), defaultVideoProfile.getHeight());
      }
    }

    // TODO(camsim99): Suppression is currently safe because legacy code is used as a fallback for SDK < S.
    // This should be removed when reverting that fallback behavior: https://github.com/flutter/flutter/issues/119668.
    CamcorderProfile profile =
        getBestAvailableCamcorderProfileForResolutionPresetLegacy(cameraId, preset);
    return new Size(profile.videoFrameWidth, profile.videoFrameHeight);
  }

  /**
   * Gets the best possible {@link android.media.CamcorderProfile} for the supplied {@link
   * ResolutionPreset}. Supports SDK < 31.
   *
   * @param cameraId Camera identifier which indicates the device's camera for which to select a
   *                 {@link android.media.CamcorderProfile}.
   * @param preset   The {@link ResolutionPreset} for which is to be translated to a {@link
   *                 android.media.CamcorderProfile}.
   * @return The best possible {@link android.media.CamcorderProfile} that matches the supplied
   * {@link ResolutionPreset}.
   */
  @TargetApi(Build.VERSION_CODES.R)
  // All of these cases deliberately fall through to get the best available profile.
  @SuppressWarnings({"fallthrough", "deprecation"})
  @NonNull
  public static CamcorderProfile getBestAvailableCamcorderProfileForResolutionPresetLegacy(
      int cameraId, @NonNull ResolutionPreset preset) {
    if (cameraId < 0) {
      throw new AssertionError(
          "getBestAvailableCamcorderProfileForResolutionPreset can only be used with valid (>=0) camera identifiers.");
    }

    switch (preset) {
      case max:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_HIGH)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_HIGH);
        }
        // fall through
      case ultraHigh:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_2160P);
        }
        // fall through
      case veryHigh:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P);
        }
        // fall through
      case high:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P);
        }
        // fall through
      case medium:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P);
        }
        // fall through
      case low:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA);
        }
        // fall through
      default:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
          return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW);
        } else {
          throw new IllegalArgumentException(
              "No capture session available for current capture session.");
        }
    }
  }

  @TargetApi(Build.VERSION_CODES.S)
  // All of these cases deliberately fall through to get the best available profile.
  @SuppressWarnings("fallthrough")
  @NonNull
  public static EncoderProfiles getBestAvailableCamcorderProfileForResolutionPreset(
      int cameraId, @NonNull ResolutionPreset preset) {
    if (cameraId < 0) {
      throw new AssertionError(
          "getBestAvailableCamcorderProfileForResolutionPreset can only be used with valid (>=0) camera identifiers.");
    }

    String cameraIdString = Integer.toString(cameraId);

    switch (preset) {
      case max:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_HIGH)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_HIGH);
        }
        // fall through
      case ultraHigh:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_2160P);
        }
        // fall through
      case veryHigh:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_1080P);
        }
        // fall through
      case high:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_720P);
        }
        // fall through
      case medium:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_480P);
        }
        // fall through
      case low:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_QVGA);
        }
        // fall through
      default:
        if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
          return CamcorderProfile.getAll(cameraIdString, CamcorderProfile.QUALITY_LOW);
        }

        throw new IllegalArgumentException(
            "No capture session available for current capture session.");
    }
  }

  // All of these cases deliberately fall through to get the best available camera profile.
  @SuppressWarnings("fallthrough")
  @NonNull
  public static Size getBestAvailableCameraSizeForResolutionPreset(@NonNull ResolutionPreset preset, Size[] availableOutputSizes) {
    List<Size> availableStandardOutputSizes = new ArrayList<>();
    for (Size outputSize : availableOutputSizes) {
      if ((Math.abs((double) outputSize.getWidth() / outputSize.getHeight() - (double)4 / 3) < 0.01)) {
        availableStandardOutputSizes.add(outputSize);
      }
    }
    Size selectedSize = null;
    switch (preset) {
      case max:
        selectedSize = selectPhotoCaptureSize(null, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        // fall through
      case ultraHigh:
        selectedSize = selectPhotoCaptureSize(2160, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        // fall through
      case veryHigh:
        selectedSize = selectPhotoCaptureSize(1080, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        // fall through
      case high:
        // Both 768 and 720 are common HD picture heights.
        selectedSize = selectPhotoCaptureSize(768, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        selectedSize = selectPhotoCaptureSize(720, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        // fall through
      case medium:
        selectedSize = selectPhotoCaptureSize(480, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        // fall through
      case low:
        selectedSize = selectPhotoCaptureSize(240, availableStandardOutputSizes);
        if (selectedSize != null) {
          return selectedSize;
        }
        // fall through
      default:
        // default to lowest available 4:3 resolution.
        if (availableStandardOutputSizes.size() > 0) {
          return availableStandardOutputSizes.get(availableStandardOutputSizes.size() - 1);
        }
        throw new IllegalArgumentException(
            "No capture session available for current capture session.");
    }
  }

  private static Size selectPhotoCaptureSize(Integer resolutionWidth, List<Size> availableStandardOutputSizes) {
    Size selectedPreviewResolution = null;
    int currentHighestPixel = 0;
    for (Size standardOutputSize : availableStandardOutputSizes) {
      // When no resolutionWidth is provided, the highest resolution should be selected.
      if ((resolutionWidth != null && standardOutputSize.getHeight() == resolutionWidth) || resolutionWidth == null) {
        if (standardOutputSize.getWidth() * standardOutputSize.getHeight() > currentHighestPixel) {
          selectedPreviewResolution = standardOutputSize;
          currentHighestPixel = standardOutputSize.getWidth() * standardOutputSize.getHeight();
        }
      }
    }
    return selectedPreviewResolution;
  }


  private void configureResolution(ResolutionPreset resolutionPreset, int cameraId, CaptureMode captureMode, Size[] availableOutputSizes)
      throws IndexOutOfBoundsException {
    if (!checkIsSupported()) {
      return;
    }
    // Attempt to select the highest resolution from the available ones when in photo mode.
    if (captureMode == CaptureMode.photo) {
      captureSize = getBestAvailableCameraSizeForResolutionPreset(resolutionPreset, availableOutputSizes);
    }

    if (captureSize == null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      boolean captureSizeCalculated = false;

      if (SdkCapabilityChecker.supportsEncoderProfiles()) {
        recordingProfileLegacy = null;
        recordingProfile =
            getBestAvailableCamcorderProfileForResolutionPreset(cameraId, resolutionPreset);
        List<EncoderProfiles.VideoProfile> videoProfiles = recordingProfile.getVideoProfiles();

        EncoderProfiles.VideoProfile defaultVideoProfile = videoProfiles.get(0);

        if (defaultVideoProfile != null) {
          captureSize = new Size(defaultVideoProfile.getWidth(), defaultVideoProfile.getHeight());
        }
      }
    }

    if (captureSize == null) {
      recordingProfile = null;
      CamcorderProfile camcorderProfile =
          getBestAvailableCamcorderProfileForResolutionPresetLegacy(cameraId, resolutionPreset);
      recordingProfileLegacy = camcorderProfile;
      captureSize =
          new Size(recordingProfileLegacy.videoFrameWidth, recordingProfileLegacy.videoFrameHeight);
    }

    previewSize = computeBestPreviewSize(cameraId, resolutionPreset, captureMode, availableOutputSizes);
  }
}
