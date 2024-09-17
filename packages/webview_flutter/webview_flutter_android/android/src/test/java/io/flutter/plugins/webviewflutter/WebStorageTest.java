// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.WebStorage;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebStorageTest {
  @Test
  public void deleteAllData() {
    final PigeonApiWebStorage api = new TestProxyApiRegistrar().getPigeonApiWebStorage();

    final WebStorage instance = mock(WebStorage.class);
    api.deleteAllData(instance );

    verify(instance).deleteAllData();
  }
}
