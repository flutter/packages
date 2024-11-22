// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.WebStorage;
import org.junit.Test;

public class WebStorageTest {
  @Test
  public void deleteAllData() {
    final PigeonApiWebStorage api = new TestProxyApiRegistrar().getPigeonApiWebStorage();

    final WebStorage instance = mock(WebStorage.class);
    api.deleteAllData(instance);

    verify(instance).deleteAllData();
  }
}
