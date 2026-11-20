// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This library is not exported from material_ui.dart; it lets an ancestor (for
// example a TextField) know which pointers are pressing an enabled ink response
// in its subtree.

import 'package:flutter/widgets.dart';

/// Records the pointers that are currently pressing an enabled ink response
/// below an [InkResponsePressScope].
class InkResponsePressRegistry {
  final Map<int, Offset> _downPositions = <int, Offset>{};

  /// Registers [pointer], which went down at [globalPosition].
  void add(int pointer, Offset globalPosition) {
    _downPositions[pointer] = globalPosition;
  }

  /// Unregisters [pointer].
  void remove(int pointer) {
    _downPositions.remove(pointer);
  }

  /// Whether [pointer] is pressing an ink response.
  bool contains(int pointer) => _downPositions.containsKey(pointer);

  /// Whether a pointer pressing an ink response went down at [globalPosition].
  ///
  /// Used by gestures whose details carry the down position but not the
  /// pointer, such as [LongPressStartDetails].
  bool hasPressAt(Offset globalPosition) {
    return _downPositions.values.any(
      (Offset position) => (position - globalPosition).distance < 1.0,
    );
  }
}

/// Makes an [InkResponsePressRegistry] available to the ink responses below it.
class InkResponsePressScope extends InheritedWidget {
  /// Creates a scope that ink responses below it register their presses in.
  const InkResponsePressScope({super.key, required this.registry, required super.child});

  /// The registry that ink responses below this scope register their presses in.
  final InkResponsePressRegistry registry;

  /// The registry of the closest enclosing scope, if any.
  ///
  /// Does not make [context] depend on the scope.
  static InkResponsePressRegistry? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<InkResponsePressScope>()?.registry;
  }

  @override
  bool updateShouldNotify(InkResponsePressScope oldWidget) => registry != oldWidget.registry;
}
