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

  /// Indicates a platform specific resource is provided.
  ///
  /// See https://pub.dev/packages/webview_flutter#platform-specific-features
  /// for accessing platform-specific classes.
  platform,
}

/// Possible permission responses for resource access.
enum WebViewPermissionResponseType {
  /// Grant permission for the requested resource.
  grant,

  /// Deny permission for the requested resource.
  deny,

  /// Indicates a platform specific response is provided.
  ///
  /// See https://pub.dev/packages/webview_flutter#platform-specific-features
  /// for accessing platform-specific classes.
  platform,
}

/// Permissions request when web content requests access to protected resources.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
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
  const WebViewPermissionRequest({required this.types});

  /// All resources requested access.
  final List<WebViewPermissionResourceType> types;
}

/// Response to a permission request.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [WebViewPermissionResponse] to
/// provide additional platform specific parameters:
///
/// ```dart
/// enum WebKitWebViewPermissionResponseType {
///   prompt,
/// }
///
/// class WebKitWebViewPermissionResponse extends WebViewPermissionResponse {
///   const WebKitWebViewPermissionResponse({required this.webKitType})
///       : super(type: WebViewPermissionResponseType.platform);
///
///   final WebKitWebViewPermissionResponseType webKitType;
/// }
/// ```
@immutable
class WebViewPermissionResponse {
  /// Creates a [WebViewPermissionResponse].
  const WebViewPermissionResponse({required this.type});

  /// The type of response to a permissions request.
  final WebViewPermissionResponseType type;
}
