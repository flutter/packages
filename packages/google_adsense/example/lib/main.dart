// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: flutter_style_todos

import 'package:flutter/material.dart';

import 'package:google_adsense/experimental/ad_unit_widget.dart';
// #docregion init
import 'package:google_adsense/google_adsense.dart';

void main() async {
  // Call `initialize` with your Publisher ID (pub-0123456789012345)
  // (See: https://support.google.com/adsense/answer/105516)
  await adSense.initialize('0123456789012345');

  runApp(const MyApp());
}
// #enddocregion init

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

/// The home screen
class MyHomePage extends StatefulWidget {
  /// Constructs a [HomeScreen]
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AdSense for Flutter demo app'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AdUnitWidget(
                configuration: AdUnitConfiguration.displayAdUnit(
                  // TODO: Replace with your Ad Unit ID
                  adSlot: '1234567890',
                  // Remove AdFormat to make ads limited by height
                  adFormat: AdFormat.AUTO,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
