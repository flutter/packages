// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

/// Types of resources that can require permissions.
enum WebViewPermissionResourceType {
  /// A media device that can capture video.
  camera,

  /// A media device that can capture audio.
  microphone,
}

/// Permissions request when web content requests access to protected resources.
///
/// A response must be provided by calling a method from [response].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// When extending [WebViewPermissionRequest] additional parameters should
/// always accept `null` or have a default value to prevent breaking changes.
///
/// This example demonstrates how to extend the [WebViewPermissionRequest] to
/// provide additional platform specific parameters:
///
/// ```dart
/// enum AndroidWebViewPermissionResourceType {
///   midiSysex,
/// }
///
/// class AndroidWebViewPermissionRequest extends WebViewPermissionRequest {
///   const AndroidWebViewPermissionRequest({
///     required super.types,
///     required this.androidTypes,
///   });
///
///   final List<AndroidWebViewPermissionResourceType> androidTypes;
/// }
/// ```
@immutable
class WebViewPermissionRequest {
  /// Creates a [WebViewPermissionRequest].
  const WebViewPermissionRequest({
    required this.types,
    required this.response,
  });

  /// All resources requested access.
  final List<WebViewPermissionResourceType> types;

  /// Response to a permission request.
  final WebViewPermissionResponse response;
}

/// Response to a permission request.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// When extending [WebViewPermissionResponse] additional parameters should
/// always accept `null` or have a default value to prevent breaking changes.
///
/// This example demonstrates how to extend the [WebViewPermissionResponse] to
/// provide additional platform specific parameters:
///
/// ```dart
/// class WebKitWebViewPermissionResponse extends WebViewPermissionResponse {
///   const WebKitWebViewPermissionResponse();
///
///   Future<void> prompt() {
///     // ..
///   }
/// }
/// ```
@immutable
abstract class WebViewPermissionResponse {
  /// Creates a [WebViewPermissionResponse].
  const WebViewPermissionResponse();

  /// Grant permission for the requested resource(s).
  Future<void> grant(WebViewPermissionGrantParams params);

  /// Deny permission for the requested resource(s).
  Future<void> deny(WebViewPermissionDenyParams params);
}

/// Params for granting permission for a requested resource.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// When extending [WebViewPermissionGrantParams] additional parameters should
/// always accept `null` or have a default value to prevent breaking changes.
///
/// This example demonstrates how to extend the [WebViewPermissionGrantParams]
/// to provide additional platform specific parameters:
///
/// ```dart
/// class AndroidWebViewPermissionGrantParams extends WebViewPermissionGrantParams {
///   const AndroidWebViewPermissionGrantParams({
///     this.types = const <WebViewPermissionResourceType>[],
///   });
///
///   AndroidWebViewPermissionGrantParams.fromWebViewPermissionGrantParams(
///     WebViewPermissionGrantParams params, {
///     List<WebViewPermissionResourceType> types =
///         const <WebViewPermissionResourceType>[],
///   }) : this(types: types);
///
///   final List<WebViewPermissionResourceType> types;
/// }
/// ```
@immutable
class WebViewPermissionGrantParams {
  /// Constructs a [WebViewPermissionGrantParams].
  const WebViewPermissionGrantParams();
}

/// Params for denying permission for a requested resource.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// When extending [WebViewPermissionDenyParams] additional parameters should
/// always accept `null` or have a default value to prevent breaking changes.
///
/// This example demonstrates how to extend the [WebViewPermissionDenyParams] to
/// provide additional platform specific parameters:
///
/// ```dart
/// class AndroidWebViewPermissionDenyParams extends WebViewPermissionDenyParams {
///   const AndroidWebViewPermissionDenyParams({
///     this.types = const <WebViewPermissionResourceType>[],
///   });
///
///   AndroidWebViewPermissionDenyParams.fromWebViewPermissionDenyParams(
///     WebViewPermissionDenyParams params, {
///     List<WebViewPermissionResourceType> types =
///         const <WebViewPermissionResourceType>[],
///   }) : this(types: types);
///
///   final List<WebViewPermissionResourceType> types;
/// }
/// ```
@immutable
class WebViewPermissionDenyParams {
  /// Constructs a [WebViewPermissionDenyParams].
  const WebViewPermissionDenyParams();
}
