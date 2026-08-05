// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';

import 'activity_indicator/cupertino_activity_indicator.0.dart'
    as activity_indicator;

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({super.key});

  static const title = 'Cupertino Examples';

  final _examples = <_Example>[
    _Example(
      'activity_indicator/cupertino_activity_indicator.0.dart',
      (BuildContext context) =>
          const activity_indicator.CupertinoIndicatorApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(ExampleApp.title),
      ),
      child: Center(
        child: ListView(
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
    return CupertinoListTile(
      onTap: () {
        Navigator.of(context).pushNamed(_example.url);
      },
      title: Text(_example.filepath),
    );
  }
}

/// A self-contained Cupertino example.
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
