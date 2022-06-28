// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dartle.dart';

class _MyFlutterSearchApi extends MessageFlutterSearchApi {
  @override
  MessageSearchReply search(MessageSearchRequest input) {
    return MessageSearchReply()..result = 'Hello ${input.query}, from Flutter';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MessageFlutterSearchApi.setup(_MyFlutterSearchApi());
  runApp(const MyApp());
}

/// Main widget for the tests.
class MyApp extends StatelessWidget {
  /// Creates the main widget for the tests.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  String _message = '';
  MessageRequestState _state = MessageRequestState.pending;

  Future<void> _incrementCounter() async {
    final MessageSearchRequest request = MessageSearchRequest()
      ..query = 'Aaron';
    final MessageApi api = MessageApi();
    final MessageSearchReply reply = await api.search(request);
    setState(() {
      _message = reply.result ?? '(null)';
      _state = reply.state ?? MessageRequestState.failure;
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
              'Message:',
            ),
            Text(
              _message,
              style: Theme.of(context).textTheme.headline1,
            ),
            Text(
              _state.toString(),
              style: Theme.of(context).textTheme.headline1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.cake),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
