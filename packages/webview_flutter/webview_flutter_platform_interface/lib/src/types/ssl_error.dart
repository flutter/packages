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
    required this.error,
    required this.certificate,
    required this.host,
    required this.scheme,
    required this.port,
  });

  /// The SSL error
  final SslErrorType? error;

  /// The SSL certificate
  final SslCertificate certificate;

  ///The host of the url requesting trust
  final String host;

  ///The scheme of the url requesting trust
  final String scheme;

  /// The port of the url requesting trust
  final String port;
}
