// ignore_for_file: use_build_context_synchronously

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'router.dart';
import 'state.dart';

/// The result of an [onEnter] callback.
///
/// This sealed class represents the possible outcomes of navigation interception.
sealed class OnEnterResult {
  /// Creates an [OnEnterResult].
  const OnEnterResult();

  /// Creates an [Allow] result that allows navigation to proceed.
  const factory OnEnterResult.allow() = Allow;

  /// Creates a [Block] result that blocks navigation from proceeding.
  const factory OnEnterResult.block() = Block;
}

/// Allows the navigation to proceed.
final class Allow extends OnEnterResult {
  /// Creates an [Allow] result.
  const Allow();
}

/// Blocks the navigation from proceeding.
final class Block extends OnEnterResult {
  /// Creates a [Block] result.
  const Block();
}

/// The signature for the top-level [onEnter] callback.
///
/// This callback receives the [BuildContext], the current navigation state,
/// the state being navigated to, and a reference to the [GoRouter] instance.
/// It returns a [Future<OnEnterResult>] which should resolve to [Allow] if navigation
/// is allowed, or [Block] to block navigation.
typedef OnEnter = Future<OnEnterResult> Function(
  BuildContext context,
  GoRouterState currentState,
  GoRouterState nextState,
  GoRouter goRouter,
);
