// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:ios_platform_images/ios_platform_images.dart';

void main() => runApp(const MyApp());

/// Main widget for the example app.
class MyApp extends StatefulWidget {
  /// Default Constructor
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    IosPlatformImages.resolveURL('textfile')
        // ignore: avoid_print
        .then((String? value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    // #docregion Usage
    // "flutter" is a resource in Assets.xcassets.
    final Image xcassetImage = Image(
      image: IosPlatformImages.load('flutter'),
      semanticLabel: 'Flutter logo',
    );
    // #enddocregion Usage
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: xcassetImage,
        ),
      ),
    );
  }
}
