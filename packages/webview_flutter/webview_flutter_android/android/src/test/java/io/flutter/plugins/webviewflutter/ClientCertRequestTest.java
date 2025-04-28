// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.ClientCertRequest;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class ClientCertRequestTest {
  @Test
  public void cancel() {
    final PigeonApiClientCertRequest api =
        new TestProxyApiRegistrar().getPigeonApiClientCertRequest();

    final ClientCertRequest instance = mock(ClientCertRequest.class);
    api.cancel(instance);

    verify(instance).cancel();
  }

  @Test
  public void ignore() {
    final PigeonApiClientCertRequest api =
        new TestProxyApiRegistrar().getPigeonApiClientCertRequest();

    final ClientCertRequest instance = mock(ClientCertRequest.class);
    api.ignore(instance);

    verify(instance).ignore();
  }

  @Test
  public void proceed() {
    final PigeonApiClientCertRequest api =
        new TestProxyApiRegistrar().getPigeonApiClientCertRequest();

    final ClientCertRequest instance = mock(ClientCertRequest.class);
    final java.security.PrivateKey privateKey = mock(PrivateKey.class);
    final X509Certificate cert = mock(X509Certificate.class);
    final List<X509Certificate> chain = Collections.singletonList(cert);
    api.proceed(instance, privateKey, chain);

    verify(instance).proceed(privateKey, new X509Certificate[] {cert});
  }
}
