// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ResolutionSelectorTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public ResolutionSelector mockResolutionSelector;
  @Mock public ResolutionSelectorHostApiImpl.ResolutionSelectorProxy mockProxy;

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
  public void hostApiCreate_createsExpectedResolutionSelectorInstance() {
    final ResolutionStrategy mockResolutionStrategy = mock(ResolutionStrategy.class);
    final long resolutionStrategyIdentifier = 14;
    instanceManager.addDartCreatedInstance(mockResolutionStrategy, resolutionStrategyIdentifier);

    final AspectRatioStrategy mockAspectRatioStrategy = mock(AspectRatioStrategy.class);
    final long aspectRatioStrategyIdentifier = 15;
    instanceManager.addDartCreatedInstance(mockAspectRatioStrategy, aspectRatioStrategyIdentifier);

    final ResolutionFilter mockResolutionFilter = mock(ResolutionFilter.class);
    final long resolutionFilterIdentifier = 33;
    instanceManager.addDartCreatedInstance(mockResolutionFilter, resolutionFilterIdentifier);

    when(mockProxy.create(mockResolutionStrategy, mockAspectRatioStrategy, mockResolutionFilter))
        .thenReturn(mockResolutionSelector);
    final ResolutionSelectorHostApiImpl hostApi =
        new ResolutionSelectorHostApiImpl(instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(
        instanceIdentifier,
        resolutionStrategyIdentifier,
        resolutionFilterIdentifier,
        aspectRatioStrategyIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockResolutionSelector);
  }
}
