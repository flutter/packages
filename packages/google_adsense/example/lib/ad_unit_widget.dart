// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: flutter_style_todos

import 'package:flutter/material.dart';

// #docregion import-widget
import 'package:google_adsense/experimental/ad_unit_widget.dart';
// #enddocregion import-widget
import 'package:google_adsense/google_adsense.dart';

void main() async {
  await adSense.initialize('0123456789012345');
  runApp(const MyApp());
}

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
              const Text(
                'Responsive Ad Constrained by width of 150px:',
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 150),
                padding: const EdgeInsets.only(bottom: 10),
                child:
                    // #docregion adUnit
                    AdUnitWidget(
                  configuration: AdUnitConfiguration.displayAdUnit(
                    // TODO: Replace with your Ad Unit ID
                    adSlot: '1234567890',
                    // Remove AdFormat to make ads limited by height
                    adFormat: AdFormat.AUTO,
                  ),
                ),
                // #enddocregion adUnit
              ),
              const Text(
                'Responsive Ad Constrained by height of 100px and width of 1200px (to keep ad centered):',
              ),
              // #docregion constraints
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 100, maxWidth: 1200),
                padding: const EdgeInsets.only(bottom: 10),
                child: AdUnitWidget(
                  configuration: AdUnitConfiguration.displayAdUnit(
                    // TODO: Replace with your Ad Unit ID
                    adSlot: '1234567890',
                    // Do not use adFormat to make ad unit respect height constraint
                    // adFormat: AdFormat.AUTO,
                  ),
                ),
              ),
              // #enddocregion constraints
              const Text(
                'Fixed 125x125 size Ad:',
              ),
              Container(
                height: 125,
                width: 125,
                padding: const EdgeInsets.only(bottom: 10),
                child: AdUnitWidget(
                  configuration: AdUnitConfiguration.displayAdUnit(
                    // TODO: Replace with your Ad Unit ID
                    adSlot: '1234567890',
                    isFullWidthResponsive: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
