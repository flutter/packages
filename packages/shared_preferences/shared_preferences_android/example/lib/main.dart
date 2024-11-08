// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SharedPreferences Demo',
      home: SharedPreferencesDemo(),
    );
  }
}

class SharedPreferencesDemo extends StatefulWidget {
  const SharedPreferencesDemo({super.key});

  @override
  SharedPreferencesDemoState createState() => SharedPreferencesDemoState();
}

class SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  final SharedPreferencesAsyncPlatform _prefs =
      SharedPreferencesAsyncPlatform.instance!;
  final SharedPreferencesAsyncAndroidOptions options =
      const SharedPreferencesAsyncAndroidOptions();
  static const String _counterKey = 'counter';
  late Future<int> _counter;

  Future<void> _incrementCounter() async {
    final int? value = await _prefs.getInt(_counterKey, options);
    final int counter = (value ?? 0) + 1;

    setState(() {
      _counter = _prefs.setInt(_counterKey, counter, options).then((_) {
        return counter;
      });
    });
  }

  Future<void> _getAndSetCounter() async {
    setState(() {
      _counter = _prefs.getInt(_counterKey, options).then((int? counter) {
        return counter ?? 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getAndSetCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences Demo'),
      ),
      body: Center(
          child: FutureBuilder<int>(
              future: _counter,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        'Button tapped ${snapshot.data} time${snapshot.data == 1 ? '' : 's'}.\n\n'
                        'This should persist across restarts.',
                      );
                    }
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
