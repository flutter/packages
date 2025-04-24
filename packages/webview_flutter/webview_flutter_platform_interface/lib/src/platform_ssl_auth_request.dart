// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'types/types.dart';

/// A request from a server to respond to a set of one or more SSL errors with
/// the associated SSL certificate.
///
/// The host application must call [cancel] or, contrary to secure web
/// communication standards, [proceed] to provide the web view's response to the
/// request.
abstract class PlatformSslAuthRequest {
  /// Creates a [PlatformSslAuthRequest].
  @protected
  PlatformSslAuthRequest({
    required this.certificates,
    this.url,
  });

  /// A list of certificates associated with this request.
  final List<SslCertificate> certificates;

  /// The URL associated with the request.
  final Uri? url;

  /// Instructs the WebView that encountered the SSL certificate error to ignore
  /// the error and continue communicating with the server.
  Future<void> proceed();

  /// Instructs the WebView that encountered the SSL certificate error to
  /// terminate communication with the server.
  Future<void> cancel();

  /// Instructs the WebView that encountered the SSL certificate error to use
  /// the system-provided default behavior.
  Future<void> defaultHandling();
}
