// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import android.util.Size;
import androidx.camera.core.CameraInfo;
import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import androidx.camera.video.QualitySelector;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQuality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQualityData;
import java.util.Arrays;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;

public class QualitySelectorTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public QualitySelector mockQualitySelectorWithoutFallbackStrategy;
  @Mock public QualitySelector mockQualitySelectorWithFallbackStrategy;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void hostApiCreate_createsExpectedQualitySelectorWhenOneQualitySpecified() {
    final VideoQualityData expectedVideoQualityData =
        new VideoQualityData.Builder().setQuality(VideoQuality.UHD).build();
    final List<VideoQualityData> videoQualityDataList = Arrays.asList(expectedVideoQualityData);
    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);
    final long fallbackStrategyIdentifier = 9;
    final QualitySelectorHostApiImpl hostApi = new QualitySelectorHostApiImpl(instanceManager);

    instanceManager.addDartCreatedInstance(mockFallbackStrategy, fallbackStrategyIdentifier);

    try (MockedStatic<QualitySelector> mockedQualitySelector = mockStatic(QualitySelector.class)) {
      mockedQualitySelector
          .when(() -> QualitySelector.from(Quality.UHD))
          .thenAnswer(
              (Answer<QualitySelector>) invocation -> mockQualitySelectorWithoutFallbackStrategy);
      mockedQualitySelector
          .when(() -> QualitySelector.from(Quality.UHD, mockFallbackStrategy))
          .thenAnswer(
              (Answer<QualitySelector>) invocation -> mockQualitySelectorWithFallbackStrategy);

      // Test with no fallback strategy.
      long instanceIdentifier = 0;
      hostApi.create(instanceIdentifier, videoQualityDataList, null);

      assertEquals(
          instanceManager.getInstance(instanceIdentifier),
          mockQualitySelectorWithoutFallbackStrategy);

      // Test with fallback strategy.
      instanceIdentifier = 1;
      hostApi.create(instanceIdentifier, videoQualityDataList, fallbackStrategyIdentifier);

      assertEquals(
          instanceManager.getInstance(instanceIdentifier), mockQualitySelectorWithFallbackStrategy);
    }
  }

  @Test
  public void hostApiCreate_createsExpectedQualitySelectorWhenOrderedListOfQualitiesSpecified() {
    final List<VideoQualityData> videoQualityDataList =
        Arrays.asList(
            new VideoQualityData.Builder().setQuality(VideoQuality.UHD).build(),
            new VideoQualityData.Builder().setQuality(VideoQuality.HIGHEST).build());
    final List<Quality> expectedVideoQualityList = Arrays.asList(Quality.UHD, Quality.HIGHEST);
    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);
    final long fallbackStrategyIdentifier = 9;
    final QualitySelectorHostApiImpl hostApi = new QualitySelectorHostApiImpl(instanceManager);

    instanceManager.addDartCreatedInstance(mockFallbackStrategy, fallbackStrategyIdentifier);

    try (MockedStatic<QualitySelector> mockedQualitySelector = mockStatic(QualitySelector.class)) {
      mockedQualitySelector
          .when(() -> QualitySelector.fromOrderedList(expectedVideoQualityList))
          .thenAnswer(
              (Answer<QualitySelector>) invocation -> mockQualitySelectorWithoutFallbackStrategy);
      mockedQualitySelector
          .when(
              () -> QualitySelector.fromOrderedList(expectedVideoQualityList, mockFallbackStrategy))
          .thenAnswer(
              (Answer<QualitySelector>) invocation -> mockQualitySelectorWithFallbackStrategy);

      // Test with no fallback strategy.
      long instanceIdentifier = 0;
      hostApi.create(instanceIdentifier, videoQualityDataList, null);

      assertEquals(
          instanceManager.getInstance(instanceIdentifier),
          mockQualitySelectorWithoutFallbackStrategy);

      // Test with fallback strategy.
      instanceIdentifier = 1;
      hostApi.create(instanceIdentifier, videoQualityDataList, fallbackStrategyIdentifier);

      assertEquals(
          instanceManager.getInstance(instanceIdentifier), mockQualitySelectorWithFallbackStrategy);
    }
  }

  @Test
  public void getResolution_returnsExpectedResolutionInfo() {
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);
    final long cameraInfoIdentifier = 6;
    final VideoQuality videoQuality = VideoQuality.FHD;
    final Size sizeResult = new Size(30, 40);
    final QualitySelectorHostApiImpl hostApi = new QualitySelectorHostApiImpl(instanceManager);

    instanceManager.addDartCreatedInstance(mockCameraInfo, cameraInfoIdentifier);

    try (MockedStatic<QualitySelector> mockedQualitySelector = mockStatic(QualitySelector.class)) {
      mockedQualitySelector
          .when(() -> QualitySelector.getResolution(mockCameraInfo, Quality.FHD))
          .thenAnswer((Answer<Size>) invocation -> sizeResult);

      final ResolutionInfo result = hostApi.getResolution(cameraInfoIdentifier, videoQuality);

      assertEquals(result.getWidth(), Long.valueOf(sizeResult.getWidth()));
      assertEquals(result.getHeight(), Long.valueOf(sizeResult.getHeight()));
    }
  }
}
