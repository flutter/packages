// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;

import androidx.camera.video.FallbackStrategy;
import androidx.camera.video.Quality;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;

public class FallbackStrategyTest {
  @Test
  public void higherQualityOrLowerThan() {
    final PigeonApiFallbackStrategy api =
        new TestProxyApiRegistrar().getPigeonApiFallbackStrategy();

    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<FallbackStrategy> mockedFallbackStrategy =
        Mockito.mockStatic(FallbackStrategy.class)) {
      final Quality quality = Quality.HD;
      mockedFallbackStrategy
          .when(() -> FallbackStrategy.higherQualityOrLowerThan(quality))
          .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);

      assertEquals(api.higherQualityOrLowerThan(VideoQuality.HD), mockFallbackStrategy);
    }
  }

  @Test
  public void higherQualityThan() {
    final PigeonApiFallbackStrategy api =
        new TestProxyApiRegistrar().getPigeonApiFallbackStrategy();

    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<FallbackStrategy> mockedFallbackStrategy =
        Mockito.mockStatic(FallbackStrategy.class)) {
      final Quality quality = Quality.HD;
      mockedFallbackStrategy
          .when(() -> FallbackStrategy.higherQualityThan(quality))
          .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);

      assertEquals(api.higherQualityThan(VideoQuality.HD), mockFallbackStrategy);
    }
  }

  @Test
  public void lowerQualityOrHigherThan() {
    final PigeonApiFallbackStrategy api =
        new TestProxyApiRegistrar().getPigeonApiFallbackStrategy();

    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<FallbackStrategy> mockedFallbackStrategy =
        Mockito.mockStatic(FallbackStrategy.class)) {
      final Quality quality = Quality.HD;
      mockedFallbackStrategy
          .when(() -> FallbackStrategy.lowerQualityOrHigherThan(quality))
          .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);

      assertEquals(api.lowerQualityOrHigherThan(VideoQuality.HD), mockFallbackStrategy);
    }
  }

  @Test
  public void lowerQualityThan() {
    final PigeonApiFallbackStrategy api =
        new TestProxyApiRegistrar().getPigeonApiFallbackStrategy();

    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);

    try (MockedStatic<FallbackStrategy> mockedFallbackStrategy =
        Mockito.mockStatic(FallbackStrategy.class)) {
      final Quality quality = Quality.HD;
      mockedFallbackStrategy
          .when(() -> FallbackStrategy.lowerQualityThan(quality))
          .thenAnswer((Answer<FallbackStrategy>) invocation -> mockFallbackStrategy);

      assertEquals(api.lowerQualityThan(VideoQuality.HD), mockFallbackStrategy);
    }
  }
}
