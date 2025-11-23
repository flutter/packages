// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// For clarity, this example uses the text representation of the sample remote
/// widget library, and parses it locally. To do this, [parseLibraryFile] is
/// used. In production, this is strongly discouraged since it is 10x slower
/// than using [decodeLibraryBlob] to parse the binary version of the format.
import 'package:rfw/formats.dart' show parseLibraryFile;

import 'package:rfw/rfw.dart';

void main() {
  runApp(const Example());
}

// The "#docregion" comment helps us keep this code in sync with the
// excerpt in the rfw package's README.md file.
//
// #docregion Example
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  // Normally this would be obtained dynamically, but for this example
  // we hard-code the "remote" widgets into the app.
  //
  // Also, normally we would decode this with [decodeLibraryBlob] rather than
  // parsing the text version using [parseLibraryFile]. However, to make it
  // easier to demo, this uses the slower text format.
  static final RemoteWidgetLibrary _remoteWidgets = parseLibraryFile('''
    // The "import" keyword is used to specify dependencies, in this case,
    // the built-in widgets that are added by initState below.
    import core.widgets;
    // The "widget" keyword is used to define a new widget constructor.
    // The "root" widget is specified as the one to render in the build
    // method below.
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
    // Local widget library:
    _runtime.update(coreName, createCoreWidgets());
    // Remote widget library:
    _runtime.update(mainName, _remoteWidgets);
    // Configuration data:
    _data.update('greet', <String, Object>{'name': 'World'});
  }

  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(mainName, 'root'),
      onEvent: (String name, DynamicMap arguments) {
        // The example above does not have any way to trigger events, but if it
        // did, they would result in this callback being invoked.
        debugPrint('user triggered event "$name" with data: $arguments');
      },
    );
  }
}

// #enddocregion Example
