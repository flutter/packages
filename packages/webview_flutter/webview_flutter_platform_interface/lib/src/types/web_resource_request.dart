// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Defines the parameters of the web resource request from the associated request.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [WebResourceRequest] to
/// provide additional platform specific parameters.
///
/// When extending [WebResourceRequest] additional parameters should always
/// accept `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// class AndroidWebResourceRequest extends WebResourceRequest {
///   WebResourceRequest._({
///     required WebResourceRequest request,
///   }) : super(
///     uri: request.uri,
///   );
///
///   factory AndroidWebResourceRequest.fromWebResourceRequest(
///     WebResourceRequest request, {
///     Map<String, String> headers,
///   }) {
///     return AndroidWebResourceRequest._(request, headers: headers);
///   }
///
///   final Map<String, String> headers;
/// }
/// ```
@immutable
class WebResourceRequest {
  /// Used by the platform implementation to create a new [WebResourceRequest].
  const WebResourceRequest({required this.uri});

  /// URI for the request.
  final Uri uri;
}
