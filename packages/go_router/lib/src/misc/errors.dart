// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Thrown when [GoRouter] is used incorrectly.
class GoError extends Error {
  /// Constructs a [GoError]
  GoError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'GoError: $message';
}

/// Thrown when [GoRouter] can not handle a user request.
class GoException implements Exception {
  /// Creates an exception with message describing the reason.
  GoException(this.message);

  /// The reason that causes this exception.
  final String message;

  @override
  String toString() => 'GoException: $message';
}
