// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:mustache_template/mustache_template.dart';

void main() {
  print('=== Basic Template ===');
  // #docregion Basic
  const source = '''
{{# names }}
  <div>{{ lastname }}, {{ firstname }}</div>
{{/ names }}
{{^ names }}
  <div>No names.</div>
{{/ names }}
''';

  final template = Template(source, name: 'example.html');

  final String output = template.renderString(<String, Object>{
    'names': <Map<String, String>>[
      <String, String>{'firstname': 'Greg', 'lastname': 'Lowe'},
      <String, String>{'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
  // #enddocregion Basic

  print('\n=== Nested Paths ===');
  // #docregion Nested
  final nested = Template('{{ author.name }}');

  print(
    nested.renderString(<String, Object>{
      'author': <String, String>{'name': 'Greg Lowe'},
    }),
  );
  // #enddocregion Nested

  print('\n=== Lambdas ===');
  // #docregion Lambda
  final lambdaTemplate = Template('{{# transform }}hello{{/ transform }}');

  // Standard function declaration avoids the need to ignore linter rules
  String lambda(LambdaContext ctx) => ctx.renderString().toUpperCase();

  print(lambdaTemplate.renderString(<String, Object>{'transform': lambda}));
  // #enddocregion Lambda
}
