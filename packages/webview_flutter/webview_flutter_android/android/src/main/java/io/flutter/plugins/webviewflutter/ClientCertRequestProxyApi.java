// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.ClientCertRequest;
import androidx.annotation.NonNull;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.List;

/**
 * ProxyApi implementation for {@link ClientCertRequest}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class ClientCertRequestProxyApi extends PigeonApiClientCertRequest {
  ClientCertRequestProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void cancel(@NonNull ClientCertRequest pigeon_instance) {
    pigeon_instance.cancel();
  }

  @Override
  public void ignore(@NonNull ClientCertRequest pigeon_instance) {
    pigeon_instance.ignore();
  }

  @Override
  public void proceed(
      @NonNull ClientCertRequest pigeon_instance,
      @NonNull PrivateKey privateKey,
      @NonNull List<? extends X509Certificate> chain) {
    pigeon_instance.proceed(privateKey, chain.toArray(new X509Certificate[0]));
  }
}
