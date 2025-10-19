// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class ImageProxyTest {
  @Test
  public void format_returnsExpectedFormat() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final long value = 0;
    when(instance.getFormat()).thenReturn((int) value);

    assertEquals(value, api.format(instance));
  }

  @Test
  public void width_returnsExpectedWidth() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final long value = 0;
    when(instance.getWidth()).thenReturn((int) value);

    assertEquals(value, api.width(instance));
  }

  @Test
  public void height_returnsExpectedHeight() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final long value = 0;
    when(instance.getHeight()).thenReturn((int) value);

    assertEquals(value, api.height(instance));
  }

  @Test
  public void getPlanes_returnsExpectedPlanes() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    final List<PlaneProxy> value = Collections.singletonList(mock(PlaneProxy.class));
    when(instance.getPlanes()).thenReturn(value.toArray(new PlaneProxy[] {}));

    assertEquals(value, api.getPlanes(instance));
  }

  @Test
  public void close_callsCloseOnInstance() {
    final PigeonApiImageProxy api = new TestProxyApiRegistrar().getPigeonApiImageProxy();

    final ImageProxy instance = mock(ImageProxy.class);
    api.close(instance);

    verify(instance).close();
  }
}
