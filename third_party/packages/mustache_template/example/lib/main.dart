// Copyright 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:mustache_template/mustache_template.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mustache Template Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mustache Template Demo'),
        ),
        body: Center(
          child: Text(_renderTemplate()),
        ),
      ),
    );
  }

  String _renderTemplate() {
    // #docregion basic-usage
    const source = '''
{{# names }}
{{ lastname }}, {{ firstname }}
{{/ names }}
{{^ names }}
No names.
{{/ names }}
''';

    final template = Template(source, name: 'example-template');

    return template.renderString({
      'names': [
        {'firstname': 'Greg', 'lastname': 'Lowe'},
        {'firstname': 'Bob', 'lastname': 'Johnson'},
      ]
    });
    // #enddocregion basic-usage
  }
}
