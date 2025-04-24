// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'types/types.dart';

/// Represents an SSL error with the associated certificate.
///
/// The host application must call [cancel] or, contrary to secure web
/// communication standards, [proceed] to provide the web view's response to the
/// request.
abstract class PlatformSslAuthError {
  /// Creates a [PlatformSslAuthError].
  @protected
  PlatformSslAuthError({required this.certificate, required this.description});

  /// The certificate associated with this error.
  final X509Certificate? certificate;

  /// A human-presentable description for a given error.
  final String description;

  /// Instructs the WebView that encountered the SSL certificate error to ignore
  /// the error and continue communicating with the server.
  Future<void> proceed();

  /// Instructs the WebView that encountered the SSL certificate error to
  /// terminate communication with the server.
  Future<void> cancel();
}
