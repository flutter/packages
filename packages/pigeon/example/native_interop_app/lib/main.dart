// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/messages.g.dart';

class _ExampleFlutterApi implements MessageFlutterApi {
  @override
  String flutterMethod(String? aString) {
    return aString ?? '';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MessageFlutterApi.setUp(_ExampleFlutterApi());
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
  final ExampleHostApi _hostApi = (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
      ? ExampleHostApi.createWithNativeInteropApi()
      : ExampleHostApi();
  String? _hostCallResult;

  final ExampleHostApi _api = (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
      ? ExampleHostApi.createWithNativeInteropApi()
      : ExampleHostApi();

  /// Calls host method `add` with provided arguments.
  Future<int> add(int a, int b) async {
    try {
      return await _api.add(a, b);
    } catch (e) {
      // handle error.
      return 0;
    }
  }

  /// Sends message through host api using `MessageData` class
  /// and api `sendMessage` method.
  Future<bool> sendMessage(String messageText) {
    final message = MessageData(
      code: Code.one,
      data: <String, String>{'header': 'this is a header'},
      messageDescription: 'uri text',
    );
    try {
      return _api.sendMessage(message);
    } catch (e) {
      // handle error.
      return Future<bool>(() => true);
    }
  }

  @override
  void initState() {
    super.initState();
    _hostApi
        .determineHostLanguage()
        .then((String response) {
          setState(() {
            _hostCallResult = 'Hello from $response!';
          });
        })
        .onError<PlatformException>((PlatformException error, StackTrace _) {
          setState(() {
            _hostCallResult = 'Failed to get host language: ${error.message}';
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
