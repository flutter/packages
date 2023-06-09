// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../match.dart';

/// Thrown when [GoRouter] is used incorrectly.
class GoError extends Error {
  /// Constructs a [GoError]
  GoError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'GoError: $message';
}

/// A configuration error detected while processing redirects.
class RedirectionError extends Error implements UnsupportedError {
  /// RedirectionError constructor.
  RedirectionError(this.message, this.matches, this.location);

  /// The matches that were found while processing redirects.
  final List<RouteMatchList> matches;

  @override
  final String message;

  /// The location that was originally navigated to, before redirection began.
  final Uri location;

  @override
  String toString() => '${super.toString()} ${<String>[
        ...matches
            .map((RouteMatchList routeMatches) => routeMatches.uri.toString()),
      ].join(' => ')}';
}
