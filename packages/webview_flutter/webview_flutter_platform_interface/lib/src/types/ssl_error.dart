// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ssl_certificate.dart';
import 'ssl_error_type.dart';

/// Defines the parameters of an SSL certificate error
@immutable
class SslError {
  /// Creates a [SslError].
  const SslError({
    required this.errorType,
    required this.sslCertificate,
    required this.scheme,
    required this.host,
    required this.port,
  });

  /// The SSL error
  final SslErrorType? errorType;

  /// The SSL certificate
  final SslCertificate sslCertificate;

  ///The scheme of the url requesting trust
  final String scheme;

  ///The host of the url requesting trust
  final String host;

  /// The port of the url requesting trust
  final int port;
}
