// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Object specifying creation parameters for creating a native view.
@immutable
base class BuildWidgetCreationParams {
  /// Used by the platform implementation to create a new
  /// [BuildWidgetCreationParams].
  const BuildWidgetCreationParams({
    this.key,
    required this.context,
    this.layoutDirection = TextDirection.ltr,
  });

  /// The [Key] passed to Widget of that represents the native view.
  ///
  /// See also:
  ///  * The discussions at [Key] and [GlobalKey].
  final Key? key;

  /// A handle to the location of a widget in the widget tree.
  final BuildContext context;

  /// The layout direction to use for the native view.
  final TextDirection layoutDirection;
}
