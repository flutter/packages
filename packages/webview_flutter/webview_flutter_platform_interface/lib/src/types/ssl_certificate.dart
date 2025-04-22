// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ssl_error.dart';

/// Provides the details for an SSL certificate.
@immutable
class SslCertificate {
  /// Creates a [SslCertificate].
  const SslCertificate({this.data, this.errors = const <SslError>[]});

  /// The encoded form of this certificate.
  final Uint8List? data;

  /// A list of errors associated with this certificate.
  final List<SslError> errors;
}
