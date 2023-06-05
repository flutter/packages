// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Thrown when [GoRouter] is used incorrectly.
class GoError extends Error {
  /// Constructs a [GoError]
  GoError(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() => 'GoError: $message';
}

/// Thrown when an error occurs while building the app's UI based on the route
/// matches.
class RouteBuilderException implements Exception {
  /// Constructs a [RouteBuilderException].
  //ignore: unused_element
  RouteBuilderException(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}
