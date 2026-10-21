// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/native_interop_example.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigeon Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pigeon Demo'),
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
  final NativeInteropExampleApi _api = (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
      ? NativeInteropExampleApi.createWithNativeInteropApi()
      : NativeInteropExampleApi();
  String? _hostCallResult;

  @override
  void initState() {
    super.initState();
    _api
        .doSomething()
        .then((_) {
          setState(() {
            _hostCallResult = 'Called doSomething() successfully!';
          });
        })
        .onError<PlatformException>((PlatformException error, StackTrace _) {
          setState(() {
            _hostCallResult = 'Failed to call doSomething(): ${error.message}';
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_hostCallResult ?? 'Waiting for host language...'),
            if (_hostCallResult == null) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
