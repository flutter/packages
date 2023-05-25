// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Contains information about the response for the request.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [WebResourceResponse] to
/// provide additional platform specific parameters.
///
/// When extending [WebResourceResponse] additional parameters should always
/// accept `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// class AndroidWebResourceResponse extends WebResourceResponse {
///   WebResourceResponse._({
///     required WebResourceResponse response,
///   }) : super(
///     uri: response.uri,
///     headers: params.headers,
///   );
///
///   factory AndroidWebResourceResponse.fromWebResourceResponse(
///     WebResourceResponse response, {
///     Uri? historyUrl,
///   }) {
///     return AndroidWebResourceResponse._(response, historyUrl: historyUrl);
///   }
///
///   final Uri? historyUrl;
/// }
/// ```
/// {@end-tool}
@immutable
class WebResourceResponse {
  /// Used by the platform implementation to create a new [WebResourceResponse].
  const WebResourceResponse({
    required this.uri,
    this.headers = const <String, String>{},
  });

  /// URI for the request.
  final Uri uri;

  /// Headers for the request.
  final Map<String, String> headers;
}
