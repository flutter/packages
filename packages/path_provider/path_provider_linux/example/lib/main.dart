// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_linux/path_provider_linux.dart';

void main() {
  runApp(const MyApp());
}

/// Sample app
class MyApp extends StatefulWidget {
  /// Default Constructor
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _tempDirectory = 'Unknown';
  String? _downloadsDirectory = 'Unknown';
  String? _appSupportDirectory = 'Unknown';
  String? _appCacheDirectory = 'Unknown';
  String? _documentsDirectory = 'Unknown';
  final PathProviderLinux _provider = PathProviderLinux();

  @override
  void initState() {
    super.initState();
    initDirectories();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDirectories() async {
    String? tempDirectory;
    String? downloadsDirectory;
    String? appSupportDirectory;
    String? appCacheDirectory;
    String? documentsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      tempDirectory = await _provider.getTemporaryPath();
    } on PlatformException {
      tempDirectory = 'Failed to get temp directory.';
    }
    try {
      downloadsDirectory = await _provider.getDownloadsPath();
    } on PlatformException {
      downloadsDirectory = 'Failed to get downloads directory.';
    }

    try {
      documentsDirectory = await _provider.getApplicationDocumentsPath();
    } on PlatformException {
      documentsDirectory = 'Failed to get documents directory.';
    }

    try {
      appSupportDirectory = await _provider.getApplicationSupportPath();
    } on PlatformException {
      appSupportDirectory = 'Failed to get documents directory.';
    }

    try {
      appCacheDirectory = await _provider.getApplicationCachePath();
    } on PlatformException {
      appCacheDirectory = 'Failed to get cache directory.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _tempDirectory = tempDirectory;
      _downloadsDirectory = downloadsDirectory;
      _appSupportDirectory = appSupportDirectory;
      _appCacheDirectory = appCacheDirectory;
      _documentsDirectory = documentsDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Path Provider Linux example app')),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Temp Directory: $_tempDirectory\n'),
              Text('Documents Directory: $_documentsDirectory\n'),
              Text('Downloads Directory: $_downloadsDirectory\n'),
              Text('Application Support Directory: $_appSupportDirectory\n'),
              Text('Application Cache Directory: $_appCacheDirectory\n'),
            ],
          ),
        ),
      ),
    );
  }
}
