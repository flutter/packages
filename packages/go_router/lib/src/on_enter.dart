// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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
  final FutureOr<void> Function()? then;
}

/// Allows the navigation to proceed.
final class Allow extends OnEnterResult {
  /// Creates an [Allow] result.
  ///
  /// The [then] callback runs **after** the navigation is committed. Errors
  /// thrown by this callback are reported via `FlutterError.reportError` and
  /// do **not** undo the already-committed navigation.
  const Allow({super.then});
}

/// Blocks the navigation from proceeding.
final class Block extends OnEnterResult {
  /// Creates a [Block] result.
  ///
  /// The [then] callback is executed after the navigation is blocked.
  /// Commonly used to navigate to a different route (e.g. `router.go('/login')`).
  ///
  /// **History behavior:** a plain `Block()` (no `then`) is a "hard stop" and
  /// resets `onEnter`'s internal redirection history so subsequent attempts are
  /// evaluated fresh; `Block(then: ...)` keeps history to detect loops.
  const Block({super.then});
}
