// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.camera2.interop.CaptureRequestOptions
import android.hardware.camera2.CaptureRequest.Key<*>
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

public class CaptureRequestOptionsProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiCaptureRequestOptions api = new TestProxyApiRegistrar().getPigeonApiCaptureRequestOptions();

    assertTrue(api.pigeon_defaultConstructor(new HashMap<String, String>() {{put(mock(CaptureRequestKey.class), -1)}}) instanceof CaptureRequestOptionsProxyApi.CaptureRequestOptions);
  }

}
