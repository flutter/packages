// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class FlutterAssetManagerTest {
  @Test
  public void list() throws IOException {
    final PigeonApiFlutterAssetManager api =
        new TestProxyApiRegistrar().getPigeonApiFlutterAssetManager();

    final FlutterAssetManager instance = mock(FlutterAssetManager.class);
    final String path = "myString";
    final List<String> value = Collections.singletonList("myString");
    when(instance.list(path)).thenReturn(value.toArray(new String[0]));

    assertEquals(value, api.list(instance, path));
  }

  @Test
  public void list_returns_empty_list_when_no_results() throws IOException {
    final PigeonApiFlutterAssetManager api =
        new TestProxyApiRegistrar().getPigeonApiFlutterAssetManager();

    final FlutterAssetManager instance = mock(FlutterAssetManager.class);
    final String path = "myString";
    when(instance.list(path)).thenReturn(null);

    assertEquals(Collections.emptyList(), api.list(instance, path));
  }

  @Test(expected = RuntimeException.class)
  public void list_should_convert_io_exception_to_runtime_exception() {
    final PigeonApiFlutterAssetManager api =
        new TestProxyApiRegistrar().getPigeonApiFlutterAssetManager();

    final FlutterAssetManager instance = mock(FlutterAssetManager.class);
    final String path = "test/path";

    try {
      when(instance.list(path)).thenThrow(new IOException());
      api.list(instance, "test/path");
    } catch (IOException e) {
      fail();
    }
  }

  @Test
  public void getAssetFilePathByName() {
    final PigeonApiFlutterAssetManager api =
        new TestProxyApiRegistrar().getPigeonApiFlutterAssetManager();

    final FlutterAssetManager instance = mock(FlutterAssetManager.class);
    final String name = "myString";
    final String value = "myString1";
    when(instance.getAssetFilePathByName(name)).thenReturn(value);

    assertEquals(value, api.getAssetFilePathByName(instance, name));
  }
}
