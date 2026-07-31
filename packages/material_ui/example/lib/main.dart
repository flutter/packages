// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

import 'about/about_list_tile.0.dart';

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
      title: 'Material Example',
      home: const ExampleHome(),
      routes: <String, WidgetBuilder>{
        '/about/about_list_tile/0': (BuildContext context) => const AboutListTileExample(),
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
      appBar: AppBar(title: const Text('Tables & Trees')),
      body: Center(
        child: Column(
          children: <Widget>[
            const Spacer(flex: 3),
            FilledButton(
              onPressed: () {
                // Go to table explorer
                Navigator.of(context).pushNamed('/about/about_list_tile/0');
              },
              child: const Text('about/about_list_tile.0.dart'),
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
          ],
        ),
      ),
    );
  }
}

