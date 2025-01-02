// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.core.ImageProxy
import androidx.camera.core.ImageProxy.PlaneProxy
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

public class ImageProxyProxyApiTest {
  @Test
  public void format() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final Long value = 0;
    when(instance.getFormat()).thenReturn(value);

    assertEquals(value, api.format(instance));
  }

  @Test
  public void width() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final Long value = 0;
    when(instance.getWidth()).thenReturn(value);

    assertEquals(value, api.width(instance));
  }

  @Test
  public void height() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final Long value = 0;
    when(instance.getHeight()).thenReturn(value);

    assertEquals(value, api.height(instance));
  }

  @Test
  public void getPlanes() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final List<androidx.camera.core.ImageProxy.PlaneProxy> value = Arrays.asList(mock(PlaneProxy.class));
    when(instance.getPlanes()).thenReturn(value);

    assertEquals(value, api.getPlanes(instance ));
  }

  @Test
  public void close() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    api.close(instance );

    verify(instance).close();
  }

}
