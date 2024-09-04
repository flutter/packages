// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// The error page for navigation errors.
class NavigationErrorPage extends StatelessWidget {
  /// Creates a new instance of the [NavigationErrorPage].
  const NavigationErrorPage({super.key});

  /// The path for the error page.
  static const String path = '/error';

  /// The name for the error page.
  static const String name = 'Error';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Error Page'),
      ),
    );
  }
}
