// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const ExampleApp());
}

/// The example application widget showcasing shader sampling.
class ExampleApp extends StatefulWidget {
  /// Creates the [ExampleApp] widget.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  double _value = 2.0;

  void _onChanged(double newValue) {
    setState(() {
      _value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Shaders!')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SampledText(text: 'This is some sampled text', value: _value),
              Slider(value: _value, onChanged: _onChanged, min: 2, max: 50),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that renders text sampled and pixelated through a custom fragment shader.
class SampledText extends StatelessWidget {
  /// Creates a [SampledText] widget.
  const SampledText({super.key, required this.text, required this.value});

  /// The text content to display.
  final String text;

  /// The pixelation scale value applied to the shader.
  final double value;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder((context, shader, child) {
      return AnimatedSampler((image, size, canvas) {
        shader.setFloatUniforms((uniforms) {
          uniforms
            ..setFloat(value)
            ..setFloat(value)
            ..setSize(size);
        });

        shader.setImageSampler(0, image);

        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = shader);
      }, child: Text(text, style: const TextStyle(fontSize: 20)));
    }, assetKey: 'packages/flutter_shaders/shaders/pixelation.frag');
  }
}
