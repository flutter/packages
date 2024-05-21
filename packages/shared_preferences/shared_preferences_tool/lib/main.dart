// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

import 'src/shared_preferences_state_notifier_provider.dart';
import 'src/ui/shared_preferences_body.dart';

void main() {
  runApp(const _SharedPreferencesTools());
}

class _SharedPreferencesTools extends StatelessWidget {
  const _SharedPreferencesTools();

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: SharedPreferencesStateNotifierProvider(
        child: SharedPreferencesBody(),
      ),
    );
  }
}
