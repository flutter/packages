// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// The settings page.
class SettingsPage extends StatelessWidget {
  /// Construct the settings page.
  const SettingsPage({super.key});

  /// The path for the settings page.
  static const String path = 'settings';

  /// The name for the settings page.
  static const String name = 'Settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
