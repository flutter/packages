// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.QualitySelectorFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class QualitySelectorTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
  @Mock public QualitySelector mockQualitySelector;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public QualitySelectorFlutterApi mockFlutterApi;
  @Mock public QualitySelectorHostApiImpl.QualitySelectorProxy mockProxy;

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
  public void hostApiCreate_createsExpectedQualitySelectorWhenOneQualitySpecified() {
    final List qualityList = Arrays.asList(QualityConstraint.UHD);
    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);
    final long fallbackStrategyIdentifier = 9;
    final QualitySelectorHostApiImpl hostApi =
    new QualitySelectorHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    instanceManager.addDartCreatedInstance(mockFallbackStrategy, fallbackStrategyIdentifier);

    try (MockedStatic<QualitySelector> mockedQualitySelector =
      mockStatic(QualitySelector.class)) {
        
      }

    // Test with no fallback strategy.
    final long instanceIdentifier = 0;
    hostApi.createFrom(instanceIdentifier, quality, fallbackStrategyIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockQualitySelector);

    // Test with fallback strategy.
  }

  @Test
  public void hostApiCreate_createsExpectedQualitySelectorWhenOrderedListOfQualitiesSpecified() {

    final List qualityList = new ArrayList<Object>();

    final FallbackStrategy mockFallbackStrategy = mock(FallbackStrategy.class);
    final long fallbackStrategyIdentifier = 11;
    instanceManager.addDartCreatedInstance(mockFallbackStrategy, fallbackStrategyIdentifier);

    when(mockProxy.createFromOrderedList(qualityList, mockFallbackStrategy))
        .thenReturn(mockQualitySelector);
    final QualitySelectorHostApiImpl hostApi =
        new QualitySelectorHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.createFromOrderedList(instanceIdentifier, qualityList, fallbackStrategyIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockQualitySelector);
  }

  @Test
  public void getResolution() {

    final InvalidType mockCameraInfo = mock(InvalidType.class);
    final long cameraInfoIdentifier = 6;
    instanceManager.addDartCreatedInstance(mockCameraInfo, cameraInfoIdentifier);

    final Quality quality = Quality.SOME_ENUM_VALUE;

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockQualitySelector, instanceIdentifier);

    final Size returnValue = mock(Size.class);

    when(mockQualitySelector.getResolution(instanceIdentifier, mockcameraInfo, quality))
        .thenReturn(returnValue);

    final QualitySelectorHostApiImpl hostApi =
        new QualitySelectorHostApiImpl(mockBinaryMessenger, instanceManager);

    final Long result = hostApi.getResolution(instanceIdentifier, cameraInfoIdentifier, quality);

    verify(mockQualitySelector).getResolution(mockCameraInfo, quality);

    assertEquals(result, instanceManager.getIdentifierForStrongReference(returnValue));
  }
}
