import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pointer_interceptor_ios/pointer_interceptor_ios.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _pointerInterceptorIosPlugin = PointerInterceptorPluginIOS();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: PointerInterceptor(
          child: const Text('text'),
        )),
      ),
    );
  }
}
