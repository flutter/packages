// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

import 'src/shared_preferences_state_provider.dart';
import 'src/ui/shared_preferences_body.dart';

void main() {
  runApp(const _SharedPreferencesTool());
}

class _SharedPreferencesTool extends StatelessWidget {
  const _SharedPreferencesTool();

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: Builder(builder: (BuildContext context) {
        return FutureBuilder<Object>(
            future: serviceManager.onServiceAvailable,
            builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text('Please connect to a VM service'),
                );
              }

              return const SharedPreferencesStateProvider(
                child: SharedPreferencesBody(),
              );
            });
      }),
    );
  }
}
