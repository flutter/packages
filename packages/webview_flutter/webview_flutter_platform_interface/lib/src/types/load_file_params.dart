// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Object specifying parameters for loading a local HTML file into a web view.
///
/// Platform-specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend [LocalFileParams] to provide
/// additional platform-specific parameters.
///
/// When extending [LocalFileParams], additional parameters should always accept
/// `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// class WebKitLoadFileParams extends LoadFileParams {
///   const WebKitLoadFileParams({
///     required super.absoluteFilePath,
///     required String readAccessPath,
///   });
///
///   /// The directory to which the WebView is granted read access.
///   final String readAccessPath;
/// }
/// ```
/// {@end-tool}
@immutable
class LoadFileParams {
  /// Used by the platform implementation to load local HTML page.
  const LoadFileParams({
    required this.absoluteFilePath,
  });

  /// The path to the local HTML file to be loaded.
  final String absoluteFilePath;
}
