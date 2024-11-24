// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

// #docregion init
import 'package:google_adsense/google_adsense.dart';

void main() {
  adSense.initialize('0556581589806023');
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AdSense for Flutter demo app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            // #docregion adUnit
            // Responsive ad example
            Container(
              child: adSense.adUnit(AdUnitConfiguration.displayAdUnit(
                  adSlot: '4773943862',
                  adFormat: AdFormat.AUTO, // Remove AdFormat to make ads limited by height
                  isFullWidthResponsive: false)),
            ),
            // Fixed size ad example
            SizedBox(
              height: 125,
              width: 125,
              child: adSense.adUnit(AdUnitConfiguration.displayAdUnit(
                  adSlot: '8937810400',
                  // adFormat: AdFormat.AUTO, // Not using AdFormat to make ads limited by height
                  isFullWidthResponsive: false)),
            ),
            // #enddocregion adUnit
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
