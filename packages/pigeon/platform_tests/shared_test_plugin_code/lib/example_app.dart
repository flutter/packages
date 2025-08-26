// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'generated.dart';
import 'src/generated/jni_tests.gen.dart';
import 'test_types.dart';

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
      // await api.noop();
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();
      api!.noop();
      // final BasicClass basicClass = BasicClass(anInt: 1, aString: '1');
      // final int receivedInt = api.echoInt(4);
      // print(receivedInt);
      // // ignore: avoid_js_rounded_ints
      // final int bigInt = api.echoInt(9999999999999999);
      // print(bigInt);
      // const double sentDouble = 2.0694;
      // final double receivedDouble = api.echoDouble(sentDouble);
      // print(receivedDouble);
      // final bool receivedBool = api.echoBool(true);
      // print(receivedBool);
      const String sentString = 'default';
      // final String sString = api.echoString(sentString);
      // print(sString);
      // final BasicClass receivedString = api.echoBasicClass(basicClass);
      // print(receivedString);
      final Object receString = api.echoObject(sentString);
      print(receString);
      final Object receivInt = api.echoObject(23);
      print(receivInt);
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
        appBar: AppBar(
          title: const Text('Pigeon integration tests'),
        ),
        body: Center(
          child: Text(status),
        ),
      ),
    );
  }
}
