// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
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
    return const DevToolsExtension(
      child: _ConnectionManager(),
    );
  }
}

class _ConnectionManager extends StatefulWidget {
  const _ConnectionManager();

  @override
  State<_ConnectionManager> createState() => _ConnectionManagerState();
}

class _ConnectionManagerState extends State<_ConnectionManager> {
  @override
  void initState() {
    super.initState();
    // Used to move the application back to the loading state on the simulated
    // environment when the developer disconnects the app.
    serviceManager.registerLifecycleCallback(
      ServiceManagerLifecycle.afterCloseVmService,
      (_) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: serviceManager.onServiceAvailable,
        builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return const SharedPreferencesStateProvider(
            child: SharedPreferencesBody(),
          );
        });
  }
}
