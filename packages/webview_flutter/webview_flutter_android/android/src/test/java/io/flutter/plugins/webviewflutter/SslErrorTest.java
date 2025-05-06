// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.net.http.SslCertificate;
import android.net.http.SslError;
import org.junit.Test;

public class SslErrorTest {
  @Test
  public void certificate() {
    final PigeonApiSslError api = new TestProxyApiRegistrar().getPigeonApiSslError();

    final SslError instance = mock(SslError.class);
    final android.net.http.SslCertificate value = mock(SslCertificate.class);
    when(instance.getCertificate()).thenReturn(value);

    assertEquals(value, api.certificate(instance));
  }

  @Test
  public void url() {
    final PigeonApiSslError api = new TestProxyApiRegistrar().getPigeonApiSslError();

    final SslError instance = mock(SslError.class);
    final String value = "myString";
    when(instance.getUrl()).thenReturn(value);

    assertEquals(value, api.url(instance));
  }

  @Test
  public void getPrimaryError() {
    final PigeonApiSslError api = new TestProxyApiRegistrar().getPigeonApiSslError();

    final SslError instance = mock(SslError.class);
    final SslErrorType value = io.flutter.plugins.webviewflutter.SslErrorType.DATE_INVALID;
    when(instance.getPrimaryError()).thenReturn(SslError.SSL_DATE_INVALID);

    assertEquals(value, api.getPrimaryError(instance));
  }

  @Test
  public void hasError() {
    final PigeonApiSslError api = new TestProxyApiRegistrar().getPigeonApiSslError();

    final SslError instance = mock(SslError.class);
    final SslErrorType error = io.flutter.plugins.webviewflutter.SslErrorType.DATE_INVALID;
    final Boolean value = true;
    when(instance.hasError(SslError.SSL_DATE_INVALID)).thenReturn(value);

    assertEquals(value, api.hasError(instance, error));
  }
}
