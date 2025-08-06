// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.net.http.SslCertificate;
import java.security.cert.X509Certificate;
import java.util.Date;
import org.junit.Test;

public class SslCertificateTest {
  @Test
  public void getIssuedBy() {
    final PigeonApiSslCertificate api = new TestProxyApiRegistrar().getPigeonApiSslCertificate();

    final SslCertificate instance = mock(SslCertificate.class);
    final android.net.http.SslCertificate.DName value = mock(SslCertificate.DName.class);
    when(instance.getIssuedBy()).thenReturn(value);

    assertEquals(value, api.getIssuedBy(instance));
  }

  @Test
  public void getIssuedTo() {
    final PigeonApiSslCertificate api = new TestProxyApiRegistrar().getPigeonApiSslCertificate();

    final SslCertificate instance = mock(SslCertificate.class);
    final android.net.http.SslCertificate.DName value = mock(SslCertificate.DName.class);
    when(instance.getIssuedTo()).thenReturn(value);

    assertEquals(value, api.getIssuedTo(instance));
  }

  @Test
  public void getValidNotAfterMsSinceEpoch() {
    final PigeonApiSslCertificate api = new TestProxyApiRegistrar().getPigeonApiSslCertificate();

    final SslCertificate instance = mock(SslCertificate.class);
    final Date value = new Date(1000);
    when(instance.getValidNotAfterDate()).thenReturn(value);

    assertEquals(value.getTime(), (long) api.getValidNotAfterMsSinceEpoch(instance));
  }

  @Test
  public void getValidNotBeforeMsSinceEpoch() {
    final PigeonApiSslCertificate api = new TestProxyApiRegistrar().getPigeonApiSslCertificate();

    final SslCertificate instance = mock(SslCertificate.class);
    final Date value = new Date(1000);
    when(instance.getValidNotBeforeDate()).thenReturn(value);

    assertEquals(value.getTime(), (long) api.getValidNotBeforeMsSinceEpoch(instance));
  }

  @Test
  public void getX509Certificate() {
    final PigeonApiSslCertificate api = new TestProxyApiRegistrar().getPigeonApiSslCertificate();

    final SslCertificate instance = mock(SslCertificate.class);
    final java.security.cert.X509Certificate value = mock(X509Certificate.class);
    when(instance.getX509Certificate()).thenReturn(value);

    assertEquals(value, api.getX509Certificate(instance));
  }
}
