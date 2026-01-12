// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Defines the parameters that support `PlatformWebViewController.setOnJavaScriptAlertDialog`.
@immutable
class JavaScriptAlertDialogRequest {
  /// Creates a [JavaScriptAlertDialogRequest].
  const JavaScriptAlertDialogRequest({
    required this.message,
    required this.url,
  });

  /// The message to be displayed in the window.
  final String message;

  /// The URL of the page requesting the dialog.
  final String url;
}

/// Defines the parameters that support `PlatformWebViewController.setOnJavaScriptConfirmDialog`.
@immutable
class JavaScriptConfirmDialogRequest {
  /// Creates a [JavaScriptConfirmDialogRequest].
  const JavaScriptConfirmDialogRequest({
    required this.message,
    required this.url,
  });

  /// The message to be displayed in the window.
  final String message;

  /// The URL of the page requesting the dialog.
  final String url;
}

/// Defines the parameters that support `PlatformWebViewController.setOnJavaScriptTextInputDialog`.
@immutable
class JavaScriptTextInputDialogRequest {
  /// Creates a [JavaScriptAlertDialogRequest].
  const JavaScriptTextInputDialogRequest({
    required this.message,
    required this.url,
    required this.defaultText,
  });

  /// The message to be displayed in the window.
  final String message;

  /// The URL of the page requesting the dialog.
  final String url;

  /// The initial text to display in the text entry field.
  final String? defaultText;
}
