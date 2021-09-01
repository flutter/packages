// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:rfw/rfw.dart';

void main() {
  runApp(const Example());
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  static final RemoteWidgetLibrary _remoteWidgets = parseLibraryFile('''
    import core.widgets;
    widget root = Container(
      color: 0xFF002211,
      child: Center(
        child: Text(text: ["Hello, ", data.greet.name, "!"], textDirection: "ltr"),
      ),
    );
  ''');

  static const LibraryName coreName = LibraryName(<String>['core', 'widgets']);
  static const LibraryName mainName = LibraryName(<String>['main']);

  @override
  void initState() {
    super.initState();
    _runtime.update(coreName, createCoreWidgets());
    _runtime.update(mainName, _remoteWidgets);
    _data.update('greet', <String, Object>{'name': 'World'});
  }

  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(mainName, 'root'),
      onEvent: (String name, DynamicMap arguments) {
        debugPrint('user triggered event "$name" with data: $arguments');
      },
    );
  }
}
