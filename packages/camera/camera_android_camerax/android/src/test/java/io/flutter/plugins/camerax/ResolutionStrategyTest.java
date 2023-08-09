// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import android.util.Size;
import androidx.camera.core.resolutionselector.ResolutionStrategy;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ResolutionStrategyTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public ResolutionStrategy mockResolutionStrategy;
  @Mock public ResolutionStrategyHostApiImpl.ResolutionStrategyProxy mockProxy;

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
  public void hostApiCreate_createsExpectedResolutionStrategyInstanceWhenArgumentsValid() {
    final GeneratedCameraXLibrary.ResolutionInfo boundSize =
        new GeneratedCameraXLibrary.ResolutionInfo.Builder().setWidth(50L).setHeight(30L).build();

    final Long fallbackRule = 0L;

    when(mockProxy.create(any(Size.class), eq(fallbackRule))).thenReturn(mockResolutionStrategy);

    final ResolutionStrategyHostApiImpl hostApi =
        new ResolutionStrategyHostApiImpl(instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier, boundSize, fallbackRule);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockResolutionStrategy);
  }

  @Test
  public void hostApiCreate_throwsAssertionErrorWhenArgumentsInvalid() {
    final Long fallbackRule = 8L;
    final long instanceIdentifier = 0;

    final ResolutionStrategyHostApiImpl hostApi =
        new ResolutionStrategyHostApiImpl(instanceManager, mockProxy);

    // We expect an exception to be thrown if fallback rule is specified but bound size is not.
    assertThrows(
        IllegalArgumentException.class,
        () -> hostApi.create(instanceIdentifier, null, fallbackRule));
  }
}
