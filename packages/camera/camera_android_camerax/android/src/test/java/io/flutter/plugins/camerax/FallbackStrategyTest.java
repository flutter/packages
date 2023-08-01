
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FallbackStrategyFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class FallbackStrategyTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public FallbackStrategy mockFallbackStrategy;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public FallbackStrategyFlutterApi mockFlutterApi;
  @Mock public FallbackStrategyHostApiImpl.FallbackStrategyProxy mockProxy;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void hostApiCreate_makesCallToCreateExpectedFallbackStrategy() {
    final FallbackStrategyHostApiImpl hostApi =
    new FallbackStrategyHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);
    final long instanceIdentifier = 45;
    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<FallbackStrategy> mockedFallbackStrategy =
      mockStatic(FallbackStrategy.class)) {
      for (QualityConstraint quality : QualityConstraint.values()) {
        for (VideoResolutionFallbackRule fallbackRule : VideoResolutionFallbackRule.values()) {
          // Determine expected Quality based on QualityConstraint.
          Quality expectedQuality;
          switch (quality) {
            case SD:
              expectedQuality = Quality.SD;
              break;
            case HD:
              expectedQuality =  Quality.HD;
              break;
            case FHD:
              expectedQuality =  Quality.FHD;
              break;
            case UHD:
              expectedQuality =  Quality.UHD;
              break;
            case LOWEST:
              expectedQuality =  Quality.LOWEST;
              break;
            case HIGHEST:
              expectedQuality =  Quality.HIGHEST;
              break;
            default:
              fail(
              "The QualityConstraint "
                  + quality.toString()
                  + "is unhandled by this test.");
          }
          // Mock calls to create FallbackStrategy according to fallbackRule being tested.
          switch(fallbackRule) {
            case HIGHER_QUALITY_OR_LOWER_THAN:
              mockedFallbackStrategy
                .when(() -> FallbackStrategy.higherQualityOrLowerThan(expectedQuality))
                .thenAnswer(
                    (Answer<FallbackStrategy>)
                        invocation -> mockFallbackStrategy);
              break;
            case HIGHER_QUALITY_THAN:
              mockedFallbackStrategy
                .when(() -> FallbackStrategy.higherQualityThan(expectedQuality))
                .thenAnswer(
                    (Answer<FallbackStrategy>)
                        invocation -> mockFallbackStrategy);
              break;
            case LOWER_QUALITY_OR_HIGHER_THAN:
              mockedFallbackStrategy
                .when(() -> FallbackStrategy.lowerQualityOrHigherThan(expectedQuality))
                .thenAnswer(
                    (Answer<FallbackStrategy>)
                        invocation -> mockFallbackStrategy);
              break;
            case LOWER_QUALITY_THAN:
              mockedFallbackStrategy
                .when(() -> FallbackStrategy.lowerQualityThan(expectedQuality))
                .thenAnswer(
                    (Answer<FallbackStrategy>)
                        invocation -> mockFallbackStrategy);
              break;
            default:
              fail(
              "The VideoResolutionFallbackRule "
                  + fallbackRule.toString()
                  + "is unhandled by this test.");
          }
          hostApi.create(instanceIdentifier, quality, fallbackRule);
          assertEquals(instanceManager.getInstance(instanceIdentifier), mockFallbackStrategy);

          // Clear FallbackStrategy mock and InstanceManager.
          mockedFallbackStrategy.clear();
          instanceManager.clear();
        }
      }
    }
  }
}
