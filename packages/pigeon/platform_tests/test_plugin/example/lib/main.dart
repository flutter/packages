// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:test_plugin/all_void.gen.dart';
import 'package:test_plugin/test_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: unused_field
  final TestPlugin _testPlugin = TestPlugin();
  late final AllVoidHostApi api;
  String status = 'Calling...';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    api = AllVoidHostApi();
    try {
      await api.doit();
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
