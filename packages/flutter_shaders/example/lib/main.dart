// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() async {
  final ui.FragmentProgram program =
      await ui.FragmentProgram.fromAsset('shaders/inkwell.frag');
  runApp(MyApp(program: program));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.program});

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
            shader.setFloat(0, animation);
            shader.setFloat(1, color.red / 255.0 * color.opacity);
            shader.setFloat(2, color.green / 255.0 * color.opacity);
            shader.setFloat(3, color.blue / 255.0 * color.opacity);
            shader.setFloat(4, color.opacity);
            shader.setFloat(5, targetRadius);
            shader.setFloat(6, position.dx);
            shader.setFloat(7, position.dy);
          })),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
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
      ),
    );
  }
}
