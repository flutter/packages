// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(densePadding),
      child: Text('Error:\n$error\n\n$stackTrace'),
    );
  }
}
