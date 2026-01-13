// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// Signature for callbacks invoked after an [OnEnterResult] is resolved.
typedef OnEnterThenCallback = FutureOr<void> Function();

/// The result of an onEnter callback.
///
/// This sealed class represents the possible outcomes of navigation interception.
/// This class can't be extended. One must use one of its subtypes, [Allow] or
/// [Block], to indicate the result.
sealed class OnEnterResult {
  /// Creates an [OnEnterResult].
  const OnEnterResult({this.then});

  /// Executed after the decision is committed.
  /// Errors are reported and do not revert navigation.
  final OnEnterThenCallback? then;

  /// Whether this block represents a hard stop without a follow-up callback.
  bool get isStop => this is Block && then == null;
}

/// Allows the navigation to proceed.
///
/// The [then] callback runs **after** the navigation is committed. Errors
/// thrown by this callback are reported via `FlutterError.reportError` and
/// do **not** undo the already-committed navigation.
final class Allow extends OnEnterResult {
  /// Creates an [Allow] result with an optional [then] callback executed after
  /// navigation completes.
  const Allow({super.then});
}

/// Blocks the navigation from proceeding.
///
/// Returning an object of this class from an `onEnter` callback halts the
/// navigation completely.
///
/// Use [Block.stop] for a "hard stop" that resets the redirection history, or
/// [Block.then] to chain a callback after the block (commonly to redirect
/// elsewhere, e.g. `router.go('/login')`).
///
/// Note: We don't introspect callback bodies. Even an empty closure still
/// counts as chaining, so prefer [Block.stop] when you want the hard stop
/// behavior.
final class Block extends OnEnterResult {
  /// Creates a [Block] that stops navigation without running a follow-up
  /// callback.
  ///
  /// Returning an object created by this constructor from an `onEnter`
  /// callback halts the navigation completely and resets the redirection
  /// history so the next attempt is evaluated fresh.
  const Block.stop() : super();

  /// Creates a [Block] that runs [then] after the navigation is blocked.
  ///
  /// Keeps the redirection history to detect loops during chained redirects.
  const Block.then(OnEnterThenCallback then) : super(then: then);
}
