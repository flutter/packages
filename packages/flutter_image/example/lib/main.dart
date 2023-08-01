import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';

void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo'),
        ),
        body: const Image(
          image: NetworkImageWithRetry('https://picsum.photos/250?image=9'),
        ),
      ),
    );
  }
}