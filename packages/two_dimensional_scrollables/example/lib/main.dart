// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'table_view/table_explorer.dart';
import 'tree_view/tree_explorer.dart';

void main() {
  runApp(const ExampleApp());
}

/// A sample application that utilizes the TableView and TreeView APIs.
class ExampleApp extends StatelessWidget {
  /// Creates an instance of the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2D Scrolling Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        appBarTheme: AppBarTheme(backgroundColor: Colors.purple[50]),
      ),
      home: const ExampleHome(),
      routes: <String, WidgetBuilder>{
        '/table': (BuildContext context) => const TableExplorer(),
        '/tree': (BuildContext context) => const TreeExplorer(),
      },
    );
  }
}

/// The home page of the application, which directs to the tree or table
/// explorer.
class ExampleHome extends StatelessWidget {
  /// Creates a screen that demonstrates the TableView widget.
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables & Trees'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          const Spacer(flex: 3),
          FilledButton(
            onPressed: () {
              // Go to table explorer
              Navigator.of(context).pushNamed('/table');
            },
            child: const Text('TableView Explorer'),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              // Go to tree explorer
              Navigator.of(context).pushNamed('/tree');
            },
            child: const Text('TreeView Explorer'),
          ),
          const Spacer(flex: 3),
        ]),
      ),
    );
  }
}
