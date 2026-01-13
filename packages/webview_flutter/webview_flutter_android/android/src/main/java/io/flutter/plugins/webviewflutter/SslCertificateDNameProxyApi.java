// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.net.http.SslCertificate;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link SslCertificate.DName}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class SslCertificateDNameProxyApi extends PigeonApiSslCertificateDName {
  SslCertificateDNameProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public String getCName(@NonNull SslCertificate.DName pigeon_instance) {
    return pigeon_instance.getCName();
  }

  @NonNull
  @Override
  public String getDName(@NonNull SslCertificate.DName pigeon_instance) {
    return pigeon_instance.getDName();
  }

  @NonNull
  @Override
  public String getOName(@NonNull SslCertificate.DName pigeon_instance) {
    return pigeon_instance.getOName();
  }

  @NonNull
  @Override
  public String getUName(@NonNull SslCertificate.DName pigeon_instance) {
    return pigeon_instance.getUName();
  }
}
