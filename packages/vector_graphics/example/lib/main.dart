import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_graphics/vector_graphics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vector Graphics Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: VectorGraphic(
            bytesLoader: AssetBytesLoader(
                assetName: 'assets/tiger.bin', assetBundle: rootBundle),
          ),
        ),
      ),
    );
  }
}
