// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'android_webkit.g.dart' as android;

/// Implementation of the [PlatformSslAuthError] with the Android WebView API.
class AndroidSslAuthError extends PlatformSslAuthError {
  /// Creates an [AndroidSslAuthError].
  AndroidSslAuthError._({
    required super.certificate,
    required super.description,
    required android.SslErrorHandler handler,
    required this.url,
  }) : _handler = handler;

  final android.SslErrorHandler _handler;

  /// The URL associated with the error.
  final String url;

  /// Creates an [AndroidSslAuthError] from the parameters from the native
  /// `WebViewClient.onReceivedSslError`.
  @internal
  static Future<AndroidSslAuthError> fromNativeCallback({
    required android.SslError error,
    required android.SslErrorHandler handler,
  }) async {
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

    return AndroidSslAuthError._(
      certificate: X509Certificate(
        data:
            x509Certificate != null ? await x509Certificate.getEncoded() : null,
      ),
      handler: handler,
      description: errorDescription,
      url: error.url,
    );
  }

  @override
  Future<void> cancel() => _handler.cancel();

  @override
  Future<void> proceed() => _handler.proceed();
}
