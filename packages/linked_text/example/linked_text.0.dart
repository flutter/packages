// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:linked_text/linked_text.dart';

// This example demonstrates using LinkedText to make URLs open on tap.

void main() {
  runApp(const LinkedTextApp());
}

class LinkedTextApp extends StatelessWidget {
  const LinkedTextApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Link Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;
  // TODO(justinmc): Only the full URL works perfectly with Link! The other ones don't show the URL in the bottom of the browser and "open in new tab" doesn't work either. Do I need to parse partial URLs into their full https:// etc. form? It might not work how it would in the browser. You can do href="flutter.dev" in the browser. I need to understand more about how Link works internally, and why it has different behavior for partial URLs.
  static const String _text = 'Check out https://www.flutter.dev, or maybe just flutter.dev or www.flutter.dev.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Builder(
          builder: (BuildContext context) {
            return SelectionArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LinkedText(
                    text: _text,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
