// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoQuality;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoResolutionFallbackRule;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;

public class FallbackStrategyTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public FallbackStrategy mockFallbackStrategy;

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
  public void hostApiCreate_makesCallToCreateExpectedFallbackStrategy() {
    final FallbackStrategyHostApiImpl hostApi = new FallbackStrategyHostApiImpl(instanceManager);
    final long instanceIdentifier = 45;
    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<FallbackStrategy> mockedFallbackStrategy =
        mockStatic(FallbackStrategy.class)) {
      for (VideoQuality videoQuality : VideoQuality.values()) {
        for (VideoResolutionFallbackRule fallbackRule : VideoResolutionFallbackRule.values()) {
          // Determine expected Quality based on videoQuality being tested.
          Quality convertedQuality = null;
          switch (videoQuality) {
            case SD:
              convertedQuality = Quality.SD;
              break;
            case HD:
              convertedQuality = Quality.HD;
              break;
            case FHD:
              convertedQuality = Quality.FHD;
              break;
            case UHD:
              convertedQuality = Quality.UHD;
              break;
            case LOWEST:
              convertedQuality = Quality.LOWEST;
              break;
            case HIGHEST:
              convertedQuality = Quality.HIGHEST;
              break;
            default:
              fail("The VideoQuality " + videoQuality.toString() + "is unhandled by this test.");
          }
          // Set Quality as final local variable to avoid error about using non-final (or effecitvely final) local variables in lambda expressions.
          final Quality expectedQuality = convertedQuality;

          // Mock calls to create FallbackStrategy according to fallbackRule being tested.
          switch (fallbackRule) {
            case HIGHER_QUALITY_OR_LOWER_THAN:
              mockedFallbackStrategy
                  .when(() -> FallbackStrategy.higherQualityOrLowerThan(expectedQuality))
                  .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);
              break;
            case HIGHER_QUALITY_THAN:
              mockedFallbackStrategy
                  .when(() -> FallbackStrategy.higherQualityThan(expectedQuality))
                  .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);
              break;
            case LOWER_QUALITY_OR_HIGHER_THAN:
              mockedFallbackStrategy
                  .when(() -> FallbackStrategy.lowerQualityOrHigherThan(expectedQuality))
                  .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);
              break;
            case LOWER_QUALITY_THAN:
              mockedFallbackStrategy
                  .when(() -> FallbackStrategy.lowerQualityThan(expectedQuality))
                  .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);
              break;
            default:
              fail(
                  "The VideoResolutionFallbackRule "
                      + fallbackRule.toString()
                      + "is unhandled by this test.");
          }
          hostApi.create(instanceIdentifier, videoQuality, fallbackRule);
          assertEquals(instanceManager.getInstance(instanceIdentifier), mockFallbackStrategy);

          // Clear/reset FallbackStrategy mock and InstanceManager.
          mockedFallbackStrategy.reset();
          instanceManager.clear();
        }
      }
    }
  }
}
