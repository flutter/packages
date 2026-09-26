// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Marks whether the subtree below it belongs to the currently active branch
/// of a `StatefulShellRoute`.
///
/// Every branch of a `StatefulShellRoute` stays mounted, including the
/// inactive ones. Widgets that must only take effect for the branch the user
/// is currently looking at can use [isActiveBranchOf] to find out whether they
/// are part of the active branch.
class ActiveBranchScope extends InheritedWidget {
  /// Constructs an [ActiveBranchScope].
  const ActiveBranchScope({required this.isActive, required super.child, super.key});

  /// Whether the subtree below this widget belongs to the active branch of the
  /// enclosing `StatefulShellRoute`.
  final bool isActive;

  /// Whether [context] is part of the active branch of the closest enclosing
  /// `StatefulShellRoute`.
  ///
  /// Returns true when [context] is not below a `StatefulShellRoute`, for
  /// instance for the [Navigator] of a plain `ShellRoute`.
  ///
  /// The calling widget is rebuilt whenever the active branch changes.
  static bool isActiveBranchOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActiveBranchScope>()?.isActive ?? true;

  @override
  bool updateShouldNotify(ActiveBranchScope oldWidget) => isActive != oldWidget.isActive;
}
