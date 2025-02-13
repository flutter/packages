// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.camera2.interop.Camera2CameraControl;
import androidx.camera.core.CameraControl;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import static org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class Camera2CameraControlProxyApiTest {
  @Test
  public void addCaptureRequestOptions() {
    final PigeonApiCamera2CameraControl api = new TestProxyApiRegistrar().getPigeonApiCamera2CameraControl();

    final Camera2CameraControl instance = mock(Camera2CameraControl.class);
    final androidx.camera.camera2.interop.CaptureRequestOptions bundle = mock(CaptureRequestOptions.class);
    api.addCaptureRequestOptions(instance, bundle, null);

    verify(instance).addCaptureRequestOptions(bundle);
  }
}
