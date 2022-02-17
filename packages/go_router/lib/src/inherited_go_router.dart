// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'go_router.dart';

/// GoRouter implementation of InheritedWidget.
///
/// Used for to find the current GoRouter in the widget tree. This is useful
/// when routing from anywhere in your app.
class InheritedGoRouter extends InheritedWidget {
  /// Default constructor for the inherited go router.
  const InheritedGoRouter({
    required Widget child,
    required this.goRouter,
    Key? key,
  }) : super(child: child, key: key);

  /// The [GoRouter] that is made available to the widget tree.
  final GoRouter goRouter;

  /// Used by the Router architecture as part of the InheritedWidget.
  @override
  // ignore: prefer_expression_function_bodies
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // avoid rebuilding the widget tree if the router has not changed
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GoRouter>('goRouter', goRouter));
  }
}
