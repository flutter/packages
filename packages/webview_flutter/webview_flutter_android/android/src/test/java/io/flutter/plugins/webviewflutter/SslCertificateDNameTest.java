// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.net.http.SslCertificate;
import org.junit.Test;

public class SslCertificateDNameTest {
  @Test
  public void getCName() {
    final PigeonApiSslCertificateDName api =
        new TestProxyApiRegistrar().getPigeonApiSslCertificateDName();

    final SslCertificate.DName instance = mock(SslCertificate.DName.class);
    final String value = "myString";
    when(instance.getCName()).thenReturn(value);

    assertEquals(value, api.getCName(instance));
  }

  @Test
  public void getDName() {
    final PigeonApiSslCertificateDName api =
        new TestProxyApiRegistrar().getPigeonApiSslCertificateDName();

    final SslCertificate.DName instance = mock(SslCertificate.DName.class);
    final String value = "myString";
    when(instance.getDName()).thenReturn(value);

    assertEquals(value, api.getDName(instance));
  }

  @Test
  public void getOName() {
    final PigeonApiSslCertificateDName api =
        new TestProxyApiRegistrar().getPigeonApiSslCertificateDName();

    final SslCertificate.DName instance = mock(SslCertificate.DName.class);
    final String value = "myString";
    when(instance.getOName()).thenReturn(value);

    assertEquals(value, api.getOName(instance));
  }

  @Test
  public void getUName() {
    final PigeonApiSslCertificateDName api =
        new TestProxyApiRegistrar().getPigeonApiSslCertificateDName();

    final SslCertificate.DName instance = mock(SslCertificate.DName.class);
    final String value = "myString";
    when(instance.getUName()).thenReturn(value);

    assertEquals(value, api.getUName(instance));
  }
}
