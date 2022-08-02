// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Adaptive Layout Example',
      home: _MyHomePage(),
    ),
  );
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: 0,
      destinations: const <NavigationDestination> [
        NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
      ],
      smallBody: (_) => ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 250,
            color: const Color.fromARGB(255, 255, 201, 197),
          ),
        ),
      ),
      body: (_) => GridView.count(crossAxisCount: 2, children: <Widget>[
        for (int i = 0; i < 10; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color.fromARGB(255, 255, 201, 197),
              height: 400,
            ),
          )
      ]),
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      secondaryBody: (_) => Container(color: const Color.fromARGB(255, 234, 158, 192)),
    );
  }
}
