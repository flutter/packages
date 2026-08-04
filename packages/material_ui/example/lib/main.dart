// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

import 'about/about_list_tile.0.dart';
import 'action_buttons/action_icon_theme.0.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({super.key});

  static const title = 'Material Examples';

  final _examples = <_Example>[
    _Example(
      'about/about_list_tile.0.dart',
      (BuildContext context) => AboutListTileExample(),
    ),
    _Example(
      'action_buttons/action_icon_theme.0.dart',
      (BuildContext context) => ActionIconThemeExampleApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: _ExampleHome(examples: _examples),
      routes: <String, WidgetBuilder>{
        for (_Example example in _examples) example.url: example.builder,
      },
    );
  }
}

class _ExampleHome extends StatelessWidget {
  const _ExampleHome({required this._examples});

  final List<_Example> _examples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ExampleApp.title)),
      body: Center(
        child: Column(
          children: _examples
              .map((_Example example) => _ExampleListItem(example: example))
              .toList(),
        ),
      ),
    );
  }
}

/// One item that opens its example when tapped.
class _ExampleListItem extends StatelessWidget {
  const _ExampleListItem({required this._example});

  final _Example _example;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(_example.url);
      },
      title: Text(_example.filepath),
    );
  }
}

/// A self-contained Material example.
class _Example {
  const _Example(this.filepath, this.builder);

  final String filepath;
  final WidgetBuilder builder;

  String get url {
    final segments = filepath.split('/');
    assert(segments.length == 2);
    final directory = segments.first;
    final filename = segments.last;

    final filenameSegments = filename.split('.');
    assert(filenameSegments.length == 3);
    final number = filenameSegments[1];

    return '/$directory/$filename/$number';
  }
}
