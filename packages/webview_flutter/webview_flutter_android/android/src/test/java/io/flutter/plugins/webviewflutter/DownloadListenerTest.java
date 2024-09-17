// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.plugins.webviewflutter.DownloadListenerProxyApi.DownloadListenerImpl;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class DownloadListenerTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiDownloadListener api = new TestProxyApiRegistrar().getPigeonApiDownloadListener();

    assertTrue(api.pigeon_defaultConstructor() instanceof DownloadListenerProxyApi.DownloadListenerImpl);
  }

  @Test
  public void onDownloadStart() {
    final DownloadListenerProxyApi mockApi = mock(DownloadListenerProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final DownloadListenerImpl instance = new DownloadListenerImpl(mockApi);
    final String url = "myString";
    final String userAgent = "myString";
    final String contentDisposition = "myString";
    final String mimetype = "myString";
    final Long contentLength = 0L;
    instance.onDownloadStart(url, userAgent, contentDisposition, mimetype, contentLength);

    verify(mockApi).onDownloadStart(eq(instance), eq(url), eq(userAgent), eq(contentDisposition), eq(mimetype), eq(contentLength), any());
  }
}
