//// Copyright 2013 The Flutter Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//package io.flutter.plugins.camerax
//
//import androidx.camera.core.resolutionselector.ResolutionStrategy
//import android.util.Size
//import org.junit.Test;
//import static org.junit.Assert.assertEquals;
//import static org.junit.Assert.assertTrue;
//import org.mockito.Mockito;
//import org.mockito.Mockito.any;
//import java.util.HashMap;
//import static org.mockito.Mockito.eq;
//import static org.mockito.Mockito.mock;
//import org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//public class ResolutionStrategyProxyApiTest {
//  @Test
//  public void pigeon_defaultConstructor() {
//    final PigeonApiResolutionStrategy api = new TestProxyApiRegistrar().getPigeonApiResolutionStrategy();
//
//    assertTrue(api.pigeon_defaultConstructor(mock(CameraSize.class), io.flutter.plugins.camerax.ResolutionStrategyFallbackRule.CLOSEST_HIGHER) instanceof ResolutionStrategyProxyApi.ResolutionStrategy);
//  }
//
//  @Test
//  public void getBoundSize() {
//    final PigeonApiResolutionStrategy api = new TestProxyApiRegistrar().getPigeonApiResolutionStrategy();
//
//    final ResolutionStrategy instance = mock(ResolutionStrategy.class);
//    final android.util.Size value = mock(CameraSize.class);
//    when(instance.getBoundSize()).thenReturn(value);
//
//    assertEquals(value, api.getBoundSize(instance ));
//  }
//
//  @Test
//  public void getFallbackRule() {
//    final PigeonApiResolutionStrategy api = new TestProxyApiRegistrar().getPigeonApiResolutionStrategy();
//
//    final ResolutionStrategy instance = mock(ResolutionStrategy.class);
//    final ResolutionStrategyFallbackRule value = io.flutter.plugins.camerax.ResolutionStrategyFallbackRule.CLOSEST_HIGHER;
//    when(instance.getFallbackRule()).thenReturn(value);
//
//    assertEquals(value, api.getFallbackRule(instance ));
//  }
//
//}
