// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:dart_ui_web_shim/ui.dart' as ui;
import 'package:flutter/material.dart';

/// The viewId for the HtmlElementView rendered in this app.
/// This is overriden by the integration_tests before main runs so they can
/// control what ends up injected in the DOM.
@visibleForTesting
const String viewId = 'defined-in-tests';

void main() {
  // Take a look at the integration_test. We define this here, but the tests
  // define something else *before* this runs!
  ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    return html.DivElement()
      ..id = 'test-failed'
      ..innerText = 'Content defined in main!'
      ..style.width = '100%'
      ..style.height = '100%';
  });
  runApp(MyApp(key: UniqueKey()));
}

/// App for testing
class MyApp extends StatefulWidget {
  /// Constructs our app for testing with a key.
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: const <Widget>[
            SizedBox(
              child: HtmlElementView(
                viewType: 'defined-in-tests',
              ),
              width: 320,
              height: 240,
            ),
            Text('Testing... Look at the console output for results!'),
          ],
        ),
      ),
    );
  }
}
