// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'staggered_layout_example.dart';
import 'wrap_layout_example.dart';

void main() {
  runApp(const MyApp());
}

/// Main example
class MyApp extends StatelessWidget {
  /// Main example constructor.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

/// The home page
class MyHomePage extends StatelessWidget {
  /// The home page constructor.
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const WrapExample(),
                ),
              ),
              child: const Text('Wrap Demo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const StaggeredExample(),
                ),
              ),
              child: const Text('Staggered Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
