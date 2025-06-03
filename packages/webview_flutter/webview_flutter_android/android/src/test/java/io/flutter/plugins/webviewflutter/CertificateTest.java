// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.security.cert.Certificate;
import java.security.cert.CertificateEncodingException;
import org.junit.Test;

public class CertificateTest {
  @Test
  public void getEncoded() throws CertificateEncodingException {
    final PigeonApiCertificate api = new TestProxyApiRegistrar().getPigeonApiCertificate();

    final Certificate instance = mock(Certificate.class);
    final byte[] value = new byte[] {(byte) 0xA1};
    when(instance.getEncoded()).thenReturn(value);

    assertEquals(value, api.getEncoded(instance));
  }
}
