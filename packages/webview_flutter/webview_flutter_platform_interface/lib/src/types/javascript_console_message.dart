// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'javascript_log_level.dart';

/// Represents a console message written to the JavaScript console.
@immutable
class JavaScriptConsoleMessage {
  /// Creates a [JavaScriptConsoleMessage].
  const JavaScriptConsoleMessage({required this.level, required this.message});

  /// The severity of a JavaScript log message.
  final JavaScriptLogLevel level;

  /// The message written to the console.
  final String message;
}
