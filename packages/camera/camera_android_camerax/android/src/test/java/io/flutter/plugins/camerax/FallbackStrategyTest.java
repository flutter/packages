
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
  public void hostApiCreate() {

    final Quality quality = Quality.SOME_ENUM_VALUE;

    final VideoResolutionFallbackRule fallbackRule = VideoResolutionFallbackRule.SOME_ENUM_VALUE;

    when(mockProxy.create(quality, fallbackRule)).thenReturn(mockFallbackStrategy);

    final FallbackStrategyHostApiImpl hostApi =
        new FallbackStrategyHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier, quality, fallbackRule);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockFallbackStrategy);
  }

  @Test
  public void flutterApiCreate() {
    final FallbackStrategyFlutterApiImpl flutterApi =
        new FallbackStrategyFlutterApiImpl(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final Quality quality = Quality.SOME_ENUM_VALUE;

    final VideoResolutionFallbackRule fallbackRule = VideoResolutionFallbackRule.SOME_ENUM_VALUE;

    flutterApi.create(mockFallbackStrategy, quality, fallbackRule, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockFallbackStrategy));
    verify(mockFlutterApi).create(eq(instanceIdentifier), eq(quality), eq(fallbackRule), any());
  }
}
