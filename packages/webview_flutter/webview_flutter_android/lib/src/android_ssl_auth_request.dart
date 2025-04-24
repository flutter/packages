// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'android_webkit.g.dart' as android;

class AndroidSslCertificate extends SslCertificate {
  AndroidSslCertificate._({super.data, super.errors});

  static Future<AndroidSslCertificate> fromNativeSslError(
    android.SslError error,
  ) async {
    final android.SslCertificate certificate = error.certificate;
    final android.X509Certificate? x509Certificate =
        await certificate.getX509Certificate();

    final android.SslErrorType errorType = await error.getPrimaryError();
    final String errorDescription = switch (errorType) {
      android.SslErrorType.dateInvalid =>
        'The date of the certificate is invalid.',
      android.SslErrorType.expired => 'The certificate has expired.',
      android.SslErrorType.idMismatch => 'Hostname mismatch.',
      android.SslErrorType.invalid => 'A generic error occurred.',
      android.SslErrorType.notYetValid => 'The certificate is not yet valid.',
      android.SslErrorType.untrusted =>
        'The certificate authority is not trusted.',
      android.SslErrorType.unknown => 'The certificate has an unknown error.',
    };

    return AndroidSslCertificate._(
      data: x509Certificate != null ? await x509Certificate.getEncoded() : null,
      errors: <SslError>[SslError(description: errorDescription)],
    );
  }
}

class AndroidSslAuthRequest extends PlatformSslAuthRequest {
  AndroidSslAuthRequest({
    required android.SslErrorHandler handler,
    required super.certificates,
    super.url,
  }) : _handler = handler;

  final android.SslErrorHandler _handler;

  // /// The URL associated with the request.
  // final Uri? url;

  @override
  Future<void> cancel() => _handler.cancel();

  @override
  Future<void> proceed() => _handler.proceed();

  @override
  Future<void> defaultHandling() {
    return _handler.cancel();
  }
}
