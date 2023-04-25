// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.verify;

import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.ExposureState;
import androidx.camera.core.ZoomState;
import android.util.Range;
import android.util.Rational;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ZoomStateTest {
    @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

    @Mock public BinaryMessenger mockBinaryMessenger;
    @Mock public ZoomState mockZoomState;
  
    InstanceManager testInstanceManager;
  
    @Before
    public void setUp() {
      testInstanceManager = InstanceManager.create(identifier -> {});
    }
  
    @After
    public void tearDown() {
      testInstanceManager.stopFinalizationListener();
    }
    

    @Test
    public void create_makesExpectedCallToCreateInstanceOnDartSide() {
      ZoomStateFlutterApiImpl zoomStateFlutterApiImpl = spy(new ZoomStateFlutterApiImpl(mockBinaryMessenger, testInstanceManager));
      final Float testMinZoomRatio = 0F;
      final Float testMaxZoomRatio = 1F;

      when(mockZoomState.getMinZoomRatio()).thenReturn(testMinZoomRatio);
      when(mockZoomState.getMaxZoomRatio()).thenReturn(testMaxZoomRatio);

      zoomStateFlutterApiImpl.create(mockZoomState, reply -> {});

      final long identifier =
      Objects.requireNonNull(testInstanceManager.getIdentifierForStrongReference(mockZoomState));
      verify(zoomStateFlutterApiImpl).create(eq(identifier), eq(testMinZoomRatio.doubleValue()), eq(testMaxZoomRatio.doubleValue()), any());
    }  
}
