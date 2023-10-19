// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.when;

import androidx.camera.core.resolutionselector.AspectRatioStrategy;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class AspectRatioStrategyTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public AspectRatioStrategy mockAspectRatioStrategy;
  @Mock public AspectRatioStrategyHostApiImpl.AspectRatioStrategyProxy mockProxy;

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
  public void hostApiCreate_createsExpectedAspectRatioStrategyInstance() {
    final Long preferredAspectRatio = 0L;
    final Long fallbackRule = 1L;

    when(mockProxy.create(preferredAspectRatio, fallbackRule)).thenReturn(mockAspectRatioStrategy);

    final AspectRatioStrategyHostApiImpl hostApi =
        new AspectRatioStrategyHostApiImpl(instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier, preferredAspectRatio, fallbackRule);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockAspectRatioStrategy);
  }
}
