// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;
import java.security.cert.Certificate;
import java.security.cert.CertificateEncodingException;

/**
 * ProxyApi implementation for {@link Certificate}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class CertificateProxyApi extends PigeonApiCertificate {
  CertificateProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public byte[] getEncoded(@NonNull Certificate pigeon_instance) {
    try {
      return pigeon_instance.getEncoded();
    } catch (CertificateEncodingException exception) {
      throw new RuntimeException(exception);
    }
  }
}
