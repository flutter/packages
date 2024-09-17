// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.WebChromeClient.FileChooserParams;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Arrays;
import java.util.Collections;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import java.util.List;

public class FileChooserParamsTest {
  @Test
  public void isCaptureEnabled() {
    final PigeonApiFileChooserParams api = new TestProxyApiRegistrar().getPigeonApiFileChooserParams();

    final FileChooserParams instance = mock(FileChooserParams.class);
    final Boolean value = true;
    when(instance.isCaptureEnabled()).thenReturn(value);

    assertEquals(value, api.isCaptureEnabled(instance));
  }

  @Test
  public void acceptTypes() {
    final PigeonApiFileChooserParams api = new TestProxyApiRegistrar().getPigeonApiFileChooserParams();

    final FileChooserParams instance = mock(FileChooserParams.class);
    final List<String> value = Collections.singletonList("myString");
    when(instance.getAcceptTypes()).thenReturn(value.toArray(new String[0]));

    assertEquals(value, api.acceptTypes(instance));
  }

  @Test
  public void mode() {
    final PigeonApiFileChooserParams api = new TestProxyApiRegistrar().getPigeonApiFileChooserParams();

    final FileChooserParams instance = mock(FileChooserParams.class);
    final FileChooserMode value = io.flutter.plugins.webviewflutter.FileChooserMode.OPEN;
    when(instance.getMode()).thenReturn(FileChooserParams.MODE_OPEN);

    assertEquals(value, api.mode(instance));
  }

  @Test
  public void filenameHint() {
    final PigeonApiFileChooserParams api = new TestProxyApiRegistrar().getPigeonApiFileChooserParams();

    final FileChooserParams instance = mock(FileChooserParams.class);
    final String value = "myString";
    when(instance.getFilenameHint()).thenReturn(value);

    assertEquals(value, api.filenameHint(instance));
  }
}
