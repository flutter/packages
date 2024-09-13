// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// The counter page.
class CounterPage extends StatelessWidget {
  /// Construct the counter page.
  const CounterPage({super.key});

  /// The path for the counter page.
  static const String path = '/counter';

  /// The name for the counter page.
  static const String name = 'Counter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Page'),
      ),
      body: const Center(
        child: Text('Counter Page'),
      ),
    );
  }
}
