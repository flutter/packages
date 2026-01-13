// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;

import android.util.Size;
import androidx.camera.core.CameraInfo;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import androidx.camera.video.QualitySelector;
import java.util.Collections;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;

public class QualitySelectorTest {
  @Test
  public void from_createsExpectedQualitySelectorWhenOneQualitySpecified() {
    final PigeonApiQualitySelector api = new TestProxyApiRegistrar().getPigeonApiQualitySelector();

    final QualitySelector mockQualitySelector = mock(QualitySelector.class);
    final FallbackStrategy fallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<QualitySelector> mockedQualitySelector =
        Mockito.mockStatic(QualitySelector.class)) {
      mockedQualitySelector
          .when(() -> QualitySelector.from(Quality.HD, fallbackStrategy))
          .thenAnswer((Answer<QualitySelector>) invocation -> mockQualitySelector);

      assertEquals(api.from(VideoQuality.HD, fallbackStrategy), mockQualitySelector);
    }
  }

  @Test
  public void fromOrderedList_createsExpectedQualitySelectorWhenOrderedListOfQualitiesSpecified() {
    final PigeonApiQualitySelector api = new TestProxyApiRegistrar().getPigeonApiQualitySelector();

    final QualitySelector mockQualitySelector = mock(QualitySelector.class);
    final FallbackStrategy fallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<QualitySelector> mockedQualitySelector =
        Mockito.mockStatic(QualitySelector.class)) {
      mockedQualitySelector
          .when(
              () ->
                  QualitySelector.fromOrderedList(
                      Collections.singletonList(Quality.SD), fallbackStrategy))
          .thenAnswer((Answer<QualitySelector>) invocation -> mockQualitySelector);

      assertEquals(
          api.fromOrderedList(Collections.singletonList(VideoQuality.SD), fallbackStrategy),
          mockQualitySelector);
    }
  }

  @Test
  public void getResolution_returnsExpectedResolutionInfo() {
    final PigeonApiQualitySelector api = new TestProxyApiRegistrar().getPigeonApiQualitySelector();

    final CameraInfo cameraInfo = mock(CameraInfo.class);

    try (MockedStatic<QualitySelector> mockedQualitySelector =
        Mockito.mockStatic(QualitySelector.class)) {
      final Size value = new Size(1, 2);
      mockedQualitySelector
          .when(() -> QualitySelector.getResolution(cameraInfo, Quality.UHD))
          .thenAnswer((Answer<Size>) invocation -> value);

      assertEquals(api.getResolution(cameraInfo, VideoQuality.UHD), value);
    }
  }
}
