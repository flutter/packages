// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/event_channel_messages.g.dart';
import 'src/messages.g.dart';

// #docregion main-dart-flutter
class _ExampleFlutterApi implements MessageFlutterApi {
  @override
  String flutterMethod(String? aString) {
    return aString ?? '';
  }
}
// #enddocregion main-dart-flutter

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // #docregion main-dart-flutter
  MessageFlutterApi.setUp(_ExampleFlutterApi());
  // #enddocregion main-dart-flutter
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
  final ExampleHostApi _hostApi = ExampleHostApi();
  String? _hostCallResult;

  // #docregion main-dart
  final ExampleHostApi _api = ExampleHostApi();

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
      description: 'uri text',
    );
    try {
      return _api.sendMessage(message);
    } catch (e) {
      // handle error.
      return Future<bool>(() => true);
    }
  }
  // #enddocregion main-dart

  // #docregion main-dart-event
  Stream<String> getEventStream() async* {
    final Stream<PlatformEvent> events = streamEvents();
    await for (final PlatformEvent event in events) {
      switch (event) {
        case IntEvent():
          final int intData = event.data;
          yield '$intData, ';
        case StringEvent():
          final String stringData = event.data;
          yield '$stringData, ';
      }
    }
  }
  // #enddocregion main-dart-event

  @override
  void initState() {
    super.initState();
    _hostApi
        .getHostLanguage()
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
            if (Platform.isAndroid || Platform.isIOS)
              StreamBuilder<String>(
                stream: getEventStream(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data ?? '');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
              )
            else
              const Text('event channels are not supported on this platform'),
          ],
        ),
      ),
    );
  }
}
