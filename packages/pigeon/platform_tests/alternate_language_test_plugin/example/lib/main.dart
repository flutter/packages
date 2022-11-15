// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:alternate_language_test_plugin/alternate_language_test_plugin.dart';
import 'package:flutter/material.dart';

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
  final AlternateLanguageTestPlugin _alternateLanguageTestPlugin =
      AlternateLanguageTestPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // TODO(tarrinneal): Call TestPlugin methods here for manual integration
    // testing, once they exist. See
    // https://github.com/flutter/flutter/issues/111505
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pigeon integration tests'),
        ),
        body: const Center(
          child: Text(
              'TODO, see https://github.com/flutter/flutter/issues/111505'),
        ),
      ),
    );
  }
}
