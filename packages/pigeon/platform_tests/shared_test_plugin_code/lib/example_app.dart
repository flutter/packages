// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'generated.dart';

void main() {
  runApp(const ExampleApp());
}

/// A trivial example that validates that Pigeon is able to successfully call
/// into native code.
///
/// Actual testing is all done in the integration tests, which run in the
/// context of the example app but don't actually rely on this class.
class ExampleApp extends StatefulWidget {
  /// Creates a new example app.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late final HostIntegrationCoreApi api;
  String status = 'Calling...';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    api = HostIntegrationCoreApi();
    try {
      // Make a single trivial call just to validate that everything is wired
      // up.
      await api.noop();
    } catch (e) {
      setState(() {
        status = 'Failed: $e';
      });
      return;
    }
    setState(() {
      status = 'Success!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pigeon integration tests')),
        body: Center(child: Text(status)),
      ),
    );
  }
}
