// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'webview_credential.dart';

/// Defines the parameters of a pending HTTP authentication request received by
/// the webview through a [HttpAuthRequestCallback].
///
/// Platform specific implementations can add additional fields by extending
/// this class and providing a factory method that takes the [HttpAuthRequest]
/// as a parameter.
///
/// This example demonstrates how to extend the [HttpAuthRequest] to provide
/// additional platform specific parameters.
///
/// When extending [HttpAuthRequest], additional parameters should always accept
/// `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// @immutable
/// class WKWebViewHttpAuthRequest extends HttpAuthRequest {
///   WKWebViewHttpAuthRequest._(
///     HttpAuthRequest authRequest,
///     this.extraData,
///   ) : super(
///      onProceed: authRequest.onProceed,
///      onCancel: authRequest.onCancel,
///      host: authRequest.host,
///      realm: authRequest.realm,
///   );
///
///   factory WKWebViewHttpAuthRequest.fromHttpAuthRequest(
///     HttpAuthRequest authRequest, {
///     String? extraData,
///   }) {
///     return WKWebViewHttpAuthRequest._(
///       authRequest,
///       extraData: extraData,
///     );
///   }
///
///   final String? extraData;
/// }
/// ```
@immutable
class HttpAuthRequest {
  /// Creates a [HttpAuthRequest].
  const HttpAuthRequest({
    required this.onProceed,
    required this.onCancel,
    required this.host,
    this.realm,
  });

  /// The callback to authenticate.
  final void Function(WebViewCredential credential) onProceed;

  /// The callback to cancel authentication.
  final void Function() onCancel;

  /// The host requiring authentication.
  final String host;

  /// The realm requiring authentication.
  final String? realm;
}
