// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:linked_text/linked_text.dart';

// This example demonstrates highlighting URLs in a TextSpan tree instead of a
// flat String.

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
      home: const MyHomePage(title: 'Flutter LinkedText.spans Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

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
                  // #docregion linked_text_spans
                  LinkedText(
                    spans: <InlineSpan>[
                      TextSpan(
                        text: 'Check out https://www.',
                        style: DefaultTextStyle.of(context).style,
                        children: const <InlineSpan>[
                          TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                            text: 'flutter',
                          ),
                        ],
                      ),
                      TextSpan(
                        text: '.dev!',
                        style: DefaultTextStyle.of(context).style,
                      ),
                    ],
                  ),
                  // #enddocregion linked_text_spans
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
