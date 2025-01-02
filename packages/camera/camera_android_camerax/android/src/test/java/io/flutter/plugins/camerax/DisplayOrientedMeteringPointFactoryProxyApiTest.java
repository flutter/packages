// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.DisplayOrientedMeteringPointFactory
import androidx.camera.core.CameraInfo
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class DisplayOrientedMeteringPointFactoryProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiDisplayOrientedMeteringPointFactory api = new TestProxyApiRegistrar().getPigeonApiDisplayOrientedMeteringPointFactory();

    assertTrue(api.pigeon_defaultConstructor(mock(CameraInfo.class), 1.0, 1.0) instanceof DisplayOrientedMeteringPointFactoryProxyApi.DisplayOrientedMeteringPointFactory);
  }

}
