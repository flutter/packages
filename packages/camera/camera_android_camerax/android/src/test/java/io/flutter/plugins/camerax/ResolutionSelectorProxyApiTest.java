//// Copyright 2013 The Flutter Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//package io.flutter.plugins.camerax
//
//import androidx.camera.core.resolutionselector.ResolutionSelector
//import androidx.camera.core.resolutionselector.AspectRatioStrategy
//import androidx.camera.core.resolutionselector.ResolutionFilter
//import androidx.camera.core.resolutionselector.ResolutionStrategy
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
//public class ResolutionSelectorProxyApiTest {
//  @Test
//  public void pigeon_defaultConstructor() {
//    final PigeonApiResolutionSelector api = new TestProxyApiRegistrar().getPigeonApiResolutionSelector();
//
//    assertTrue(api.pigeon_defaultConstructor(mock(AspectRatioStrategy.class)) instanceof ResolutionSelectorProxyApi.ResolutionSelector);
//  }
//
//  @Test
//  public void resolutionFilter() {
//    final PigeonApiResolutionSelector api = new TestProxyApiRegistrar().getPigeonApiResolutionSelector();
//
//    final ResolutionSelector instance = mock(ResolutionSelector.class);
//    final androidx.camera.core.resolutionselector.ResolutionFilter value = mock(ResolutionFilter.class);
//    when(instance.getResolutionFilter()).thenReturn(value);
//
//    assertEquals(value, api.resolutionFilter(instance));
//  }
//
//  @Test
//  public void resolutionStrategy() {
//    final PigeonApiResolutionSelector api = new TestProxyApiRegistrar().getPigeonApiResolutionSelector();
//
//    final ResolutionSelector instance = mock(ResolutionSelector.class);
//    final androidx.camera.core.resolutionselector.ResolutionStrategy value = mock(ResolutionStrategy.class);
//    when(instance.getResolutionStrategy()).thenReturn(value);
//
//    assertEquals(value, api.resolutionStrategy(instance));
//  }
//
//  @Test
//  public void getAspectRatioStrategy() {
//    final PigeonApiResolutionSelector api = new TestProxyApiRegistrar().getPigeonApiResolutionSelector();
//
//    final ResolutionSelector instance = mock(ResolutionSelector.class);
//    final androidx.camera.core.resolutionselector.AspectRatioStrategy value = mock(AspectRatioStrategy.class);
//    when(instance.getAspectRatioStrategy()).thenReturn(value);
//
//    assertEquals(value, api.getAspectRatioStrategy(instance ));
//  }
//
//}
