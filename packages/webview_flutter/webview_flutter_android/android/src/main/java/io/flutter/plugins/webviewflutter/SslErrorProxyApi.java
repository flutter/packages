// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.net.http.SslError;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link SslError}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class SslErrorProxyApi extends PigeonApiSslError {
  SslErrorProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public android.net.http.SslCertificate certificate(@NonNull SslError pigeon_instance) {
    return pigeon_instance.getCertificate();
  }

  @NonNull
  @Override
  public String url(@NonNull SslError pigeon_instance) {
    return pigeon_instance.getUrl();
  }

  @NonNull
  @Override
  public SslErrorType getPrimaryError(@NonNull SslError pigeon_instance) {
    switch (pigeon_instance.getPrimaryError()) {
      case SslError.SSL_DATE_INVALID:
        return SslErrorType.DATE_INVALID;
      case SslError.SSL_EXPIRED:
        return SslErrorType.EXPIRED;
      case SslError.SSL_IDMISMATCH:
        return SslErrorType.ID_MISMATCH;
      case SslError.SSL_INVALID:
        return SslErrorType.INVALID;
      case SslError.SSL_NOTYETVALID:
        return SslErrorType.NOT_YET_VALID;
      case SslError.SSL_UNTRUSTED:
        return SslErrorType.UNTRUSTED;
      default:
        return SslErrorType.UNKNOWN;
    }
  }

  @Override
  public boolean hasError(@NonNull SslError pigeon_instance, @NonNull SslErrorType error) {
    int nativeError = -1;
    switch (error) {
      case DATE_INVALID:
        nativeError = SslError.SSL_DATE_INVALID;
        break;
      case EXPIRED:
        nativeError = SslError.SSL_EXPIRED;
        break;
      case ID_MISMATCH:
        nativeError = SslError.SSL_IDMISMATCH;
        break;
      case INVALID:
        nativeError = SslError.SSL_INVALID;
        break;
      case NOT_YET_VALID:
        nativeError = SslError.SSL_NOTYETVALID;
        break;
      case UNTRUSTED:
        nativeError = SslError.SSL_UNTRUSTED;
        break;
      case UNKNOWN:
        throw getPigeonRegistrar().createUnknownEnumException(error);
    }
    return pigeon_instance.hasError(nativeError);
  }
}
