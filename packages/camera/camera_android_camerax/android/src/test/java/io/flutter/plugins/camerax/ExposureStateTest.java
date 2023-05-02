// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.util.Range;
import android.util.Rational;
import androidx.camera.core.ExposureState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureCompensationRange;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class ExposureStateTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public ExposureState mockExposureState;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Config(sdk = 21)
  @Test
  public void create_makesExpectedCallToCreateInstanceOnDartSide() {
    // SDK version configured because ExposureState requires Android 21.
    ExposureStateFlutterApiImpl exposureStateFlutterApiImpl =
        spy(new ExposureStateFlutterApiImpl(mockBinaryMessenger, testInstanceManager));
    final int minExposureCompensation = 0;
    final int maxExposureCompensation = 1;
    Range<Integer> testExposueCompensationRange =
        new Range<Integer>(minExposureCompensation, maxExposureCompensation);
    Rational textExposureCompensationStep = new Rational(1, 5); // Makes expected Double value 0.2.

    when(mockExposureState.getExposureCompensationRange()).thenReturn(testExposueCompensationRange);
    when(mockExposureState.getExposureCompensationStep()).thenReturn(textExposureCompensationStep);

    final ArgumentCaptor<ExposureCompensationRange> exposureCompensationRangeCaptor =
        ArgumentCaptor.forClass(ExposureCompensationRange.class);

    exposureStateFlutterApiImpl.create(mockExposureState, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(mockExposureState));
    verify(exposureStateFlutterApiImpl)
        .create(eq(identifier), exposureCompensationRangeCaptor.capture(), eq(0.2), any());

    ExposureCompensationRange exposureCompensationRange =
        exposureCompensationRangeCaptor.getValue();
    assertEquals(
        exposureCompensationRange.getMinCompensation().intValue(), minExposureCompensation);
    assertEquals(
        exposureCompensationRange.getMaxCompensation().intValue(), maxExposureCompensation);
  }
}
