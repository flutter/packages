// Copyright 2013 The Flutter Authors
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

/// Raised when [Block] is returned from `onEnter` but there is no prior
/// route configuration to restore (e.g., an initial deep link was blocked).
///
/// Apps can check for this specific type in `onException` to recover
/// gracefully (e.g., redirect to a loading screen with the deep link
/// preserved) instead of treating it as a generic routing error.
class BlockedInitialNavigationException extends GoException {
  /// Creates an exception for a blocked initial navigation attempt.
  BlockedInitialNavigationException(super.message);
}
