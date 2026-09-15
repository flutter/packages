// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Object specifying parameters for injecting JavaScript that runs when the
/// document element is created, before any other content of the page loads.
///
/// Platform-specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend [DocumentStartJavaScriptParams] to
/// provide additional platform-specific parameters.
///
/// When extending [DocumentStartJavaScriptParams], additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// class AndroidDocumentStartJavaScriptParams extends DocumentStartJavaScriptParams {
///   const AndroidDocumentStartJavaScriptParams({
///     required super.source,
///     this.allowedOriginRules = const <String>{'*'},
///   });
///
///   /// The origins that are allowed to run the script.
///   final Set<String> allowedOriginRules;
/// }
/// ```
@immutable
base class DocumentStartJavaScriptParams {
  /// Creates a new [DocumentStartJavaScriptParams] object.
  const DocumentStartJavaScriptParams({required this.source});

  /// The JavaScript source code that runs when the document begins to load.
  final String source;
}
