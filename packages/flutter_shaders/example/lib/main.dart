// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() async {
  final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset('shaders/inkwell.frag');
  runApp(MyApp(program: program));
}

/// The main application widget for the shader demo.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp] demo widget.
  const MyApp({super.key, required this.program});

  /// The fragment program used to power shader effects.
  final ui.FragmentProgram program;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: ShaderInkFeatureFactory(program, (
          shader, {
          required double animation,
          required Color color,
          required Offset position,
          required Size referenceBoxSize,
          required double targetRadius,
          required TextDirection textDirection,
        }) {
          shader.setFloatUniforms(
            (uniforms) => uniforms
              ..setFloat(animation)
              ..setColor(color, premultiply: true)
              ..setFloat(targetRadius)
              ..setOffset(position),
          );
        }),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// The home page widget displaying counter and shader effects.
class MyHomePage extends StatefulWidget {
  /// Creates the home page with a given [title].
  const MyHomePage({super.key, required this.title});

  /// The title displayed in the AppBar.
  final String title;

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
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
