import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

/// Entry point of the cross_file example application.
void main() {
  runApp(const MyApp());
}

/// A minimal app that demonstrates creating and using an XFile.
class MyApp extends StatelessWidget {
  /// Creates the example app widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bytes = Uint8List.fromList('Hello from cross_file'.codeUnits);
    final file = XFile.fromData(
      bytes,
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
