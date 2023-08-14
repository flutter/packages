// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'web_resource_request.dart';
import 'web_resource_response.dart';

/// Error returned in `PlatformNavigationDelegate.setOnHttpError` when an HTTP
/// response error has been received.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [HttpResponseError] to
/// provide additional platform specific parameters.
///
/// When extending [HttpResponseError] additional parameters should always
/// accept `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// class IOSHttpResponseError extends HttpResponseError {
///   IOSHttpResponseError._(HttpResponseError error, {required this.domain})
///       : super(
///           statusCode: error.statusCode,
///         );
///
///   factory IOSHttpResponseError.fromHttpResponseError(
///     HttpResponseError error, {
///     required String? domain,
///   }) {
///     return IOSHttpResponseError._(error, domain: domain);
///   }
///
///   final String? domain;
/// }
/// ```
@immutable
class HttpResponseError {
  /// Used by the platform implementation to create a new [HttpResponseError].
  const HttpResponseError({
    this.request,
    this.response,
  });

  /// The associated request.
  final WebResourceRequest? request;

  /// The associated response.
  final WebResourceResponse? response;
}
