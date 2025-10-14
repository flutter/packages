// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.net.http.SslCertificate;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.Date;

/**
 * ProxyApi implementation for {@link SslCertificate}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class SslCertificateProxyApi extends PigeonApiSslCertificate {
  SslCertificateProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @Nullable
  @Override
  public android.net.http.SslCertificate.DName getIssuedBy(
      @NonNull SslCertificate pigeon_instance) {
    return pigeon_instance.getIssuedBy();
  }

  @Nullable
  @Override
  public android.net.http.SslCertificate.DName getIssuedTo(
      @NonNull SslCertificate pigeon_instance) {
    return pigeon_instance.getIssuedTo();
  }

  @Nullable
  @Override
  public Long getValidNotAfterMsSinceEpoch(@NonNull SslCertificate pigeon_instance) {
    final Date date = pigeon_instance.getValidNotAfterDate();
    if (date != null) {
      return date.getTime();
    }
    return null;
  }

  @Nullable
  @Override
  public Long getValidNotBeforeMsSinceEpoch(@NonNull SslCertificate pigeon_instance) {
    final Date date = pigeon_instance.getValidNotBeforeDate();
    if (date != null) {
      return date.getTime();
    }
    return null;
  }

  @Nullable
  @Override
  public java.security.cert.X509Certificate getX509Certificate(
      @NonNull SslCertificate pigeon_instance) {
    if (getPigeonRegistrar().sdkIsAtLeast(Build.VERSION_CODES.Q)) {
      return pigeon_instance.getX509Certificate();
    } else {
      Log.d(
          "SslCertificateProxyApi",
          getPigeonRegistrar()
              .createUnsupportedVersionMessage(
                  "SslCertificate.getX509Certificate", "Build.VERSION_CODES.Q"));
      return null;
    }
  }
}
