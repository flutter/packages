import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final file = XFile.fromData(
      const [1, 2, 3],
      name: 'demo.txt',
      mimeType: 'text/plain',
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('cross_file example')),
        body: Center(
          child: Text('Created file: ${file.name}'),
        ),
      ),
    );
  }
}
