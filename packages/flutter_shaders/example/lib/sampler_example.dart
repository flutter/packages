import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
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
        appBar: AppBar(title: Text('Shaders!')),
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

class SampledText extends StatelessWidget {
  const SampledText({super.key, required this.text, required this.value});

  final String text;
  final double value;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder((context, shader, child) {
      return AnimatedSampler((image, size, canvas) {
        shader.setFloat(0, value);
        shader.setFloat(1, value);
        shader.setFloat(2, size.width);
        shader.setFloat(3, size.height);
        shader.setImageSampler(0, image);

        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..shader = shader,
        );
      }, child: Text(text, style: TextStyle(fontSize: 20)));
    }, assetKey: 'packages/flutter_shaders/shaders/pixelation.frag');
  }
}
