// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';

/// A panel that displays an error message and a stack trace.
class ErrorPanel extends StatelessWidget {
  /// Default constructor for [ErrorPanel].
  const ErrorPanel({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  /// The error message to display.
  /// This will be displayed as a string.
  final Object error;

  /// The stack trace to display.
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(densePadding),
      child: Text(
        'Error:\n$error\n\n$stackTrace',
        style: Theme.of(context).errorTextStyle,
      ),
    );
  }
}
